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
import Topo from '@hapi/topo';

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

export const projectionSinks = <P extends {}>(projections: P) =>
  Object.entries(supportedSinks).filter(([id]) => id in projections);

/**
 * Apply sinks in topological order, based on their inter-dependencies
 */
export const applySinks = <P extends {}>(projections: P, allSinks = projectionSinks(projections)) => {
  const selectedSinks = allSinks.map(([id, { dependencies, sink$ }]) => ({
    dependencies,
    id,
    sink$
  }));
  const sortedSinks = (() => {
    const sorter = new Topo.Sorter<typeof selectedSinks[0]['sink$']>();
    for (const { id, sink$, dependencies } of selectedSinks) {
      sorter.add(sink$, {
        after: dependencies,
        group: id
      });
    }
    return sorter.nodes;
  })();
  return (evt$: SinkObservable<P, WithTypeormContext>) =>
    // eslint-disable-next-line prefer-spread, @typescript-eslint/no-explicit-any
    evt$.pipe.apply(evt$, sortedSinks as any) as SinkObservable<P, WithTypeormContext>;
};

export { supportedSinks };
export type SupportedProjections = Pick<Projections.AllProjections, keyof typeof supportedSinks>;

export const shouldEnablePgBossExtension = <P extends {}>(projections: P) =>
  projectionSinks(projections).some(([_, { extensions }]) => extensions?.pgBoss);
