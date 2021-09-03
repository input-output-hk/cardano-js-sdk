import OgmiosSchema from '@cardano-ogmios/schema';

export type Tx = { hash: OgmiosSchema.Hash16 } & OgmiosSchema.Tx;
