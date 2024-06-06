import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { TransactionFailure } from '../../src/index.js';
import { createWallet } from './util.js';
import { firstValueFrom, of } from 'rxjs';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';
import uniq from 'lodash/uniq.js';
import type { BaseWallet } from '../../src/index.js';

describe('integration/withdrawal', () => {
  let wallet: BaseWallet;
  let rewardAccounts: Cardano.RewardAccountInfo[];

  beforeEach(async () => {
    ({ wallet } = await createWallet());
    rewardAccounts = [
      {
        address: Cardano.RewardAccount('stake_test1uqu7qkgf00zwqupzqfzdq87dahwntcznklhp3x30t3ukz6gswungn'),
        credentialStatus: Cardano.StakeCredentialStatus.Registered,
        delegatee: {
          currentEpoch: undefined,
          nextEpoch: undefined,
          nextNextEpoch: undefined
        },
        rewardBalance: 33_333n
      },
      {
        address: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
        credentialStatus: Cardano.StakeCredentialStatus.Unregistered,
        delegatee: {
          currentEpoch: undefined,
          nextEpoch: undefined,
          nextNextEpoch: undefined
        },
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

    const txBuilder = wallet.createTxBuilder();
    const tx = await txBuilder.addOutput(mocks.utxo[0][1]).build().inspect();

    expect(tx.body.withdrawals).toBeUndefined();
  });

  it(`does not withdraw from reward accounts with zero balance when 
      there are others with positive balance`, async () => {
    rewardAccounts[0].rewardBalance = 0n;
    wallet.delegation.rewardAccounts$ = of(rewardAccounts);

    const txBuilder = wallet.createTxBuilder();
    const tx = await txBuilder.addOutput(mocks.utxo[0][1]).build().inspect();

    const withdrawWithReward: Cardano.Withdrawal = {
      quantity: rewardAccounts[1].rewardBalance,
      stakeAddress: rewardAccounts[1].address
    };
    expect(tx.body.withdrawals).toEqual([withdrawWithReward]);
  });

  it('can withdraw from multiple accounts in the same transaction', async () => {
    wallet.delegation.rewardAccounts$ = of(rewardAccounts);
    const txBuilder = wallet.createTxBuilder();
    const tx = await txBuilder.addOutput(mocks.utxo[0][1]).build().inspect();

    const withdrawals: Cardano.Withdrawal[] = rewardAccounts.map(
      ({ rewardBalance: quantity, address: stakeAddress }) => ({ quantity, stakeAddress })
    );
    expect(tx.body.withdrawals).toEqual(withdrawals);
  });

  it('can submit transaction', async () => {
    const availableRewards = await firstValueFrom(wallet.balance.rewardAccounts.rewards$);
    const accounts = uniq((await firstValueFrom(wallet.addresses$)).map((address) => address.rewardAccount));
    const txInternals = await wallet.initializeTx({
      certificates: [
        {
          __typename: Cardano.CertificateType.StakeDeregistration,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(accounts[0])),
            type: Cardano.CredentialType.KeyHash
          }
        }
      ],
      outputs: new Set() // In a real transaction you would probably want to have some outputs
    });
    expect(typeof txInternals.body.fee).toBe('bigint');
    const tx = await wallet.finalizeTx({ tx: txInternals });

    const expectedRewards = accounts.map((rewardAccount) => ({
      quantity: availableRewards / BigInt(accounts.length),
      stakeAddress: rewardAccount
    }));

    expect(tx.body.withdrawals).toEqual(expectedRewards);

    const onChainSubscription = wallet.transactions.outgoing.onChain$.subscribe(({ id }) => {
      if (id === tx.id) {
        // Transaction successful
      }
    });

    const failedSubscription = wallet.transactions.outgoing.failed$.subscribe(({ id, reason }) => {
      if (id === tx.id) {
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
    onChainSubscription.unsubscribe();
    failedSubscription.unsubscribe();
    wallet.shutdown();
  });
});
