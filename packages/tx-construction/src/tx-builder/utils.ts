import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';

import {
  ComputeMinimumCoinQuantity,
  GreedyInputSelector,
  TokenBundleSizeExceedsLimit
} from '@cardano-sdk/input-selection';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { InvalidHereafterError } from './types';
import { RedeemersByType, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit } from '../input-selection';
import { RewardAccountWithPoolId, TxBuilderProviders } from '../types';
import { ValidityInterval } from '@cardano-sdk/core/dist/cjs/Cardano';
import minBy from 'lodash/minBy';

const COLLATERAL_AMOUNT_IN_LOVELACE = 5_000_000n;

/**
 * Sorts the given Utxo by coin size in descending order.
 *
 * @param lhs The left-hand side of the comparison operation.
 * @param rhs The left-hand side of the comparison operation.
 */
const sortByCoins = (lhs: Cardano.Utxo, rhs: Cardano.Utxo) => {
  if (lhs[1].value.coins > rhs[1].value.coins) {
    return -1;
  } else if (lhs[1].value.coins < rhs[1].value.coins) {
    return 1;
  }
  return 0;
};

/**
 * Gets whether the given value will produce a valid UTXO.
 *
 * @param out The value to be tested.
 * @param computeCoinQuantity callback that computes the minimum coin quantity for the given UTXO.
 * @param computeBundleSizeExceedsLimit callback that determines if a token bundle has exceeded its size limit.
 * @returns true if the value is valid; otherwise, false.
 */
const isValidValue = (
  out: Cardano.TxOut,
  computeCoinQuantity: ComputeMinimumCoinQuantity,
  computeBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit
): boolean => {
  let isValid = out.value.coins >= computeCoinQuantity(out);

  if (out.value.assets) isValid = isValid && !computeBundleSizeExceedsLimit(out.value.assets);

  return isValid;
};

export type RewardAccountsAndWeights = Map<Cardano.RewardAccount, number>;

/**
 * Searches the payment address with the smallest index associated to the reward accounts.
 *
 * @param rewardAccountsWithWeights reward account addresses and the portfolio distribution weights.
 * @param ownAddresses addresses to search in by reward account.
 * @returns GreedyInputSelector with the addresses and weights to use as change addresses.
 * @throws in case some reward accounts are not associated with any of the own addresses
 */
export const createGreedyInputSelector = (
  rewardAccountsWithWeights: RewardAccountsAndWeights,
  ownAddresses: GroupedAddress[]
) => {
  // select the address with smallest index for each reward account
  const addressesAndWeights = new Map(
    [...rewardAccountsWithWeights].map(([rewardAccount, weight]) => {
      const address = minBy(
        ownAddresses.filter((ownAddr) => ownAddr.rewardAccount === rewardAccount),
        ({ index }) => index
      );
      if (!address) {
        throw new Error(`Could not find any address associated with ${rewardAccount}.`);
      }
      return [address.address, weight];
    })
  );

  return new GreedyInputSelector({
    getChangeAddresses: () => Promise.resolve(addressesAndWeights)
  });
};

/** Registered and delegated < Registered < Unregistered */
export const sortRewardAccountsDelegatedFirst = (a: RewardAccountWithPoolId, b: RewardAccountWithPoolId): number => {
  const getScore = (acct: RewardAccountWithPoolId) => {
    let score = 2;
    if (acct.credentialStatus === Cardano.StakeCredentialStatus.Registered) {
      score = 1;
      if (acct.delegatee?.nextNextEpoch) {
        score = 0;
      }
    }
    return score;
  };

  return getScore(a) - getScore(b);
};

export const buildRedeemers = (redeemersData: RedeemersByType, maxExecutionUnits: Cardano.ExUnits) => {
  const redeemers = [];

  const knownRedeemers = [
    ...(redeemersData.mint ?? []),
    ...(redeemersData.vote ?? []),
    ...(redeemersData.propose ?? []),
    ...(redeemersData.certificate ?? []),
    ...(redeemersData.withdrawal ?? []),
    ...(redeemersData.spend ? [...redeemersData.spend.values()] : [])
  ];

  for (const value of knownRedeemers) {
    const index = Number.MAX_SAFE_INTEGER;

    redeemers.push({
      data: value.data,
      executionUnits:
        value.executionUnits.memory === 0 && value.executionUnits.steps === 0
          ? maxExecutionUnits
          : value.executionUnits,
      index,
      purpose: value.purpose
    });
  }

  return redeemers;
};

export const validateValidityInterval = (tip: Cardano.Tip, validityInterval?: ValidityInterval) => {
  if (!validityInterval?.invalidHereafter) {
    return;
  }

  if (tip.slot >= validityInterval.invalidHereafter) {
    throw new InvalidHereafterError();
  }
};

export const buildWitness = async (
  knownScripts: Map<Crypto.Hash28ByteBase16, Cardano.Script>,
  knownReferenceScripts: Set<Crypto.Hash28ByteBase16>,
  knownDatums: Map<Cardano.DatumHash, Cardano.PlutusData>,
  knownInlineDatums: Set<Cardano.DatumHash>,
  knownRedeemers: RedeemersByType,
  providers: TxBuilderProviders
  // eslint-disable-next-line max-params
): Promise<Cardano.Witness> => {
  const witnesses = { signatures: new Map() } as Cardano.Witness;

  if (knownDatums) {
    witnesses.datums = [];

    for (const [key, value] of knownDatums) {
      if (!knownInlineDatums.has(key)) witnesses.datums.push(value);
    }
  }

  if (knownScripts) {
    witnesses.scripts = [];

    for (const [key, value] of knownScripts) {
      if (!knownReferenceScripts.has(key)) witnesses.scripts.push(value);
    }
  }

  const { maxExecutionUnitsPerTransaction } = await providers.protocolParameters();

  if (knownRedeemers) {
    witnesses.redeemers = buildRedeemers(knownRedeemers, maxExecutionUnitsPerTransaction);
  }

  return witnesses;
};

export const computeCollateral = async (
  providers: TxBuilderProviders
): Promise<{ collaterals: Set<Cardano.TxIn>; collateralReturn: Cardano.TxOut }> => {
  const availableUtxo = (await providers.utxoAvailable()).sort(sortByCoins);

  const selectedCollateral = [];

  const { coinsPerUtxoByte, maxValueSize } = await providers.protocolParameters();

  let totalCoins = 0n;
  for (const utxo of availableUtxo) {
    selectedCollateral.push(utxo);
    totalCoins += utxo[1].value.coins;

    if (totalCoins > COLLATERAL_AMOUNT_IN_LOVELACE) {
      const returnAddress = selectedCollateral[0][1].address;

      const collateralValues = selectedCollateral.map((x) => x[1].value);
      const totalValueInCollateral = coalesceValueQuantities(collateralValues);
      const collateralReturnValue = { ...totalValueInCollateral };

      collateralReturnValue.coins -= COLLATERAL_AMOUNT_IN_LOVELACE;

      const collateralReturn = { address: returnAddress, value: collateralReturnValue };

      if (
        isValidValue(
          collateralReturn,
          computeMinimumCoinQuantity(coinsPerUtxoByte),
          tokenBundleSizeExceedsLimit(maxValueSize)
        )
      ) {
        return { collateralReturn, collaterals: new Set(selectedCollateral.map((x) => x[0])) };
      }
    }
  }

  throw new Error('No suitable collateral found');
};
