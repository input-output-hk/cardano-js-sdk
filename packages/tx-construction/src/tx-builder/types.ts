import { Cardano } from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';

import { InputSelectionError, SelectionSkeleton } from '@cardano-sdk/input-selection';

import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { OutputValidation } from '../output-validation';
import { SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';

export type PartialTxOut = Partial<
  Pick<Cardano.TxOut, 'address' | 'datumHash' | 'datum' | 'scriptReference'> & { value: Partial<Cardano.Value> }
>;

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

export class RewardAccountMissingError extends CustomError {}

export type TxOutValidationError =
  | OutputValidationMissingRequiredError
  | OutputValidationMinimumCoinError
  | OutputValidationTokenBundleSizeError;
export type TxBodyValidationError = TxOutValidationError | InputSelectionError | RewardAccountMissingError;

/**
 * Helps build transaction outputs from its constituent parts.
 * Usage examples are in the unit/integration tests from `TxBuilder.test.ts`.
 */
export interface OutputBuilder {
  /**
   * Create transaction output snapshot, as it was configured until the point of calling this method.
   *
   * @returns {Cardano.TxOut} transaction output snapshot.
   *  - It can be used in {@link TxBuilder.addOutput}.
   *  - It will be validated once {@link TxBuilder.build} method is called.
   * @throws OutputValidationMissingRequiredError {@link OutputValidationMissingRequiredError} if
   * the mandatory fields 'address' or 'coins' are missing
   */
  toTxOut(): Cardano.TxOut;
  /** Sets transaction output `value` field. Preexisting `value` is overwritten. */
  value(value: Cardano.Value): OutputBuilder;
  /** Sets transaction output value `coins` field. */
  coin(coin: Cardano.Lovelace): OutputBuilder;
  /** Sets transaction output value `assets` field. Preexisting assets are overwritten */
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
  /** Sets transaction output `address` field. */
  address(address: Cardano.PaymentAddress): OutputBuilder;
  /** Sets transaction output `datum` field. */
  datum(datum: Hash32ByteBase16): OutputBuilder;
  /**
   * Checks if the transaction output is complete and valid
   *
   * @returns {Promise<Cardano.TxOut>} Promise<Cardano.TxOut> which can be used as input in `TxBuilder.addOutput()`.
   * @throws {TxOutValidationError} TxOutValidationError
   */
  build(): Promise<Cardano.TxOut>;
}

export type SignedTx = Cardano.Tx;

/** Transaction body built with {@link TxBuilder.build}. */
export interface UnsignedTx {
  readonly body: Cardano.TxBody;
  readonly auxiliaryData?: Cardano.AuxiliaryData;
  readonly extraSigners?: TransactionSigner[];
  readonly signingOptions?: SignTransactionOptions;
  readonly inputSelection: SelectionSkeleton;
  readonly hash: Cardano.TransactionId;

  sign(): Promise<SignedTx>;
}

/**
 * Extended promise for unsigned transactions that allows chaining build() with sign(), without
 * awaiting for the build() operation.
 * `const unsignedTx = await txBuilder.build().sign();`
 * At the same time it allows awaiting for build() in case signing is not desired immediately.
 * `const signedTx = await txBuilder.build();`
 * UnsignedTxPromise must also lazy executed, in the sense that the code will be executed only after the Promise is
 * awaited, as opposed to normal Promise behavior where the code is executed when creating the Promise.
 */
export interface UnsignedTxPromise extends Promise<UnsignedTx> {
  sign(): Promise<SignedTx>;
}

export interface TxBuilder {
  /**
   * Transaction body that is updated by `TxBuilder` methods.
   * It should not be updated directly, but this is not restricted to allow experimental HydratedTxBody changes that are not
   * yet available in the TxBuilder interface.
   * Every method call recreates the partialTxBody, thus updating it immutably.
   */
  partialTxBody: Partial<Cardano.TxBody>;
  /**
   * TxMetadata to be added in the transaction auxiliary data body blob, after {@link TxBuilder.build}.
   * Configured using {@link TxBuilder.setMetadata} method.
   * It should not be updated directly, but this is not restricted to allow experimental HydratedTxBody changes that are not.
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
   * Does *not* addOutput.
   *
   * @param txOut optional partial transaction output to use for initialization.
   * @returns {OutputBuilder} {@link OutputBuilder} util for building transaction outputs.
   */
  buildOutput(txOut?: PartialTxOut): OutputBuilder;
  /**
   * Configure transaction to include delegation.
   * - On `build()`, StakeKeyDeregistration or StakeDelegation and (if needed)
   *   StakeKeyRegistration certificates are added in the transaction body.
   * - Stake key deregister is done by not providing the `poolId` parameter: `delegate()`.
   * - If wallet contains multiple reward accounts, it will create certificates for all of them.
   *
   * @param poolId Pool Id to delegate to. If undefined, stake key deregistration will be done.
   */
  delegate(poolId?: Cardano.PoolId): TxBuilder;
  /** Sets TxMetadata in {@link auxiliaryData} */
  setMetadata(metadata: Cardano.TxMetadata): TxBuilder;
  /** Sets extra signers in {@link extraSigners} */
  setExtraSigners(signers: TransactionSigner[]): TxBuilder;
  /** Sets signing options in {@link signingOptions} */
  setSigningOptions(options: SignTransactionOptions): TxBuilder;

  /**
   * Builds an {@link UnsignedTx} based on partialTxBody.
   * All positive balance found in reward accounts is included in the transaction withdrawal.
   * Performs multiple validations to make sure the transaction body is correct.
   *
   * @returns {UnsignedTxPromise}
   * - Can be used to build and sign directly: `const signedTx = await txBuilder.build().sign()`, or do the steps
   *   separately at a later time: `const unsignedTx = await txBuilder.build(); const signedTx = await unsignedTx.sign()`
   * - This is a snapshot of transaction. Further changes done via TxBuilder, will not update this snapshot.
   * @throws {TxBodyValidationError[]} TxBodyValidationError[]
   */
  build(): UnsignedTxPromise;

  // TODO:
  // - setMint
  // - setMetadatum(label: bigint, metadatum: Cardano.Metadatum | null);
  // - burn
  // TODO: maybe this, or maybe datum should be added together with an output?
  //  collaterals should be automatically computed and added to tx when you add scripts
  // - setScripts(scripts: Array<{script, datum, redeemer}>)
  // - setValidityInterval
  // TODO: figure out what script_data_hash is used for
  // - setScriptIntegrityHash(hash: Cardano.util.Hash32ByteBase16 | null);
  // - setRequiredExtraSignatures(keyHashes: Cardano.Ed25519KeyHash[]);
}
