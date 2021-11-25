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
  });

  test('initial state has extendedAccountPublicKey', () => {
    expect(keyManager.extendedAccountPublicKey).toBeInstanceOf(CSL.Bip32PublicKey);
  });

  test('derivePublicKey', () => {
    expect(keyManager.derivePublicKey(KeyManagement.KeyType.Stake, 1)).toBeInstanceOf(CSL.PublicKey);
  });

  test('deriveAddress', async () => {
    const address = await keyManager.deriveAddress(0, 0);
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
});
