import { loadCardanoSerializationLib } from '@cardano-sdk/core';
import { testKeyManager } from '../testKeyManager';
import { Delegation } from '../../src';

describe('Delegation.withdrawal', () => {
  it('creates objects of correct types', async () => {
    const csl = await loadCardanoSerializationLib();
    const keyManager = await testKeyManager(csl);
    const withdrawal = Delegation.withdrawal(csl, keyManager, 5000);
    expect(withdrawal.address).toBeInstanceOf(csl.RewardAddress);
    expect(withdrawal.quantity).toBeInstanceOf(csl.BigNum);
  });
});
