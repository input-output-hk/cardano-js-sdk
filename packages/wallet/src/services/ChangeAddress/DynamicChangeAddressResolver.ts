import * as Crypto from '@cardano-sdk/crypto';
import { BigNumber } from 'bignumber.js';
import { Cardano } from '@cardano-sdk/core';
import { ChangeAddressResolver, Selection } from '@cardano-sdk/input-selection';
import { DelegatedStake, DelegationTracker } from '../types';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { InvalidStateError } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { Observable, firstValueFrom } from 'rxjs';
import isEqual from 'lodash/isEqual.js';
import uniq from 'lodash/uniq.js';

/**
 * We are using buckets as an analogy to stake keys which are delegated to specific
 * pools with a specific amount of the total balance, and a target amount of balance.
 *
 * Buckets are considered filled if their current balance + allocated change is => than
 * their capacity and unfilled if their current balance + allocated change is < than their capacity.
 *
 * The bucket capacity is defined as a % (as specified in the delegation portfolio) of the total staked balance,
 * I.E if the total balance is 100 lovelace, and the portfolio % is 0.1, then capacity is set as 10 lovelace.
 */
type Bucket = {
  address: Cardano.PaymentAddress;
  change: Array<Cardano.TxOut>;
  capacity: bigint;
  filledAmount: bigint;
};

/**
 * Gets the coalesced coin amount from the given TxOut array.
 *
 * @param txOuts The TxOuts to coalesce.
 * @returns The coin value coalesced.
 */
const getBalanceInTxOuts = (txOuts: Array<Cardano.TxOut>) => {
  let balanceInBuckets = 0n;

  for (const txOut of txOuts) {
    balanceInBuckets += txOut.value.coins;
  }

  return balanceInBuckets;
};

/**
 * Aggregates all the coin balance in the input set from any input in the selection that belongs to us.
 *
 * @param knownAddresses The wallet know addresses.
 * @param inputs The inputs.
 */
const getSpentInInputs = (knownAddresses: Array<GroupedAddress>, inputs: Array<Cardano.Utxo>) =>
  inputs
    .filter((utxo) => knownAddresses.some((groupedAddress) => groupedAddress.address === utxo[0].address))
    .map((utxo) => utxo[1].value.coins)
    .reduce((a, b) => a + b, 0n);

/**
 * Aggregates all the coin balance in the output set from any output in the selection that belongs to us.
 *
 * @param knownAddresses The wallet know addresses.
 * @param outputs The outputs.
 */
const getBalanceFromOutputs = (knownAddresses: Array<GroupedAddress>, outputs: Array<Cardano.TxOut>) =>
  outputs
    .filter((out) => knownAddresses.some((groupedAddress) => groupedAddress.address === out.address))
    .map((out) => out.value.coins)
    .reduce((a, b) => a + b, 0n);

/**
 * Gets the spent amount by this selection from a given reward account.
 *
 * @param rewardAccount The reward account that we want to query.
 * @param inputs The inputs in the selection.
 */
const getSpentFromRewardAccount = (rewardAccount: Cardano.RewardAccount, inputs: Array<Cardano.Utxo>) =>
  inputs
    .filter((utxo) => {
      const address = Cardano.Address.fromString(utxo[0].address)?.asBase();

      // Address may not have stake credential.
      if (!address) return false;

      return (
        (Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Hash28ByteBase16) ===
        address.getStakeCredential().hash
      );
    })
    .map((utxo) => utxo[1].value.coins)
    .reduce((a, b) => a + b, 0n);

/**
 * Gets the deposited amount by this selection to a given reward account.
 *
 * @param rewardAccount The reward account that we want to query.
 * @param outputs The outputs in the selection.
 */
