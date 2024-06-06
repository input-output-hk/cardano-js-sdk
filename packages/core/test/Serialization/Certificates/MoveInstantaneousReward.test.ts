/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { MoveInstantaneousReward } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('MoveInstantaneousReward', () => {
  describe('toOtherPot', () => {
    it('can decode toOtherPot MoveInstantaneousReward from CBOR', () => {
      const cborUseReserves = HexBlob('820682001a000f4240');
      const cborUseTreasury = HexBlob('820682011a000f4240');

      const certUseReserves = MoveInstantaneousReward.fromCbor(cborUseReserves);
      const certUseTreasury = MoveInstantaneousReward.fromCbor(cborUseTreasury);

      expect(certUseReserves.asToOtherPot()?.pot()).toEqual(Cardano.MirCertificatePot.Reserves);
      expect(certUseReserves.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
      expect(certUseTreasury.asToOtherPot()?.pot()).toEqual(Cardano.MirCertificatePot.Treasury);
      expect(certUseTreasury.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
    });

    it('can decode toOtherPot MoveInstantaneousReward from Core', () => {
      const coreUseReservers: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToOtherPot,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 1_000_000n
      };

      const coreUseTreasury: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToOtherPot,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 1_000_000n
      };

      const certUseReserves = MoveInstantaneousReward.fromCore(coreUseReservers);
      const certUseTreasury = MoveInstantaneousReward.fromCore(coreUseTreasury);

      expect(certUseReserves.asToOtherPot()?.pot()).toEqual(Cardano.MirCertificatePot.Reserves);
      expect(certUseReserves.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
      expect(certUseTreasury.asToOtherPot()?.pot()).toEqual(Cardano.MirCertificatePot.Treasury);
      expect(certUseTreasury.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
    });

    it('can encode toOtherPot MoveInstantaneousReward to CBOR', () => {
      const coreUseReservers: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToOtherPot,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 1_000_000n
      };

      const coreUseTreasury: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToOtherPot,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 1_000_000n
      };

      const certUseReserves = MoveInstantaneousReward.fromCore(coreUseReservers);
      const certUseTreasury = MoveInstantaneousReward.fromCore(coreUseTreasury);

      expect(certUseReserves.toCbor()).toEqual('820682001a000f4240');
      expect(certUseTreasury.toCbor()).toEqual('820682011a000f4240');
    });

    it('can encode toOtherPot MoveInstantaneousReward to Core', () => {
      const cborUseReserves = HexBlob('820682001a000f4240');
      const cborUseTreasury = HexBlob('820682011a000f4240');

      const certUseReserves = MoveInstantaneousReward.fromCbor(cborUseReserves);
      const certUseTreasury = MoveInstantaneousReward.fromCbor(cborUseTreasury);

      expect(certUseReserves.toCore()).toEqual({
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToOtherPot,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 1_000_000n
      });

      expect(certUseTreasury.toCore()).toEqual({
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToOtherPot,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 1_000_000n
      });
    });
  });

  describe('toStakeCreds', () => {
    it('can decode toStakeCreds MoveInstantaneousReward from CBOR', () => {
      const cborUseReserves = HexBlob('82068200a18200581c0101010101010101010101010101010101010101010101010101010100');
      const cborUseTreasury = HexBlob('82068201a18200581c0101010101010101010101010101010101010101010101010101010100');

      const certUseReserves = MoveInstantaneousReward.fromCbor(cborUseReserves);
      const certUseTreasury = MoveInstantaneousReward.fromCbor(cborUseTreasury);

      expect(certUseReserves.asToStakeCreds()?.pot()).toEqual(Cardano.MirCertificatePot.Reserves);
      expect(certUseReserves.asToStakeCreds()?.getStakeCreds()).toEqual(
        new Map([
          [
            {
              hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
              type: Cardano.CredentialType.KeyHash
            },
            0n
          ]
        ])
      );
      expect(certUseTreasury.asToStakeCreds()?.pot()).toEqual(Cardano.MirCertificatePot.Treasury);
      expect(certUseTreasury.asToStakeCreds()?.getStakeCreds()).toEqual(
        new Map([
          [
            {
              hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
              type: Cardano.CredentialType.KeyHash
            },
            0n
          ]
        ])
      );
    });

    it('can decode toStakeCreds MoveInstantaneousReward from Core', () => {
      const coreUseReserves: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 0n,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
          type: Cardano.CredentialType.KeyHash
        }
      };

      const coreUseTreasury: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 0n,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
          type: Cardano.CredentialType.KeyHash
        }
      };

      const certUseReserves = MoveInstantaneousReward.fromCore(coreUseReserves);
      const certUseTreasury = MoveInstantaneousReward.fromCore(coreUseTreasury);

      expect(certUseReserves.asToStakeCreds()?.pot()).toEqual(Cardano.MirCertificatePot.Reserves);
      expect(certUseReserves.asToStakeCreds()?.getStakeCreds()).toEqual(
        new Map([
          [
            {
              hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
              type: Cardano.CredentialType.KeyHash
            },
            0n
          ]
        ])
      );
      expect(certUseTreasury.asToStakeCreds()?.pot()).toEqual(Cardano.MirCertificatePot.Treasury);
      expect(certUseTreasury.asToStakeCreds()?.getStakeCreds()).toEqual(
        new Map([
          [
            {
              hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
              type: Cardano.CredentialType.KeyHash
            },
            0n
          ]
        ])
      );
    });

    it('can encode toStakeCreds MoveInstantaneousReward to CBOR', () => {
      const coreUseReservers: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 0n,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
          type: Cardano.CredentialType.KeyHash
        }
      };

      const coreUseTreasury: Cardano.MirCertificate = {
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 0n,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
          type: Cardano.CredentialType.KeyHash
        }
      };

      const certUseReserves = MoveInstantaneousReward.fromCore(coreUseReservers);
      const certUseTreasury = MoveInstantaneousReward.fromCore(coreUseTreasury);

      expect(certUseReserves.toCbor()).toEqual(
        '82068200a18200581c0101010101010101010101010101010101010101010101010101010100'
      );
      expect(certUseTreasury.toCbor()).toEqual(
        '82068201a18200581c0101010101010101010101010101010101010101010101010101010100'
      );
    });

    it('can encode toStakeCreds MoveInstantaneousReward to Core', () => {
      const cborUseReserves = HexBlob('82068200a18200581c0101010101010101010101010101010101010101010101010101010100');
      const cborUseTreasury = HexBlob('82068201a18200581c0101010101010101010101010101010101010101010101010101010100');

      const certUseReserves = MoveInstantaneousReward.fromCbor(cborUseReserves);
      const certUseTreasury = MoveInstantaneousReward.fromCbor(cborUseTreasury);

      expect(certUseReserves.toCore()).toEqual({
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Reserves,
        quantity: 0n,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
          type: Cardano.CredentialType.KeyHash
        }
      });

      expect(certUseTreasury.toCore()).toEqual({
        __typename: Cardano.CertificateType.MIR,
        kind: Cardano.MirCertificateKind.ToStakeCreds,
        pot: Cardano.MirCertificatePot.Treasury,
        quantity: 0n,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
          type: Cardano.CredentialType.KeyHash
        }
      });
    });
  });
});
