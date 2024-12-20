import * as Crypto from '@cardano-sdk/crypto';
import { AssetId, TokenMap } from '../Cardano';
import {
  AssetsMintedInspection,
  Inspector,
  ResolutionResult,
  assetsBurnedInspector,
  assetsMintedInspector,
  resolveInputs,
  totalAddressInputsValueInspector,
  totalAddressOutputsValueInspector
} from './txInspector';
import { BigIntMath } from '@cardano-sdk/util';
import { TimeoutError } from '../errors';
import { coalesceTokenMaps, subtractTokenMaps } from '../Asset/util';
import { coalesceValueQuantities } from './coalesceValueQuantities';
import { computeImplicitCoin } from '../Cardano/util';
import { promiseTimeout } from './promiseTimeout';
import { subtractValueQuantities } from './subtractValueQuantities';
import { tryGetAssetInfos } from './tryGetAssetInfos';
import type * as Cardano from '../Cardano';
import type { AssetInfoWithAmount } from './tokenTransferInspector';
import type { AssetProvider } from '../Provider';
import type { Logger } from 'ts-log';
import type { Milliseconds } from './time';

interface TransactionSummaryInspectorArgs {
  addresses: Cardano.PaymentAddress[];
  rewardAccounts: Cardano.RewardAccount[];
  inputResolver: Cardano.InputResolver;
  protocolParameters: Cardano.ProtocolParameters;
  assetProvider: AssetProvider;
  dRepKeyHash?: Crypto.Ed25519KeyHashHex;
  timeout: Milliseconds;
  logger: Logger;
}

export type TransactionSummaryInspection = {
  assets: Map<Cardano.AssetId, AssetInfoWithAmount>;
  /**
   * Spent amount from the wallet's perspective, computed as `own outputs - (own inputs + withdrawals)`.
   * Withdrawals are a type of "own input", and are accounted for when computing the wallet spent amount.
   * Positive when the wallet is receiving funds, negative when the wallet is sending funds.
   */
  coins: Cardano.Lovelace;
  collateral: Cardano.Lovelace;
  deposit: Cardano.Lovelace;
  returnedDeposit: Cardano.Lovelace;
  fee: Cardano.Lovelace;
  unresolved: {
    inputs: Cardano.TxIn[];
    value: Cardano.Value;
  };
};

export type TransactionSummaryInspector = (
  args: TransactionSummaryInspectorArgs
) => Inspector<TransactionSummaryInspection>;

type IntoTokenTransferValueProps = {
  assetProvider: AssetProvider;
  logger: Logger;
  timeout: Milliseconds;
  tokenMap?: TokenMap;
};

/**
 * Gets the collateral specified for this transaction.
 *
 * @param tx transaction to inspect.
 * @param inputResolver input resolver.
 * @param addresses addresses to inspect.
 */
export const getCollateral = async (
  tx: Cardano.Tx,
  inputResolver: Cardano.InputResolver,
  addresses: Cardano.PaymentAddress[]
): Promise<Cardano.Lovelace> => {
  if (!tx.body.collaterals || tx.body.collaterals.length === 0) return 0n;

  const resolvedCollateralInputs = (await resolveInputs(tx.body.collaterals, inputResolver)).resolvedInputs.filter(
    (input) => addresses.includes(input.address)
  );

  const totalOwnedValueAtRisk = BigIntMath.sum(resolvedCollateralInputs.map(({ value }) => value.coins));

  // If collateral return is specified, it means that not all the balance in the collateral inputs would be spent given a validation failure
  if (tx.body.collateralReturn) {
    // In the case of CIP-40 we need to sum all the collateral inputs we own, and check if the collateral return is coming to one of our addresses
    // If it is, we can simply subtract the sum of all our collateral inputs with the amount returned in the collateral returned, if the collateral return
    // is going somewhere else, it means we will lose whatever is on those outputs given a failure.
    if (!addresses.includes(tx.body.collateralReturn.address)) return totalOwnedValueAtRisk;

    // Should never be negative in a correctly balanced transaction, but let's do a sanity check anyway.
    return BigIntMath.max([totalOwnedValueAtRisk - tx.body.collateralReturn.value.coins, 0n]) ?? 0n;
  }

  // Legacy collaterals, we simply return the addition of the collateral inputs we own.
  return totalOwnedValueAtRisk;
};

const totalInputsValue = (resolvedInputs: ResolutionResult) => {
  const receivedInputsValues = resolvedInputs.resolvedInputs.map((input) => input.value);
  return coalesceValueQuantities(receivedInputsValues);
};

const totalOutputsValue = (outputs: Cardano.TxOut[]) => coalesceValueQuantities(outputs.map((output) => output.value));

