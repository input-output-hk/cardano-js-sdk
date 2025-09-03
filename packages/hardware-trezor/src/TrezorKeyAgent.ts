/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import * as Trezor from '@trezor/connect';
import { BIP32Path } from '@cardano-sdk/crypto';
import { Cardano, NotImplementedError, Serialization } from '@cardano-sdk/core';
import {
  CardanoKeyConst,
  CommunicationType,
  KeyAgentBase,
  KeyAgentDependencies,
  KeyAgentType,
  KeyPurpose,
  KeyRole,
  MasterKeyGeneration,
  SerializableTrezorKeyAgentData,
  SignBlobResult,
  SignTransactionContext,
  TrezorConfig,
  errors,
  util
} from '@cardano-sdk/key-management';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { HexBlob, areStringsEqualInConstantTime } from '@cardano-sdk/util';
import { txToTrezor } from './transformers/tx';
import _TrezorConnectWeb from '@trezor/connect-web';

const TrezorConnectNode = Trezor.default;
const TrezorConnectWeb = (_TrezorConnectWeb as any).default
  ? ((_TrezorConnectWeb as any).default as typeof _TrezorConnectWeb)
  : _TrezorConnectWeb;

const transportTypedError = (error?: any) =>
  new errors.AuthenticationError(
    'Trezor transport failed',
    new errors.TransportError('Trezor transport failed', error)
  );

export interface TrezorKeyAgentProps extends Omit<SerializableTrezorKeyAgentData, '__typename'> {
  isTrezorInitialized?: boolean;
}

export interface GetTrezorXpubProps {
  accountIndex: number;
  communicationType: CommunicationType;
  purpose: KeyPurpose;
  derivationType?: MasterKeyGeneration;
}

export interface CreateTrezorKeyAgentProps {
  chainId: Cardano.ChainId;
  accountIndex?: number;
  trezorConfig: TrezorConfig;
  purpose?: KeyPurpose;
}

export type TrezorConnectInstanceType = typeof TrezorConnectNode | typeof TrezorConnectWeb;

const getTrezorConnect = (communicationType: CommunicationType): TrezorConnectInstanceType =>
  communicationType === CommunicationType.Node ? TrezorConnectNode : TrezorConnectWeb;

/** Maps MasterKeyGeneration string literals to Trezor CardanoDerivationType numeric values */
const mapDerivationType = (derivationType: MasterKeyGeneration): Trezor.PROTO.CardanoDerivationType => {
  switch (derivationType) {
    case 'ICARUS':
      return Trezor.PROTO.CardanoDerivationType.ICARUS;
    case 'ICARUS_TREZOR':
      return Trezor.PROTO.CardanoDerivationType.ICARUS_TREZOR;
    case 'LEDGER':
      return Trezor.PROTO.CardanoDerivationType.LEDGER;
    default:
      throw new Error(`Unsupported derivation type: ${derivationType}`);
  }
};

const stakeCredentialCert = (certificateType: Trezor.PROTO.CardanoCertificateType): boolean =>
  certificateType === Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION ||
  certificateType === Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION ||
  certificateType === Trezor.PROTO.CardanoCertificateType.STAKE_DELEGATION;

const containsOnlyScriptHashCredentials = (tx: Omit<Trezor.CardanoSignTransaction, 'signingMode'>): boolean => {
  if (tx.certificates) {
    for (const cert of tx.certificates) {
      if (!stakeCredentialCert(cert.type) || !cert.scriptHash) return false;
    }
  }
  return !tx.withdrawals?.some((withdrawal) => !withdrawal.scriptHash);
};

const multiSigWitnessPaths: BIP32Path[] = [
  util.accountKeyDerivationPathToBip32Path(0, { index: 0, role: KeyRole.External }, KeyPurpose.MULTI_SIG)
];

const isMultiSig = (tx: Omit<Trezor.CardanoSignTransaction, 'signingMode'>): boolean => {
  const allThirdPartyInputs = !tx.inputs.some((input) => input.path);
  // Trezor doesn't allow change outputs to address controlled by your keys and instead you have to use script address for change out
  const allThirdPartyOutputs = !tx.outputs.some((out) => 'addressParameters' in out);

  return (
    allThirdPartyInputs &&
    allThirdPartyOutputs &&
    !tx.collateralInputs &&
    !tx.collateralReturn &&
    !tx.totalCollateral &&
    !tx.referenceInputs &&
    containsOnlyScriptHashCredentials(tx)
  );
};

export class TrezorKeyAgent extends KeyAgentBase {
  readonly isTrezorInitialized: Promise<boolean>;
  readonly #communicationType: CommunicationType;
  readonly #trezorConfig: TrezorConfig;

