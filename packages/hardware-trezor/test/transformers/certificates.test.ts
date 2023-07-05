import * as Trezor from 'trezor-connect';
import { Cardano } from '@cardano-sdk/core';
import { CardanoKeyConst, KeyRole, util } from '@cardano-sdk/key-management';
import {
  contextWithKnownAddresses,
  contextWithKnownAddressesWithoutStakingCredentials,
  contextWithoutKnownAddresses,
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
            type: Trezor.CardanoCertificateType.STAKE_REGISTRATION
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
            type: Trezor.CardanoCertificateType.STAKE_DEREGISTRATION
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
            type: Trezor.CardanoCertificateType.STAKE_REGISTRATION
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
            type: Trezor.CardanoCertificateType.STAKE_DEREGISTRATION
          }
        ]);
      });

      it('can map a script hash stake registration certificate', async () => {
        const certificates = mapCerts([stakeRegistrationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.CardanoCertificateType.STAKE_REGISTRATION
          }
        ]);
      });

      it('can map a script hash stake deregistration certificate', async () => {
        const certificates = mapCerts([stakeDeregistrationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.CardanoCertificateType.STAKE_DEREGISTRATION
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
            type: Trezor.CardanoCertificateType.STAKE_DELEGATION
          }
        ]);
      });

      it('can map a delegation certificate with unknown stake key', async () => {
        const certificates = mapCerts([stakeDelegationCertificate], contextWithoutKnownAddresses);

        expect(certificates).toEqual([
          {
            pool: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            type: Trezor.CardanoCertificateType.STAKE_DELEGATION
          }
        ]);
      });

      it('can map a delegation certificate with known address and unknown stake key', async () => {
        const certificates = mapCerts([stakeDelegationCertificate], contextWithKnownAddressesWithoutStakingCredentials);

        expect(certificates).toEqual([
          {
            keyHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
            pool: '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf',
            type: Trezor.CardanoCertificateType.STAKE_DELEGATION
          }
        ]);
      });
    });
  });
});
