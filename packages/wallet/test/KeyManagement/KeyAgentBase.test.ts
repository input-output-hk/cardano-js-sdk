/* eslint-disable sonarjs/no-duplicate-string */
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

const NETWORK_ID = Cardano.NetworkId.testnet;
const ACCOUNT_INDEX = 1;

class MockKeyAgent extends KeyManagement.KeyAgentBase {
  get networkId(): Cardano.NetworkId {
    return NETWORK_ID;
  }
  get accountIndex(): number {
    return ACCOUNT_INDEX;
  }
  get serializableData() {
    return this.serializableDataImpl();
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
  });

  describe('signTransaction', () => {
    it('signs with payment key only for tx with no certificates', async () => {
      const publicKey = 'publicKey';
      const signature = 'signature';
      keyAgent.signBlob.mockResolvedValueOnce({ publicKey, signature });

      const hash = Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec');
      const witnessSet = await keyAgent.signTransaction({
        body: { certificates: [] } as unknown as Cardano.TxBodyAlonzo,
        hash
      });

      expect(keyAgent.signBlob).toBeCalledTimes(1);
      expect(keyAgent.signBlob).toBeCalledWith({ index: 0, type: KeyManagement.KeyType.External }, hash);
      expect(witnessSet.size).toBe(1);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect(witnessSet.get(publicKey as any)).toBe(signature);
    });

    it('signs with both payment and stake key for tx with certificates', async () => {
      const paymentPublicKey = 'publicKey1';
      const paymentSignature = 'signature1';
      const stakePublicKey = 'publicKey2';
      const stakeSignature = 'signature2';
      keyAgent.signBlob
        .mockResolvedValueOnce({ publicKey: paymentPublicKey, signature: paymentSignature })
        .mockResolvedValueOnce({ publicKey: stakePublicKey, signature: stakeSignature });

      const hash = Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec');
      const witnessSet = await keyAgent.signTransaction({
        body: {
          certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration }]
        } as unknown as Cardano.TxBodyAlonzo,
        hash
      });

      expect(keyAgent.signBlob).toBeCalledTimes(2);
      expect(keyAgent.signBlob).toBeCalledWith({ index: 0, type: KeyManagement.KeyType.External }, hash);
      expect(keyAgent.signBlob).toBeCalledWith({ index: 0, type: KeyManagement.KeyType.Stake }, hash);
      expect(witnessSet.size).toBe(2);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect(witnessSet.get(paymentPublicKey as any)).toBe(paymentSignature);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect(witnessSet.get(stakePublicKey as any)).toBe(stakeSignature);
    });
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
