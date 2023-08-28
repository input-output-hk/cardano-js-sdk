import * as Crypto from '@cardano-sdk/crypto';
import { AccountKeyDerivationPath, CardanoKeyConst, Ed25519KeyPair, KeyPair, KeyRole } from '../types';

export const harden = (num: number): number => 0x80_00_00_00 + num;

export const STAKE_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  role: KeyRole.Stake
};

export const DREP_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
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
}

export const deriveAccountPrivateKey = async ({
  rootPrivateKey,
  accountIndex,
  bip32Ed25519
}: DeriveAccountPrivateKeyProps): Promise<Crypto.Bip32PrivateKeyHex> =>
  await bip32Ed25519.derivePrivateKey(rootPrivateKey, [
    harden(CardanoKeyConst.PURPOSE),
    harden(CardanoKeyConst.COIN_TYPE),
    harden(accountIndex)
  ]);
