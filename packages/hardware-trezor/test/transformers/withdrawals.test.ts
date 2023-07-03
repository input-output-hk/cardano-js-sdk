import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import {
  contextWithKnownAddresses,
  contextWithoutKnownAddresses,
  coreWithdrawalWithKeyHashCredential,
  coreWithdrawalWithScriptHashCredential,
  stakeKeyHash,
  stakeScriptHash
} from '../testData';
import { mapWithdrawals, toTrezorWithdrawal } from '../../src/transformers';

describe('withdrawals', () => {
  describe('mapWithdrawals', () => {
    it('return undefined if given an undefined object as withdrawal', async () => {
      const withdrawals: Cardano.Withdrawal[] | undefined = undefined;
      const txIns = mapWithdrawals(withdrawals, contextWithKnownAddresses);
      expect(txIns).toEqual(undefined);
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
