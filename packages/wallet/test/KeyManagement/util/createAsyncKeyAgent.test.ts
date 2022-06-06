import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../../src';
import { firstValueFrom } from 'rxjs';

describe('createAsyncKeyAgent maps KeyAgent to AsyncKeyAgent', () => {
  let keyAgent: KeyManagement.KeyAgent;
  let asyncKeyAgent: KeyManagement.AsyncKeyAgent;
  const addressDerivationPath = { index: 0, type: 0 };

  beforeEach(async () => {
    const mnemonicWords = KeyManagement.util.generateMnemonicWords();
    const getPassword = jest.fn().mockResolvedValue(Buffer.from('password'));
    keyAgent = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
      getPassword,
      mnemonicWords,
      networkId: Cardano.NetworkId.testnet
    });
    asyncKeyAgent = KeyManagement.util.createAsyncKeyAgent(keyAgent);
  });
  it('deriveAddress/signBlob/signTransaction are unchanged', async () => {
    await expect(asyncKeyAgent.deriveAddress(addressDerivationPath)).resolves.toEqual(
      await keyAgent.deriveAddress(addressDerivationPath)
    );
    const keyDerivationPath = { index: 0, role: 0 };
    const blob = Cardano.util.HexBlob('abc123');
    await expect(asyncKeyAgent.signBlob(keyDerivationPath, blob)).resolves.toEqual(
      await keyAgent.signBlob(keyDerivationPath, blob)
    );
    const options: KeyManagement.SignTransactionOptions = { inputAddressResolver: () => Promise.resolve(null) };
    const txInternals = {
      body: { fee: 20_000n, inputs: [], outputs: [], validityInterval: {} } as Cardano.TxBodyAlonzo,
      hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
    };
    await expect(asyncKeyAgent.signTransaction(txInternals, options)).resolves.toEqual(
      await keyAgent.signTransaction(txInternals, options)
    );
  });
  it('knownAddresses$ is emits initial addresses and after new address derivation', async () => {
    await expect(firstValueFrom(asyncKeyAgent.knownAddresses$)).resolves.toEqual(keyAgent.knownAddresses);
    await asyncKeyAgent.deriveAddress(addressDerivationPath);
    await expect(firstValueFrom(asyncKeyAgent.knownAddresses$)).resolves.toEqual(keyAgent.knownAddresses);
  });
  it('stops emitting addresses$ after shutdown', (done) => {
    asyncKeyAgent.shutdown();
    asyncKeyAgent.knownAddresses$.subscribe({
      complete: done,
      next: () => {
        throw new Error('Should not emit');
      }
    });
    void asyncKeyAgent.deriveAddress(addressDerivationPath);
  });
});
