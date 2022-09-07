import { Cardano } from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';

import { InputSelectionError } from '@cardano-sdk/cip2';

import { OutputValidation } from '../types';
import { SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';

export type PartialTxOut = Partial<Pick<Cardano.TxOut, 'address' | 'datum'> & { value: Partial<Cardano.Value> }>;

export enum TxOutputFailure {
  MinimumCoin = 'Minimum coin not met',
  TokenBundleSizeExceedsLimit = 'Token Bundle Exceeds Limit',
  MissingRequiredFields = 'Mandatory fields address or coin are missing'
}

export class OutputValidationMissingRequiredError extends CustomError {
  public constructor(public txOut: PartialTxOut) {
    super(TxOutputFailure.MissingRequiredFields);
  }
}

export class OutputValidationMinimumCoinError extends CustomError {
  public constructor(public txOut: PartialTxOut, public outputValidation: OutputValidation) {
    super(TxOutputFailure.MinimumCoin);
  }
}

export class OutputValidationTokenBundleSizeError extends CustomError {
  public constructor(public txOut: PartialTxOut, public outputValidation: OutputValidation) {
    super(TxOutputFailure.TokenBundleSizeExceedsLimit);
  }
}

export class IncompatibleWalletError extends CustomError {}

export type TxOutValidationError =
  | OutputValidationMissingRequiredError
  | OutputValidationMinimumCoinError
  | OutputValidationTokenBundleSizeError;
export type TxBodyValidationError = TxOutValidationError | InputSelectionError | IncompatibleWalletError;

export type Valid<TValid> = TValid & {
  isValid: true;
};

export interface Invalid<TError> {
  isValid: false;
  errors: TError[];
}

export interface ValidTxOutData {
  readonly txOut: Cardano.TxOut;
}

export type ValidTxOut = Valid<ValidTxOutData>;
export type InvalidTxOut = Invalid<TxOutValidationError>;
export type MaybeValidTxOut = ValidTxOut | InvalidTxOut;

/**
 * Helps build transaction outputs from it's constituent parts.
 * Usage examples are in the unit/integration tests from `builtTx.test.ts`.
 */
export interface OutputBuilder {
  /**
   * Transaction output that is updated by `OutputBuilder` methods.
   * It should not be updated directly, but this is not restricted to allow experimental TxOutput changes that are not
   * yet available in the OutputBuilder interface.
   * Every method call recreates the `partialOutput`, thus updating it immutably.
   */
  partialOutput: PartialTxOut;
  /** Sets {@link partialOutput} `value` field. Preexisting `value` is overwritten. */
  value(value: Cardano.Value): OutputBuilder;
  /** Sets {@link partialOutput}.value `coins` field. */
  coin(coin: Cardano.Lovelace): OutputBuilder;
  /** Sets {@link partialOutput}.value `assets` field. Preexisting assets are overwritten */
  assets(assets: Cardano.TokenMap): OutputBuilder;
  /**
   * Add/Remove/Update asset.
   * - If `assetId` is new, the asset is created and added to assets.
   * - If `assetId` is already added, the asset quantity is updated.
   * - If `quantity` is 0, the the asset is removed.
   *
   * @param assetId id
   * @param quantity To remove an asset, set quantity to 0
   */
  asset(assetId: Cardano.AssetId, quantity: bigint): OutputBuilder;
  /** Sets {@link partialOutput} `address` field. */
  address(address: Cardano.Address): OutputBuilder;
  /** Sets {@link partialOutput} `datum` field. */
  datum(datum: Cardano.util.Hash32ByteBase16): OutputBuilder;
  /**
   * Checks if the constructed `partialOutput` is complete and valid
   *
   * @returns {Promise<MaybeValidTxOut>} When it is a `ValidTxOut` it can be used as input in `TxBuilder.addOutput()`.
   * In case of it is an `InvalidTxOut`, it embeds a TxOutValidationError with more details
   */
  build(): Promise<MaybeValidTxOut>;
}

export interface SignedTx {
  readonly tx: Cardano.NewTxAlonzo;
  submit(): Promise<void>;
}

export interface ValidTxBody {
  readonly body: Cardano.NewTxBodyAlonzo;
  readonly auxiliaryData?: Cardano.AuxiliaryData;
  readonly extraSigners?: TransactionSigner[];
  readonly signingOptions?: SignTransactionOptions;

  sign(): Promise<SignedTx>;
}

export type ValidTx = Valid<ValidTxBody>;
export type InvalidTx = Invalid<TxBodyValidationError>;
export type MaybeValidTx = ValidTx | InvalidTx;

export interface TxBuilder {
  /**
   * Transaction body that is updated by `TxBuilder` methods.
   * It should not be updated directly, but this is not restricted to allow experimental TxBody changes that are not
   * yet available in the TxBuilder interface.
   * Every method call recreates the partialTxBody, thus updating it immutably.
   */
  partialTxBody: Partial<Cardano.NewTxBodyAlonzo>;
  /**
   * TxMetadata to be added in the transaction auxiliary data body blob, after {@link TxBuilder.build}.
   * Configured using {@link TxBuilder.setMetadata} method.
   * It should not be updated directly, but this is not restricted to allow experimental TxBody changes that are not.
   */
  auxiliaryData?: Cardano.AuxiliaryData;
  extraSigners?: TransactionSigner[];
  signingOptions?: SignTransactionOptions;

  /** @param txOut transaction output to add to {@link partialTxBody} outputs. */
  addOutput(txOut: Cardano.TxOut): TxBuilder;
  /**
   * @param txOut transaction output to be removed from {@link partialTxBody} outputs.
   * It must be in partialTxBody.outputs (===)
   */
  removeOutput(txOut: Cardano.TxOut): TxBuilder;
  /**
   * Does *not* addOutput
   *
   * @param txOut optional partial transaction output to use for initialization.
   * @returns {OutputBuilder} {@link OutputBuilder} util for building transaction outputs.
   */
  buildOutput(txOut?: PartialTxOut): OutputBuilder;
  /**
   * Configure transaction to include delegation.
   * - On `build()`, StakeDelegation and (if needed) StakeKeyRegistration certificates are added in
   *   the transaction body.
   * - If wallet contains multiple reward accounts, it will create certificates for all of them.
   *
   * @param poolId Pool Id to delegate to.
   */
  delegate(poolId: Cardano.PoolId): TxBuilder;
  /** Sets TxMetadata in {@link auxiliaryData} */
  setMetadata(metadata: Cardano.TxMetadata): TxBuilder;
  /** Sets extra signers in {@link extraSigners} */
  setExtraSigners(signers: TransactionSigner[]): TxBuilder;
  /** Sets signing options in {@link signingOptions} */
  setSigningOptions(options: SignTransactionOptions): TxBuilder;

  /**
   * Builds a `ValidTxBody` based on partialTxBody.
   * Performs multiple validations to make sure the transaction body is correct.
   * In case validations fail, it creates a `TxBodyValidationError` instead of `ValidTxBody`.
   *
   * @returns {Promise<MaybeValidTx>}
   * - In case it is a `ValidTx`, it can be used to sign and submit the transaction. This is a snapshot of transaction.
   *   Further changes done via TxBuilder, will not update this snapshot.
   * - In case of it is an `InvalidTx`, it embeds a TxBodyValidationError with more details
   */
  build(): Promise<MaybeValidTx>;

  // TODO:
  // - setMint
  // - setMetadatum(label: bigint, metadatum: Cardano.Metadatum | null);
  // - burn
  // TODO: maybe this, or maybe datum should be added together with an output?
  //  collaterals should be automatically computed and added to tx when you add scripts
  // - setScripts(scripts: Array<{script, datum, redeemer}>)
  // - setValidityInterval
  // TODO: figure out what script_data_hash is used for
  // - setScriptIntegrityHash(hash: Cardano.Hash32ByteBase16 | null);
  // - setRequiredExtraSignatures(keyHashes: Cardano.Ed25519KeyHash[]);
}
