import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';
import { testKeyManager } from '../mocks';

describe('InMemoryKeyManager', () => {
  let keyManager: KeyManagement.KeyManager;

  beforeEach(async () => {
    keyManager = await testKeyManager();
  });

  test('extendedAccountPublicKey', async () => {
    const extendedAccountPublicKey = await keyManager.extendedAccountPublicKey;
    expect(typeof extendedAccountPublicKey).toBe('string');
  });

  test('derivePublicKey', async () => {
    const publicKey = await keyManager.derivePublicKey({ index: 1, type: KeyManagement.KeyType.Stake });
    expect(typeof publicKey).toBe('string');
  });

  test('deriveAddress', async () => {
    const address = await keyManager.deriveAddress({ index: 1, type: KeyManagement.AddressType.Internal });
    expect(address).toBeDefined();
  });

  test('signTransaction', async () => {
    const witnessSet = await keyManager.signTransaction({
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
    const authenticate = async () => Buffer.from('password');

    it('can decrypt yoroi-encrypted root private key', async () => {
      const keyAgentFromEncryptedKey = new KeyManagement.InMemoryKeyAgent({
        accountIndex: 0,
        authenticate,
        encryptedRootPrivateKey: Buffer.from(yoroiEncryptedRootPrivateKeyHex, 'hex'),
        networkId: Cardano.NetworkId.testnet
      });
      const exportedPrivateKey = await keyAgentFromEncryptedKey.exportPrivateKey();
      expect(Buffer.from(exportedPrivateKey).toString('hex')).toEqual(yoroiRootPrivateKeyHex);
    });

    it('can import yoroi 15-word mnemonic', async () => {
      const keyAgentFromMnemonic = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
        authenticate,
        mnemonicWords: yoroiMnemonic,
        networkId: Cardano.NetworkId.testnet
      });
      const exportedPrivateKey = await keyAgentFromMnemonic.exportPrivateKey();
      expect(Buffer.from(exportedPrivateKey).toString('hex')).toEqual(yoroiRootPrivateKeyHex);
    });
  });
});
