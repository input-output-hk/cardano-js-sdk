/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { AccountKeyDerivationPath, AddressType, GroupedAddress, KeyRole, TxInId, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';

export const stakeKeyPath = {
  index: 0,
  role: KeyRole.Stake
};

const txId = (seed: number) => Cardano.TransactionId(Array.from({ length: 64 + 1 }).join(seed.toString()));

const toStakeCredential = (stakeKeyHash: Crypto.Hash28ByteBase16): Cardano.Credential => ({
  hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Ed25519KeyHashHex(stakeKeyHash)),
  type: Cardano.CredentialType.KeyHash
});

const createBaseGroupedAddress = (
  address: Cardano.PaymentAddress,
  rewardAccount: Cardano.RewardAccount,
  type: AddressType,
  index: number
) => ({
  address,
  index,
  rewardAccount,
  type
});

const createGroupedAddress = (
  address: Cardano.PaymentAddress,
  rewardAccount: Cardano.RewardAccount,
  type: AddressType,
  index: number,
  stakeKeyDerivationPath?: AccountKeyDerivationPath
) =>
  ({
    ...createBaseGroupedAddress(address, rewardAccount, type, index),
    stakeKeyDerivationPath
  } as GroupedAddress);

const createTestAddresses = () => {
  const otherRewardAccount = Cardano.RewardAccount('stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj');
  const ownRewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
  const address1 = Cardano.PaymentAddress(
    'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
  );
  const address2 = Cardano.PaymentAddress(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  );

  return { address1, address2, otherRewardAccount, ownRewardAccount };
};

