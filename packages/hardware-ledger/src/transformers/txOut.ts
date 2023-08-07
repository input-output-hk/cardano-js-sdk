import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { CML, Cardano, Serialization, coreToCml } from '@cardano-sdk/core';
import { HexBlob, InvalidArgumentError, ManagedFreeableScope, Transform, usingAutoFree } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '../types';
import { mapTokenMap } from './assets';
import { paymentKeyPathFromGroupedAddress, stakeKeyPathFromGroupedAddress } from './keyPaths';

const toInlineDatum: Transform<Cardano.Datum, Ledger.Datum> = (datum) => ({
  datumHex: datum.toString(),
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

  if (knownAddress) {
    const spendingPath = paymentKeyPathFromGroupedAddress(knownAddress);
    const stakingPath = stakeKeyPathFromGroupedAddress(knownAddress);

    if (!stakingPath) throw new InvalidArgumentError('txOut', 'Missing staking key key path.');

    return {
      params: {
        params: {
          spendingPath,
          stakingPath
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

// TODO: Remove these functions once our serialization classes are completed.
const toCmlTxOut = (scope: ManagedFreeableScope, out: Cardano.TxOut): CML.TransactionOutput =>
  coreToCml.txOut(scope, out);

// TODO: Update these functions once our serialization classes are completed.
const getScriptHex = (scope: ManagedFreeableScope, cmlOut: CML.TransactionOutput): HexBlob | null => {
  const scriptRef = scope.manage(cmlOut.script_ref());

  if (!scriptRef) return null;

  const script = scope.manage(scriptRef.script());
  return HexBlob.fromBytes(script.to_bytes());
};

// TODO: Update these functions once our serialization classes are completed.
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
 * @param cmlOut The output to be verified.
 */
const isBabbage = (cmlOut: CML.TransactionOutput): boolean => {
  const reader = new Serialization.CborReader(HexBlob.fromBytes(cmlOut.to_bytes()));
  return reader.peekState() === Serialization.CborReaderState.StartMap;
};

export const toTxOut: Transform<Cardano.TxOut, Ledger.TxOutput, LedgerTxTransformerContext> = (txOut, context) =>
  usingAutoFree((scope) => {
    const cmlOut = toCmlTxOut(scope, txOut);
    const scriptHex = getScriptHex(scope, cmlOut);

    return isBabbage(cmlOut)
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
  });

export const mapTxOuts = (txOuts: Cardano.TxOut[], context: LedgerTxTransformerContext): Ledger.TxOutput[] =>
  txOuts.map((txOut) => toTxOut(txOut, context));
