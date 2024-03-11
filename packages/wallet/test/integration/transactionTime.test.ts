import { BaseWallet } from '../../src';
import { createSlotTimeCalc } from '@cardano-sdk/core';
import { createWallet } from './util';
import { firstValueFrom } from 'rxjs';

describe('integration/transactionTime', () => {
  let wallet: BaseWallet;

  beforeAll(async () => {
    ({ wallet } = await createWallet());
  });

  it('provides utils necessary for computing transaction time', async () => {
    const transactions = await firstValueFrom(wallet.transactions.history$);
    const eraSummaries = await firstValueFrom(wallet.eraSummaries$);
    const slotTimeCalc = createSlotTimeCalc(eraSummaries);
    const transactionTime = slotTimeCalc(transactions[0].blockHeader.slot);
    expect(typeof transactionTime.getTime()).toBe('number');
  });

  afterAll(() => wallet.shutdown());
});
