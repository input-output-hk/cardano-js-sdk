/* eslint-disable complexity */
import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  Bip32Account,
  SignTransactionOptions,
  TransactionSigner,
  WitnessedTx,
  util
} from '@cardano-sdk/key-management';
import { Cardano, HandleProvider, HandleResolution, Serialization, metadatum } from '@cardano-sdk/core';
import {
  CustomizeCb,
  InsufficientRewardAccounts,
  OutOfSyncRewardAccounts,
  OutputBuilderTxOut,
  PartialTx,
  PartialTxOut,
  ScriptUnlockProps,
  TxBuilder,
  TxBuilderDependencies,
  TxContext,
  TxEvaluator,
  TxInspection,
  TxOutValidationError,
  UnwitnessedTx
} from './types';
import { GreedyTxEvaluator } from './GreedyTxEvaluator';
import { Logger } from 'ts-log';
import { OutputBuilderValidator, TxOutputBuilder } from './OutputBuilder';
import { RedeemersByType } from '../input-selection';
import { RewardAccountWithPoolId } from '../types';
import {
  RewardAccountsAndWeights,
  buildWitness,
  computeCollateral,
  createGreedyInputSelector,
  sortRewardAccountsDelegatedFirst,
  validateValidityInterval
} from './utils';
import { SelectionSkeleton } from '@cardano-sdk/input-selection';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { contextLogger, deepEquals } from '@cardano-sdk/util';
import { createOutputValidator } from '../output-validation';
import { initializeTx } from './initializeTx';
import { lastValueFrom } from 'rxjs';
import omit from 'lodash/omit';
import uniq from 'lodash/uniq';

const DUMMY_SCRIPT_DATA_HASH = '0'.repeat(64) as unknown as Crypto.Hash32ByteBase16;

type BuiltTx = {
  tx: Cardano.TxBodyWithHash;
  ctx: TxContext;
  inputSelection: SelectionSkeleton;
};

interface Signer {
  sign(builtTx: BuiltTx): Promise<WitnessedTx>;
}

interface Builder {
  build(): Promise<BuiltTx>;
}

interface LazySignerProps {
  builder: Builder;
  signer: Signer;
}

type TxBuilderStakePool = Omit<Cardano.Cip17Pool, 'id'> & { id: Cardano.PoolId };

class LazyTxSigner implements UnwitnessedTx {
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
        signingContext: { knownAddresses, handleResolutions },
        auxiliaryData,
        witness
      },
      inputSelection
    } = await this.#build();

    return {
      ...tx,
      auxiliaryData,
      handleResolutions,
      inputSelection,
      ownAddresses: knownAddresses,
      witness: witness as Cardano.Witness
    };
  }

  async sign(): Promise<WitnessedTx> {
    return this.#signer.sign(await this.#build());
  }
}

export type TxIdWithIndex = string;

export class GenericTxBuilder implements TxBuilder {
  partialTxBody: Partial<Cardano.TxBody> = {};
  partialAuxiliaryData?: Cardano.AuxiliaryData;
  partialExtraSigners?: TransactionSigner[];
  partialSigningOptions?: SignTransactionOptions;

  #dependencies: TxBuilderDependencies;
  #outputValidator: OutputBuilderValidator;
  #requestedPortfolio?: TxBuilderStakePool[];
  #txEvaluator: TxEvaluator;
  #logger: Logger;
  #handleProvider?: HandleProvider;
  #handleResolutions: HandleResolution[];
  #delegateFirstStakeCredConfig: Cardano.PoolId | null | undefined = undefined;

