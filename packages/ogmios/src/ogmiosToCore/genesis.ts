import { Cardano, Seconds } from '@cardano-sdk/core';
import { Schema } from '@cardano-ogmios/client';
import omit from 'lodash/omit';

// REVIEW: Schema.GenesisShelley has all the properties we are looking for here
export const genesis = (ogmiosGenesis: Schema.GenesisShelley): Cardano.CompactGenesis => ({
  ...omit(ogmiosGenesis, 'initialParameters'),
  activeSlotsCoefficient: (() => {
    const [nominator, denominator] = ogmiosGenesis.activeSlotsCoefficient.split('/');
    return Number(nominator) / Number(denominator);
  })(),
  maxLovelaceSupply: BigInt(ogmiosGenesis.maxLovelaceSupply),
  networkId: ogmiosGenesis.network === 'mainnet' ? Cardano.NetworkId.Mainnet : Cardano.NetworkId.Testnet,
  slotLength: Seconds(ogmiosGenesis.slotLength.seconds),
  systemStart: new Date(ogmiosGenesis.startTime)
});
