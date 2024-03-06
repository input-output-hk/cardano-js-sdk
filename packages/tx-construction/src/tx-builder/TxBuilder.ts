/* eslint-disable complexity */
import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  GroupedAddress,
  SignTransactionOptions,
  TransactionSigner,
  util
} from '@cardano-sdk/key-management';
import { Cardano, HandleProvider, HandleResolution, metadatum } from '@cardano-sdk/core';
import {
  CustomizeCb,
  InsufficientRewardAccounts,
  OutOfSyncRewardAccounts,
  OutputBuilderTxOut,
  PartialTx,
  PartialTxOut,
  SignedTx,
  TxBuilder,
  TxBuilderDependencies,
  TxContext,
  TxInspection,
  TxOutValidationError,
  UnsignedTx
} from './types';
import { GreedyInputSelector, SelectionSkeleton } from '@cardano-sdk/input-selection';
import { Logger } from 'ts-log';
import { OutputBuilderValidator, TxOutputBuilder } from './OutputBuilder';
import { RewardAccountWithPoolId } from '../types';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { contextLogger, deepEquals } from '@cardano-sdk/util';
import { createOutputValidator } from '../output-validation';
import { finalizeTx } from './finalizeTx';
import { initializeTx } from './initializeTx';
import { lastValueFrom } from 'rxjs';
import minBy from 'lodash/minBy';
import omit from 'lodash/omit';
import uniq from 'lodash/uniq';

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

