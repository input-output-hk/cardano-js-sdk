import { CustomError } from 'ts-custom-error';
import { TxSubmission } from '@cardano-ogmios/client';

export const EraMismatchError = TxSubmission.EraMismatchError;
export const UnkownResultError = TxSubmission.UnknownResultError;

export const AddressAttributesTooLargeError = TxSubmission.errors.AddressAttributesTooLarge.Error;
export const AlreadyDelegatingError = TxSubmission.errors.AlreadyDelegating.Error;
export const BadInputsError = TxSubmission.errors.BadInputs.Error;
export const CollateralHasNonAdaAssetsError = TxSubmission.errors.CollateralHasNonAdaAssets.Error;
export const CollateralIsScriptError = TxSubmission.errors.CollateralIsScript.Error;
export const CollateralTooSmallError = TxSubmission.errors.CollateralTooSmall.Error;
export const CollectErrorsError = TxSubmission.errors.CollectErrors.Error;
export const DelegateNotRegisteredError = TxSubmission.errors.DelegateNotRegistered.Error;
export const DuplicateGenesisVrfError = TxSubmission.errors.DuplicateGenesisVrf.Error;
export const ExecutionUnitsTooLargeError = TxSubmission.errors.ExecutionUnitsTooLarge.Error;
export const ExpiredUtxoError = TxSubmission.errors.ExpiredUtxo.Error;
export const ExtraDataMismatchError = TxSubmission.errors.ExtraDataMismatch.Error;
export const ExtraRedeemersError = TxSubmission.errors.ExtraRedeemers.Error;
export const FeeTooSmallError = TxSubmission.errors.FeeTooSmall.Error;
export const InsufficientFundsForMirError = TxSubmission.errors.InsufficientFundsForMir.Error;
export const InsufficientGenesisSignaturesError = TxSubmission.errors.InsufficientGenesisSignatures.Error;
export const InvalidMetadataError = TxSubmission.errors.InvalidMetadata.Error;
export const InvalidWitnessesError = TxSubmission.errors.InvalidWitnesses.Error;
export const MirNegativeTransferNotCurrentlyAllowedError =
  TxSubmission.errors.MirNegativeTransferNotCurrentlyAllowed.Error;
export const MirProducesNegativeUpdateError = TxSubmission.errors.MirProducesNegativeUpdate.Error;
export const MirTransferNotCurrentlyAllowedError = TxSubmission.errors.MirTransferNotCurrentlyAllowed.Error;
export const MissingAtLeastOneInputUtxoError = TxSubmission.errors.MissingAtLeastOneInputUtxo.Error;
export const MissingCollateralInputsError = TxSubmission.errors.MissingCollateralInputs.Error;
export const MissingDatumHashesForInputsError = TxSubmission.errors.MissingDatumHashesForInputs.Error;
export const MissingRequiredDatumsError = TxSubmission.errors.MissingRequiredDatums.Error;
export const MissingRequiredRedeemersError = TxSubmission.errors.MissingRequiredRedeemers.Error;
export const MissingRequiredSignaturesError = TxSubmission.errors.MissingRequiredSignatures.Error;
export const MissingScriptWitnessesError = TxSubmission.errors.MissingScriptWitnesses.Error;
export const MissingTxMetadataError = TxSubmission.errors.MissingTxMetadata.Error;
export const MissingTxMetadataHashError = TxSubmission.errors.MissingTxMetadataHash.Error;
export const MissingVkWitnessesError = TxSubmission.errors.MissingVkWitnesses.Error;
export const NetworkMismatchError = TxSubmission.errors.NetworkMismatch.Error;
export const NonGenesisVotersError = TxSubmission.errors.NonGenesisVoters.Error;
export const OutputTooSmallError = TxSubmission.errors.OutputTooSmall.Error;
export const OutsideForecastError = TxSubmission.errors.OutsideForecast.Error;
export const OutsideOfValidityIntervalError = TxSubmission.errors.OutsideOfValidityInterval.Error;
export const PoolCostTooSmallError = TxSubmission.errors.PoolCostTooSmall.Error;
export const PoolMetadataHashTooBigError = TxSubmission.errors.PoolMetadataHashTooBig.Error;
export const ProtocolVersionCannotFollowError = TxSubmission.errors.ProtocolVersionCannotFollow.Error;
export const RewardAccountNotEmptyError = TxSubmission.errors.RewardAccountNotEmpty.Error;
export const RewardAccountNotExistingError = TxSubmission.errors.RewardAccountNotExisting.Error;
export const ScriptWitnessNotValidatingError = TxSubmission.errors.ScriptWitnessNotValidating.Error;
export const StakeKeyAlreadyRegisteredError = TxSubmission.errors.StakeKeyAlreadyRegistered.Error;
export const StakeKeyNotRegisteredError = TxSubmission.errors.StakeKeyNotRegistered.Error;
export const StakePoolNotRegisteredError = TxSubmission.errors.StakePoolNotRegistered.Error;
export const TooLateForMirError = TxSubmission.errors.TooLateForMir.Error;
export const TooManyAssetsInOutputError = TxSubmission.errors.TooManyAssetsInOutput.Error;
export const TooManyCollateralInputsError = TxSubmission.errors.TooManyCollateralInputs.Error;
export const TriesToForgeAdaError = TxSubmission.errors.TriesToForgeAda.Error;
export const TxMetadataHashMismatchError = TxSubmission.errors.TxMetadataHashMismatch.Error;
export const TxTooLargeError = TxSubmission.errors.TxTooLarge.Error;
export const UnknownGenesisKeyError = TxSubmission.errors.UnknownGenesisKey.Error;
export const UnknownOrIncompleteWithdrawalsError = TxSubmission.errors.UnknownOrIncompleteWithdrawals.Error;
export const UnspendableDatumsError = TxSubmission.errors.UnspendableDatums.Error;
export const UnspendableScriptInputsError = TxSubmission.errors.UnspendableScriptInputs.Error;
export const UpdateWrongEpochError = TxSubmission.errors.UpdateWrongEpoch.Error;
export const ValidationTagMismatchError = TxSubmission.errors.ValidationTagMismatch.Error;
export const ValueNotConservedError = TxSubmission.errors.ValueNotConserved.Error;
export const WrongCertificateTypeError = TxSubmission.errors.WrongCertificateType.Error;
export const WrongPoolCertificateError = TxSubmission.errors.WrongPoolCertificate.Error;
export const WrongRetirementEpochError = TxSubmission.errors.WrongRetirementEpoch.Error;
export class UnknownTxSubmissionError extends CustomError {
  constructor(public innerError: unknown) {
    super('Unknown submission error. See "innerError".');
  }
}
