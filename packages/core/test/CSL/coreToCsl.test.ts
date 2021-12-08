/* eslint-disable max-len */
import { Asset, CSL, Cardano, coreToCsl } from '../../src';

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

describe('coreToCsl', () => {
  it('txIn', () => {
    expect(coreToCsl.txIn(txIn)).toBeInstanceOf(CSL.TransactionInput);
  });
  it('txOut', () => {
    expect(coreToCsl.txOut(txOut)).toBeInstanceOf(CSL.TransactionOutput);
  });
  it('utxo', () => {
    expect(coreToCsl.utxo([[txIn, txOut]])[0]).toBeInstanceOf(CSL.TransactionUnspentOutput);
  });
  describe('value', () => {
    it('coin only', () => {
      const quantities = { coins: 100_000n };
      const value = coreToCsl.value(quantities);
      expect(value.coin().to_str()).toEqual(quantities.coins.toString());
      expect(value.multiasset()).toBeUndefined();
    });
    it('coin with assets', () => {
      const value = coreToCsl.value(txOut.value);
      expect(value.coin().to_str()).toEqual(txOut.value.coins.toString());
      const multiasset = value.multiasset()!;
      expect(multiasset.len()).toBe(2);
      for (const [assetId, expectedAssetQuantity] of txOut.value.assets!.entries()) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
        expect(assetQuantity).toBe(expectedAssetQuantity);
      }
      expect(value).toBeInstanceOf(CSL.Value);
    });
  });
  it('tokenMap', () => {
    const multiasset = coreToCsl.tokenMap(txOut.value.assets!);
    expect(multiasset).toBeInstanceOf(CSL.MultiAsset);
    expect(multiasset.len()).toBe(2);
    for (const [assetId, expectedAssetQuantity] of txOut.value.assets!.entries()) {
      const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
      const assetQuantity = BigInt(multiasset.get(scriptHash)!.get(assetName)!.to_str());
      expect(assetQuantity).toBe(expectedAssetQuantity);
    }
  });
  it('txBody', () => {
    const cslBody = coreToCsl.txBody(coreTxBody);
    expect(cslBody.certs()?.get(0).as_pool_retirement()?.epoch()).toBe(500);
    expect(cslBody.fee().to_str()).toBe(coreTxBody.fee.toString());
    expect(Buffer.from(cslBody.inputs().get(0).transaction_id().to_bytes()).toString('hex')).toBe(
      coreTxBody.inputs[0].txId
    );
    expect(cslBody.outputs().get(0).amount().coin().to_str()).toBe(coreTxBody.outputs[0].value.coins.toString());
    expect(cslBody.validity_start_interval()).toBe(coreTxBody.validityInterval.invalidBefore);
    expect(cslBody.ttl()).toBe(coreTxBody.validityInterval.invalidHereafter);
    expect(cslBody.withdrawals()?.get(cslBody.withdrawals()!.keys().get(0)!)?.to_str()).toBe(
      coreTxBody.withdrawals![0].quantity.toString()
    );
  });
  it('tx', () => {
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
    expect(cslTx.body()).toBeInstanceOf(CSL.TransactionBody);
    const witness = cslTx.witness_set().vkeys()!.get(0)!;
    expect(Buffer.from(witness.vkey().public_key().as_bytes()).toString('hex')).toBe(vkey);
    expect(witness.signature().to_hex()).toBe(signature);
  });
});
