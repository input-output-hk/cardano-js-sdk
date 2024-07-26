import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountKeyDerivationPath,
  AsyncKeyAgent,
  KeyPurpose,
  SignDataContext,
  SignTransactionContext,
  TransactionSigner,
  WitnessOptions,
  WitnessedTx,
  Witnesser,
  util as keyManagementUtil
} from '@cardano-sdk/key-management';

import { AnyBip32Wallet, AnyWallet, ScriptWallet, WalletId, WalletType } from './types';
import { Cardano, Serialization, TxCBOR } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { InitializeTxWitness } from '@cardano-sdk/tx-construction';
import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';
import { SigningCoordinatorSignApi } from './SigningCoordinator';
import { WalletManagerApi } from './walletManager.types';
import { WalletRepositoryApi } from './WalletRepository';
import { firstValueFrom } from 'rxjs';

const SCRIPT_TYPE_NOT_SUPPORTED =
  'Only native scripts of types: RequireAllOf, RequireAnyOf and RequireNOf are supported by this script witnesser';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Crypto.Ed25519PublicKeyHex(Array.from({ length: 64 }).map(randomHexChar).join(''));

const isBip32Wallet = <T extends {}, U extends {}>(wallet: AnyWallet<T, U>): wallet is AnyBip32Wallet<T, U> =>
  wallet.type === WalletType.InMemory || wallet.type === WalletType.Ledger || wallet.type === WalletType.Trezor;

/**
 * Merges two arrays of items into a single array, avoiding duplication of items.
 *
 * @param arr1 The first array of items.
 * @param arr2 The second array of items.
 * @param serializeFn The function to serialize the items.
 * @returns The merged array of items.
 * @private
 */
const mergeArrays = <T>(arr1: T[], arr2: T[], serializeFn: (item: T) => HexBlob): T[] => {
  const serializedItems = new Set(arr1.map(serializeFn));
  const mergedArray = [...arr1];

  for (const item of arr2) {
    const serializedItem = serializeFn(item);
    if (!serializedItems.has(serializedItem)) {
      mergedArray.push(item);
      serializedItems.add(serializedItem);
    }
  }
  return mergedArray;
};

/**
 * Merges two witnesses into a single one avoiding duplication of witness data.
 *
 * @param lhs The left-hand side witness.
 * @param rhs The right-hand side witness.
 * @returns The merged witness.
 * @private
 */
// eslint-disable-next-line complexity
const mergeWitnesses = (lhs: Cardano.Witness, rhs?: InitializeTxWitness): Cardano.Witness => {
  if (!rhs) {
    if (!lhs.signatures) lhs.signatures = new Map();
    return lhs as unknown as Cardano.Witness;
  }
  const mergedSignatures = new Map([...(lhs.signatures ?? []), ...(rhs.signatures ?? [])]);

  // Merge arrays of complex objects
  const mergedRedeemers = mergeArrays(lhs.redeemers || [], rhs.redeemers || [], (elem) =>
    Serialization.Redeemer.fromCore(elem).toCbor()
  );

  const mergedScripts = mergeArrays(lhs.scripts || [], rhs.scripts || [], (elem) =>
    Serialization.Script.fromCore(elem).toCbor()
  );

  const mergedBootstrap = mergeArrays(lhs.bootstrap || [], rhs.bootstrap || [], (elem) =>
    Serialization.BootstrapWitness.fromCore(elem).toCbor()
  );

  const mergedDatums = mergeArrays(lhs.datums || [], rhs.datums || [], (elem) =>
    Serialization.PlutusData.fromCore(elem).toCbor()
  );

  return {
    bootstrap: mergedBootstrap,
    datums: mergedDatums,
    redeemers: mergedRedeemers,
    scripts: mergedScripts,
    signatures: mergedSignatures
  };
};

/**
 * Predicate that returns true if the given script is a native script of the supported types.
 *
 * @param script The script to check.
 */
const isScriptSupported = (
  script: Cardano.Script
): script is Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript => {
  if (!Cardano.isNativeScript(script)) return false;

  switch (script.kind) {
    case Cardano.NativeScriptKind.RequireAllOf:
    case Cardano.NativeScriptKind.RequireAnyOf:
    case Cardano.NativeScriptKind.RequireNOf:
      return true;
    default:
      return false;
  }
};

