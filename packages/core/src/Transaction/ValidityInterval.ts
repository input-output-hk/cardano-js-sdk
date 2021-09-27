import { Slot } from '@cardano-ogmios/schema';

export interface ValidityInterval {
  invalidBefore?: Slot;
  invalidHereafter?: Slot;
}
