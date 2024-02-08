/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import * as Trezor from '@trezor/connect';
import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import {
  CardanoKeyConst,
  CommunicationType,
  KeyAgentBase,
  KeyAgentDependencies,
  KeyAgentType,
  SerializableTrezorKeyAgentData,
  SignBlobResult,
  SignTransactionContext,
  TrezorConfig,
  errors,
  util
} from '@cardano-sdk/key-management';
import { txToTrezor } from './transformers/tx';
import TrezorConnectWeb from '@trezor/connect-web';

const TrezorConnectNode = Trezor.default;

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
}

export interface CreateTrezorKeyAgentProps {
  chainId: Cardano.ChainId;
  accountIndex?: number;
  trezorConfig: TrezorConfig;
}

export type TrezorConnectInstanceType = typeof TrezorConnectNode | typeof TrezorConnectWeb;

const getTrezorConnect = (communicationType: CommunicationType): TrezorConnectInstanceType =>
  communicationType === CommunicationType.Node ? TrezorConnectNode : TrezorConnectWeb;

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

  constructor({ isTrezorInitialized, ...serializableData }: TrezorKeyAgentProps, dependencies: KeyAgentDependencies) {
    super({ ...serializableData, __typename: KeyAgentType.Trezor }, dependencies);
    if (!isTrezorInitialized) {
      this.isTrezorInitialized = TrezorKeyAgent.initializeTrezorTransport(serializableData.trezorConfig);
    }
    this.#communicationType = serializableData.trezorConfig.communicationType;
  }

  static async initializeTrezorTransport({
    manifest,
    communicationType,
    silentMode = false,
    lazyLoad = false
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
      if (deviceFeatures.payload.model !== 'T') {
        throw new errors.TransportError(`Trezor device model "${deviceFeatures.payload.model}" is not supported.`);
      }
      return deviceFeatures.payload;
    } catch (error) {
      throw transportTypedError(error);
    }
  }

  static async getXpub({ accountIndex, communicationType }: GetTrezorXpubProps): Promise<Crypto.Bip32PublicKeyHex> {
    try {
      await TrezorKeyAgent.checkDeviceConnection(communicationType);
      const derivationPath = `m/${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${accountIndex}'`;
      const trezorConnect = getTrezorConnect(communicationType);
      const extendedPublicKey = await trezorConnect.cardanoGetPublicKey({
        path: derivationPath,
        showOnTrezor: true
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
    { chainId, accountIndex = 0, trezorConfig }: CreateTrezorKeyAgentProps,
    dependencies: KeyAgentDependencies
  ) {
    const isTrezorInitialized = await TrezorKeyAgent.initializeTrezorTransport(trezorConfig);
    const extendedAccountPublicKey = await TrezorKeyAgent.getXpub({
      accountIndex,
      communicationType: trezorConfig.communicationType
    });
    return new TrezorKeyAgent(
      {
        accountIndex,
        chainId,
        extendedAccountPublicKey,
        isTrezorInitialized,
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
    { body, hash }: Cardano.TxBodyWithHash,
    { knownAddresses, txInKeyPathMap }: SignTransactionContext
  ): Promise<Cardano.Signatures> {
    try {
      await this.isTrezorInitialized;
      const trezorTxData = await txToTrezor(body, {
        accountIndex: this.accountIndex,
        chainId: this.chainId,
        knownAddresses,
        txInKeyPathMap
      });

      const signingMode = TrezorKeyAgent.matchSigningMode(trezorTxData);

      const trezorConnect = getTrezorConnect(this.#communicationType);
      const result = await trezorConnect.cardanoSignTransaction({
        ...trezorTxData,
        signingMode
      });

      const expectedPublicKeys = await Promise.all(
        util
          .ownSignatureKeyPaths(body, knownAddresses, txInKeyPathMap)
          .map((derivationPath) => this.derivePublicKey(derivationPath))
      );

      if (!result.success) {
        throw new errors.TransportError('Failed to export extended account public key', result.payload);
      }

      const signedData = result.payload;

      if (signedData.hash !== hash) {
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

  async exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex> {
    throw new NotImplementedError('Operation not supported!');
  }
}