const mintInspectionToTokenMap = (mintedAssets: AssetsMintedInspection) =>
  new Map<Cardano.AssetId, bigint>(
    mintedAssets.map((asset) => [AssetId.fromParts(asset.policyId, asset.assetName), asset.quantity])
  );

const getImplicitAssets = async (tx: Cardano.Tx) => {
  const mintedAssets = mintInspectionToTokenMap(await assetsMintedInspector(tx));
  const burnedAssets = mintInspectionToTokenMap(await assetsBurnedInspector(tx));

  return coalesceTokenMaps([mintedAssets, burnedAssets]);
};

const getUnaccountedFunds = async (
  tx: Cardano.Tx,
  resolvedInputs: ResolutionResult,
  implicitCoin: Cardano.Lovelace,
  fee: Cardano.Lovelace,
  implicitAssets: Cardano.TokenMap = new Map()
): Promise<Cardano.Value> => {
  const totalInputs = totalInputsValue(resolvedInputs);
  const totalOutputs = totalOutputsValue(tx.body.outputs);

  totalInputs.assets = coalesceTokenMaps([totalInputs.assets, implicitAssets]);
  totalInputs.coins += implicitCoin;
  totalOutputs.coins += fee;

  return subtractValueQuantities([totalOutputs, totalInputs]);
};

const intoAssetInfoWithAmount = async ({
  assetProvider,
  logger,
  timeout,
  tokenMap
}: IntoTokenTransferValueProps): Promise<Map<Cardano.AssetId, AssetInfoWithAmount>> => {
  if (!tokenMap) return new Map();

  const assetIds = tokenMap && tokenMap.size > 0 ? [...tokenMap.keys()] : [];
  const assetInfos = new Map<Cardano.AssetId, AssetInfoWithAmount>();

  if (assetIds.length > 0) {
    const assets = await tryGetAssetInfos({
      assetIds,
      assetProvider,
      logger,
      timeout
    });

    for (const asset of assets) {
      const amount = tokenMap?.get(asset.assetId) ?? 0n;
      assetInfos.set(asset.assetId, { amount, assetInfo: asset });
    }
  }

  return assetInfos;
};

/**
 * Inspects a transaction and produces a summary.
 *
 * @param {TransactionSummaryInspectorArgs} args The arguments for the inspector.
 */
export const transactionSummaryInspector: TransactionSummaryInspector =
  ({
    inputResolver,
    addresses,
    rewardAccounts,
    protocolParameters,
    assetProvider,
    dRepKeyHash,
    timeout,
    logger
  }: TransactionSummaryInspectorArgs) =>
  async (tx) => {
    let resolvedInputs: ResolutionResult;

    try {
      resolvedInputs = await promiseTimeout(resolveInputs(tx.body.inputs, inputResolver), timeout);
    } catch (error) {
      if (error instanceof TimeoutError) {
        logger.error('Error: Inputs resolution timed out');
      }

      resolvedInputs = {
        resolvedInputs: [],
        unresolvedInputs: tx.body.inputs
      };
    }

    const fee = tx.body.fee;

    const implicit = computeImplicitCoin(
      protocolParameters,
      { certificates: tx.body.certificates, withdrawals: tx.body.withdrawals },
      rewardAccounts || [],
      dRepKeyHash
    );

    const collateral = await getCollateral(tx, inputResolver, addresses);

    const withdrawals = implicit.withdrawals || 0n;
    const totalOutputValue = await totalAddressOutputsValueInspector(addresses)(tx);
    const totalInputValue = await totalAddressInputsValueInspector(addresses, inputResolver)(tx);
    const implicitCoin = withdrawals + (implicit.reclaimDeposit || 0n) - (implicit.deposit || 0n);
    const implicitAssets = await getImplicitAssets(tx);

    const diff = {
      assets: subtractTokenMaps([totalOutputValue.assets, totalInputValue.assets]),
      // Withdrawals are a type of "own input", which must be accounted for when computing the wallet spent amount.
      // `coins` represents the actual spent coins from the wallets perspective, using the formula `ownOutputs - ownInputs`.
      // deposit is like a foreign output, and reclaimDeposit is like a foreignInput,
      // so they do not need to be included in the computation.
      coins: totalOutputValue.coins - (totalInputValue.coins + withdrawals)
    };

    return {
      assets: await intoAssetInfoWithAmount({
        assetProvider,
        logger,
        timeout,
        tokenMap: diff.assets
      }),
      coins: diff.coins,
      collateral,
      deposit: implicit.deposit || 0n,
      fee,
      returnedDeposit: implicit.reclaimDeposit || 0n,
      unresolved: {
        inputs: resolvedInputs.unresolvedInputs,
        value: await getUnaccountedFunds(tx, resolvedInputs, implicitCoin, fee, implicitAssets)
      }
    };
  };