  constructor({ isTrezorInitialized, ...serializableData }: TrezorKeyAgentProps, dependencies: KeyAgentDependencies) {
    super({ ...serializableData, __typename: KeyAgentType.Trezor }, dependencies);
    if (!isTrezorInitialized) {
      this.isTrezorInitialized = TrezorKeyAgent.initializeTrezorTransport(serializableData.trezorConfig);
    }
    this.#communicationType = serializableData.trezorConfig.communicationType;
    this.#trezorConfig = serializableData.trezorConfig;
  }

  get trezorConfig(): TrezorConfig {
    return this.#trezorConfig;
  }

  static async initializeTrezorTransport({
    manifest,
    communicationType,
    silentMode = false,
    lazyLoad = false,
    shouldHandlePassphrase = false
  }: TrezorConfig): Promise<boolean> {
    const trezorConnect = getTrezorConnect(communicationType);
    try {
      await trezorConnect.init({
        // eslint-disable-next-line max-len
        // Set to "false" (default) if you want to start communication with bridge on application start (and detect connected device right away)
        // Set it to "true", then trezor-connect will not be initialized until you call some trezorConnect.method()
        // This is useful when you don't know if you are dealing with Trezor user
        lazyLoad: communicationType !== CommunicationType.Node && lazyLoad,
        // Manifest is required from Trezor Connect 7:
        // https://github.com/trezor/connect/blob/develop/docs/index.md#trezor-connect-manifest
        manifest,
        // Show Trezor Suite popup. Disabled for node based apps
        popup: communicationType !== CommunicationType.Node && !silentMode
      });

      if (shouldHandlePassphrase) {
        trezorConnect.on(Trezor.UI_EVENT, (event) => {
          // React on ui-request_passphrase event
          if (event.type === Trezor.UI.REQUEST_PASSPHRASE && event.payload.device) {
            trezorConnect.uiResponse({
              payload: {
                passphraseOnDevice: true,
                save: true,
                value: ''
              },
              type: Trezor.UI.RECEIVE_PASSPHRASE
            });
          }
        });
      }

      return true;
    } catch (error: any) {
      if (error.code === 'Init_AlreadyInitialized') return true;
      throw transportTypedError(error);
    }
  }

  static async checkDeviceConnection(communicationType: CommunicationType): Promise<Trezor.Features> {
    const trezorConnect = getTrezorConnect(communicationType);
    try {
      const deviceFeatures = await trezorConnect.getFeatures();
      if (!deviceFeatures.success) {
        throw new errors.TransportError('Failed to get device', deviceFeatures.payload);
      }
      return deviceFeatures.payload;
    } catch (error) {
      throw transportTypedError(error);
    }
  }

  static async getXpub({
    accountIndex,
    communicationType,
    purpose,
    derivationType
  }: GetTrezorXpubProps): Promise<Crypto.Bip32PublicKeyHex> {
    try {
      await TrezorKeyAgent.checkDeviceConnection(communicationType);
      const derivationPath = `m/${purpose}'/${CardanoKeyConst.COIN_TYPE}'/${accountIndex}'`;
      const trezorConnect = getTrezorConnect(communicationType);
      const trezorDerivationType = derivationType ? mapDerivationType(derivationType) : undefined;

      const extendedPublicKey = await trezorConnect.cardanoGetPublicKey({
        path: derivationPath,
        showOnTrezor: true,
        ...(derivationType && {
          derivationType: trezorDerivationType
        })
      });
      if (!extendedPublicKey.success) {
        throw new errors.TransportError('Failed to export extended account public key', extendedPublicKey.payload);
      }
      return Crypto.Bip32PublicKeyHex(extendedPublicKey.payload.publicKey);
    } catch (error: any) {
      throw transportTypedError(error);
    }
  }

  static async createWithDevice(
    { chainId, accountIndex = 0, trezorConfig, purpose = KeyPurpose.STANDARD }: CreateTrezorKeyAgentProps,
    dependencies: KeyAgentDependencies
  ) {
    const isTrezorInitialized = await TrezorKeyAgent.initializeTrezorTransport(trezorConfig);
    const extendedAccountPublicKey = await TrezorKeyAgent.getXpub({
      accountIndex,
      communicationType: trezorConfig.communicationType,
      derivationType: trezorConfig.derivationType,
      purpose
    });
    return new TrezorKeyAgent(
      {
        accountIndex,
        chainId,
        extendedAccountPublicKey,
        isTrezorInitialized,
        purpose,
        trezorConfig
      },
      dependencies
    );
  }

