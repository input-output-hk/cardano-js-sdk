import { Cardano } from '@cardano-sdk/core';

export type Tip = Pick<Cardano.Tip, 'slot' | 'blockNo'>;
