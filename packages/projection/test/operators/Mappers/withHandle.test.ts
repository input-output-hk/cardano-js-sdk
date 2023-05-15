import { Cardano } from '@cardano-sdk/core';
import { ProjectionEvent } from '../../../src';
import { filterHandlesByPolicyId, withHandles } from '../../../src/operators/Mappers';
import { firstValueFrom, of } from 'rxjs';

describe('withHandles', () => {
  it('maps tx outputs to handles and filter by policyId', async () => {
    const validTxSource$ = of({
      block: {
        body: [
          {
            body: {
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
                      [
                        Cardano.AssetId('8f78a4388b1a3e1a1435257e9356fa0c2cc0d3a5999d63b5886c964354657374746f6b656e'),
                        1n
                      ]
                    ]),
                    coins: 1_724_100n
                  }
                }
              ]
            }
          },
          {
            body: {
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
            }
          }
        ]
      }
    } as ProjectionEvent);

    const { handles } = await firstValueFrom(
      validTxSource$.pipe(
        withHandles(),
        filterHandlesByPolicyId({
          policyIds: [Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a')]
        })
      )
    );

    expect(Array.isArray(handles)).toBeTruthy();
  });
});
