import * as AssetId from '../assetId.js';
import { Cardano } from '@cardano-sdk/core';
import { handleAssetId } from './mockData.js';
import { resolvedHandle } from './mockHandleProvider.js';
import delay from 'delay';
import type { UtxoProvider } from '@cardano-sdk/core';

export const utxo: Cardano.Utxo[] = [
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      index: 1,
      txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        assets: new Map([
          [AssetId.PXL, 5n],
          [AssetId.TSLA, 10n]
        ]),
        coins: 4_027_026_465n
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      index: 0,
      txId: Cardano.TransactionId('c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        assets: new Map([
          [AssetId.TSLA, 15n],
          [AssetId.PXL, 20n]
        ]),
        coins: 3_289_566n
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      index: 1,
      txId: Cardano.TransactionId('c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        coins: 3_289_566n
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      index: 2,
      txId: Cardano.TransactionId('c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        coins: 1_000_000n
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      index: 3,
      txId: Cardano.TransactionId('c7c0973c6bbf1a04a9f306da7814b4fa564db649bf48b0bd93c273bd03143547')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        coins: 5_289_566n
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      index: 2,
      txId: Cardano.TransactionId('ea1517b8c36fea3148df9aa1f49bbee66ff59a5092331a67bd8b3c427e1d79d7')
    },
    {
      address: resolvedHandle.cardanoAddress,
      value: {
        assets: new Map([[handleAssetId, 1n]]),
        coins: 9_825_963n
      }
    }
  ]
];

export const utxo2 = utxo.slice(1);

/**
 * Provider stub for testing
 *
 * @param The options
 * @param The.address patch utxos to use a specific utxo output address
 * @param The.utxoSet The set of UTXOs to be included in the wallet state.
 *
 * returns UtxoProvider-compatible object
 */
export const mockUtxoProvider = ({
  address,
  utxoSet = utxo
}: {
  address?: Cardano.PaymentAddress;
  utxoSet?: Cardano.Utxo[];
} = {}): UtxoProvider => ({
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  utxoByAddresses: jest
    .fn()
    .mockResolvedValue(address ? utxoSet.map(([txIn, txOut]) => [txIn, { ...txOut, address }]) : utxoSet)
});

export const mockUtxoProvider2 = (delayMs: number): UtxoProvider => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementation(() => delay(delayMs).then(() => resolvedValue));
  return {
    healthCheck: delayedJestFn(true),
    utxoByAddresses: delayedJestFn(utxo2)
  };
};
export type UtxoProviderStub = ReturnType<typeof mockUtxoProvider>;
