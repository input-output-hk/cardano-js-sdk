/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { PoolRetirement } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('PoolRetirement', () => {
  it('can decode PoolRetirement from CBOR', () => {
    const cbor = HexBlob('8304581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef921903e8');

    const certificate = PoolRetirement.fromCbor(cbor);

    expect(certificate.epoch()).toEqual(1000);
    expect(certificate.poolKeyHash()).toEqual('d85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92');
  });

  it('can decode PoolRetirement from Core', () => {
    const core: Cardano.PoolRetirementCertificate = {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: Cardano.EpochNo(1000),
      poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34')
    };

    const certificate = PoolRetirement.fromCore(core);

    expect(certificate.epoch()).toEqual(1000);
    expect(certificate.poolKeyHash()).toEqual('d85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92');
  });

  it('can encode PoolRetirement to CBOR', () => {
    const core: Cardano.PoolRetirementCertificate = {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: Cardano.EpochNo(1000),
      poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34')
    };

    const certificate = PoolRetirement.fromCore(core);

    expect(certificate.toCbor()).toEqual('8304581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef921903e8');
  });

  it('can encode PoolRetirement to Core', () => {
    const cbor = HexBlob('8304581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef921903e8');

    const certificate = PoolRetirement.fromCbor(cbor);

    expect(certificate.toCore()).toEqual({
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: Cardano.EpochNo(1000),
      poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34')
    });
  });
});
