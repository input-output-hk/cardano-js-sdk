/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { MultiHostName, SingleHostAddr, SingleHostName } from '../../../../src/Serialization/index.js';
import type * as Cardano from '../../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('Relay', () => {
  describe('SingleHostName', () => {
    it('can decode relay from CBOR', () => {
      const cbor = HexBlob('83010a6b6578616d706c652e636f6d');

      const relay = SingleHostName.fromCbor(cbor);

      expect(relay.port()).toEqual(10);
      expect(relay.dnsName()).toEqual('example.com');
    });

    it('can decode relay from CBOR (No port)', () => {
      const cbor = HexBlob('8301f66b6578616d706c652e636f6d');

      const relay = SingleHostName.fromCbor(cbor);

      expect(relay.port()).toBeUndefined();
      expect(relay.dnsName()).toEqual('example.com');
    });

    it('can decode relay from Core', () => {
      const core = {
        __typename: 'RelayByName',
        hostname: 'example.com',
        port: 10
      } as Cardano.RelayByName;

      const relay = SingleHostName.fromCore(core);

      expect(relay.port()).toEqual(10);
      expect(relay.dnsName()).toEqual('example.com');
    });

    it('can encode relay to CBOR (no port)', () => {
      const core = {
        __typename: 'RelayByName',
        hostname: 'example.com'
      } as Cardano.RelayByName;

      const relay = SingleHostName.fromCore(core);

      expect(relay.toCbor()).toEqual('8301f66b6578616d706c652e636f6d');
    });

    it('can encode relay to CBOR', () => {
      const core = {
        __typename: 'RelayByName',
        hostname: 'example.com',
        port: 10
      } as Cardano.RelayByName;

      const relay = SingleHostName.fromCore(core);

      expect(relay.toCbor()).toEqual('83010a6b6578616d706c652e636f6d');
    });

    it('can encode relay to Core', () => {
      const cbor = HexBlob('83010a6b6578616d706c652e636f6d');

      const relay = SingleHostName.fromCbor(cbor);

      expect(relay.toCore()).toEqual({
        __typename: 'RelayByName',
        hostname: 'example.com',
        port: 10
      });
    });
  });

  describe('MultiHostName', () => {
    it('can decode relay from CBOR', () => {
      const cbor = HexBlob('82026b6578616d706c652e636f6d');

      const relay = MultiHostName.fromCbor(cbor);

      expect(relay.dnsName()).toEqual('example.com');
    });

    it('can decode relay from Core', () => {
      const core = { __typename: 'RelayByNameMultihost', dnsName: 'example.com' } as Cardano.RelayByNameMultihost;

      const relay = MultiHostName.fromCore(core);

      expect(relay.dnsName()).toEqual('example.com');
    });

    it('can encode relay to CBOR', () => {
      const core = { __typename: 'RelayByNameMultihost', dnsName: 'example.com' } as Cardano.RelayByNameMultihost;

      const relay = MultiHostName.fromCore(core);

      expect(relay.toCbor()).toEqual('82026b6578616d706c652e636f6d');
    });

    it('can encode relay to Core', () => {
      const cbor = HexBlob('82026b6578616d706c652e636f6d');

      const relay = MultiHostName.fromCbor(cbor);

      expect(relay.toCore()).toEqual({ __typename: 'RelayByNameMultihost', dnsName: 'example.com' });
    });
  });

  describe('SingleHostAddr', () => {
    it('can decode relay from CBOR', () => {
      const cbor = HexBlob('84000a440a03020a5001020304010203040102030401020304');

      const relay = SingleHostAddr.fromCbor(cbor);

      expect(relay.port()).toEqual(10);
      expect(relay.ipv4()).toEqual('10.3.2.10');
      expect(relay.ipv6()).toEqual('0102:0304:0102:0304:0102:0304:0102:0304');
    });

    it('can decode relay from Core', () => {
      const core = {
        __typename: 'RelayByAddress',
        ipv4: '10.3.2.10',
        ipv6: '0102:0304:0102:0304:0102:0304:0102:0304',
        port: 10
      } as Cardano.RelayByAddress;

      const relay = SingleHostAddr.fromCore(core);

      expect(relay.port()).toEqual(10);
      expect(relay.ipv4()).toEqual('10.3.2.10');
      expect(relay.ipv6()).toEqual('0102:0304:0102:0304:0102:0304:0102:0304');
    });

    it('IPv6 addresses are always represented in canonical form', () => {
      const cbor = HexBlob('84000a440a03020a5000000000000000000000ffff0a03020a');

      const relay = SingleHostAddr.fromCbor(cbor);

      expect(relay.port()).toEqual(10);
      expect(relay.ipv4()).toEqual('10.3.2.10');
      expect(relay.ipv6()).toEqual('0000:0000:0000:0000:0000:ffff:0a03:020a');
      expect(relay.toCbor()).toEqual('84000a440a03020a5000000000000000000000ffff0a03020a');
    });

    it('can decode relay from CBOR with IPv4-mapped IPv6 addresses', () => {
      const core = {
        __typename: 'RelayByAddress',
        ipv4: '10.3.2.10',
        ipv6: '::ffff:10.3.2.10',
        port: 10
      } as Cardano.RelayByAddress;

      const relay = SingleHostAddr.fromCore(core);

      expect(relay.port()).toEqual(10);
      expect(relay.ipv4()).toEqual('10.3.2.10');
      expect(relay.ipv6()).toEqual('::ffff:10.3.2.10');
      expect(relay.toCbor()).toEqual('84000a440a03020a5000000000000000000000ffff0a03020a');
    });

    it('can encode relay to CBOR', () => {
      const core = {
        __typename: 'RelayByAddress',
        ipv4: '10.3.2.10',
        ipv6: '0102:0304:0102:0304:0102:0304:0102:0304',
        port: 10
      } as Cardano.RelayByAddress;

      const relay = SingleHostAddr.fromCore(core);

      expect(relay.toCbor()).toEqual('84000a440a03020a5001020304010203040102030401020304');
    });

    it('can encode relay to Core', () => {
      const cbor = HexBlob('84000a440a03020a5001020304010203040102030401020304');

      const relay = SingleHostAddr.fromCbor(cbor);

      expect(relay.toCore()).toEqual({
        __typename: 'RelayByAddress',
        ipv4: '10.3.2.10',
        ipv6: '0102:0304:0102:0304:0102:0304:0102:0304',
        port: 10
      });
    });
  });
});
