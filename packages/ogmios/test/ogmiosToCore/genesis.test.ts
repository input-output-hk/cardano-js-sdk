import { Cardano, Milliseconds } from '@cardano-sdk/core';
import { mockGenesisShelley } from './testData';
import { ogmiosToCore } from '../../src';

describe('ogmiosToCore', () => {
  describe('genesis', () => {
    it('converts all incompatible genesis properties to core types', () => {
      expect(ogmiosToCore.genesis(mockGenesisShelley)).toEqual({
        ...mockGenesisShelley,
        activeSlotsCoefficient: 0.05,
        maxLovelaceSupply: 45_000_000_000_000_000n,
        networkId: Cardano.NetworkId.Testnet,
        slotLength: Milliseconds.toSeconds(Milliseconds(Number(mockGenesisShelley.slotLength.milliseconds))),
        systemStart: new Date('2022-08-09T00:00:00Z')
      } as Cardano.CompactGenesis);
    });
  });
});
