import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { loadCardanoSerializationLib, CardanoSerializationLib, CSL, CardanoProvider, Ogmios } from '@cardano-sdk/core';
import { SelectionConstraints } from '@cardano-sdk/util-dev';
import { providerStub } from './ProviderStub';
import {
  createTransactionInternals,
  CreateTxInternalsProps,
  Delegation,
  InMemoryUtxoRepository,
  UtxoRepository
} from '../src';
import { KeyManager } from '../src/KeyManagement';
import { Withdrawal } from '../src/Delegation';
import { testKeyManager } from './testKeyManager';

const address =
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g';

describe('createTransactionInternals', () => {
  let csl: CardanoSerializationLib;
  let provider: CardanoProvider;
  let inputSelector: InputSelector;
  let utxoRepository: UtxoRepository;
  let keyManager: KeyManager;
  let outputs: Set<CSL.TransactionOutput>;

  const createSimpleTransactionInternals = async (props?: Partial<CreateTxInternalsProps>) => {
    const result = await utxoRepository.selectInputs(outputs, SelectionConstraints.NO_CONSTRAINTS);
    const ledgerTip = await provider.ledgerTip();
    return await createTransactionInternals(csl, {
      changeAddress: 'addr_test1gz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerspqgpsqe70et',
      inputSelection: result.selection,
      validityInterval: {
        invalidHereafter: ledgerTip.slot + 3600
      },
      ...props
    });
  };

  beforeEach(async () => {
    csl = await loadCardanoSerializationLib();
    provider = providerStub();
    inputSelector = roundRobinRandomImprove(csl);
    keyManager = testKeyManager(csl);

    outputs = new Set([
      Ogmios.ogmiosToCsl(csl).txOut({
        address,
        value: { coins: 4_000_000 }
      }),
      Ogmios.ogmiosToCsl(csl).txOut({
        address,
        value: { coins: 2_000_000 }
      })
    ]);
    utxoRepository = new InMemoryUtxoRepository(csl, provider, keyManager, inputSelector);
  });

  test('simple transaction', async () => {
    const { body, hash } = await createSimpleTransactionInternals();
    expect(body).toBeInstanceOf(csl.TransactionBody);
    expect(hash).toBeInstanceOf(csl.TransactionHash);
  });

  test('transaction with withdrawals', async () => {
    const withdrawal: Withdrawal = {
      address: csl.RewardAddress.new(
        csl.NetworkId.testnet().kind(),
        csl.StakeCredential.from_keyhash(keyManager.stakeKey.hash())
      ),
      quantity: csl.BigNum.from_str('5000000')
    };
    const { body } = await createSimpleTransactionInternals({ withdrawals: [withdrawal] });
    const txWithdrawals = body.withdrawals()!;
    expect(txWithdrawals.len()).toBe(1);
    const txWithdrawalQty = txWithdrawals.get(withdrawal.address);
    expect(txWithdrawalQty?.to_str()).toBe(withdrawal.quantity.to_str());
  });

  test('transaction with certificates', async () => {
    const delegatee = 'pool1qqvukkkfr3ux4qylfkrky23f6trl2l6xjluv36z90ax7gfa8yxt';
    const certFactory = new Delegation.CertificateFactory(csl, keyManager);
    const certificates = [certFactory.stakeKeyRegistration(), certFactory.stakeDelegation(delegatee)];
    const { body } = await createSimpleTransactionInternals({ certificates });
    expect(body.certs()!.len()).toBe(certificates.length);
  });
});
