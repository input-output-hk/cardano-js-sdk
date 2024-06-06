import type { APExtMetadataResponse, Cip6ExtMetadataResponse } from './HttpStakePoolMetadata/index.js';
import type { Cardano } from '@cardano-sdk/core';
import type { CustomError } from 'ts-custom-error';
import type { Hash32ByteBase16 } from '@cardano-sdk/crypto';

export interface StakePoolMetadataService {
  getStakePoolMetadata(hash: Hash32ByteBase16, url: string): Promise<Cardano.StakePoolMetadata | CustomError>;

  getStakePoolExtendedMetadata(poolMetadata: Cardano.StakePoolMetadata): Promise<Cardano.ExtendedStakePoolMetadata>;

  getValidateStakePoolExtendedMetadata(
    metadata: Cardano.StakePoolMetadata
  ): Promise<Cardano.ExtendedStakePoolMetadata | CustomError | undefined>;
}

export interface SmashStakePoolDelistedService {
  getDelistedStakePoolIds(): Promise<Array<string> | CustomError>;
}
export enum ExtMetadataFormat {
  CIP6 = 'cip-6',
  AdaPools = 'ada-pools'
}

export type StakePoolExtMetadataResponse = APExtMetadataResponse | Cip6ExtMetadataResponse;
