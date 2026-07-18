import * as Cardano from '../../src/Cardano';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { createBatchInputResolver, directDepositsInspector, guardsInspector, toMergedBatchView } from '../../src';

const topId = Cardano.TransactionId('1000000000000000000000000000000000000000000000000000000000000001');
const subTx1Id = Cardano.TransactionId('2000000000000000000000000000000000000000000000000000000000000002');
const subTx2Id = Cardano.TransactionId('3000000000000000000000000000000000000000000000000000000000000003');
const externalTxId = Cardano.TransactionId('4000000000000000000000000000000000000000000000000000000000000004');

const address1 = Cardano.PaymentAddress(
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
);
const address2 = Cardano.PaymentAddress(
  'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
);
const ownRewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
const foreignRewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');

const assetA = Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740');
const assetB = Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41');

const keyGuard: Cardano.Credential = {
  hash: Hash28ByteBase16('00112233445566778899aabbccddeeff00112233445566778899aabb'),
  type: Cardano.CredentialType.KeyHash
};
const scriptGuard: Cardano.Credential = {
  hash: Hash28ByteBase16('aabbccddeeff00112233445566778899aabbccddeeff001122334455'),
  type: Cardano.CredentialType.ScriptHash
};

const certificate1 = {
  __typename: Cardano.CertificateType.StakeRegistration,
  stakeCredential: keyGuard
} as Cardano.Certificate;
const certificate2 = {
  __typename: Cardano.CertificateType.StakeDeregistration,
  stakeCredential: keyGuard
} as Cardano.Certificate;

const topOutput: Cardano.TxOut = { address: address1, value: { coins: 1_000_000n } };
const subTx1Output0: Cardano.TxOut = { address: address1, value: { coins: 2_000_000n } };
const subTx1Output1: Cardano.TxOut = { address: address2, value: { coins: 3_000_000n } };
const subTx2Output: Cardano.TxOut = { address: address2, value: { coins: 4_000_000n } };

const emptyWitness: Cardano.Witness = { signatures: new Map() };
const mockScript = {
  __type: Cardano.ScriptType.Native,
  keyHash: keyGuard.hash,
  kind: Cardano.NativeScriptKind.RequireSignature
} as Cardano.Script;

const buildBatchTx = (): Cardano.Tx =>
  ({
    body: {
      certificates: [certificate1],
      directDeposits: [
        { quantity: 2_000_000n, stakeAddress: ownRewardAccount },
        { quantity: 3_000_000n, stakeAddress: foreignRewardAccount }
      ],
      fee: 300_000n,
      guards: [keyGuard, scriptGuard],
      inputs: [{ index: 0, txId: externalTxId }],
      mint: new Map([[assetA, 5n]]),
      outputs: [topOutput],
      subTransactions: [
        {
          body: {
            certificates: [certificate2],
            directDeposits: [{ quantity: 5_000_000n, stakeAddress: foreignRewardAccount }],
            inputs: [{ index: 1, txId: externalTxId }],
            mint: new Map([
              [assetA, -2n],
              [assetB, 7n]
            ]),
            outputs: [subTx1Output0, subTx1Output1],
            withdrawals: [{ quantity: 100n, stakeAddress: ownRewardAccount }]
          },
          id: subTx1Id,
          witness: { scripts: [mockScript], signatures: new Map() }
        },
        {
          body: {
            inputs: [{ index: 1, txId: subTx1Id }],
            outputs: [subTx2Output]
          },
          id: subTx2Id,
          witness: emptyWitness
        }
      ],
      withdrawals: [{ quantity: 200n, stakeAddress: foreignRewardAccount }]
    },
    id: topId,
    witness: emptyWitness
  } as unknown as Cardano.Tx);

