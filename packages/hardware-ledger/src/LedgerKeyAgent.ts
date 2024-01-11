/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import {
  CardanoKeyConst,
  Cip1852PathLevelIndexes,
  CommunicationType,
  KeyAgentBase,
  KeyAgentDependencies,
  KeyAgentType,
  SerializableLedgerKeyAgentData,
  SignBlobResult,
  SignTransactionContext,
  errors
} from '@cardano-sdk/key-management';
import { LedgerTransportType } from './types';
import { str_to_path } from '@cardano-foundation/ledgerjs-hw-app-cardano/dist/utils/address';
import { toLedgerTx } from './transformers';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import _LedgerConnection, {
  Certificate,
  CertificateType,
  GetVersionResponse,
  PoolKeyType,
  PoolOwnerType,
  StakeCredentialParams,
  StakeCredentialParamsType,
  Transaction,
  TransactionSigningMode,
  TxOutputDestinationType
} from '@cardano-foundation/ledgerjs-hw-app-cardano';
import _TransportWebHID from '@ledgerhq/hw-transport-webhid';
import type LedgerTransport from '@ledgerhq/hw-transport';

const TransportWebHID = (_TransportWebHID as any).default
  ? ((_TransportWebHID as any).default as typeof _TransportWebHID)
  : _TransportWebHID;
const LedgerConnection = (_LedgerConnection as any).default
  ? ((_LedgerConnection as any).default as typeof _LedgerConnection)
  : _LedgerConnection;
type LedgerConnection = _LedgerConnection;

export interface LedgerKeyAgentProps extends Omit<SerializableLedgerKeyAgentData, '__typename'> {
  deviceConnection?: LedgerConnection;
}

export interface CreateLedgerKeyAgentProps {
  chainId: Cardano.ChainId;
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

const transportTypedError = (error?: any) => new errors.TransportError('Ledger transport failed', error);

const hasRegistrationOrRetirementCerts = (certificates: Certificate[] | null | undefined): boolean => {
  if (!certificates) return false;

  return (
    certificates.some((cert) => cert.type === CertificateType.STAKE_POOL_RETIREMENT) ||
    certificates.some((cert) => cert.type === CertificateType.STAKE_POOL_REGISTRATION)
  );
};

const stakeCredentialCert = (cert: Certificate) =>
  cert.type === CertificateType.STAKE_REGISTRATION ||
  cert.type === CertificateType.STAKE_DEREGISTRATION ||
  cert.type === CertificateType.STAKE_DELEGATION;

interface StakeCredentialCertificateParams {
  stakeCredential: StakeCredentialParams;
}

const containsOnlyScriptHashCreds = (tx: Transaction): boolean => {
  const withdrawalsAllScriptHash = !tx.withdrawals?.some(
    (withdrawal) => withdrawal.stakeCredential.type !== StakeCredentialParamsType.SCRIPT_HASH
  );

  if (tx.certificates) {
    for (const cert of tx.certificates) {
      if (!stakeCredentialCert(cert)) return false;

      const certParams = cert.params as unknown as StakeCredentialCertificateParams;
      if (certParams.stakeCredential.type !== StakeCredentialParamsType.SCRIPT_HASH) return false;
    }
  }

  return withdrawalsAllScriptHash;
};

const isMultiSig = (tx: Transaction): boolean => {
  const result = false;

  const allThirdPartyInputs = !tx.inputs.some((input) => input.path !== null);
  // Ledger doesn't allow change outputs to address controlled by your keys and instead you have to use script address for change out
  const allThirdPartyOutputs = !tx.outputs.some((out) => out.destination.type !== TxOutputDestinationType.THIRD_PARTY);

  if (
    allThirdPartyInputs &&
    allThirdPartyOutputs &&
    !tx.collateralInputs &&
    !tx.requiredSigners &&
    !hasRegistrationOrRetirementCerts(tx.certificates) &&
    containsOnlyScriptHashCreds(tx)
  ) {
    return true;
  }

  return result;
};

type LedgerConnectionWithCommunicationTypeAndDevicePath = {
  deviceConnection: LedgerConnection;
  communicationType: CommunicationType;
  devicePath?: string;
};

export class LedgerKeyAgent extends KeyAgentBase {
  readonly deviceConnection?: LedgerConnection;
  readonly #communicationType: CommunicationType;
  static deviceConnections: LedgerConnectionWithCommunicationTypeAndDevicePath[] = [];

  constructor({ deviceConnection, ...serializableData }: LedgerKeyAgentProps, dependencies: KeyAgentDependencies) {
    super({ ...serializableData, __typename: KeyAgentType.Ledger }, dependencies);
    this.deviceConnection = deviceConnection;
    this.#communicationType = serializableData.communicationType;
  }

  static findKeyAgentByCommunicationTypeAndDevicePath(communicationType: CommunicationType, devicePath?: string) {
    return this.deviceConnections?.find(
      (connection) => connection.communicationType === communicationType && connection.devicePath === devicePath
    );
  }

  /**
   * @throws TransportError
   */
  static async getHidDeviceList(communicationType: CommunicationType): Promise<string[]> {
    try {
      return communicationType === CommunicationType.Node ? TransportNodeHid.list() : TransportWebHID.list();
    } catch (error) {
      throw new errors.TransportError('Cannot fetch device list', error);
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
      throw new errors.TransportError('Creating transport failed', error);
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
      throw new errors.TransportError('Cannot communicate with Ledger Cardano App', error);
    }
  }

