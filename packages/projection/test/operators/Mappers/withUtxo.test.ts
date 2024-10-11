import { Cardano } from '@cardano-sdk/core';
import { ProjectionEvent } from '../../../src';
import {
  filterProducedUtxoByAddresses,
  filterProducedUtxoByAssetPolicyId,
  filterProducedUtxoByAssetsPresence,
  withUtxo
} from '../../../src/operators/Mappers';
import { firstValueFrom, of } from 'rxjs';

export const validTxSource$ = of({
  block: {
    body: [
      {
        body: {
          inputs: [
            {
              index: 1,
              txId: '434342da3f66f94d929d8c7a49484e1c212c74c6213d7b938119f6e0dcb9454c'
            },
            {
              index: 2,
              txId: '434342da3f66f94d929d8c7a49484e1c212c74c6213d7b938119f6e0dcb9454c'
            }
          ],
          outputs: [
            {
              address: Cardano.PaymentAddress('addr_test1wzlv9cslk9tcj0wpm9p5t6kajyt37ap5sc9rzkaxa9p67ys2ygypv'),
              datumHash: '99c170cc1247e7b7971e194c7e400e219360d3991cb588e9833f77ee9edbbd06' as Cardano.DatumHash,
              value: {
                assets: new Map([
                  [
                    Cardano.AssetId(
                      '8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c96435365636f6e6454657374746f6b656e'
                    ),
                    1n
                  ],
                  [Cardano.AssetId('8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c964354657374746f6b656e'), 1n],
                  [Cardano.AssetId('7f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c964354657374746f6b656e'), 1n]
                ]),
                coins: 1_724_100n
              }
            }
          ]
        },
        inputSource: Cardano.InputSource.inputs,
        witness: {}
      },
      {
        body: {
          inputs: [
            {
              index: 0,
              txId: '73e26ff267b5ee32d8e413635f4f4c9547db1c2af1694faf51be20b9f508b8f6'
            }
          ],
          outputs: [
            {
              address:
                'addr_test1qzrf8t56qhzcp2chrtn7deqhep0dttr3eemhnut6lth3gulj7cuplfarmnq5fyumgl0lklddvau9dhamaexykljzvpyswqt56p',
              value: {
                assets: new Map(),
                coins: 25_485_292n
              }
            },
            {
              address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
              value: {
                assets: new Map(),
                coins: 74_341_815n
              }
            }
          ]
        },
        inputSource: Cardano.InputSource.inputs,
        witness: {}
      },
      {
        body: {
          inputs: [
            {
              index: 0,
              txId: '73e26ff267b5ee32d8e413635f4f4c9547db1c2af1694faf51be20b9f508b8f6'
            }
          ],
          outputs: [
            {
              address:
                'addr_test1qzrf8t56qhzcp2chrtn7deqhep0dttr3eemhnut6lth3gulj7cuplfarmnq5fyumgl0lklddvau9dhamaexykljzvpyswqt56p',
              value: {
                assets: new Map([
                  [
                    Cardano.AssetId(
                      '8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c96435365636f6e6454657374746f6b656e'
                    ),
                    1n
                  ],
                  [Cardano.AssetId('8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c964354657374746f6b656e'), 1n],
                  [Cardano.AssetId('7f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c964354657374746f6b656e'), 1n]
                ]),
                coins: 25_485_292n
              }
            },
            {
              address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
              value: {
                assets: new Map(),
                coins: 74_341_815n
              }
            }
          ]
        },
        inputSource: Cardano.InputSource.inputs,
        witness: {}
      }
    ]
  }
} as ProjectionEvent);

