import { APExtMetadataResponse, Cip6ExtMetadataResponse } from './HttpStakePoolMetadata';
import { Cardano } from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';

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