const getDepositToRewardAccount = (rewardAccount: Cardano.RewardAccount, outputs: Array<Cardano.TxOut>) =>
  outputs
    .filter((txOut) => {
      const address = Cardano.Address.fromString(txOut.address)?.asBase();

      // Address may not have stake credential.
      if (!address) return false;

      return (
        (Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Hash28ByteBase16) ===
        address.getStakeCredential().hash
      );
    })
    .map((txOut) => txOut.value.coins)
    .reduce((a, b) => a + b, 0n);

/**
 * Gets a payment address from our known addresses that match the given reward account.
 *
 * @param knownAddresses The wallet know addresses.
 * @param account The reward account we are looking for.
 */
const getAddressForRewardAccount = (knownAddresses: Array<GroupedAddress>, account: Cardano.RewardAccount) =>
  knownAddresses.find((groupedAddress) => groupedAddress.rewardAccount === account);

/**
 * Creates a list of buckets (one for each entry in the delegation portfolio). It will also compute the updated delegated amounts
 * and percentages after applying the changes of the selection to the wallet state.
 *
 * @param selection The current selection of inputs to satisfy the outputs in the transaction.
 * @param delegateAmounts The delegated stake amounts to each pool.
 * @param portfolio The current delegation portfolio.
 * @param knownAddresses The list of known addresses.
 */
const createBuckets = (
  selection: Selection,
  delegateAmounts: Array<DelegatedStake>,
  portfolio: Cardano.Cip17DelegationPortfolio,
  knownAddresses: Array<GroupedAddress>
): Array<Bucket> => {
  const buckets = new Array<Bucket>();
  const inputs = [...selection.inputs];
  const outputs = [...selection.outputs];

  // We need to 'apply' the transaction, by deducting the balance used in inputs from our addresses and adding any balance
  // in the outputs that are going to our addresses before distributing the change.
  const totalStakeDelegatedBeforeTx = delegateAmounts.map((delegated) => delegated.stake).reduce((a, b) => a + b, 0n);
  const balanceInChange = getBalanceInTxOuts(selection.change);
  const negativeBalance = getSpentInInputs(knownAddresses, inputs) + selection.fee;
  const positiveBalance = getBalanceFromOutputs(knownAddresses, outputs) + balanceInChange;
  const totalStake = totalStakeDelegatedBeforeTx + positiveBalance - negativeBalance;

  const totalWeight = portfolio.pools.map((pool) => pool.weight).reduce((sum, current) => sum + current, 0);
  const weightsAsPercent = new Map(portfolio.pools.map((pool) => [pool.id, pool.weight / totalWeight]));

  for (const delegated of delegateAmounts) {
    if (delegated.rewardAccounts.length === 0)
      throw new InvalidStateError(`No reward accounts delegating to pool '${delegated.pool.id}'.`);

    const account = delegated.rewardAccounts[0];
    const groupedAddress = getAddressForRewardAccount(knownAddresses, account);

    if (!groupedAddress) throw new InvalidStateError(`Reward account '${account}' unknown.`);

    const adjustedStake =
      delegated.stake - getSpentFromRewardAccount(account, inputs) + getDepositToRewardAccount(account, outputs);

    const percentageForPool = weightsAsPercent.get(delegated.pool.hexId);

    if (percentageForPool === undefined)
      throw new InvalidStateError(`Pool '${delegated.pool.id}' not found in the portfolio.`); // Shouldn't happen.

    buckets.push({
      address: groupedAddress.address,
      capacity: BigInt(new BigNumber(totalStake.toString()).multipliedBy(percentageForPool).toFixed(0, 0)),
      change: new Array<Cardano.TxOut>(),
      filledAmount: adjustedStake
    });
  }

  return buckets;
};

/**
 * Computes the gap of the given bucket. The gap is defined as the difference between bucket capacity and the currently filled
 * quantity, normalized as a number between 0 and 1.
 *
 * @param bucket The bucket to compute the gap for.
 */
