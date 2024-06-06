/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { ProtocolVersion } from '../../../src/Serialization/index.js';
import type * as Cardano from '../../../src/Cardano/index.js';

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
});
