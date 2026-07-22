import { Cardano, Serialization } from '@cardano-sdk/core';
import { createDijkstraBatchFixture } from '../src';

const resolveOrThrow = (utxos: Cardano.Utxo[], txIn: Cardano.TxIn): Cardano.TxOut => {
  const utxo = utxos.find(([produced]) => produced.txId === txIn.txId && produced.index === txIn.index);
  if (!utxo) throw new Error(`Unresolvable input: ${txIn.txId}#${txIn.index}`);
  return utxo[1];
};

const totalCoins = (utxos: Cardano.Utxo[], txIns: Cardano.TxIn[]): Cardano.Lovelace =>
  txIns.reduce((total, txIn) => total + resolveOrThrow(utxos, txIn).value.coins, 0n);

const totalOutputCoins = (outputs: Cardano.TxOut[]): Cardano.Lovelace =>
  outputs.reduce((total, { value }) => total + value.coins, 0n);

describe('createDijkstraBatchFixture', () => {
  const fixture = createDijkstraBatchFixture();
  const topLevelBody = fixture.tx.body;
  const [subTx1Body, subTx2Body] = topLevelBody.subTransactions!.map(({ body }) => body);
  const allUtxos = [...fixture.externalUtxos, fixture.intraBatchUtxo];
  const directDepositTotal = topLevelBody.directDeposits!.reduce((total, { quantity }) => total + quantity, 0n);

  it('is deterministic', () => {
    expect(createDijkstraBatchFixture().cbor).toEqual(fixture.cbor);
  });

  describe('serialization', () => {
    it('round trips the cbor byte-exactly', () => {
      expect(Serialization.Transaction.fromCbor(fixture.cbor).toCbor()).toEqual(fixture.cbor);
    });

    it('re-encodes byte-exactly from core', () => {
      expect(Serialization.Transaction.fromCore(fixture.tx).toCbor()).toEqual(fixture.cbor);
    });

    it('decodes cleanly in strict mode', () => {
      expect(() => Serialization.Transaction.fromCbor(fixture.cbor, { strict: true })).not.toThrow();
    });

    it('exposes the id of the top level transaction and of each sub transaction', () => {
      expect(Serialization.Transaction.fromCbor(fixture.cbor).getId()).toEqual(fixture.tx.id);
      expect(
        topLevelBody.subTransactions!.map((subTx) => Serialization.SubTransaction.fromCore(subTx).getId())
      ).toEqual(fixture.subTxIds);
    });
  });

  describe('batch economics', () => {
    it('balances across the whole batch: all inputs equal all outputs plus fee plus direct deposits', () => {
      const allInputs = [...topLevelBody.inputs, ...subTx1Body.inputs, ...subTx2Body.inputs];
      const allOutputs = [...topLevelBody.outputs, ...subTx1Body.outputs, ...subTx2Body.outputs];

      expect(totalCoins(allUtxos, allInputs)).toEqual(
        totalOutputCoins(allOutputs) + topLevelBody.fee + directDepositTotal
      );
    });

    it('does not balance at the top level alone', () => {
      expect(totalCoins(allUtxos, topLevelBody.inputs)).not.toEqual(
        totalOutputCoins(topLevelBody.outputs) + topLevelBody.fee + directDepositTotal
      );
    });

    it('does not balance in either sub transaction alone', () => {
      expect(totalCoins(allUtxos, subTx1Body.inputs)).not.toEqual(totalOutputCoins(subTx1Body.outputs));
      expect(totalCoins(allUtxos, subTx2Body.inputs)).not.toEqual(totalOutputCoins(subTx2Body.outputs));
    });
  });

  describe('intra-batch input', () => {
    it('is spent by sub transaction 2 and produced by sub transaction 1', () => {
      const [intraBatchTxIn] = fixture.intraBatchUtxo;

      expect(subTx2Body.inputs).toContainEqual({ index: intraBatchTxIn.index, txId: intraBatchTxIn.txId });
      expect(intraBatchTxIn.txId).toEqual(fixture.subTxIds[0]);
      expect(subTx1Body.outputs[intraBatchTxIn.index]).toEqual(fixture.intraBatchUtxo[1]);
    });

    it('is not resolvable from the external utxos', () => {
      const [intraBatchTxIn] = fixture.intraBatchUtxo;

      expect(() => resolveOrThrow(fixture.externalUtxos, intraBatchTxIn)).toThrow('Unresolvable input');
    });

    it('external utxos resolve every batch input except the intra-batch one', () => {
      const allInputs = [...topLevelBody.inputs, ...subTx1Body.inputs, ...subTx2Body.inputs];
      const externallyResolvable = allInputs.filter((txIn) => txIn.txId !== fixture.subTxIds[0]);

      expect(externallyResolvable).toHaveLength(fixture.externalUtxos.length);
      for (const txIn of externallyResolvable) expect(() => resolveOrThrow(fixture.externalUtxos, txIn)).not.toThrow();
    });
  });

  describe('hydrated view', () => {
    const hydratedBody = fixture.hydratedTx.body;

    it('mirrors the id, witness and non-input body fields of the core transaction', () => {
      expect(fixture.hydratedTx.id).toEqual(fixture.tx.id);
      expect(fixture.hydratedTx.witness).toEqual(fixture.tx.witness);
      expect(hydratedBody.fee).toEqual(topLevelBody.fee);
      expect(hydratedBody.guards).toEqual(topLevelBody.guards);
      expect(hydratedBody.directDeposits).toEqual(topLevelBody.directDeposits);
      expect(hydratedBody.accountBalanceIntervals).toEqual(topLevelBody.accountBalanceIntervals);
      expect(hydratedBody.outputs).toEqual(topLevelBody.outputs);
    });

    it('carries each sub transaction with its id', () => {
      expect(hydratedBody.subTransactions!.map(({ id }) => id)).toEqual(fixture.subTxIds);
      expect(hydratedBody.subTransactions!.map(({ body }) => body.outputs)).toEqual([
        subTx1Body.outputs,
        subTx2Body.outputs
      ]);
    });

    it('hydrates every input with the address of the utxo it spends', () => {
      const hydratedInputs = [
        ...hydratedBody.inputs,
        ...hydratedBody.subTransactions!.flatMap(({ body }) => body.inputs)
      ];

      expect(hydratedInputs.map(({ address }) => address)).toEqual(
        hydratedInputs.map((txIn) => resolveOrThrow(allUtxos, txIn).address)
      );
    });

    it('hydrates the intra-batch input from the sibling sub transaction output', () => {
      const [, hydratedSubTx2] = hydratedBody.subTransactions!;
      const intraBatchInput = hydratedSubTx2.body.inputs.find(({ txId }) => txId === fixture.subTxIds[0]);

      expect(intraBatchInput).toBeDefined();
      expect(intraBatchInput!.address).toEqual(fixture.actors.counterparty2Address);
    });
  });

  describe('dijkstra decorations', () => {
    it('carries one key hash guard and one script hash guard at the top level', () => {
      expect(topLevelBody.guards!.map(({ type }) => type)).toEqual([
        Cardano.CredentialType.KeyHash,
        Cardano.CredentialType.ScriptHash
      ]);
    });

    it('asserts an account balance interval on the wallet reward credential', () => {
      expect(topLevelBody.accountBalanceIntervals).toEqual([
        {
          credential: {
            hash: Cardano.RewardAccount.toHash(fixture.actors.walletRewardAccount),
            type: Cardano.CredentialType.KeyHash
          },
          interval: { exclusiveUpperBound: 100_000_000n, inclusiveLowerBound: 2_000_000n }
        }
      ]);
    });

    it('direct-deposits into the wallet reward account', () => {
      expect(topLevelBody.directDeposits).toEqual([
        { quantity: 2_000_000n, stakeAddress: fixture.actors.walletRewardAccount }
      ]);
    });

    it('sub transaction 2 requires the top level script guard without a datum', () => {
      expect(subTx2Body.requiredTopLevelGuards).toEqual([{ credential: topLevelBody.guards![1], datum: null }]);
    });

    it('sub transaction 1 mints the fixture asset into its wallet-bound output', () => {
      expect(subTx1Body.mint!.get(fixture.mintedAssetId)).toEqual(100n);
      expect(subTx1Body.outputs[0].address).toEqual(fixture.actors.walletAddress);
      expect(subTx1Body.outputs[0].value.assets!.get(fixture.mintedAssetId)).toEqual(100n);
    });
  });
});
