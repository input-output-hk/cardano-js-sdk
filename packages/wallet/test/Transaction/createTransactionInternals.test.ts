import { CreateTxInternalsProps, createTransactionInternals } from '../../src/Transaction';
import { SelectionConstraints } from '@cardano-sdk/util-dev';
import { SelectionSkeleton, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { WalletProvider, coreToCsl } from '@cardano-sdk/core';
import { providerStub, utxo } from '../mocks';

const address =
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g';

const outputs = [
  {
    address,
    value: { coins: 4_000_000n }
  }
];

describe('Transaction.createTransactionInternals', () => {
  let provider: WalletProvider;

  beforeEach(() => {
    provider = providerStub();
  });

  const createSimpleTransactionInternals = async (
    props: (inputSelection: SelectionSkeleton) => Partial<CreateTxInternalsProps> = () => ({})
  ) => {
    const result = await roundRobinRandomImprove().select({
      constraints: SelectionConstraints.NO_CONSTRAINTS,
      outputs: new Set(outputs.map((output) => coreToCsl.txOut(output))),
      utxo: new Set(coreToCsl.utxo(utxo))
    });
    const ledgerTip = await provider.ledgerTip();
    const overrides = props(result.selection);
    return await createTransactionInternals({
      changeAddress: 'addr_test1gz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerspqgpsqe70et',
      validityInterval: {
        invalidHereafter: ledgerTip.slot + 3600
      },
      ...overrides,
      inputSelection: {
        ...result.selection,
        ...overrides.inputSelection
      }
    });
  };

  it('adds output for change', async () => {
    const txInternals = await createSimpleTransactionInternals();
    expect(txInternals.body.outputs).toHaveLength(2);
  });

  it('coverts csl types from selection result to core', async () => {
    const txInternals = await createSimpleTransactionInternals();
    expect(txInternals.body.outputs).toHaveLength(2);
    expect(typeof txInternals.body.fee).toBe('bigint');
    expect(typeof txInternals.body.inputs[0].address).toBe('string');
    expect(typeof txInternals.hash).toBe('string');
  });
});
