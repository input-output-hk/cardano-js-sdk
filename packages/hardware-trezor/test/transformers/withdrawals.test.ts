import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import {
  contextWithKnownAddresses,
  contextWithoutKnownAddresses,
  coreWithdrawalWithKeyHashCredential,
  coreWithdrawalWithScriptHashCredential,
  stakeKeyHash,
  stakeScriptHash
} from '../testData.js';
import { mapWithdrawals, toTrezorWithdrawal } from '../../src/transformers/index.js';
import type { Cardano } from '@cardano-sdk/core';

describe('withdrawals', () => {
  describe('mapWithdrawals', () => {
    it('returns an empty array if there are no withdrawals', async () => {
      const withdrawals: Cardano.Withdrawal[] = [];
      const txIns = mapWithdrawals(withdrawals, contextWithKnownAddresses);
      expect(txIns).toEqual([]);
    });

    it('can map a a set of withdrawals', async () => {
      const withdrawals = await mapWithdrawals(
        [coreWithdrawalWithKeyHashCredential, coreWithdrawalWithKeyHashCredential, coreWithdrawalWithKeyHashCredential],
        contextWithKnownAddresses
      );

      const expectedWithdrawal = {
        amount: '5',
        path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0]
      };
      expect(withdrawals).toEqual([expectedWithdrawal, expectedWithdrawal, expectedWithdrawal]);
    });
  });

  describe('toTrezorWithdrawals', () => {
    it('can map a withdrawal with known address', async () => {
      const withdrawal = toTrezorWithdrawal(coreWithdrawalWithKeyHashCredential, contextWithKnownAddresses);
      expect(withdrawal).toEqual({
        amount: '5',
        path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0]
      });
    });

    it('can map a withdrawal with unknown address', async () => {
      const withdrawal = toTrezorWithdrawal(coreWithdrawalWithKeyHashCredential, contextWithoutKnownAddresses);
      expect(withdrawal).toEqual({
        amount: '5',
        keyHash: stakeKeyHash
      });
    });

    it('can map a withdrawal with script credential', async () => {
      const withdrawal = toTrezorWithdrawal(coreWithdrawalWithScriptHashCredential, contextWithoutKnownAddresses);
      expect(withdrawal).toEqual({
        amount: '5',
        scriptHash: stakeScriptHash
      });
    });
  });
});
