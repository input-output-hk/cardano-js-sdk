import { Cardano, CSL } from '@cardano-sdk/core';
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
    const txHash = CSL.TransactionHash.from_bytes(
      Buffer.from('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec', 'hex')
    );
    const witnessSet = await keyManager.signTransaction(txHash);
    expect(witnessSet).toBeInstanceOf(CSL.TransactionWitnessSet);
  });
});
