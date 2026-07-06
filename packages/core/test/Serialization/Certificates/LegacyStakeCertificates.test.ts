/* eslint-disable sonarjs/no-duplicate-string */
import { Certificate } from '../../../src/Serialization';
import { CertificateKind } from '../../../src/Serialization/Certificates/CertificateKind';
import { HexBlob } from '@cardano-sdk/util';

// Kind 0/1 vectors reuse the fixtures from StakeRegistration.test.ts and StakeDeregistration.test.ts
// (generated with the cardano-serialization-lib). Kind 7/8 zero deposit vectors reuse the fixtures
// from Registration.test.ts and Unregistration.test.ts. Kind 7/8 nonzero deposit vectors are derived
// from the pinned Dijkstra CDDL rules reg_cert = (7, stake_credential, coin) and
// unreg_cert = (8, stake_credential, coin): 83 (array 3), 07/08 (kind), 8200581c<28 byte key hash>
// (stake_credential) and 1a001e8480 (coin 2000000).
const stakeRegistrationCbor = HexBlob('82008200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');
const stakeDeregistrationCbor = HexBlob('82018200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');
const registrationZeroDepositCbor = HexBlob('83078200581c0000000000000000000000000000000000000000000000000000000000');
const unregistrationZeroDepositCbor = HexBlob('83088200581c0000000000000000000000000000000000000000000000000000000000');
const registrationCbor = HexBlob('83078200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f1a001e8480');
const unregistrationCbor = HexBlob('83088200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f1a001e8480');

const roundTrips = (cbor: HexBlob) => {
  const decoded = Certificate.fromCbor(cbor);

  expect(decoded.toCbor()).toEqual(cbor);
  expect(Certificate.fromCore(decoded.toCore()).toCbor()).toEqual(cbor);
};

// Kinds 0 and 1 are removed from the Dijkstra certificate union but the SDK must keep
// decoding and re-encoding them byte-exact for historical chain data (Shelley through Conway).
describe('Legacy stake certificates (kinds 0 and 1) coexist with deposit-explicit certificates (kinds 7 and 8)', () => {
  it('round trips a StakeRegistration (kind 0) certificate byte-exact', () => {
    roundTrips(stakeRegistrationCbor);
  });

  it('round trips a StakeDeregistration (kind 1) certificate byte-exact', () => {
    roundTrips(stakeDeregistrationCbor);
  });

  it('round trips a Registration (kind 7) certificate byte-exact', () => {
    roundTrips(registrationZeroDepositCbor);
    roundTrips(registrationCbor);
  });

  it('round trips an Unregistration (kind 8) certificate byte-exact', () => {
    roundTrips(unregistrationZeroDepositCbor);
    roundTrips(unregistrationCbor);
  });

  it('dispatches kind 0 and kind 7 registrations independently', () => {
    const legacy = Certificate.fromCbor(stakeRegistrationCbor);
    const depositExplicit = Certificate.fromCbor(registrationCbor);

    expect(legacy.kind()).toEqual(CertificateKind.StakeRegistration);
    expect(legacy.asStakeRegistration()).toBeDefined();
    expect(legacy.asRegistrationCert()).toBeUndefined();

    expect(depositExplicit.kind()).toEqual(CertificateKind.Registration);
    expect(depositExplicit.asRegistrationCert()).toBeDefined();
    expect(depositExplicit.asStakeRegistration()).toBeUndefined();

    expect(depositExplicit.asRegistrationCert()!.stakeCredential()).toEqual(
      legacy.asStakeRegistration()!.stakeCredential()
    );
    expect(depositExplicit.asRegistrationCert()!.deposit()).toEqual(2_000_000n);
  });

  it('dispatches kind 1 and kind 8 unregistrations independently', () => {
    const legacy = Certificate.fromCbor(stakeDeregistrationCbor);
    const depositExplicit = Certificate.fromCbor(unregistrationCbor);

    expect(legacy.kind()).toEqual(CertificateKind.StakeDeregistration);
    expect(legacy.asStakeDeregistration()).toBeDefined();
    expect(legacy.asUnregistrationCert()).toBeUndefined();

    expect(depositExplicit.kind()).toEqual(CertificateKind.Unregistration);
    expect(depositExplicit.asUnregistrationCert()).toBeDefined();
    expect(depositExplicit.asStakeDeregistration()).toBeUndefined();

    expect(depositExplicit.asUnregistrationCert()!.stakeCredential()).toEqual(
      legacy.asStakeDeregistration()!.stakeCredential()
    );
    expect(depositExplicit.asUnregistrationCert()!.deposit()).toEqual(2_000_000n);
  });
});
