import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import {
  CommunicationType,
  GroupedAddress,
  KeyAgentType,
  SerializableLedgerKeyAgentData,
  SignBlobResult
} from './types';
import { KeyAgentBase } from './KeyAgentBase';
import { TransportError } from './errors';
import AppAda, { GetVersionResponse, utils } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import TransportWebHID from '@ledgerhq/hw-transport-webhid';
import type Transport from '@ledgerhq/hw-transport';

export interface LedgerKeyAgentProps {
  networkId: Cardano.NetworkId;
  accountIndex: number;
  knownAddresses: GroupedAddress[];
  extendedAccountPublicKey: Cardano.Bip32PublicKey;
  deviceConnection?: AppAda;
  communicationType: CommunicationType;
}

export interface CreateWithDevice {
  communicationType: CommunicationType;
  networkId: Cardano.NetworkId;
  accountIndex: number;
  knownAddresses: GroupedAddress[];
}

export interface GetXpubProps {
  deviceConnection?: AppAda;
  communicationType: CommunicationType;
  accountIndex: number;
}

export class LedgerKeyAgent extends KeyAgentBase {
  readonly #networkId: Cardano.NetworkId;
  readonly #accountIndex: number;
  readonly #knownAddresses: GroupedAddress[];
  readonly #extendedAccountPublicKey: Cardano.Bip32PublicKey;
  readonly #deviceConnection?: AppAda;
  readonly #communicationType: CommunicationType;

  constructor({
    networkId,
    accountIndex,
    knownAddresses,
    extendedAccountPublicKey,
    deviceConnection,
    communicationType
  }: LedgerKeyAgentProps) {
    super();
    this.#accountIndex = accountIndex;
    this.#networkId = networkId;
    this.#knownAddresses = knownAddresses;
    this.#extendedAccountPublicKey = extendedAccountPublicKey;
    this.#deviceConnection = deviceConnection;
    this.#communicationType = communicationType;
  }

  get networkId(): Cardano.NetworkId {
    return this.#networkId;
  }

  get accountIndex(): number {
    return this.#accountIndex;
  }

  get __typename(): KeyAgentType {
    return KeyAgentType.Ledger;
  }

  get knownAddresses(): GroupedAddress[] {
    return this.#knownAddresses;
  }

  get serializableData(): SerializableLedgerKeyAgentData {
    return {
      __typename: KeyAgentType.Ledger,
      networkId: this.networkId,
      accountIndex: this.#accountIndex,
      knownAddresses: this.#knownAddresses,
      extendedAccountPublicKey: this.#extendedAccountPublicKey,
      communicationType: this.#communicationType,
      deviceConnection: this.#deviceConnection,
    };
  }

  static async createTransport(activeTransport?: TransportWebHID): Promise<TransportWebHID> {
    return await (activeTransport ? TransportWebHID.open(activeTransport.device) : TransportWebHID.request());
  }

  static async createDeviceConnection(activeTransport: Transport): Promise<AppAda> {
    const deviceConnection = new AppAda(activeTransport);
    // Perform app check to see if device can respond
    await deviceConnection.getVersion();
    return deviceConnection;
  }

  static async establishDeviceConnection(communicationType: CommunicationType): Promise<AppAda> {
    let transport;
    if (communicationType !== CommunicationType.Web) {
      throw new TransportError('Communication method not supported');
    }
    try {
      transport = await LedgerKeyAgent.createTransport();
      if (!transport || !transport.deviceModel) {
        throw new TransportError('Transport failed');
      }
      const isSupportedLedgerModel = transport.deviceModel.id === 'nanoS' || transport.deviceModel.id === 'nanoX';
      if (!isSupportedLedgerModel) {
        throw new TransportError('Ledger device model not supported');
      }
      return await LedgerKeyAgent.createDeviceConnection(transport);
    } catch (error) {
      // If transport is established we need to close it so we can recover device from previous session
      if (transport) {
        // eslint-disable-next-line @typescript-eslint/no-floating-promises
        transport.close();
      }
      throw error;
    }
  }

  static async checkDeviceConnection(communicationType: CommunicationType, deviceConnection?: AppAda): Promise<AppAda> {
    try {
      if (!deviceConnection) {
        return await LedgerKeyAgent.establishDeviceConnection(communicationType);
      }
      // Create / Check device connection with currently active transport
      return await LedgerKeyAgent.createDeviceConnection(deviceConnection.transport);
    } catch (error) {
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
    const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
    const derivationPath = `1852'/1815'/${accountIndex}'`;
    const extendedPublicKey = await recoveredDeviceConnection.getExtendedPublicKey({
      path: utils.str_to_path(derivationPath) // BIP32Path
    });
    const xPubHex = `${extendedPublicKey.publicKeyHex}${extendedPublicKey.chainCodeHex}`;
    return Cardano.Bip32PublicKey(xPubHex);
  }

  static async getAppVersion(
    communicationType: CommunicationType,
    deviceConnection?: AppAda
  ): Promise<GetVersionResponse> {
    const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
    return await recoveredDeviceConnection.getVersion();
  }

  static async createWithDevice({ communicationType, networkId, accountIndex, knownAddresses }: CreateWithDevice) {
    const deviceConnection = await LedgerKeyAgent.establishDeviceConnection(communicationType);
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
      knownAddresses,
      networkId
    });
  }

  async getExtendedAccountPublicKey(): Promise<Cardano.Bip32PublicKey> {
    return this.#extendedAccountPublicKey;
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  async derivePublicKey(): Promise<Cardano.Ed25519PublicKey> {
    throw new NotImplementedError('derivePublicKey');
  }

  async exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey> {
    throw new NotImplementedError('Operation not supported!');
  }
}
