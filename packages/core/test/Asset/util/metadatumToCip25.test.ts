import { AssetInfo } from '../../../src/Asset';
import { AssetName, Metadatum, PolicyId, TxMetadata } from '../../../src/Cardano';
import { dummyLogger as logger } from 'ts-log';
import { metadatumToCip25 } from '../../../src/Asset/util';

describe('NftMetadata/metadatumToCip25', () => {
  const asset = {
    name: AssetName('abc123'),
    policyId: PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7')
  } as AssetInfo;

  const minimalMetadata = new Map([
    ['image', 'ipfs://image'],
    ['name', 'test nft']
  ]);

  const minimalConvertedMetadata = {
    image: ['ipfs://image'],
    name: 'test nft',
    version: '1.0'
  };

  it('returns null for non-cip25 metadatum', () => {
    const metadatum: TxMetadata = new Map([[123n, 'metadatum']]);
    expect(metadatumToCip25(asset, metadatum, logger)).toBeNull();
  });

  it('returns null for cip25 metadatum with no metadata for given policyId', () => {
    const metadata: TxMetadata = new Map([[721n, new Map([['other_policy_id', minimalMetadata]])]]);
    expect(metadatumToCip25(asset, metadata, logger)).toBeNull();
  });

  it('returns null for cip25 metadatum with no metadata for given assetId', () => {
    const metadatum: TxMetadata = new Map([
      [721n, new Map([[asset.policyId.toString(), new Map([['other_asset_id', minimalMetadata]])]])]
    ]);
    expect(metadatumToCip25(asset, metadatum, logger)).toBeNull();
  });

  it('converts minimal metadata', () => {
    const metadatum: TxMetadata = new Map([
      [721n, new Map([[asset.policyId.toString(), new Map([[asset.name.toString(), minimalMetadata]])]])]
    ]);
    expect(metadatumToCip25(asset, metadatum, logger)).toEqual(minimalConvertedMetadata);
  });

  it('supports asset name as utf8 string', () => {
    const metadatum: TxMetadata = new Map([
      [
        721n,
        new Map([
          [asset.policyId.toString(), new Map([[Buffer.from(asset.name.toString()).toString('utf8'), minimalMetadata]])]
        ])
      ]
    ]);
    expect(metadatumToCip25(asset, metadatum, logger)).toEqual(minimalConvertedMetadata);
  });

  it('converts version', () => {
    const metadatum: TxMetadata = new Map([
      [
        721n,
        new Map([
          [
            asset.policyId.toString(),
            new Map<Metadatum, Metadatum>([
              [asset.name.toString(), minimalMetadata],
              ['version', '2.0']
            ])
          ]
        ])
      ]
    ]);
    expect(metadatumToCip25(asset, metadatum, logger)).toEqual({
      ...minimalConvertedMetadata,
      version: '2.0'
    });
  });

  it('coverts optional properties (mediaType, description and <other properties>)', () => {
    const metadatum: TxMetadata = new Map([
      [
        721n,
        new Map([
          [
            asset.policyId.toString(),
            new Map<Metadatum, Metadatum>([
              [
                asset.name.toString(),
                new Map([
                  ...minimalMetadata.entries(),
                  ['description', 'description'],
                  ['extraProp', 'extra'],
                  ['mediaType', 'image/png']
                ])
              ]
            ])
          ]
        ])
      ]
    ]);
    expect(metadatumToCip25(asset, metadatum, logger)).toEqual({
      ...minimalConvertedMetadata,
      description: ['description'],
      mediaType: 'image/png',
      otherProperties: new Map([['extraProp', 'extra']])
    });
  });

  it('coverts files', () => {
    const file1 = new Map([
      ['mediaType', 'image/jpg'],
      ['name', 'file1'],
      ['src', 'https://file1.location']
    ]);
    const file2 = new Map<Metadatum, Metadatum>([
      ['extraProp', 'extra'],
      ['mediaType', 'image/png'],
      ['name', 'file2'],
      ['src', ['https://file2.location']]
    ]);
    const metadatum: TxMetadata = new Map([
      [
        721n,
        new Map([
          [
            asset.policyId.toString(),
            new Map<Metadatum, Metadatum>([
              [
                asset.name.toString(),
                new Map<Metadatum, Metadatum>([...minimalMetadata.entries(), ['files', [file1, file2]]])
              ]
            ])
          ]
        ])
      ]
    ]);
    expect(metadatumToCip25(asset, metadatum, logger)).toEqual({
      ...minimalConvertedMetadata,
      files: [
        { mediaType: 'image/jpg', name: 'file1', src: ['https://file1.location'] },
        {
          mediaType: 'image/png',
          name: 'file2',
          otherProperties: new Map([['extraProp', 'extra']]),
          src: ['https://file2.location']
        }
      ]
    });
  });
});
