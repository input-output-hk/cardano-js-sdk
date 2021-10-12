import { TxOut } from '@cardano-ogmios/schema';
import { roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { Cardano, loadCardanoSerializationLib } from '@cardano-sdk/core';
import { blockfrostProvider, Options } from '@cardano-sdk/blockfrost';
import {
  createSingleAddressWallet,
  InMemoryTransactionTracker,
  InMemoryUtxoRepository,
  KeyManagement,
  SingleAddressWalletProps,
  Transaction,
  TransactionError,
  TransactionFailure
} from '@cardano-sdk/wallet';

const walletProps: SingleAddressWalletProps = { name: 'some-wallet' };
const networkId = Cardano.NetworkId.mainnet;
const mnemonicWords = ['your', 'mnemonic'];
const password = 'your_password';
const blockfrostOptions: Options = { projectId: 'your-project-id' };

export const withdrawAll = async (outputs: Set<TxOut>) => {
  const csl = await loadCardanoSerializationLib();
  const keyManager = KeyManagement.createInMemoryKeyManager({ csl, mnemonicWords, password, networkId });
  const provider = blockfrostProvider(blockfrostOptions);
  const txTracker = new InMemoryTransactionTracker({ csl, provider });
  const inputSelector = roundRobinRandomImprove(csl);
  const utxoRepository = new InMemoryUtxoRepository({ csl, provider, txTracker, inputSelector, keyManager });
  const wallet = await createSingleAddressWallet(walletProps, { csl, keyManager, provider, utxoRepository, txTracker });

  utxoRepository.on('transactionUntracked', (tx) => {
    // UtxoRepository is not sure whether it's UTxO can be spent due to failing to track transaction confirmation.
    // SubmitTxResult.confirmed has rejected. Calling trackTransaction will lock UTxO again:
    txTracker.trackTransaction(tx).catch((error) => {
      /* eslint-disable-next-line sonarjs/no-all-duplicated-branches */
      if (error instanceof TransactionError && error.reason === TransactionFailure.Timeout) {
        // Transaction has expired and will not be confirmed. Therefore it's safe to spend the UTxO again.
      } else {
        // Probably wait a little bit and retry
      }
    });
  });

  // Call this to sync available balance
  await utxoRepository.sync();

  const certFactory = new Transaction.CertificateFactory(csl, keyManager);

  const { body, hash } = await wallet.initializeTx({
    certificates: [certFactory.stakeKeyDeregistration()],
    withdrawals: [Transaction.withdrawal(csl, keyManager, utxoRepository.rewards || 0)],
    outputs
  });
  // Calculated fee is returned by invoking body.fee()
  const tx = await wallet.signTx(body, hash);

  const { submitted, confirmed } = wallet.submitTx(tx);
  // Transaction is submitting. UTxO is locked.
  await submitted;
  // Transaction is successfully submitted, but not confirmed yet
  await confirmed;
};
