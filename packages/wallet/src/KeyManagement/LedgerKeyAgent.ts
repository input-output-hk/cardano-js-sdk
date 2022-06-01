/* eslint-disable @typescript-eslint/no-explicit-any */
import { AuthenticationError, TransportError } from './errors';
import { Cardano, NotImplementedError, coreToCsl } from '@cardano-sdk/core';
import { CardanoKeyConst, Cip1852PathLevelIndexes, txToLedger } from './util';
import {
  CommunicationType,
  KeyAgentType,
  LedgerTransportType,
  SerializableLedgerKeyAgentData,
  SignBlobResult,
  SignTransactionOptions
} from './types';
import { KeyAgentBase } from './KeyAgentBase';
import { TxInternals } from '../Transaction';
import LedgerConnection, { GetVersionResponse, utils } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import TransportWebHID from '@ledgerhq/hw-transport-webhid';
import type LedgerTransport from '@ledgerhq/hw-transport';

export interface LedgerKeyAgentProps extends Omit<SerializableLedgerKeyAgentData, '__typename'> {
  deviceConnection?: LedgerConnection;
}

export interface CreateLedgerKeyAgentProps {
  networkId: Cardano.NetworkId;
  protocolMagic: Cardano.NetworkMagic;
  accountIndex?: number;
  communicationType: CommunicationType;
  deviceConnection?: LedgerConnection | null;
}

export interface GetLedgerXpubProps {
  deviceConnection?: LedgerConnection;
  communicationType: CommunicationType;
  accountIndex: number;
}

export interface CreateLedgerTransportProps {
  communicationType: CommunicationType;
  activeTransport?: LedgerTransportType;
  devicePath?: string;
}

const transportTypedError = (error?: any) =>
  new AuthenticationError('Ledger transport failed', new TransportError('Ledger transport failed', error));

export class LedgerKeyAgent extends KeyAgentBase {
  readonly deviceConnection?: LedgerConnection;
  readonly #communicationType: CommunicationType;
  readonly #protocolMagic: Cardano.NetworkMagic;

  constructor({ deviceConnection, ...serializableData }: LedgerKeyAgentProps) {
    super({ ...serializableData, __typename: KeyAgentType.Ledger });
    this.deviceConnection = deviceConnection;
    this.#communicationType = serializableData.communicationType;
    this.#protocolMagic = serializableData.protocolMagic;
  }

  /**
   * @throws TransportError
   */
  static async getHidDeviceList(communicationType: CommunicationType): Promise<string[]> {
    try {
      return communicationType === CommunicationType.Node ? TransportNodeHid.list() : TransportWebHID.list();
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
  }: CreateLedgerTransportProps): Promise<LedgerTransportType> {
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
  static async createDeviceConnection(activeTransport: LedgerTransport): Promise<LedgerConnection> {
    try {
      const deviceConnection = new LedgerConnection(activeTransport);
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
  ): Promise<LedgerConnection> {
    let transport;
    try {
      transport = await LedgerKeyAgent.createTransport({ communicationType, devicePath });
      if (!transport || !transport.deviceModel) {
        throw new TransportError('Missing transport');
      }
      const isSupportedLedgerModel =
        transport.deviceModel.id === 'nanoS' ||
        transport.deviceModel.id === 'nanoX' ||
        transport.deviceModel.id === 'nanoSP';
      if (!isSupportedLedgerModel) {
        throw new TransportError(`Ledger device model: "${transport.deviceModel.id}" is not supported`);
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
    deviceConnection?: LedgerConnection
  ): Promise<LedgerConnection> {
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
  }: GetLedgerXpubProps): Promise<Cardano.Bip32PublicKey> {
    try {
      const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
      const derivationPath = `${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${accountIndex}'`;
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
    deviceConnection?: LedgerConnection
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
    protocolMagic,
    accountIndex = 0,
    communicationType,
    deviceConnection
  }: CreateLedgerKeyAgentProps) {
    const deviceListPaths = await LedgerKeyAgent.getHidDeviceList(communicationType);
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
      networkId,
      protocolMagic
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
        networkId: this.networkId,
        protocolMagic: this.#protocolMagic
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
              index: witness.path[Cip1852PathLevelIndexes.INDEX],
              role: witness.path[Cip1852PathLevelIndexes.ROLE]
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
