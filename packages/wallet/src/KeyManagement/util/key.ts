import { AccountKeyDerivationPath, KeyType } from '../types';

export const harden = (num: number): number => 0x80_00_00_00 + num;

export const STAKE_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  type: KeyType.Stake
};
