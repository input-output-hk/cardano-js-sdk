import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  CONTEXT_WITHOUT_KNOWN_ADDRESSES,
  CONTEXT_WITH_KNOWN_ADDRESSES,
  rewardAccount,
  stakeKeyHash
} from '../testData';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import { mapWithdrawals, toWithdrawal } from '../../src/transformers';

describe('withdrawals', () => {
  describe('mapWithdrawals', () => {
    it('return null if given an undefined object as withdrawal', async () => {
      const withdrawals: Cardano.Withdrawal[] | undefined = undefined;
      const txIns = mapWithdrawals(withdrawals, CONTEXT_WITH_KNOWN_ADDRESSES);
      expect(txIns).toEqual(null);
    });

    it('can map a a set of withdrawals', async () => {
      const coreWithdrawal = {
        quantity: 5n,
        stakeAddress: rewardAccount
      };

      const withdrawals = await mapWithdrawals(
        [coreWithdrawal, coreWithdrawal, coreWithdrawal],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(withdrawals!.length).toEqual(3);

      for (const withdrawal of withdrawals!) {
        expect(withdrawal).toEqual({
          amount: 5n,
          stakeCredential: {
            keyPath: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(0),
              2,
              0
            ],
            type: Ledger.CredentialParamsType.KEY_PATH
          }
        });
      }
      expect.assertions(4);
    });
  });

  describe('toWithdrawals', () => {
    it('can map a withdrawal with known address', async () => {
      const withdrawal = toWithdrawal(
        {
          quantity: 5n,
          stakeAddress: rewardAccount
        },
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(withdrawal).toEqual({
        amount: 5n,
        stakeCredential: {
          keyPath: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0],
          type: Ledger.CredentialParamsType.KEY_PATH
        }
      });
    });

    it('can map a withdrawal with unknown address', async () => {
      const requiredSigner = toWithdrawal(
        {
          quantity: 5n,
          stakeAddress: rewardAccount
        },
        CONTEXT_WITHOUT_KNOWN_ADDRESSES
      );

      expect(requiredSigner).toEqual({
        amount: 5n,
        stakeCredential: {
          keyHashHex: stakeKeyHash,
          type: Ledger.CredentialParamsType.KEY_HASH
        }
      });
    });
  });
});