describe('KeyManagement.util.ownSignaturePaths', () => {
  const { address1, address2, ownRewardAccount, otherRewardAccount } = createTestAddresses();
  const ownStakeKeyHash = Cardano.RewardAccount.toHash(ownRewardAccount);
  const ownStakeCredential = {
    hash: ownStakeKeyHash,
    type: Cardano.CredentialType.KeyHash
  };

  const otherStakeKeyHash = Cardano.RewardAccount.toHash(otherRewardAccount);
  const otherStakeCredential = {
    hash: otherStakeKeyHash,
    type: Cardano.CredentialType.KeyHash
  };

  let dRepPublicKey: Crypto.Ed25519PublicKeyHex;
  let dRepKeyHash: Crypto.Ed25519KeyHashHex;
  const foreignDRepKeyHash = Crypto.Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');

  const knownAddress1 = createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0, stakeKeyPath);

  beforeAll(() => Crypto.ready());

  beforeEach(async () => {
    dRepPublicKey = Crypto.Ed25519PublicKeyHex('deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01');
    dRepKeyHash = Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash().hex();
  });

  it('returns distinct derivation paths required to sign the transaction', async () => {
    const inputs: Cardano.TxIn[] = [
      { index: 0, txId: txId(0) },
      { index: 1, txId: txId(0) },
      { index: 2, txId: txId(1) }
    ];
    const txBody = { inputs } as Cardano.TxBody;
    const knownAddresses = [address1, address2].map((address, index) =>
      createGroupedAddress(address, ownRewardAccount, AddressType.External, index, stakeKeyPath)
    );

    expect(
      util.ownSignatureKeyPaths(txBody, knownAddresses, {
        [TxInId(inputs[0])]: { index: knownAddresses[0].index, role: Number(knownAddresses[0].type) },
        [TxInId(inputs[1])]: { index: knownAddresses[1].index, role: Number(knownAddresses[1].type) },
        [TxInId(inputs[2])]: { index: knownAddresses[0].index, role: Number(knownAddresses[0].type) }
      })
    ).toEqual([
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
    'does not return stake key derivation path when a StakeRegistration' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [{ __typename: Cardano.CertificateType.StakeRegistration, stakeCredential: ownStakeCredential }],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([]);
    }
  );

  it(
    'returns stake key derivation path when a Conway stake Registration' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.Registration,
            stakeCredential: ownStakeCredential
          } as Cardano.NewStakeAddressCertificate
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([
        {
          index: 0,
          role: KeyRole.Stake
        }
      ]);
    }
  );

  it(
    'returns stake key derivation path when a StakeDeregistration' +
      ' certificate with the wallet stake key hash is present',
    async () => {
      const txBody = {
        certificates: [
          { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential: ownStakeCredential }
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([
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
        certificates: [{ __typename: Cardano.CertificateType.StakeDelegation, stakeCredential: ownStakeCredential }],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([
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
        { __typename: Cardano.CertificateType.StakeDelegation, stakeCredential: ownStakeCredential },
        { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential: otherStakeCredential }
      ],
      inputs: [{}, {}, {}]
    } as Cardano.TxBody;

    expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([
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
            poolId: Cardano.PoolId.fromKeyHash(Ed25519KeyHashHex(ownStakeKeyHash))
          }
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([
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
              id: Cardano.PoolId.fromKeyHash(Ed25519KeyHashHex(ownStakeKeyHash)),
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

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([
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

    expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {})).toEqual([
      {
        index: 0,
        role: KeyRole.Stake
      }
    ]);
  });

  it('does not return derivation paths when all certificates and voting procedures are foreign', async () => {
    const txBody = {
      certificates: [
        { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential: otherStakeCredential },
        { __typename: Cardano.CertificateType.Registration, stakeCredential: otherStakeCredential },
        { __typename: Cardano.CertificateType.VoteDelegation, stakeCredential: otherStakeCredential },
        { __typename: Cardano.CertificateType.StakeVoteDelegation, stakeCredential: otherStakeCredential },
        {
          __typename: Cardano.CertificateType.StakeRegistrationDelegation,
          stakeCredential: otherStakeCredential
        },
        {
          __typename: Cardano.CertificateType.VoteRegistrationDelegation,
          stakeCredential: otherStakeCredential
        },
        {
          __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
          stakeCredential: otherStakeCredential
        },
        { __typename: Cardano.CertificateType.Unregistration, stakeCredential: otherStakeCredential },
        {
          __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
          dRepCredential: {
            hash: foreignDRepKeyHash,
            type: Cardano.CredentialType.KeyHash
          },
          deposit: 0n
        } as Cardano.UnRegisterDelegateRepresentativeCertificate,
        {
          __typename: Cardano.CertificateType.UpdateDelegateRepresentative,
          dRepCredential: {
            hash: foreignDRepKeyHash,
            type: Cardano.CredentialType.KeyHash
          }
        } as Cardano.UpdateDelegateRepresentativeCertificate
      ],
      fee: 0n,
      inputs: [{}, {}, {}] as Cardano.TxIn[],
      outputs: [],
      votingProcedures: [
        {
          voter: {
            __typename: Cardano.VoterType.dRepKeyHash,
            credential: { hash: foreignDRepKeyHash, type: Cardano.CredentialType.KeyHash }
          },
          votes: []
        },
        {
          voter: {
            __typename: Cardano.VoterType.stakePoolKeyHash,
            credential: {
              hash: Crypto.Hash28ByteBase16(otherStakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          },
          votes: []
        }
      ]
    } as Cardano.TxBody;

    expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {}, dRepKeyHash)).toEqual([]);
  });

  it('signs withdrawals for own reward account', async () => {
    const txBody = {
      inputs: [{}, {}, {}],
      withdrawals: [{ quantity: 1n, stakeAddress: ownRewardAccount }]
    } as Cardano.TxBody;
    const knownAddresses = [createGroupedAddress(address1, ownRewardAccount, AddressType.External, 0, stakeKeyPath)];
    expect(util.ownSignatureKeyPaths(txBody, knownAddresses, {})).toEqual([
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
    expect(util.ownSignatureKeyPaths(txBody, knownAddresses, {})).toEqual([]);
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

    expect(util.ownSignatureKeyPaths(txBody, knownAddresses, {})).toEqual([
      {
        index: 100,
        role: KeyRole.External
      }
    ]);
  });

  it('returns the derivation path of a known stake credential key hash present in the requiredSigners field', async () => {
    const rewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
    const stakeKeyHash = Ed25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount));

    const txBody = {
      inputs: [{}, {}, {}],
      requiredExtraSignatures: [stakeKeyHash]
    } as Cardano.TxBody;
    const knownAddresses = [createGroupedAddress(address1, rewardAccount, AddressType.External, 0, stakeKeyPath)];

    expect(util.ownSignatureKeyPaths(txBody, knownAddresses, {})).toEqual([
      {
        index: 0,
        role: KeyRole.Stake
      }
    ]);
  });

  describe('Stake key derivation path', () => {
    const rewardAccounts = [
      'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
      'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d',
      'stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj',
      'stake_test1uzwd0ng8pw7vvhm4k3s28azx9c6ytug60uh35jvztgg03rge58jf8',
      'stake_test1urpklgzqsh9yqz8pkyuxcw9dlszpe5flnxjtl55epla6ftqktdyfz',
      'stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv'
    ]
      .map((acct) => ({ account: Cardano.RewardAccount(acct) }))
      .map(({ account }) => ({ account, stakeKeyHash: Cardano.RewardAccount.toHash(account) }));

    // Using multiple stake keys with one payment key to have separate derivation paths per each certificate
    const knownAddresses = rewardAccounts.map(({ account }, index) =>
      createGroupedAddress(address1, account, AddressType.External, 0, { index, role: KeyRole.Stake })
    );

    it('is returned for certificates with the wallet stake key hash', async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.VoteDelegation,
            stakeCredential: toStakeCredential(rewardAccounts[0].stakeKeyHash)
          },
          {
            __typename: Cardano.CertificateType.StakeVoteDelegation,
            stakeCredential: toStakeCredential(rewardAccounts[1].stakeKeyHash)
          },
          {
            __typename: Cardano.CertificateType.StakeRegistrationDelegation,
            stakeCredential: toStakeCredential(rewardAccounts[2].stakeKeyHash)
          },
          {
            __typename: Cardano.CertificateType.VoteRegistrationDelegation,
            stakeCredential: toStakeCredential(rewardAccounts[3].stakeKeyHash)
          },
          {
            __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
            stakeCredential: toStakeCredential(rewardAccounts[4].stakeKeyHash)
          },
          {
            __typename: Cardano.CertificateType.Unregistration,
            stakeCredential: toStakeCredential(rewardAccounts[5].stakeKeyHash)
          }
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, knownAddresses, {})).toEqual([
        { index: 0, role: KeyRole.Stake },
        { index: 1, role: KeyRole.Stake },
        { index: 2, role: KeyRole.Stake },
        { index: 3, role: KeyRole.Stake },
        { index: 4, role: KeyRole.Stake },
        { index: 5, role: KeyRole.Stake }
      ]);
    });

    it('duplicates are removed when multiple certificates use the wallet stake key hash', async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.VoteDelegation,
            stakeCredential: toStakeCredential(rewardAccounts[0].stakeKeyHash)
          },
          {
            __typename: Cardano.CertificateType.StakeVoteDelegation,
            stakeCredential: toStakeCredential(rewardAccounts[0].stakeKeyHash)
          }
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, knownAddresses, {})).toEqual([{ index: 0, role: KeyRole.Stake }]);
    });

    it('is returned for StakePool voter in voting procedures', async () => {
      const txBody = {
        fee: 0n,
        inputs: [{}, {}, {}] as Cardano.TxIn[],
        outputs: [],
        votingProcedures: [
          {
            voter: {
              __typename: Cardano.VoterType.stakePoolKeyHash,
              credential: {
                hash: Crypto.Hash28ByteBase16(rewardAccounts[3].stakeKeyHash),
                type: Cardano.CredentialType.KeyHash
              }
            },
            votes: []
          }
        ]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, knownAddresses, {})).toEqual([{ index: 3, role: KeyRole.Stake }]);
    });
  });

  describe('DRep key derivation path', () => {
    it('is returned for UnregisterDelegateRepresentative certificate with the wallet dRep key hash', async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
            dRepCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(dRepKeyHash),
              type: Cardano.CredentialType.KeyHash
            },
            deposit: 0n
          } as Cardano.UnRegisterDelegateRepresentativeCertificate
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {}, dRepKeyHash)).toEqual([
        { index: 0, role: KeyRole.DRep }
      ]);
    });

    it('is returned for UpdateDelegateRepresentative certificate with the wallet dRep key hash', async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.UpdateDelegateRepresentative,
            dRepCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(dRepKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.UpdateDelegateRepresentativeCertificate
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {}, dRepKeyHash)).toEqual([
        { index: 0, role: KeyRole.DRep }
      ]);
    });

    it('is returned with a DrepRegistration certificate', async () => {
      const txBody = {
        certificates: [
          {
            __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
            dRepCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(dRepKeyHash),
              type: Cardano.CredentialType.KeyHash
            },
            deposit: 0n
          } as Cardano.RegisterDelegateRepresentativeCertificate
        ],
        inputs: [{}, {}, {}]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {}, dRepKeyHash)).toEqual([
        { index: 0, role: KeyRole.DRep }
      ]);
    });

    it('is returned for DRep voter in voting procedures', async () => {
      const txBody = {
        fee: 0n,
        inputs: [{}, {}, {}] as Cardano.TxIn[],
        outputs: [],
        votingProcedures: [
          {
            voter: {
              __typename: Cardano.VoterType.dRepKeyHash,
              credential: { hash: Crypto.Hash28ByteBase16(dRepKeyHash), type: Cardano.CredentialType.KeyHash }
            },
            votes: []
          }
        ]
      } as Cardano.TxBody;

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {}, dRepKeyHash)).toEqual([
        { index: 0, role: KeyRole.DRep }
      ]);
    });
  });

  describe('Native scripts', () => {
    it('includes derivation paths from native scripts when scripts are provided', async () => {
      const txBody: Cardano.TxBody = {
        fee: BigInt(0),
        inputs: [{}, {}, {}] as Cardano.TxIn[],
        outputs: []
      };

      const scripts: Cardano.Script[] = [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex(ownStakeKeyHash),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ];

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {}, undefined, scripts)).toEqual([
        {
          index: 0,
          role: KeyRole.Stake
        }
      ]);
    });

    it('does not include derivation paths from native scripts with foreign key hashes', async () => {
      const txBody: Cardano.TxBody = {
        fee: BigInt(0),
        inputs: [{}, {}, {}] as Cardano.TxIn[],
        outputs: []
      };

      const scripts: Cardano.Script[] = [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Ed25519KeyHashHex(otherStakeKeyHash),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ];

      expect(util.ownSignatureKeyPaths(txBody, [knownAddress1], {}, undefined, scripts)).toEqual([]);
    });
    it('includes derivation paths for multi-signature native scripts', async () => {
      const scriptAddress = Cardano.PaymentAddress(
        'addr_test1xr806j8xcq6cw6jjkzfxyewyue33zwnu4ajnu28hakp5fmc6gddlgeqee97vwdeafwrdgrtzp2rw8rlchjf25ld7r2ssptq3m9'
      );
      const scriptRewardAccount = Cardano.RewardAccount(
        'stake_test17qdyxkl5vsvujlx8xu75hpk5p43q4phr3lutey420klp4gg7zmhrn'
      );
      const txBody: Cardano.TxBody = {
        fee: BigInt(0),
        inputs: [{}, {}, {}] as Cardano.TxIn[],
        outputs: []
      };

      const scripts: Cardano.Script[] = [
        {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireAnyOf,
          scripts: [
            {
              __type: Cardano.ScriptType.Native,
              keyHash: Ed25519KeyHashHex('b498c0eaceb9a8c7c829d36fc84e892113c9d2636b53b0636d7518b4'),
              kind: Cardano.NativeScriptKind.RequireSignature
            },
            {
              __type: Cardano.ScriptType.Native,
              keyHash: Ed25519KeyHashHex(otherStakeKeyHash),
              kind: Cardano.NativeScriptKind.RequireSignature
            }
          ]
        }
      ];

      const knownAddress = createGroupedAddress(scriptAddress, scriptRewardAccount, AddressType.External, 0);
      expect(util.ownSignatureKeyPaths(txBody, [knownAddress], {}, undefined, scripts)).toEqual([
        {
          index: 0,
          role: KeyRole.External
        }
      ]);
    });
  });
});