  /**
   * @throws TransportError
   */
  static async establishDeviceConnection(
    communicationType: CommunicationType,
    devicePath?: string
    // eslint-disable-next-line complexity
  ): Promise<LedgerConnection> {
    const sameConnectionByTypeAndPath = this.findKeyAgentByCommunicationTypeAndDevicePath(
      communicationType,
      devicePath
    );
    if (sameConnectionByTypeAndPath) return sameConnectionByTypeAndPath.deviceConnection;
    let transport;
    try {
      transport = await LedgerKeyAgent.createTransport({ communicationType, devicePath });
      if (!transport || !transport.deviceModel) {
        throw new errors.TransportError('Missing transport');
      }
      const isSupportedLedgerModel =
        transport.deviceModel.id === 'nanoS' ||
        transport.deviceModel.id === 'nanoX' ||
        transport.deviceModel.id === 'nanoSP';
      if (!isSupportedLedgerModel) {
        throw new errors.TransportError(`Ledger device model: "${transport.deviceModel.id}" is not supported`);
      }
      const newConnection = await LedgerKeyAgent.createDeviceConnection(transport);
      this.deviceConnections.push({
        communicationType,
        deviceConnection: newConnection,
        ...(!!devicePath && { devicePath })
      });
      return newConnection;
    } catch (error: any) {
      if (error.innerError.message.includes('cannot open device with path')) {
        throw new errors.TransportError('Connection already established', error);
      }
      // If transport is established we need to close it so we can recover device from previous session
      if (transport) {
        // eslint-disable-next-line @typescript-eslint/no-floating-promises
        transport.close();
      }
      throw new errors.TransportError('Establishing device connection failed', error);
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
  }: GetLedgerXpubProps): Promise<Crypto.Bip32PublicKeyHex> {
    try {
      const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
      const derivationPath = `${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${accountIndex}'`;
      const extendedPublicKey = await recoveredDeviceConnection.getExtendedPublicKey({
        path: str_to_path(derivationPath) // BIP32Path
      });
      const xPubHex = `${extendedPublicKey.publicKeyHex}${extendedPublicKey.chainCodeHex}`;
      return Crypto.Bip32PublicKeyHex(xPubHex);
    } catch (error: any) {
      if (error.code === 28_169) {
        throw new errors.AuthenticationError('Failed to export extended account public key', error);
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
  static async createWithDevice(
    { chainId, accountIndex = 0, communicationType, deviceConnection }: CreateLedgerKeyAgentProps,
    dependencies: KeyAgentDependencies
  ) {
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

    return new LedgerKeyAgent(
      {
        accountIndex,
        chainId,
        communicationType,
        deviceConnection: activeDeviceConnection,
        extendedAccountPublicKey
      },
      dependencies
    );
  }

  /**
   * Gets the mode in which we want to sign the transaction.
   * Ledger has certain limitations due to which it cannot sign arbitrary combination of all transaction features.
   * The mode specifies which use-case the user want to use and triggers additional validation on `tx` field.
   */
  static getSigningMode(tx: Transaction): TransactionSigningMode {
    if (tx.certificates) {
      for (const cert of tx.certificates) {
        // Represents pool registration from the perspective of a pool owner.
        if (
          cert.type === CertificateType.STAKE_POOL_REGISTRATION &&
          cert.params.poolOwners.some((owner) => owner.type === PoolOwnerType.DEVICE_OWNED)
        )
          return TransactionSigningMode.POOL_REGISTRATION_AS_OWNER;

        // Represents pool registration from the perspective of a pool operator.
        if (
          cert.type === CertificateType.STAKE_POOL_REGISTRATION &&
          cert.params.poolKey.type === PoolKeyType.DEVICE_OWNED
        )
          return TransactionSigningMode.POOL_REGISTRATION_AS_OPERATOR;
      }
    }

    if (tx.collateralInputs) {
      return TransactionSigningMode.PLUTUS_TRANSACTION;
    }

    // Represents a transaction controlled by native scripts.
    // Like an ordinary transaction, but stake credentials and all similar elements are given as script hashes
    if (isMultiSig(tx)) {
      return TransactionSigningMode.MULTISIG_TRANSACTION;
    }

    // Represents an ordinary user transaction transferring funds.
    return TransactionSigningMode.ORDINARY_TRANSACTION;
  }

  // TODO: Allow additional key paths
  async signTransaction(
    { body, hash }: Cardano.TxBodyWithHash,
    { knownAddresses, txInKeyPathMap }: SignTransactionContext
  ): Promise<Cardano.Signatures> {
    try {
      const ledgerTxData = await toLedgerTx(body, {
        accountIndex: this.accountIndex,
        chainId: this.chainId,
        knownAddresses,
        txInKeyPathMap
      });

      const deviceConnection = await LedgerKeyAgent.checkDeviceConnection(
        this.#communicationType,
        this.deviceConnection
      );

      const signingMode = LedgerKeyAgent.getSigningMode(ledgerTxData);

      const result = await deviceConnection.signTransaction({
        signingMode,
        tx: ledgerTxData
      });

      if (result.txHashHex !== hash) {
        throw new errors.HwMappingError('Ledger computed a different transaction id');
      }

      return new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>(
        await Promise.all(
          result.witnesses.map(async (witness) => {
            const publicKey = await this.derivePublicKey({
              index: witness.path[Cip1852PathLevelIndexes.INDEX],
              role: witness.path[Cip1852PathLevelIndexes.ROLE]
            });
            const signature = Crypto.Ed25519SignatureHex(witness.witnessSignatureHex);
            return [publicKey, signature] as const;
          })
        )
      );
    } catch (error: any) {
      if (error.code === 28_169) {
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
