import { CustomError } from 'ts-custom-error';
import type * as Cardano from '../../Cardano/index.js';

export enum GeneralCardanoNodeErrorCode {
  ServerNotReady = 503,
  Unknown = 500,
  ConnectionFailure = -1
}

export enum ChainSyncErrorCode {
  IntersectionNotFound = 1000,
  IntersectionInterleaved = 1001
}

export enum StateQueryErrorCode {
  AcquireLedgerStateFailure = 2000,
  EraMismatch = 2001,
  UnavailableInCurrentEra = 2002,
  AcquiredExpired = 2003
}

export enum TxSubmissionErrorCode {
  EraMismatch = 3005,
  InvalidSignatories = 3100,
  MissingSignatories = 3101,
  MissingScripts = 3102,
  FailingNativeScript = 3103,
  ExtraneousScripts = 3104,
  MissingMetadataHash = 3105,
  MissingMetadata = 3106,
  MetadataHashMismatch = 3107,
  InvalidMetadata = 3108,
  MissingRedeemers = 3109,
  ExtraneousRedeemers = 3110,
  MissingDatums = 3111,
  ExtraneousDatums = 3112,
  ScriptIntegrityHashMismatch = 3113,
  OrphanScriptInputs = 3114,
  MissingCostModels = 3115,
  MalformedScripts = 3116,
  UnknownOutputReferences = 3117,
  OutsideOfValidityInterval = 3118,
  TransactionTooLarge = 3119,
  ValueTooLarge = 3120,
  EmptyInputSet = 3121,
  TransactionFeeTooSmall = 3122,
  ValueNotConserved = 3123,
  NetworkMismatch = 3124,
  InsufficientlyFundedOutputs = 3125,
  BootstrapAttributesTooLarge = 3126,
  MintingOrBurningAda = 3127,
  InsufficientCollateral = 3128,
  CollateralLockedByScript = 3129,
  UnforeseeableSlot = 3130,
  TooManyCollateralInputs = 3131,
  MissingCollateralInputs = 3132,
  NonAdaCollateral = 3133,
  ExecutionUnitsTooLarge = 3134,
  TotalCollateralMismatch = 3135,
  SpendsMismatch = 3136,
  UnauthorizedVote = 3137,
  UnknownGovernanceProposal = 3138,
  InvalidProtocolParametersUpdate = 3139,
  UnknownStakePool = 3140,
  IncompleteWithdrawals = 3141,
  RetirementTooLate = 3142,
  StakePoolCostTooLow = 3143,
  MetadataHashTooLarge = 3144,
  CredentialAlreadyRegistered = 3145,
  UnknownCredential = 3146,
  NonEmptyRewardAccount = 3147,
  InvalidGenesisDelegation = 3148,
  InvalidMIRTransfer = 3149,
  ForbiddenWithdrawal = 3150,
  CredentialDepositMismatch = 3151,
  DRepAlreadyRegistered = 3152,
  DRepNotRegistered = 3153,
  UnknownConstitutionalCommitteeMember = 3154,
  GovernanceProposalDepositMismatch = 3155,
  ConflictingCommitteeUpdate = 3156,
  InvalidCommitteeUpdate = 3157,
  TreasuryWithdrawalMismatch = 3158,
  InvalidOrMissingPreviousProposal = 3159,
  FailureUnrecognizedCertificateType = 3998,
  InternalLedgerTypeConversionError = 3999,
  DeserialisationFailure = -32_602
}

export abstract class CardanoNodeError<Code extends number, Data = unknown> extends CustomError {
  code: Code;
  data: Data;

  constructor(code: Code, data: Data, message: string) {
    super(message);
    this.code = code;
    this.data = data;
  }
}

export class GeneralCardanoNodeError<Data = unknown> extends CardanoNodeError<GeneralCardanoNodeErrorCode, Data> {}
export class ChainSyncError<Data = unknown> extends CardanoNodeError<ChainSyncErrorCode, Data> {}
export class TxSubmissionError<Data = unknown> extends CardanoNodeError<TxSubmissionErrorCode, Data> {}
export class StateQueryError<Data = unknown> extends CardanoNodeError<StateQueryErrorCode, Data> {}

export type OutsideOfValidityIntervalData = {
  validityInterval: Cardano.ValidityInterval;
  currentSlot: Cardano.Slot;
};
export type ValueNotConservedData = {
  consumed: Cardano.Value;
  produced: Cardano.Value;
};
export type IncompleteWithdrawalsData = {
  withdrawals: Cardano.Withdrawal[];
};