const getBucketGap = (bucket: Bucket) => {
  // We need to avoid a division by 0 here. If capacity is 0, we just return a gap of 0.
  if (bucket.capacity === 0n) return new BigNumber('0');

  const capacity = new BigNumber(bucket.capacity.toString());
  const filledAmount = new BigNumber(bucket.filledAmount.toString());

  return capacity.minus(filledAmount).dividedBy(capacity);
};

/**
 * Picks the next bucket to fill, the bucket with the biggest gap will be chosen.
 *
 * @param buckets The list of available buckets.
 */
const pickBucket = (buckets: Array<Bucket>) =>
  buckets.sort((a, b) => {
    const gapA = getBucketGap(a);
    const gapB = getBucketGap(b);

    if (gapB.isGreaterThan(gapA)) {
      return 1;
    } else if (gapB.isLessThan(gapA)) {
      return -1;
    }
    return 0;
  })[0];

/**
 * Distributing change is related to a class of problems called "multiway number partitioning", which is NP-hard. If the problem
 * size is small (such as is our case), more exact methods such as dynamic programming or integer programming could be used,
 * but since this is still a POC, for simplicity’s sake, we are implementing a simplified and iterative approach to
 * solve this:
 *
 * 1 - Sort the change list in descending order. The reason to sort is to allocate the largest change outputs first to
 * the 'buckets' with the largest gap, and the smaller outputs to the buckets with smaller gaps, reducing wasted change (over flow).
 * 2 - For each change output, add it to the bucket that currently has the largest gap and is not overflowed.
 * 3 - Repeat until all change outputs are in a bucket.
 *
 * This will yield a reasonable approximation to the optimal distribution of change, giving priority to buckets with larger
 * gaps, but at the same time making sure we are not 'wasting' change by overflowing a single bucket too much.
 *
 * TODO: Explore more exact algorithms for change distribution. The approach we have followed here is a greedy heuristic, which can
 * provide reasonable solutions quickly but is not guaranteed to find the optimal solution. It might be feasible to use a more
 * rigorous approach such as integer programming, simulated annealing, or a complete search, which could examine all possible
 * assignments of change outputs to buckets and select the one that most closely matches the desired proportions. However,
 * these methods can be computationally intensive and may not be practical, and probably overkill for our use case (To be determined).
 *
 * @param changeOutputs The list of change outputs to be distributed.
 * @param prefilledBuckets The list of buckets, we should have one bucket per entry in the delegation distribution portfolio.
 * @returns A list of buckets with the given change outputs distributed in a way that closely matches the expected distribution (best effort).
 */
const distributeChange = (changeOutputs: Array<Cardano.TxOut>, prefilledBuckets: Array<Bucket>): Array<Bucket> => {
  const buckets = [...prefilledBuckets];
  const sortedOutputs = changeOutputs.sort((a, b) => {
    if (a.value.coins > b.value.coins) {
      return 1;
    } else if (a.value.coins < b.value.coins) {
      return -1;
    }
    return 0;
  });

  while (sortedOutputs.length > 0) {
    const bucket = pickBucket(buckets);
    const selected = sortedOutputs.splice(0, 1)[0];
    bucket.change.push(selected);
    bucket.filledAmount += selected.value.coins;
  }

  for (const bucket of buckets) {
    bucket.change = bucket.change.map((txOut) => {
      txOut.address = bucket.address;
      return txOut;
    });
  }

  return buckets;
};

/**
 * Gets whether the portfolio pools matches the current stake distribution pools.
 *
 * @param portfolio The staking portfolio.
 * @param distribution the distribution.
 * @returns true if both matches, otherwise; false.
 */
export const delegationMatchesPortfolio = (
  portfolio: Cardano.Cip17DelegationPortfolio,
  distribution: DelegatedStake[]
): boolean => {
  const portfolioPools = uniq(portfolio.pools.map((cip17Pool) => cip17Pool.id)).sort();
  const delegationPools = uniq(distribution.map((delegatedStake) => delegatedStake.pool.hexId)).sort();

  return isEqual(portfolioPools, delegationPools);
};

