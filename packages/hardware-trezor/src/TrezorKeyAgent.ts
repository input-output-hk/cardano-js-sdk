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
  TrezorConfig,
  errors
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
        knownAddresses: [],
        trezorConfig
      },
      dependencies
    );
  }

  /**
   * Gets the mode in which we want to sign the transaction.
   */
  static getSigningMode(tx: Omit<Trezor.CardanoSignTransaction, 'signingMode'>): Trezor.PROTO.CardanoTxSigningMode {
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

    // Represents an ordinary user transaction transferring funds.
    return Trezor.PROTO.CardanoTxSigningMode.ORDINARY_TRANSACTION;
  }

  async signTransaction(tx: Cardano.TxBodyWithHash): Promise<Cardano.Signatures> {
    try {
      await this.isTrezorInitialized;
      const trezorTxData = await txToTrezor({
        cardanoTxBody: tx.body,
        chainId: this.chainId,
        inputResolver: this.inputResolver,
        knownAddresses: this.knownAddresses
      });

      const signingMode = TrezorKeyAgent.getSigningMode(trezorTxData);

      const trezorConnect = getTrezorConnect(this.#communicationType);
      const result = await trezorConnect.cardanoSignTransaction({
        ...trezorTxData,
        signingMode
      });
      if (!result.success) {
        throw new errors.TransportError('Failed to export extended account public key', result.payload);
      }

      const signedData = result.payload;

      if (signedData.hash !== tx.hash) {
        throw new errors.HwMappingError('Trezor computed a different transaction id');
      }

      return new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>(
        await Promise.all(
          signedData.witnesses.map(async (witness) => {
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