describe('createBatchInputResolver', () => {
  const tx = buildBatchTx();

  it('resolves inputs produced by the top level transaction', async () => {
    const resolver = createBatchInputResolver(tx);

    expect(await resolver.resolveInput({ index: 0, txId: topId })).toEqual(topOutput);
  });

  it('resolves inputs produced by sub transactions', async () => {
    const resolver = createBatchInputResolver(tx);

    expect(await resolver.resolveInput({ index: 1, txId: subTx1Id })).toEqual(subTx1Output1);
    expect(await resolver.resolveInput({ index: 0, txId: subTx2Id })).toEqual(subTx2Output);
  });

  it('resolves to null for an out of range index of a batch producer', async () => {
    const resolver = createBatchInputResolver(tx);

    expect(await resolver.resolveInput({ index: 5, txId: subTx1Id })).toBeNull();
  });

  it('delegates batch-external inputs to the fallback resolver', async () => {
    const externalOutput: Cardano.TxOut = { address: address2, value: { coins: 9_000_000n } };
    const fallback: Cardano.InputResolver = { resolveInput: jest.fn().mockResolvedValue(externalOutput) };
    const resolver = createBatchInputResolver(tx, fallback);
    const externalInput = { index: 0, txId: externalTxId };

    expect(await resolver.resolveInput(externalInput)).toEqual(externalOutput);
    expect(fallback.resolveInput).toHaveBeenCalledWith(externalInput, undefined);
  });

  it('resolves batch-external inputs to null without a fallback resolver', async () => {
    const resolver = createBatchInputResolver(tx);

    expect(await resolver.resolveInput({ index: 0, txId: externalTxId })).toBeNull();
  });

  it('skips sub transactions that do not carry an id', async () => {
    const withoutIds = buildBatchTx();
    for (const subTx of withoutIds.body.subTransactions!) delete (subTx as { id?: Cardano.TransactionId }).id;
    const resolver = createBatchInputResolver(withoutIds);

    expect(await resolver.resolveInput({ index: 1, txId: subTx1Id })).toBeNull();
  });
});

describe('toMergedBatchView', () => {
  it('returns the input unchanged when there are no sub transactions', () => {
    const tx = buildBatchTx();
    tx.body.subTransactions = undefined;

    expect(toMergedBatchView(tx)).toBe(tx);
  });

  it('concatenates inputs and outputs across the batch and clears subTransactions', () => {
    const view = toMergedBatchView(buildBatchTx());

    expect(view.body.inputs).toEqual([
      { index: 0, txId: externalTxId },
      { index: 1, txId: externalTxId },
      { index: 1, txId: subTx1Id }
    ]);
    expect(view.body.outputs).toEqual([topOutput, subTx1Output0, subTx1Output1, subTx2Output]);
    expect(view.body.subTransactions).toBeUndefined();
  });

  it('merges mint maps, certificates, withdrawals and direct deposits', () => {
    const view = toMergedBatchView(buildBatchTx());

    expect(view.body.mint).toEqual(
      new Map([
        [assetA, 3n],
        [assetB, 7n]
      ])
    );
    expect(view.body.certificates).toEqual([certificate1, certificate2]);
    expect(view.body.withdrawals).toEqual([
      { quantity: 200n, stakeAddress: foreignRewardAccount },
      { quantity: 100n, stakeAddress: ownRewardAccount }
    ]);
    expect(view.body.directDeposits).toEqual([
      { quantity: 2_000_000n, stakeAddress: ownRewardAccount },
      { quantity: 3_000_000n, stakeAddress: foreignRewardAccount },
      { quantity: 5_000_000n, stakeAddress: foreignRewardAccount }
    ]);
  });

  it('pools witness scripts and keeps top level only fields', () => {
    const view = toMergedBatchView(buildBatchTx());

    expect(view.witness.scripts).toEqual([mockScript]);
    expect(view.body.fee).toEqual(300_000n);
    expect(view.body.guards).toEqual([keyGuard, scriptGuard]);
    expect(view.id).toEqual(topId);
  });
});

describe('directDepositsInspector', () => {
  it('totals direct deposits into the given reward accounts', async () => {
    expect(await directDepositsInspector([ownRewardAccount])(buildBatchTx())).toEqual(2_000_000n);
    expect(await directDepositsInspector([ownRewardAccount])(toMergedBatchView(buildBatchTx()))).toEqual(2_000_000n);
    expect(await directDepositsInspector([foreignRewardAccount])(toMergedBatchView(buildBatchTx()))).toEqual(
      8_000_000n
    );
  });

  it('returns zero when the transaction has no direct deposits into the given accounts', async () => {
    const tx = buildBatchTx();
    tx.body.directDeposits = undefined;

    expect(await directDepositsInspector([ownRewardAccount])(tx)).toEqual(0n);
  });
});

describe('guardsInspector', () => {
  it('returns the guard credentials of the transaction', async () => {
    expect(await guardsInspector(buildBatchTx())).toEqual([keyGuard, scriptGuard]);
  });

  it('returns an empty array when the transaction has no guards', async () => {
    const tx = buildBatchTx();
    tx.body.guards = undefined;

    expect(await guardsInspector(tx)).toEqual([]);
  });
});
