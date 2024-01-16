import { AsyncKeyAgent, SignBlobResult, Witnesser, util } from '../../src';
import { Cardano, Serialization } from '@cardano-sdk/core';
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
    await expect(
      witnesser.signBlob(keyDerivationPath, blob, {
        address: 'stub' as Cardano.PaymentAddress,
        sender: { url: 'some test' }
      })
    ).resolves.toBe(result);
    expect(asyncKeyAgent.signBlob).toBeCalledWith(keyDerivationPath, blob);
  });

  it('signTransaction is unchanged', async () => {
    const transaction = new Serialization.Transaction(
      Serialization.TransactionBody.fromCore({ fee: 20_000n, inputs: [], outputs: [], validityInterval: {} }),
      new Serialization.TransactionWitnessSet()
    );

    const txInternals = {
      body: transaction.body().toCore(),
      hash: Cardano.TransactionId('3643bb5fe745ba0532977f82ecf54699963c97adef2626f7c780225d218e9ba6')
    };

    const options = { knownAddresses: [], txInKeyPathMap: {} };
    const result = {} as Cardano.Signatures;
    asyncKeyAgent.signTransaction.mockResolvedValueOnce(result);
    await expect(witnesser.witness(transaction, options)).resolves.toEqual({ signatures: result });
    expect(asyncKeyAgent.signTransaction).toBeCalledWith(txInternals, options, void 0);
  });
});
