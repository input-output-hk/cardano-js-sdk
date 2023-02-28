import { APExtMetadataResponse, Cip6ExtMetadataResponse } from './HttpStakePoolMetadata';
import { Cardano } from '@cardano-sdk/core';

export interface StakePoolMetadataService {
  getStakePoolExtendedMetadata(
    poolMetadata: Cardano.StakePoolMetadata
  ): Promise<Cardano.ExtendedStakePoolMetadata | null>;
}

export enum ExtMetadataFormat {
  CIP6 = 'cip-6',
  AdaPools = 'ada-pools'
}

export type StakePoolExtMetadataResponse = APExtMetadataResponse | Cip6ExtMetadataResponse;
