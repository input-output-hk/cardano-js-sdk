/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, ChainSyncEventType, ChainSyncRollForward } from '@cardano-sdk/core';
import { ChainSyncDataSet, SerializedChainSyncEvent, chainSyncData } from '@cardano-sdk/util-dev';
import { Mappers, ProjectionEvent } from '../../../src';
import { Observable, firstValueFrom, map, of } from 'rxjs';
import { dummyLogger } from 'ts-log';

// Events in inline-datum.json have both cip25 and cip68 metadata.
// Removing cip25 metadata helps testing cip68.
const removeTxMetadata =
  <T>() =>
  (evt$: Observable<ProjectionEvent<T>>): Observable<ProjectionEvent<T>> =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        block: {
          ...evt.block,
          body: evt.block.body.map((tx) => ({
            ...tx,
            auxiliaryData: undefined
          }))
        }
      }))
    );

const isDatumInBlock = (data: Cardano.Block) =>
  data.body.some((item) => item?.body?.outputs?.some((output) => !!output?.datum));

const datumNftmetadata = {
  nftMetadata: {
    description: undefined,
    files: undefined,
    image: 'ipfs://zb2rhaGkrm2gQC366SZbbTQmjDd3fjd44ftHH4L4TtABypSKa',
    mediaType: 'image/jpeg',
    name: '$snek69',
    otherProperties: new Map<string, string | bigint>([
      ['og', 0n],
      ['og_number', 0n],
      ['rarity', 'common'],
      ['length', 6n],
      ['characters', 'letters,numbers'],
      ['numeric_modifiers', ''],
      ['version', 1n]
    ]),
    version: '1'
  },
  referenceTokenAssetId: Cardano.AssetId(
    'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a000643b0736e656b3639'
  ),
  userTokenAssetId: Cardano.AssetId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a000de140736e656b3639')
};

