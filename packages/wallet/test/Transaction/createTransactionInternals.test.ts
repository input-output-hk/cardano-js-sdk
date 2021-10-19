import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { WalletProvider, Ogmios, CSL } from '@cardano-sdk/core';
import { SelectionConstraints } from '@cardano-sdk/util-dev';
import { providerStub, txTracker, testKeyManager } from '../mocks';
import {
  CertificateFactory,
  createTransactionInternals,
  CreateTxInternalsProps,
  Withdrawal
} from '../../src/Transaction';
import { UtxoRepository, InMemoryUtxoRepository, KeyManagement } from '../../src';

const address =
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g';

describe('Transaction.createTransactionInternals', () => {
  let provider: WalletProvider;
  let inputSelector: InputSelector;
  let utxoRepository: UtxoRepository;
  let keyManager: KeyManagement.KeyManager;
  let outputs: Set<CSL.TransactionOutput>;

  const createSimpleTransactionInternals = async (props?: Partial<CreateTxInternalsProps>) => {
    const result = await utxoRepository.selectInputs(outputs, SelectionConstraints.NO_CONSTRAINTS);
    const ledgerTip = await provider.ledgerTip();
    return await createTransactionInternals({
      changeAddress: 'addr_test1gz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerspqgpsqe70et',
      inputSelection: result.selection,
      validityInterval: {
        invalidHereafter: ledgerTip.slot + 3600
      },
      ...props
    });
  };

  beforeEach(async () => {
    provider = providerStub();
    inputSelector = roundRobinRandomImprove();
    keyManager = testKeyManager();

    outputs = new Set([
      Ogmios.ogmiosToCsl.txOut({
        address,
        value: { coins: 4_000_000 }
      }),
      Ogmios.ogmiosToCsl.txOut({
        address,
        value: { coins: 2_000_000 }
      })
    ]);
    utxoRepository = new InMemoryUtxoRepository({ provider, keyManager, inputSelector, txTracker });
  });

  test('simple transaction', async () => {
    const { body, hash } = await createSimpleTransactionInternals();
    expect(body).toBeInstanceOf(CSL.TransactionBody);
    expect(hash).toBeInstanceOf(CSL.TransactionHash);
  });

  test('transaction with withdrawals', async () => {
    const withdrawal: Withdrawal = {
      address: CSL.RewardAddress.new(
        CSL.NetworkId.testnet().kind(),
        CSL.StakeCredential.from_keyhash(keyManager.stakeKey.hash())
      ),
      quantity: CSL.BigNum.from_str('5000000')
    };
    const { body } = await createSimpleTransactionInternals({ withdrawals: [withdrawal] });
    const txWithdrawals = body.withdrawals()!;
    expect(txWithdrawals.len()).toBe(1);
    const txWithdrawalQty = txWithdrawals.get(withdrawal.address);
    expect(txWithdrawalQty?.to_str()).toBe(withdrawal.quantity.to_str());
  });

  test('transaction with certificates', async () => {
    const delegatee = 'pool1qqvukkkfr3ux4qylfkrky23f6trl2l6xjluv36z90ax7gfa8yxt';
    const certFactory = new CertificateFactory(keyManager);
    const certificates = [certFactory.stakeKeyRegistration(), certFactory.stakeDelegation(delegatee)];
    const { body } = await createSimpleTransactionInternals({ certificates });
    expect(body.certs()!.len()).toBe(certificates.length);
  });
});
