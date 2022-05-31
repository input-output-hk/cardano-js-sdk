/* eslint-disable @typescript-eslint/no-explicit-any */
import { AuthenticationError, TransportError } from './errors';
import { Cardano, NotImplementedError, coreToCsl } from '@cardano-sdk/core';
import { CardanoKeyConst, txToTrezor } from './util';
import {
  CommunicationType,
  KeyAgentType,
  SerializableTrezorKeyAgentData,
  SignBlobResult,
  SignTransactionOptions,
  TrezorConfig
} from './types';
import { KeyAgentBase } from './KeyAgentBase';
import { TxInternals } from '../Transaction';
import TrezorConnect, { Features } from 'trezor-connect';

export interface TrezorKeyAgentProps extends Omit<SerializableTrezorKeyAgentData, '__typename'> {
  isTrezorInitialized?: boolean;
}

export interface GetTrezorXpubProps {
  accountIndex: number;
}

export interface CreateTrezorKeyAgentProps {
  networkId: Cardano.NetworkId;
  accountIndex?: number;
  protocolMagic: Cardano.NetworkMagic;
  trezorConfig: TrezorConfig;
}

const transportTypedError = (error?: any) =>
  new AuthenticationError('Trezor transport failed', new TransportError('Trezor transport failed', error));

export class TrezorKeyAgent extends KeyAgentBase {
  readonly isTrezorInitialized: Promise<boolean>;
  readonly #protocolMagic: Cardano.NetworkMagic;

  constructor({ isTrezorInitialized, ...serializableData }: TrezorKeyAgentProps) {
    super({ ...serializableData, __typename: KeyAgentType.Trezor });
    this.#protocolMagic = serializableData.protocolMagic;
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
    try {
      const deviceFeatures = await TrezorConnect.getFeatures();
      if (!deviceFeatures.success) {
        throw new TransportError('Failed to get device', deviceFeatures.payload);
      }
      if (deviceFeatures.payload.model !== 'T') {
        throw new TransportError(`Trezor device model "${deviceFeatures.payload.model}" is not supported.`);
      }
      return deviceFeatures.payload;
    } catch (error) {
      throw transportTypedError(error);
    }
  }

  /**
   * @throws AuthenticationError
   */
  static async getXpub({ accountIndex }: GetTrezorXpubProps): Promise<Cardano.Bip32PublicKey> {
    try {
      await TrezorKeyAgent.checkDeviceConnection();
      const derivationPath = `m/${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${accountIndex}'`;
      const extendedPublicKey = await TrezorConnect.cardanoGetPublicKey({
        path: derivationPath,
        showOnTrezor: true
      });
      if (!extendedPublicKey.success) {
        throw new TransportError('Failed to export extended account public key', extendedPublicKey.payload);
      }
      return Cardano.Bip32PublicKey(extendedPublicKey.payload.publicKey);
    } catch (error: any) {
      throw transportTypedError(error);
    }
  }

  /**
   * @throws AuthenticationError
   */
  static async createWithDevice({
    networkId,
    accountIndex = 0,
    protocolMagic,
    trezorConfig
  }: CreateTrezorKeyAgentProps) {
    const isTrezorInitialized = await TrezorKeyAgent.initializeTrezorTransport(trezorConfig);
    const extendedAccountPublicKey = await TrezorKeyAgent.getXpub({
      accountIndex
    });
    return new TrezorKeyAgent({
      accountIndex,
      extendedAccountPublicKey,
      isTrezorInitialized,
      knownAddresses: [],
      networkId,
      protocolMagic,
      trezorConfig
    });
  }

  async signTransaction(
    { body }: TxInternals,
    { inputAddressResolver }: SignTransactionOptions
  ): Promise<Cardano.Signatures> {
    try {
      await this.isTrezorInitialized;
      const cslTxBody = coreToCsl.txBody(body);
      const trezorTxData = await txToTrezor({
        accountIndex: this.accountIndex,
        cslTxBody,
        inputAddressResolver,
        knownAddresses: this.knownAddresses,
        networkId: this.networkId,
        protocolMagic: this.#protocolMagic
      });

      const result = await TrezorConnect.cardanoSignTransaction(trezorTxData);
      if (!result.success) {
        throw new TransportError('Failed to export extended account public key', result.payload);
      }

      const signedData = result.payload;
      return new Map<Cardano.Ed25519PublicKey, Cardano.Ed25519Signature>(
        await Promise.all(
          signedData.witnesses.map(async (witness) => {
            const publicKey = Cardano.Ed25519PublicKey(witness.pubKey);
            const signature = Cardano.Ed25519Signature(witness.signature);
            return [publicKey, signature] as const;
          })
        )
      );
    } catch (error: any) {
      if (error.innerError.code === 'Failure_ActionCancelled') {
        throw new AuthenticationError('Transaction signing aborted', error);
      }
      throw transportTypedError(error);
    }
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  async exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey> {
    throw new NotImplementedError('Operation not supported!');
  }
}
