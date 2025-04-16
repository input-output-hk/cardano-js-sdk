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

export const toTxOut: Transform<
  { txOut: Cardano.TxOut; index: number; isCollateral: boolean },
  Trezor.CardanoOutput,
  TrezorTxTransformerContext
> = (elem, context) => {
  const { txOut, index, isCollateral } = elem;
  const output = Serialization.TransactionOutput.fromCore(txOut);
  const scriptHex = getScriptHex(output);
  const format = isCollateral ? context?.collateralReturnFormat : context?.outputsFormat[index];
  const isBabbage = format === Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE;

  return {
    ...toDestination(txOut, context),
    amount: txOut.value.coins.toString(),
    datumHash: txOut.datumHash?.toString(),
    format,
    inlineDatum: isBabbage ? (txOut.datum ? getInlineDatum(txOut.datum) : undefined) : undefined,
    referenceScript: isBabbage ? scriptHex : undefined,
    tokenBundle: mapTokenMap(txOut.value.assets)
  };
};

export const mapTxOuts = (txOuts: Cardano.TxOut[], context: TrezorTxTransformerContext): Trezor.CardanoOutput[] =>
  txOuts.map((txOut, index) => toTxOut({ index, isCollateral: false, txOut }, context));
