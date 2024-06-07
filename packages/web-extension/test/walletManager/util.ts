import { Bip32PublicKeyHex } from '@cardano-sdk/crypto';
import { Bip32WalletAccount } from '../../src';
import { KeyPurpose } from '@cardano-sdk/key-management';

export type WalletMetadata = { name: string };
export type AccountMetadata = { name: string };

export const createPubKey = (numWallet: number, accountIndex: number) =>
  Bip32PublicKeyHex(
    `${numWallet}a4f80dea2632a17c99ae9d8b934abf02643db5426b889fef14709c85e294aa12ac1f1560a893ea7937c5bfbfdeab459b1a396f1174b9c5a673a640d01880c3${accountIndex}`
  );

export const createAccount = (
  numWallet: number,
  accountIndex: number,
  purpose: KeyPurpose = KeyPurpose.STANDARD
): Bip32WalletAccount<AccountMetadata> => ({
  accountIndex,
  extendedAccountPublicKey: createPubKey(numWallet, accountIndex),
  metadata: { name: `Wallet ${numWallet} Account #${accountIndex}` },
  purpose
});
