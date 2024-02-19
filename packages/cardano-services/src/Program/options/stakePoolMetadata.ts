import { Command } from 'commander';
import { MissingProgramOption } from '../errors';
import { STAKE_POOL_METADATA_QUEUE } from '@cardano-sdk/projection-typeorm';
import { addOptions, newOption } from './util';
import { urlValidator } from '../../util/validators';

export enum StakePoolMetadataOptionDescriptions {
  Mode = 'This mode governs where the stake pool metadata is fetched from',
  Url = 'SMASH server api url'
}

export enum StakePoolMetadataFetchMode {
  /**
   * Use metadata available from the provided data by the projection. Projection reads its data directly from the certificate.
   */
  DIRECT = 'direct',
  /** Use configured SMASH server to fetch stake pool metadata. */
  SMASH = 'smash'
}

export interface StakePoolMetadataProgramOptions {
  smashUrl?: string;
  metadataFetchMode: StakePoolMetadataFetchMode;
}

export const withStakePoolMetadataOptions = (command: Command) => {
  addOptions(command, [
    newOption(
      '--metadata-fetch-mode <metadataFetchMode>',
      StakePoolMetadataOptionDescriptions.Mode,
      'METADATA_FETCH_MODE',
      (mode: string) => StakePoolMetadataFetchMode[mode.toUpperCase() as keyof typeof StakePoolMetadataFetchMode],
      'direct'
    ).choices(['direct', 'smash']),
    newOption(
      '--smash-url <smashUrl>',
      StakePoolMetadataOptionDescriptions.Url,
      'SMASH_URL',
      urlValidator(StakePoolMetadataOptionDescriptions.Url, true)
    )
  ]);

  return command;
};

export const checkProgramOptions = (metadataFetchMode: StakePoolMetadataFetchMode, smashUrl: string | undefined) => {
  if (metadataFetchMode === StakePoolMetadataFetchMode.SMASH && !smashUrl)
    throw new MissingProgramOption(STAKE_POOL_METADATA_QUEUE, 'smash-url to be set when metadata-fetch-mode is smash');
};
