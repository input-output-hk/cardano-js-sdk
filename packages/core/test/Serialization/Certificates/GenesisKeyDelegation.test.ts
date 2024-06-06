/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { GenesisKeyDelegation } from '../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('GenesisKeyDelegation', () => {
  it('can decode GenesisKeyDelegation from CBOR', () => {
    const cbor = HexBlob(
      '8405581c00010001000100010001000100010001000100010001000100010001581c0002000200020002000200020002000200020002000200020002000258200003000300030003000300030003000300030003000300030003000300030003'
    );

    const certificate = GenesisKeyDelegation.fromCbor(cbor);

    expect(certificate.genesisHash()).toEqual('00010001000100010001000100010001000100010001000100010001');
    expect(certificate.genesisDelegateHash()).toEqual('00020002000200020002000200020002000200020002000200020002');
    expect(certificate.vrfKeyHash()).toEqual('0003000300030003000300030003000300030003000300030003000300030003');
  });

  it('can decode GenesisKeyDelegation from Core', () => {
    const core: Cardano.GenesisKeyDelegationCertificate = {
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: Crypto.Hash28ByteBase16('00020002000200020002000200020002000200020002000200020002'),
      genesisHash: Crypto.Hash28ByteBase16('00010001000100010001000100010001000100010001000100010001'),
      vrfKeyHash: Crypto.Hash32ByteBase16('0003000300030003000300030003000300030003000300030003000300030003')
    };

    const certificate = GenesisKeyDelegation.fromCore(core);

    expect(certificate.genesisHash()).toEqual('00010001000100010001000100010001000100010001000100010001');
    expect(certificate.genesisDelegateHash()).toEqual('00020002000200020002000200020002000200020002000200020002');
    expect(certificate.vrfKeyHash()).toEqual('0003000300030003000300030003000300030003000300030003000300030003');
  });

  it('can encode GenesisKeyDelegation to CBOR', () => {
    const core: Cardano.GenesisKeyDelegationCertificate = {
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: Crypto.Hash28ByteBase16('00020002000200020002000200020002000200020002000200020002'),
      genesisHash: Crypto.Hash28ByteBase16('00010001000100010001000100010001000100010001000100010001'),
      vrfKeyHash: Crypto.Hash32ByteBase16('0003000300030003000300030003000300030003000300030003000300030003')
    };

    const certificate = GenesisKeyDelegation.fromCore(core);

    expect(certificate.toCbor()).toEqual(
      '8405581c00010001000100010001000100010001000100010001000100010001581c0002000200020002000200020002000200020002000200020002000258200003000300030003000300030003000300030003000300030003000300030003'
    );
  });

  it('can encode GenesisKeyDelegation to Core', () => {
    const cbor = HexBlob(
      '8405581c00010001000100010001000100010001000100010001000100010001581c0002000200020002000200020002000200020002000200020002000258200003000300030003000300030003000300030003000300030003000300030003'
    );

    const certificate = GenesisKeyDelegation.fromCbor(cbor);

    expect(certificate.toCore()).toEqual({
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: Crypto.Hash28ByteBase16('00020002000200020002000200020002000200020002000200020002'),
      genesisHash: Crypto.Hash28ByteBase16('00010001000100010001000100010001000100010001000100010001'),
      vrfKeyHash: Crypto.Hash32ByteBase16('0003000300030003000300030003000300030003000300030003000300030003')
    });
  });
});
