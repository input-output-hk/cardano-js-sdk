import { Cardano, InvalidStringError } from '@cardano-sdk/core';
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

  describe('queryTransactionsByAddresses', () => {
    it('Shelley address (addr_test1)', async () => {
      const txs = await walletProvider.queryTransactionsByAddresses([
        Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg')
      ]);
      expect(txs.length).toBeGreaterThanOrEqual(47);
      expect(txs[0].id).toBe('bedfc2ff545ef1ac3cc4d1a06aa67a6d68a663ffb1092f8764390b8a58ef97b4');
      expect(txs[46].id).toBe('f632b491bb481b4d93fa69e1901ebb623a3af65fde500f1b019eaabd4bb2a980');
    });
    it('extended Shelley address (addr_test1)', async () => {
      const txs = await walletProvider.queryTransactionsByAddresses([
        Cardano.Address(
          'addr_test1qph5x6uahxhxyvtqatzj77sjtjmdjycemt5ncjuj2r4e' +
            'yflkdap42xncd6cazjarce6jh8mx52fcf8ugststvyklj70qhzhe9h'
        )
      ]);
      expect(txs.length).toBeGreaterThanOrEqual(4);
      expect(txs[0].id).toBe('a01623f7e3fc679c9f369e06ac0cd942740cade30367b24cedace20a430af1cf');
      expect(txs[3].id).toBe('667f714ee9d9975ca4fa0f5451e006d3dafcdafb7342fe288ebcaf17c100a996');
    });
    it('Icarus Byron address (2c)', async () => {
      const txs = await walletProvider.queryTransactionsByAddresses([
        Cardano.Address('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr')
      ]);
      expect(txs.length).toBeGreaterThanOrEqual(1);
      expect(txs[0].id).toBe('2822d491a890b40cd2a22003b81a97f63c2b8c373b1b0b8dfa1598739fe34c06');
    });
    it('multiple address types', async () => {
      const txs = await walletProvider.queryTransactionsByAddresses([
        Cardano.Address('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr'),
        Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
        Cardano.Address(
          'addr_test1qph5x6uahxhxyvtqatzj77sjtjmdjycemt5ncjuj2r4e' +
            'yflkdap42xncd6cazjarce6jh8mx52fcf8ugststvyklj70qhzhe9h'
        )
      ]);
      expect(txs.length).toBeGreaterThanOrEqual(52);
      expect(txs[0].id).toBe('2822d491a890b40cd2a22003b81a97f63c2b8c373b1b0b8dfa1598739fe34c06');
      expect(txs[51].id).toBe('667f714ee9d9975ca4fa0f5451e006d3dafcdafb7342fe288ebcaf17c100a996');
    });
    it('Shelley address not used - no transactions', async () => {
      const txs = await walletProvider.queryTransactionsByAddresses([
        Cardano.Address('addr_test1vrfxjeunkc9xu8rpnhgkluptaq0rm8kyxh8m3q9vtcetjwshvpnsm')
      ]);
      expect(txs.length).toBe(0);
    });
    it('query ignores invalid transaction (script failure)', async () => {
      const txs = await walletProvider.queryTransactionsByAddresses([
        Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg')
      ]);
      expect(
        txs.find(
          (tx) => tx.id === Cardano.TransactionId('43149210cbbfbc92bc2b199bb14cb15330414e2288ac31be92a3b5a490f9abfc')
        )
      ).toBeUndefined();
    });
    it('stake address throws error', async () => {
      expect(() => Cardano.Address('stake_test1ur676rnu57m272uvflhm8ahgu8xk980vxg382zye2wpxnjs2dnddx')).toThrowError(
        InvalidStringError
      );
    });
  });
});
