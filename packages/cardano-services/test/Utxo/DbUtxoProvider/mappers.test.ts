import { Cardano } from '@cardano-sdk/core';
import { utxosToCore } from '../../../src/Utxo/index.js';
import type { UtxoModel } from '../../../src/Utxo/index.js';

describe('utxosToCore', () => {
  const someFetchedUtxos: UtxoModel[] = [
    {
      address:
        'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7',
      asset_name: '54455354',
      asset_policy: '4eecf4013e2ab14ec8e500fafeafbdf2bd060254d76c9629a65b7f70',
      asset_quantity: '1',
      coins: '999502622402',
      index: 1,
      tx_id: '8fd14baca91c674fafae59701b7dc0eda1266202ec8445bad3244bd8669a7fb5'
    }
  ];
  it('should correctly map to core utxos', () => {
    expect(utxosToCore(someFetchedUtxos)).toEqual([
      [
        {
          address: Cardano.PaymentAddress(
            'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
          ),
          index: 1,
          txId: Cardano.TransactionId('8fd14baca91c674fafae59701b7dc0eda1266202ec8445bad3244bd8669a7fb5')
        },
        {
          address: Cardano.PaymentAddress(
            'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
          ),
          value: {
            assets: new Map<Cardano.AssetId, bigint>([
              [Cardano.AssetId('4eecf4013e2ab14ec8e500fafeafbdf2bd060254d76c9629a65b7f7054455354'), BigInt('1')]
            ]),
            coins: BigInt('999502622402')
          }
        }
      ]
    ]);
  });
  it('should correctly map multiple assets in same utxo', () => {
    expect(
      utxosToCore([
        ...someFetchedUtxos,
        {
          ...someFetchedUtxos[0],
          asset_name: '5445535432',
          asset_policy: '8615849a049172dcd729fc3185032b266ceeba4dc21a0e61e713ebf8'
        }
      ])
    ).toEqual([
      [
        {
          address: Cardano.PaymentAddress(
            'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
          ),
          index: 1,
          txId: Cardano.TransactionId('8fd14baca91c674fafae59701b7dc0eda1266202ec8445bad3244bd8669a7fb5')
        },
        {
          address: Cardano.PaymentAddress(
            'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
          ),
          value: {
            assets: new Map<Cardano.AssetId, bigint>([
              [Cardano.AssetId('4eecf4013e2ab14ec8e500fafeafbdf2bd060254d76c9629a65b7f7054455354'), BigInt('1')],
              [Cardano.AssetId('8615849a049172dcd729fc3185032b266ceeba4dc21a0e61e713ebf85445535432'), BigInt('1')]
            ]),
            coins: BigInt('999502622402')
          }
        }
      ]
    ]);
  });
});
