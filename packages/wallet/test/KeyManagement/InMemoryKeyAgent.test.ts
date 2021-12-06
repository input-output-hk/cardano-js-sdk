import { AuthenticationError } from '../../src/KeyManagement/errors';
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

describe('InMemoryKeyAgent', () => {
  let keyAgent: KeyManagement.InMemoryKeyAgent;
  let getPassword: jest.Mock;

  beforeEach(async () => {
    getPassword = jest.fn().mockResolvedValue(Buffer.from('password'));
    keyAgent = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
      getPassword,
      mnemonicWords: KeyManagement.util.generateMnemonicWords(),
      networkId: Cardano.NetworkId.testnet
    });
  });

  afterEach(() => getPassword.mockReset());

  test('networkId', () => {
    expect(typeof keyAgent.networkId).toBe('number');
  });

  test('__typename', () => {
    expect(typeof keyAgent.__typename).toBe('string');
  });

  test('accountIndex', () => {
    expect(typeof keyAgent.accountIndex).toBe('number');
  });

  describe('serializableData', () => {
    let serializableData: KeyManagement.SerializableInMemoryKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as KeyManagement.SerializableInMemoryKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.networkId).toBe('number');
      expect(serializableData.encryptedRootPrivateKeyBytes.length > 0).toBe(true);
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });

  describe('getExtendedAccountPublicKey', () => {
    it('resolves on sucessful decryption', async () => {
      const extendedAccountPublicKey = await keyAgent.getExtendedAccountPublicKey();
      expect(typeof extendedAccountPublicKey).toBe('string');
    });
    it('rejects on getPassword rejection', async () => {
      getPassword.mockRejectedValueOnce(new Error('any error'));
      await expect(() => keyAgent.getExtendedAccountPublicKey()).rejects.toThrowError(
        new AuthenticationError('Failed to enter password')
      );
    });
    it('rejects on incorrect password', async () => {
      getPassword.mockResolvedValueOnce(Buffer.from('incorrect password'));
      await expect(() => keyAgent.getExtendedAccountPublicKey()).rejects.toThrowError(
        new AuthenticationError('Failed to decrypt root private key')
      );
    });
  });

  test('signBlob', async () => {
    const { publicKey, signature } = await keyAgent.signBlob(
      { index: 0, type: KeyManagement.KeyType.Internal },
      KeyManagement.HexBlob('abc123')
    );
    expect(typeof publicKey).toBe('string');
    expect(typeof signature).toBe('string');
  });

  test('derivePublicKey', async () => {
    const externalPublicKey = await keyAgent.derivePublicKey({ index: 1, type: KeyManagement.KeyType.External });
    expect(typeof externalPublicKey).toBe('string');
    const stakePublicKey = await keyAgent.derivePublicKey({ index: 1, type: KeyManagement.KeyType.Stake });
    expect(typeof stakePublicKey).toBe('string');
  });

  test('deriveAddress', async () => {
    const address = await keyAgent.deriveAddress({ index: 1, type: KeyManagement.AddressType.Internal });
    expect(address).toBeDefined();
  });

  test('exportRootPrivateKey ignores password cache', async () => {
    const privateKey = await keyAgent.exportRootPrivateKey();
    expect(typeof privateKey).toBe('string');
    expect(getPassword).toBeCalledTimes(2); // once on initialization of key agent
    expect(getPassword).toBeCalledWith(true);
  });

  test('signTransaction', async () => {
    const witnessSet = await keyAgent.signTransaction({
      body: {
        certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration }]
      } as unknown as Cardano.TxBodyAlonzo,
      hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
    });
    expect(witnessSet.size).toBe(2);
    expect(typeof [...witnessSet.values()][0]).toBe('string');
  });

  describe('yoroi compatibility', () => {
    const yoroiMnemonic = [
      'glide',
      'pencil',
      'pitch',
      'genius',
      'actor',
      'cause',
      'worry',
      'spot',
      'noble',
      'essay',
      'yellow',
      'robot',
      'cat',
      'glove',
      'shell'
    ];
    const yoroiRootPrivateKeyHex =
      // eslint-disable-next-line max-len
      '306c8eeeeab20533fde6d8a3272e848b9b669b1b9edae2265b6cde195bc2c3540eab2f531bce7f8adf9afd6257620d80be6f11a02829d7cf61294ef12e2ff7d8636ac76f6aaa14049eb3e90e25153ce080151ceecd86b0ad52f5fb499aa21eb9';
    const yoroiEncryptedRootPrivateKeyHex =
      // eslint-disable-next-line max-len
      '7ec495800df33892c274b954145208c7038d22478f98d7c6843697a964ec10f49856e2c7ee7b2dbf9fa939d3b6b80caee60fa097cb1fb8bfb75271662c8d35c93aa0515f61d79d3f2e21d2dc26d144e83d6791122c45c9b6e1c941b8f71b7904efa16e68c3512e14e30f8831b397c7ddeb56242f376177721eb7d6acd7e99848cd8cf64de5f88e14a6a2e9890329c7d80d91250da96bb1343f22529d';
    // eslint-disable-next-line unicorn/consistent-function-scoping

    it('can decrypt yoroi-encrypted root private key', async () => {
      const keyAgentFromEncryptedKey = new KeyManagement.InMemoryKeyAgent({
        accountIndex: 0,
        encryptedRootPrivateKey: Buffer.from(yoroiEncryptedRootPrivateKeyHex, 'hex'),
        getPassword,
        networkId: Cardano.NetworkId.testnet
      });
      const exportedPrivateKeyHex = await keyAgentFromEncryptedKey.exportRootPrivateKey();
      expect(exportedPrivateKeyHex).toEqual(yoroiRootPrivateKeyHex);
    });

    it('can import yoroi 15-word mnemonic', async () => {
      const keyAgentFromMnemonic = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
        getPassword,
        mnemonicWords: yoroiMnemonic,
        networkId: Cardano.NetworkId.testnet
      });
      const exportedPrivateKeyHex = await keyAgentFromMnemonic.exportRootPrivateKey();
      expect(exportedPrivateKeyHex).toEqual(yoroiRootPrivateKeyHex);
    });
  });
});
