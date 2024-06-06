import {
  AcquirePointNotOnChainError,
  AcquirePointTooOldError,
  EraMismatchError,
  IntersectionNotFoundError,
  QueryUnavailableInCurrentEraError,
  ServerNotReady,
  TipIsOriginError,
  TxSubmission,
  UnknownResultError,
  WebSocketClosed
} from '@cardano-ogmios/client';
import { ComposableError } from '@cardano-sdk/util';
import { CustomError } from 'ts-custom-error';

export class NotInitializedError extends CustomError {
  constructor(methodName: string, moduleName: string) {
    super(`${methodName} cannot be called until ${moduleName} is initialized`);
  }
}

// CardanoNode related errors
export class UnknownCardanoNodeError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(innerError: InnerError) {
    super('Unknown CardanoNode error', innerError);
  }
}

export const CardanoClientErrors = {
  AcquirePointNotOnChainError,
  AcquirePointTooOldError,
  ConnectionError: WebSocketClosed,
  EraMismatchError,
  IntersectionNotFoundError,
  QueryUnavailableInCurrentEraError,
  ServerNotReady,
  TipIsOriginError,
  UnknownResultError
};

type CardanoClientErrorName = keyof typeof CardanoClientErrors;
type CardanoClientErrorClass = (typeof CardanoClientErrors)[CardanoClientErrorName];

// TxSubmission related errors
export class UnknownTxSubmissionError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(innerError: InnerError) {
    super('Unknown submission error', innerError);
  }
}

const ogmiosSubmissionErrors = TxSubmission.submissionErrors.errors;

