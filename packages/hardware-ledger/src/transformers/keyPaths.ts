import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { CardanoKeyConst, GroupedAddress, util } from '@cardano-sdk/key-management';

export const paymentKeyPathFromGroupedAddress = (address: GroupedAddress): Ledger.BIP32Path => [
  util.harden(CardanoKeyConst.PURPOSE),
  util.harden(CardanoKeyConst.COIN_TYPE),
  util.harden(address.accountIndex),
  address.type,
  address.index
];

export const stakeKeyPathFromGroupedAddress = (address: GroupedAddress | undefined): Ledger.BIP32Path | null => {
  if (!address) return null;
  if (address && address.stakeKeyDerivationPath) {
    return [
      util.harden(CardanoKeyConst.PURPOSE),
      util.harden(CardanoKeyConst.COIN_TYPE),
      util.harden(address.accountIndex),
      address.stakeKeyDerivationPath.role,
      address.stakeKeyDerivationPath.index
    ];
  }

  return null;
};
