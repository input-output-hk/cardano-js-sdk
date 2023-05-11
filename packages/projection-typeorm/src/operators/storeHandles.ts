import { Mappers } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

export const storeHandles = typeormOperator<Mappers.WithHandles & Mappers.WithMint>(
  async ({ mint: _mint, handles: _handles }) => {
    // TODO: upsert the HandleEntity
    // check mint property: if this asset id is minted, then we need to query asset table
    // to check the supply quantity and set the handle address to null if >1
    // if asset is burned, we also need to check if maybe there's only 1 token of the handle remaining, then set it in handles table
    // Also, revert those operations when evt.type === ChainSyncEventType.RollBackwards
    throw new Error('Not implemented');
  }
);
