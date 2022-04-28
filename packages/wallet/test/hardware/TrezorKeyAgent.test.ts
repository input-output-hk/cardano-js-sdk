import * as mocks from '../mocks';
import { Cardano } from '@cardano-sdk/core';
import { CommunicationType } from '../../src/KeyManagement/types';
import { KeyManagement } from '../../src';

describe('TrezorKeyAgent', () => {
  let keyAgent: KeyManagement.TrezorKeyAgent;

  beforeAll(async () => {
    keyAgent = await KeyManagement.TrezorKeyAgent.createWithDevice({
      networkId: Cardano.NetworkId.testnet,
      trezorConfig: {
        communicationType: CommunicationType.Node,
        manifest: {
          appUrl: 'https://your.application.com',
          email: 'email@developer.com'
        }
      }
    });
    const groupedAddress: KeyManagement.GroupedAddress = {
      accountIndex: 0,
      address: mocks.utxo[0][0].address,
      index: 0,
      networkId: Cardano.NetworkId.testnet,
      rewardAccount: mocks.rewardAccount,
      type: KeyManagement.AddressType.External
    };
    keyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
    keyAgent.knownAddresses.push(groupedAddress);
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

  describe('serializableData', () => {
    let serializableData: KeyManagement.SerializableTrezorKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as KeyManagement.SerializableTrezorKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.networkId).toBe('number');
      expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
      expect(Array.isArray(serializableData.knownAddresses)).toBe(true);
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });
});
