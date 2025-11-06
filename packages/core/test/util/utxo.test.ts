import { Cardano, createUtxoId, sortTxIn, sortUtxoByTxIn } from '../../src';

describe('util/utxo', () => {
  describe('createUtxoId', () => {
    it('creates a UTXO ID from hash and index', () => {
      const txHash = '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5';
      const index = 0;

      expect(createUtxoId(txHash, index)).toBe('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5:0');
    });

    it('handles different indices', () => {
      const txHash = '1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477';

      expect(createUtxoId(txHash, 0)).toBe('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477:0');
      expect(createUtxoId(txHash, 1)).toBe('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477:1');
      expect(createUtxoId(txHash, 99)).toBe('1e043f100dce12d107f679685acd2fc0610e10f72a92d412794c9773d11d8477:99');
    });
  });

  describe('sortTxIn', () => {
    it('sorts by txId first (ascending)', () => {
      const txIn1: Cardano.TxIn = {
        index: 0,
        txId: Cardano.TransactionId('1f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
      };
      const txIn2: Cardano.TxIn = {
        index: 0,
        txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
      };

      expect(sortTxIn(txIn1, txIn2)).toBeGreaterThan(0);
      expect(sortTxIn(txIn2, txIn1)).toBeLessThan(0);
    });

    it('sorts by index when txId is the same', () => {
      const txId = Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
      const txIn1: Cardano.TxIn = { index: 1, txId };
      const txIn2: Cardano.TxIn = { index: 0, txId };
      const txIn3: Cardano.TxIn = { index: 2, txId };

      expect(sortTxIn(txIn1, txIn2)).toBeGreaterThan(0);
      expect(sortTxIn(txIn2, txIn1)).toBeLessThan(0);
      expect(sortTxIn(txIn3, txIn1)).toBeGreaterThan(0);
    });

    it('returns 0 for identical TxIn', () => {
      const txId = Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
      const txIn1: Cardano.TxIn = { index: 0, txId };
      const txIn2: Cardano.TxIn = { index: 0, txId };

      expect(sortTxIn(txIn1, txIn2)).toBe(0);
    });

    it('can be used with Array.sort to sort TxIn array', () => {
      const txId1 = Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
      const txId2 = Cardano.TransactionId('1f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');

      const inputs: Cardano.TxIn[] = [
        { index: 1, txId: txId1 },
        { index: 0, txId: txId2 },
        { index: 0, txId: txId1 },
        { index: 2, txId: txId1 }
      ];

      inputs.sort(sortTxIn);

      expect(inputs[0]).toEqual({ index: 0, txId: txId1 });
      expect(inputs[1]).toEqual({ index: 1, txId: txId1 });
      expect(inputs[2]).toEqual({ index: 2, txId: txId1 });
      expect(inputs[3]).toEqual({ index: 0, txId: txId2 });
    });
  });

  describe('sortUtxoByTxIn', () => {
    const address = Cardano.PaymentAddress(
      'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
    );

    it('sorts UTXOs by txId first (ascending)', () => {
      const utxo1: Cardano.Utxo = [
        {
          address,
          index: 0,
          txId: Cardano.TransactionId('1f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        },
        { address, value: { coins: 1_000_000n } }
      ];
      const utxo2: Cardano.Utxo = [
        {
          address,
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        },
        { address, value: { coins: 2_000_000n } }
      ];

      expect(sortUtxoByTxIn(utxo1, utxo2)).toBeGreaterThan(0);
      expect(sortUtxoByTxIn(utxo2, utxo1)).toBeLessThan(0);
    });

    it('sorts UTXOs by index when txId is the same', () => {
      const txId = Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
      const utxo1: Cardano.Utxo = [
        { address, index: 1, txId },
        { address, value: { coins: 1_000_000n } }
      ];
      const utxo2: Cardano.Utxo = [
        { address, index: 0, txId },
        { address, value: { coins: 2_000_000n } }
      ];
      const utxo3: Cardano.Utxo = [
        { address, index: 2, txId },
        { address, value: { coins: 3_000_000n } }
      ];

      expect(sortUtxoByTxIn(utxo1, utxo2)).toBeGreaterThan(0);
      expect(sortUtxoByTxIn(utxo2, utxo1)).toBeLessThan(0);
      expect(sortUtxoByTxIn(utxo3, utxo1)).toBeGreaterThan(0);
    });

    it('returns 0 for identical UTXOs (same TxIn)', () => {
      const txId = Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
      const utxo1: Cardano.Utxo = [
        { address, index: 0, txId },
        { address, value: { coins: 1_000_000n } }
      ];
      const utxo2: Cardano.Utxo = [
        { address, index: 0, txId },
        { address, value: { coins: 2_000_000n } }
      ];

      expect(sortUtxoByTxIn(utxo1, utxo2)).toBe(0);
    });

    it('can be used with Array.sort to sort UTXO array', () => {
      const txId1 = Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
      const txId2 = Cardano.TransactionId('1f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');

      const utxos: Cardano.Utxo[] = [
        [
          { address, index: 1, txId: txId1 },
          { address, value: { coins: 1_000_000n } }
        ],
        [
          { address, index: 0, txId: txId2 },
          { address, value: { coins: 2_000_000n } }
        ],
        [
          { address, index: 0, txId: txId1 },
          { address, value: { coins: 3_000_000n } }
        ],
        [
          { address, index: 2, txId: txId1 },
          { address, value: { coins: 4_000_000n } }
        ]
      ];

      utxos.sort(sortUtxoByTxIn);

      // Should be sorted by txId first, then by index
      expect(utxos[0][0]).toEqual({ address, index: 0, txId: txId1 });
      expect(utxos[1][0]).toEqual({ address, index: 1, txId: txId1 });
      expect(utxos[2][0]).toEqual({ address, index: 2, txId: txId1 });
      expect(utxos[3][0]).toEqual({ address, index: 0, txId: txId2 });
    });

    it('handles UTXOs with different addresses but same TxIn', () => {
      const txId = Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5');
      const address1 = Cardano.PaymentAddress(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      );
      const address2 = Cardano.PaymentAddress(
        'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
      );

      const utxo1: Cardano.Utxo = [
        { address: address1, index: 0, txId },
        { address: address1, value: { coins: 1_000_000n } }
      ];
      const utxo2: Cardano.Utxo = [
        { address: address2, index: 0, txId },
        { address: address2, value: { coins: 2_000_000n } }
      ];

      // Should return 0 because TxIn is the same (sorting only considers TxIn, not TxOut)
      expect(sortUtxoByTxIn(utxo1, utxo2)).toBe(0);
    });
  });
});