/** Gets the current delegation portfolio. */
export type GetDelegationPortfolio = () => Promise<Cardano.Cip17DelegationPortfolio | null>;

/** Resolves the address to be used for change. */
export class DynamicChangeAddressResolver implements ChangeAddressResolver {
  readonly #getDelegationPortfolio: GetDelegationPortfolio;
  readonly #delegationDistribution: DelegationTracker['distribution$'];
  readonly #addresses$: Observable<GroupedAddress[]>;
  readonly #logger: Logger;

  /**
   * Initializes a new instance of the StakeDistributionChangeAddressResolver.
   *
   * @param addresses$ The wallet known addresses.
   * @param delegationDistribution The wallet delegation distribution observable.
   * @param getDelegationPortfolio The current delegation portfolio.
   * @param logger The logger instance.
   */
  constructor(
    addresses$: Observable<GroupedAddress[]>,
    delegationDistribution: DelegationTracker['distribution$'],
    getDelegationPortfolio: GetDelegationPortfolio,
    logger: Logger
  ) {
    this.#getDelegationPortfolio = getDelegationPortfolio;
    this.#delegationDistribution = delegationDistribution;
    this.#addresses$ = addresses$;
    this.#logger = logger;
  }

  /** Resolve the change addresses for change outputs that better maintains the desired stake distribution. */
  async resolve(selection: Selection): Promise<Array<Cardano.TxOut>> {
    const delegationDistribution = [...(await firstValueFrom(this.#delegationDistribution)).values()];
    let portfolio = await this.#getDelegationPortfolio();
    const addresses = await firstValueFrom(this.#addresses$);
    let updatedChange = [...selection.change];

    if (addresses.length === 0) throw new InvalidStateError('The wallet has no known addresses.');

    // If the wallet is not delegating to any pool, fall back to giving all change to the first derived address.
    if (delegationDistribution.length === 0) {
      updatedChange = updatedChange.map((txOut) => {
        txOut.address = addresses[0].address;
        return txOut;
      });

      return updatedChange;
    }

    // If only one delegation is found, assign all change to that reward account.
    if (delegationDistribution.length === 1) {
      if (delegationDistribution[0].rewardAccounts.length === 0)
        throw new InvalidStateError(`No reward accounts delegating to pool '${delegationDistribution[0].pool.id}'.`);

      // Several reward accounts could be delegated to the same pool, in this case it doesn't
      // matter which one we chose to place the stake at.
      const groupedAddress = addresses.find(
        (address) => address.rewardAccount === delegationDistribution[0].rewardAccounts[0]
      );

      if (!groupedAddress)
        throw new InvalidStateError(`Reward account '${delegationDistribution[0].rewardAccounts[0]}' unknown.`);

      updatedChange = updatedChange.map((txOut) => {
        txOut.address = groupedAddress.address;
        return txOut;
      });

      return updatedChange;
    }

    // If the portfolio doesn't match the current delegation (same pools), this strategy won't work, we can't guess
    // where to put the balance, we will fall back to even distribution and log a warning.
    if (!portfolio || !delegationMatchesPortfolio(portfolio, delegationDistribution)) {
      this.#logger.warn('The portfolio doesnt match current wallet delegation.');
      this.#logger.warn(`Portfolio: ${portfolio}`);

      const pools = delegationDistribution.map((stake) => ({
        id: stake.pool.hexId,
        weight: 1 / delegationDistribution.length
      }));

      portfolio = { name: 'Default Portfolio', pools };
    }

    const buckets = createBuckets(selection, delegationDistribution, portfolio, addresses);
    const updatedBuckets = distributeChange(selection.change, buckets);

    updatedChange = new Array<Cardano.TxOut>();

    for (const bucket of updatedBuckets) {
      updatedChange = [...updatedChange, ...bucket.change];
    }

    return updatedChange;
  }
}
