/* eslint-disable @typescript-eslint/no-explicit-any */
import { AuthenticationError, TransportError } from './errors';
import { Cardano, NotImplementedError, coreToCsl } from '@cardano-sdk/core';
import {
  CommunicationType,
  KeyAgentType,
  SerializableLedgerKeyAgentData,
  SignBlobResult,
  SignTransactionOptions,
  TransportType
} from './types';
import { KeyAgentBase } from './KeyAgentBase';
import { TxInternals } from '../Transaction';
import { txToLedger } from './util';
import DeviceConnection, { GetVersionResponse, HARDENED, utils } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import TransportWebHID from '@ledgerhq/hw-transport-webhid';
import type Transport from '@ledgerhq/hw-transport';

export interface LedgerKeyAgentProps extends Omit<SerializableLedgerKeyAgentData, '__typename'> {
  deviceConnection?: DeviceConnection;
}

export interface CreateWithDevice {
  networkId: Cardano.NetworkId;
  accountIndex?: number;
  communicationType: CommunicationType;
  deviceConnection?: DeviceConnection | null;
}

export interface GetXpubProps {
  deviceConnection?: DeviceConnection;
  communicationType: CommunicationType;
  accountIndex: number;
}

export interface CreateTransportProps {
  communicationType: CommunicationType;
  activeTransport?: TransportType;
  devicePath?: string;
}

const transportTypedError = (error?: any) =>
  new AuthenticationError('Transport failed', new TransportError('Transport failed', error));

export class LedgerKeyAgent extends KeyAgentBase {
  readonly deviceConnection?: DeviceConnection;
  readonly #communicationType: CommunicationType;

  constructor({ deviceConnection, ...serializableData }: LedgerKeyAgentProps) {
    super({ ...serializableData, __typename: KeyAgentType.Ledger });
    this.deviceConnection = deviceConnection;
    this.#communicationType = serializableData.communicationType;
  }

  /**
   * @throws TransportError
   */
  static async getHidDeviceList(): Promise<string[]> {
    try {
      return await TransportNodeHid.list();
    } catch (error) {
      throw new TransportError('Cannot fetch device list', error);
    }
  }

  /**
   * @throws TransportError
   */
  static async createTransport({
    communicationType,
    activeTransport,
    devicePath = ''
  }: CreateTransportProps): Promise<TransportType> {
    try {
      if (communicationType === CommunicationType.Node) {
        return await TransportNodeHid.open(devicePath);
      }
      return await (activeTransport && activeTransport instanceof TransportWebHID
        ? TransportWebHID.open(activeTransport.device)
        : TransportWebHID.request());
    } catch (error) {
      throw new TransportError('Creating transport failed', error);
    }
  }

  /**
   * @throws TransportError
   */
  static async createDeviceConnection(activeTransport: Transport): Promise<DeviceConnection> {
    try {
      const deviceConnection = new DeviceConnection(activeTransport);
      // Perform app check to see if device can respond
      await deviceConnection.getVersion();
      return deviceConnection;
    } catch (error) {
      throw new TransportError('Cannot communicate with Ledger Cardano App', error);
    }
  }

  /**
   * @throws TransportError
   */
  static async establishDeviceConnection(
    communicationType: CommunicationType,
    devicePath?: string
  ): Promise<DeviceConnection> {
    let transport;
    try {
      transport = await LedgerKeyAgent.createTransport({ communicationType, devicePath });
      if (!transport || !transport.deviceModel) {
        throw new TransportError('Missing transport');
      }
      const isSupportedLedgerModel = transport.deviceModel.id === 'nanoS' || transport.deviceModel.id === 'nanoX';
      if (!isSupportedLedgerModel) {
        throw new TransportError('Ledger device model not supported');
      }
      return await LedgerKeyAgent.createDeviceConnection(transport);
    } catch (error: any) {
      if (error.innerError.message.includes('cannot open device with path')) {
        throw new TransportError('Connection already established', error);
      }
      // If transport is established we need to close it so we can recover device from previous session
      if (transport) {
        // eslint-disable-next-line @typescript-eslint/no-floating-promises
        transport.close();
      }
      throw new TransportError('Establishing device connection failed', error);
    }
  }

