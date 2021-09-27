import { createInMemoryKeyManager } from '@src/InMemoryKey';
import { util } from '@src/.';
import { CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '@cardano-sdk/wallet';

describe('InMemoryKeyManager', () => {
  let keyManager: KeyManagement.KeyManager;
  let csl: CardanoSerializationLib;

  beforeEach(async () => {
    csl = await loadCardanoSerializationLib();
    const mnemonic = util.generateMnemonic();
    keyManager = createInMemoryKeyManager({
      csl,
      mnemonic,
      networkId: Cardano.NetworkId.testnet,
      password: '123'
    });
    expect(keyManager.publicKey).toBeInstanceOf(csl.PublicKey);
  });

  test('initial state publicKey', async () => {
    expect(keyManager.publicKey).toBeDefined();
    expect(keyManager.publicParentKey).toBeDefined();
  });

  test('deriveAddress', async () => {
    const address = await keyManager.deriveAddress(0, 0);
    expect(address).toBeDefined();
    expect(keyManager.publicParentKey).toBeDefined();
  });

  test('signTransaction', async () => {
    const txHash = csl.TransactionHash.from_bytes(
      Buffer.from('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec', 'hex')
    );
    const witnessSet = await keyManager.signTransaction(txHash);
    expect(witnessSet).toBeInstanceOf(csl.TransactionWitnessSet);
  });
});
