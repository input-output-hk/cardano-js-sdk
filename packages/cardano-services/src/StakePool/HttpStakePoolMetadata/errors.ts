import { ComposableError, formatErrorMessage } from '@cardano-sdk/util';

export enum StakePoolMetadataServiceFailure {
  FailedToFetchExtendedMetadata = 'FAILED_TO_FETCH_EXTENDED_METADATA',
  FailedToFetchMetadata = 'FAILED_TO_FETCH_METADATA',
  FailedToFetchExtendedSignature = 'FAILED_TO_FETCH_EXTENDED_SIGNATURE',
  InvalidExtendedMetadataFormat = 'INVALID_EXTENDED_METADATA_FORMAT',
  InvalidExtendedMetadataSignature = 'INVALID_EXTENDED_METADATA_SIGNATURE',
  InvalidStakePoolHash = 'INVALID_STAKE_POOL_HASH',
  InvalidMetadata = 'INVALID_METADATA',
  Unknown = 'UNKNOWN_ERROR'
}

export class StakePoolMetadataServiceError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(public reason: StakePoolMetadataServiceFailure, innerError?: InnerError, public detail?: string) {
    super(formatErrorMessage(reason, detail), innerError);
  }
}

export class SmashStakePoolDelistedServiceError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(innerError?: InnerError, public detail?: string) {
    super(formatErrorMessage('FAILED_TO_FETCH_DELISTED_POOLS', detail), innerError);
  }
}