const getTxWithStubWitness = async (
  body: Cardano.TxBody,
  paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
  stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
  extraSigners?: TransactionSigner[],
  witness?: Cardano.Witness
): Promise<Cardano.Witness> => {
  const mockSignature = Crypto.Ed25519SignatureHex(
    // eslint-disable-next-line max-len
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
  );

  // Depending on the script, we need to provide a different number of signatures, however we will always compute the
  // transaction witness size with the maximum number of signatures possible since we don't know how many participants will want to sing
  // the transaction.
  const withdrawalSignatures = body.withdrawals && body.withdrawals.length > 0 ? stakingScript.scripts.length : 0;

  const paymentSignatures = paymentScript.scripts.length;
  const totalSignature = withdrawalSignatures + paymentSignatures + (extraSigners?.length || 0);
  const signatureMap = new Map();

  for (let i = 0; i < totalSignature; ++i) signatureMap.set(randomPublicKey(), mockSignature);

  const stubWitness = mergeWitnesses({ scripts: [], signatures: new Map() }, witness);

  stubWitness.signatures = new Map([
    ...(stubWitness.signatures ? stubWitness.signatures.entries() : []),
    ...signatureMap.entries()
  ]);
  stubWitness.scripts = [...(stubWitness.scripts ?? []), paymentScript, stakingScript];

  return stubWitness;
};

// eslint-disable-next-line complexity
const requiresStakingWitness = (
  body: Serialization.TransactionBody,
  stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
  networkId: Cardano.NetworkId
): boolean => {
  const hash = Serialization.NativeScript.fromCore(stakingScript).hash();
  const rewardAccount = Cardano.RewardAccount.fromCredential(
    { hash, type: Cardano.CredentialType.ScriptHash },
    networkId
  );
  const withdrawals = body.withdrawals() ?? new Map();
  const certificates = (body.certs()?.values() ?? []).map((certificate) => certificate.toCore());

  if (withdrawals.size > 0 && withdrawals.has((key: Cardano.RewardAccount) => key === rewardAccount)) return true;

  for (const cert of certificates) {
    switch (cert.__typename) {
      case Cardano.CertificateType.VoteDelegation:
      case Cardano.CertificateType.StakeVoteDelegation:
      case Cardano.CertificateType.StakeRegistrationDelegation:
      case Cardano.CertificateType.VoteRegistrationDelegation:
      case Cardano.CertificateType.StakeVoteRegistrationDelegation:
      case Cardano.CertificateType.Registration:
      case Cardano.CertificateType.Unregistration:
      case Cardano.CertificateType.StakeDeregistration:
      case Cardano.CertificateType.StakeDelegation: {
        if (cert.stakeCredential.type === Cardano.CredentialType.ScriptHash && hash === cert.stakeCredential.hash)
          return true;
      }
    }
  }
  return false;
};

export const walletManagerChannel = (channelName: string) => `${channelName}-wallet-manager`;
export const walletChannel = (channelName: string) => `${walletManagerChannel(channelName)}-wallet`;
export const repositoryChannel = (channelName: string) => `${channelName}-wallet-repository`;

export const walletManagerProperties: RemoteApiProperties<WalletManagerApi> = {
  activate: RemoteApiPropertyType.MethodReturningPromise,
  activeWalletId$: RemoteApiPropertyType.HotObservable,
  deactivate: RemoteApiPropertyType.MethodReturningPromise,
  destroyData: RemoteApiPropertyType.MethodReturningPromise,
  switchNetwork: RemoteApiPropertyType.MethodReturningPromise
};

/**
 * Predicate that returns true if the given object is a script.
 *
 * @param object The object to check.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isScript = (object: any): object is Cardano.Script =>
  object?.__type === Cardano.ScriptType.Plutus || object?.__type === Cardano.ScriptType.Native;

/**
 * Predicate that returns true if the given object is a public key.
 *
 * @param object The object to check.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isBip32PublicKeyHex = (object: any): object is Crypto.Bip32PublicKeyHex =>
  // eslint-disable-next-line wrap-regex
  typeof object === 'string' && object.length === 128 && /^[\da-f]+$/i.test(object);

/** Compute a unique walletId from the script */
export const getScriptWalletId = async (script: Cardano.Script): Promise<string> =>
  Serialization.Script.fromCore(script).hash().slice(0, 32);

