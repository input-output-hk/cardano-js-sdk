import { Cardano } from '@cardano-sdk/core';
import { Observable, firstValueFrom } from 'rxjs';

import { FinalizeTxProps, InitializeTxProps, ObservableWallet } from '../types';
import {
  IncompatibleWalletError,
  MaybeValidTx,
  OutputBuilder,
  OutputValidationMinimumCoinError,
  OutputValidationTokenBundleSizeError,
  PartialTxOut,
  SignedTx,
  TxBodyValidationError,
  TxBuilder,
  TxOutValidationError
} from './types';
import { ObservableWalletTxOutputBuilder, toOutputValidationError } from './OutputBuilder';
import { OutputValidator, RewardAccount, StakeKeyStatus, WalletUtilContext, createWalletUtil } from '../services';
import { SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { deepEquals } from '@cardano-sdk/util';

/**
 * Minimal sub-type of ObservableWallet that is used by TxBuilder.
 */
export type ObservableWalletTxBuilderDependencies = Pick<ObservableWallet, 'submitTx'> & {
  delegation: { rewardAccounts$: Observable<Pick<RewardAccount, 'address' | 'keyStatus'>[]> };
} & {
  initializeTx: (
    props: Pick<InitializeTxProps, 'auxiliaryData' | 'outputs' | 'signingOptions' | 'extraSigners' | 'certificates'>
  ) => ReturnType<ObservableWallet['initializeTx']>;
} & {
  finalizeTx: (
    props: Pick<FinalizeTxProps, 'auxiliaryData' | 'tx' | 'signingOptions' | 'extraSigners'>
  ) => ReturnType<ObservableWallet['finalizeTx']>;
} & WalletUtilContext;

/**
 * Transactions built with {@link ObservableWalletTxBuilder.build} method, use this method to sign the transaction.
 *
 * @returns Promise with `SignedTx` object that has a {@link SignedTx.submit} method that submits the transaction.
 */
const createSignedTx = async ({
  wallet,
  tx,
  extraSigners,
  signingOptions,
  auxiliaryData
}: FinalizeTxProps & { wallet: ObservableWalletTxBuilderDependencies }): Promise<SignedTx> => {
  const finalizedTx = await wallet.finalizeTx({ auxiliaryData, extraSigners, signingOptions, tx });
  return {
    submit: () => wallet.submitTx(finalizedTx),
    tx: finalizedTx
  };
};

/**
 * `TxBuilder` concrete implementation, based on `ObservableWalletTxBuilderDependencies`.
 * It relies on `ObservableWalletTxBuilderDependencies` for building, signing, sending, etc.
 * Usage examples are in the unit/integration tests from `builtTx.test.ts`.
 */
export class ObservableWalletTxBuilder implements TxBuilder {
  partialTxBody: Partial<Cardano.NewTxBodyAlonzo> = {};
  auxiliaryData?: Cardano.AuxiliaryData;
  extraSigners?: TransactionSigner[];
  signingOptions?: SignTransactionOptions;

  #observableWallet: ObservableWalletTxBuilderDependencies;
  #util: OutputValidator;

  /**
   * @param observableWallet minimal ObservableWallet needed to do actions like {@link build()}, {@link delegate()} etc.
   * @param util optional custom output validator util. Uses {@link createWalletUtil} by default.
   */
  constructor(
    observableWallet: ObservableWalletTxBuilderDependencies,
    util: OutputValidator = createWalletUtil(observableWallet)
  ) {
    this.#observableWallet = observableWallet;
    this.#util = util;
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
    return new ObservableWalletTxOutputBuilder(this.#util, txOut);
  }

  async delegate(poolId: Cardano.PoolId): Promise<TxBuilder> {
    const rewardAccounts = await firstValueFrom(this.#observableWallet.delegation.rewardAccounts$);

    if (!rewardAccounts?.length) {
      // This shouldn't happen
      throw new IncompatibleWalletError();
    }

    // Discard previous delegation and prepare for new one
    this.partialTxBody = { ...this.partialTxBody, certificates: [] };

    for (const rewardAccount of rewardAccounts) {
      const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount.address);

      if (rewardAccount.keyStatus === StakeKeyStatus.Unregistered) {
        this.partialTxBody.certificates!.push(ObservableWalletTxBuilder.#createStakeKeyCert(stakeKeyHash));
      }

      this.partialTxBody.certificates!.push(ObservableWalletTxBuilder.#createDelegationCert(poolId, stakeKeyHash));
    }
    return this;
  }

  setMetadata(metadata: Cardano.TxMetadata): TxBuilder {
    this.auxiliaryData = { ...this.auxiliaryData, body: { ...this.auxiliaryData?.body, blob: new Map(metadata) } };
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
      await this.#validateOutputs();

      const tx = await this.#observableWallet.initializeTx({
        auxiliaryData: this.auxiliaryData,
        certificates: this.partialTxBody.certificates,
        extraSigners: this.extraSigners,
        outputs: new Set(this.partialTxBody.outputs || []),
        signingOptions: this.signingOptions
      });
      return {
        auxiliaryData: this.auxiliaryData && { ...this.auxiliaryData },
        body: tx.body,
        extraSigners: this.extraSigners && [...this.extraSigners],
        isValid: true,
        sign: () =>
          createSignedTx({
            auxiliaryData: this.auxiliaryData && { ...this.auxiliaryData },
            extraSigners: this.extraSigners && [...this.extraSigners],
            signingOptions: this.signingOptions && { ...this.signingOptions },
            tx,
            wallet: this.#observableWallet
          }),
        signingOptions: this.signingOptions && { ...this.signingOptions }
      };
    } catch (error) {
      const errors = Array.isArray(error) ? (error as TxBodyValidationError[]) : [error as TxBodyValidationError];
      return {
        errors,
        isValid: false
      };
    }
  }

  async #validateOutputs(): Promise<TxOutValidationError[]> {
    const outputValidations =
      this.partialTxBody.outputs && (await this.#util.validateOutputs(this.partialTxBody.outputs));

    const errors = [...(outputValidations?.entries() || [])]
      .map(([txOut, validation]) => toOutputValidationError(txOut, validation))
      .filter((err): err is OutputValidationTokenBundleSizeError | OutputValidationMinimumCoinError => !!err);

    if (errors.length > 0) {
      throw errors;
    }
    return [];
  }

  static #createDelegationCert(
    poolId: Cardano.PoolId,
    stakeKeyHash: Cardano.Ed25519KeyHash
  ): Cardano.StakeDelegationCertificate {
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId,
      stakeKeyHash
    };
  }

  static #createStakeKeyCert(stakeKeyHash: Cardano.Ed25519KeyHash): Cardano.StakeAddressCertificate {
    return {
      __typename: Cardano.CertificateType.StakeKeyRegistration,
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
export const buildTx = (observableWallet: ObservableWalletTxBuilderDependencies, util?: OutputValidator): TxBuilder =>
  new ObservableWalletTxBuilder(observableWallet, util);
