import { Cardano, Seconds } from '@cardano-sdk/core';
import { Schema } from '@cardano-ogmios/client';
import omit from 'lodash/omit.js';

export const genesis = (ogmiosGenesis: Schema.CompactGenesis): Cardano.CompactGenesis => ({
  ...omit(ogmiosGenesis, 'protocolParameters'),
  activeSlotsCoefficient: (() => {
    const [nominator, denominator] = ogmiosGenesis.activeSlotsCoefficient.split('/');
    return Number(nominator) / Number(denominator);
  })(),
  maxLovelaceSupply: BigInt(ogmiosGenesis.maxLovelaceSupply),
  networkId: ogmiosGenesis.network === 'mainnet' ? Cardano.NetworkId.Mainnet : Cardano.NetworkId.Testnet,
  slotLength: Seconds(ogmiosGenesis.slotLength),
  systemStart: new Date(ogmiosGenesis.systemStart)
});
