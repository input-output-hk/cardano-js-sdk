import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent, InMemoryKeyAgent, KeyAgent, util } from '../../src';
import { CML, Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { dummyLogger } from 'ts-log';
import { firstValueFrom } from 'rxjs';

describe('createAsyncKeyAgent maps KeyAgent to AsyncKeyAgent', () => {
  let keyAgent: KeyAgent;
  let asyncKeyAgent: AsyncKeyAgent;
  let inputResolver: jest.Mocked<Cardano.util.InputResolver>;
  const addressDerivationPath = { index: 0, type: 0 };

  beforeEach(async () => {
    const mnemonicWords = util.generateMnemonicWords();
    const getPassword = jest.fn().mockResolvedValue(Buffer.from('password'));
    inputResolver = { resolveInputAddress: jest.fn() };
    keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preview,
        getPassword,
        mnemonicWords
      },
      { bip32Ed25519: new Crypto.CmlBip32Ed25519(CML), inputResolver, logger: dummyLogger }
    );
    asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  });
  it('getChainId resolves with chainId', async () => {
    expect(await asyncKeyAgent.getChainId()).toEqual(keyAgent.chainId);
  });
  it('deriveAddress/signBlob/signTransaction are unchanged', async () => {
    await expect(asyncKeyAgent.deriveAddress(addressDerivationPath)).resolves.toEqual(
      await keyAgent.deriveAddress(addressDerivationPath)
    );
    const keyDerivationPath = { index: 0, role: 0 };
    const blob = HexBlob('abc123');
    await expect(asyncKeyAgent.signBlob(keyDerivationPath, blob)).resolves.toEqual(
      await keyAgent.signBlob(keyDerivationPath, blob)
    );
    inputResolver.resolveInputAddress.mockResolvedValue(null);
    const txInternals = {
      body: { fee: 20_000n, inputs: [], outputs: [], validityInterval: {} } as Cardano.HydratedTxBody,
      hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
    };
    await expect(asyncKeyAgent.signTransaction(txInternals)).resolves.toEqual(
      await keyAgent.signTransaction(txInternals)
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
