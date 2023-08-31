import { Cardano, Handle, HandleProvider, HandleResolution, TxCBOR } from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';

import { InputSelectionError, InputSelector, SelectionSkeleton } from '@cardano-sdk/input-selection';

import { AsyncKeyAgent, GroupedAddress, SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { InitializeTxWitness, TxBuilderProviders } from '../types';
import { Logger } from 'ts-log';
import { OutputBuilderValidator } from './OutputBuilder';
import { OutputValidation } from '../output-validation';

export type PartialTxOut = Partial<
  Pick<Cardano.TxOut, 'address' | 'datumHash' | 'datum' | 'scriptReference'> & {
    value: Partial<Cardano.Value>;
    handle?: Handle;
  }
>;

export enum TxOutputFailure {
  MinimumCoin = 'Minimum coin not met',
  TokenBundleSizeExceedsLimit = 'Token Bundle Exceeds Limit',
  MissingRequiredFields = 'Mandatory fields address or coin are missing',
  MissingHandleProviderError = "Missing 'HandleProvider'",
  HandleNotFound = 'Handle not found',
  NegativeAssetQty = 'Negative or zero asset quantity'
}

export class InvalidConfigurationError extends CustomError {
  public constructor(public message: string) {
    super(message);
  }
}

export class HandleNotFoundError extends CustomError {
  public constructor(public txOut: PartialTxOut) {
    super(TxOutputFailure.HandleNotFound);
  }
}

export class InsufficientRewardAccounts extends CustomError {
  public constructor(poolIds: Cardano.PoolId[], rewardAccounts: Cardano.RewardAccount[]) {
    const msg = `Internal error: insufficient stake keys: ${rewardAccounts.length}. Required: ${poolIds.length}.
    Pool ids: ${poolIds.join(',')}; Reward accounts: ${rewardAccounts.length}`;
    super(msg);
  }
}

/** New stake keys derived for multi-delegation were not found in the rewardAccounts provider */
export class OutOfSyncRewardAccounts extends CustomError {
  public constructor(rewardAccounts: Cardano.RewardAccount[]) {
    const msg = `Timeout while waiting for reward accounts provider to contain new reward accounts: ${rewardAccounts}`;
    super(msg);
  }
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

export class OutputValidationNegativeAssetQtyError extends CustomError {
  public constructor(public txOut: PartialTxOut, public outputValidation: OutputValidation) {
    super(TxOutputFailure.NegativeAssetQty);
  }
}

export type TxOutValidationError =
  | OutputValidationMissingRequiredError
  | OutputValidationMinimumCoinError
  | OutputValidationTokenBundleSizeError;
export type TxBodyValidationError = TxOutValidationError | InputSelectionError;

/**
 * Add handle data which is only used when building the output but doesn't
 * appear in the final TxOut type since it's extracted before then and passed
 * as `ctx`.
 */
export type OutputBuilderTxOut = Cardano.TxOut & { handle?: HandleResolution };

/**
 * Helps build transaction outputs from its constituent parts.
 * Usage examples are in the unit/integration tests from `TxBuilder.test.ts`.
 */
export interface OutputBuilder {
  /**
   * @returns a partial output that has properties set by calling other TxBuilder methods. Does not validate the output.
   */
  inspect(): Promise<PartialTxOut>;
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
  build(): Promise<OutputBuilderTxOut>;
  handle(handle: Handle): OutputBuilder;
}

export interface TxContext {
  ownAddresses: GroupedAddress[];
  signingOptions?: SignTransactionOptions;
  auxiliaryData?: Cardano.AuxiliaryData;
  witness?: InitializeTxWitness;
  isValid?: boolean;
  handles?: HandleResolution[];
}

export type TxInspection = Cardano.TxBodyWithHash &
  Pick<TxContext, 'ownAddresses' | 'auxiliaryData' | 'handles'> & {
    inputSelection: SelectionSkeleton;
  };

export interface SignedTx {
  cbor: TxCBOR;
  tx: Cardano.Tx;
  context: {
    handles: HandleResolution[];
  };
}

/**
 * Transaction body built with {@link TxBuilder.build}
 * `const unsignedTx = await txBuilder.build().sign();`
 * At the same time it allows inspecting the built transaction before signing it:
 * `const signedTx = await txBuilder.build().inspect();`
 * Transaction is built lazily: only when inspect() or sign() is called.
 */
export interface UnsignedTx {
  inspect(): Promise<TxInspection>;
  sign(): Promise<SignedTx>;
}

export interface PartialTx {
  /**
   * Transaction body that is updated by {@link TxBuilder} methods.
   */
  body: Partial<Cardano.TxBody>;
  /**
   * TxMetadata to be added in the transaction auxiliary data body blob, after {@link TxBuilder.build}.
   * Configured using {@link TxBuilder.metadata} method.
   */
  auxiliaryData?: Cardano.AuxiliaryData;
  extraSigners?: TransactionSigner[];
  signingOptions?: SignTransactionOptions;
}
export interface TxBuilder {
  /**
   * @returns a partial transaction that has properties set by calling other TxBuilder methods. Does not validate the transaction.
   */
  inspect(): Promise<PartialTx>;

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
   * Configures the transaction to include all the certificates needed to delegate to the pools from the portfolio.
   *
   * IMPORTANT:
   *  - When there are multiple reward accounts or a portfolio with multiple pools is requested, {@link GreedyInputSelector}
   * will be used to distribute the funds according to the weights.
   *  - Even when delegating to a single pool, the presence of
   * multiple reward accounts implies the use of {@link GreedyInputSelector} to make sure that all funds are sent to the
   * stake key being delegated.
   *  - To avoid this behavior, please make sure that your wallet has a single reward account, AND you are delegating to a single pool.
   *  - Please see documentation for {@link GreedyInputSelector} to understand the side effects.
   *
   * - Portfolio delegations that already exist will be preserved.
   * - Delegation certificates will be sent for portfolio pools that are not already delegated.
   *   The order in which stake keys are used is:
   *     1. Stake keys that are delegated but shouldn't be anymore
   *     2. Registered but not delegated stake keys.
   *     3. Unregistered stake keys.
   *     4. New stake keys are derived if number of pools exceeds the number of available stake keys.
   * - Deregister stake key certificates are sent for stake keys delegated to pools that are no longer
   *   part of the portfolio, and are not needed for re-delegation.
   * All certificates are created on build().
   *
   * @param portfolio the CIP17 delegation portfolio to apply. Using `null` will deregister all stake keys,
   *  reclaiming the deposits.
   */
  delegatePortfolio(portfolio: Pick<Cardano.Cip17DelegationPortfolio, 'pools'> | null): TxBuilder;
  /** Sets TxMetadata in {@link auxiliaryData} */
  metadata(metadata: Cardano.TxMetadata): TxBuilder;
  /** Sets extra signers in {@link extraSigners} */
  extraSigners(signers: TransactionSigner[]): TxBuilder;
  /** Sets signing options in {@link signingOptions} */
  signingOptions(options: SignTransactionOptions): TxBuilder;

  /**
   * Create a snapshot of current transaction properties.
   * All positive balance found in reward accounts is included in the transaction withdrawal.
   * Performs multiple validations to make sure the transaction body is correct.
   *
   * @returns {UnsignedTx}
   * Can be used to build and sign directly: `const signedTx = await txBuilder.build().sign()`,
   * or inspect the transaction before signing:
   * ```
   * const tx = await txBuilder.build();
   * const unsignedTx = await tx.inspect();
   * const signedTx = await tx.sign()
   * ```
   *
   * This is a snapshot of transaction. Further changes done via TxBuilder, will not update this snapshot.
   * @throws {TxBodyValidationError[]} TxBodyValidationError[]
   */
  build(): UnsignedTx;

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

export interface TxBuilderDependencies {
  inputSelector?: InputSelector;
  inputResolver: Cardano.InputResolver;
  keyAgent: AsyncKeyAgent;
  txBuilderProviders: TxBuilderProviders;
  logger: Logger;
  outputValidator?: OutputBuilderValidator;
  handleProvider?: HandleProvider;
}

export type FinalizeTxDependencies = Pick<TxBuilderDependencies, 'inputResolver' | 'keyAgent'>;
