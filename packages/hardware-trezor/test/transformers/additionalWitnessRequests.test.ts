import { contextWithKnownAddresses, txIn } from '../testData';
import { mapAdditionalWitnessRequests } from '../../src/transformers/additionalWitnessRequests';
import { toTrezorTxIn } from '../../src';

describe('additionalWitnessRequests', () => {
  it('should include payment key paths and reward account key path from given inputs', async () => {
    const mappedTrezorTxIn = await toTrezorTxIn(txIn, contextWithKnownAddresses);
    const result = mapAdditionalWitnessRequests([mappedTrezorTxIn], contextWithKnownAddresses);
    expect(result).toEqual([
      [2_147_485_500, 2_147_485_463, 2_147_483_648, 1, 0], // payment key path
      [2_147_485_500, 2_147_485_463, 2_147_483_648, 2, 0] // reward account key path
    ]);
  });
});
