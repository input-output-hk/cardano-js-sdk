import { Cardano, Handle } from '.';
import { ComposableError, formatErrorMessage } from '@cardano-sdk/util';
import { CustomError } from 'ts-custom-error';

export enum ProviderFailure {
  Conflict = 'CONFLICT',
  NotFound = 'NOT_FOUND',
  Unknown = 'UNKNOWN',
  Forbidden = 'FORBIDDEN',
  InvalidResponse = 'INVALID_RESPONSE',
  NotImplemented = 'NOT_IMPLEMENTED',
  Unhealthy = 'UNHEALTHY',
  ConnectionFailure = 'CONNECTION_FAILURE',
  BadRequest = 'BAD_REQUEST',
  ServerUnavailable = 'SERVER_UNAVAILABLE'
}

export const providerFailureToStatusCodeMap: { [key in ProviderFailure]: number } = {
  [ProviderFailure.BadRequest]: 400,
  [ProviderFailure.Forbidden]: 403,
  [ProviderFailure.NotFound]: 404,
  [ProviderFailure.Conflict]: 409,
  [ProviderFailure.Unhealthy]: 500,
  [ProviderFailure.Unknown]: 500,
  [ProviderFailure.InvalidResponse]: 500,
  [ProviderFailure.NotImplemented]: 500,
  [ProviderFailure.ConnectionFailure]: 500,
  [ProviderFailure.ServerUnavailable]: 500
};

const isProviderFailure = (reason: string): reason is ProviderFailure =>
  Object.values(ProviderFailure).includes(reason as ProviderFailure);

export const reasonToProviderFailure = (reason: string): ProviderFailure =>
  isProviderFailure(reason) ? reason : ProviderFailure.Unknown;

export class ProviderError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(public reason: ProviderFailure, innerError?: InnerError, public detail?: string) {
    super(formatErrorMessage(reason, detail), innerError);
  }
}

export class HandleOwnerChangeError extends CustomError {
  constructor(
    public handle: Handle,
    public expectedAddress: Cardano.PaymentAddress,
    public actualAddress: Cardano.PaymentAddress | null
  ) {
    super(`Expected: ${expectedAddress} for handle $${handle}. Actual: ${actualAddress}`);
  }
}

export enum SerializationFailure {
  InvalidType = 'INVALID_TYPE',
  Overflow = 'OVERFLOW',
  InvalidAddress = 'INVALID_ADDRESS',
  MaxLengthLimit = 'MAX_LENGTH_LIMIT',
  InvalidScript = 'INVALID_SCRIPT',
  InvalidNativeScriptKind = 'INVALID_NATIVE_SCRIPT_KIND',
  InvalidScriptType = 'INVALID_SCRIPT_TYPE',
  InvalidDatum = 'INVALID_DATUM'
}

export class SerializationError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(public reason: SerializationFailure, public detail?: string, innerError?: InnerError) {
    super(formatErrorMessage(reason, detail), innerError);
  }
}

export class InvalidProtocolParametersError extends CustomError {
  public constructor(reason: string) {
    super(reason);
  }
}

export class NotImplementedError extends CustomError {
  public constructor(missingFeature: string) {
    super(`Not implemented: ${missingFeature}`);
  }
}

export class TimeoutError extends CustomError {
  public constructor(message: string) {
    super(`Timeout: ${message}`);
  }
}
