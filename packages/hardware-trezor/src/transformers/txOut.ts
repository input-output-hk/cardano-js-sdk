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
  const isScriptAddress = Cardano.util.isScriptAddress(txOut.address);

  if (!knownAddress || isScriptAddress) {
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

const getScriptHex = (output: Serialization.TransactionOutput): HexBlob | undefined => {
  const scriptRef = output.scriptRef();

  if (!scriptRef) return undefined;

  return scriptRef.toCbor();
};

const getInlineDatum = (datum: Cardano.PlutusData): string => Serialization.PlutusData.fromCore(datum).toCbor();

export const toTxOut: Transform<Cardano.TxOut, Trezor.CardanoOutput, TrezorTxTransformerContext> = (txOut, context) => {
  const destination = toDestination(txOut, context);
  const output = Serialization.TransactionOutput.fromCore(txOut);
  const scriptHex = getScriptHex(output);

  return context?.useBabbageOutputs
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
