/* eslint-disable sonarjs/no-duplicate-string */
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

const NETWORK_ID = Cardano.NetworkId.testnet;
const ACCOUNT_INDEX = 1;

class MockKeyAgent extends KeyManagement.KeyAgentBase {
  #knownAddresses = [];
  get networkId(): Cardano.NetworkId {
    return NETWORK_ID;
  }
  get accountIndex(): number {
    return ACCOUNT_INDEX;
  }
  get serializableData() {
    return this.serializableDataImpl();
  }
  get knownAddresses(): KeyManagement.GroupedAddress[] {
    return this.#knownAddresses;
  }
  serializableDataImpl = jest.fn();
  getExtendedAccountPublicKey = jest.fn();
  signBlob = jest.fn();
  derivePublicKey = jest.fn();
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
    keyAgent = new MockKeyAgent();
  });

  afterEach(() => {
    keyAgent.derivePublicKey.mockReset();
    keyAgent.signBlob.mockReset();
  });
  // eslint-disable-next-line max-len
  // extpubkey:  return '781ad7d97e043e3790e6a94111e2e65b5a5e584a3e542f4655f7794f80d2a081ee571e58e8982b6a549d9090df6d86b6bb2afc69a226eee44ac7f3e3e1da9a14';

  test('deriveAddress', async () => {
    const paymentKey = 'b524f4627318819891efe52da641e05604168e508c3cc9f3e13945f21b69afa0';
    const stakeKey = '6a27d881ef58bd3816f60c05a5fbe872726e76fc239985fde9dcb9a8d7e582e8';
    keyAgent.derivePublicKey.mockResolvedValueOnce(paymentKey).mockResolvedValueOnce(stakeKey);

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
    const witnessSet = await keyAgent.signTransaction({
      body,
      hash: Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec')
    });
    expect(keyAgent.signBlob).toBeCalledTimes(2);
    expect(ownSignatureKeyPaths).toBeCalledWith(body, keyAgent.knownAddresses);
    expect(witnessSet.size).toBe(2);
    expect(typeof [...witnessSet.values()][0]).toBe('string');
  });

  test('deriveCslPublicKey', async () => {
    const publicKey = 'b524f4627318819891efe52da641e05604168e508c3cc9f3e13945f21b69afa0';
    keyAgent.derivePublicKey.mockResolvedValueOnce(publicKey);
    expect(await keyAgent.deriveCslPublicKeyPublic({} as KeyManagement.AccountKeyDerivationPath)).toBeInstanceOf(
      CSL.PublicKey
    );
    expect(keyAgent.derivePublicKey).toBeCalledTimes(1);
  });
});
