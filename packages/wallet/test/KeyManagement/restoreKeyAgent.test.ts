import { KeyManagement } from '../../src';

describe('KeyManagement/restoreKeyAgent', () => {
  describe('InMemoryKeyAgent', () => {
    const inMemoryKeyAgentData: KeyManagement.SerializableInMemoryKeyAgentData = {
      __typename: KeyManagement.KeyAgentType.InMemory,
      accountIndex: 0,
      encryptedRootPrivateKeyBytes: [
        9, 10, 153, 62, 225, 131, 81, 153, 234, 186, 63, 211, 14, 172, 194, 82, 184, 119, 228, 49, 2, 133, 239, 127,
        196, 140, 219, 8, 136, 248, 186, 84, 165, 123, 197, 105, 73, 181, 144, 27, 137, 206, 159, 63, 37, 138, 150, 49,
        194, 164, 58, 66, 200, 97, 242, 184, 110, 11, 39, 106, 131, 156, 196, 138, 219, 29, 7, 71, 117, 172, 111, 88,
        44, 103, 205, 168, 94, 156, 89, 252, 92, 55, 218, 216, 40, 59, 88, 227, 170, 118, 161, 116, 84, 39, 92, 33, 66,
        157, 42, 14, 225, 45, 175, 93, 214, 141, 163, 136, 13, 46, 152, 33, 166, 202, 127, 122, 146, 239, 38, 125, 114,
        66, 141, 241, 161, 163, 19, 81, 122, 125, 149, 49, 175, 149, 111, 48, 138, 254, 189, 69, 35, 135, 62, 177, 43,
        152, 95, 7, 87, 78, 204, 222, 109, 3, 239, 117
      ],
      networkId: 0
    };
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const getPassword: KeyManagement.GetPassword = async () => Buffer.from('password');

    it('can restore key manager from valid data and password', async () => {
      await expect(KeyManagement.restoreKeyAgent(inMemoryKeyAgentData, getPassword)).resolves.not.toThrow();
    });

    it('throws when attempting to restore key manager from invalid data', async () => {
      await expect(() =>
        KeyManagement.restoreKeyAgent(
          {
            ...inMemoryKeyAgentData,
            encryptedRootPrivateKeyBytes: [...inMemoryKeyAgentData.encryptedRootPrivateKeyBytes, 0]
          },
          getPassword
        )
      ).rejects.toThrow();
    });

    it('throws when attempting to restore key manager from valid data and no password', async () => {
      await expect(() => KeyManagement.restoreKeyAgent(inMemoryKeyAgentData)).rejects.toThrow();
    });

    it('throws when attempting to restore key manager from valid data and invalid password', async () => {
      await expect(() =>
        KeyManagement.restoreKeyAgent(inMemoryKeyAgentData, async () => Buffer.from('123'))
      ).rejects.toThrow();
    });
  });
});
