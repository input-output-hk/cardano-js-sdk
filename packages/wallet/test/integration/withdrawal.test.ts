import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, TransactionFailure } from '../../src';
import { createWallet } from './util';
import { firstValueFrom } from 'rxjs';

describe('integration/withdrawal', () => {
  let wallet: SingleAddressWallet;

  beforeAll(async () => {
    ({ wallet } = await createWallet());
  });

  it('has balance', async () => {
    expect(typeof (await firstValueFrom(wallet.balance.utxo.total$))?.coins).toBe('bigint');
    expect(typeof (await firstValueFrom(wallet.balance.rewardAccounts.rewards$))).toBe('bigint');
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
      outputs: new Set(), // In a real transaction you would probably want to have some outputs
      withdrawals: [{ quantity: availableRewards, stakeAddress: rewardAccount }]
    });
    expect(typeof txInternals.body.fee).toBe('bigint');
    const tx = await wallet.finalizeTx(txInternals);

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
