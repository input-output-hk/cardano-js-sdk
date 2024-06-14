import { Cardano, Milliseconds } from '@cardano-sdk/core';
import { Schema } from '@cardano-ogmios/client';
import omit from 'lodash/omit.js';

export const genesis = (ogmiosGenesis: Schema.GenesisShelley): Cardano.CompactGenesis => ({
  ...omit(ogmiosGenesis, 'initialParameters'),
  activeSlotsCoefficient: (() => {
    const [nominator, denominator] = ogmiosGenesis.activeSlotsCoefficient.split('/');
    return Number(nominator) / Number(denominator);
  })(),
  maxLovelaceSupply: BigInt(ogmiosGenesis.maxLovelaceSupply),
  networkId: ogmiosGenesis.network === 'mainnet' ? Cardano.NetworkId.Mainnet : Cardano.NetworkId.Testnet,
  slotLength: Milliseconds.toSeconds(Milliseconds(Number(ogmiosGenesis.slotLength.milliseconds))),
  systemStart: new Date(ogmiosGenesis.startTime)
});
