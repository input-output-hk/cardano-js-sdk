import { Cardano } from '@cardano-sdk/core';
import { walletProvider } from './config';

describe('blockfrostWalletProvider', () => {
  describe('queryTransactionsByHashes', () => {
    it('parses metadata correctly', async () => {
      const [tx] = await walletProvider.queryTransactionsByHashes([
        Cardano.TransactionId('84801fb64a9c5078c406ead24017ba0b069ef6ac6446fef8bdb8f97bade3cfa5')
      ]);
      expect(tx.auxiliaryData!.body.blob!['9223372036854775707']).toEqual(
        '9223372036854775707922337203685477570792233720368547757079223372'
      );
    });
    it('parses collaterals correctly', async () => {
      const [tx] = await walletProvider.queryTransactionsByHashes([
        Cardano.TransactionId('12fa9af65e21b36ec4dc4cbce478e911d52585adb46f2b4fe3d6563e7ee5a61a')
      ]);
      expect(tx.body.inputs!.length).toEqual(1);
      expect(tx.body.outputs!.length).toEqual(1);
      expect(tx.body.collaterals!.length).toEqual(2);
      expect(tx.body.collaterals![0]).toEqual({
        address:
          'addr_test1qrv0j69s06vd56365fsh5ync44ykaqr4exwf2vt6tuv76' +
          'lcxy8jmk9rapjmuk2e7cfmshs27r4sx7tk0q3afktjf7j2qvdncx7',
        index: 1,
        txId: '2db6592c4782064295295b365c2e8ce84084fa24b1b3f5834f3c6b65268b7878'
      });
    });
  });
});
