/* eslint-disable @typescript-eslint/no-explicit-any */
import { arrayEquals, directionalTransactionsEquals, strictEquals, utxoEquals } from '../../../src';

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

  test('directionalTransactionsEquals ', () => {
    expect(directionalTransactionsEquals([], [])).toBe(true);
    expect(directionalTransactionsEquals([{ tx: { id: 'id1' } }] as any[], [{ tx: { id: 'id2' } }] as any[])).toBe(
      false
    );
    expect(directionalTransactionsEquals([{ tx: { id: 'id1' } }] as any[], [{ tx: { id: 'id1' } }] as any[])).toBe(
      true
    );
  });

  test('utxoEquals ', () => {
    expect(utxoEquals([], [])).toBe(true);
    expect(utxoEquals([[{ index: 0, txId: 'tx1' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(true);
    expect(utxoEquals([[{ index: 0, txId: 'tx2' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(false);
    expect(utxoEquals([[{ index: 1, txId: 'tx1' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(false);
  });
});
