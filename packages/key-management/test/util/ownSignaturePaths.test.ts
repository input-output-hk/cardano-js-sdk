import { AddressType, GroupedAddress, KeyRole, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';

const createGroupedAddress = (
  address: Cardano.Address,
  rewardAccount: Cardano.RewardAccount,
  type: AddressType,
  index: number
): GroupedAddress =>
  ({
    address,
    index,
    rewardAccount,
    type
  } as GroupedAddress);

describe('KeyManagement.util.ownSignaturePaths', () => {
  const ownRewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
  const otherRewardAccount = Cardano.RewardAccount('stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj');
  const address1 = Cardano.Address(
    'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
  );
  const address2 = Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  );

  it('returns distinct derivation paths required to sign the transaction', async () => {
    const txBody = {
      certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration }],
      inputs: [{}, {}, {}]
    } as Cardano.TxBody;
    const knownAddresses = [address1, address2].map((address, index) =>
      createGroupedAddress(address, ownRewardAccount, AddressType.External, index)
    );
    const resolveInputAddress = jest
      .fn()
      .mockReturnValueOnce(address1)
      .mockReturnValueOnce(address2)
      .mockReturnValueOnce(address1);
    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInputAddress })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      },
      {
        index: 1,
        role: KeyRole.External
      },
      {
        index: 0,
        role: KeyRole.Stake
      }
    ]);
  });

  it('signs withdrawals for own reward account', async () => {
    const txBody = {
      inputs: [{}, {}, {}],
      withdrawals: [{ quantity: 1n, stakeAddress: ownRewardAccount }]
    } as Cardano.TxBody;
    const knownAddresses = [createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0)];
    const resolveInputAddress = jest.fn().mockReturnValue(address1);
    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInputAddress })).toEqual([
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
    const knownAddresses = [createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0)];
    const resolveInputAddress = jest.fn().mockReturnValue(address1);
    expect(await util.ownSignatureKeyPaths(txBody, knownAddresses, { resolveInputAddress })).toEqual([
      {
        index: 0,
        role: KeyRole.External
      }
    ]);
  });
});
