import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, TransportType } from '../../src/KeyManagement/types';
import { KeyManagement } from '../../src';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';

describe('LedgerKeyAgent', () => {
  let keyAgent: KeyManagement.LedgerKeyAgent;
  beforeAll(async () => {
    keyAgent = await KeyManagement.LedgerKeyAgent.createWithDevice({
      communicationType: CommunicationType.Node,
      networkId: Cardano.NetworkId.testnet
    });
  });

  test('__typename', () => {
    expect(typeof keyAgent.serializableData.__typename).toBe('string');
  });

  test('networkId', () => {
    expect(typeof keyAgent.networkId).toBe('number');
  });

  test('accountIndex', () => {
    expect(typeof keyAgent.accountIndex).toBe('number');
  });

  test('knownAddresses', () => {
    expect(Array.isArray(keyAgent.knownAddresses)).toBe(true);
  });

  test('extendedAccountPublicKey', () => {
    expect(typeof keyAgent.extendedAccountPublicKey).toBe('string');
  });

  describe('establish, check and re-establish device connection', () => {
    let deviceConnection: DeviceConnection;
    beforeAll(async () => {
      if (keyAgent.deviceConnection) {
        keyAgent.deviceConnection.transport.close();
      }
      deviceConnection = await KeyManagement.LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);
    });

    it('can check active device connection', async () => {
      const activeDeviceConnection = await KeyManagement.LedgerKeyAgent.checkDeviceConnection(
        CommunicationType.Node,
        deviceConnection
      );
      expect(activeDeviceConnection).toBeDefined();
      expect(typeof activeDeviceConnection).toBe('object');
      activeDeviceConnection.transport.close();
    });

    it('can re-establish closed device connection', async () => {
      if (deviceConnection) {
        deviceConnection.transport.close();
      }
      const activeDeviceConnection = await KeyManagement.LedgerKeyAgent.checkDeviceConnection(CommunicationType.Node);
      expect(activeDeviceConnection).toBeDefined();
      expect(typeof activeDeviceConnection).toBe('object');
      activeDeviceConnection.transport.close();
    });
  });

  describe('create device connection with transport', () => {
    let transport: TransportType;
    beforeAll(async () => {
      transport = await KeyManagement.LedgerKeyAgent.createTransport({
        communicationType: CommunicationType.Node
      });
    });

    it('can create device connection with activeTransport', async () => {
      const activeDeviceConnection = await KeyManagement.LedgerKeyAgent.createDeviceConnection(transport);
      expect(activeDeviceConnection).toBeDefined();
      expect(typeof activeDeviceConnection).toBe('object');
      activeDeviceConnection.transport.close();
    });
  });

  describe('serializableData', () => {
    let serializableData: KeyManagement.SerializableLedgerKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as KeyManagement.SerializableLedgerKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.networkId).toBe('number');
      expect(Array.isArray(serializableData.knownAddresses)).toBe(true);
      expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
      expect(typeof serializableData.communicationType).toBe('string');
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });
});
