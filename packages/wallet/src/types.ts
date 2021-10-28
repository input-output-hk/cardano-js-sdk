import { Cardano } from '@cardano-sdk/core';

export type Milliseconds = number;

/** internal = change address & external = receipt address */
export enum AddressType {
  internal = 'Internal',
  external = 'External'
}

export interface Address {
  address: string;
  index: number;
  type: AddressType;
  accountIndex: number;
}

export interface Balance extends Cardano.Value {
  rewards: Cardano.Lovelace;
}