  /**
   * @throws TransportError
   */
  static async checkDeviceConnection(
    communicationType: CommunicationType,
    deviceConnection?: DeviceConnection
  ): Promise<DeviceConnection> {
    try {
      if (!deviceConnection) {
        return await LedgerKeyAgent.establishDeviceConnection(communicationType);
      }
      // Create / Check device connection with currently active transport
      return await LedgerKeyAgent.createDeviceConnection(deviceConnection.transport);
    } catch (error: any) {
      // Device disconnected -> re-establish connection
      if (error.name === 'DisconnectedDeviceDuringOperation') {
        return await LedgerKeyAgent.establishDeviceConnection(communicationType);
      }
      throw error;
    }
  }

  /**
   * @throws AuthenticationError
   */
  static async getXpub({
    deviceConnection,
    communicationType,
    accountIndex
  }: GetXpubProps): Promise<Cardano.Bip32PublicKey> {
    try {
      const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
      const derivationPath = `1852'/1815'/${accountIndex}'`;
      const extendedPublicKey = await recoveredDeviceConnection.getExtendedPublicKey({
        path: utils.str_to_path(derivationPath) // BIP32Path
      });
      const xPubHex = `${extendedPublicKey.publicKeyHex}${extendedPublicKey.chainCodeHex}`;
      return Cardano.Bip32PublicKey(xPubHex);
    } catch (error: any) {
      if (error.code === 28_169) {
        throw new AuthenticationError('Failed to export extended account public key', error);
      }
      throw transportTypedError(error);
    }
  }

  /**
   * @throws TransportError
   */
  static async getAppVersion(
    communicationType: CommunicationType,
    deviceConnection?: DeviceConnection
  ): Promise<GetVersionResponse> {
    const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
    return await recoveredDeviceConnection.getVersion();
  }

  /**
   * @throws AuthenticationError
   * @throws TransportError
   */
  static async createWithDevice({
    networkId,
    accountIndex = 0,
    communicationType,
    deviceConnection
  }: CreateWithDevice) {
    const deviceListPaths = await LedgerKeyAgent.getHidDeviceList();
    // Re-use device connection if you want to create a key agent with new / additional account(s) and pass accountIndex
    const activeDeviceConnection = await (deviceConnection
      ? LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection)
      : LedgerKeyAgent.establishDeviceConnection(communicationType, deviceListPaths[0]));
    const extendedAccountPublicKey = await LedgerKeyAgent.getXpub({
      accountIndex,
      communicationType,
      deviceConnection: activeDeviceConnection
    });

    return new LedgerKeyAgent({
      accountIndex,
      communicationType,
      deviceConnection: activeDeviceConnection,
      extendedAccountPublicKey,
      knownAddresses: [],
      networkId
    });
  }

  async signTransaction(
    { body }: TxInternals,
    { inputAddressResolver }: SignTransactionOptions
  ): Promise<Cardano.Signatures> {
    try {
      const cslTxBody = coreToCsl.txBody(body);
      const ledgerTxData = await txToLedger({
        accountIndex: this.accountIndex,
        cslTxBody,
        inputAddressResolver,
        knownAddresses: this.knownAddresses,
        networkId: this.networkId
      });
      const deviceConnection = await LedgerKeyAgent.checkDeviceConnection(
        this.#communicationType,
        this.deviceConnection
      );
      const result = await deviceConnection.signTransaction(ledgerTxData);

      return new Map<Cardano.Ed25519PublicKey, Cardano.Ed25519Signature>(
        await Promise.all(
          result.witnesses.map(async (witness) => {
            const publicKey = await this.derivePublicKey({
              index: HARDENED - witness.path[2],
              role: witness.path[3]
            });
            const signature = Cardano.Ed25519Signature(witness.witnessSignatureHex);
            return [publicKey, signature] as const;
          })
        )
      );
    } catch (error: any) {
      if (error.code === 28_169) {
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
