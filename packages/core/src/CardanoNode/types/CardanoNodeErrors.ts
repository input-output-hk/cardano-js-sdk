import {
  AcquirePointNotOnChainError,
  AcquirePointTooOldError,
  EraMismatchError,
  IntersectionNotFoundError,
  QueryUnavailableInCurrentEraError,
  ServerNotReady,
  TipIsOriginError,
  UnknownResultError,
  WebSocketClosed
} from '@cardano-ogmios/client';
import { ComposableError } from '../../errors';
import { CustomError } from 'ts-custom-error';

export class UnknownCardanoNodeError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(innerError: InnerError) {
    super('Unknown CardanoNode error', innerError);
  }
}

export class CardanoNodeNotInitializedError extends CustomError {
  constructor(methodName: string) {
    super(`${methodName} cannot be called until CardanoNode is initialized`);
  }
}

export const CardanoClientErrors = {
  AcquirePointNotOnChainError,
  AcquirePointTooOldError,
  EraMismatchError,
  IntersectionNotFoundError,
  QueryUnavailableInCurrentEraError,
  ServerNotReady,
  TipIsOriginError,
  UnknownResultError,
  WebSocketClosed
};

type CardanoClientErrorName = keyof typeof CardanoClientErrors;
type CardanoClientErrorClass = typeof CardanoClientErrors[CardanoClientErrorName];
export type CardanoNodeError =
  | InstanceType<CardanoClientErrorClass>
  | UnknownCardanoNodeError
  | CardanoNodeNotInitializedError;
