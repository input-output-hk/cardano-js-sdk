import * as Trezor from 'trezor-connect';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { InvalidArgumentError, Transform } from '@cardano-sdk/util';
import { TrezorTxOutputDestination, TrezorTxTransformerContext } from '../types';
import { bip32PathToStrPath, paymentKeyPathFromGroupedAddress, stakingKeyPathFromGroupedAddress } from './keyPaths';
import { mapTokenMap } from './assets';

const toDestination: Transform<Cardano.TxOut, TrezorTxOutputDestination, TrezorTxTransformerContext> = (
  txOut,
  context
) => {
  const knownAddress = context?.knownAddresses.find((address: GroupedAddress) => address.address === txOut.address);

  if (knownAddress) {
    const paymentPath = paymentKeyPathFromGroupedAddress(knownAddress);
    const stakingPath = stakingKeyPathFromGroupedAddress(knownAddress);

    if (!stakingPath) throw new InvalidArgumentError('txOut', 'Missing staking key key path.');

    return {
      addressParameters: {
        addressType: Trezor.CardanoAddressType.BASE,
        path: bip32PathToStrPath(paymentPath),
        stakingPath: bip32PathToStrPath(stakingPath)
      }
    };
  }

  return {
    address: txOut.address
  };
};

// TODO - use Transform (@cardano-sdk/util) once it is fixed. Even if prop is marked as optional it has to be added to fullfil Transform rules e.g. datumHash
export const toTxOut = (txOut: Cardano.TxOut, context: TrezorTxTransformerContext): Trezor.CardanoOutput => {
  const destination = toDestination(txOut, context);
  const trezorTxOut = {
    ...destination,
    amount: txOut.value.coins.toString()
  };
  if (txOut.value.assets) {
    const tokenBundle = mapTokenMap(txOut.value.assets);
    Object.assign(trezorTxOut, { tokenBundle });
  }
  return trezorTxOut;
};

export const mapTxOuts = (txOuts: Cardano.TxOut[], context: TrezorTxTransformerContext): Trezor.CardanoOutput[] =>
  txOuts.map((txOut) => toTxOut(txOut, context));