/**
 * Compute a unique walletId from the extended account public key.
 *
 * @param pubKey The extended account public key.
 */
export const getExtendedAccountPublicKeyWalletId = async (pubKey: Crypto.Bip32PublicKeyHex): Promise<string> =>
  Crypto.blake2b(Crypto.blake2b.BYTES_MIN).update(Buffer.from(pubKey, 'hex')).digest('hex');

/**
 * Compute a unique walletId from the keyAgent.
 *
 * @param keyAgent The key agent.
 */
export const getKeyAgentWalletId = async (keyAgent: AsyncKeyAgent): Promise<string> =>
  getExtendedAccountPublicKeyWalletId(await keyAgent.getExtendedAccountPublicKey());

/** Compute a unique walletId. */
export const getWalletId = async (
  walletIdParam: AsyncKeyAgent | Cardano.Script | Crypto.Bip32PublicKeyHex
): Promise<string> => {
  if (isScript(walletIdParam)) return getScriptWalletId(walletIdParam);

  if (isBip32PublicKeyHex(walletIdParam)) return getExtendedAccountPublicKeyWalletId(walletIdParam);

  return getKeyAgentWalletId(walletIdParam);
};

const createScriptWitness = async <WalletMetadata extends {}, AccountMetadata extends {}>(
  wallet: ScriptWallet<WalletMetadata>,
  chainId: Cardano.ChainId,
  signingCoordinatorApi: SigningCoordinatorSignApi<WalletMetadata, AccountMetadata>,
  walletRepository: WalletRepositoryApi<WalletMetadata, AccountMetadata>,
  tx: Serialization.Transaction,
  context: SignTransactionContext,
  options?: WitnessOptions
  // eslint-disable-next-line max-params
) => {
  if (!isScriptSupported(wallet.paymentScript) || !isScriptSupported(wallet.stakingScript))
    throw new Error(SCRIPT_TYPE_NOT_SUPPORTED);

  const paymentKeysPaths = wallet.ownSigners.map((signer) => signer.paymentScriptKeyPath);
  const stakingKeysPaths = wallet.ownSigners.map((signer) => signer.stakingScriptKeyPath);
  const paths = [
    ...paymentKeysPaths,
    ...(requiresStakingWitness(tx.body(), wallet.stakingScript, chainId.networkId) ? stakingKeysPaths : [])
  ];
  const wallets = await firstValueFrom(walletRepository.wallets$);

  let signatures;
  for (const signer of wallet.ownSigners) {
    const signerWallet = wallets.find((w) => w.walletId === signer.walletId);

    if (!signerWallet) throw new Error(`Wallet with id ${signer.walletId} not found`);
    if (!isBip32Wallet(signerWallet)) throw new Error('Only Bip32 wallets are supported');

    const signingResult = await signingCoordinatorApi.signTransaction(
      {
        options: { ...options, additionalKeyPaths: [...(options?.additionalKeyPaths ?? []), ...paths] },
        signContext: context,
        tx: tx.toCbor()
      },
      {
        accountIndex: signer.accountIndex,
        chainId,
        purpose: signer.purpose,
        wallet: signerWallet
      }
    );

    signatures = [...(signatures ? signatures.entries() : []), ...signingResult.entries()];
  }

  return {
    scripts: [wallet.paymentScript, wallet.stakingScript],
    signatures: signatures ? new Map(signatures) : new Map()
  };
};

