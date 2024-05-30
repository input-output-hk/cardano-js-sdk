import * as Trezor from '@trezor/connect';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { GroupedAddress, util } from '@cardano-sdk/key-management';
import { HexBlob, InvalidArgumentError, Transform } from '@cardano-sdk/util';
import { TrezorTxOutputDestination, TrezorTxTransformerContext } from '../types';
import { mapTokenMap } from './assets';

const toDestination: Transform<Cardano.TxOut, TrezorTxOutputDestination, TrezorTxTransformerContext> = (
  txOut,
  context
) => {
  const knownAddress = context?.knownAddresses.find((address: GroupedAddress) => address.address === txOut.address);
  const purpose = knownAddress?.purpose;

  if (!knownAddress || !purpose) {
    return {
      address: txOut.address
    };
  }

  const paymentPath = util.paymentKeyPathFromGroupedAddress({ address: knownAddress, purpose });
  const stakingPath = util.stakeKeyPathFromGroupedAddress({ address: knownAddress, purpose });

  if (!stakingPath) throw new InvalidArgumentError('txOut', 'Missing staking key key path.');

  return {
    addressParameters: {
      addressType: Trezor.PROTO.CardanoAddressType.BASE,
      path: paymentPath,
      stakingPath
    }
  };
};

const getScriptHex = (output: Serialization.TransactionOutput): HexBlob | undefined => {
  const scriptRef = output.scriptRef();

  if (!scriptRef) return undefined;

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

const getInlineDatum = (datum: Cardano.PlutusData): string => Serialization.PlutusData.fromCore(datum).toCbor();

export const toTxOut: Transform<Cardano.TxOut, Trezor.CardanoOutput, TrezorTxTransformerContext> = (txOut, context) => {
  const destination = toDestination(txOut, context);
  const output = Serialization.TransactionOutput.fromCore(txOut);
  const scriptHex = getScriptHex(output);

  return isBabbage(output)
    ? {
        ...destination,
        amount: txOut.value.coins.toString(),
        datumHash: txOut.datumHash?.toString(),
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE,
        inlineDatum: txOut.datum ? getInlineDatum(txOut.datum) : undefined,
        referenceScript: scriptHex,
        tokenBundle: mapTokenMap(txOut.value.assets)
      }
    : {
        ...destination,
        amount: txOut.value.coins.toString(),
        datumHash: txOut.datumHash?.toString(),
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY,
        inlineDatum: undefined,
        referenceScript: undefined,
        tokenBundle: mapTokenMap(txOut.value.assets)
      };
};

export const mapTxOuts = (txOuts: Cardano.TxOut[], context: TrezorTxTransformerContext): Trezor.CardanoOutput[] =>
  txOuts.map((txOut) => toTxOut(txOut, context));
