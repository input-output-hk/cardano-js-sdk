import { Slot, Hash16, Tx } from '@cardano-ogmios/schema';

export interface ValidityInterval {
  invalidBefore?: Slot;
  invalidHereafter?: Slot;
}

export type WithHash = { hash: Hash16 } & Tx;