/** Builds the witnesser for the given Bip32 wallet. */
export const buildBip32Witnesser = <WalletMetadata extends { name: string }, AccountMetadata extends { name: string }>(
  wallet: AnyBip32Wallet<WalletMetadata, AccountMetadata>,
  _walletId: WalletId,
  chainId: Cardano.ChainId,
  signingCoordinatorApi: SigningCoordinatorSignApi<WalletMetadata, AccountMetadata>,
  accountIndex?: number
): Witnesser =>
  <Witnesser>{
    signBlob: async (derivationPath: AccountKeyDerivationPath, blob: HexBlob, context: SignDataContext) =>
      await signingCoordinatorApi.signData(
        {
          blob,
          derivationPath,
          signContext: context
        },
        {
          accountIndex: accountIndex!,
          chainId,
          purpose: KeyPurpose.STANDARD,
          wallet
        }
      ),
    async witness(
      tx: Serialization.Transaction,
      context: SignTransactionContext,
      options?: WitnessOptions
    ): Promise<WitnessedTx> {
      const coreTx = tx.toCore();
      const hash = tx.getId();
      const signatures =
        options?.stubSign !== undefined && options.stubSign
          ? await keyManagementUtil.stubSignTransaction({
              context,
              signTransactionOptions: options,
              txBody: coreTx.body
            })
          : await signingCoordinatorApi.signTransaction(
              {
                options,
                signContext: context,
                tx: tx.toCbor()
              },
              {
                accountIndex: accountIndex!,
                chainId,
                purpose: KeyPurpose.STANDARD,
                wallet
              }
            );

      const transaction = {
        auxiliaryData: coreTx.auxiliaryData,
        body: coreTx.body,
        id: hash,
        isValid: tx.isValid(),
        witness: {
          ...coreTx.witness,
          signatures: new Map([...signatures.entries(), ...(coreTx.witness?.signatures?.entries() || [])])
        }
      };

      return {
        cbor: TxCBOR.serialize(transaction),
        context: {
          handleResolutions: context.handleResolutions ?? []
        },
        tx: transaction
      };
    }
  };

/** Builds the witnesser for the given script wallet. */
export const buildNativeScriptWitnesser = <
  WalletMetadata extends { name: string },
  AccountMetadata extends { name: string }
>(
  wallet: ScriptWallet<WalletMetadata>,
  _walletId: WalletId,
  chainId: Cardano.ChainId,
  signingCoordinatorApi: SigningCoordinatorSignApi<WalletMetadata, AccountMetadata>,
  walletRepository: WalletRepositoryApi<WalletMetadata, AccountMetadata>
  // eslint-disable-next-line sonarjs/cognitive-complexity
): Witnesser => {
  if (!isScriptSupported(wallet.paymentScript) || !isScriptSupported(wallet.stakingScript))
    throw new Error(SCRIPT_TYPE_NOT_SUPPORTED);

  return {
    signBlob: async () => {
      throw new Error('signBlob is not supported by this witnesser');
    },
    async witness(
      tx: Serialization.Transaction,
      context: SignTransactionContext,
      options?: WitnessOptions
    ): Promise<WitnessedTx> {
      if (!isScriptSupported(wallet.paymentScript) || !isScriptSupported(wallet.stakingScript))
        throw new Error(SCRIPT_TYPE_NOT_SUPPORTED);

      let witness;
      const coreTx = tx.toCore();
      const hash = tx.getId();

      if (options?.stubSign !== undefined && options.stubSign) {
        witness = await getTxWithStubWitness(
          coreTx.body,
          wallet.paymentScript,
          wallet.stakingScript,
          options?.extraSigners
        );
      } else {
        witness = await createScriptWitness(
          wallet,
          chainId,
          signingCoordinatorApi,
          walletRepository,
          new Serialization.Transaction(
            Serialization.TransactionBody.fromCore(coreTx.body),
            new Serialization.TransactionWitnessSet()
          ),
          context,
          options
        );

        const extraSignatures: Cardano.Signatures = new Map();
        if (options?.extraSigners) {
          for (const extraSigner of options?.extraSigners) {
            const extraSignature = await extraSigner.sign({
              body: coreTx.body,
              hash
            });
            extraSignatures.set(extraSignature.pubKey, extraSignature.signature);
          }
        }

        witness.signatures = new Map([
          ...(witness.signatures ? witness.signatures.entries() : []),
          ...extraSignatures.entries()
        ]);
      }

      const transaction = {
        auxiliaryData: coreTx.auxiliaryData,
        body: coreTx.body,
        id: hash,
        isValid: tx.isValid(),
        witness: mergeWitnesses(coreTx.witness, witness)
      };

      return {
        cbor: TxCBOR.serialize(transaction),
        context: {
          handleResolutions: context.handleResolutions ?? []
        },
        tx: transaction
      };
    }
  };
};
