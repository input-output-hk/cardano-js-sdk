/* eslint-disable sonarjs/no-duplicate-string */
import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, KeyRole, util } from '@cardano-sdk/key-management';
import {
  contextWithKnownAddresses,
  contextWithKnownAddressesWithoutStakingCredentials,
  contextWithoutKnownAddresses,
  conwayDeregistrationCertificate,
  conwayRegistrationCertificate,
  poolRegistrationCertificate,
  stakeCredential,
  stakeDelegationCertificate,
  stakeDeregistrationCertificate,
  stakeRegistrationCertificate
} from '../testData';
import { mapCerts } from '../../src/transformers';

describe('certificates', () => {
  describe('mapCerts', () => {
    it('returns an empty array if there are no certificates', async () => {
      const certs: Cardano.Certificate[] = [];
      const trezorCerts = mapCerts(certs, contextWithKnownAddresses);

      expect(trezorCerts).toEqual([]);
    });

    describe('stake registration and deregistration certificates', () => {
      it('can map a stake key stake registration certificate', async () => {
        const certificates = mapCerts([stakeRegistrationCertificate], contextWithKnownAddresses);

        expect(certificates).toEqual([
          {
            path: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(0),
              KeyRole.Stake,
              0
            ],
            type: Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION
          }
        ]);
      });

      it('can map a stake key stake deregistration certificate', async () => {
        const certificates = mapCerts([stakeDeregistrationCertificate], contextWithKnownAddresses);

        expect(certificates).toEqual([
          {
            path: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(0),
              KeyRole.Stake,
              0
            ],
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION
          }
        ]);
      });

      it('can map a key hash stake registration certificate', async () => {
        const certificates = mapCerts(
          [stakeRegistrationCertificate],
          contextWithKnownAddressesWithoutStakingCredentials
        );

        expect(certificates).toEqual([
          {
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION
          }
        ]);
      });

      it('can map a key hash stake deregistration certificate', async () => {
        const certificates = mapCerts(
          [stakeDeregistrationCertificate],
          contextWithKnownAddressesWithoutStakingCredentials
        );

        expect(certificates).toEqual([
          {
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION
          }
        ]);
      });

      it('can map a script hash stake registration certificate', async () => {
        const certificates = mapCerts([stakeRegistrationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION
          }
        ]);
      });

      it('can map a script hash stake deregistration certificate', async () => {
        const certificates = mapCerts([stakeDeregistrationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION
          }
        ]);
      });
    });

    describe('stake delegation certificates', () => {
      it('can map a delegation certificate with known stake key', async () => {
        const certificates = mapCerts([stakeDelegationCertificate], contextWithKnownAddresses);

        expect(certificates).toEqual([
          {
            path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 2, 0],
            pool: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DELEGATION
          }
        ]);
      });

      it('can map a delegation certificate with unknown stake key', async () => {
        const certificates = mapCerts([stakeDelegationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            pool: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DELEGATION
          }
        ]);
      });

      it('can map a delegation certificate with known address and unknown stake key', async () => {
        const certificates = mapCerts([stakeDelegationCertificate], contextWithKnownAddressesWithoutStakingCredentials);

        expect(certificates).toEqual([
          {
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            pool: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DELEGATION
          }
        ]);
      });
    });

    describe('pool registration certificates', () => {
      it('can map a pool registration certificate with known keys', async () => {
        expect(mapCerts([poolRegistrationCertificate], contextWithKnownAddresses)).toEqual([
          {
            poolParameters: {
              cost: '1000',
              margin: {
                denominator: '5',
                numerator: '1'
              },
              metadata: {
                hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
                url: 'https://example.com'
              },
              owners: [
                {
                  stakingKeyPath: [
                    util.harden(CardanoKeyConst.PURPOSE),
                    util.harden(CardanoKeyConst.COIN_TYPE),
                    util.harden(0),
                    2,
                    0
                  ]
                }
              ],
              pledge: '10000',
              poolId: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              relays: [
                {
                  ipv4Address: '127.0.0.1',
                  port: 6000,
                  type: 0
                },
                {
                  hostName: 'example.com',
                  port: 5000,
                  type: 1
                },
                {
                  hostName: 'example.com',
                  type: 2
                }
              ],
              rewardAccount: 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr',
              vrfKeyHash: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
            },
            type: Trezor.PROTO.CardanoCertificateType.STAKE_POOL_REGISTRATION
          }
        ]);
      });

      it('can map a pool registration certificate with unknown keys', async () => {
        expect(mapCerts([poolRegistrationCertificate], contextWithoutKnownAddresses)).toEqual([
          {
            poolParameters: {
              cost: '1000',
              margin: {
                denominator: '5',
                numerator: '1'
              },
              metadata: {
                hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
                url: 'https://example.com'
              },
              owners: [{ stakingKeyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f' }],
              pledge: '10000',
              poolId: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              relays: [
                {
                  ipv4Address: '127.0.0.1',
                  port: 6000,
                  type: 0
                },
                {
                  hostName: 'example.com',
                  port: 5000,
                  type: 1
                },
                {
                  hostName: 'example.com',
                  type: 2
                }
              ],
              rewardAccount: 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr',
              vrfKeyHash: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
            },
            type: Trezor.PROTO.CardanoCertificateType.STAKE_POOL_REGISTRATION
          }
        ]);
      });
    });

    describe('conway registration and deregistration certificates', () => {
      it('can map a registration certificate', async () => {
        const certificates = mapCerts([conwayRegistrationCertificate], contextWithKnownAddresses);

        expect(certificates).toEqual([
          {
            deposit: '10000000',
            path: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(0),
              KeyRole.Stake,
              0
            ],
            type: Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION_CONWAY
          }
        ]);
      });

      it('can map a stake key stake deregistration certificate', async () => {
        const certificates = mapCerts([conwayDeregistrationCertificate], contextWithKnownAddresses);

        expect(certificates).toEqual([
          {
            deposit: '10000000',
            path: [
              util.harden(CardanoKeyConst.PURPOSE),
              util.harden(CardanoKeyConst.COIN_TYPE),
              util.harden(0),
              KeyRole.Stake,
              0
            ],
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION_CONWAY
          }
        ]);
      });

      it('can map a key hash stake registration certificate', async () => {
        const certificates = mapCerts(
          [conwayRegistrationCertificate],
          contextWithKnownAddressesWithoutStakingCredentials
        );

        expect(certificates).toEqual([
          {
            deposit: '10000000',
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION_CONWAY
          }
        ]);
      });

      it('can map a key hash stake deregistration certificate', async () => {
        const certificates = mapCerts(
          [conwayDeregistrationCertificate],
          contextWithKnownAddressesWithoutStakingCredentials
        );

        expect(certificates).toEqual([
          {
            deposit: '10000000',
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION_CONWAY
          }
        ]);
      });

      it('can map a script hash stake registration certificate', async () => {
        const certificates = mapCerts([conwayRegistrationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            deposit: '10000000',
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION_CONWAY
          }
        ]);
      });

      it('can map a script hash stake deregistration certificate', async () => {
        const certificates = mapCerts([conwayDeregistrationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            deposit: '10000000',
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION_CONWAY
          }
        ]);
      });
    });

    describe('Cardano.CertificateType.VoteDelegation', () => {
      it('can map always abstain type of drep', () => {
        const trezorCerts = mapCerts(
          [
            {
              __typename: Cardano.CertificateType.VoteDelegation,
              dRep: { __typename: 'AlwaysAbstain' },
              stakeCredential
            }
          ],
          contextWithKnownAddressesWithoutStakingCredentials
        );

        expect(trezorCerts).toEqual([
          {
            dRep: {
              type: Trezor.PROTO.CardanoDRepType.ABSTAIN
            },
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.VOTE_DELEGATION
          }
        ]);
      });
      it('can map always no confidence type of drep', () => {
        const trezorCerts = mapCerts(
          [
            {
              __typename: Cardano.CertificateType.VoteDelegation,
              dRep: { __typename: 'AlwaysNoConfidence' },
              stakeCredential
            }
          ],
          contextWithKnownAddressesWithoutStakingCredentials
        );

        expect(trezorCerts).toEqual([
          {
            dRep: {
              type: Trezor.PROTO.CardanoDRepType.NO_CONFIDENCE
            },
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.VOTE_DELEGATION
          }
        ]);
      });
      it('can map dRep credential type of drep', () => {
        const trezorCerts = mapCerts(
          [
            {
              __typename: Cardano.CertificateType.VoteDelegation,
              dRep: stakeCredential,
              stakeCredential
            }
          ],
          contextWithKnownAddressesWithoutStakingCredentials
        );

        expect(trezorCerts).toEqual([
          {
            dRep: {
              keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
              type: Trezor.PROTO.CardanoDRepType.KEY_HASH
            },
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.PROTO.CardanoCertificateType.VOTE_DELEGATION
          }
        ]);
      });
    });
  });
});