  /**
   * Gets the mode in which we want to sign the transaction.
   * This function will always return the first matching type depending on the provided data
   * Data is further checked on the Trezor side
   */
  static matchSigningMode(tx: Omit<Trezor.CardanoSignTransaction, 'signingMode'>): Trezor.PROTO.CardanoTxSigningMode {
    if (tx.certificates) {
      for (const cert of tx.certificates) {
        // Represents pool registration from the perspective of a pool owner.
        if (
          cert.type === Trezor.PROTO.CardanoCertificateType.STAKE_POOL_REGISTRATION &&
          cert.poolParameters?.owners.some((owner) => owner.stakingKeyPath)
        )
          return Trezor.PROTO.CardanoTxSigningMode.POOL_REGISTRATION_AS_OWNER;
      }
    }

    /** Plutus signing mode has a broader usage e.g. multisig tx that contains referenceInputs is marked as plutus */
    if (tx.collateralInputs || tx.collateralReturn || tx.totalCollateral || tx.referenceInputs) {
      return Trezor.PROTO.CardanoTxSigningMode.PLUTUS_TRANSACTION;
    }

    // Represents a transaction controlled by native scripts.
    // Like an ordinary transaction, but stake credentials and all similar elements are given as script hashes
    if (isMultiSig(tx)) {
      return Trezor.PROTO.CardanoTxSigningMode.MULTISIG_TRANSACTION;
    }

    // Represents an ordinary user transaction transferring funds.
    return Trezor.PROTO.CardanoTxSigningMode.ORDINARY_TRANSACTION;
  }

  async signTransaction(
    txBody: Serialization.TransactionBody,
    { knownAddresses, txInKeyPathMap, scripts }: SignTransactionContext
  ): Promise<Cardano.Signatures> {
    try {
      await this.isTrezorInitialized;
      const body = txBody.toCore();
      const hash = txBody.hash() as unknown as HexBlob;

      const outputsFormat = txBody
        .outputs()
        .map((out) =>
          out.isBabbageOutput()
            ? Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE
            : Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
        );
      const collateralReturnFormat = txBody.collateralReturn()?.isBabbageOutput()
        ? Trezor.PROTO.CardanoTxOutputSerializationFormat.MAP_BABBAGE
        : Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY;

      const trezorTxData = await txToTrezor(body, {
        accountIndex: this.accountIndex,
        chainId: this.chainId,
        collateralReturnFormat,
        knownAddresses,
        outputsFormat,
        tagCborSets: txBody.hasTaggedSets(),
        txInKeyPathMap
      });

      const signingMode = TrezorKeyAgent.matchSigningMode(trezorTxData);

      const trezorConnect = getTrezorConnect(this.#communicationType);
      const result = await trezorConnect.cardanoSignTransaction({
        ...trezorTxData,
        ...(signingMode === Trezor.PROTO.CardanoTxSigningMode.MULTISIG_TRANSACTION && {
          additionalWitnessRequests: multiSigWitnessPaths
        }),
        signingMode,
        ...(this.trezorConfig.derivationType
          ? {
              derivationType: mapDerivationType(this.trezorConfig.derivationType)
            }
          : {})
      });

      const expectedPublicKeys = await Promise.all(
        util
          .ownSignatureKeyPaths(body, knownAddresses, txInKeyPathMap, undefined, scripts)
          .map((derivationPath) => this.derivePublicKey(derivationPath))
      );

      if (!result.success) {
        throw new errors.TransportError('Failed to export extended account public key', result.payload);
      }

      const signedData = result.payload;

      if (!areStringsEqualInConstantTime(signedData.hash, hash)) {
        throw new errors.HwMappingError('Trezor computed a different transaction id');
      }

      return new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>(
        await Promise.all(
          signedData.witnesses
            .filter((witness) => expectedPublicKeys.includes(Crypto.Ed25519PublicKeyHex(witness.pubKey)))
            .map(async (witness) => {
              const publicKey = Crypto.Ed25519PublicKeyHex(witness.pubKey);
              const signature = Crypto.Ed25519SignatureHex(witness.signature);
              return [publicKey, signature] as const;
            })
        )
      );
    } catch (error: any) {
      if (error.innerError.code === 'Failure_ActionCancelled') {
        throw new errors.AuthenticationError('Transaction signing aborted', error);
      }
      throw transportTypedError(error);
    }
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  async signCip8Data(): Promise<Cip30DataSignature> {
    throw new NotImplementedError('signCip8Data');
  }

  async exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex> {
    throw new NotImplementedError('Operation not supported!');
  }
}
