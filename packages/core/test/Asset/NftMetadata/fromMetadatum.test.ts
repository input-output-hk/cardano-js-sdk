/* eslint-disable unicorn/no-useless-undefined */
import { Asset, Cardano } from '../../../src/index.js';
import { AssetName, PolicyId } from '../../../src/Cardano/index.js';
import { dummyLogger } from 'ts-log';
import { fromSerializableObject } from '@cardano-sdk/util';
import type { Metadatum, TxMetadata } from '../../../src/Cardano/index.js';

const logger = dummyLogger;

// eslint-disable-next-line max-statements
describe('NftMetadata.fromMetadatum', () => {
  const assetNameStringUtf8 = 'Cardano Timeline 2022';
  const assetNameString = Buffer.from(assetNameStringUtf8).toString('hex');
  const policyIdString = 'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7';
  const assetImageIPFS = 'ipfs://QmWS6DgF8Ma8oooBn7CtD3ChHyzzMw5NXWfnDbVFTip8af';
  const assetImageHTTPS = 'https://tokens.cardano.org';
  const ipfsUrl = 'ipfs://image';

  const asset = {
    name: AssetName(assetNameString),
    policyId: PolicyId(policyIdString)
  } as Asset.AssetInfo;

  const minimalMetadata = new Map([
    ['image', ipfsUrl],
    ['name', assetNameStringUtf8]
  ]);

  const minimalConvertedMetadataV1 = {
    image: ipfsUrl,
    name: assetNameStringUtf8,
    version: '1.0'
  };

  const minimalConvertedMetadataV2 = {
    ...minimalConvertedMetadataV1,
    version: '2.0'
  };

  const validAsset = {
    name: Cardano.AssetName('43617264616e6f2054696d656c696e652032303232'),
    policyId: Cardano.PolicyId('41b20f83bdf559fa1580caf7960fd188e6aafacf5e81dfb089e82486')
  };

  const createMetadataV1 = (assetMetadatum: Map<Metadatum, Metadatum>): TxMetadata =>
    new Map<bigint, Metadatum>([
      [721n, new Map([[policyIdString, new Map<Metadatum, Metadatum>([[assetNameStringUtf8, assetMetadatum]])]])]
    ]);
  const createMetadataV2 = (assetMetadatum: Map<Metadatum, Metadatum>, version: Metadatum = 2n): TxMetadata =>
    new Map<bigint, Metadatum>([
      [
        721n,
        new Map([
          [
            policyIdString,
            new Map<Metadatum, Metadatum>([
              [assetNameString, assetMetadatum],
              ['version', version]
            ])
          ]
        ])
      ]
    ]);

  const createMetadatumWithFiles = (
    files: { __type: 'Map'; value: string[][] }[],
    image: string | string[],
    name: string | undefined
  ) =>
    fromSerializableObject<Cardano.TxMetadata>({
      __type: 'Map',
      value: [
        [
          {
            __type: 'bigint',
            value: '721'
          },
          {
            __type: 'Map',
            value: [
              [
                '41b20f83bdf559fa1580caf7960fd188e6aafacf5e81dfb089e82486',
                {
                  __type: 'Map',
                  value: [
                    [
                      assetNameStringUtf8,
                      {
                        __type: 'Map',
                        value: [
                          ['era', 'ALL'],
                          ['name', name],
                          ['unit', 'none'],
                          ['files', files],
                          ['image', image],
                          ['edition', '2022'],
                          ['project', 'CTimelines'],
                          ['twitter', 'https://twitter.com/CTimelines1_io'],
                          ['website', 'https://ctimelines1.io'],
                          ['copyright', 'CTimelines 2021'],
                          ['mediaType', 'image/gif'],
                          ['collection', name]
                        ]
                      }
                    ]
                  ]
                }
              ]
            ]
          }
        ]
      ]
    });

  describe('invalid metadata on optional fields', () => {
    it('omits files with a missing file media type', () => {
      const metadatum = createMetadatumWithFiles(
        [
          {
            __type: 'Map',
            value: [
              ['src', 'ipfs://QmTcKWh95A5fTx1Bbw158cowWysvqLCWTgR9UBiEKD9cuh'],
              ['name', 'BRAVO']
            ]
          },
          {
            __type: 'Map',
            value: [
              ['src', 'ipfs://QmTcKWh95A5fTx1Bbw158cowWysvqLCWTgR9UBiEKD9cuv'],
              ['mediaType', 'image/png'],
              ['name', 'BRAVO']
            ]
          }
        ],
        assetImageIPFS,
        assetNameStringUtf8
      );
      const result = Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger);
      expect(result).toBeTruthy();
      expect(result?.files).toHaveLength(1);
    });

    it('omits files with a missing file source', () => {
      const metadatum = createMetadatumWithFiles(
        [
          {
            __type: 'Map',
            value: [
              ['mediaType', 'image/png'],
              ['name', 'BRAVO']
            ]
          },
          {
            __type: 'Map',
            value: [
              ['src', 'ipfs://QmTcKWh95A5fTx1Bbw158cowWysvqLCWTgR9UBiEKD9cuq'],
              ['mediaType', 'image/png'],
              ['name', 'BRAVO']
            ]
          }
        ],
        assetImageIPFS,
        assetNameStringUtf8
      );
      const result = Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger);
      expect(result).toBeTruthy();
      expect(result?.files).toHaveLength(1);
    });
  });

  it('returns null for non-cip25 metadatum', () => {
    const metadatum: TxMetadata = new Map([[123n, 'metadatum']]);
    expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toBeNull();
  });

  it('returns null for cip25 metadatum with no metadata for given policyId', () => {
    const metadata: TxMetadata = new Map([[721n, new Map([['other_policy_id', minimalMetadata]])]]);
    expect(Asset.NftMetadata.fromMetadatum(asset, metadata, logger)).toBeNull();
  });

  it('returns null for cip25 metadatum with no metadata for given assetId', () => {
    const metadatum: TxMetadata = new Map([
      [721n, new Map([[policyIdString, new Map([['other_asset_id', minimalMetadata]])]])]
    ]);
    expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toBeNull();
  });

  describe('name', () => {
    describe('metadatum without name', () => {
      const metadatum = createMetadataV2(new Map([['image', ipfsUrl]]));

      describe('loose mode', () => {
        it('returns metadata with empty name string', () => {
          expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toMatchObject({
            name: ''
          });
        });
      });

      describe('strict mode', () => {
        it('returns null', () => {
          expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger, true)).toBeNull();
        });
      });
    });
  });

  it('returns null for cip25 metadatum with invalid image format', () => {
    const metadatum = createMetadatumWithFiles([], 'http/tokens.cardano.org', assetNameStringUtf8);
    expect(Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger)).toBeNull();
  });

  it('returns metadata files with a missing file name', () => {
    const metadatum = createMetadatumWithFiles(
      [
        {
          __type: 'Map',
          value: [
            ['src', 'ipfs://QmTcKWh95A5fTx1Bbw158cowWysvqLCWTgR9UBiEKD9cuf'],
            ['mediaType', 'image/png']
          ]
        },
        {
          __type: 'Map',
          value: [
            ['src', 'ipfs://QmTcKWh95A5fTx1Bbw158cowWysvqLCWTgR9UBiEKD9cu8'],
            ['mediaType', 'image/png'],
            ['name', 'BRAVO']
          ]
        }
      ],
      assetImageIPFS,
      assetNameStringUtf8
    );
    const result = Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger);
    expect(result).toBeTruthy();
    expect(result?.files).toHaveLength(2);
  });

  it('converts minimal metadata', () => {
    const metadatum: TxMetadata = createMetadataV1(minimalMetadata);
    expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual(minimalConvertedMetadataV1);
  });

  it('supports asset name as utf8 string', () => {
    const metadatum: TxMetadata = new Map([
      [721n, new Map([[policyIdString, new Map([[assetNameStringUtf8, minimalMetadata]])]])]
    ]);
    expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual(minimalConvertedMetadataV1);
  });

  it('supports image with ipfs protocol as string', () => {
    const metadatum = createMetadatumWithFiles(
      [],
      ['ipfs://bafybeihtdkq3ntfcewytdaimnrslpxsatsg47e3bqlsgi', '3jkax65pypymi'],
      assetNameStringUtf8
    );
    const result = Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger);
    expect(result?.image).toEqual('ipfs://bafybeihtdkq3ntfcewytdaimnrslpxsatsg47e3bqlsgi3jkax65pypymi');
  });

  it('supports image with ipfs protocol as array', () => {
    const metadatum = createMetadatumWithFiles([], assetImageIPFS, assetNameStringUtf8);
    const result = Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger);
    expect(result?.image).toEqual(assetImageIPFS);
  });

  it('supports image in https protocol', () => {
    const metadatum = createMetadatumWithFiles([], assetImageHTTPS, assetNameStringUtf8);
    const result = Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger);
    expect(result?.image).toEqual(assetImageHTTPS);
  });

  it('supports bse64 decoded image following data URL scheme standard', () => {
    const base64DecodedImage = [
      'data:image/png;base64,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'
    ];

    const metadatum = createMetadatumWithFiles([], base64DecodedImage, assetNameStringUtf8);
    const result = Asset.NftMetadata.fromMetadatum(validAsset, metadatum, logger);
    expect(result?.image).toEqual(base64DecodedImage.join(''));
  });

  it('replaces the name field with the asset_name when name is missing', () => {
    // Arrange
    const missingNameMetadata = new Map([['image', ipfsUrl]]);
    const metadatum: TxMetadata = createMetadataV1(missingNameMetadata);

    // Act
    const result = Asset.NftMetadata.fromMetadatum(asset, metadatum, logger);

    // Assert
    expect(result).toEqual(minimalConvertedMetadataV1);
  });

  it('supports CIP-0025 v2', () => {
    const metadatum: TxMetadata = new Map([
      [
        721n,
        new Map([[Buffer.from(policyIdString, 'hex'), new Map([[Buffer.from(assetNameStringUtf8), minimalMetadata]])]])
      ]
    ]);
    expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual(minimalConvertedMetadataV1);
  });

  describe('version', () => {
    const expectedMetadata = {
      ...minimalConvertedMetadataV1,
      version: '2.0'
    };

    it('can parse version as string that is a floating point number', () => {
      const metadatum: TxMetadata = createMetadataV2(minimalMetadata, '2.0');
      expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual(expectedMetadata);
    });

    it('can parse version as string that is an integer number', () => {
      const metadatum: TxMetadata = createMetadataV2(minimalMetadata, '2');
      expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual(expectedMetadata);
    });

    it('returns null if version is a string that has non-number characters', () => {
      const metadatum: TxMetadata = createMetadataV2(minimalMetadata, '1a');
      expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toBeNull();
    });

    it('can parse version as bigint', () => {
      const metadatum: TxMetadata = createMetadataV2(minimalMetadata, 2n);
      expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual(expectedMetadata);
    });
  });

  it('coverts optional properties (mediaType, description and <other properties>)', () => {
    const metadatum: TxMetadata = createMetadataV1(
      new Map([
        ...minimalMetadata.entries(),
        ['description', 'description'],
        ['extraProp', 'extra'],
        ['mediaType', 'image/png']
      ])
    );
    expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual({
      ...minimalConvertedMetadataV1,
      description: 'description',
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
      ['src', ['ipfs://file2.location']]
    ]);

    const base64FileSrc = [
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAlYAAAJWCAYAAACapc',
      'kfAAAMF0lEQVR4nO3YMWtedRiHYZVDnTs4dMg3UDo1Qyeh0G7FvUuGElBwk9IUCp',
      'maUjo7lCLi7FAcBDN1cusQcHRyqKNdnfQDuJTX++RJ3ve6PsCfH4cz3DwffvnD6T',
      '8fAADwv300PQAAYFsIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI',
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw',
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL',
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI',
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw',
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL',
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI',
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw',
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL',
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI',
      'gIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKw',
      'CAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiL',
      'ACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAIgIKwCAiLACAI',
      'gs0wPgr5+/m55A5MaNG9MT2HG/f/LZ9AR2nIsVAEBEWAEARIQVAEBEWAEARIQVAE',
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA',
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI',
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAE',
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBkmR4A/NezW/vTEz',
      'ayt783PYEd99XZ9AJ2nYsVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA',
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI',
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAE',
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA',
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBkmR4Az27tT0/YKXv7e9MTALaWixUAQE',
      'RYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQ',
      'BEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBElu',
      'kBwPk6vP90esKF8+Llw+kJwJZwsQIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsA',
      'IAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiA',
      'grAICIsAIAiAgrAICIsAIAiAgrAIDIMj0AOF+PD++t9vYXz05We/vVg6PV3j68/3',
      'S1t1+8fLja22ta85usafl6vX8Q3oeLFQBARFgBAESEFQBARFgBAESEFQBARFgBAE',
      'SEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQ',
      'BARFgBAESEFQBARFgBAESEFQBARFgBAESW6QHA9nj14Gh6wkYeH96bnnDhvHn3x2',
      'pvr/mfnKz2MrwfFysAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICC',
      'sAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgI',
      'iwAgCICCsAgIiwAgCILNMDgO2xt783PYHImx+/nZ6wmbPpAew6FysAgIiwAgCICC',
      'sAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgI',
      'iwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCILNMD4OTjT6',
      'cnbOTo79+mJwBwwbhYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQE',
      'RYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQ',
      'BEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhB',
      'UAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQERYAQBEhBUAQE',
      'RYAQBEhBUAQERYAQBEhBUAQERYAQBElukBAFw8f/7062pvX7t7c7W3YZqLFQBARF',
      'gBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAE',
      'SEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESW6Q',
      'EAXDzX7t6cngCXkosVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI',
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAE',
      'BEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA',
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI',
      'QVAEBEWAEARIQVAEBEWAEARIQVAEBkmR4Al9Wdk+fTEzbyy9E30xMAtpaLFQBARF',
      'gBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAE',
      'SEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESEFQBARFgBAESW6Q',
      'HA+bpz8nx6ApfA58ffT0+AS8nFCgAgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCg',
      'AgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCgAgIqwAACLCCgAgIq',
      'wAACLCCgAgIqwAACLCCgAgIqwAACLL9ABge1y98nZ6AsAoFysAgIiwAgCICCsAgI',
      'iwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAg',
      'CICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCILNMD4PXxwfQEAE',
      'i4WAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWA',
      'EARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARIQVAEBEWAEARI',
      'QVAEBkmR5A5/XxwfQEIlevvJ2ewI47e3J7esJGrj86nZ7AjnOxAgCICCsAgIiwAg',
      'CICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICC',
      'sAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgIiwAgCICCsAgMgyPeAien18MD',
      '2ByNUrb6cnAOfo7Mnt6Qkbuf7odHoCERcrAICIsAIAiAgrAICIsAIAiAgrAICIsA',
      'IAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiA',
      'grAICIsAIAiAgrAICIsAIAiAgrAICIsAIAiPwLOiNBXRuPIIgAAAAASUVORK5CYI',
      'I='
    ];
    const file3 = new Map<Metadatum, Metadatum>([
      ['mediaType', 'image/jpg'],
      ['name', 'file3'],
      ['src', base64FileSrc]
    ]);

    const metadatum: TxMetadata = createMetadataV2(
      new Map<Metadatum, Metadatum>([...minimalMetadata.entries(), ['files', [file1, file2, file3]]])
    );
    expect(Asset.NftMetadata.fromMetadatum(asset, metadatum, logger)).toEqual({
      ...minimalConvertedMetadataV2,
      files: [
        { mediaType: 'image/jpg', name: 'file1', src: 'https://file1.location' },
        {
          mediaType: 'image/png',
          name: 'file2',
          otherProperties: new Map([['extraProp', 'extra']]),
          src: 'ipfs://file2.location'
        },
        { mediaType: 'image/jpg', name: 'file3', src: base64FileSrc.join('') }
      ]
    });
  });
});
