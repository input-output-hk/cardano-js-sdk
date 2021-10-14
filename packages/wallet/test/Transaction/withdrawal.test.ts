import { loadCardanoSerializationLib } from '@cardano-sdk/core';
import { testKeyManager } from '../mocks';
import { Transaction } from '../../src';

describe('Transaction.withdrawal', () => {
  it('creates objects of correct types', async () => {
    const csl = await loadCardanoSerializationLib();
    const keyManager = await testKeyManager(csl);
    const withdrawal = Transaction.withdrawal(csl, keyManager, 5000n);
    expect(withdrawal.address).toBeInstanceOf(csl.RewardAddress);
    expect(withdrawal.quantity).toBeInstanceOf(csl.BigNum);
  });
});
