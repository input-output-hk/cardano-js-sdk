import { AssetId, CslTestUtil } from '@cardano-sdk/util-dev';
import { CSL, Cardano, coreToCsl, cslToCore } from '@cardano-sdk/core';

describe('cslToCore', () => {
  describe('value', () => {
    it('coin only', () => {
      const coins = 100_000n;
      const value = CSL.Value.new(CSL.BigNum.from_str(coins.toString()));
      const quantities = cslToCore.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toBeUndefined();
    });
    it('coin with assets', () => {
      const coins = 100_000n;
      const assets = new Map([
        [AssetId.TSLA, 100n],
        [AssetId.PXL, 200n]
      ]);
      const value = coreToCsl.value({ assets, coins });
      const quantities = cslToCore.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toEqual(assets);
    });
  });

  it('txIn', () => {
    const cslInput = CslTestUtil.createTxInput();
    const address = Cardano.Address('addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24');
    const txIn = cslToCore.txIn(cslInput, address);
    expect(typeof txIn.index).toBe('number');
    expect(typeof txIn.txId).toBe('string');
    expect(txIn.address).toBe(address);
  });

  it('txOut', () => {
    const value = { coins: 100_000n };
    const cslOutput = CslTestUtil.createOutput(value);
    const txOut = cslToCore.txOut(cslOutput);
    expect(typeof txOut.address).toBe('string');
    expect(txOut.value).toEqual(value);
    expect(txOut.datum).toBeUndefined();
  });

  test('witness set', () => {
    const txIn: Cardano.TxIn = {
      address: Cardano.Address(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      ),
      index: 0,
      txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
    };
    const txOut: Cardano.TxOut = {
      address: Cardano.Address(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      ),
      value: {
        assets: new Map([
          [Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'), 20n],
          [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), 50n]
        ]),
        coins: 10n
      }
    };
    const coreTxBody: Cardano.TxBodyAlonzo = {
      certificates: [
        {
          __typename: Cardano.CertificateType.PoolRetirement,
          epoch: 500,
          poolId: Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc')
        }
      ],
      fee: 10n,
      inputs: [txIn],
      outputs: [txOut],
      validityInterval: {
        invalidBefore: 100,
        invalidHereafter: 1000
      },
      withdrawals: [
        {
          quantity: 5n,
          stakeAddress: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
        }
      ]
    };

    const vkey = '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39';
    const signature =
      'bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755';
    const coreTx: Cardano.NewTxAlonzo = {
      body: coreTxBody,
      id: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8'),
      witness: {
        signatures: new Map([[Cardano.Ed25519PublicKey(vkey), Cardano.Ed25519Signature(signature)]])
      }
    };
    const cslTx = coreToCsl.tx(coreTx);
    expect(cslToCore.txWitnessSet(cslTx.witness_set())).not.toThrow();
  });

  test.skip('txBody', () => {
    const txIn: Cardano.TxIn = {
      address: Cardano.Address(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      ),
      index: 0,
      txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
    };
    const txOut: Cardano.TxOut = {
      address: Cardano.Address(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      ),
      value: {
        assets: new Map([
          [Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'), 20n],
          [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), 50n]
        ]),
        coins: 10n
      }
    };

    const coreTxBody: Cardano.TxBodyAlonzo = {
      certificates: [
        {
          __typename: Cardano.CertificateType.PoolRetirement,
          epoch: 500,
          poolId: Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc')
        }
      ],
      fee: 10n,
      inputs: [txIn],
      outputs: [txOut],
      validityInterval: {
        invalidBefore: 100,
        invalidHereafter: 1000
      },
      withdrawals: [
        {
          quantity: 5n,
          stakeAddress: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
        }
      ]
    };
    const vkey = '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39';
    const signature =
      'bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755';
    const coreTx: Cardano.NewTxAlonzo = {
      body: coreTxBody,
      id: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8'),
      witness: {
        signatures: new Map([[Cardano.Ed25519PublicKey(vkey), Cardano.Ed25519Signature(signature)]])
      }
    };
    expect(cslToCore.newTx(coreToCsl.tx(coreTx))).toEqual(coreTx);
  });
});