  #preSelectedInputs = new Map<TxIdWithIndex, Cardano.Utxo>();
  #referenceInputs = new Map<TxIdWithIndex, Cardano.Utxo>();
  #knownScripts = new Map<Crypto.Hash28ByteBase16, Cardano.Script>();
  #knownReferenceScripts = new Set<Crypto.Hash28ByteBase16>();
  #knownDatums = new Map<Cardano.DatumHash, Cardano.PlutusData>();
  #knownInlineDatums = new Set<Cardano.DatumHash>();
  #knownRedeemers: RedeemersByType = {
    certificate: new Array<Cardano.Redeemer>(),
    mint: new Array<Cardano.Redeemer>(),
    propose: new Array<Cardano.Redeemer>(),
    spend: new Map<TxIdWithIndex, Cardano.Redeemer>(),
    vote: new Array<Cardano.Redeemer>(),
    withdrawal: new Array<Cardano.Redeemer>()
  };

  #unresolvedInputs = new Array<Cardano.TxIn>();
  #unresolvedReferenceInputs = new Array<Cardano.TxIn>();
  #unresolvedDatums = new Array<Cardano.DatumHash>();

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
    this.#txEvaluator =
      dependencies.txEvaluator ?? new GreedyTxEvaluator(dependencies.txBuilderProviders.protocolParameters);
  }

  async inspect(): Promise<PartialTx> {
    return {
      auxiliaryData: this.partialAuxiliaryData,
      body: this.partialTxBody,
      extraSigners: this.partialExtraSigners,
      signingOptions: this.partialSigningOptions
    };
  }

  addReferenceInput(input: Cardano.TxIn | Cardano.Utxo): TxBuilder {
    if (Array.isArray(input)) {
      const inputId: TxIdWithIndex = `${input[0].txId}#${input[0].index}`;
      this.#referenceInputs.set(inputId, input);

      return this;
    }

    if (
      !this.#unresolvedReferenceInputs.some(
        (unresolvedInput) => unresolvedInput.txId === input.txId && unresolvedInput.index === input.index
      )
    )
      this.#unresolvedReferenceInputs.push(input);

    return this;
  }

  addInput(input: Cardano.TxIn | Cardano.Utxo, scriptUnlockProps?: ScriptUnlockProps): TxBuilder {
    if (scriptUnlockProps) {
      this.#addScriptInput(input, scriptUnlockProps);
      return this;
    }

    if (Array.isArray(input)) {
      const inputId: TxIdWithIndex = `${input[0].txId}#${input[0].index}`;
      this.#preSelectedInputs.set(inputId, input);

      return this;
    }

    if (
      !this.#unresolvedInputs.some(
        (unresolvedInput) => unresolvedInput.txId === input.txId && unresolvedInput.index === input.index
      )
    )
      this.#unresolvedInputs.push(input);

    return this;
  }

  addDatum(datum: Cardano.PlutusData): TxBuilder {
    const hash = Serialization.PlutusData.fromCore(datum).hash();

    this.#knownDatums.set(hash, datum);

    return this;
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

  delegateFirstStakeCredential(poolId: Cardano.PoolId | null): TxBuilder {
    this.#delegateFirstStakeCredConfig = poolId;
    return this;
  }

  delegatePortfolio(portfolio: Cardano.Cip17DelegationPortfolio | null): TxBuilder {
    if (!this.#dependencies.bip32Account) throw new Error('BIP32 account is required to delegate portfolio.');

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

  build(): UnwitnessedTx {
    return new LazyTxSigner({
      builder: {
        // eslint-disable-next-line sonarjs/cognitive-complexity,max-statements
        build: async () => {
          this.#logger.debug('Building');
          try {
            const rewardAccountsWithWeights = this.#dependencies.bip32Account
              ? await this.#delegatePortfolio()
              : await this.#delegateFirstStakeCredential();

            await this.#validateOutputs();

            validateValidityInterval(
              await this.#dependencies.txBuilderProviders.tip(),
              this.partialTxBody.validityInterval
            );

            // Take a snapshot of returned properties,
            // so that they don't change while `initializeTx` is resolving
            const ownAddresses = await this.#dependencies.txBuilderProviders.addresses.get();
            const registeredRewardAccounts = (await this.#dependencies.txBuilderProviders.rewardAccounts()).filter(
              (acct) =>
                acct.credentialStatus === Cardano.StakeCredentialStatus.Registered ||
                acct.credentialStatus === Cardano.StakeCredentialStatus.Registering
            );
            const auxiliaryData = this.partialAuxiliaryData && { ...this.partialAuxiliaryData };
            const extraSigners = this.partialExtraSigners && [...this.partialExtraSigners];
            const partialSigningOptions = this.partialSigningOptions && { ...this.partialSigningOptions, extraSigners };

            if (this.partialAuxiliaryData) {
              this.partialTxBody.auxiliaryDataHash = Cardano.computeAuxiliaryDataHash(this.partialAuxiliaryData);
            }

            const dependencies = { ...this.#dependencies };
            const isAlteringDelegation =
              this.#requestedPortfolio !== undefined || this.#delegateFirstStakeCredConfig !== undefined;

            if (
              this.#dependencies.bip32Account &&
              isAlteringDelegation &&
              (rewardAccountsWithWeights.size > 1 ||
                (registeredRewardAccounts.length > 1 && rewardAccountsWithWeights.size <= 1))
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
              dependencies.inputSelector = createGreedyInputSelector(rewardAccountsWithWeights, ownAddresses);
            }

            // Resolved all unresolved inputs
            await Promise.all(
              this.#unresolvedInputs.map((input) => this.#resolveInput(input, this.#preSelectedInputs))
            );
            await Promise.all(
              this.#unresolvedReferenceInputs.map((input) => this.#resolveInput(input, this.#referenceInputs))
            );

            // We must resolve datums after inputs since we may discover datums during that process.
            await Promise.all(this.#unresolvedDatums.map((datumHash) => this.#resolveDatum(datumHash)));

            const witness = await buildWitness(
              this.#knownScripts,
              this.#knownReferenceScripts,
              this.#knownDatums,
              this.#knownInlineDatums,
              this.#knownRedeemers,
              this.#dependencies.txBuilderProviders
            );

            const hasPlutusScripts = [...this.#knownScripts.values()].some((script) => Cardano.isPlutusScript(script));

            const { collaterals, collateralReturn } = hasPlutusScripts
              ? await computeCollateral(this.#dependencies.txBuilderProviders)
              : { collateralReturn: undefined, collaterals: undefined };

            const scriptVersions = new Set<Cardano.PlutusLanguageVersion>();
            for (const script of this.#knownScripts.values()) {
              if (Cardano.isPlutusScript(script)) {
                scriptVersions.add(script.version);
              }
            }

            const { body, hash, inputSelection, redeemers } = await initializeTx(
              {
                auxiliaryData,
                certificates: this.partialTxBody.certificates,
                collateralReturn,
                collaterals,
                customizeCb: this.#customizeCb,
                handleResolutions: this.#handleResolutions,
                inputs: new Set(this.#preSelectedInputs.values()),
                options: {
                  validityInterval: this.partialTxBody.validityInterval
                },
                outputs: new Set(this.partialTxBody.outputs || []),
                proposalProcedures: this.partialTxBody.proposalProcedures,
                redeemersByType: this.#knownRedeemers,
                referenceInputs: new Set([...this.#referenceInputs.values()].map((utxo) => utxo[0])),
                scriptIntegrityHash: hasPlutusScripts ? DUMMY_SCRIPT_DATA_HASH : undefined,
                scriptVersions,
                signingOptions: partialSigningOptions,
                txEvaluator: this.#txEvaluator,
                witness
              },
              dependencies
            );

            witness.redeemers = redeemers;

            return {
              ctx: {
                auxiliaryData,
                ownAddresses,
                signingContext: {
                  handleResolutions: this.#handleResolutions,
                  knownAddresses: ownAddresses,
                  txInKeyPathMap: await util.createTxInKeyPathMap(body, ownAddresses, this.#dependencies.inputResolver)
                },
                signingOptions: { ...partialSigningOptions, extraSigners },
                witness
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
        sign: ({ tx, ctx }) => {
          const transaction = new Serialization.Transaction(
            Serialization.TransactionBody.fromCore(tx.body),
            Serialization.TransactionWitnessSet.fromCore((ctx.witness ?? { signatures: new Map() }) as Cardano.Witness),
            ctx.auxiliaryData ? Serialization.AuxiliaryData.fromCore(ctx.auxiliaryData) : undefined
          );

          if (ctx.isValid !== undefined) transaction.setIsValid(ctx.isValid);

          const signingOptions = { ...ctx.signingOptions, stubSign: false };
          const signingContext = ctx.signingContext;

          return this.#dependencies.witnesser.witness(transaction, signingContext, signingOptions);
        }
      }
    });
  }
  setValidityInterval(validityInterval: Cardano.ValidityInterval): TxBuilder {
    this.partialTxBody = { ...this.partialTxBody, validityInterval };

    return this;
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

  async #getOrCreateRewardAccounts(bip32Account: Bip32Account): Promise<RewardAccountWithPoolId[]> {
    let allRewardAccounts: Cardano.RewardAccount[] = [];
    if (this.#requestedPortfolio) {
      const knownAddresses = await this.#dependencies.txBuilderProviders.addresses.get();
      const { newAddresses } = await util.ensureStakeKeys({
        bip32Account,
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

  async #delegateFirstStakeCredential(): Promise<RewardAccountsAndWeights> {
    const rewardAccountsWithWeights: RewardAccountsAndWeights = new Map();
    if (this.#delegateFirstStakeCredConfig === undefined) {
      // Delegation was not configured by user
      return Promise.resolve(rewardAccountsWithWeights);
    }

    const rewardAccounts = await this.#dependencies.txBuilderProviders.rewardAccounts();

    if (!rewardAccounts?.length) {
      // This shouldn't happen
      throw new Error('Could not find any rewardAccount.');
    }

    const rewardAccount = rewardAccounts[0];

    this.partialTxBody = { ...this.partialTxBody, certificates: [] };

    const stakeCredential = Cardano.Address.fromBech32(rewardAccount.address).asReward()?.getPaymentCredential();

    if (!stakeCredential) {
      // This shouldn't happen
      throw new Error(`Invalid credential ${stakeCredential}.`);
    }

    if (this.#delegateFirstStakeCredConfig === null) {
      // Deregister scenario
      if (rewardAccount.credentialStatus === Cardano.StakeCredentialStatus.Unregistered) {
        this.#logger.warn('Stake key not registered.', rewardAccount.address, rewardAccount.credentialStatus);
      } else {
        this.partialTxBody.certificates!.push({
          __typename: Cardano.CertificateType.StakeDeregistration,
          stakeCredential
        });
      }
    } else {
      // Register and delegate scenario
      if (rewardAccount.credentialStatus !== Cardano.StakeCredentialStatus.Unregistered) {
        this.#logger.debug('Stake key already registered', rewardAccount.address, rewardAccount.credentialStatus);
      } else {
        this.partialTxBody.certificates!.push({
          __typename: Cardano.CertificateType.StakeRegistration,
          stakeCredential
        });
      }

      rewardAccountsWithWeights.set(rewardAccount.address, 1);
      this.partialTxBody.certificates!.push({
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: this.#delegateFirstStakeCredConfig,
        stakeCredential
      });
    }

    return rewardAccountsWithWeights;
  }

  async #delegatePortfolio(): Promise<RewardAccountsAndWeights> {
    const rewardAccountsWithWeights: RewardAccountsAndWeights = new Map();
    if (!this.#requestedPortfolio) {
      // Delegation using CIP17 portfolio was not requested
      return rewardAccountsWithWeights;
    }

    if (!this.#dependencies.bip32Account) throw new Error('BIP32 account is required to delegate portfolio.');

    // Create stake keys to match number of requested pools
    const rewardAccounts = await this.#getOrCreateRewardAccounts(this.#dependencies.bip32Account);

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
        rewardAccount.credentialStatus === Cardano.StakeCredentialStatus.Registered &&
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
          rewardAccount.credentialStatus === Cardano.StakeCredentialStatus.Unregistered ||
          !rewardAccount.delegatee?.nextNextEpoch ||
          this.#requestedPortfolio?.every(({ id }) => id !== rewardAccount.delegatee?.nextNextEpoch?.id)
      )
      .sort(sortRewardAccountsDelegatedFirst)
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
      if (rewardAccount.credentialStatus !== Cardano.StakeCredentialStatus.Registered) {
        certificates.push(Cardano.createStakeRegistrationCert(rewardAccount.address));
      }
      certificates.push(Cardano.createDelegationCert(rewardAccount.address, newPoolId));
      rewardAccountsWithWeights.set(rewardAccount.address, weight);
    }

    // Deregister stake keys no longer needed
    this.#logger.debug(`De-registering ${availableRewardAccounts.length} stake keys`);
    for (const rewardAccount of availableRewardAccounts) {
      if (rewardAccount.credentialStatus === Cardano.StakeCredentialStatus.Registered) {
        // TODO: re-enable conway stake deregistration cert, after the conway hardfork
        certificates.push(Cardano.createStakeDeregistrationCert(rewardAccount.address /* , rewardAccount.deposit*/));
      }
    }
    this.partialTxBody = { ...this.partialTxBody, certificates };
    return rewardAccountsWithWeights;
  }

  async #resolveDatum(datumHash: Cardano.DatumHash) {
    // Lets check first if the datum was not added independently to the builder via addDatum.
    if (this.#knownDatums.has(datumHash)) return;

    if (!this.#dependencies.datumResolver) throw new Error('Cant resolve unknown datums. Datum resolver not set.');

    const datum = await this.#dependencies.datumResolver.resolve(datumHash);

    if (!datum) throw new Error(`Could not resolve datum with datum hash ${datumHash}`);

    this.#knownDatums.set(datumHash, datum);
  }

  async #resolveInput(input: Cardano.TxIn, inputs: Map<TxIdWithIndex, Cardano.Utxo>) {
    const inputId: TxIdWithIndex = `${input.txId}#${input.index}`;

    const resolvedInput = await this.#dependencies.inputResolver.resolveInput(input);

    if (!resolvedInput) throw new Error(`Could not resolve input ${inputId}`);

    if (resolvedInput.scriptReference) {
      const policyId = Serialization.Script.fromCore(resolvedInput.scriptReference).hash();

      this.#knownScripts.set(policyId, resolvedInput.scriptReference);
      this.#knownReferenceScripts.add(policyId);
    }

    const datum = resolvedInput.datum;

    if (datum) {
      if (Serialization.isDatumHash(datum)) {
        if (!this.#knownDatums.has(datum)) this.#unresolvedDatums.push(datum);
      } else {
        const hash = Serialization.PlutusData.fromCore(datum).hash();
        this.#knownDatums.set(hash, datum);
        this.#knownInlineDatums.add(hash); // We need to keep track of which datums are inline vs the ones provided
      }
    }

    inputs.set(inputId, [{ ...input, address: resolvedInput.address }, resolvedInput]);
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity
  #addScriptInput(input: Cardano.TxIn | Cardano.Utxo, scriptUnlockProps: ScriptUnlockProps) {
    let txId: TxIdWithIndex;

    if (Array.isArray(input)) {
      txId = `${input[0].txId}#${input[0].index}`;
      this.#preSelectedInputs.set(txId, input);

      if (input[1].datum) {
        const hash = Serialization.PlutusData.fromCore(input[1].datum).hash();
        this.#knownDatums.set(hash, input[1].datum);
        this.#knownInlineDatums.add(hash);
      }

      if (input[1].datumHash) {
        this.#unresolvedDatums.push(input[1].datumHash);
      }
    } else {
      txId = `${input.txId}#${input.index}`;

      if (
        !this.#unresolvedInputs.some(
          (unresolvedInput) => unresolvedInput.txId === input.txId && unresolvedInput.index === input.index
        )
      )
        this.#unresolvedInputs.push(input);
    }

    if (scriptUnlockProps.script) {
      const hash = Serialization.Script.fromCore(scriptUnlockProps.script).hash();
      this.#knownScripts.set(hash, scriptUnlockProps.script);
    }

    if (scriptUnlockProps.redeemer) {
      this.#knownRedeemers.spend?.set(txId, {
        data: scriptUnlockProps.redeemer,
        executionUnits: {
          memory: 0,
          steps: 0
        },
        index: 0,
        purpose: Cardano.RedeemerPurpose.spend
      });
    }

    if (scriptUnlockProps.datum) {
      if (Serialization.isDatumHash(scriptUnlockProps.datum)) {
        if (!this.#knownDatums.has(scriptUnlockProps.datum)) this.#unresolvedDatums.push(scriptUnlockProps.datum);
      } else {
        const hash = Serialization.PlutusData.fromCore(scriptUnlockProps.datum).hash();
        this.#knownDatums.set(hash, scriptUnlockProps.datum);
      }
    }
  }
}
