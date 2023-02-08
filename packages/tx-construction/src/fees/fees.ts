import { CML, Cardano, coreToCml } from '@cardano-sdk/core';
import { OpaqueNumber, usingAutoFree } from '@cardano-sdk/util';

/**
 * The constant overhead of 160 bytes accounts for the transaction input and the entry in the UTxO map data
 * structure (20 words * 8 bytes).
 */
const MIN_ADA_CONSTANT_OVERHEAD = 160;

// TODO: Remove this serialization function once CBOR serialization has been added to the SDK.
/**
 * Serializes the given BigInt to CBOR format.
 *
 * @param bigInt The BigInt to be serialized.
 */
const serializeBigInt = (bigInt: string) =>
  usingAutoFree((scope) => scope.manage(CML.BigNum.from_str(bigInt)).to_bytes());

// TODO: Remove this serialization function once CBOR serialization has been added to the SDK.
/**
 * Serializes the given Tx Output to CBOR format.
 *
 * @param output The Tx Output to be serialized.
 */
const serializeTxOutput = (output: Cardano.TxOut) =>
  usingAutoFree((scope) => coreToCml.txOut(scope, output).to_bytes());

// TODO: Remove this serialization function once CBOR serialization has been added to the SDK.
/**
 * Serializes the given Tx to CBOR format.
 *
 * @param tx The Tx to be serialized.
 */
const serializeTx = (tx: Cardano.Tx) => usingAutoFree((scope) => coreToCml.tx(scope, tx).to_bytes());

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
 * Gets the minimum fee incurred by the scripts on the transaction.
 *
 * @param tx The transaction to compute the min script fee from.
 * @param exUnitsPrice The prices of the execution units.
 */
const minScriptFee = (tx: Cardano.Tx, exUnitsPrice: Cardano.Prices): bigint => {
  if (!tx.witness.redeemers) return BigInt(0);

  const totalExUnits = getTotalExUnits(tx.witness.redeemers);

  return BigInt(Math.ceil(totalExUnits.steps * exUnitsPrice.steps + totalExUnits.memory * exUnitsPrice.memory));
};

/**
 * The value of the min fee constant is a payable fee, regardless of the size of the transaction. This parameter was
 * primarily introduced to prevent Distributed-Denial-of-Service (DDoS) attacks. This constant makes such attacks
 * prohibitively expensive, and eliminates the possibility of an attacker generating millions of small transactions
 * to flood and crash the system.
 */
export type MinFeeConstant = OpaqueNumber<'MinFeeConstant'>;
export const MinFeeConstant = (value: number): MinFeeConstant => value as unknown as MinFeeConstant;

/**
 * Min fee coefficient reflects the dependence of the transaction cost on the size of the transaction. The larger
 * the transaction, the more resources are needed to store and process it.
 */
export type MinFeeCoefficient = OpaqueNumber<'MinFeeCoefficient'>;
export const MinFeeCoefficient = (value: number): MinFeeCoefficient => value as unknown as MinFeeCoefficient;

/**
 * Gets the minimum fee incurred by the transaction size.
 *
 * @param tx The transaction to compute the min fee from.
 * @param minFeeConstant The prices of the execution units.
 * @param minFeeCoefficient The prices of the execution units.
 */
const minNoScriptFee = (tx: Cardano.Tx, minFeeConstant: MinFeeConstant, minFeeCoefficient: MinFeeCoefficient) => {
  const txSize = serializeTx(tx).length;
  return BigInt(Math.ceil(txSize * minFeeCoefficient.valueOf() + minFeeConstant.valueOf()));
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
      BigInt(serializeTxOutput(output).length + MIN_ADA_CONSTANT_OVERHEAD + sizeDiff) * coinsPerUtxoByte;

    const newCoinSize = serializeBigInt(tentativeMinAda.toString()).length;

    isDone = latestSize === newCoinSize;
    latestSize = newCoinSize;
  }

  const sizeChange = latestSize - oldCoinSize;

  return BigInt(serializeTxOutput(output).length + MIN_ADA_CONSTANT_OVERHEAD + sizeChange) * coinsPerUtxoByte;
};

/**
 * Gets the minimum transaction fee for the given transaction given its size and its execution units budget.
 *
 * @param tx The transaction to compute the min fee from.
 * @param exUnitsPrice The current (given by protocol parameters) execution unit prices.
 * @param minFeeConstant The current (given by protocol parameters) constant fee that all transaction must pay.
 * @param minFeeCoefficient The current (given by protocol parameters) transaction size fee coefficient.
 */
export const minFee = (
  tx: Cardano.Tx,
  exUnitsPrice: Cardano.Prices,
  minFeeConstant: MinFeeConstant,
  minFeeCoefficient: MinFeeCoefficient
) => minNoScriptFee(tx, minFeeConstant, minFeeCoefficient) + minScriptFee(tx, exUnitsPrice);
