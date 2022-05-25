import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../../src';
import { createAsyncKeyAgent } from '../../../src/KeyManagement/util/createAsyncKeyAgent';

describe('createAsyncKeyAgent', () => {
  it('maps KeyAgent to AsyncKeyAgent', async () => {
    const mnemonicWords = KeyManagement.util.generateMnemonicWords();
    const getPassword = jest.fn().mockResolvedValue(Buffer.from('password'));
    const keyAgent = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
      getPassword,
      mnemonicWords,
      networkId: Cardano.NetworkId.testnet
    });
    const asyncKeyAgent = createAsyncKeyAgent(keyAgent);
    const addressDerivationPath = { index: 0, type: 0 };
    await expect(asyncKeyAgent.deriveAddress(addressDerivationPath)).resolves.toEqual(
      await keyAgent.deriveAddress(addressDerivationPath)
    );
    const keyDerivationPath = { index: 0, role: 0 };
    const blob = Cardano.util.HexBlob('abc123');
    await expect(asyncKeyAgent.signBlob(keyDerivationPath, blob)).resolves.toEqual(
      await keyAgent.signBlob(keyDerivationPath, blob)
    );
    const options = { inputAddressResolver: () => null };
    const txInternals = {
      body: { fee: 20_000n, inputs: [], outputs: [], validityInterval: {} } as Cardano.TxBodyAlonzo,
      hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
    };
    await expect(asyncKeyAgent.signTransaction(txInternals, options)).resolves.toEqual(
      await keyAgent.signTransaction(txInternals, options)
    );
    await expect(asyncKeyAgent.getKnownAddresses()).resolves.toEqual(keyAgent.knownAddresses);
  });
});
