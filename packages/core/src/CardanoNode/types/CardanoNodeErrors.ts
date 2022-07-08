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
import { CustomError } from 'ts-custom-error';

export class UnknownCardanoNodeError extends CustomError {
  constructor(public innerError: unknown) {
    super('Unknown CardanoNode error. See "innerError".');
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
