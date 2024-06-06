import { TxInId } from '@cardano-sdk/key-management';
import { contextWithKnownAddresses, txIn } from '../testData.js';
import { mapAdditionalWitnessRequests } from '../../src/transformers/additionalWitnessRequests.js';

describe('additionalWitnessRequests', () => {
  it('should include payment key paths and reward account key path from given inputs', async () => {
    const paymentKeyPath = { index: 0, role: 1 };
    const result = mapAdditionalWitnessRequests([txIn], {
      ...contextWithKnownAddresses,
      txInKeyPathMap: { [TxInId(txIn)]: paymentKeyPath }
    });
    expect(result).toEqual([
      [2_147_485_500, 2_147_485_463, 2_147_483_648, paymentKeyPath.role, paymentKeyPath.index],
      [2_147_485_500, 2_147_485_463, 2_147_483_648, 2, 0] // reward account key path
    ]);
  });
});
