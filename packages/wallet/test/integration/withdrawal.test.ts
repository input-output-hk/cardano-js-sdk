import { roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { Cardano, CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/core';
import {
  createSingleAddressWallet,
  InMemoryTransactionTracker,
  InMemoryUtxoRepository,
  KeyManagement,
  SingleAddressWallet,
  SingleAddressWalletProps,
  Transaction,
  TransactionError,
  TransactionFailure,
  TransactionTracker,
  UtxoRepository,
  UtxoRepositoryEvent
} from '@cardano-sdk/wallet';
// Not testing with a real provider
import { providerStub } from '../ProviderStub';

const walletProps: SingleAddressWalletProps = { name: 'some-wallet' };
const networkId = Cardano.NetworkId.mainnet;
const mnemonicWords = KeyManagement.util.generateMnemonicWords();
const password = 'your_password';

describe('integration/withdrawal', () => {
  let csl: CardanoSerializationLib;
  let keyManager: KeyManagement.KeyManager;
  let txTracker: TransactionTracker;
  let utxoRepository: UtxoRepository;
  let wallet: SingleAddressWallet;

  beforeAll(async () => {
    csl = await loadCardanoSerializationLib();
    keyManager = KeyManagement.createInMemoryKeyManager({ csl, mnemonicWords, password, networkId });
    const provider = providerStub();
    const inputSelector = roundRobinRandomImprove(csl);
    txTracker = new InMemoryTransactionTracker({ csl, provider });
    utxoRepository = new InMemoryUtxoRepository({ csl, provider, txTracker, inputSelector, keyManager });
    wallet = await createSingleAddressWallet(walletProps, {
      csl,
      keyManager,
      provider,
      utxoRepository,
      txTracker
    });

    // Call this to sync available balance
    await utxoRepository.sync();
  });

  it('does not throw', async () => {
    // This is not testing anything, just a usage example
    utxoRepository.on(UtxoRepositoryEvent.TransactionUntracked, (tx) => {
      // UtxoRepository is not sure whether it's UTxO can be spent due to failing to track transaction confirmation.
      // SubmitTxResult.confirmed has rejected. Calling track() will lock UTxO again:
      txTracker.track(tx).catch((error) => {
        /* eslint-disable-next-line sonarjs/no-all-duplicated-branches */
        if (error instanceof TransactionError && error.reason === TransactionFailure.Timeout) {
          // Transaction has expired and will not be confirmed. Therefore it's safe to spend the UTxO again.
        } else {
          // Probably wait a little bit and retry
        }
      });
    });

    const certFactory = new Transaction.CertificateFactory(csl, keyManager);

    const { body, hash } = await wallet.initializeTx({
      certificates: [certFactory.stakeKeyDeregistration()],
      withdrawals: [Transaction.withdrawal(csl, keyManager, utxoRepository.rewards || 0n)],
      outputs: new Set() // In a real transaction you would probably want to have some outputs
    });
    // Calculated fee is returned by invoking body.fee()
    const tx = await wallet.signTx(body, hash);

    const { submitted, confirmed } = wallet.submitTx(tx);
    // Transaction is submitting. UTxO is locked.
    await submitted;
    // Transaction is successfully submitted, but not confirmed yet
    await confirmed;
  });
});
