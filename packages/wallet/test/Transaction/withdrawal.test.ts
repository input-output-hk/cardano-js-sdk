import { CSL } from '@cardano-sdk/core';
import { Transaction } from '../../src';
import { testKeyManager } from '../mocks';

describe('Transaction.withdrawal', () => {
  it('creates objects of correct types', async () => {
    const keyManager = await testKeyManager();
    const withdrawal = Transaction.withdrawal(keyManager, 5000n);
    expect(withdrawal.address).toBeInstanceOf(CSL.RewardAddress);
    expect(withdrawal.quantity).toBeInstanceOf(CSL.BigNum);
  });
});
