/* eslint-disable sonarjs/no-duplicate-string */
// import * as Crypto from '@cardano-sdk/crypto';
import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  CONTEXT_WITHOUT_KNOWN_ADDRESSES,
  CONTEXT_WITH_KNOWN_ADDRESSES,
  poolId,
  poolId2,
  poolParameters,
  stakeKeyHash
} from '../testData';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, KeyRole, util } from '@cardano-sdk/key-management';
import { mapCerts } from '../../src/transformers/certificates';

describe('certificates', () => {
  describe('mapCerts', () => {
    it('returns null when given an undefined token map', async () => {
      const certs: Cardano.Certificate | undefined = undefined;
      const ledgerCerts = mapCerts(certs, CONTEXT_WITHOUT_KNOWN_ADDRESSES);

      expect(ledgerCerts).toEqual(null);
    });

    it('can map a script hash stake registration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash
          }
        ],
        CONTEXT_WITHOUT_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
            }
          },
          type: Ledger.CertificateType.STAKE_REGISTRATION
        }
      ]);
    });

    it('can map a stake key stake registration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              keyPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                KeyRole.Stake,
                0
              ],
              type: Ledger.StakeCredentialParamsType.KEY_PATH
            }
          },
          type: Ledger.CertificateType.STAKE_REGISTRATION
        }
      ]);
    });

    it('can map a script hash stake deregistration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash
          }
        ],
        CONTEXT_WITHOUT_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
            }
          },
          type: Ledger.CertificateType.STAKE_DEREGISTRATION
        }
      ]);
    });

    it('can map a stake key stake deregistration certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            stakeCredential: {
              keyPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                KeyRole.Stake,
                0
              ],
              type: Ledger.StakeCredentialParamsType.KEY_PATH
            }
          },
          type: Ledger.CertificateType.STAKE_DEREGISTRATION
        }
      ]);
    });

    it('can map a pool registration certificate with known keys', async () => {
      expect(
        mapCerts(
          [
            {
              __typename: Cardano.CertificateType.PoolRegistration,
              poolParameters
            }
          ],
          CONTEXT_WITH_KNOWN_ADDRESSES
        )
      ).toEqual([
        {
          params: {
            cost: 1000n,
            margin: {
              denominator: 5,
              numerator: 1
            },
            metadata: {
              metadataHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
              metadataUrl: 'https://example.com'
            },
            pledge: 10_000n,
            poolKey: {
              params: {
                path: [
                  util.harden(CardanoKeyConst.PURPOSE),
                  util.harden(CardanoKeyConst.COIN_TYPE),
                  util.harden(0),
                  2,
                  0
                ]
              },
              type: Ledger.PoolKeyType.DEVICE_OWNED
            },
            poolOwners: [
              {
                params: {
                  stakingPath: [
                    util.harden(CardanoKeyConst.PURPOSE),
                    util.harden(CardanoKeyConst.COIN_TYPE),
                    util.harden(0),
                    2,
                    0
                  ]
                },
                type: Ledger.PoolOwnerType.DEVICE_OWNED
              }
            ],
            relays: [
              {
                params: {
                  dnsName: 'example.com',
                  portNumber: 5000
                },
                type: 1
              },
              {
                params: {
                  ipv4: '127.0.0.1',
                  portNumber: 6000
                },
                type: 0
              },
              {
                params: {
                  dnsName: 'example.com'
                },
                type: 1
              }
            ],
            rewardAccount: {
              params: {
                path: [
                  util.harden(CardanoKeyConst.PURPOSE),
                  util.harden(CardanoKeyConst.COIN_TYPE),
                  util.harden(0),
                  2,
                  0
                ]
              },
              type: Ledger.PoolRewardAccountType.DEVICE_OWNED
            },
            vrfKeyHashHex: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
          },
          type: 3
        }
      ]);
    });

    it('can map a pool registration certificate with unknown keys', async () => {
      expect(
        mapCerts(
          [
            {
              __typename: Cardano.CertificateType.PoolRegistration,
              poolParameters
            }
          ],
          CONTEXT_WITHOUT_KNOWN_ADDRESSES
        )
      ).toEqual([
        {
          params: {
            cost: 1000n,
            margin: {
              denominator: 5,
              numerator: 1
            },
            metadata: {
              metadataHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
              metadataUrl: 'https://example.com'
            },
            pledge: 10_000n,
            poolKey: {
              params: {
                keyHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'
              },
              type: Ledger.PoolKeyType.THIRD_PARTY
            },
            poolOwners: [
              {
                params: {
                  stakingKeyHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'
                },
                type: Ledger.PoolOwnerType.THIRD_PARTY
              }
            ],
            relays: [
              {
                params: {
                  dnsName: 'example.com',
                  portNumber: 5000
                },
                type: 1
              },
              {
                params: {
                  ipv4: '127.0.0.1',
                  portNumber: 6000
                },
                type: 0
              },
              {
                params: {
                  dnsName: 'example.com'
                },
                type: 1
              }
            ],
            rewardAccount: {
              params: {
                rewardAccountHex: 'e1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'
              },
              type: Ledger.PoolRewardAccountType.THIRD_PARTY
            },
            vrfKeyHashHex: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
          },
          type: 3
        }
      ]);
    });

    it('throws if its given a pool retirement certificate but the signing key cant be found', async () => {
      expect(() =>
        mapCerts(
          [
            {
              __typename: Cardano.CertificateType.PoolRetirement,
              epoch: Cardano.EpochNo(500),
              poolId: Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc')
            }
          ],
          CONTEXT_WITHOUT_KNOWN_ADDRESSES
        )
      ).toThrow("Invalid argument 'certificate': Missing key matching pool retirement certificate.");
    });

    it('can map a stake pool retirement certificate', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(500),
            poolId: Cardano.PoolId(poolId)
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            poolKeyPath: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(0),
              KeyRole.Stake,
              0
            ],
            retirementEpoch: 500
          },
          type: Ledger.CertificateType.STAKE_POOL_RETIREMENT
        }
      ]);
    });

    it('can map a delegation certificate with unknown stake key', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: poolId2,
            stakeKeyHash
          }
        ],
        CONTEXT_WITHOUT_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            poolKeyHashHex: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            stakeCredential: {
              scriptHashHex: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
            }
          },
          type: Ledger.CertificateType.STAKE_DELEGATION
        }
      ]);
    });

    it('can map a delegation certificate with known stake key', async () => {
      const ledgerCerts = mapCerts(
        [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: poolId2,
            stakeKeyHash
          }
        ],
        CONTEXT_WITH_KNOWN_ADDRESSES
      );

      expect(ledgerCerts).toEqual([
        {
          params: {
            poolKeyHashHex: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            stakeCredential: {
              keyPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                2,
                0
              ],
              type: Ledger.StakeCredentialParamsType.KEY_PATH
            }
          },
          type: Ledger.CertificateType.STAKE_DELEGATION
        }
      ]);
    });
  });
});
