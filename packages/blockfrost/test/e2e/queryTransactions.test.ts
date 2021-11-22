import { walletProvider } from './config';

describe('blockfrostWalletProvider', () => {
  describe('queryTransactionsByHashes', () => {
    it('parses metadata correctly', async () => {
      const [tx] = await walletProvider.queryTransactionsByHashes([
        '84801fb64a9c5078c406ead24017ba0b069ef6ac6446fef8bdb8f97bade3cfa5'
      ]);
      expect(tx.auxiliaryData!.body.blob!['9223372036854775707']).toEqual(
        '9223372036854775707922337203685477570792233720368547757079223372'
      );
    });
  });
});
