import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  CONTEXT_WITHOUT_KNOWN_ADDRESSES,
  CONTEXT_WITH_KNOWN_ADDRESSES,
  rewardAccount,
  rewardAccount2,
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

    it('can sort canonically and map a set of withdrawals', async () => {
      const coreWithdrawal = {
        quantity: 5n,
        stakeAddress: rewardAccount
      };
      const coreWithdrawal2 = {
        quantity: 5n,
        stakeAddress: rewardAccount2
      };

      const withdrawals = await mapWithdrawals([coreWithdrawal, coreWithdrawal2], CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(withdrawals!.length).toEqual(2);

      expect(withdrawals).toEqual([
        {
          amount: 5n,
          stakeCredential: {
            keyHashHex: '06e2ae44dff6770dc0f4ada3cf4cf2605008e27aecdb332ad349fda7',
            type: Ledger.CredentialParamsType.KEY_HASH
          }
        },
        {
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
        }
      ]);

      expect.assertions(2);
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
