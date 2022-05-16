import { AccountKeyDerivationPath, KeyRole } from '../types';
import { CSL } from '@cardano-sdk/core';
import { CardanoKeyConst } from '.';

export const harden = (num: number): number => 0x80_00_00_00 + num;

export const STAKE_KEY_DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  role: KeyRole.Stake
};

export const deriveAccountPrivateKey = (rootPrivateKey: CSL.Bip32PrivateKey, accountIndex: number) =>
  rootPrivateKey
    .derive(harden(CardanoKeyConst.PURPOSE))
    .derive(harden(CardanoKeyConst.COIN_TYPE))
    .derive(harden(accountIndex));
