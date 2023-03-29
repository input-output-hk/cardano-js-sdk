import * as supportedSinks from './sinks';
import {
  AlreadyHasActiveConnectionError,
  CannotConnectAlreadyConnectedError,
  CannotExecuteNotConnectedError,
  CannotGetEntityManagerNotConnectedError,
  ConnectionIsNotSetError,
  ConnectionNotFoundError,
  NoConnectionForRepositoryError,
  NoConnectionOptionError,
  NoNeedToReleaseEntityManagerError,
  NoVersionOrUpdateDateColumnError,
  PersistedEntityNotFoundError,
  PessimisticLockTransactionRequiredError,
  QueryRunnerAlreadyReleasedError,
  QueryRunnerProviderAlreadyReleasedError,
  TransactionAlreadyStartedError,
  TransactionNotStartedError
} from 'typeorm';
import { Projections, SinkObservable } from '@cardano-sdk/projection';
import { WithTypeormContext } from './types';

// Might have to adjust this list - classes were picked based on names and their doc comments
const recoverableErrorClasses = [
  AlreadyHasActiveConnectionError,
  CannotConnectAlreadyConnectedError,
  CannotExecuteNotConnectedError,
  CannotGetEntityManagerNotConnectedError,
  ConnectionIsNotSetError,
  ConnectionNotFoundError,
  NoConnectionForRepositoryError,
  NoConnectionOptionError,
  NoNeedToReleaseEntityManagerError,
  NoVersionOrUpdateDateColumnError,
  PersistedEntityNotFoundError,
  PessimisticLockTransactionRequiredError,
  QueryRunnerAlreadyReleasedError,
  QueryRunnerProviderAlreadyReleasedError,
  TransactionAlreadyStartedError,
  TransactionNotStartedError
];

export const isRecoverableTypeormError = (error: unknown) =>
  recoverableErrorClasses.some((Class) => error instanceof Class);

export const applySinks = <P extends {}>(projections: P) => {
  const selectedSinks = Object.entries(supportedSinks)
    .filter(([id]) => id in projections)
    .map(([_, { sink$ }]) => sink$);
  return (evt$: SinkObservable<P, WithTypeormContext>) =>
    // eslint-disable-next-line prefer-spread, @typescript-eslint/no-explicit-any
    evt$.pipe.apply(evt$, selectedSinks as any) as SinkObservable<P, WithTypeormContext>;
};

export { supportedSinks };
export type SupportedProjections = Pick<Projections.AllProjections, keyof typeof supportedSinks>;
