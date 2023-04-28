import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { FinalizeTxProps, InitializeTxProps, InitializeTxResult, ObservableWallet } from '../types';
import {
  IncompatibleWalletError,
  MaybeValidTx,
  OutputBuilder,
  PartialTxOut,
  SignedTx,
  TxAlreadySubmittedError,
  TxBodyValidationError,
  TxBuilder,
  TxOutValidationError,
  ValidTx
} from './types';
import { Logger } from 'ts-log';
import { Observable, firstValueFrom } from 'rxjs';
import { ObservableWalletTxOutputBuilder } from './OutputBuilder';
import { OutputValidator, RewardAccount, StakeKeyStatus, WalletUtilContext, createWalletUtil } from '../services';
import { SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { contextLogger, deepEquals } from '@cardano-sdk/util';

/**
 * Minimal sub-type of ObservableWallet that is used by TxBuilder.
 */
export type ObservableWalletTxBuilderDependencies = Pick<ObservableWallet, 'submitTx'> & {
  delegation: { rewardAccounts$: Observable<Pick<RewardAccount, 'address' | 'keyStatus'>[]> };
} & {
  initializeTx: (
    props: Pick<InitializeTxProps, 'auxiliaryData' | 'outputs' | 'signingOptions' | 'certificates' | 'witness'>
  ) => ReturnType<ObservableWallet['initializeTx']>;
} & {
  finalizeTx: (
    props: Pick<FinalizeTxProps, 'auxiliaryData' | 'tx' | 'signingOptions' | 'witness'>
  ) => ReturnType<ObservableWallet['finalizeTx']>;
} & WalletUtilContext;

/**
 * Properties needed by {@link buildTx} to build a {@link ObservableWalletTxBuilder} TxBuilder
 *
 * - {@link BuildTxProps.observableWallet} minimal ObservableWallet needed to do actions like {@link ObservableWalletTxBuilder.build},
 *   {@link ObservableWalletTxBuilder.delegate} etc.
 * - {@link BuildTxProps.outputValidator} optional custom output validator util.
 *   Uses {@link createWalletUtil} by default.
 */
export interface BuildTxProps {
  observableWallet: ObservableWalletTxBuilderDependencies;
  outputValidator?: OutputValidator;
  logger: Logger;
}

interface Delegate {
  type: 'delegate';
  poolId: Cardano.PoolId;
}

interface KeyDeregistration {
  type: 'deregister';
}
type DelegateConfig = Delegate | KeyDeregistration;

/**
 * Transactions built with {@link ObservableWalletTxBuilder.build} method, use this method to sign the transaction.
 *
 * @returns Promise with `SignedTx` object that has a {@link SignedTx.submit} method that submits the transaction.
 */
const createSignedTx = async ({
  wallet,
  tx,
  witness,
  signingOptions,
  auxiliaryData,
  afterSubmitCb,
  logger
}: FinalizeTxProps & {
  wallet: ObservableWalletTxBuilderDependencies;
  afterSubmitCb: () => void;
  logger: Logger;
}): Promise<SignedTx> => {
  const finalizedTx = await wallet.finalizeTx({
    auxiliaryData,
    signingOptions,
    tx,
    witness
  });
  return {
    submit: async () => {
      logger.debug('submitting', finalizedTx);
      await wallet.submitTx(finalizedTx);
      return afterSubmitCb();
    },
    tx: finalizedTx
  };
};

/**
 * `TxBuilder` concrete implementation, based on `ObservableWalletTxBuilderDependencies`.
 * It relies on `ObservableWalletTxBuilderDependencies` for building, signing, sending, etc.
 * Usage examples are in the unit/integration tests from `builtTx.test.ts`.
 */
export class ObservableWalletTxBuilder implements TxBuilder {
  partialTxBody: Partial<Cardano.TxBody> = {};
  auxiliaryData?: Cardano.AuxiliaryData;
  extraSigners?: TransactionSigner[];
  signingOptions?: SignTransactionOptions;

  #observableWallet: ObservableWalletTxBuilderDependencies;
  #outputValidator: OutputValidator;
  #delegateConfig: DelegateConfig;
  #logger: Logger;
  #isSubmitted = false; // Do not allow building if a transaction built by this builder was already submitted

  constructor({ observableWallet, outputValidator = createWalletUtil(observableWallet), logger }: BuildTxProps) {
    this.#observableWallet = observableWallet;
    this.#outputValidator = outputValidator;
    this.#logger = logger;
  }

  isSubmitted(): boolean {
    return this.#isSubmitted;
  }

  addOutput(txOut: Cardano.TxOut): TxBuilder {
    this.partialTxBody = { ...this.partialTxBody, outputs: [...(this.partialTxBody.outputs || []), txOut] };
    return this;
  }

  removeOutput(txOut: Cardano.TxOut): TxBuilder {
    this.partialTxBody = {
      ...this.partialTxBody,
      outputs: this.partialTxBody.outputs?.filter((output) => !deepEquals(output, txOut))
    };
    return this;
  }

  buildOutput(txOut?: PartialTxOut): OutputBuilder {
    return new ObservableWalletTxOutputBuilder({
      logger: contextLogger(this.#logger, 'outputBuilder'),
      outputValidator: this.#outputValidator,
      txOut
    });
  }

  delegate(poolId?: Cardano.PoolId): TxBuilder {
    this.#delegateConfig = poolId ? { poolId, type: 'delegate' } : { type: 'deregister' };
    return this;
  }

  setMetadata(metadata: Cardano.TxMetadata): TxBuilder {
    this.auxiliaryData = { ...this.auxiliaryData, blob: new Map(metadata) };
    return this;
  }

  setExtraSigners(signers: TransactionSigner[]): TxBuilder {
    this.extraSigners = [...signers];
    return this;
  }

  setSigningOptions(options: SignTransactionOptions): TxBuilder {
    this.signingOptions = { ...options };
    return this;
  }

  async build(): Promise<MaybeValidTx> {
    try {
      if (this.isSubmitted()) throw new TxAlreadySubmittedError();
      this.#logger.debug('Building');
      await this.#addDelegationCertificates();
      await this.#validateOutputs();

      if (this.auxiliaryData)
        this.partialTxBody.auxiliaryDataHash = Cardano.computeAuxiliaryDataHash(this.auxiliaryData);

      const tx = await this.#observableWallet.initializeTx({
        auxiliaryData: this.auxiliaryData,
        certificates: this.partialTxBody.certificates,
        outputs: new Set(this.partialTxBody.outputs || []),
        signingOptions: this.signingOptions,
        witness: { extraSigners: this.extraSigners }
      });
      return this.#createValidTx(tx);
    } catch (error) {
      const errors = Array.isArray(error) ? (error as TxBodyValidationError[]) : [error as TxBodyValidationError];
      this.#logger.debug('Build errors', errors);
      return {
        errors,
        isValid: false
      };
    }
  }

  #createValidTx(tx: InitializeTxResult): ValidTx {
    this.#logger.debug('createValidTx', tx);
    return {
      auxiliaryData: this.auxiliaryData && { ...this.auxiliaryData },
      body: tx.body,
      extraSigners: this.extraSigners && [...this.extraSigners],
      hash: tx.hash,
      inputSelection: tx.inputSelection,
      isValid: true,
      sign: () =>
        createSignedTx({
          afterSubmitCb: () => (this.#isSubmitted = true),
          auxiliaryData: this.auxiliaryData && { ...this.auxiliaryData },
          logger: contextLogger(this.#logger, 'signedTx'),
          signingOptions: this.signingOptions && { ...this.signingOptions },
          tx,
          wallet: this.#observableWallet,
          witness: { extraSigners: this.extraSigners && [...this.extraSigners] }
        }),
      signingOptions: this.signingOptions && { ...this.signingOptions }
    };
  }

  async #validateOutputs(): Promise<TxOutValidationError[]> {
    const errors = (
      await Promise.all(this.partialTxBody.outputs?.map((output) => this.buildOutput(output).build()) || [])
    ).flatMap((output) => (output.isValid ? [] : output.errors));

    if (errors.length > 0) {
      throw errors;
    }
    return [];
  }

  async #addDelegationCertificates(): Promise<void> {
    if (!this.#delegateConfig) {
      // Delegation was not configured by user
      return Promise.resolve();
    }

    const rewardAccounts = await firstValueFrom(this.#observableWallet.delegation.rewardAccounts$);

    if (!rewardAccounts?.length) {
      // This shouldn't happen
      throw new IncompatibleWalletError();
    }

    // Discard previous delegation and prepare for new one
    this.partialTxBody = { ...this.partialTxBody, certificates: [] };

    for (const rewardAccount of rewardAccounts) {
      const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount.address);
      if (this.#delegateConfig.type === 'deregister') {
        // Deregister scenario
        if (rewardAccount.keyStatus === StakeKeyStatus.Unregistered) {
          this.#logger.warn(
            'Skipping stake key deregister. Stake key not registered.',
            rewardAccount.address,
            rewardAccount.keyStatus
          );
        } else {
          this.partialTxBody.certificates!.push({
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash
          });
        }
      } else if (this.#delegateConfig.type === 'delegate') {
        // Register and delegate scenario
        if (rewardAccount.keyStatus !== StakeKeyStatus.Unregistered) {
          this.#logger.debug(
            'Skipping stake key register. Stake key already registered',
            rewardAccount.address,
            rewardAccount.keyStatus
          );
        } else {
          this.partialTxBody.certificates!.push({
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash
          });
        }

        this.partialTxBody.certificates!.push(
          ObservableWalletTxBuilder.#createDelegationCert(this.#delegateConfig.poolId, stakeKeyHash)
        );
      }
    }
  }

  static #createDelegationCert(
    poolId: Cardano.PoolId,
    stakeKeyHash: Crypto.Ed25519KeyHashHex
  ): Cardano.StakeDelegationCertificate {
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId,
      stakeKeyHash
    };
  }
}

/**
 * Factory function to create an {@link ObservableWalletTxBuilder}.
 *
 * `ObservableWallet.buildTx()` would be nice, but it adds quite a lot of complexity
 * to web-extension messaging, so it will be separate util like this one for MVP.
 */
export const buildTx = (props: BuildTxProps): TxBuilder => new ObservableWalletTxBuilder(props);
