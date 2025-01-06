import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, ProviderFailure, TxSubmissionErrorCode, TxSubmitProvider } from '@cardano-sdk/core';
import { GenericTxBuilder, TxBuilderDependencies } from '@cardano-sdk/tx-construction';
import { firstValueFrom } from 'rxjs';
import { getEnv, getWallet, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

describe('TxSubmitProvider', () => {
  let wallet: BaseWallet;
  let txSubmitProvider: TxSubmitProvider;
  let ownAddress: Cardano.PaymentAddress;
  let walletTxBuilderDependencies: TxBuilderDependencies;

  beforeAll(async () => {
    const env = getEnv(walletVariables);
    ({
      wallet,
      providers: { txSubmitProvider }
    } = await getWallet({ env, idx: 0, logger, name: 'Test Wallet' }));
    const addresses = await firstValueFrom(wallet.addresses$);
    ownAddress = addresses[0].address;
    walletTxBuilderDependencies = wallet.getTxBuilderDependencies();
  });

  it('maps ProviderError{TxSubmissionError{OutsideOfValidityInterval}}', async () => {
    const actualTip = await firstValueFrom(wallet.tip$);
    const txBuilder = new GenericTxBuilder({
      ...walletTxBuilderDependencies,
      txBuilderProviders: {
        ...walletTxBuilderDependencies.txBuilderProviders,
        tip: async () => ({
          ...actualTip,
          // GenericTxBuilder fails to build a tx with expired validity interval.
          // we need to trick it to believe the it's within validity interval
          // in order to test submission error
          slot: Cardano.Slot(actualTip.slot - 10)
        })
      }
    });
    const tx = await txBuilder
      .addOutput({ address: ownAddress, value: { coins: 2_000_000n } })
      .setValidityInterval({ invalidHereafter: Cardano.Slot(actualTip.slot - 1) })
      .build()
      .sign();

    await expect(txSubmitProvider.submitTx({ signedTransaction: tx.cbor })).rejects.toThrow(
      expect.objectContaining({
        innerError: expect.objectContaining({
          code: TxSubmissionErrorCode.OutsideOfValidityInterval
        }),
        reason: ProviderFailure.BadRequest
      })
    );
  });

  it('maps ProviderError{TxSubmissionError{ValueNotConserved}}', async () => {
    const txBuilder = new GenericTxBuilder({
      ...walletTxBuilderDependencies,
      inputSelector: {
        select: async ({ utxo, outputs }) => ({
          remainingUTxO: new Set([...utxo].slice(1)),
          selection: {
            change: [] as Cardano.TxOut[],
            fee: 2_000_000n,
            inputs: new Set([[...utxo][0]]),
            outputs
          }
        })
      }
    });
    const tx = await txBuilder
      .addOutput({ address: ownAddress, value: { coins: 2_000_000n } })
      .build()
      .sign();

    await expect(txSubmitProvider.submitTx({ signedTransaction: tx.cbor })).rejects.toThrow(
      expect.objectContaining({
        innerError: expect.objectContaining({
          code: TxSubmissionErrorCode.ValueNotConserved,
          data: expect.objectContaining({
            consumed: expect.objectContaining({ coins: expect.any(BigInt) }),
            produced: expect.objectContaining({ coins: expect.any(BigInt) })
          })
        }),
        reason: ProviderFailure.BadRequest
      })
    );
  });

  // this mapping is not implemented yet due to
  // https://input-output-rnd.slack.com/archives/C06J663L2A2/p1735920667624239
  it.skip('maps ProviderError{TxSubmissionError{IncompleteWithdrawals}}', async () => {
    const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
    if (rewardAccounts.some((acc) => !acc.dRepDelegatee || !acc.rewardBalance)) {
      return logger.warn(
        'Skipping IncompleteWithdrawals error test because there are either no rewards, or not delegated to drep'
      );
    }
    const txBuilder = new GenericTxBuilder({
      ...walletTxBuilderDependencies,
      txBuilderProviders: {
        ...walletTxBuilderDependencies.txBuilderProviders,
        rewardAccounts: async () => {
          const accounts = await walletTxBuilderDependencies.txBuilderProviders.rewardAccounts();
          return accounts.map((account) => ({
            ...account,
            rewardBalance: account.rewardBalance - 1n
          }));
        }
      }
    });
    const tx = await txBuilder
      .addOutput({ address: ownAddress, value: { coins: 2_000_000n } })
      .build()
      .sign();

    await expect(txSubmitProvider.submitTx({ signedTransaction: tx.cbor })).rejects.toThrow(
      expect.objectContaining({
        innerError: expect.objectContaining({
          code: TxSubmissionErrorCode.IncompleteWithdrawals
        }),
        reason: ProviderFailure.BadRequest
      })
    );
  });
});