export const TxSubmissionErrors = {
  AddressAttributesTooLargeError: ogmiosSubmissionErrors.AddressAttributesTooLarge.Error,
  AlreadyDelegatingError: ogmiosSubmissionErrors.AlreadyDelegating.Error,
  BadInputsError: ogmiosSubmissionErrors.BadInputs.Error,
  CollateralHasNonAdaAssetsError: ogmiosSubmissionErrors.CollateralHasNonAdaAssets.Error,
  CollateralIsScriptError: ogmiosSubmissionErrors.CollateralIsScript.Error,
  CollateralTooSmallError: ogmiosSubmissionErrors.CollateralTooSmall.Error,
  CollectErrorsError: ogmiosSubmissionErrors.CollectErrors.Error,
  DelegateNotRegisteredError: ogmiosSubmissionErrors.DelegateNotRegistered.Error,
  DuplicateGenesisVrfError: ogmiosSubmissionErrors.DuplicateGenesisVrf.Error,
  EraMismatchError: ogmiosSubmissionErrors.EraMismatch.Error,
  ExecutionUnitsTooLargeError: ogmiosSubmissionErrors.ExecutionUnitsTooLarge.Error,
  ExpiredUtxoError: ogmiosSubmissionErrors.ExpiredUtxo.Error,
  ExtraDataMismatchError: ogmiosSubmissionErrors.ExtraDataMismatch.Error,
  ExtraRedeemersError: ogmiosSubmissionErrors.ExtraRedeemers.Error,
  ExtraScriptWitnessesError: ogmiosSubmissionErrors.ExtraScriptWitnesses.Error,
  FeeTooSmallError: ogmiosSubmissionErrors.FeeTooSmall.Error,
  InsufficientFundsForMirError: ogmiosSubmissionErrors.InsufficientFundsForMir.Error,
  InsufficientGenesisSignaturesError: ogmiosSubmissionErrors.InsufficientGenesisSignatures.Error,
  InvalidMetadataError: ogmiosSubmissionErrors.InvalidMetadata.Error,
  InvalidWitnessesError: ogmiosSubmissionErrors.InvalidWitnesses.Error,
  MalformedReferenceScriptsError: ogmiosSubmissionErrors.MalformedReferenceScripts.Error,
  MalformedScriptWitnessesError: ogmiosSubmissionErrors.MalformedScriptWitnesses.Error,
  MirNegativeTransferError: ogmiosSubmissionErrors.MirNegativeTransfer.Error,
  MirNegativeTransferNotCurrentlyAllowedError: ogmiosSubmissionErrors.MirNegativeTransferNotCurrentlyAllowed.Error,
  MirProducesNegativeUpdateError: ogmiosSubmissionErrors.MirProducesNegativeUpdate.Error,
  MirTransferNotCurrentlyAllowedError: ogmiosSubmissionErrors.MirTransferNotCurrentlyAllowed.Error,
  MissingAtLeastOneInputUtxoError: ogmiosSubmissionErrors.MissingAtLeastOneInputUtxo.Error,
  MissingCollateralInputsError: ogmiosSubmissionErrors.MissingCollateralInputs.Error,
  MissingDatumHashesForInputsError: ogmiosSubmissionErrors.MissingDatumHashesForInputs.Error,
  MissingRequiredDatumsError: ogmiosSubmissionErrors.MissingRequiredDatums.Error,
  MissingRequiredRedeemersError: ogmiosSubmissionErrors.MissingRequiredRedeemers.Error,
  MissingRequiredSignaturesError: ogmiosSubmissionErrors.MissingRequiredSignatures.Error,
  MissingScriptWitnessesError: ogmiosSubmissionErrors.MissingScriptWitnesses.Error,
  MissingTxMetadataError: ogmiosSubmissionErrors.MissingTxMetadata.Error,
  MissingTxMetadataHashError: ogmiosSubmissionErrors.MissingTxMetadataHash.Error,
  MissingVkWitnessesError: ogmiosSubmissionErrors.MissingVkWitnesses.Error,
  NetworkMismatchError: ogmiosSubmissionErrors.NetworkMismatch.Error,
  NonGenesisVotersError: ogmiosSubmissionErrors.NonGenesisVoters.Error,
  OutputTooSmallError: ogmiosSubmissionErrors.OutputTooSmall.Error,
  OutsideForecastError: ogmiosSubmissionErrors.OutsideForecast.Error,
  OutsideOfValidityIntervalError: ogmiosSubmissionErrors.OutsideOfValidityInterval.Error,
  PoolCostTooSmallError: ogmiosSubmissionErrors.PoolCostTooSmall.Error,
  PoolMetadataHashTooBigError: ogmiosSubmissionErrors.PoolMetadataHashTooBig.Error,
  ProtocolVersionCannotFollowError: ogmiosSubmissionErrors.ProtocolVersionCannotFollow.Error,
  RewardAccountNotEmptyError: ogmiosSubmissionErrors.RewardAccountNotEmpty.Error,
  RewardAccountNotExistingError: ogmiosSubmissionErrors.RewardAccountNotExisting.Error,
  ScriptWitnessNotValidatingError: ogmiosSubmissionErrors.ScriptWitnessNotValidating.Error,
  StakeKeyAlreadyRegisteredError: ogmiosSubmissionErrors.StakeKeyAlreadyRegistered.Error,
  StakeKeyNotRegisteredError: ogmiosSubmissionErrors.StakeKeyNotRegistered.Error,
  StakePoolNotRegisteredError: ogmiosSubmissionErrors.StakePoolNotRegistered.Error,
  TooLateForMirError: ogmiosSubmissionErrors.TooLateForMir.Error,
  TooManyAssetsInOutputError: ogmiosSubmissionErrors.TooManyAssetsInOutput.Error,
  TooManyCollateralInputsError: ogmiosSubmissionErrors.TooManyCollateralInputs.Error,
  TotalCollateralMismatchError: ogmiosSubmissionErrors.TotalCollateralMismatch.Error,
  TriesToForgeAdaError: ogmiosSubmissionErrors.TriesToForgeAda.Error,
  TxMetadataHashMismatchError: ogmiosSubmissionErrors.TxMetadataHashMismatch.Error,
  TxTooLargeError: ogmiosSubmissionErrors.TxTooLarge.Error,
  UnknownGenesisKeyError: ogmiosSubmissionErrors.UnknownGenesisKey.Error,
  UnknownOrIncompleteWithdrawalsError: ogmiosSubmissionErrors.UnknownOrIncompleteWithdrawals.Error,
  UnspendableDatumsError: ogmiosSubmissionErrors.UnspendableDatums.Error,
  UnspendableScriptInputsError: ogmiosSubmissionErrors.UnspendableScriptInputs.Error,
  UpdateWrongEpochError: ogmiosSubmissionErrors.UpdateWrongEpoch.Error,
  ValidationTagMismatchError: ogmiosSubmissionErrors.ValidationTagMismatch.Error,
  ValueNotConservedError: ogmiosSubmissionErrors.ValueNotConserved.Error,
  WrongCertificateTypeError: ogmiosSubmissionErrors.WrongCertificateType.Error,
  WrongPoolCertificateError: ogmiosSubmissionErrors.WrongPoolCertificate.Error,
  WrongRetirementEpochError: ogmiosSubmissionErrors.WrongRetirementEpoch.Error
};

type TxSubmissionErrorName = keyof typeof TxSubmissionErrors;
type TxSubmissionErrorClass = (typeof TxSubmissionErrors)[TxSubmissionErrorName];

export type TxSubmissionError = InstanceType<TxSubmissionErrorClass> | UnknownTxSubmissionError;

export type CardanoNodeError =
  | InstanceType<CardanoClientErrorClass>
  | UnknownCardanoNodeError
  | NotInitializedError
  | TxSubmissionError;
