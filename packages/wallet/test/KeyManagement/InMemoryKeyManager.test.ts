import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

describe('InMemoryKeyManager', () => {
  let keyManager: KeyManagement.KeyManager;

  beforeEach(() => {
    const mnemonicWords = KeyManagement.util.generateMnemonicWords();
    keyManager = KeyManagement.createInMemoryKeyManager({
      mnemonicWords,
      networkId: Cardano.NetworkId.testnet,
      password: '123'
    });
    expect(keyManager.publicKey).toBeInstanceOf(CSL.PublicKey);
  });

  test('initial state publicKey', () => {
    expect(keyManager.publicKey).toBeDefined();
    expect(keyManager.publicParentKey).toBeDefined();
  });

  test('deriveAddress', async () => {
    const address = await keyManager.deriveAddress(0, 0);
    expect(address).toBeDefined();
    expect(keyManager.publicParentKey).toBeDefined();
  });

  test('signTransaction', async () => {
    const witnessSet = await keyManager.signTransaction({
      body: {
        certificates: [{ __typename: Cardano.CertificateType.StakeRegistration }]
      } as unknown as Cardano.TxBodyAlonzo,
      hash: '8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec'
    });
    expect(Object.keys(witnessSet)).toHaveLength(2);
    expect(typeof witnessSet[Object.keys(witnessSet)[0]]).toBe('string');
  });

  test('rewardAccount', () => {
    expect(keyManager.rewardAccount.startsWith('stake_test')).toBe(true);
  });
});
