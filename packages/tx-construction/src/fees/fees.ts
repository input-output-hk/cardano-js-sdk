import { Cardano, Serialization } from '@cardano-sdk/core';
import { ProtocolParametersForInputSelection } from '@cardano-sdk/input-selection';

/**
 * The constant overhead of 160 bytes accounts for the transaction input and the entry in the UTxO map data
 * structure (20 words * 8 bytes).
 */
const MIN_ADA_CONSTANT_OVERHEAD = 160;

/**
 * Serializes the given BigInt to CBOR format.
 *
 * @param bigInt The BigInt to be serialized.
 */
const serializeBigInt = (bigInt: string) => {
  const writer = new Serialization.CborWriter();

  writer.writeInt(BigInt(bigInt));

  return writer.encode();
};

/**
 * Serializes the given Tx Output to CBOR format.
 *
 * @param output The size in bytes of the serialized tx out.
 */
const serializeTxOutputSize = (output: Cardano.TxOut) =>
  Serialization.TransactionOutput.fromCore(output).toCbor().length / 2;

/**
 * Serializes the given Tx to CBOR format.
 *
 * @param tx The Tx to be serialized.
 */
const serializeTx = (tx: Cardano.Tx) => Buffer.from(Serialization.Transaction.fromCore(tx).toCbor(), 'hex');

/**
 * Gets the total transaction execution units budget from the redeemers.
 *
 * @param redeemers The transaction redeemer.
 */
const getTotalExUnits = (redeemers: Cardano.Redeemer[]): Cardano.ExUnits => {
  const totalExUnits: Cardano.ExUnits = { memory: 0, steps: 0 };

  for (const redeemer of redeemers) {
    totalExUnits.memory += redeemer.executionUnits.memory;
    totalExUnits.steps += redeemer.executionUnits.steps;
  }

  return totalExUnits;
};

/**
 * Starting in the Conway era, the ref script min fee calculation is given by the total size (in bytes) of
 * reference scripts priced according to a different, growing tiered pricing model.
 * See https://github.com/CardanoSolutions/ogmios/releases/tag/v6.5.0
 *
 * @param tx The transaction to compute the min ref script fee from.
 * @param resolvedInputs The resolved inputs of the transaction.
 * @param coinsPerRefScriptByte The price per byte of the reference script.
 */
const minRefScriptFee = (tx: Cardano.Tx, resolvedInputs: Cardano.Utxo[], coinsPerRefScriptByte: number): bigint => {
  if (coinsPerRefScriptByte === 0) return BigInt(0);

  let base: number = coinsPerRefScriptByte;
  const range = 25_600;
  const multiplier = 1.2;

  let totalRefScriptsSize = 0;

  const totalInputs = [...tx.body.inputs, ...(tx.body.referenceInputs ?? [])];
  for (const output of totalInputs) {
    const resolvedInput = resolvedInputs.find(
      (input) => input[0].txId === output.txId && input[0].index === output.index
    );

    if (resolvedInput && resolvedInput[1].scriptReference) {
      totalRefScriptsSize += Serialization.Script.fromCore(resolvedInput[1].scriptReference).toCbor().length / 2;
    }
  }

  let scriptRefFee = 0;
  while (totalRefScriptsSize > 0) {
    scriptRefFee += Math.ceil(Math.min(range, totalRefScriptsSize) * base);
    totalRefScriptsSize = Math.max(totalRefScriptsSize - range, 0);
    base *= multiplier;
  }

  return BigInt(scriptRefFee);
};

/**
 * Gets the minimum fee incurred by the scripts on the transaction.
 *
 * @param tx The transaction to compute the min script fee from.
 * @param exUnitsPrice The prices of the execution units.
 * @param resolvedInputs The resolved inputs of the transaction.
 * @param coinsPerRefScriptByte The price per byte of the reference script.
 */
const minScriptFee = (
  tx: Cardano.Tx,
  exUnitsPrice: Cardano.Prices,
  resolvedInputs: Cardano.Utxo[],
  coinsPerRefScriptByte: number
): bigint => {
  const scriptRefFee = minRefScriptFee(tx, resolvedInputs, coinsPerRefScriptByte);

  if (!tx.witness.redeemers) return BigInt(scriptRefFee);

  const totalExUnits = getTotalExUnits(tx.witness.redeemers);

  return (
    BigInt(Math.ceil(totalExUnits.steps * exUnitsPrice.steps + totalExUnits.memory * exUnitsPrice.memory)) +
    scriptRefFee
  );
};

/**
 * Gets the minimum fee incurred by the transaction size.
 *
 * @param tx The transaction to compute the min fee from.
 * @param minFeeConstant The prices of the execution units.
 * @param minFeeCoefficient The prices of the execution units.
 */
const minNoScriptFee = (tx: Cardano.Tx, minFeeConstant: number, minFeeCoefficient: number) => {
  const txSize = serializeTx(tx).length;
  return BigInt(Math.ceil(txSize * minFeeCoefficient + minFeeConstant));
};

/**
 * Gets the minimum ADA amount required to be contained in the given UTXO.
 *
 * Requiring some amount of ADA to be included in every UTXO (where that amount is based on the size of the UTXO,
 * in bytes) limits the maximum total size taken up by UTXO entries on the ledger at any given time.
 *
 * @param output The UTXO to get the minimum ADA amount.
 * @param coinsPerUtxoByte parameter used to adjust the maximum possible UTXO size by raising and lowering the min ada
 * required per UTXO.
 */
export const minAdaRequired = (output: Cardano.TxOut, coinsPerUtxoByte: bigint): bigint => {
  const oldCoinSize = serializeBigInt(output.value.coins.toString()).length;

  let latestSize = oldCoinSize;
  let isDone = false;

  while (!isDone) {
    const sizeDiff = latestSize - oldCoinSize;

    const tentativeMinAda =
      BigInt(serializeTxOutputSize(output) + MIN_ADA_CONSTANT_OVERHEAD + sizeDiff) * coinsPerUtxoByte;

    const newCoinSize = serializeBigInt(tentativeMinAda.toString()).length;

    isDone = latestSize === newCoinSize;
    latestSize = newCoinSize;
  }

  const sizeChange = latestSize - oldCoinSize;

  return BigInt(serializeTxOutputSize(output) + MIN_ADA_CONSTANT_OVERHEAD + sizeChange) * coinsPerUtxoByte;
};

/**
 * Gets the minimum transaction fee for the given transaction given its size and its execution units budget.
 *
 * @param tx The transaction to compute the min fee from.
 * @param resolvedInputs The resolved inputs of the transaction.
 * @param pparams The protocol parameters.
 */
export const minFee = (tx: Cardano.Tx, resolvedInputs: Cardano.Utxo[], pparams: ProtocolParametersForInputSelection) =>
  minNoScriptFee(tx, pparams.minFeeConstant, pparams.minFeeCoefficient) +
  minScriptFee(
    tx,
    pparams.prices,
    resolvedInputs,
    pparams.minFeeRefScriptCostPerByte ? Number(pparams.minFeeRefScriptCostPerByte) : 0
  );
