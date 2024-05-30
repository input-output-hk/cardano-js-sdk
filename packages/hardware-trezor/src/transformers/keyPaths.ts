import { BIP32Path } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, KeyPurpose, TxInId, util } from '@cardano-sdk/key-management';
import { TrezorTxTransformerContext } from '../types';

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

export const resolveStakeKeyPath = (
  rewardAddress: Cardano.RewardAddress,
  knownAddresses: GroupedAddress[],
  purpose: KeyPurpose
): BIP32Path | null => {
  const knownAddress = knownAddresses.find(
    ({ rewardAccount }) => rewardAccount === rewardAddress.toAddress().toBech32()
  );
  return util.stakeKeyPathFromGroupedAddress({
    address: knownAddress,
    purpose
  });
};
