import { BIP32Path } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { TrezorTxTransformerContext } from '../types';
import { TxInId, util } from '@cardano-sdk/key-management';

/** Uses the given Trezor input resolver to resolve the payment key path for known addresses for given input transaction. */
export const resolvePaymentKeyPathForTxIn = (
  txIn: Cardano.TxIn,
  context?: TrezorTxTransformerContext
): BIP32Path | undefined => {
  if (!context) return;
  const txInKeyPath = context?.txInKeyPathMap[TxInId(txIn)];
  if (txInKeyPath) {
    return util.accountKeyDerivationPathToBip32Path(context.accountIndex, txInKeyPath);
  }
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
