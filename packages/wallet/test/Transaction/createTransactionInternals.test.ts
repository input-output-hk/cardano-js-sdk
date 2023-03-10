import * as Crypto from '@cardano-sdk/crypto';
import { AssetId } from '@cardano-sdk/util-dev';
import { Cardano, NetworkInfoProvider } from '@cardano-sdk/core';
import { CreateTxInternalsProps, createTransactionInternals } from '../../src/Transaction';
import { SelectionConstraints } from '../../../input-selection/test/util';
import { SelectionSkeleton, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { mockNetworkInfoProvider, utxo } from '../mocks';

const address = Cardano.PaymentAddress(
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
);

const outputs = [
  {
    address,
    value: { coins: 4_000_000n }
  }
];

describe('Transaction.createTransactionInternals', () => {
  let provider: NetworkInfoProvider;

  beforeEach(() => {
    provider = mockNetworkInfoProvider();
  });

  const createSimpleTransactionInternals = async (
    props: (inputSelection: SelectionSkeleton) => Partial<CreateTxInternalsProps> = () => ({})
  ) => {
    const result = await roundRobinRandomImprove().select({
      constraints: SelectionConstraints.NO_CONSTRAINTS,
      outputs: new Set(outputs),
      utxo: new Set(utxo)
    });
    const ledgerTip = await provider.ledgerTip();
    const overrides = props(result.selection);
    return await createTransactionInternals({
      changeAddress: Cardano.PaymentAddress(
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
      ),
      validityInterval: {
        invalidHereafter: Cardano.Slot(ledgerTip.slot + 3600)
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

  it('converts csl types from selection result to core', async () => {
    const props = {
      collaterals: new Set([utxo[2][0]]),
      mint: new Map([
        [AssetId.PXL, 5n],
        [AssetId.TSLA, 20n]
      ]),
      requiredExtraSignatures: [Crypto.Ed25519KeyHashHex('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed5')],
      scriptIntegrityHash: Crypto.Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')
    };
    const txInternals = await createSimpleTransactionInternals(() => props);
    expect(txInternals.body.outputs).toHaveLength(2);
    expect(txInternals.body.collaterals).toEqual<Cardano.TxIn[]>([utxo[2][0]]);
    expect(txInternals.body.mint).toEqual<Cardano.TokenMap>(props.mint);
    expect(txInternals.body.requiredExtraSignatures).toEqual<Crypto.Ed25519KeyHashHex[]>(props.requiredExtraSignatures);
    expect(txInternals.body.scriptIntegrityHash).toEqual<Crypto.Hash32ByteBase16>(props.scriptIntegrityHash);
    expect(typeof txInternals.body.fee).toBe('bigint');
    expect(typeof txInternals.body.inputs[0].txId).toBe('string');
    expect(typeof txInternals.hash).toBe('string');
  });
});
