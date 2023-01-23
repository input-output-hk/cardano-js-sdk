/* eslint-disable sonarjs/no-duplicate-string */
import { AssetInfo } from '../../../src/Asset';
import { AssetName, Metadatum, PolicyId, TxMetadata } from '../../../src/Cardano';
import { Cardano } from '../../../src';
import { fromSerializableObject } from '@cardano-sdk/util';
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

  describe('treats invalid format optional fields as non-present', () => {
    test.skip('missing file name', () => {
      const metadatum = fromSerializableObject<Cardano.MetadatumMap>({
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
                        'Cardano Timeline 2022',
                        {
                          __type: 'Map',
                          value: [
                            ['era', 'ALL'],
                            ['name', 'Cardano Timeline 2022'],
                            ['unit', 'none'],
                            [
                              'files',
                              [
                                {
                                  __type: 'Map',
                                  value: [
                                    ['src', 'ipfs://QmTcKWh95A5fTx1Bbw158cowWysvqLCWTgR9UBiEKD9cu8'],
                                    ['mediaType', 'image/png']
                                  ]
                                }
                              ]
                            ],
                            ['image', 'ipfs://QmWS6DgF8Ma8oooBn7CtD3ChHyzzMw5NXWfnDbVFTip8ai'],
                            ['edition', '2022'],
                            ['project', 'CTimelines'],
                            ['twitter', 'https://twitter.com/CTimelines_io'],
                            ['website', 'https://ctimelines.io'],
                            ['copyright', 'CTimelines 2022'],
                            ['mediaType', 'image/gif'],
                            ['collection', 'Cardano Timeline 2022']
                          ]
                        }
                      ],
                      [
                        'Cardano Timeline 2022 #1',
                        {
                          __type: 'Map',
                          value: [
                            ['era', 'Pre-BYRON'],
                            ['name', 'Cardano Timeline 2022 #1'],
                            ['unit', '1'],
                            [
                              'files',
                              [
                                {
                                  __type: 'Map',
                                  value: [
                                    ['src', 'ipfs://QmdDUw5xFZnqmvG5hYSek1MsB7SZb2TT6vmot5WL1dEBLN'],
                                    ['mediaType', 'image/png']
                                  ]
                                }
                              ]
                            ],
                            ['image', 'ipfs://QmQggGYmgXZmcM3mbEC3uqYrUkNNAjP5zGvt9z4NA9h424'],
                            ['edition', '2022'],
                            ['project', 'CTimelines'],
                            ['twitter', 'https://twitter.com/CTimelines_io'],
                            ['website', 'https://ctimelines.io'],
                            ['copyright', 'CTimelines 2022'],
                            ['mediaType', 'image/gif'],
                            ['collection', 'Cardano Timeline 2022']
                          ]
                        }
                      ],
                      [
                        'Cardano Timeline 2022 #2',
                        {
                          __type: 'Map',
                          value: [
                            ['era', 'BYRON'],
                            ['name', 'Cardano Timeline 2022 #2'],
                            ['unit', '2'],
                            [
                              'files',
                              [
                                {
                                  __type: 'Map',
                                  value: [
                                    ['src', 'ipfs://QmPRgarLTu2Rvi6xnRvcPN8otNcpaDhxaFCjZKwynEgugy'],
                                    ['mediaType', 'image/png']
                                  ]
                                }
                              ]
                            ],
                            ['image', 'ipfs://QmbiC1SqY32ecGH2Ao9VygBL4iwcpYEXGNuK271z9tSXza'],
                            ['edition', '2022'],
                            ['project', 'CTimelines'],
                            ['twitter', 'https://twitter.com/CTimelines_io'],
                            ['website', 'https://ctimelines.io'],
                            ['copyright', 'CTimelines 2022'],
                            ['mediaType', 'image/gif'],
                            ['collection', 'Cardano Timeline 2022']
                          ]
                        }
                      ],
                      [
                        'Cardano Timeline 2022 #3',
                        {
                          __type: 'Map',
                          value: [
                            ['era', 'SHELLEY'],
                            ['name', 'Cardano Timeline 2022 #3'],
                            ['unit', '3'],
                            [
                              'files',
                              [
                                {
                                  __type: 'Map',
                                  value: [
                                    ['src', 'ipfs://QmcFq8XHfg7e5PCUJnfrDgyahgnFMcDsWoLAAf2HttsVK3'],
                                    ['mediaType', 'image/png']
                                  ]
                                }
                              ]
                            ],
                            ['image', 'ipfs://Qmd9Fz4wPb3UMpfx39btPyE4XvrDms5vzMCCe3AgaFj7sm'],
                            ['edition', '2022'],
                            ['project', 'CTimelines'],
                            ['twitter', 'https://twitter.com/CTimelines_io'],
                            ['website', 'https://ctimelines.io'],
                            ['copyright', 'CTimelines 2022'],
                            ['mediaType', 'image/gif'],
                            ['collection', 'Cardano Timeline 2022']
                          ]
                        }
                      ],
                      [
                        'Cardano Timeline 2022 #4',
                        {
                          __type: 'Map',
                          value: [
                            ['era', 'GOGHEN'],
                            ['name', 'Cardano Timeline 2022 #4'],
                            ['unit', '4'],
                            [
                              'files',
                              [
                                {
                                  __type: 'Map',
                                  value: [
                                    ['src', 'ipfs://Qmd8gky76YDWYAZvnw3af3EFrbP72QdYiN9HMyqMG3TsWx'],
                                    ['mediaType', 'image/png']
                                  ]
                                }
                              ]
                            ],
                            ['image', 'ipfs://QmQW5iCF3Ls8MAhBtcU6TFxcDjiwQAtHA3FJBo39gPKJzt'],
                            ['edition', '2022'],
                            ['project', 'CTimelines'],
                            ['twitter', 'https://twitter.com/CTimelines_io'],
                            ['website', 'https://ctimelines.io'],
                            ['copyright', 'CTimelines 2022'],
                            ['mediaType', 'image/gif'],
                            ['collection', 'Cardano Timeline 2022']
                          ]
                        }
                      ],
                      [
                        'Cardano Timeline 2022 #5',
                        {
                          __type: 'Map',
                          value: [
                            ['era', 'BASHO'],
                            ['name', 'Cardano Timeline 2022 #5'],
                            ['unit', '5'],
                            [
                              'files',
                              [
                                {
                                  __type: 'Map',
                                  value: [
                                    ['src', 'ipfs://QmNyC8fjZ5Yb5E7yKUTGbyVNF5KjBC8dzSycuZrsvrLN3A'],
                                    ['mediaType', 'image/png']
                                  ]
                                }
                              ]
                            ],
                            ['image', 'ipfs://QmeSh7anRGk4FZZzhpsaz9RCX4gNrXAYTfTz1U7kDCoJ1w'],
                            ['edition', '2022'],
                            ['project', 'CTimelines'],
                            ['twitter', 'https://twitter.com/CTimelines_io'],
                            ['website', 'https://ctimelines.io'],
                            ['copyright', 'CTimelines 2022'],
                            ['mediaType', 'image/gif'],
                            ['collection', 'Cardano Timeline 2022']
                          ]
                        }
                      ],
                      [
                        'Cardano Timeline 2022 #6',
                        {
                          __type: 'Map',
                          value: [
                            ['era', 'VOLTAIRE'],
                            ['name', 'Cardano Timeline 2022 #6'],
                            ['unit', '6'],
                            [
                              'files',
                              [
                                {
                                  __type: 'Map',
                                  value: [
                                    ['src', 'ipfs://QmWVoqbi85scFsmNiyHaEmaVZLysqnHkTKfVHyK5sHbKQv'],
                                    ['mediaType', 'image/png']
                                  ]
                                }
                              ]
                            ],
                            ['image', 'ipfs://QmWJAsFbbuKvxynakmkvwH8w75Zy1ZQQmbXnZxmKoxP8wP'],
                            ['edition', '2022'],
                            ['project', 'CTimelines'],
                            ['twitter', 'https://twitter.com/CTimelines_io'],
                            ['website', 'https://ctimelines.io'],
                            ['copyright', 'CTimelines 2022'],
                            ['mediaType', 'image/gif'],
                            ['collection', 'Cardano Timeline 2022']
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
      expect(
        metadatumToCip25(
          {
            name: Cardano.AssetName('43617264616e6f2054696d656c696e652032303232'), // 'Cardano Timeline 2022'
            policyId: Cardano.PolicyId('41b20f83bdf559fa1580caf7960fd188e6aafacf5e81dfb089e82486')
          },
          metadatum,
          console
        )
      ).toBeTruthy();
    });
  });

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
