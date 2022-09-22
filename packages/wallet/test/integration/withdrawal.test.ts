import { Cardano } from '@cardano-sdk/core';
import { firstValueFrom, of } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';

import * as mocks from '../mocks';
import { RewardAccount, SingleAddressWallet, StakeKeyStatus, TransactionFailure, buildTx } from '../../src';
import { assertTxIsValid } from '../util';
import { createWallet } from './util';

describe('integration/withdrawal', () => {
  let wallet: SingleAddressWallet;
  let rewardAccounts: RewardAccount[];

  beforeEach(async () => {
    ({ wallet } = await createWallet());
    rewardAccounts = [
      {
        address: Cardano.RewardAccount('stake_test1uqu7qkgf00zwqupzqfzdq87dahwntcznklhp3x30t3ukz6gswungn'),
        delegatee: {
          currentEpoch: undefined,
          nextEpoch: undefined,
          nextNextEpoch: undefined
        },
        keyStatus: StakeKeyStatus.Registered,
        rewardBalance: 33_333n
      },
      {
        address: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
        delegatee: {
          currentEpoch: undefined,
          nextEpoch: undefined,
          nextNextEpoch: undefined
        },
        keyStatus: StakeKeyStatus.Unregistered,
        rewardBalance: 44_444n
      }
    ];
  });

  it('has balance', async () => {
    expect(typeof (await firstValueFrom(wallet.balance.utxo.total$))?.coins).toBe('bigint');
    expect(typeof (await firstValueFrom(wallet.balance.rewardAccounts.rewards$))).toBe('bigint');
  });

  it('does not set withdrawal when reward account has zero balance', async () => {
    rewardAccounts[0].rewardBalance = 0n;
    wallet.delegation.rewardAccounts$ = of([rewardAccounts[0]]);

    const txBuilder = buildTx({ logger, observableWallet: wallet });
    const tx = await txBuilder.addOutput(mocks.utxo[0][1]).build();
    assertTxIsValid(tx);

    expect(tx.body.withdrawals).toBeUndefined();
  });

  it(`does not withdraw from reward accounts with zero balance when 
      there are others with positive balance`, async () => {
    rewardAccounts[0].rewardBalance = 0n;
    wallet.delegation.rewardAccounts$ = of(rewardAccounts);

    const txBuilder = buildTx({ logger, observableWallet: wallet });
    const tx = await txBuilder.addOutput(mocks.utxo[0][1]).build();
    assertTxIsValid(tx);

    const withdrawWithReward: Cardano.Withdrawal = {
      quantity: rewardAccounts[1].rewardBalance,
      stakeAddress: rewardAccounts[1].address
    };
    expect(tx.body.withdrawals).toEqual([withdrawWithReward]);
  });

  it('can withdraw from multiple accounts in the same transaction', async () => {
    wallet.delegation.rewardAccounts$ = of(rewardAccounts);
    const txBuilder = buildTx({ logger, observableWallet: wallet });
    const tx = await txBuilder.addOutput(mocks.utxo[0][1]).build();
    assertTxIsValid(tx);

    const withdrawals: Cardano.Withdrawal[] = rewardAccounts.map(
      ({ rewardBalance: quantity, address: stakeAddress }) => ({ quantity, stakeAddress })
    );
    expect(tx.body.withdrawals).toEqual(withdrawals);
  });

  it('can submit transaction', async () => {
    const availableRewards = await firstValueFrom(wallet.balance.rewardAccounts.rewards$);
    const rewardAccount = (await firstValueFrom(wallet.addresses$))[0].rewardAccount;
    const txInternals = await wallet.initializeTx({
      certificates: [
        {
          __typename: Cardano.CertificateType.StakeKeyDeregistration,
          stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount)
        }
      ],
      outputs: new Set() // In a real transaction you would probably want to have some outputs
    });
    expect(typeof txInternals.body.fee).toBe('bigint');
    const tx = await wallet.finalizeTx({ tx: txInternals });

    expect(tx.body.withdrawals).toEqual([{ quantity: availableRewards, stakeAddress: rewardAccount }]);

    const confirmedSubscription = wallet.transactions.outgoing.confirmed$.subscribe((confirmedTx) => {
      if (confirmedTx === tx) {
        // Transaction successful
      }
    });

    const failedSubscription = wallet.transactions.outgoing.failed$.subscribe(({ tx: failedTx, reason }) => {
      if (failedTx === tx) {
        // Transaction failed because of reason, which is most likely:
        expect(reason === TransactionFailure.Timeout || reason === TransactionFailure.FailedToSubmit).toBe(true);
      }
    });

    try {
      await wallet.submitTx(tx);
    } catch {
      // Failed to submit transaction
    }

    // Cleanup
    confirmedSubscription.unsubscribe();
    failedSubscription.unsubscribe();
    wallet.shutdown();
  });
});
