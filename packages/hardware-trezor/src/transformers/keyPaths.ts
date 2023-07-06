import { BIP32Path } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, GroupedAddress, util } from '@cardano-sdk/key-management';
import { TrezorTxTransformerContext } from '../types';

/**
 * Constructs the hardened derivation path of the payment key for the
 * given grouped address of an HD wallet as specified in CIP 1852
 * https://cips.cardano.org/cips/cip1852/
 */
export const paymentKeyPathFromGroupedAddress = (address: GroupedAddress): BIP32Path => [
  util.harden(CardanoKeyConst.PURPOSE),
  util.harden(CardanoKeyConst.COIN_TYPE),
  util.harden(address.accountIndex),
  address.type,
  address.index
];

export const stakeKeyPathFromGroupedAddress = (address: GroupedAddress): BIP32Path | null =>
  address.stakeKeyDerivationPath
    ? [
        util.harden(CardanoKeyConst.PURPOSE),
        util.harden(CardanoKeyConst.COIN_TYPE),
        util.harden(address.accountIndex),
        address.stakeKeyDerivationPath.role,
        address.stakeKeyDerivationPath.index
      ]
    : null;

/**
 * Uses the given Trezor input resolver to resolve the payment key
 * path for known addresses for given input transaction.
 */
export const resolvePaymentKeyPathForTxIn = async (
  txIn: Cardano.TxIn,
  context?: TrezorTxTransformerContext
): Promise<BIP32Path | undefined> => {
  if (!context) return;
  const txOut = await context.inputResolver.resolveInput(txIn);
  const knownAddress = context.knownAddresses.find(({ address }) => address === txOut?.address);
  return knownAddress ? paymentKeyPathFromGroupedAddress(knownAddress) : undefined;
};
