import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent, GroupedAddress, SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { contextLogger, deepEquals } from '@cardano-sdk/util';

import { FinalizeTxProps, InitializeTxResult, TxBuilderDependencies } from '../types';
import {
  OutputBuilder,
  PartialTxOut,
  RewardAccountMissingError,
  SignedTx,
  TxBodyValidationError,
  TxBuilder,
  TxOutValidationError,
  UnsignedTx,
  UnsignedTxPromise
} from './types';
import { OutputValidator, createOutputValidator } from '../output-validation';
import { TxOutputBuilder } from './OutputBuilder';
import { finalizeTx } from './finalizeTx';
import { initializeTx } from './initializeTx';

interface Delegate {
  type: 'delegate';
  poolId: Cardano.PoolId;
}

interface KeyDeregistration {
  type: 'deregister';
}
type DelegateConfig = Delegate | KeyDeregistration;

class GenericUnsignedTxPromise implements UnsignedTxPromise {
  constructor(private callback: () => Promise<UnsignedTx>) {}

  then<TResult1 = UnsignedTx, TResult2 = never>(
    onfulfilled?: ((value: UnsignedTx) => TResult1 | PromiseLike<TResult1>) | null | undefined,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    onrejected?: ((reason: any) => TResult2 | PromiseLike<TResult2>) | null | undefined
  ): Promise<TResult1 | TResult2> {
    return this.callback().then(onfulfilled, onrejected);
  }

  catch<TResult = never>(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    onrejected?: ((reason: any) => TResult | PromiseLike<TResult>) | null | undefined
  ): Promise<UnsignedTx | TResult> {
    return this.callback().catch(onrejected);
  }
  finally(onfinally?: (() => void) | null | undefined): Promise<UnsignedTx> {
    return this.finally(onfinally);
  }
  [Symbol.toStringTag]: string;

  async sign(): Promise<SignedTx> {
    const tx = await this.callback();
    return tx.sign();
  }
}

/**
 * Transactions built with {@link GenericTxBuilder.build} method, use this method to sign the transaction.
 *
 * @returns Promise with `SignedTx`.
 */
const createSignedTx = async ({
  tx,
  witness,
  signingOptions,
  auxiliaryData,
  inputResolver,
  keyAgent,
  addresses
}: FinalizeTxProps & {
  inputResolver: Cardano.InputResolver;
  keyAgent: AsyncKeyAgent;
  addresses: GroupedAddress[];
}): Promise<SignedTx> =>
  await finalizeTx(
    {
      addresses,
      auxiliaryData,
      signingOptions,
      tx,
      witness
    },
    { inputResolver, keyAgent }
  );

export class GenericTxBuilder implements TxBuilder {
  partialTxBody: Partial<Cardano.TxBody> = {};
  auxiliaryData?: Cardano.AuxiliaryData;
  extraSigners?: TransactionSigner[];
  signingOptions?: SignTransactionOptions;

  #dependencies: TxBuilderDependencies;
  #outputValidator: OutputValidator;
  #delegateConfig: DelegateConfig;
  #logger: Logger;

  constructor(
    dependencies: TxBuilderDependencies,
    outputValidator = createOutputValidator({ protocolParameters: dependencies.txBuilderProviders.protocolParameters })
  ) {
    this.#outputValidator = outputValidator;
    this.#dependencies = dependencies;
    this.#logger = dependencies.logger;
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
    return new TxOutputBuilder({
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

  build(): UnsignedTxPromise {
    return new GenericUnsignedTxPromise(() => {
      this.#logger.debug('Building');
      return this.#addDelegationCertificates()
        .then(() => this.#validateOutputs())
        .then(() => {
          if (this.auxiliaryData) {
            this.partialTxBody.auxiliaryDataHash = Cardano.computeAuxiliaryDataHash(this.auxiliaryData);
          }

          return initializeTx(
            {
              auxiliaryData: this.auxiliaryData,
              certificates: this.partialTxBody.certificates,
              outputs: new Set(this.partialTxBody.outputs || []),
              signingOptions: this.signingOptions,
              witness: { extraSigners: this.extraSigners }
            },
            this.#dependencies
          );
        })
        .then((tx) => this.#createValidTx(tx))
        .catch((error) => {
          const errors = Array.isArray(error) ? (error as TxBodyValidationError[]) : [error as TxBodyValidationError];
          this.#logger.debug('Build errors', errors);
          throw errors;
        });
    });
  }

  #createValidTx(tx: InitializeTxResult): UnsignedTx {
    this.#logger.debug('createValidTx', tx);
    return {
      auxiliaryData: this.auxiliaryData && { ...this.auxiliaryData },
      body: tx.body,
      extraSigners: this.extraSigners && [...this.extraSigners],
      hash: tx.hash,
      inputSelection: tx.inputSelection,
      sign: async () =>
        createSignedTx({
          addresses: await this.#dependencies.txBuilderProviders.addresses(),
          auxiliaryData: this.auxiliaryData && { ...this.auxiliaryData },
          inputResolver: this.#dependencies.inputResolver,
          keyAgent: this.#dependencies.keyAgent,
          signingOptions: this.signingOptions && { ...this.signingOptions },
          tx,
          witness: { extraSigners: this.extraSigners && [...this.extraSigners] }
        }),
      signingOptions: this.signingOptions && { ...this.signingOptions }
    };
  }

  /** @throws {TxOutValidationError[]} TxOutValidationError[] in case of validation errors */
  async #validateOutputs(): Promise<void> {
    if (this.partialTxBody.outputs) {
      const errors: TxOutValidationError[] = [];
      await Promise.all(
        this.partialTxBody.outputs?.map((output) =>
          this.buildOutput(output)
            .build()
            .catch((error) => errors.push(error))
        )
      );
      if (errors.length > 0) {
        throw errors;
      }
    }
  }

  async #addDelegationCertificates(): Promise<void> {
    if (!this.#delegateConfig) {
      // Delegation was not configured by user
      return Promise.resolve();
    }

    const rewardAccounts = await this.#dependencies.txBuilderProviders.rewardAccounts();

    if (!rewardAccounts?.length) {
      // This shouldn't happen
      throw new RewardAccountMissingError();
    }

    // Discard previous delegation and prepare for new one
    this.partialTxBody = { ...this.partialTxBody, certificates: [] };

    for (const rewardAccount of rewardAccounts) {
      const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount.address);
      if (this.#delegateConfig.type === 'deregister') {
        // Deregister scenario
        if (rewardAccount.keyStatus === Cardano.StakeKeyStatus.Unregistered) {
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
        if (rewardAccount.keyStatus !== Cardano.StakeKeyStatus.Unregistered) {
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
          GenericTxBuilder.#createDelegationCert(this.#delegateConfig.poolId, stakeKeyHash)
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
