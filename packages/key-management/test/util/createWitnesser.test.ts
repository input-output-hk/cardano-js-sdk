import { AsyncKeyAgent, SignBlobResult, Witnesser, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';

describe('createBip32Ed25519Witnesser', () => {
  let asyncKeyAgent: jest.Mocked<AsyncKeyAgent>;
  let witnesser: Witnesser;

  beforeEach(async () => {
    asyncKeyAgent = {
      signBlob: jest.fn(),
      signTransaction: jest.fn()
    } as unknown as jest.Mocked<AsyncKeyAgent>;
    witnesser = util.createBip32Ed25519Witnesser(asyncKeyAgent);
  });

  it('signBlob is unchanged', async () => {
    const keyDerivationPath = { index: 0, role: 0 };
    const blob = HexBlob('abc123');
    const result = {} as SignBlobResult;
    asyncKeyAgent.signBlob.mockResolvedValueOnce(result);
    await expect(witnesser.signBlob(keyDerivationPath, blob)).resolves.toBe(result);
    expect(asyncKeyAgent.signBlob).toBeCalledWith(keyDerivationPath, blob);
  });

  it('signTransaction is unchanged', async () => {
    const txInternals = {
      body: { fee: 20_000n, inputs: [], outputs: [], validityInterval: {} } as Cardano.HydratedTxBody,
      hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
    };
    const options = { knownAddresses: [], txInKeyPathMap: {} };
    const result = {} as Cardano.Signatures;
    asyncKeyAgent.signTransaction.mockResolvedValueOnce(result);
    await expect(witnesser.witness(txInternals, options)).resolves.toEqual({ signatures: result });
    expect(asyncKeyAgent.signTransaction).toBeCalledWith(txInternals, options, void 0);
  });
});
