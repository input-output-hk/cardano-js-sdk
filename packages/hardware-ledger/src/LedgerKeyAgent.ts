/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import {
  AlgorithmId,
  CBORValue,
  COSESign1Builder,
  HeaderMap,
  Headers,
  Label,
  ProtectedHeaderMap
} from '@emurgo/cardano-message-signing-nodejs';
import { Cardano, NotImplementedError, util as coreUtils } from '@cardano-sdk/core';
import {
  CardanoKeyConst,
  Cip1852PathLevelIndexes,
  CommunicationType,
  GroupedAddress,
  KeyAgentBase,
  KeyAgentDependencies,
  KeyAgentType,
  KeyPurpose,
  KeyRole,
  SerializableLedgerKeyAgentData,
  SignBlobResult,
  SignTransactionContext,
  cip8,
  errors,
  util
} from '@cardano-sdk/key-management';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { HID } from 'node-hid';
import { HexBlob, areNumbersEqualInConstantTime, areStringsEqualInConstantTime } from '@cardano-sdk/util';
import { LedgerDevice, LedgerTransportType } from './types';
import { str_to_path } from '@cardano-foundation/ledgerjs-hw-app-cardano/dist/utils/address';
import { toLedgerTx } from './transformers';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import _LedgerConnection, {
  AddressType,
  BIP32Path,
  Certificate,
  CertificateType,
  CredentialParams,
  CredentialParamsType,
  DeviceOwnedAddress,
  GetVersionResponse,
  MessageAddressFieldType,
  MessageData,
  PoolKeyType,
  PoolOwnerType,
  Transaction,
  TransactionSigningMode,
  TxOutputDestinationType,
  VoterType,
  VoterVotes
} from '@cardano-foundation/ledgerjs-hw-app-cardano';
import _TransportWebUSB from '@ledgerhq/hw-transport-webusb';
import type LedgerTransport from '@ledgerhq/hw-transport';

const TransportWebUSB = (_TransportWebUSB as any).default
  ? ((_TransportWebUSB as any).default as typeof _TransportWebUSB)
  : _TransportWebUSB;
const LedgerConnection = (_LedgerConnection as any).default
  ? ((_LedgerConnection as any).default as typeof _LedgerConnection)
  : _LedgerConnection;
type LedgerConnection = _LedgerConnection;

const isUsbDevice = (device: any): device is USBDevice =>
  typeof USBDevice !== 'undefined' && device instanceof USBDevice;

const isDeviceAlreadyOpenError = (error: unknown) => {
  if (typeof error !== 'object') return false;
  const innerError = (error as any).innerError;
  if (typeof innerError !== 'object') return false;
  return (
    innerError.code === 11 ||
    (typeof innerError.message === 'string' && innerError.message.includes('cannot open device with path'))
  );
};

const CARDANO_APP_CONNECTION_ERROR_MESSAGE = 'Cannot communicate with Ledger Cardano App';

export interface LedgerKeyAgentProps extends Omit<SerializableLedgerKeyAgentData, '__typename'> {
  deviceConnection?: LedgerConnection;
}

export interface CreateLedgerKeyAgentProps {
  chainId: Cardano.ChainId;
  accountIndex?: number;
  communicationType: CommunicationType;
  deviceConnection?: LedgerConnection | null;
  purpose?: KeyPurpose;
}

export interface GetLedgerXpubProps {
  deviceConnection?: LedgerConnection;
  communicationType: CommunicationType;
  accountIndex: number;
  purpose: KeyPurpose;
}

