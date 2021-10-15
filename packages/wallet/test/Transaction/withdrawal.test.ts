import { CSL } from '@cardano-sdk/core';
import { testKeyManager } from '../mocks';
import { Transaction } from '../../src';

describe('Transaction.withdrawal', () => {
  it('creates objects of correct types', async () => {
    const keyManager = await testKeyManager();
    const withdrawal = Transaction.withdrawal(keyManager, 5000n);
    expect(withdrawal.address).toBeInstanceOf(CSL.RewardAddress);
    expect(withdrawal.quantity).toBeInstanceOf(CSL.BigNum);
  });
});
