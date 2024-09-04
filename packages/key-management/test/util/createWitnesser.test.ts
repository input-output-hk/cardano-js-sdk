import { AsyncKeyAgent, Witnesser, util } from '../../src';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { HexBlob } from '@cardano-sdk/util';

describe('createBip32Ed25519Witnesser', () => {
  let asyncKeyAgent: jest.Mocked<AsyncKeyAgent>;
  let witnesser: Witnesser;

  beforeEach(async () => {
    asyncKeyAgent = {
      signBlob: jest.fn(),
      signCip8Data: jest.fn(),
      signTransaction: jest.fn()
    } as unknown as jest.Mocked<AsyncKeyAgent>;
    witnesser = util.createBip32Ed25519Witnesser(asyncKeyAgent);
  });

  it('signData is unchanged', async () => {
    const blob = HexBlob('abc123');
    const result = {} as Cip30DataSignature;
    const props = {
      knownAddresses: [],
      payload: blob,
      sender: { url: 'some test' },
      signWith: 'stub' as Cardano.PaymentAddress
    };
    asyncKeyAgent.signCip8Data.mockResolvedValueOnce(result);
    await expect(witnesser.signData(props)).resolves.toBe(result);
    expect(asyncKeyAgent.signCip8Data).toBeCalledWith(props);
  });

  it('signTransaction is unchanged', async () => {
    const transaction = new Serialization.Transaction(
      Serialization.TransactionBody.fromCore({ fee: 20_000n, inputs: [], outputs: [], validityInterval: {} }),
      new Serialization.TransactionWitnessSet()
    );

    const options = { knownAddresses: [], txInKeyPathMap: {} };
    const result = new Map();
    asyncKeyAgent.signTransaction.mockResolvedValueOnce(result);

    const witnessTx = await witnesser.witness(transaction, options);
    await expect(witnessTx.tx.witness).toEqual({ signatures: result });
    expect(asyncKeyAgent.signTransaction).toBeCalledWith(transaction.body(), options, void 0);
  });
});
