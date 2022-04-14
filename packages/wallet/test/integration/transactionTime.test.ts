import { SingleAddressWallet } from '../../src';
import { createSlotTimeCalc } from '@cardano-sdk/core';
import { createWallet } from './util';
import { firstValueFrom } from 'rxjs';

describe('integration/transactionTime', () => {
  let wallet: SingleAddressWallet;

  beforeAll(async () => {
    wallet = await createWallet();
  });

  it('provides utils necessary for computing transaction time', async () => {
    const transactions = await firstValueFrom(wallet.transactions.history.incoming$);
    const {
      network: { timeSettings }
    } = await firstValueFrom(wallet.networkInfo$);
    const slotTimeCalc = createSlotTimeCalc(timeSettings);
    const transactionTime = slotTimeCalc(transactions[0].blockHeader.slot);
    expect(typeof transactionTime.getTime()).toBe('number');
  });

  afterAll(() => wallet.shutdown());
});
