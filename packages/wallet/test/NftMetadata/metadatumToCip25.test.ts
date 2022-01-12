import { Cardano } from '@cardano-sdk/core';
import { metadatumToCip25 } from '../../src/NftMetadata';
import { omit } from 'lodash';

describe('NftMetadata/metadatumToCip25', () => {
  const asset = {
    name: Cardano.AssetName('abc123'),
    policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7')
  } as Cardano.Asset;

  const minimalMetadata = {
    image: 'ipfs://image',
    name: 'test nft'
  };

  const minimalConvertedMetadata = {
    image: 'ipfs://image',
    name: 'test nft',
    version: '1.0'
  };

  it('returns undefined for non-cip25 metadatum', () => {
    const metadatum: Cardano.MetadatumMap = {
      other: 'metadatum'
    };
    expect(metadatumToCip25(asset, metadatum)).toBeUndefined();
  });

  it('returns undefined for cip25 metadatum with no metadata for given policyId', () => {
    const metadatum: Cardano.MetadatumMap = {
      '721': {
        other_policy_id: minimalMetadata
      }
    };
    expect(metadatumToCip25(asset, metadatum)).toBeUndefined();
  });

  it('returns undefined for cip25 metadatum with no metadata for given assetId', () => {
    const metadatum: Cardano.MetadatumMap = {
      '721': {
        [asset.policyId.toString()]: {
          other_asset_id: minimalMetadata
        }
      }
    };
    expect(metadatumToCip25(asset, metadatum)).toBeUndefined();
  });

  it('converts minimal metadata', () => {
    const metadatum: Cardano.MetadatumMap = {
      '721': {
        [asset.policyId.toString()]: {
          [asset.name.toString()]: minimalMetadata
        }
      }
    };
    expect(metadatumToCip25(asset, metadatum)).toEqual(minimalConvertedMetadata);
  });

  // CIP-25 doesn't explicitly say anything about encoding.
  // It is most likely assumed to be hex strings,
  // but people are likely to specify utf8, because it's named '<asset_name>'
  it('supports asset name as utf8 string', () => {
    const metadatum: Cardano.MetadatumMap = {
      '721': {
        [asset.policyId.toString()]: {
          [Buffer.from(asset.name.toString()).toString('utf8')]: minimalMetadata
        }
      }
    };
    expect(metadatumToCip25(asset, metadatum)).toEqual(minimalConvertedMetadata);
  });

  it('converts version', () => {
    const metadatum: Cardano.MetadatumMap = {
      '721': {
        [asset.policyId.toString()]: {
          [asset.name.toString()]: minimalMetadata,
          version: '2.0'
        }
      }
    };
    expect(metadatumToCip25(asset, metadatum)).toEqual({
      ...minimalConvertedMetadata,
      version: '2.0'
    });
  });

  it('coverts optional properties (mediaType, description and <other properties>)', () => {
    const metadatum: Cardano.MetadatumMap = {
      '721': {
        [asset.policyId.toString()]: {
          [asset.name.toString()]: {
            ...minimalMetadata,
            description: 'description',
            extraProp: 'extra',
            mediaType: 'image/png'
          }
        }
      }
    };
    expect(metadatumToCip25(asset, metadatum)).toEqual({
      ...minimalConvertedMetadata,
      description: 'description',
      mediaType: 'image/png',
      otherProperties: { extraProp: 'extra' }
    });
  });

  it('coverts files', () => {
    const file1 = {
      mediaType: 'image/jpg',
      name: 'file1',
      src: 'https://file1.location'
    };
    const file2 = {
      extraProp: 'extra',
      mediaType: 'image/png',
      name: 'file2',
      src: ['https://file2.location']
    };
    const metadatum: Cardano.MetadatumMap = {
      '721': {
        [asset.policyId.toString()]: {
          [asset.name.toString()]: {
            ...minimalMetadata,
            files: [file1, file2]
          }
        }
      }
    };
    expect(metadatumToCip25(asset, metadatum)).toEqual({
      ...minimalConvertedMetadata,
      files: [file1, { ...omit(file2, 'extraProp'), otherProperties: { extraProp: 'extra' } }]
    });
  });
});