describe('withUtxo', () => {
  const failedTxSource$ = of({
    block: {
      body: [
        {
          body: {
            collaterals: [
              {
                index: 2,
                txId: '434342da3f66f94d929d8c7a49484e1c212c74c6213d7b938119f6e0dcb9454c'
              }
            ],
            inputs: [
              {
                index: 1,
                txId: '434342da3f66f94d929d8c7a49484e1c212c74c6213d7b938119f6e0dcb9454c'
              }
            ],
            outputs: [
              {
                address: Cardano.PaymentAddress('addr_test1wzlv9cslk9tcj0wpm9p5t6kajyt37ap5sc9rzkaxa9p67ys2ygypv'),
                datumHash: '99c170cc1247e7b7971e194c7e400e219360d3991cb588e9833f77ee9edbbd06' as Cardano.DatumHash,
                value: {
                  assets: new Map([
                    [
                      Cardano.AssetId(
                        '8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c96435365636f6e6454657374746f6b656e'
                      ),
                      1n
                    ],
                    [Cardano.AssetId('8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c964354657374746f6b656e'), 1n]
                  ]),
                  coins: 1_724_100n
                }
              }
            ]
          },
          inputSource: Cardano.InputSource.collaterals,
          witness: {}
        },
        {
          body: {
            collateralReturn: {
              address: 'addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf',
              value: {
                assets: new Map(),
                coins: 74_341_815n
              }
            },
            collaterals: [
              {
                index: 0,
                txId: '73e26ff267b5ee32d8e413635f4f4c9547db1c2af1694faf51be20b9f508b8f6'
              }
            ],
            inputs: [
              {
                index: 0,
                txId: '73e26ff267b5ee32d8e413635f4f4c9547db1c2af1694faf51be20b9f508b8f6'
              }
            ],
            outputs: [
              {
                address:
                  'addr_test1qzrf8t56qhzcp2chrtn7deqhep0dttr3eemhnut6lth3gulj7cuplfarmnq5fyumgl0lklddvau9dhamaexykljzvpyswqt56p',
                value: {
                  assets: new Map([
                    [
                      Cardano.AssetId(
                        'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a5365636f6e6454657374746f6b656e'
                      ),
                      3n
                    ]
                  ]),
                  coins: 25_485_292n
                }
              },
              {
                address:
                  'addr_test1qzrf8t56qhzcp2chrtn7deqhep0dttr3eemhnut6lth3gulj7cuplfarmnq5fyumgl0lklddvau9dhamaexykljzvpyswqt56p',
                value: {
                  assets: new Map(),
                  coins: 25_485_292n
                }
              }
            ]
          },
          inputSource: Cardano.InputSource.collaterals,
          witness: {}
        }
      ]
    }
  } as ProjectionEvent);

  it('maps all produced and consumed utxo into flat arrays', async () => {
    const {
      utxo: { consumed, produced }
    } = await firstValueFrom(validTxSource$.pipe(withUtxo()));
    expect(consumed).toHaveLength(4);
    expect(produced).toHaveLength(5);
  });

  it('hydrates produced output datum from witness', async () => {
    const {
      utxo: { produced }
    } = await firstValueFrom(
      of({
        block: {
          body: [
            {
              body: {
                inputs: [
                  {
                    index: 1,
                    txId: '434342da3f66f94d929d8c7a49484e1c212c74c6213d7b938119f6e0dcb9454c'
                  }
                ],
                outputs: [
                  {
                    address: Cardano.PaymentAddress('addr_test1wzlv9cslk9tcj0wpm9p5t6kajyt37ap5sc9rzkaxa9p67ys2ygypv'),
                    datumHash: '51f55225cb45388c05903db1e5095382ceafa2d17ff13ffbecf31b037c7c4dc1' as Cardano.DatumHash,
                    value: { coins: 1_724_100n }
                  }
                ]
              },
              inputSource: Cardano.InputSource.inputs,
              witness: {
                datums: [
                  {
                    cbor: 'd8799f4108d8799fd8799fd8799fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffffd87a80ffd87a80ff1a002625a0d8799fd879801a4f2442c1d8799f1b000000108fdb12acffffff',
                    constructor: 0n,
                    fields: {
                      cbor: '9f4108d8799fd8799fd8799fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffffd87a80ffd87a80ff1a002625a0d8799fd879801a4f2442c1d8799f1b000000108fdb12acffffff',
                      items: [
                        new Uint8Array([8]),
                        {
                          cbor: 'd8799fd8799fd8799fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffffd87a80ffd87a80ff',
                          constructor: 0n,
                          fields: {
                            cbor: '9fd8799fd8799fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffffd87a80ffd87a80ff',
                            items: [
                              {
                                cbor: 'd8799fd8799fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffffd87a80ff',
                                constructor: 0n,
                                fields: {
                                  cbor: '9fd8799fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffffd87a80ff',
                                  items: [
                                    {
                                      cbor: 'd8799fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffff',
                                      constructor: 0n,
                                      fields: {
                                        cbor: '9fd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ffd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffffff',
                                        items: [
                                          {
                                            cbor: 'd8799f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ff',
                                            constructor: 0n,
                                            fields: {
                                              cbor: '9f581c5247dd3bdf2d2f838a2f0c91b38f127523772d24393993e10fbbd235ff',
                                              items: [
                                                new Uint8Array([
                                                  82, 71, 221, 59, 223, 45, 47, 131, 138, 47, 12, 145, 179, 143, 18,
                                                  117, 35, 119, 45, 36, 57, 57, 147, 225, 15, 187, 210, 53
                                                ])
                                              ]
                                            }
                                          },
                                          {
                                            cbor: 'd8799fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffff',
                                            constructor: 0n,
                                            fields: {
                                              cbor: '9fd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffffff',
                                              items: [
                                                {
                                                  cbor: 'd8799fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffff',
                                                  constructor: 0n,
                                                  fields: {
                                                    cbor: '9fd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ffff',
                                                    items: [
                                                      {
                                                        cbor: 'd8799f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ff',
                                                        constructor: 0n,
                                                        fields: {
                                                          cbor: '9f581c9a45a01d85c481827325eca0537957bf0480ec37e9ada731b06400d0ff',
                                                          items: [
                                                            new Uint8Array([
                                                              154, 69, 160, 29, 133, 196, 129, 130, 115, 37, 236, 160,
                                                              83, 121, 87, 191, 4, 128, 236, 55, 233, 173, 167, 49, 176,
                                                              100, 0, 208
                                                            ])
                                                          ]
                                                        }
                                                      }
                                                    ]
                                                  }
                                                }
                                              ]
                                            }
                                          }
                                        ]
                                      }
                                    },
                                    {
                                      cbor: 'd87a80',
                                      constructor: 1n,
                                      fields: {
                                        cbor: '80',
                                        items: []
                                      }
                                    }
                                  ]
                                }
                              },
                              {
                                cbor: 'd87a80',
                                constructor: 1n,
                                fields: {
                                  cbor: '80',
                                  items: []
                                }
                              }
                            ]
                          }
                        },
                        2_500_000n,
                        {
                          cbor: 'd8799fd879801a4f2442c1d8799f1b000000108fdb12acffff',
                          constructor: 0n,
                          fields: {
                            cbor: '9fd879801a4f2442c1d8799f1b000000108fdb12acffff',
                            items: [
                              {
                                cbor: 'd87980',
                                constructor: 0n,
                                fields: {
                                  cbor: '80',
                                  items: []
                                }
                              },
                              1_327_776_449n,
                              {
                                cbor: 'd8799f1b000000108fdb12acff',
                                constructor: 0n,
                                fields: {
                                  cbor: '9f1b000000108fdb12acff',
                                  items: [71_132_975_788n]
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ]
        }
      } as ProjectionEvent).pipe(withUtxo())
    );
    expect(produced[0][1].datum).toBeTruthy();
  });

  it('when inputSource is collateral: maps consumed/produced utxo from collateral/collateralReturn', async () => {
    const {
      utxo: { consumed, produced }
    } = await firstValueFrom(failedTxSource$.pipe(withUtxo()));
    expect(consumed).toHaveLength(2);
    expect(produced).toHaveLength(1);
    expect(consumed[0].index).toBe(2);
    expect(produced[0][1].address).toBe('addr_test1vptwv4jvaqt635jvthpa29lww3vkzypm8l6vk4lv4tqfhhgajdgwf');
  });

  describe('filterProducedUtxoByAddresses', () => {
    it('keeps only utxo produced for supplied addresses', async () => {
      const {
        utxo: { produced }
      } = await firstValueFrom(
        validTxSource$.pipe(
          withUtxo(),
          filterProducedUtxoByAddresses({
            addresses: [
              Cardano.PaymentAddress(
                'addr_test1qzrf8t56qhzcp2chrtn7deqhep0dttr3eemhnut6lth3gulj7cuplfarmnq5fyumgl0lklddvau9dhamaexykljzvpyswqt56p'
              )
            ]
          })
        )
      );

      expect(produced).toHaveLength(2);
    });
  });

  describe('filterProducedUtxoByAssetsPresence', () => {
    it('keeps only utxo produced that contain any assets', async () => {
      const {
        utxo: { produced }
      } = await firstValueFrom(validTxSource$.pipe(withUtxo(), filterProducedUtxoByAssetsPresence()));

      const utxosWithAssets = produced.filter(([_key, { value }]) => value.assets && value.assets.size > 0);

      expect(utxosWithAssets.length).toBe(produced.length);

      for (const [_key, { value }] of utxosWithAssets) {
        expect(value.assets?.size).toBeGreaterThan(0);
      }
    });
  });

  describe('filterProducedUtxoByAssetPolicyId', () => {
    it('keeps only utxo produced based on specified policy id, also filtering their value assets', async () => {
      const {
        utxo: { produced }
      } = await firstValueFrom(
        validTxSource$.pipe(
          withUtxo(),
          filterProducedUtxoByAssetPolicyId({
            policyIds: [Cardano.PolicyId('8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c9643')]
          })
        )
      );

      expect(produced).toHaveLength(2);
      expect(produced[0][1].value.assets?.size).toBe(2);
    });
  });
});
