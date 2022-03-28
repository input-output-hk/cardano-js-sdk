import { CustomError } from 'ts-custom-error';
import { TxSubmission } from '@cardano-ogmios/client';

export class UnknownTxSubmissionError extends CustomError {
  constructor(public innerError: unknown) {
    super('Unknown submission error. See "innerError".');
  }
}

export const TxSubmissionErrors = {
  AddressAttributesTooLargeError: TxSubmission.errors.AddressAttributesTooLarge.Error,
  AlreadyDelegatingError: TxSubmission.errors.AlreadyDelegating.Error,
  BadInputsError: TxSubmission.errors.BadInputs.Error,
  CollateralHasNonAdaAssetsError: TxSubmission.errors.CollateralHasNonAdaAssets.Error,
  CollateralIsScriptError: TxSubmission.errors.CollateralIsScript.Error,
  CollateralTooSmallError: TxSubmission.errors.CollateralTooSmall.Error,
  CollectErrorsError: TxSubmission.errors.CollectErrors.Error,
  DelegateNotRegisteredError: TxSubmission.errors.DelegateNotRegistered.Error,
  DuplicateGenesisVrfError: TxSubmission.errors.DuplicateGenesisVrf.Error,
  EraMismatchError: TxSubmission.errors.EraMismatch.Error,
  ExecutionUnitsTooLargeError: TxSubmission.errors.ExecutionUnitsTooLarge.Error,
  ExpiredUtxoError: TxSubmission.errors.ExpiredUtxo.Error,
  ExtraDataMismatchError: TxSubmission.errors.ExtraDataMismatch.Error,
  ExtraRedeemersError: TxSubmission.errors.ExtraRedeemers.Error,
  ExtraScriptWitnessesError: TxSubmission.errors.ExtraScriptWitnesses.Error,
  FeeTooSmallError: TxSubmission.errors.FeeTooSmall.Error,
  InsufficientFundsForMirError: TxSubmission.errors.InsufficientFundsForMir.Error,
  InsufficientGenesisSignaturesError: TxSubmission.errors.InsufficientGenesisSignatures.Error,
  InvalidMetadataError: TxSubmission.errors.InvalidMetadata.Error,
  InvalidWitnessesError: TxSubmission.errors.InvalidWitnesses.Error,
  MirNegativeTransferNotCurrentlyAllowedError: TxSubmission.errors.MirNegativeTransferNotCurrentlyAllowed.Error,
  MirProducesNegativeUpdateError: TxSubmission.errors.MirProducesNegativeUpdate.Error,
  MirTransferNotCurrentlyAllowedError: TxSubmission.errors.MirTransferNotCurrentlyAllowed.Error,
  MissingAtLeastOneInputUtxoError: TxSubmission.errors.MissingAtLeastOneInputUtxo.Error,
  MissingCollateralInputsError: TxSubmission.errors.MissingCollateralInputs.Error,
  MissingDatumHashesForInputsError: TxSubmission.errors.MissingDatumHashesForInputs.Error,
  MissingRequiredDatumsError: TxSubmission.errors.MissingRequiredDatums.Error,
  MissingRequiredRedeemersError: TxSubmission.errors.MissingRequiredRedeemers.Error,
  MissingRequiredSignaturesError: TxSubmission.errors.MissingRequiredSignatures.Error,
  MissingScriptWitnessesError: TxSubmission.errors.MissingScriptWitnesses.Error,
  MissingTxMetadataError: TxSubmission.errors.MissingTxMetadata.Error,
  MissingTxMetadataHashError: TxSubmission.errors.MissingTxMetadataHash.Error,
  MissingVkWitnessesError: TxSubmission.errors.MissingVkWitnesses.Error,
  NetworkMismatchError: TxSubmission.errors.NetworkMismatch.Error,
  NonGenesisVotersError: TxSubmission.errors.NonGenesisVoters.Error,
  OutputTooSmallError: TxSubmission.errors.OutputTooSmall.Error,
  OutsideForecastError: TxSubmission.errors.OutsideForecast.Error,
  OutsideOfValidityIntervalError: TxSubmission.errors.OutsideOfValidityInterval.Error,
  PoolCostTooSmallError: TxSubmission.errors.PoolCostTooSmall.Error,
  PoolMetadataHashTooBigError: TxSubmission.errors.PoolMetadataHashTooBig.Error,
  ProtocolVersionCannotFollowError: TxSubmission.errors.ProtocolVersionCannotFollow.Error,
  RewardAccountNotEmptyError: TxSubmission.errors.RewardAccountNotEmpty.Error,
  RewardAccountNotExistingError: TxSubmission.errors.RewardAccountNotExisting.Error,
  ScriptWitnessNotValidatingError: TxSubmission.errors.ScriptWitnessNotValidating.Error,
  StakeKeyAlreadyRegisteredError: TxSubmission.errors.StakeKeyAlreadyRegistered.Error,
  StakeKeyNotRegisteredError: TxSubmission.errors.StakeKeyNotRegistered.Error,
  StakePoolNotRegisteredError: TxSubmission.errors.StakePoolNotRegistered.Error,
  TooLateForMirError: TxSubmission.errors.TooLateForMir.Error,
  TooManyAssetsInOutputError: TxSubmission.errors.TooManyAssetsInOutput.Error,
  TooManyCollateralInputsError: TxSubmission.errors.TooManyCollateralInputs.Error,
  TriesToForgeAdaError: TxSubmission.errors.TriesToForgeAda.Error,
  TxMetadataHashMismatchError: TxSubmission.errors.TxMetadataHashMismatch.Error,
  TxTooLargeError: TxSubmission.errors.TxTooLarge.Error,
  UnknownGenesisKeyError: TxSubmission.errors.UnknownGenesisKey.Error,
  UnknownOrIncompleteWithdrawalsError: TxSubmission.errors.UnknownOrIncompleteWithdrawals.Error,
  UnknownTxSubmissionError,
  UnspendableDatumsError: TxSubmission.errors.UnspendableDatums.Error,
  UnspendableScriptInputsError: TxSubmission.errors.UnspendableScriptInputs.Error,
  UpdateWrongEpochError: TxSubmission.errors.UpdateWrongEpoch.Error,
  ValidationTagMismatchError: TxSubmission.errors.ValidationTagMismatch.Error,
  ValueNotConservedError: TxSubmission.errors.ValueNotConserved.Error,
  WrongCertificateTypeError: TxSubmission.errors.WrongCertificateType.Error,
  WrongPoolCertificateError: TxSubmission.errors.WrongPoolCertificate.Error,
  WrongRetirementEpochError: TxSubmission.errors.WrongRetirementEpoch.Error
};

type TxSubmissionErrorName = keyof typeof TxSubmissionErrors;
type TxSubmissionErrorClass = typeof TxSubmissionErrors[TxSubmissionErrorName];
export type TxSubmissionError = InstanceType<TxSubmissionErrorClass>;
