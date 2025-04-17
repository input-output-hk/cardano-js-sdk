import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { HexBlob, InvalidArgumentError, Transform } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '../types';
import { mapTokenMap } from './assets';
import { util } from '@cardano-sdk/key-management';

const toInlineDatum: Transform<Cardano.PlutusData, Ledger.Datum> = (datum) => ({
  datumHex: Serialization.PlutusData.fromCore(datum).toCbor(),
  type: Ledger.DatumType.INLINE
});

const toDatumHash: Transform<Cardano.DatumHash, Ledger.Datum> = (datumHash) => ({
  datumHashHex: datumHash.toString(),
  type: Ledger.DatumType.HASH
});

const toDestination: Transform<Cardano.TxOut, Ledger.TxOutputDestination, LedgerTxTransformerContext> = (
  txOut,
  context
) => {
  const knownAddress = context?.knownAddresses.find((address) => address.address === txOut.address);
  const isScriptAddress = Cardano.util.isScriptAddress(txOut.address);

  if (knownAddress && !isScriptAddress) {
    const paymentKeyPath = util.paymentKeyPathFromGroupedAddress(knownAddress);
    const stakeKeyPath = util.stakeKeyPathFromGroupedAddress(knownAddress);

    if (!stakeKeyPath) throw new InvalidArgumentError('txOut', 'Missing stake key key path.');

    return {
      params: {
        params: {
          spendingPath: paymentKeyPath,
          stakingPath: stakeKeyPath
        },
        type: Ledger.AddressType.BASE_PAYMENT_KEY_STAKE_KEY
      },
      type: Ledger.TxOutputDestinationType.DEVICE_OWNED
    };
  }

  return {
    params: {
      addressHex: Cardano.Address.fromBech32(txOut.address).toBytes()
    },
    type: Ledger.TxOutputDestinationType.THIRD_PARTY
  };
};

const getScriptHex = (output: Serialization.TransactionOutput): HexBlob | null => {
  const scriptRef = output.scriptRef();

  if (!scriptRef) return null;

  return scriptRef.toCbor();
};

export const toTxOut: Transform<
  { txOut: Cardano.TxOut; index: number; isCollateral: boolean },
  Ledger.TxOutput,
  LedgerTxTransformerContext
> = (elem, context) => {
  const { txOut, index, isCollateral } = elem;
  const output = Serialization.TransactionOutput.fromCore(txOut);
  const scriptHex = getScriptHex(output);
  const format = isCollateral ? context?.collateralReturnFormat : context?.outputsFormat[index];
  const isBabbageFormat = format === Ledger.TxOutputFormat.MAP_BABBAGE;

  return {
    amount: txOut.value.coins,
    destination: toDestination(txOut, context),
    tokenBundle: mapTokenMap(txOut.value.assets),
    ...(isBabbageFormat
      ? {
          datum: txOut.datumHash ? toDatumHash(txOut.datumHash) : txOut.datum ? toInlineDatum(txOut.datum) : null,
          format: Ledger.TxOutputFormat.MAP_BABBAGE,
          referenceScriptHex: scriptHex
        }
      : {
          datumHashHex: txOut.datumHash ?? null,
          format: Ledger.TxOutputFormat.ARRAY_LEGACY
        })
  };
};

export const mapTxOuts = (txOuts: Cardano.TxOut[], context: LedgerTxTransformerContext): Ledger.TxOutput[] =>
  txOuts.map((txOut, index) => toTxOut({ index, isCollateral: false, txOut }, context));
