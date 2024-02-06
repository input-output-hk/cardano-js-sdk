import * as Cardano from '../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { AssetId, TokenMap } from '../Cardano';
import { AssetInfoWithAmount } from './tokenTransferInspector';
import { AssetProvider } from '../Provider';
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
import { coalesceTokenMaps, subtractTokenMaps } from '../Asset/util';
import { coalesceValueQuantities } from './coalesceValueQuantities';
import { computeImplicitCoin } from '../Cardano/util';
import { subtractValueQuantities } from './subtractValueQuantities';

interface TransactionSummaryInspectorArgs {
  addresses: Cardano.PaymentAddress[];
  rewardAccounts: Cardano.RewardAccount[];
  inputResolver: Cardano.InputResolver;
  protocolParameters: Cardano.ProtocolParameters;
  assetProvider: AssetProvider;
  dRepKeyHash?: Crypto.Ed25519KeyHashHex;
}

export type TransactionSummaryInspection = {
  assets: Map<Cardano.AssetId, AssetInfoWithAmount>;
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
  implicitAssets: Cardano.TokenMap = new Map()
): Promise<Cardano.Value> => {
  const totalInputs = totalInputsValue(resolvedInputs);
  const totalOutputs = totalOutputsValue(tx.body.outputs);

  totalInputs.assets = coalesceTokenMaps([totalInputs.assets, implicitAssets]);
  totalInputs.coins += implicitCoin;

  return subtractValueQuantities([totalOutputs, totalInputs]);
};

const toAssetInfoWithAmount = async (
  assetProvider: AssetProvider,
  tokenMap?: TokenMap
): Promise<Map<Cardano.AssetId, AssetInfoWithAmount>> => {
  if (!tokenMap) return new Map();

  const assetIds = tokenMap && tokenMap.size > 0 ? [...tokenMap.keys()] : [];
  const assetInfos = new Map<Cardano.AssetId, AssetInfoWithAmount>();

  if (assetIds.length > 0) {
    const assets = await assetProvider.getAssets({
      assetIds,
      extraData: { nftMetadata: true, tokenMetadata: true }
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
  (args: TransactionSummaryInspectorArgs) => async (tx) => {
    const { inputResolver, addresses, rewardAccounts, protocolParameters, assetProvider, dRepKeyHash } = args;
    const resolvedInputs = await resolveInputs(tx.body.inputs, inputResolver);
    const fee = tx.body.fee;

    const implicit = computeImplicitCoin(
      protocolParameters,
      { certificates: tx.body.certificates, withdrawals: tx.body.withdrawals },
      rewardAccounts || [],
      dRepKeyHash
    );

    const collateral = await getCollateral(tx, inputResolver, addresses);

    const totalOutputValue = await totalAddressOutputsValueInspector(addresses)(tx);
    const totalInputValue = await totalAddressInputsValueInspector(addresses, inputResolver)(tx);
    const implicitCoin = (implicit.withdrawals || 0n) + (implicit.reclaimDeposit || 0n) - (implicit.deposit || 0n);
    const implicitAssets = await getImplicitAssets(tx);

    const diff = {
      assets: subtractTokenMaps([totalOutputValue.assets, totalInputValue.assets]),
      coins: totalOutputValue.coins - totalInputValue.coins
    };

    return {
      assets: await toAssetInfoWithAmount(assetProvider, diff.assets),
      coins: diff.coins,
      collateral,
      deposit: implicit.deposit || 0n,
      fee,
      returnedDeposit: implicit.reclaimDeposit || 0n,
      unresolved: {
        inputs: resolvedInputs.unresolvedInputs,
        value: await getUnaccountedFunds(tx, resolvedInputs, implicitCoin, implicitAssets)
      }
    };
  };
