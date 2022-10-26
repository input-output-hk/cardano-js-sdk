import { AccountKeyDerivationPath, CardanoKeyConst, Ed25519KeyPair, KeyPair, KeyRole } from '../types';
import { CML, Cardano, util } from '@cardano-sdk/core';

export const harden = (num: number): number => 0x80_00_00_00 + num;

export const STAKE_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  role: KeyRole.Stake
};

export const toEd25519KeyPair = (bip32KeyPair: KeyPair): Ed25519KeyPair => {
  const pubKeyBytes = Buffer.from(bip32KeyPair.vkey, 'hex');
  const cmlPubKey = CML.Bip32PublicKey.from_bytes(pubKeyBytes);
  const vkey = Cardano.Ed25519PublicKey.fromHexBlob(util.bytesToHex(cmlPubKey.to_raw_key().as_bytes()));
  const prvKeyBytes = Buffer.from(bip32KeyPair.skey, 'hex');
  const cmlPrvKey = CML.Bip32PrivateKey.from_bytes(prvKeyBytes);
  const skey = Cardano.Ed25519PrivateKey.fromHexBlob(util.bytesToHex(cmlPrvKey.to_raw_key().as_bytes()));
  return {
    skey,
    vkey
  };
};

export interface DeriveAccountPrivateKeyProps {
  rootPrivateKey: CML.Bip32PrivateKey;
  accountIndex: number;
}

export const deriveAccountPrivateKey = ({
  rootPrivateKey,
  accountIndex
}: DeriveAccountPrivateKeyProps): CML.Bip32PrivateKey =>
  rootPrivateKey
    .derive(harden(CardanoKeyConst.PURPOSE))
    .derive(harden(CardanoKeyConst.COIN_TYPE))
    .derive(harden(accountIndex));