export interface CreateLedgerTransportProps {
  communicationType: CommunicationType;
  nodeHidDevicePath?: string;
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

const establishDeviceConnectionMethodName = 'establishDeviceConnection';

const parseEstablishDeviceConnectionSecondParam = (
  communicationType: CommunicationType,
  nodeHidDevicePathOrDevice?: string | LedgerDevice
) => {
  let device: LedgerDevice | undefined;
  let nodeHidDevicePath: string | undefined;

  const deviceObjectRecognized =
    (communicationType === CommunicationType.Node && nodeHidDevicePathOrDevice instanceof HID) ||
    (communicationType === CommunicationType.Web && isUsbDevice(nodeHidDevicePathOrDevice));
  const devicePathRecognized =
    communicationType === CommunicationType.Node && typeof nodeHidDevicePathOrDevice === 'string';

  if (deviceObjectRecognized) {
    device = nodeHidDevicePathOrDevice;
  } else if (devicePathRecognized) {
    nodeHidDevicePath = nodeHidDevicePathOrDevice;
  } else if (nodeHidDevicePathOrDevice !== undefined) {
    throw new Error(`Invalid arguments of the '${establishDeviceConnectionMethodName}' method`);
  }

  return {
    device,
    nodeHidDevicePath
  };
};

interface StakeCredentialCertificateParams {
  stakeCredential: CredentialParams;
}

const containsOnlyScriptHashCreds = (tx: Transaction): boolean => {
  const withdrawalsAllScriptHash = !tx.withdrawals?.some(
    (withdrawal) => !areNumbersEqualInConstantTime(withdrawal.stakeCredential.type, CredentialParamsType.SCRIPT_HASH)
  );

  if (tx.certificates) {
    for (const cert of tx.certificates) {
      if (!stakeCredentialCert(cert)) return false;

      const certParams = cert.params as unknown as StakeCredentialCertificateParams;
      if (!areNumbersEqualInConstantTime(certParams.stakeCredential.type, CredentialParamsType.SCRIPT_HASH))
        return false;
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

type DeviceConnectionsWithTheirInitialParams = { deviceConnection: LedgerConnection } & (
  | {
      communicationType: CommunicationType.Node;
      device?: HID;
      nodeHidDevicePath?: string;
    }
  | {
      communicationType: CommunicationType.Web;
      device?: USBDevice;
    }
);

type OpenTransportForDeviceParams = {
  communicationType: CommunicationType;
  device: LedgerDevice;
};

const getDerivationPath = (
  signWith: Cardano.PaymentAddress | Cardano.RewardAccount | Cardano.DRepID,
  knownAddresses: GroupedAddress[],
  accountIndex: number,
  purpose: number
): { signingPath: BIP32Path; addressParams: DeviceOwnedAddress } => {
  if (Cardano.DRepID.isValid(signWith)) {
    const path = util.accountKeyDerivationPathToBip32Path(accountIndex, util.DREP_KEY_DERIVATION_PATH, purpose);

    return {
      addressParams: {
        params: {
          spendingPath: path
        },
        type: AddressType.ENTERPRISE_KEY
      },
      signingPath: path
    };
  }

  const isRewardAccount = signWith.startsWith('stake');

  // Reward account
  if (isRewardAccount) {
    const knownRewardAddress = knownAddresses.find(({ rewardAccount }) => rewardAccount === signWith);

    if (!knownRewardAddress)
      throw new cip8.Cip30DataSignError(cip8.Cip30DataSignErrorCode.ProofGeneration, 'Unknown reward address');

    const path = util.accountKeyDerivationPathToBip32Path(
      accountIndex,
      knownRewardAddress.stakeKeyDerivationPath || util.STAKE_KEY_DERIVATION_PATH,
      purpose
    );

    return {
      addressParams: {
        params: {
          stakingPath: path
        },
        type: AddressType.REWARD_KEY
      },
      signingPath: path
    };
  }

  const knownAddress = knownAddresses.find(({ address }) => address === signWith);

  if (!knownAddress) {
    throw new cip8.Cip30DataSignError(cip8.Cip30DataSignErrorCode.ProofGeneration, 'Unknown address');
  }

  // Base address
  if (knownAddress.rewardAccount) {
    const spendingPath = util.accountKeyDerivationPathToBip32Path(
      accountIndex,
      {
        index: knownAddress.index,
        role: knownAddress.type as number as KeyRole
      },
      purpose
    );

    const stakingPath = util.accountKeyDerivationPathToBip32Path(
      accountIndex,
      knownAddress.stakeKeyDerivationPath || {
        index: 0,
        role: KeyRole.Stake
      },
      purpose
    );

    return {
      addressParams: {
        params: {
          spendingPath,
          stakingPath
        },
        type: AddressType.BASE_PAYMENT_KEY_STAKE_KEY
      },
      signingPath: spendingPath
    };
  }

  const spendingPath = util.accountKeyDerivationPathToBip32Path(
    accountIndex,
    {
      index: knownAddress.index,
      role: knownAddress.type as number as KeyRole
    },
    purpose
  );

  // Enterprise Address
  return {
    addressParams: {
      params: {
        spendingPath
      },
      type: AddressType.ENTERPRISE_KEY
    },
    signingPath: spendingPath
  };
};

export class LedgerKeyAgent extends KeyAgentBase {
  readonly deviceConnection?: LedgerConnection;
  readonly #communicationType: CommunicationType;
  static deviceConnections: DeviceConnectionsWithTheirInitialParams[] = [];

  constructor({ deviceConnection, ...serializableData }: LedgerKeyAgentProps, dependencies: KeyAgentDependencies) {
    super({ ...serializableData, __typename: KeyAgentType.Ledger }, dependencies);
    this.deviceConnection = deviceConnection;
    this.#communicationType = serializableData.communicationType;
  }

  private static async findConnectionByCommunicationTypeAndDevicePath(
    communicationType: CommunicationType,
    nodeHidDevicePath?: string,
    device?: LedgerDevice
  ): Promise<LedgerConnection | null> {
    const matchingConnectionData = this.deviceConnections?.find((connection) => {
      const sameCommunication = communicationType === connection.communicationType;
      if (connection.communicationType === CommunicationType.Web) {
        return sameCommunication && device === connection.device;
      }
      if (connection.communicationType === CommunicationType.Node) {
        return sameCommunication && device === connection.device && nodeHidDevicePath === connection.nodeHidDevicePath;
      }
    });
    if (!matchingConnectionData) return null;

    try {
      await this.testConnection(matchingConnectionData.deviceConnection);
    } catch (error) {
      if (error instanceof errors.TransportError && error.message.includes(CARDANO_APP_CONNECTION_ERROR_MESSAGE)) {
        this.deviceConnections = this.deviceConnections.filter(
          (connectionData) => connectionData !== matchingConnectionData
        );
        return null;
      }

      throw error;
    }

    return matchingConnectionData.deviceConnection;
  }

  /**
   * @throws TransportError
   */
  private static async getHidDeviceList(communicationType: CommunicationType): Promise<string[]> {
    try {
      return communicationType === CommunicationType.Node ? TransportNodeHid.list() : TransportWebUSB.list();
    } catch (error) {
      throw new errors.TransportError('Cannot fetch device list', error);
    }
  }

  private static attachDisconnectionCleanupHandler(transport: LedgerTransportType) {
    const onDisconnect = () => {
      transport.off('disconnect', onDisconnect);
      this.deviceConnections = this.deviceConnections.filter(
        ({ deviceConnection }) => deviceConnection.transport !== transport
      );
      void transport.close();
    };
    transport.on('disconnect', onDisconnect);
  }

  /**
   * @throws TransportError
   */
  private static async openTransportForDevice({ communicationType, device }: OpenTransportForDeviceParams) {
    let transport: LedgerTransportType;
    try {
      if (communicationType === CommunicationType.Node && device instanceof HID) {
        transport = new TransportNodeHid(device);
      } else if (communicationType === CommunicationType.Web && isUsbDevice(device)) {
        transport = await TransportWebUSB.open(device);
      } else {
        throw new errors.TransportError(`Invalid device object provided for communication type ${communicationType}`);
      }
    } catch (error) {
      throw new errors.TransportError('Failed to open a transport for a given device', error);
    }
    this.attachDisconnectionCleanupHandler(transport);
    return transport;
  }

  /**
   * @throws TransportError
   */
  static async createTransport({
    communicationType,
    nodeHidDevicePath = ''
  }: CreateLedgerTransportProps): Promise<LedgerTransportType> {
    let transport: LedgerTransportType;
    try {
      transport =
        communicationType === CommunicationType.Node
          ? await TransportNodeHid.open(nodeHidDevicePath)
          : await TransportWebUSB.request();
    } catch (error) {
      throw new errors.TransportError('Creating transport failed', error);
    }

    this.attachDisconnectionCleanupHandler(transport);
    return transport;
  }

  /**
   * @throws TransportError
   */
  private static async testConnection(activeConnection: LedgerConnection): Promise<void> {
    try {
      // Perform app check to see if device can respond
      await activeConnection.getVersion();
    } catch (error) {
      throw new errors.TransportError(CARDANO_APP_CONNECTION_ERROR_MESSAGE, error);
    }
  }

  /**
   * @throws TransportError
   */
  static async createDeviceConnection(activeTransport: LedgerTransport): Promise<LedgerConnection> {
    const deviceConnection = new LedgerConnection(activeTransport);
    await this.testConnection(deviceConnection);
    return deviceConnection;
  }

  private static rememberConnection({
    communicationType,
    device,
    deviceConnection,
    nodeHidDevicePath
  }: {
    communicationType: CommunicationType;
    device?: LedgerDevice;
    deviceConnection: LedgerConnection;
    nodeHidDevicePath?: string;
  }) {
    this.deviceConnections.push({
      deviceConnection,
      ...(communicationType === CommunicationType.Node
        ? {
            communicationType,
            ...(device instanceof HID && { device }),
            ...(nodeHidDevicePath !== undefined && { nodeHidDevicePath })
          }
        : {
            communicationType,
            ...(isUsbDevice(device) && { device })
          })
    });
  }

  /**
   * @throws TransportError
   */
  static async [establishDeviceConnectionMethodName](communicationType: CommunicationType): Promise<LedgerConnection>;
  static async [establishDeviceConnectionMethodName](
    communicationType: CommunicationType,
    nodeHidDevicePath: string
  ): Promise<LedgerConnection>;
  static async [establishDeviceConnectionMethodName](
    communicationType: CommunicationType.Node,
    device: HID
  ): Promise<LedgerConnection>;
  static async [establishDeviceConnectionMethodName](
    communicationType: CommunicationType.Web,
    device: USBDevice
  ): Promise<LedgerConnection>;
  static async [establishDeviceConnectionMethodName](
    communicationType: CommunicationType,
    nodeHidDevicePathOrDevice?: string | LedgerDevice
  ): Promise<LedgerConnection> {
    const { device, nodeHidDevicePath } = parseEstablishDeviceConnectionSecondParam(
      communicationType,
      nodeHidDevicePathOrDevice
    );

    const matchingOpenConnection = await this.findConnectionByCommunicationTypeAndDevicePath(
      communicationType,
      nodeHidDevicePath,
      device
    );
    if (matchingOpenConnection) return matchingOpenConnection;

    let transport: LedgerTransportType | undefined;
    try {
      transport = device
        ? await LedgerKeyAgent.openTransportForDevice({ communicationType, device })
        : await LedgerKeyAgent.createTransport({ communicationType, nodeHidDevicePath });

      if (!transport || !transport.deviceModel) {
        throw new errors.TransportError('Missing transport');
      }

      const newConnection = await LedgerKeyAgent.createDeviceConnection(transport);
      this.rememberConnection({
        communicationType,
        device,
        deviceConnection: newConnection,
        nodeHidDevicePath
      });

      return newConnection;
    } catch (error) {
      if (isDeviceAlreadyOpenError(error)) {
        throw new errors.TransportError('Connection already established', error);
      }
      // If transport is established we need to close it, so we can recover device from previous session
      if (transport) {
        void transport.close();
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
    accountIndex,
    purpose
  }: GetLedgerXpubProps): Promise<Crypto.Bip32PublicKeyHex> {
    try {
      const recoveredDeviceConnection = await LedgerKeyAgent.checkDeviceConnection(communicationType, deviceConnection);
      const derivationPath = `${purpose}'/${CardanoKeyConst.COIN_TYPE}'/${accountIndex}'`;
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
    {
      chainId,
      accountIndex = 0,
      communicationType,
      deviceConnection,
      purpose = KeyPurpose.STANDARD
    }: CreateLedgerKeyAgentProps,
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
      deviceConnection: activeDeviceConnection,
      purpose
    });

    return new LedgerKeyAgent(
      {
        accountIndex,
        chainId,
        communicationType,
        deviceConnection: activeDeviceConnection,
        extendedAccountPublicKey,
        purpose
      },
      dependencies
    );
  }

  private static isKeyHashOrScriptHashVoter(votingProcedures?: VoterVotes[] | null): boolean {
    return !!votingProcedures?.some((votingProcedure) => {
      switch (votingProcedure.voter.type) {
        case VoterType.COMMITTEE_KEY_HASH:
        case VoterType.COMMITTEE_SCRIPT_HASH:
        case VoterType.DREP_KEY_HASH:
        case VoterType.DREP_SCRIPT_HASH:
        case VoterType.STAKE_POOL_KEY_HASH:
          return true;
        default:
          return false;
      }
    });
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

    /**
     * VotingProcedures: We are currently supporting only keyHash and scriptHash voter types in voting procedures.
     * To sign tx with keyHash and scriptHash voter type we have to use PLUTUS_TRANSACTION signing mode
     */
    if (tx.collateralInputs || LedgerKeyAgent.isKeyHashOrScriptHashVoter(tx.votingProcedures)) {
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

  // TODO: LW-10571 - Allow additional key paths. This is necessary for multi-signature wallets
  // hardware devices inspect the transaction to determine which keys to use for signing,
  // however, multi sig transaction do not reference the CIP-1854 directly, but rather the script hash
  // so we need to be able to instruct the HW to sign the transaction with arbitrary keys.
  async signTransaction(
    { body, hash }: Cardano.TxBodyWithHash,
    { knownAddresses, txInKeyPathMap }: SignTransactionContext
  ): Promise<Cardano.Signatures> {
    try {
      const dRepPublicKey = await this.derivePublicKey(util.DREP_KEY_DERIVATION_PATH);
      const dRepKeyHashHex = (await Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash()).hex();
      const ledgerTxData = await toLedgerTx(body, {
        accountIndex: this.accountIndex,
        chainId: this.chainId,
        dRepKeyHashHex,
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

      if (!areStringsEqualInConstantTime(result.txHashHex, hash)) {
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

  async signCip8Data(request: cip8.Cip8SignDataContext): Promise<Cip30DataSignature> {
    try {
      const { signingPath, addressParams } = getDerivationPath(
        request.signWith,
        request.knownAddresses,
        this.accountIndex,
        this.purpose
      );

      const messageData: MessageData = {
        address: addressParams,
        addressFieldType: MessageAddressFieldType.ADDRESS,
        hashPayload: false,
        messageHex: request.payload,
        network: {
          networkId: this.chainId.networkId,
          protocolMagic: this.chainId.networkMagic
        },
        preferHexDisplay: false,
        signingPath
      };

      const deviceConnection = await LedgerKeyAgent.checkDeviceConnection(
        this.#communicationType,
        this.deviceConnection
      );

      const result = await deviceConnection.signMessage(messageData);

      // Re-create the CIP-008 payload the same way the firmware does it internally, otherwise the signature
      // will not verify.
      const addressBytes = coreUtils.hexToBytes(HexBlob(result.addressFieldHex));

      const protectedHeaders = HeaderMap.new();
      protectedHeaders.set_algorithm_id(Label.from_algorithm_id(AlgorithmId.EdDSA));
      protectedHeaders.set_header(cip8.CoseLabel.address, CBORValue.new_bytes(addressBytes));

      const builder = COSESign1Builder.new(
        Headers.new(ProtectedHeaderMap.new(protectedHeaders), HeaderMap.new()),
        coreUtils.hexToBytes(request.payload),
        false
      );

      const coseSign1 = builder.build(Buffer.from(result.signatureHex, 'hex'));
      const coseKey = cip8.createCoseKey(addressBytes, Crypto.Ed25519PublicKeyHex(result.signingPublicKeyHex));

      return {
        key: coreUtils.bytesToHex(coseKey.to_bytes()),
        signature: coreUtils.bytesToHex(coseSign1.to_bytes())
      };
    } catch (error: any) {
      if (error.code === 28_169) {
        throw new errors.AuthenticationError('Transaction signing aborted', error);
      }
      throw transportTypedError(error);
    }
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('Operation not supported!');
  }

  async exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex> {
    throw new NotImplementedError('Operation not supported!');
  }
}
