/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, NotImplementedError, coreToCml } from '@cardano-sdk/core';
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
import { ManagedFreeableScope } from '@cardano-sdk/util';
import { txToTrezor } from './transformers/tx';
import TrezorConnect, { Features } from 'trezor-connect';

export interface TrezorKeyAgentProps extends Omit<SerializableTrezorKeyAgentData, '__typename'> {
  isTrezorInitialized?: boolean;
}

export interface GetTrezorXpubProps {
  accountIndex: number;
}

export interface CreateTrezorKeyAgentProps {
  chainId: Cardano.ChainId;
  accountIndex?: number;
  trezorConfig: TrezorConfig;
}

const transportTypedError = (error?: any) =>
  new errors.AuthenticationError(
    'Trezor transport failed',
    new errors.TransportError('Trezor transport failed', error)
  );

export class TrezorKeyAgent extends KeyAgentBase {
  readonly isTrezorInitialized: Promise<boolean>;

  constructor({ isTrezorInitialized, ...serializableData }: TrezorKeyAgentProps, dependencies: KeyAgentDependencies) {
    super({ ...serializableData, __typename: KeyAgentType.Trezor }, dependencies);
    if (!isTrezorInitialized) {
      this.isTrezorInitialized = TrezorKeyAgent.initializeTrezorTransport(serializableData.trezorConfig);
    }
  }

  /**
   * @throws AuthenticationError
   */
  static async initializeTrezorTransport({
    manifest,
    communicationType,
    silentMode = false,
    lazyLoad = false
  }: TrezorConfig): Promise<boolean> {
    try {
      await TrezorConnect.init({
        // eslint-disable-next-line max-len
        // Set to "false" (default) if you want to start communication with bridge on application start (and detect connected device right away)
        // Set it to "true", then trezor-connect will not be initialized until you call some TrezorConnect.method()
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

  /**
   * @throws AuthenticationError
   */
  static async checkDeviceConnection(): Promise<Features> {
    const deviceFeatures = await TrezorConnect.getFeatures();
    if (!deviceFeatures.success) {
      throw transportTypedError(new errors.TransportError('Failed to get device', deviceFeatures.payload));
    }
    if (deviceFeatures.payload.model !== 'T') {
      throw transportTypedError(
        new errors.TransportError(`Trezor device model "${deviceFeatures.payload.model}" is not supported.`)
      );
    }
    return deviceFeatures.payload;
  }

  /**
   * @throws AuthenticationError
   */
  static async getXpub({ accountIndex }: GetTrezorXpubProps): Promise<Crypto.Bip32PublicKeyHex> {
    await TrezorKeyAgent.checkDeviceConnection();
    const derivationPath = `m/${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${accountIndex}'`;
    const extendedPublicKey = await TrezorConnect.cardanoGetPublicKey({
      path: derivationPath,
      showOnTrezor: true
    });
    if (!extendedPublicKey.success) {
      throw transportTypedError(
        new errors.TransportError('Failed to export extended account public key', extendedPublicKey.payload)
      );
    }
    return Crypto.Bip32PublicKeyHex(extendedPublicKey.payload.publicKey);
  }

  /**
   * @throws AuthenticationError
   */
  static async createWithDevice(
    { chainId, accountIndex = 0, trezorConfig }: CreateTrezorKeyAgentProps,
    dependencies: KeyAgentDependencies
  ) {
    const isTrezorInitialized = await TrezorKeyAgent.initializeTrezorTransport(trezorConfig);
    const extendedAccountPublicKey = await TrezorKeyAgent.getXpub({ accountIndex });
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

  async signTransaction({ body }: Cardano.TxBodyWithHash): Promise<Cardano.Signatures> {
    const scope = new ManagedFreeableScope();
    try {
      await this.isTrezorInitialized;
      const cslTxBody = coreToCml.txBody(scope, body);
      const trezorTxData = await txToTrezor({
        accountIndex: this.accountIndex,
        cardanoTxBody: body,
        chainId: this.chainId,
        cslTxBody,
        inputResolver: this.inputResolver,
        knownAddresses: this.knownAddresses
      });

      const result = await TrezorConnect.cardanoSignTransaction(trezorTxData);
      if (!result.success) {
        throw new errors.TransportError('Failed to export extended account public key', result.payload);
      }

      const signedData = result.payload;
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
    } finally {
      scope.dispose();
    }
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  async exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex> {
    throw new NotImplementedError('Operation not supported!');
  }
}
