import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, TransportType } from '../../src/KeyManagement/types';
import { KeyManagement } from '../../src';
import AppAda from '@cardano-foundation/ledgerjs-hw-app-cardano';

describe('LedgerKeyAgent', () => {
  let keyAgent: KeyManagement.LedgerKeyAgent;
  beforeAll(async () => {
    keyAgent = await KeyManagement.LedgerKeyAgent.createWithDevice({
      communicationType: CommunicationType.Node,
      networkId: Cardano.NetworkId.testnet
    });
  });

  test('__typename', () => {
    expect(typeof keyAgent.__typename).toBe('string');
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

  test('getExtendedAccountPublicKey', async () => {
    const extendedAccountPublicKey = await keyAgent.getExtendedAccountPublicKey();
    expect(typeof extendedAccountPublicKey).toBe('string');
  });

  describe('device management', () => {
    let activeDeviceConnection: AppAda;
    let activeTransport: TransportType;

    beforeAll(() => {
      if (keyAgent.deviceConnection) {
        keyAgent.deviceConnection.transport.close();
      }
    });

    it('can establish new device connection', async () => {
      const deviceConnection = await KeyManagement.LedgerKeyAgent.establishDeviceConnection(CommunicationType.Node);
      activeDeviceConnection = deviceConnection;
      expect(deviceConnection).toBeDefined();
      expect(typeof deviceConnection).toBe('object');
    });

    it('can check active device connection', async () => {
      const deviceConnection = await KeyManagement.LedgerKeyAgent.checkDeviceConnection(
        CommunicationType.Node,
        activeDeviceConnection
      );
      expect(deviceConnection).toBeDefined();
      expect(typeof deviceConnection).toBe('object');
    });

    it('can check and re-establish device connection not established', async () => {
      if (activeDeviceConnection) {
        // Close active connection so we can simulate device check and instantiating new one
        activeDeviceConnection.transport.close();
      }
      const deviceConnection = await KeyManagement.LedgerKeyAgent.checkDeviceConnection(CommunicationType.Node);
      activeDeviceConnection = deviceConnection;
      expect(deviceConnection).toBeDefined();
      expect(typeof deviceConnection).toBe('object');
    });

    it('can create new transport', async () => {
      if (activeDeviceConnection) {
        // Close active connection so we can create new one with same device
        activeDeviceConnection.transport.close();
      }
      const transport = await KeyManagement.LedgerKeyAgent.createTransport({
        communicationType: CommunicationType.Node
      });
      activeTransport = transport;
      expect(transport).toBeDefined();
      expect(typeof transport).toBe('object');
    });

    it('can create device connection with activeTransport', async () => {
      const deviceConnection = await KeyManagement.LedgerKeyAgent.createDeviceConnection(activeTransport);
      expect(deviceConnection).toBeDefined();
      expect(typeof deviceConnection).toBe('object');
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
