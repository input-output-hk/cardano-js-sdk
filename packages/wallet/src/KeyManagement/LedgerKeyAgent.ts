/* eslint-disable @typescript-eslint/no-explicit-any */
import { AuthenticationError, TransportError } from './errors';
import { Cardano, NotImplementedError, CSL, coreToCsl } from '@cardano-sdk/core';
import {
  CommunicationType,
  KeyAgentType,
  SerializableLedgerKeyAgentData,
  SignBlobResult,
  TransportType,
  KeyRole,
} from './types';
import { KeyAgentBase } from './KeyAgentBase';
import DeviceConnection, {
  GetVersionResponse,
  utils,
  HARDENED,
} from '@cardano-foundation/ledgerjs-hw-app-cardano';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import TransportWebHID from '@ledgerhq/hw-transport-webhid';
import type Transport from '@ledgerhq/hw-transport';
import { txToLedger, STAKE_KEY_DERIVATION_PATH } from './util';
import { TxInternals } from '../Transaction'

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

  async signTransaction(txInternals: TxInternals): Promise<Cardano.Signatures> {
    try {
      const cslTxBody = coreToCsl.txBody(txInternals.body);
      const cslWitnessSet = CSL.TransactionWitnessSet.new();
      const cslTransaction = CSL.Transaction.new(cslTxBody, cslWitnessSet);

      const stakeKeyHash = await this.derivePublicKey(STAKE_KEY_DERIVATION_PATH);
      const paymentKeyHash = await this.derivePublicKey({
        index: this.serializableData.accountIndex,
        role: KeyRole.Internal,
      });
      const keys = {
        payment: {
          hash: paymentKeyHash,
          path: [HARDENED + 1852, HARDENED + 1815, HARDENED + this.serializableData.accountIndex, KeyRole.Internal, 0],
        },
        stake: {
          hash: stakeKeyHash,
          path: [HARDENED + 1852, HARDENED + 1815, HARDENED + this.serializableData.accountIndex, KeyRole.Stake, 0],
        },
      };

      const accountAddress = this.knownAddresses[0].address;
      const addrHex = utils.buf_to_hex(utils.bech32_decodeAddress(accountAddress.toString()))

      const ledgerTxData = await txToLedger({
        tx: cslTransaction,
        networkId: this.serializableData.networkId,
        keys,
        addressHex: addrHex,
        index: this.serializableData.accountIndex,
      });

      // @ts-ignore
      const deviceConnection = await LedgerKeyAgent.checkDeviceConnection(this.serializableData.communicationType, this.deviceConnection);
      const result = await deviceConnection.signTransaction(ledgerTxData);

      return new Map<Cardano.Ed25519PublicKey, Cardano.Ed25519Signature>(
        await Promise.all(
          result.witnesses.map(async (witness) => {
            const publicKey = await this.derivePublicKey({
              index: HARDENED - witness.path[2],
              role: witness.path[3],
            });
            const signature = Cardano.Ed25519Signature(
              witness.witnessSignatureHex
            );
            return [publicKey, signature] as const;
          })
        )
      );
    } catch (error: any) {
      // eslint-disable-next-line unicorn/numeric-separators-style
      if (error.code === 28169) {
        throw new AuthenticationError('Transaction signing aborted', error);
      }
      throw new TransportError('Transport failed', error);
    }
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  async exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey> {
    throw new NotImplementedError('Operation not supported!');
  }
}
