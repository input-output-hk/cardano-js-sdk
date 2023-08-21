/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { AccountKeyDerivationPath, AddressType, GroupedAddress, KeyRole, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { txOut } from '../../../tx-construction/test/testData';

export const stakeKeyPath = {
  index: 0,
  role: KeyRole.Stake
};

const createGroupedAddress = (
  address: Cardano.PaymentAddress,
  rewardAccount: Cardano.RewardAccount,
  type: AddressType,
  index: number,
  stakeKeyDerivationPath: AccountKeyDerivationPath
  // eslint-disable-next-line max-params
): GroupedAddress =>
  ({
    address,
    index,
    rewardAccount,
    stakeKeyDerivationPath,
    type
  } as GroupedAddress);

describe('KeyManagement.util.ownSignaturePaths', () => {
  const ownRewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
  const otherRewardAccount = Cardano.RewardAccount('stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj');
  const address1 = Cardano.PaymentAddress(
    'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
  );
  const address2 = Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  );

  const ownStakeKeyHash = Cardano.RewardAccount.toHash(ownRewardAccount);
  const otherStakeKeyHash = Cardano.RewardAccount.toHash(otherRewardAccount);

  const knownAddress1 = createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0, stakeKeyPath);

  it('returns distinct derivation paths required to sign the transaction', async () => {
    const txBody = {
      inputs: [{}, {}, {}]
    } as Cardano.TxBody;
    const knownAddresses = [address1, address2].map((address, index) =>
      createGroupedAddress(address, ownRewardAccount, AddressType.External, index, stakeKeyPath)
    );
    const resolveInput = jest
      .fn()
      .mockReturnValueOnce({ ...txOut, address: address1 })
      .mockReturnValueOnce({ ...txOut, address: address2 })
      .mockReturnValueOnce({ ...txOut, address: address1 });
    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInput })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      },
      {
        index: 1,
        role: KeyRole.External
      }
    ]);
  });

  it(
    'does not return stake key derivation path when a StakeKeyRegistration' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash: ownStakeKeyHash }],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;
      const resolveInput = jest
        .fn()
        .mockReturnValueOnce({ ...txOut, address: address1 })
        .mockReturnValueOnce(address1);
      expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
        {
          index: 0,
          role: KeyRole.External
        }
      ]);
    }
  );

  it(
    'returns stake key derivation path when a StakeKeyDeregistration' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, stakeKeyHash: ownStakeKeyHash }],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;
      const resolveInput = jest
        .fn()
        .mockReturnValueOnce({ ...txOut, address: address1 })
        .mockReturnValueOnce(address1);
      expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
        {
          index: 0,
          role: KeyRole.External
        },
        {
          index: 0,
          role: KeyRole.Stake
        }
      ]);
    }
  );

  it(
    'returns stake key derivation path when a StakeDelegation' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [{ __typename: Cardano.CertificateType.StakeDelegation, stakeKeyHash: ownStakeKeyHash }],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;
      const resolveInput = jest
        .fn()
        .mockReturnValueOnce({ ...txOut, address: address1 })
        .mockReturnValueOnce(address1);
      expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
        {
          index: 0,
          role: KeyRole.External
        },
        {
          index: 0,
          role: KeyRole.Stake
        }
      ]);
    }
  );

  // eslint-disable-next-line max-len
  it('returns stake key derivation path when at least one certificate with the wallet stake key hash is present', async () => {
    const txBody = {
      certificates: [
        { __typename: Cardano.CertificateType.StakeDelegation, stakeKeyHash: ownStakeKeyHash },
        { __typename: Cardano.CertificateType.StakeKeyDeregistration, stakeKeyHash: otherStakeKeyHash }
      ],
      inputs: [{}, {}, {}]
    } as Cardano.TxBody;
    const resolveInput = jest
      .fn()
      .mockReturnValueOnce({ ...txOut, address: address1 })
      .mockReturnValueOnce(address1);
    expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      },
      {
        index: 0,
        role: KeyRole.Stake
      }
    ]);
  });

  it(
    'returns stake key derivation path when a PoolRetirement' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(40),
            poolId: Cardano.PoolId.fromKeyHash(ownStakeKeyHash)
          }
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;
      const resolveInput = jest
        .fn()
        .mockReturnValueOnce({ ...txOut, address: address1 })
        .mockReturnValueOnce(address1);
      expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
        {
          index: 0,
          role: KeyRole.External
        },
        {
          index: 0,
          role: KeyRole.Stake
        }
      ]);
    }
  );

  it(
    'returns stake key derivation path when a PoolRegistration' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              cost: 340n,
              id: Cardano.PoolId.fromKeyHash(ownStakeKeyHash),
              margin: {
                denominator: 50,
                numerator: 10
              },
              owners: [ownRewardAccount],
              pledge: 10_000n,
              relays: [
                {
                  __typename: 'RelayByName',
                  hostname: 'localhost'
                }
              ],
              rewardAccount: ownRewardAccount,
              vrf: Cardano.VrfVkHex('641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014')
            }
          }
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;
      const resolveInput = jest
        .fn()
        .mockReturnValueOnce({ ...txOut, address: address1 })
        .mockReturnValueOnce(address1);
      expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
        {
          index: 0,
          role: KeyRole.External
        },
        {
          index: 0,
          role: KeyRole.Stake
        }
      ]);
    }
  );

  it('returns stake key derivation path when a MIR certificate with the wallet stake key hash is present', async () => {
    const txBody = {
      certificates: [
        {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToStakeCreds,
          stakeCredential: Cardano.Address.fromString(ownRewardAccount)!.asReward()!.getPaymentCredential()
        }
      ],
      inputs: [{}, {}, {}]
    } as Cardano.TxBody;
    const resolveInput = jest
      .fn()
      .mockReturnValueOnce({ ...txOut, address: address1 })
      .mockReturnValueOnce(address1);
    expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      },
      {
        index: 0,
        role: KeyRole.Stake
      }
    ]);
  });

  // eslint-disable-next-line max-len
  it('does not return stake key derivation path when no certificate with wallet stake key hash is present', async () => {
    const txBody = {
      certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash: otherStakeKeyHash }],
      inputs: [{}, {}, {}]
    } as Cardano.TxBody;
    const resolveInput = jest
      .fn()
      .mockReturnValueOnce({ ...txOut, address: address1 })
      .mockReturnValueOnce(address1);
    expect(await util.ownSignatureKeyPaths(txBody, [knownAddress1], { resolveInput })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      }
    ]);
  });

  it('signs withdrawals for own reward account', async () => {
    const txBody = {
      inputs: [{}, {}, {}],
      withdrawals: [{ quantity: 1n, stakeAddress: ownRewardAccount }]
    } as Cardano.TxBody;
    const knownAddresses = [createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0, stakeKeyPath)];
    const resolveInput = jest.fn().mockReturnValue({ ...txOut, address: address1 });
    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInput })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      },
      {
        index: 0,
        role: KeyRole.Stake
      }
    ]);
  });

  it('does not sign withdrawals for non-own reward accounts', async () => {
    const txBody = {
      inputs: [{}, {}, {}],
      withdrawals: [{ quantity: 1n, stakeAddress: otherRewardAccount }]
    } as Cardano.TxBody;
    const knownAddresses = [createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0, stakeKeyPath)];
    const resolveInput = jest.fn().mockReturnValue({ ...txOut, address: address1 });
    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInput })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      }
    ]);
  });

  it('returns the derivation path of a known payment credential key hash present in the requiredSigners field', async () => {
    const paymentAddress = Cardano.PaymentAddress(
      'addr1qxdtr6wjx3kr7jlrvrfzhrh8w44qx9krcxhvu3e79zr7497tpmpxjfyhk3vwg6qjezjmlg5nr5dzm9j6nxyns28vsy8stu5lh6'
    );
    const paymentHash = Crypto.Ed25519KeyHashHex('9ab1e9d2346c3f4be360d22b8ee7756a0316c3c1aece473e2887ea97');

    const txBody = {
      inputs: [{}, {}, {}],
      requiredExtraSignatures: [paymentHash]
    } as Cardano.TxBody;
    const knownAddresses = [
      createGroupedAddress(paymentAddress, ownRewardAccount, AddressType.External, 100, stakeKeyPath)
    ];

    const resolveInput = jest.fn().mockReturnValueOnce(null);
    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInput })).toEqual([
      {
        index: 100,
        role: KeyRole.External
      }
    ]);
  });

  it('returns the derivation path of a known stake credential key hash present in the requiredSigners field', async () => {
    const rewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
    const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);

    const txBody = {
      inputs: [{}, {}, {}],
      requiredExtraSignatures: [stakeKeyHash]
    } as Cardano.TxBody;
    const knownAddresses = [createGroupedAddress(address1, rewardAccount, AddressType.External, 0, stakeKeyPath)];
    const resolveInput = jest.fn().mockReturnValue(null);

    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInput })).toEqual([
      {
        index: 0,
        role: KeyRole.Stake
      }
    ]);
  });
});
