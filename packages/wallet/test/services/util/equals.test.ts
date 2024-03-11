/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, EpochInfo, EraSummary } from '@cardano-sdk/core';
import {
  DelegatedStake,
  delegatedStakeEquals,
  epochInfoEquals,
  eraSummariesEquals,
  groupedAddressesEquals,
  signedTxsEquals,
  tipEquals,
  transactionsEquals,
  txEquals,
  utxoEquals
} from '../../../src';
import { GroupedAddress, WitnessedTx } from '@cardano-sdk/key-management';
import { Percent } from '@cardano-sdk/util';

describe('equals', () => {
  const txId1 = Cardano.TransactionId('4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6');
  const txId2 = Cardano.TransactionId('01d7366549986d83edeea262e97b68eca3430d3bb052ed1c37d2202fd5458872');

  test('txEquals', () => {
    expect(txEquals({ id: txId1 } as Cardano.HydratedTx, { id: txId2 } as Cardano.HydratedTx)).toBe(false);
    expect(txEquals({ id: txId1 } as Cardano.HydratedTx, { id: txId1 } as Cardano.HydratedTx)).toBe(true);
  });

  test('transactionsEquals', () => {
    expect(transactionsEquals([], [])).toBe(true);
    expect(transactionsEquals([{ id: txId1 } as Cardano.HydratedTx], [{ id: txId2 } as Cardano.HydratedTx])).toBe(
      false
    );
    expect(transactionsEquals([{ id: txId1 } as Cardano.HydratedTx], [{ id: txId1 } as Cardano.HydratedTx])).toBe(true);
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
    const addresses1 = [{ address: 'a' as unknown as Cardano.PaymentAddress } as GroupedAddress];
    const addresses2 = [{ address: 'b' as unknown as Cardano.PaymentAddress } as GroupedAddress];
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

  test('delegatedStakeEquals compares poolId, stake and percentage changes', () => {
    const pool1: DelegatedStake = {
      percentage: Percent(0.45),
      pool: { id: 'abc' },
      stake: 100n
    } as DelegatedStake;

    expect(delegatedStakeEquals(pool1, { ...pool1 })).toBe(true);
    expect(delegatedStakeEquals(pool1, { ...pool1, pool: { id: 'cde' } as Cardano.StakePool })).toBe(false);
    expect(delegatedStakeEquals(pool1, { ...pool1, percentage: Percent(0.22) })).toBe(false);
    expect(delegatedStakeEquals(pool1, { ...pool1, stake: 101n })).toBe(false);
  });

  test('signedTxsEquals compares signed tx id', () => {
    const signedTxs1 = [{ tx: { id: txId1 } } as WitnessedTx];
    const signedTxs2 = [{ tx: { id: txId2 } } as WitnessedTx];
    expect(signedTxsEquals(signedTxs1, [...signedTxs1.map((signedTx) => ({ ...signedTx }))])).toBe(true);
    expect(signedTxsEquals(signedTxs1, signedTxs2)).toBe(false);
  });
});
