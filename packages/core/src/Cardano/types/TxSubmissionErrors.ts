import '@cardano-ogmios/schema';
import { CustomError } from 'ts-custom-error';
import { TxSubmission } from '@cardano-ogmios/client';

export class UnknownTxSubmissionError extends CustomError {
  constructor(public innerError: unknown) {
    super('Unknown submission error. See "innerError".');
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
type TxSubmissionErrorClass = typeof TxSubmissionErrors[TxSubmissionErrorName];
export type TxSubmissionError = InstanceType<TxSubmissionErrorClass> | UnknownTxSubmissionError;
