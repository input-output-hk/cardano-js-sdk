/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { PoolMetadata } from '../../../../src/Serialization/index.js';
import type * as Cardano from '../../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('PoolMetadata', () => {
  it('can decode PoolMetadata from CBOR', () => {
    const cbor = HexBlob(
      '827368747470733a2f2f6578616d706c652e636f6d58200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
    );

    const metadata = PoolMetadata.fromCbor(cbor);

    expect(metadata.url()).toEqual('https://example.com');
    expect(metadata.poolMetadataHash()).toEqual('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
  });

  it('can decode PoolMetadata from Core', () => {
    const core = {
      hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
      url: 'https://example.com'
    } as Cardano.PoolMetadataJson;

    const metadata = PoolMetadata.fromCore(core);

    expect(metadata.url()).toEqual('https://example.com');
    expect(metadata.poolMetadataHash()).toEqual('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
  });

  it('can encode PoolMetadata to CBOR', () => {
    const core = {
      hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
      url: 'https://example.com'
    } as Cardano.PoolMetadataJson;

    const metadata = PoolMetadata.fromCore(core);

    expect(metadata.toCbor()).toEqual(
      '827368747470733a2f2f6578616d706c652e636f6d58200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
    );
  });

  it('can encode PoolMetadata to Core', () => {
    const cbor = HexBlob(
      '827368747470733a2f2f6578616d706c652e636f6d58200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
    );

    const metadata = PoolMetadata.fromCbor(cbor);

    expect(metadata.toCore()).toEqual({
      hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
      url: 'https://example.com'
    });
  });
});
