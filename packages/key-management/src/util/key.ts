import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountKeyDerivationPath,
  CardanoKeyConst,
  Ed25519KeyPair,
  GroupedAddress,
  KeyPair,
  KeyPurpose,
  KeyRole
} from '../types';
import { BIP32Path } from '@cardano-sdk/crypto';

export const harden = (num: number): number => 0x80_00_00_00 + num;

export const STAKE_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  purpose: KeyPurpose.STANDARD,
  role: KeyRole.Stake
};

export const DREP_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  purpose: KeyPurpose.STANDARD,
  role: KeyRole.DRep
};

export const toEd25519KeyPair = async (
  bip32KeyPair: KeyPair,
  provider: Crypto.Bip32Ed25519
): Promise<Ed25519KeyPair> => ({
  skey: await provider.getRawPrivateKey(bip32KeyPair.skey),
  vkey: await provider.getRawPublicKey(bip32KeyPair.vkey)
});

export interface DeriveAccountPrivateKeyProps {
  rootPrivateKey: Crypto.Bip32PrivateKeyHex;
  accountIndex: number;
  bip32Ed25519: Crypto.Bip32Ed25519;
  purpose: KeyPurpose;
}

interface GroupAddressKeyPath {
  address: GroupedAddress;
  purpose: KeyPurpose;
}

export const deriveAccountPrivateKey = async ({
  rootPrivateKey,
  accountIndex,
  bip32Ed25519,
  purpose
}: DeriveAccountPrivateKeyProps): Promise<Crypto.Bip32PrivateKeyHex> =>
  await bip32Ed25519.derivePrivateKey(rootPrivateKey, [
    harden(purpose),
    harden(CardanoKeyConst.COIN_TYPE),
    harden(accountIndex)
  ]);

// TODO: test
/**
 * Constructs the hardened derivation path for the specified
 * account key of an HD wallet as specified in CIP 1852 or CIP 1854
 * https://cips.cardano.org/cips/cip1852/
 * https://cips.cardano.org/cips/cip1854
 */
export const accountKeyDerivationPathToBip32Path = (
  accountIndex: number,
  { index, role, purpose }: AccountKeyDerivationPath
): BIP32Path => [harden(purpose), harden(CardanoKeyConst.COIN_TYPE), harden(accountIndex), role, index];

/**
 * Constructs the hardened derivation path of the payment key for the
 * given grouped address of an HD wallet as specified in CIP 1852 or CIP 1854
 * https://cips.cardano.org/cips/cip1852/
 * https://cips.cardano.org/cips/cip1854/
 */
export const paymentKeyPathFromGroupedAddress = ({ address, purpose }: GroupAddressKeyPath): BIP32Path => [
  harden(purpose),
  harden(CardanoKeyConst.COIN_TYPE),
  harden(address.accountIndex),
  address.type,
  address.index
];

/**
 * Constructs the hardened derivation path of the staking key for the
 * given grouped address of an HD wallet as specified in CIP 11
 * https://cips.cardano.org/cips/cip11/
 */
export const stakeKeyPathFromGroupedAddress = ({
  address,
  purpose
}: Partial<GroupAddressKeyPath>): BIP32Path | null => {
  if (!address?.stakeKeyDerivationPath || !purpose) return null;
  return [
    harden(purpose),
    harden(CardanoKeyConst.COIN_TYPE),
    harden(address.accountIndex),
    address.stakeKeyDerivationPath.role,
    address.stakeKeyDerivationPath.index
  ];
};