type TxBuilderStakePool = Omit<Cardano.Cip17Pool, 'id'> & { id: Cardano.PoolId };
type RewardAccountsAndWeights = Map<Cardano.RewardAccount, number>;

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
      ctx: {
        signingContext: { knownAddresses },
        auxiliaryData,
        handleResolutions
      },
      inputSelection
    } = await this.#build();
    return { ...tx, auxiliaryData, handleResolutions, inputSelection, ownAddresses: knownAddresses };
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
  #requestedPortfolio?: TxBuilderStakePool[];
  #logger: Logger;
  #handleProvider?: HandleProvider;
  #handleResolutions: HandleResolution[];
  #customizeCb: CustomizeCb;

  constructor(dependencies: TxBuilderDependencies) {
    this.#outputValidator =
      dependencies.outputValidator ||
      createOutputValidator({
        protocolParameters: dependencies.txBuilderProviders.protocolParameters
      });
    this.#dependencies = dependencies;
    this.#logger = dependencies.logger;
    this.#handleProvider = dependencies.handleProvider;
    this.#handleResolutions = [];
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
    if (txOut.handleResolution) {
      this.#handleResolutions = [...this.#handleResolutions, txOut.handleResolution];
    }
    const txOutNoHandle = omit(txOut, ['handle', 'handleResolution']);
    this.partialTxBody = { ...this.partialTxBody, outputs: [...(this.partialTxBody.outputs || []), txOutNoHandle] };
    return this;
  }

  removeOutput(txOut: OutputBuilderTxOut): TxBuilder {
    this.#handleResolutions = this.#handleResolutions.filter((hndRes) => hndRes.handle !== txOut.handle);
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

  delegatePortfolio(portfolio: Cardano.Cip17DelegationPortfolio | null): TxBuilder {
    if (portfolio?.pools.length === 0) {
      throw new Error('Portfolio should define at least one delegation pool.');
    }
    this.#requestedPortfolio = (portfolio?.pools ?? []).map((pool) => ({
      ...pool,
      id: Cardano.PoolId.fromKeyHash(pool.id as unknown as Crypto.Ed25519KeyHashHex)
    }));

    if (portfolio) {
      if (this.partialAuxiliaryData?.blob) {
        this.partialAuxiliaryData.blob.set(
          Cardano.DelegationMetadataLabel,
          metadatum.jsonToMetadatum(Cardano.portfolioMetadataFromCip17(portfolio))
        );
      } else {
        this.partialAuxiliaryData = {
          ...this.partialAuxiliaryData,
          blob: new Map([
            [Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(Cardano.portfolioMetadataFromCip17(portfolio))]
          ])
        };
      }
    }

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

  customize(cb: CustomizeCb): TxBuilder {
    this.#customizeCb = cb;
    return this;
  }

  build(): UnsignedTx {
    return new LazyTxSigner({
      builder: {
        build: async () => {
          this.#logger.debug('Building');
          try {
            const rewardAccountsWithWeights = await this.#delegatePortfolio();
            await this.#validateOutputs();
            // Take a snapshot of returned properties,
            // so that they don't change while `initializeTx` is resolving
            const ownAddresses = await this.#dependencies.txBuilderProviders.addresses.get();
            const registeredRewardAccounts = (await this.#dependencies.txBuilderProviders.rewardAccounts()).filter(
              (acct) =>
                acct.keyStatus === Cardano.StakeKeyStatus.Registered ||
                acct.keyStatus === Cardano.StakeKeyStatus.Registering
            );
            const auxiliaryData = this.partialAuxiliaryData && { ...this.partialAuxiliaryData };
            const extraSigners = this.partialExtraSigners && [...this.partialExtraSigners];
            const partialSigningOptions = this.partialSigningOptions && { ...this.partialSigningOptions };

            if (this.partialAuxiliaryData) {
              this.partialTxBody.auxiliaryDataHash = Cardano.computeAuxiliaryDataHash(this.partialAuxiliaryData);
            }

            const dependencies = { ...this.#dependencies };
            // Use greedy input selection if:
            // 1. Multi delegating: to distribute the funds to multiple addresses.
            // 2. Reducing the number of pools to 1 or 0, which implies we have multiple registered stake keys. This is needed
            //    to concentrate the funds back into a single address and delegate its stake key.
            if (
              rewardAccountsWithWeights.size > 1 ||
              (registeredRewardAccounts.length > 1 && rewardAccountsWithWeights.size <= 1)
            ) {
              // If the wallet is currently delegating to several pools, and all delegations are being removed,
              // then the funds will be concentrated back into a single address.
              if (rewardAccountsWithWeights.size === 0) {
                const firstAddress = await this.#dependencies.bip32Account.deriveAddress(
                  { index: 0, type: AddressType.External },
                  0
                );

                rewardAccountsWithWeights.set(firstAddress.rewardAccount, 1);
              }

              // Distributing balance according to weights is necessary when there are multiple reward accounts
              // and delegating, to make sure utxos are part of the correct addresses (the ones being delegated)
              dependencies.inputSelector = GenericTxBuilder.#createGreedyInputSelector(
                rewardAccountsWithWeights,
                ownAddresses
              );
            }

            const { body, hash, inputSelection } = await initializeTx(
              {
                auxiliaryData,
                certificates: this.partialTxBody.certificates,
                customizeCb: this.#customizeCb,
                handleResolutions: this.#handleResolutions,
                outputs: new Set(this.partialTxBody.outputs || []),
                proposalProcedures: this.partialTxBody.proposalProcedures,
                signingOptions: partialSigningOptions,
                witness: { extraSigners }
              },
              dependencies
            );
            return {
              ctx: {
                auxiliaryData,
                handleResolutions: this.#handleResolutions,
                ownAddresses,
                signingContext: {
                  knownAddresses: ownAddresses,
                  txInKeyPathMap: await util.createTxInKeyPathMap(body, ownAddresses, this.#dependencies.inputResolver)
                },
                signingOptions: partialSigningOptions,
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

  async #getOrCreateRewardAccounts(): Promise<RewardAccountWithPoolId[]> {
    let allRewardAccounts: Cardano.RewardAccount[] = [];
    if (this.#requestedPortfolio) {
      const knownAddresses = await this.#dependencies.txBuilderProviders.addresses.get();
      const { newAddresses } = await util.ensureStakeKeys({
        bip32Account: this.#dependencies.bip32Account,
        count: this.#requestedPortfolio.length,
        knownAddresses,
        logger: contextLogger(this.#logger, 'getOrCreateRewardAccounts')
      });
      await this.#dependencies.txBuilderProviders.addresses.add(...newAddresses);
      allRewardAccounts = uniq([...knownAddresses, ...newAddresses]).map(({ rewardAccount }) => rewardAccount);
    }

    const rewardAccounts$ = coldObservableProvider({
      pollUntil: (rewardAccounts) =>
        allRewardAccounts.every((newAccount) => rewardAccounts.some((acct) => acct.address === newAccount)),
      provider: this.#dependencies.txBuilderProviders.rewardAccounts,
      retryBackoffConfig: { initialInterval: 10, maxInterval: 100, maxRetries: 10 }
    });

    try {
      return await lastValueFrom(rewardAccounts$);
    } catch {
      throw new OutOfSyncRewardAccounts(allRewardAccounts);
    }
  }

  async #delegatePortfolio(): Promise<RewardAccountsAndWeights> {
    const rewardAccountsWithWeights: RewardAccountsAndWeights = new Map();
    if (!this.#requestedPortfolio) {
      // Delegation using CIP17 portfolio was not requested
      return rewardAccountsWithWeights;
    }

    // Create stake keys to match number of requested pools
    const rewardAccounts = await this.#getOrCreateRewardAccounts();

    // New poolIds will be allocated to un-delegated stake keys
    const newPools = this.#requestedPortfolio
      .filter((cip17Pool) =>
        rewardAccounts.every((rewardAccount) => rewardAccount.delegatee?.nextNextEpoch?.id !== cip17Pool.id)
      )
      .reverse();

    this.#logger.debug(
      'New poolIds requested in portfolio:',
      newPools.map(({ id }) => id)
    );

    // Reward accounts already delegated to the correct pool. Change must be distributed accordingly
    for (const account of rewardAccounts.filter(
      (rewardAccount) =>
        rewardAccount.keyStatus === Cardano.StakeKeyStatus.Registered &&
        rewardAccount.delegatee?.nextNextEpoch &&
        this.#requestedPortfolio?.some(({ id }) => id === rewardAccount.delegatee?.nextNextEpoch?.id)
    ))
      rewardAccountsWithWeights.set(
        account.address,
        this.#requestedPortfolio!.find(({ id }) => id === account.delegatee?.nextNextEpoch?.id)!.weight
      );

    // Reward accounts which don't have the stake key registered or that were delegated but should not be anymore
    const availableRewardAccounts = rewardAccounts
      .filter(
        (rewardAccount) =>
          rewardAccount.keyStatus === Cardano.StakeKeyStatus.Unregistered ||
          !rewardAccount.delegatee?.nextNextEpoch ||
          this.#requestedPortfolio?.every(({ id }) => id !== rewardAccount.delegatee?.nextNextEpoch?.id)
      )
      .sort(GenericTxBuilder.#sortRewardAccountsDelegatedFirst)
      .reverse(); // items will be popped from this array, so we want the most suitable at the end of the array

    if (newPools.length > availableRewardAccounts.length) {
      throw new InsufficientRewardAccounts(
        newPools.map(({ id }) => id),
        availableRewardAccounts.map(({ address }) => address)
      );
    }

    // Code below will pop items one by one (poolId)-(available stake key)
    const certificates: Cardano.Certificate[] = [];
    while (newPools.length > 0 && availableRewardAccounts.length > 0) {
      const { id: newPoolId, weight } = newPools.pop()!;
      const rewardAccount = availableRewardAccounts.pop()!;
      this.#logger.debug(`Building delegation certificate for ${newPoolId} ${rewardAccount}`);
      if (rewardAccount.keyStatus !== Cardano.StakeKeyStatus.Registered) {
        certificates.push(Cardano.createStakeRegistrationCert(rewardAccount.address));
      }
      certificates.push(Cardano.createDelegationCert(rewardAccount.address, newPoolId));
      rewardAccountsWithWeights.set(rewardAccount.address, weight);
    }

    // Deregister stake keys no longer needed
    this.#logger.debug(`De-registering ${availableRewardAccounts.length} stake keys`);
    for (const rewardAccount of availableRewardAccounts) {
      if (rewardAccount.keyStatus === Cardano.StakeKeyStatus.Registered) {
        certificates.push(Cardano.createStakeDeregistrationCert(rewardAccount.address, rewardAccount.deposit));
      }
    }
    this.partialTxBody = { ...this.partialTxBody, certificates };
    return rewardAccountsWithWeights;
  }

  /** Registered and delegated < Registered < Unregistered */
  static #sortRewardAccountsDelegatedFirst(a: RewardAccountWithPoolId, b: RewardAccountWithPoolId): number {
    const getScore = (acct: RewardAccountWithPoolId) => {
      let score = 2;
      if (acct.keyStatus === Cardano.StakeKeyStatus.Registered) {
        score = 1;
        if (acct.delegatee?.nextNextEpoch) {
          score = 0;
        }
      }
      return score;
    };

    return getScore(a) - getScore(b);
  }

  /**
   * Searches the payment address with the smallest index associated to the reward accounts.
   *
   * @param rewardAccountsWithWeights reward account addresses and the portfolio distribution weights.
   * @param ownAddresses addresses to search in by reward account.
   * @returns GreedyInputSelector with the addresses and weights to use as change addresses.
   * @throws in case some reward accounts are not associated with any of the own addresses
   */
  static #createGreedyInputSelector(
    rewardAccountsWithWeights: RewardAccountsAndWeights,
    ownAddresses: GroupedAddress[]
  ) {
    // select the address with smallest index for each reward account
    const addressesAndWeights = new Map(
      [...rewardAccountsWithWeights].map(([rewardAccount, weight]) => {
        const address = minBy(
          ownAddresses.filter((ownAddr) => ownAddr.rewardAccount === rewardAccount),
          ({ index }) => index
        );
        if (!address) {
          throw new Error(`Could not find any address associated with ${rewardAccount}.`);
        }
        return [address.address, weight];
      })
    );

    return new GreedyInputSelector({
      getChangeAddresses: () => Promise.resolve(addressesAndWeights)
    });
  }
}
