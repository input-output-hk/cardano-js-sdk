import { APExtMetadataResponse, Cip6ExtMetadataResponse, StakePoolMetadataResponse } from './HttpStakePoolMetadata';
import { Cardano } from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';

export interface StakePoolMetadataService {
  getStakePoolMetadata(hash: Hash32ByteBase16, url: string): Promise<StakePoolMetadataResponse>;
  getStakePoolExtendedMetadata(poolMetadata: Cardano.StakePoolMetadata): Promise<Cardano.ExtendedStakePoolMetadata>;
}

export enum ExtMetadataFormat {
  CIP6 = 'cip-6',
  AdaPools = 'ada-pools'
}

export type StakePoolExtMetadataResponse = APExtMetadataResponse | Cip6ExtMetadataResponse;
