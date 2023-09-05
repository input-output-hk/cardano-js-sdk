import { BIP32Path } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { TrezorTxTransformerContext } from '../types';
import { util } from '@cardano-sdk/key-management';

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
  return knownAddress ? util.paymentKeyPathFromGroupedAddress(knownAddress) : undefined;
};

// Resolves the stake key path for known addresses for the given reward address.
export const resolveStakeKeyPath = (
  rewardAddress: Cardano.RewardAddress | undefined,
  context: TrezorTxTransformerContext
): BIP32Path | null => {
  if (!rewardAddress) return null;
  const knownAddress = context.knownAddresses.find(
    ({ rewardAccount }) => rewardAccount === rewardAddress.toAddress().toBech32()
  );
  return util.stakeKeyPathFromGroupedAddress(knownAddress);
};
