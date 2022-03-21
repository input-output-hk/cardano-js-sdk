import { AccountKeyDerivationPath, KeyType } from '../types';
import { CSL } from '@cardano-sdk/core';

export const harden = (num: number): number => 0x80_00_00_00 + num;

export const STAKE_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  type: KeyType.Stake
};

export const deriveAccountPrivateKey = (rootPrivateKey: CSL.Bip32PrivateKey, accountIndex: number) =>
  rootPrivateKey.derive(harden(1852)).derive(harden(1815)).derive(harden(accountIndex));
