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

export const toTxOut: Transform<Cardano.TxOut, Ledger.TxOutput, LedgerTxTransformerContext> = (txOut, context) => {
  const output = Serialization.TransactionOutput.fromCore(txOut);
  const scriptHex = getScriptHex(output);

  return context?.useBabbageOutputs
    ? {
        amount: txOut.value.coins,
        datum: txOut.datumHash ? toDatumHash(txOut.datumHash) : txOut.datum ? toInlineDatum(txOut.datum) : null,
        destination: toDestination(txOut, context),
        format: Ledger.TxOutputFormat.MAP_BABBAGE,
        referenceScriptHex: scriptHex,
        tokenBundle: mapTokenMap(txOut.value.assets)
      }
    : {
        amount: txOut.value.coins,
        datumHashHex: txOut.datumHash ? txOut.datumHash : null,
        destination: toDestination(txOut, context),
        format: Ledger.TxOutputFormat.ARRAY_LEGACY,
        tokenBundle: mapTokenMap(txOut.value.assets)
      };
};

export const mapTxOuts = (txOuts: Cardano.TxOut[], context: LedgerTxTransformerContext): Ledger.TxOutput[] =>
  txOuts.map((txOut) => toTxOut(txOut, context));
