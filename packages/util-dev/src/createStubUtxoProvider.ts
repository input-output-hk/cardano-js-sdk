import { Cardano } from '@cardano-sdk/core';
import delay from 'delay';
import type { UtxoByAddressesArgs, UtxoProvider } from '@cardano-sdk/core';

export const somePartialUtxos: Cardano.Utxo[] = [
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
      ),
      index: 0,
      txId: Cardano.TransactionId('8fd14baca91c674fafae59701b7dc0eda1266202ec8445bad3244bd8669a7fb5')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
      ),
      value: {
        coins: BigInt('999502622402')
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      ),
      index: 0,
      txId: Cardano.TransactionId('a62624fdc47e8b774ddff11a9a56cae5fa9b072975af87bf0a0583fca0e345f4')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      ),
      value: {
        coins: BigInt('19717868703')
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
      ),
      index: 0,
      txId: Cardano.TransactionId('3d4cd09885d39673125c3a15f8acb45d92fde137f9effe7a5131f6cc7241d960')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
      ),
      value: {
        coins: BigInt('10306556787917')
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
      ),
      index: 0,
      txId: Cardano.TransactionId('19251f57476d7af2777252270413c01383d9503110a68b4fde1a239c119c4f5d')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
      ),
      value: {
        coins: BigInt('1497246388')
      }
    }
  ]
];

export const createStubUtxoProvider = (utxos: Cardano.Utxo[] = somePartialUtxos, delayMs?: number): UtxoProvider => ({
  healthCheck: async () => {
    if (delayMs) await delay(delayMs);
    return { ok: true };
  },
  utxoByAddresses: async ({ addresses }: UtxoByAddressesArgs) => {
    if (delayMs) await delay(delayMs);
    return utxos.filter((u) => addresses.includes(u[0].address) && addresses.includes(u[1].address));
  }
});
