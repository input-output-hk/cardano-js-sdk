/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, EpochInfo, EraSummary } from '@cardano-sdk/core';
import { GroupedAddress } from '@cardano-sdk/key-management';
import {
  arrayEquals,
  epochInfoEquals,
  eraSummariesEquals,
  groupedAddressesEquals,
  shallowArrayEquals,
  strictEquals,
  tipEquals,
  transactionsEquals,
  txEquals,
  utxoEquals
} from '../../../src';

describe('equals', () => {
  const txId1 = Cardano.TransactionId('4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6');
  const txId2 = Cardano.TransactionId('01d7366549986d83edeea262e97b68eca3430d3bb052ed1c37d2202fd5458872');

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
    expect(txEquals({ id: txId1 } as Cardano.TxAlonzo, { id: txId2 } as Cardano.TxAlonzo)).toBe(false);
    expect(txEquals({ id: txId1 } as Cardano.TxAlonzo, { id: txId1 } as Cardano.TxAlonzo)).toBe(true);
  });

  test('transactionsEquals', () => {
    expect(transactionsEquals([], [])).toBe(true);
    expect(transactionsEquals([{ id: txId1 } as Cardano.TxAlonzo], [{ id: txId2 } as Cardano.TxAlonzo])).toBe(false);
    expect(transactionsEquals([{ id: txId1 } as Cardano.TxAlonzo], [{ id: txId1 } as Cardano.TxAlonzo])).toBe(true);
  });

  test('utxoEquals ', () => {
    expect(utxoEquals([], [])).toBe(true);
    expect(utxoEquals([[{ index: 0, txId: 'tx1' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(true);
    expect(utxoEquals([[{ index: 0, txId: 'tx2' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(false);
    expect(utxoEquals([[{ index: 1, txId: 'tx1' }]] as any, [[{ index: 0, txId: 'tx1' }]] as any)).toBe(false);
  });

  test('eraSummariesEquals compares fromSlotNo', () => {
    expect(eraSummariesEquals([{ start: { slot: 1 } } as EraSummary], [{ start: { slot: 1 } } as EraSummary])).toBe(
      true
    );
    expect(eraSummariesEquals([{ start: { slot: 1 } } as EraSummary], [{ start: { slot: 2 } } as EraSummary])).toBe(
      false
    );
  });

  test('groupedAddressesEquals compares address', () => {
    const addresses1 = [{ address: 'a' as unknown as Cardano.Address } as GroupedAddress];
    const addresses2 = [{ address: 'b' as unknown as Cardano.Address } as GroupedAddress];
    expect(groupedAddressesEquals(addresses1, [...addresses1.map((addr) => ({ ...addr }))])).toBe(true);
    expect(groupedAddressesEquals(addresses1, addresses2)).toBe(false);
  });

  test('tipEquals compares hash', () => {
    const tip1 = { hash: 'hash1' } as unknown as Cardano.Tip;
    const tip2 = { hash: 'hash2' } as unknown as Cardano.Tip;
    expect(tipEquals(tip1, { ...tip1 })).toBe(true);
    expect(tipEquals(tip1, tip2)).toBe(false);
  });

  test('epochInfoEquals compares epochNo', () => {
    const info1 = { epochNo: 1 } as unknown as EpochInfo;
    const info2 = { epochNo: 2 } as unknown as EpochInfo;
    expect(epochInfoEquals(info1, { ...info1 })).toBe(true);
    expect(epochInfoEquals(info1, info2)).toBe(false);
  });
});
