import { Cardano } from '@cardano-sdk/core';
import { ogmiosToCore } from '../../src/index.js';
import type { Schema } from '@cardano-ogmios/client';

describe('ogmiosToCore', () => {
  describe('genesis', () => {
    it('converts all incompatible genesis properties to core types', () => {
      const ogmiosGenesis: Omit<Schema.CompactGenesis, 'protocolParameters'> = {
        activeSlotsCoefficient: '1/20',
        epochLength: 86_400,
        maxKesEvolutions: 120,
        maxLovelaceSupply: 45_000_000_000_000_000,
        network: 'testnet',
        networkMagic: 2,
        securityParameter: 432,
        slotLength: 1,
        slotsPerKesPeriod: 86_400,
        systemStart: '2022-08-09T00:00:00Z',
        updateQuorum: 5
      };
      expect(ogmiosToCore.genesis(ogmiosGenesis as Schema.CompactGenesis)).toEqual({
        ...ogmiosGenesis,
        activeSlotsCoefficient: 0.05,
        maxLovelaceSupply: 45_000_000_000_000_000n,
        networkId: Cardano.NetworkId.Testnet,
        systemStart: new Date('2022-08-09T00:00:00Z')
      });
    });
  });
});
