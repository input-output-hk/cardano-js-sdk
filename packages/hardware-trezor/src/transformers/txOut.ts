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

  if (!knownAddress) {
    return {
      address: txOut.address
    };
  }

  const paymentPath = util.paymentKeyPathFromGroupedAddress(knownAddress);
  const stakingPath = util.stakeKeyPathFromGroupedAddress(knownAddress);

  if (!stakingPath) throw new InvalidArgumentError('txOut', 'Missing staking key key path.');

  return {
    addressParameters: {
      addressType: Trezor.PROTO.CardanoAddressType.BASE,
      path: paymentPath,
      stakingPath
    }
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

const getInlineDatum = (datum: Cardano.PlutusData): string => Serialization.PlutusData.fromCore(datum).toCbor();

// TODO - use Transform (@cardano-sdk/util) once it is fixed. Even if prop is marked as optional it has to be added to fullfil Transform rules e.g. datumHash
export const toTxOut = (txOut: Cardano.TxOut, context: TrezorTxTransformerContext): Trezor.CardanoOutput => {
  const destination = toDestination(txOut, context);
  const output = Serialization.TransactionOutput.fromCore(txOut);
  const referenceScriptHex = getScriptHex(output);

  const trezorTxOut = isBabbage(output)
    ? {
        ...destination,
        ...(txOut.datumHash
          ? { datumHash: txOut.datumHash.toString() }
          : txOut.datum
          ? { inlineDatum: getInlineDatum(txOut.datum) }
          : undefined),
        ...(referenceScriptHex && { referenceScript: referenceScriptHex }),
        amount: txOut.value.coins.toString(),
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE
      }
    : {
        ...destination,
        ...(txOut.datumHash && { datumHash: txOut.datumHash.toString() }),
        amount: txOut.value.coins.toString(),
        format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
      };

  if (txOut.value.assets) {
    const tokenBundle = mapTokenMap(txOut.value.assets);
    Object.assign(trezorTxOut, { tokenBundle });
  }

  return trezorTxOut;
};

export const mapTxOuts = (txOuts: Cardano.TxOut[], context: TrezorTxTransformerContext): Trezor.CardanoOutput[] =>
  txOuts.map((txOut) => toTxOut(txOut, context));
