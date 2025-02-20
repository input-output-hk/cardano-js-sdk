import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { HexBlob, InvalidArgumentError, Transform } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '../types';
import { mapTokenMap } from './assets';
import { util } from '@cardano-sdk/key-management';

const isScriptAddress = (address: string): boolean => {
  const baseAddress = Cardano.Address.fromBech32(address).asBase();
  const paymentCredential = baseAddress?.getPaymentCredential();
  const stakeCredential = baseAddress?.getStakeCredential();
  return (
    paymentCredential?.type === Cardano.CredentialType.ScriptHash &&
    stakeCredential?.type === Cardano.CredentialType.ScriptHash
  );
};

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
  const isScriptWallet = isScriptAddress(txOut.address);

  if (knownAddress && !isScriptWallet) {
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

/**
 * There are currently two types of outputs supported by the ledger:
 *
 * legacy_transaction_output =
 *   [ address
 *   , amount : value
 *   , ? datum_hash : $hash32
 *   ]
 *
 * and
 *
 * post_alonzo_transaction_output =
 *   { 0 : address
 *   , 1 : value
 *   , ? 2 : datum_option ; New; datum option
 *   , ? 3 : script_ref   ; New; script reference
 *   }
 *
 * Legacy outputs are definite length arrays of three elements, however the new babbage outputs are definite length maps
 * of four elements.
 *
 * @param out The output to be verified.
 */
const isBabbage = (out: Serialization.TransactionOutput): boolean => {
  const reader = new Serialization.CborReader(out.toCbor());
  return reader.peekState() === Serialization.CborReaderState.StartMap;
};

export const toTxOut: Transform<Cardano.TxOut, Ledger.TxOutput, LedgerTxTransformerContext> = (txOut, context) => {
  const output = Serialization.TransactionOutput.fromCore(txOut);
  const scriptHex = getScriptHex(output);

  return isBabbage(output)
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
