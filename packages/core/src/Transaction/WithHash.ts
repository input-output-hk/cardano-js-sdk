import OgmiosSchema from '@cardano-ogmios/schema';

export type WithHash = { hash: OgmiosSchema.Hash16 } & OgmiosSchema.Tx;
