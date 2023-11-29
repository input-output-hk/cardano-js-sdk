import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent, InMemoryKeyAgent, Witnesser, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { dummyLogger } from 'ts-log';

describe('createBip32Ed25519Witnesser', () => {
  let asyncKeyAgent: AsyncKeyAgent;
  let witnesser: Witnesser;
  let inputResolver: jest.Mocked<Cardano.InputResolver>;

  beforeEach(async () => {
    const mnemonicWords = util.generateMnemonicWords();
    const getPassphrase = jest.fn().mockResolvedValue(Buffer.from('password'));
    inputResolver = { resolveInput: jest.fn() };
    const keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preview,
        getPassphrase,
        mnemonicWords
      },
      { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), inputResolver, logger: dummyLogger }
    );
    asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
    witnesser = util.createBip32Ed25519Witnesser(asyncKeyAgent);
  });

  it('signBlob is unchanged', async () => {
    const keyDerivationPath = { index: 0, role: 0 };
    const blob = HexBlob('abc123');

    await expect(asyncKeyAgent.signBlob(keyDerivationPath, blob)).resolves.toEqual(
      await witnesser.signBlob(keyDerivationPath, blob)
    );
  });

  it('signTransaction is unchanged', async () => {
    inputResolver.resolveInput.mockResolvedValue(null);

    const txInternals = {
      body: { fee: 20_000n, inputs: [], outputs: [], validityInterval: {} } as Cardano.HydratedTxBody,
      hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
    };

    await expect(asyncKeyAgent.signTransaction(txInternals)).resolves.toEqual(
      (
        await witnesser.witness(txInternals)
      ).signatures
    );
  });
});
