/* eslint-disable sonarjs/no-duplicate-string */
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

const NETWORK_ID = Cardano.NetworkId.testnet;
const ACCOUNT_INDEX = 1;

class MockKeyAgent extends KeyManagement.KeyAgentBase {
  constructor(data: KeyManagement.SerializableInMemoryKeyAgentData) {
    super(data);
  }

  serializableDataImpl = jest.fn();
  signBlob = jest.fn();
  exportRootPrivateKey = jest.fn();
  deriveCslPublicKeyPublic(derivationPath: KeyManagement.AccountKeyDerivationPath) {
    return this.deriveCslPublicKey(derivationPath);
  }
}

jest.mock('../../src/KeyManagement/util/ownSignatureKeyPaths');
const { ownSignatureKeyPaths } = jest.requireMock('../../src/KeyManagement/util/ownSignatureKeyPaths');

describe('KeyAgentBase', () => {
  let keyAgent: MockKeyAgent;

  beforeAll(() => {
    keyAgent = new MockKeyAgent({
      __typename: KeyManagement.KeyAgentType.InMemory,
      accountIndex: ACCOUNT_INDEX,
      encryptedRootPrivateKeyBytes: [],
      extendedAccountPublicKey: Cardano.Bip32PublicKey(
        // eslint-disable-next-line max-len
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      ),
      knownAddresses: [],
      networkId: NETWORK_ID
    });
  });

  afterEach(() => {
    keyAgent.signBlob.mockReset();
  });
  // eslint-disable-next-line max-len
  // extpubkey:  return '781ad7d97e043e3790e6a94111e2e65b5a5e584a3e542f4655f7794f80d2a081ee571e58e8982b6a549d9090df6d86b6bb2afc69a226eee44ac7f3e3e1da9a14';

  test('deriveAddress', async () => {
    const paymentKey = 'b524f4627318819891efe52da641e05604168e508c3cc9f3e13945f21b69afa0';
    const stakeKey = '6a27d881ef58bd3816f60c05a5fbe872726e76fc239985fde9dcb9a8d7e582e8';
    keyAgent.derivePublicKey = jest.fn().mockResolvedValueOnce(paymentKey).mockResolvedValueOnce(stakeKey);

    const index = 1;
    const type = KeyManagement.AddressType.External;
    const address = await keyAgent.deriveAddress({ index, type });
    expect(address.index).toBe(index);
    expect(address.type).toBe(type);
    expect(address.accountIndex).toBe(ACCOUNT_INDEX);
    expect(address.networkId).toBe(NETWORK_ID);
    expect(address.address.startsWith('addr_test')).toBe(true);
    expect(address.rewardAccount.startsWith('stake_test')).toBe(true);
    expect(keyAgent.knownAddresses).toHaveLength(1);
  });

  test('signTransaction', async () => {
    ownSignatureKeyPaths.mockReturnValueOnce([
      { index: 0, role: 0 },
      { index: 0, role: 2 }
    ]);
    keyAgent.signBlob
      .mockResolvedValueOnce({ publicKey: 'key1', signature: 'signature1' })
      .mockResolvedValueOnce({ publicKey: 'key2', signature: 'signature2' });
    const body = {} as unknown as Cardano.TxBodyAlonzo;
    const inputAddressResolver = {} as KeyManagement.InputAddressResolver;
    const options = { inputAddressResolver } as KeyManagement.SignTransactionOptions;
    const witnessSet = await keyAgent.signTransaction(
      {
        body,
        hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
      },
      options
    );
    expect(keyAgent.signBlob).toBeCalledTimes(2);
    expect(ownSignatureKeyPaths).toBeCalledWith(body, keyAgent.knownAddresses, inputAddressResolver);
    expect(witnessSet.size).toBe(2);
    expect(typeof [...witnessSet.values()][0]).toBe('string');
  });

  test('derivePublicKey', async () => {
    const externalPublicKey = await keyAgent.derivePublicKey({ index: 1, role: KeyManagement.KeyRole.External });
    expect(typeof externalPublicKey).toBe('string');
    const stakePublicKey = await keyAgent.derivePublicKey({ index: 1, role: KeyManagement.KeyRole.Stake });
    expect(typeof stakePublicKey).toBe('string');
  });

  test('deriveCslPublicKey', async () => {
    expect(await keyAgent.deriveCslPublicKeyPublic({ index: 0, role: KeyManagement.KeyRole.External })).toBeInstanceOf(
      CSL.PublicKey
    );
  });
});
