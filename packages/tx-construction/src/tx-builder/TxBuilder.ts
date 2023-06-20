import { Cardano, HandleProvider, HandleResolution } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import {
  OutputBuilderTxOut,
  PartialTx,
  PartialTxOut,
  RewardAccountMissingError,
  SignedTx,
  TxBuilder,
  TxBuilderDependencies,
  TxContext,
  TxInspection,
  TxOutValidationError,
  UnsignedTx
} from './types';
import { OutputBuilderValidator, TxOutputBuilder } from './OutputBuilder';
import { SelectionSkeleton } from '@cardano-sdk/input-selection';
import { SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { contextLogger, deepEquals } from '@cardano-sdk/util';
import { createOutputValidator } from '../output-validation';
import { finalizeTx } from './finalizeTx';
import { firstValueFrom } from 'rxjs';
import { initializeTx } from './initializeTx';

interface Delegate {
  type: 'delegate';
  poolId: Cardano.PoolId;
}

interface KeyDeregistration {
  type: 'deregister';
}
type DelegateConfig = Delegate | KeyDeregistration;

type BuiltTx = {
  tx: Cardano.TxBodyWithHash;
  ctx: TxContext;
  inputSelection: SelectionSkeleton;
};

interface Signer {
  sign(builtTx: BuiltTx): Promise<SignedTx>;
}

interface Builder {
  build(): Promise<BuiltTx>;
}

interface LazySignerProps {
  builder: Builder;
  signer: Signer;
}

class LazyTxSigner implements UnsignedTx {
  #built?: BuiltTx;
  #signer: Signer;
  #builder: Builder;

  constructor({ builder, signer }: LazySignerProps) {
    this.#builder = builder;
    this.#signer = signer;
  }

  async #build() {
    return (this.#built ||= await this.#builder.build());
  }

  async inspect(): Promise<TxInspection> {
    const {
      tx,
      ctx: { ownAddresses, auxiliaryData, handles },
      inputSelection
    } = await this.#build();
    return { ...tx, auxiliaryData, handles, inputSelection, ownAddresses };
  }

  async sign(): Promise<SignedTx> {
    return this.#signer.sign(await this.#build());
  }
}

export class GenericTxBuilder implements TxBuilder {
  partialTxBody: Partial<Cardano.TxBody> = {};
  partialAuxiliaryData?: Cardano.AuxiliaryData;
  partialExtraSigners?: TransactionSigner[];
  partialSigningOptions?: SignTransactionOptions;

  #dependencies: TxBuilderDependencies;
  #outputValidator: OutputBuilderValidator;
  #delegateConfig: DelegateConfig;
  #logger: Logger;
  #handleProvider?: HandleProvider;
  #handles: HandleResolution[];

  constructor(dependencies: TxBuilderDependencies) {
    this.#outputValidator =
      dependencies.outputValidator ||
      createOutputValidator({
        protocolParameters: dependencies.txBuilderProviders.protocolParameters
      });
    this.#dependencies = dependencies;
    this.#logger = dependencies.logger;
    this.#handleProvider = dependencies.handleProvider;
    this.#handles = [];
  }

  async inspect(): Promise<PartialTx> {
    return {
      auxiliaryData: this.partialAuxiliaryData,
      body: this.partialTxBody,
      extraSigners: this.partialExtraSigners,
      signingOptions: this.partialSigningOptions
    };
  }

  addOutput(txOut: OutputBuilderTxOut): TxBuilder {
    this.partialTxBody = { ...this.partialTxBody, outputs: [...(this.partialTxBody.outputs || []), txOut] };

    if (txOut.handle) {
      this.#handles = [...this.#handles, txOut.handle];
    }

    return this;
  }

  removeOutput(txOut: OutputBuilderTxOut): TxBuilder {
    this.#handles = this.#handles.filter((handle) => handle !== txOut.handle);
    this.partialTxBody = {
      ...this.partialTxBody,
      outputs: this.partialTxBody.outputs?.filter((output) => !deepEquals(output, txOut))
    };
    return this;
  }

  buildOutput(txOut?: PartialTxOut): TxOutputBuilder {
    return new TxOutputBuilder({
      handleProvider: this.#handleProvider,
      logger: contextLogger(this.#logger, 'outputBuilder'),
      outputValidator: this.#outputValidator,
      txOut
    });
  }

  delegate(poolId?: Cardano.PoolId): TxBuilder {
    this.#delegateConfig = poolId ? { poolId, type: 'delegate' } : { type: 'deregister' };
    return this;
  }

  metadata(metadata: Cardano.TxMetadata): TxBuilder {
    this.partialAuxiliaryData = { ...this.partialAuxiliaryData, blob: new Map(metadata) };
    return this;
  }

  extraSigners(signers: TransactionSigner[]): TxBuilder {
    this.partialExtraSigners = [...signers];
    return this;
  }

  signingOptions(options: SignTransactionOptions): TxBuilder {
    this.partialSigningOptions = { ...options };
    return this;
  }

  build(): UnsignedTx {
    return new LazyTxSigner({
      builder: {
        build: async () => {
          this.#logger.debug('Building');
          try {
            await this.#addDelegationCertificates();
            await this.#validateOutputs();
            // Take a snapshot of returned properties,
            // so that they don't change while `initializeTx` is resolving
            const ownAddresses = await firstValueFrom(this.#dependencies.keyAgent.knownAddresses$);
            const auxiliaryData = this.partialAuxiliaryData && { ...this.partialAuxiliaryData };
            const extraSigners = this.partialExtraSigners && [...this.partialExtraSigners];
            const signingOptions = this.partialSigningOptions && { ...this.partialSigningOptions };

            if (this.partialAuxiliaryData) {
              this.partialTxBody.auxiliaryDataHash = Cardano.computeAuxiliaryDataHash(this.partialAuxiliaryData);
            }

            const { body, hash, inputSelection } = await initializeTx(
              {
                auxiliaryData,
                certificates: this.partialTxBody.certificates,
                handles: this.#handles,
                outputs: new Set(this.partialTxBody.outputs || []),
                signingOptions,
                witness: { extraSigners }
              },
              this.#dependencies
            );
            return {
              ctx: {
                auxiliaryData,
                handles: this.#handles,
                ownAddresses,
                signingOptions,
                witness: { extraSigners }
              },
              inputSelection,
              tx: { body, hash }
            };
          } catch (error) {
            this.#logger.debug('Transaction build error', error);
            if (Array.isArray(error)) throw error[0];
            throw error;
          }
        }
      },
      signer: {
        sign: ({ tx, ctx }) => finalizeTx(tx, ctx, this.#dependencies)
      }
    });
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
      if (this.#delegateConfig.type === 'deregister') {
        // Deregister scenario
        if (rewardAccount.keyStatus === Cardano.StakeKeyStatus.Unregistered) {
          this.#logger.warn(
            'Skipping stake key deregister. Stake key not registered.',
            rewardAccount.address,
            rewardAccount.keyStatus
          );
        } else {
          this.partialTxBody.certificates!.push(Cardano.createStakeKeyDeregistrationCert(rewardAccount.address));
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
          this.partialTxBody.certificates!.push(Cardano.createStakeKeyRegistrationCert(rewardAccount.address));
        }

        this.partialTxBody.certificates!.push(
          Cardano.createDelegationCert(rewardAccount.address, this.#delegateConfig.poolId)
        );
      }
    }
  }
}
