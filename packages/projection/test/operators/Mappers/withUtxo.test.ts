import { Cardano } from '@cardano-sdk/core';
import {
  filterProducedUtxoByAddresses,
  filterProducedUtxoByAssetPolicyId,
  filterProducedUtxoByAssetsPresence,
  withUtxo
} from '../../../src/operators/Mappers/index.js';
import { firstValueFrom, of } from 'rxjs';
import type { ProjectionEvent } from '../../../src/index.js';

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
        inputSource: Cardano.InputSource.inputs
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
        inputSource: Cardano.InputSource.inputs
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
        inputSource: Cardano.InputSource.inputs
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
          inputSource: Cardano.InputSource.collaterals
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
          inputSource: Cardano.InputSource.collaterals
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
