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
