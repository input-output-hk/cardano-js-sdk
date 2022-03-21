/* eslint-disable @typescript-eslint/no-explicit-any */
import { AuthenticationError, TransportError } from './errors';
import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import {
  CommunicationType,
  KeyAgentType,
  SerializableLedgerKeyAgentData,
  SignBlobResult,
  TransportType
} from './types';
import { KeyAgentBase } from './KeyAgentBase';
import DeviceConnection, { GetVersionResponse, utils } from '@cardano-foundation/ledgerjs-hw-app-cardano';
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

export class LedgerKeyAgent extends KeyAgentBase {
  readonly deviceConnection?: DeviceConnection;

  constructor({ deviceConnection, ...serializableData }: LedgerKeyAgentProps) {
    super({ ...serializableData, __typename: KeyAgentType.Ledger });
    this.deviceConnection = deviceConnection;
  }

  static async getHidDeviceList(): Promise<string[]> {
    return await TransportNodeHid.list();
  }

  static async createTransport({
    communicationType,
    activeTransport,
    devicePath = ''
  }: CreateTransportProps): Promise<TransportType> {
    if (communicationType === CommunicationType.Node) {
      return await TransportNodeHid.open(devicePath);
    }
    return await (activeTransport && activeTransport instanceof TransportWebHID
      ? TransportWebHID.open(activeTransport.device)
      : TransportWebHID.request());
  }

  static async createDeviceConnection(activeTransport: Transport): Promise<DeviceConnection> {
    const deviceConnection = new DeviceConnection(activeTransport);
    // Perform app check to see if device can respond
    await deviceConnection.getVersion();
    return deviceConnection;
  }

  static async establishDeviceConnection(
    communicationType: CommunicationType,
    devicePath?: string
  ): Promise<DeviceConnection> {
    let transport;
    try {
      transport = await LedgerKeyAgent.createTransport({ communicationType, devicePath });
      if (!transport || !transport.deviceModel) {
        throw new TransportError('Transport failed');
      }
      const isSupportedLedgerModel = transport.deviceModel.id === 'nanoS' || transport.deviceModel.id === 'nanoX';
      if (!isSupportedLedgerModel) {
        throw new TransportError('Ledger device model not supported');
      }
      return await LedgerKeyAgent.createDeviceConnection(transport);
    } catch (error: any) {
      if (error.message.includes('cannot open device with path')) {
        throw new TransportError('Connection already established', error);
      }
      // If transport is established we need to close it so we can recover device from previous session
      if (transport) {
        // eslint-disable-next-line @typescript-eslint/no-floating-promises
        transport.close();
      }
      throw error;
    }
  }

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
      // eslint-disable-next-line unicorn/numeric-separators-style
      if (error.code === 28169) {
        throw new AuthenticationError('Failed to export extended account public key', error);
      }
      throw new TransportError('Transport failed', error);
    }
  }

  static async getAppVersion(
    communicationType: CommunicationType,
    deviceConnection?: DeviceConnection
  ): Promise<GetVersionResponse> {
    const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
    return await recoveredDeviceConnection.getVersion();
  }

  static async createWithDevice({ networkId, accountIndex = 0, communicationType }: CreateWithDevice) {
    const deviceListPaths = await LedgerKeyAgent.getHidDeviceList();
    const deviceConnection = await LedgerKeyAgent.establishDeviceConnection(communicationType, deviceListPaths[0]);
    const extendedAccountPublicKey = await LedgerKeyAgent.getXpub({
      accountIndex,
      communicationType,
      deviceConnection
    });

    return new LedgerKeyAgent({
      accountIndex,
      communicationType,
      deviceConnection,
      extendedAccountPublicKey,
      knownAddresses: [],
      networkId
    });
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  async exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey> {
    throw new NotImplementedError('Operation not supported!');
  }
}
