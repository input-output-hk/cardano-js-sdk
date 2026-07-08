/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { ProtocolVersion } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('ProtocolVersion', () => {
  it('can decode ProtocolVersion from CBOR', () => {
    const cbor = HexBlob('820103');

    const version = ProtocolVersion.fromCbor(cbor);

    expect(version.major()).toEqual(1);
    expect(version.minor()).toEqual(3);
  });

  it('can decode ProtocolVersion from Core', () => {
    const core = { major: 1, minor: 3 } as Cardano.ProtocolVersion;

    const version = ProtocolVersion.fromCore(core);

    expect(version.major()).toEqual(1);
    expect(version.minor()).toEqual(3);
  });

  it('can encode ProtocolVersion to CBOR', () => {
    const core = { major: 1, minor: 3 } as Cardano.ProtocolVersion;

    const version = ProtocolVersion.fromCore(core);

    expect(version.toCbor()).toEqual('820103');
  });

  it('can encode ProtocolVersion to Core', () => {
    const cbor = HexBlob('820103');

    const version = ProtocolVersion.fromCbor(cbor);

    expect(version.toCore()).toEqual({ major: 1, minor: 3 });
  });

  it('can round trip a ProtocolVersion with the maximum uint32 minor version byte-exact', () => {
    const cbor = HexBlob('820c1affffffff');

    const version = ProtocolVersion.fromCbor(cbor);

    expect(version.major()).toEqual(12);
    expect(version.minor()).toEqual(4_294_967_295);
    expect(version.toCbor()).toEqual(cbor);
    expect(ProtocolVersion.fromCore(version.toCore()).toCbor()).toEqual(cbor);
  });

  it('can round trip a ProtocolVersion with major version 13', () => {
    const cbor = HexBlob('820d00');

    const version = ProtocolVersion.fromCbor(cbor);

    expect(version.major()).toEqual(13);
    expect(version.minor()).toEqual(0);
    expect(version.toCbor()).toEqual(cbor);
    expect(ProtocolVersion.fromCore(version.toCore()).toCbor()).toEqual(cbor);
  });

  it('throws when encoding a minor version greater than the maximum uint32 value', () => {
    const version = new ProtocolVersion(12, 4_294_967_296);

    expect(() => version.toCbor()).toThrow(
      'Minor protocol version must be a uint of size 4 (0 to 4294967295), but got 4294967296'
    );
  });

  it('throws when encoding a negative minor version', () => {
    const version = new ProtocolVersion(12, -1);

    expect(() => version.toCbor()).toThrow('Minor protocol version must be a uint of size 4');
  });
});
