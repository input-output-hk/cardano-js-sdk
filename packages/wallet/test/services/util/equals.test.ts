/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { arrayEquals, shallowArrayEquals, strictEquals, transactionsEquals, txEquals, utxoEquals } from '../../../src';

describe('equals', () => {
  test('strictEquals', () => {
    expect(strictEquals('1', 1 as unknown as string)).toBe(false);
    expect(strictEquals('1', '1')).toBe(true);
  });

  test('arrayEquals', () => {
    expect(arrayEquals([], [], strictEquals)).toBe(true);
    expect(arrayEquals(['a'], ['a', 'b'], strictEquals)).toBe(false);
    expect(arrayEquals(['a', 'b'], ['a', 'b'], strictEquals)).toBe(true);
  });

  test('shallowArrayEquals', () => {
    expect(shallowArrayEquals([], [])).toBe(true);
    const a = { prop: 'prop' };
    const b = { prop: 'prop' };
    expect(shallowArrayEquals([a], [b])).toBe(false);
    expect(shallowArrayEquals([a], [a])).toBe(true);
  });

  test('txEquals', () => {
    expect(txEquals({ id: 'tx1' } as Cardano.TxAlonzo, { id: 'tx2' } as Cardano.TxAlonzo)).toBe(false);
    expect(txEquals({ id: 'tx1' } as Cardano.TxAlonzo, { id: 'tx1' } as Cardano.TxAlonzo)).toBe(true);
  });

  test('transactionsEquals', () => {
    expect(transactionsEquals([], [])).toBe(true);
    expect(transactionsEquals([{ id: 'id1' } as Cardano.TxAlonzo], [{ id: 'id2' } as Cardano.TxAlonzo])).toBe(false);
    expect(transactionsEquals([{ id: 'id1' } as Cardano.TxAlonzo], [{ id: 'id1' } as Cardano.TxAlonzo])).toBe(true);
  });

  test('utxoEquals ', () => {
    expect(utxoEquals([], [])).toBe(true);
    expect(utxoEquals([[{ index: 0, txId: 'tx1' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(true);
    expect(utxoEquals([[{ index: 0, txId: 'tx2' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(false);
    expect(utxoEquals([[{ index: 1, txId: 'tx1' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(false);
  });
});