describe('withNftMetadata', () => {
  const assetId1 = Cardano.AssetId('7d878696b149b529807aa01b8e20785e0a0d470c32c13f53f08a55e344455630303032');
  const assetId2 = Cardano.AssetId('7d878696b149b529807aa01b8e20785e0a0d470c32c13f53f08a55e344455638393230');
  const otherProperties1 = new Map([
    ['Background', 'Ocean'],
    ['Body', 'Pale'],
    ['Drink', 'Beer'],
    ['Eyes', 'Bored'],
    ['Facial Hair', 'Dali Brown'],
    ['Food', 'Apple'],
    ['Head', 'Make ETH Great Again Cap'],
    ['Mouth', 'Happy'],
    ['Outfit', 'Pharoah'],
    ['Skill', 'Ruby Ruffian'],
    ['race', 'Human']
  ]);

  const otherProperties2 = new Map([
    ['Background', 'Rose'],
    ['Body', 'Cyborg'],
    ['Drink', 'Soda'],
    ['Eyes', 'Baked'],
    ['Facial Hair', 'Snot Mop Brown'],
    ['Food', 'Banana'],
    ['Head', 'Viking'],
    ['Mouth', 'Happy'],
    ['Outfit', 'Warrior'],
    ['Skill', 'Rust Wrangler']
  ]);

  const nftAuxiliaryData = {
    blob: new Map([
      [
        721n,
        new Map([
          [
            '7d878696b149b529807aa01b8e20785e0a0d470c32c13f53f08a55e3',
            new Map([
              [
                'DEV0002',
                new Map([
                  ...otherProperties1,
                  ['image', 'ipfs://QmWmB37VZ9uc2cVe2fG31Xqjxw5VbUu4DMLkGt9LW6z7Up'],
                  ['mediaType', 'image/jpeg'],
                  ['name', 'DEV 0002']
                ])
              ],
              [
                'DEV8920',
                new Map([
                  ...otherProperties2,
                  ['image', 'ipfs://QmRXW8zsyP3orMf4v2nUZEf5bMWfUXi68ipMmuDKwgvXRJ'],
                  ['mediaType', 'image/jpeg'],
                  ['name', 'DEV 8920']
                ])
              ]
            ])
          ]
        ])
      ]
    ])
  };

  const source$ = of({
    block: {
      body: [
        {
          auxiliaryData: nftAuxiliaryData,
          body: {
            mint: new Map([
              [assetId1, 1n],
              [assetId2, 1n]
            ])
          }
        }
      ],
      header: { blockNo: Cardano.BlockNo(1_156_123) }
    }
  } as ProjectionEvent);

  const stubEvents = chainSyncData(ChainSyncDataSet.WithInlineDatum);

  const someNftMetadata = new Map([
    [
      'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a000de140736e656b3639',
      {
        description: undefined,
        files: undefined,
        image: 'ipfs://zb2rhaGkrm2gQC366SZbbTQmjDd3fjd44ftHH4L4TtABypSKa',
        mediaType: 'image/jpeg',
        name: '$snek69',
        otherProperties: new Map<string, string | bigint>([
          ['og', 0n],
          ['og_number', 0n],
          ['rarity', 'common'],
          ['length', 6n],
          ['characters', 'letters,numbers'],
          ['numeric_modifiers', ''],
          ['version', 1n]
        ]),
        version: '1'
      }
    ]
  ]);

  it('finds cip25 nft metadata', async () => {
    const { nftMetadata } = await firstValueFrom(
      source$.pipe(
        Mappers.withMint(),
        Mappers.withUtxo(),
        Mappers.withCIP67(),
        Mappers.withNftMetadata({ logger: dummyLogger })
      )
    );
    const result1 = {
      description: undefined,
      files: undefined,
      image: 'ipfs://QmWmB37VZ9uc2cVe2fG31Xqjxw5VbUu4DMLkGt9LW6z7Up',
      mediaType: 'image/jpeg',
      name: 'DEV 0002',
      otherProperties: otherProperties1,
      version: '1.0'
    };

    const result2 = {
      description: undefined,
      files: undefined,
      image: 'ipfs://QmRXW8zsyP3orMf4v2nUZEf5bMWfUXi68ipMmuDKwgvXRJ',
      mediaType: 'image/jpeg',
      name: 'DEV 8920',
      otherProperties: otherProperties2,
      version: '1.0'
    };

    expect(nftMetadata).toMatchObject([
      { nftMetadata: result1, userTokenAssetId: assetId1 },
      { nftMetadata: result2, userTokenAssetId: assetId2 }
    ]);
  });

  it('finds cip68 nft metadata', async () => {
    const sourceWithStub$ = of(
      stubEvents.allEvents.find(
        (event: SerializedChainSyncEvent) =>
          event.eventType === ChainSyncEventType.RollForward && isDatumInBlock(event.block)
      ) as ChainSyncRollForward as ProjectionEvent
    );

    const { nftMetadata } = await firstValueFrom(
      sourceWithStub$.pipe(
        removeTxMetadata(),
        Mappers.withMint(),
        Mappers.withUtxo(),
        Mappers.withCIP67(),
        Mappers.withNftMetadata({ logger: dummyLogger })
      )
    );

    expect(nftMetadata).toMatchObject(someNftMetadata);
    expect(nftMetadata).toMatchObject([datumNftmetadata]);
  });

  it('finds updated cip68 nft metadata (asset was not minted in this block)', async () => {
    const testBlock = stubEvents.allEvents.find(
      (event: SerializedChainSyncEvent) =>
        event.eventType === ChainSyncEventType.RollForward && isDatumInBlock(event.block)
    ) as ChainSyncRollForward;

    const sourceWithoutMint$ = of({
      block: {
        body: [
          {
            auxiliaryData: nftAuxiliaryData,
            body: {
              inputs: [] as Cardano.TxIn[],
              outputs: testBlock.block.body[0].body.outputs
            },
            inputSource: Cardano.InputSource.inputs
          }
        ],
        header: { blockNo: Cardano.BlockNo(1_156_123) }
      },
      eventType: ChainSyncEventType.RollForward
    } as ProjectionEvent);
    const { nftMetadata } = await firstValueFrom(
      sourceWithoutMint$.pipe(
        removeTxMetadata(),
        Mappers.withMint(),
        Mappers.withUtxo(),
        Mappers.withCIP67(),
        Mappers.withNftMetadata({ logger: dummyLogger })
      )
    );

    expect(nftMetadata).toEqual([datumNftmetadata]);
  });

  it('keeps a single NftMetadata per userTokenAssetId, prioritizing cip68', async () => {
    const testBlock = stubEvents.allEvents.find(
      (event: SerializedChainSyncEvent) =>
        event.eventType === ChainSyncEventType.RollForward && isDatumInBlock(event.block)
    ) as ChainSyncRollForward;

    const policyId = Cardano.AssetId.getPolicyId(datumNftmetadata.userTokenAssetId);
    const assetName = Cardano.AssetId.getAssetName(datumNftmetadata.userTokenAssetId);
    const testBlockData = {
      block: {
        body: [
          {
            auxiliaryData: {
              blob: new Map<Cardano.Metadatum, Cardano.Metadatum>([
                [
                  721n,
                  new Map([
                    [
                      policyId,
                      new Map([
                        [
                          Buffer.from(assetName, 'hex').toString('utf8'),
                          new Map([
                            ['image', 'ipfs://QmWmB37VZ9uc2cVe2fG31Xqjxw5VbUu4DMLkGt9LW6z7Up'],
                            ['mediaType', 'image/jpeg'],
                            ['name', 'DEV 0002']
                          ])
                        ]
                      ])
                    ]
                  ])
                ]
              ])
            },
            body: {
              inputs: [] as Cardano.TxIn[],
              mint: new Map([
                // cip68 reference token
                ['f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a000643b0736e656b3639', 1n],
                // cip68 user token
                ['f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a000de140736e656b3639', 1n]
              ]),
              outputs: testBlock.block.body[0].body.outputs
            },
            inputSource: Cardano.InputSource.inputs
          }
        ],
        header: { blockNo: Cardano.BlockNo(1_156_123) }
      },
      eventType: ChainSyncEventType.RollForward
    } as ProjectionEvent;

    const sourceWithCip68$ = of(testBlockData);

    const { nftMetadata } = await firstValueFrom(
      sourceWithCip68$.pipe(
        Mappers.withMint(),
        Mappers.withUtxo(),
        Mappers.withCIP67(),
        Mappers.withNftMetadata({ logger: dummyLogger })
      )
    );

    expect(nftMetadata).toEqual([datumNftmetadata]);
  });
});
