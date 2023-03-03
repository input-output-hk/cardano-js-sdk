/* eslint-disable max-len */
import { Asset, CML, Cardano, SerializationFailure, coreToCml } from '../../src';
import { BigNum } from '@dcspark/cardano-multiplatform-lib-nodejs';
import { ManagedFreeableScope } from '@cardano-sdk/util';
import {
  babbageTxBody,
  babbageTxOutWithDatumHash,
  babbageTxOutWithInlineDatum,
  invalidBabbageTxOut,
  script,
  signature,
  tx,
  txBody,
  txIn,
  txInWithAddress,
  txOut,
  txOutWithDatum,
  valueCoinOnly,
  valueWithAssets,
  vkey
} from './testData';

const txOutByron = {
  ...txOut,
  address: Cardano.PaymentAddress(
    'DdzFFzCqrhsw3prhfMFDNFowbzUku3QmrMwarfjUbWXRisodn97R436SHc1rimp4MhPNmbdYb1aTdqtGSJixMVMi5MkArDQJ6Sc1n3Ez'
  )
};

describe('coreToCml', () => {
  let scope: ManagedFreeableScope;

  beforeEach(() => {
    scope = new ManagedFreeableScope();
  });

  afterEach(() => {
    scope.dispose();
  });

  it('txIn', () => {
    expect(coreToCml.txIn(scope, txIn)).toBeInstanceOf(CML.TransactionInput);
  });
  describe('txOut', () => {
    it('converts to CML.TransactionOutput', () => {
      expect(coreToCml.txOut(scope, txOut)).toBeInstanceOf(CML.TransactionOutput);
      expect(coreToCml.txOut(scope, txOutByron)).toBeInstanceOf(CML.TransactionOutput);
    });
    it('converts datum to CML.DataHash', () => {
      const cmlTxOut = coreToCml.txOut(scope, txOutWithDatum);
      const dataHash = scope.manage(scope.manage(cmlTxOut.datum())?.as_data_hash());
      expect(dataHash).toBeInstanceOf(CML.DataHash);
      expect(Buffer.from(dataHash!.to_bytes()).toString('hex')).toBe(txOutWithDatum.datumHash);
    });
  });
  it('utxo', () => {
    expect(coreToCml.utxo(scope, [[txInWithAddress, txOut]])[0]).toBeInstanceOf(CML.TransactionUnspentOutput);
  });
  it('utxo with babbage fields', () => {
    expect(coreToCml.utxo(scope, [[txInWithAddress, babbageTxOutWithInlineDatum]])[0]).toBeInstanceOf(
      CML.TransactionUnspentOutput
    );

    expect(coreToCml.utxo(scope, [[txInWithAddress, babbageTxOutWithDatumHash]])[0]).toBeInstanceOf(
      CML.TransactionUnspentOutput
    );
  });
  it('utxo with babbage fields throws if both datumHash and inlineDatum are present', () => {
    expect(() => coreToCml.utxo(scope, [[txInWithAddress, invalidBabbageTxOut]])[0]).toThrow();
  });
  describe('value', () => {
    it('coin only', () => {
      const value = coreToCml.value(scope, valueCoinOnly);
      expect(scope.manage(value.coin()).to_str()).toEqual(valueCoinOnly.coins.toString());
      expect(scope.manage(value.multiasset())).toBeUndefined();
    });
    it('coin with assets', () => {
      const value = coreToCml.value(scope, valueWithAssets);
      expect(scope.manage(value.coin()).to_str()).toEqual(valueWithAssets.coins.toString());
      const multiasset = scope.manage(value.multiasset())!;
      expect(multiasset.len()).toBe(3);
      for (const [assetId, expectedAssetQuantity] of valueWithAssets.assets!.entries()) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const multiAsset = scope.manage(multiasset.get(scriptHash)!);
        const assetQuantity = BigInt(scope.manage(multiAsset.get(assetName)!).to_str());
        expect(assetQuantity).toBe(expectedAssetQuantity);
      }
      expect(value).toBeInstanceOf(CML.Value);
    });
  });
  describe('tokenMap', () => {
    it('inserts a single multiasset per asset policy', () => {
      const multiasset = coreToCml.tokenMap(scope, txOut.value.assets!);
      expect(multiasset).toBeInstanceOf(CML.MultiAsset);
      const scriptHashes = scope.manage(multiasset.keys());
      expect(scriptHashes.len()).toBe(3);
      for (const [assetId, expectedAssetQuantity] of txOut.value.assets!.entries()) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
        const multiAsset = scope.manage(multiasset.get(scriptHash)!);
        const assetQuantity = BigInt(scope.manage(multiAsset.get(assetName)!).to_str());
        expect(assetQuantity).toBe(expectedAssetQuantity);
      }
    });
  });
  // eslint-disable-next-line max-statements
  it('txBody', () => {
    const cmlBody = coreToCml.txBody(scope, txBody);
    const certs = scope.manage(cmlBody.certs());
    const cert = scope.manage(certs?.get(0));
    const poolRetirement = cert?.as_pool_retirement();
    const fee = scope.manage(cmlBody.fee());
    const inputs = scope.manage(cmlBody.inputs());
    const outputs = scope.manage(cmlBody.outputs());
    const input0 = scope.manage(inputs.get(0));
    const output0 = scope.manage(outputs.get(0));
    const output0Amount = scope.manage(output0.amount());
    const output0AmountCoin = scope.manage(output0Amount.coin());
    const withdrawals = scope.manage(cmlBody.withdrawals());
    const withdrawalKeys = scope.manage(withdrawals!.keys());
    const withdrawalKeys0 = scope.manage(withdrawalKeys.get(0));
    const withdrawal0 = scope.manage(cmlBody.withdrawals()?.get(withdrawalKeys0));
    expect(poolRetirement?.epoch()).toBe(500);
    expect(fee.to_str()).toBe(txBody.fee.toString());
    expect(Buffer.from(scope.manage(input0.transaction_id()).to_bytes()).toString('hex')).toBe(txBody.inputs[0].txId);
    expect(output0AmountCoin.to_str()).toBe(txBody.outputs[0].value.coins.toString());
    expect(Number(scope.manage(cmlBody.validity_start_interval())?.to_str())).toBe(
      txBody.validityInterval!.invalidBefore
    );
    expect(Number(scope.manage(cmlBody.ttl())?.to_str())).toBe(txBody.validityInterval!.invalidHereafter);
    expect(withdrawal0!.to_str()).toBe(txBody.withdrawals![0].quantity.toString());
    const mint = scope.manage(cmlBody.multiassets())!;
    const scriptHashes = scope.manage(mint.keys());
    const mintAssets1 = scope.manage(mint.get(scope.manage(scriptHashes.get(0)))!);
    const mintAssets1Keys = scope.manage(mintAssets1.keys());
    const mintAssets1Keys0 = scope.manage(mintAssets1Keys.get(0));
    const mintAssets1Amount = scope.manage(mintAssets1.get(mintAssets1Keys0)!);
    const mintAssets2 = scope.manage(mint.get(scope.manage(scriptHashes.get(1)))!);
    const mintAssets2Keys = scope.manage(mintAssets2.keys());
    const mintAssets2Keys0 = scope.manage(mintAssets2Keys.get(0));
    const mintAssets2Amount = scope.manage(mintAssets2.get(mintAssets2Keys0)!);

    expect(scope.manage(mintAssets1Amount.as_positive())!.to_str()).toBe('20');
    expect(scope.manage(mintAssets2Amount.as_negative())!.to_str()).toBe('50');
    expect(scope.manage(cmlBody.collateral())!.len()).toBe(1);
    expect(scope.manage(cmlBody.required_signers())!.len()).toBe(1);
    expect(scope.manage(cmlBody.script_data_hash())).toBeTruthy();
  });
  // eslint-disable-next-line max-statements
  it('Babbage txBody', () => {
    const cmlBody = coreToCml.txBody(scope, babbageTxBody);
    const certs = scope.manage(cmlBody.certs());
    const cert = scope.manage(certs?.get(0));
    const poolRetirement = cert?.as_pool_retirement();
    const fee = scope.manage(cmlBody.fee());
    const inputs = scope.manage(cmlBody.inputs());
    const outputs = scope.manage(cmlBody.outputs());
    const input0 = scope.manage(inputs.get(0));
    const output0 = scope.manage(outputs.get(0));
    const output0Amount = scope.manage(output0.amount());
    const output0AmountCoin = scope.manage(output0Amount.coin());
    const withdrawals = scope.manage(cmlBody.withdrawals());
    const withdrawalKeys = scope.manage(withdrawals!.keys());
    const withdrawalKeys0 = scope.manage(withdrawalKeys.get(0));
    const withdrawal0 = scope.manage(cmlBody.withdrawals()?.get(withdrawalKeys0));
    const totalCollateral = cmlBody.total_collateral();
    const referenceInputs = scope.manage(cmlBody.reference_inputs());
    const referenceInput0 = scope.manage(referenceInputs!.get(0));
    const collateralReturn = scope.manage(cmlBody.collateral_return());
    const collateralReturnCoin = scope.manage(scope.manage(collateralReturn!.amount())!.coin());

    expect(poolRetirement?.epoch()).toBe(500);
    expect(fee.to_str()).toBe(babbageTxBody.fee.toString());
    expect(Buffer.from(scope.manage(input0.transaction_id()).to_bytes()).toString('hex')).toBe(
      babbageTxBody.inputs[0].txId
    );
    expect(output0AmountCoin.to_str()).toBe(babbageTxBody.outputs[0].value.coins.toString());
    expect(Number(scope.manage(cmlBody.validity_start_interval())?.to_str())).toBe(
      babbageTxBody.validityInterval!.invalidBefore
    );
    expect(Number(scope.manage(cmlBody.ttl())?.to_str())).toBe(babbageTxBody.validityInterval!.invalidHereafter);
    expect(withdrawal0!.to_str()).toBe(babbageTxBody.withdrawals![0].quantity.toString());
    const mint = scope.manage(cmlBody.multiassets())!;
    const scriptHashes = scope.manage(mint.keys());
    const mintAssets1 = scope.manage(mint.get(scope.manage(scriptHashes.get(0)))!);
    const mintAssets1Keys = scope.manage(mintAssets1.keys());
    const mintAssets1Keys0 = scope.manage(mintAssets1Keys.get(0));
    const mintAssets1Amount = scope.manage(mintAssets1.get(mintAssets1Keys0)!);
    const mintAssets2 = scope.manage(mint.get(scope.manage(scriptHashes.get(1)))!);
    const mintAssets2Keys = scope.manage(mintAssets2.keys());
    const mintAssets2Keys0 = scope.manage(mintAssets2Keys.get(0));
    const mintAssets2Amount = scope.manage(mintAssets2.get(mintAssets2Keys0)!);

    expect(scope.manage(mintAssets1Amount.as_positive())!.to_str()).toBe('20');
    expect(scope.manage(mintAssets2Amount.as_negative())!.to_str()).toBe('50');
    expect(scope.manage(cmlBody.collateral())!.len()).toBe(1);
    expect(scope.manage(cmlBody.required_signers())!.len()).toBe(1);
    expect(scope.manage(cmlBody.script_data_hash())).toBeTruthy();
    expect(totalCollateral!.to_str()).toBe('100');
    expect(Buffer.from(scope.manage(referenceInput0.transaction_id()).to_bytes()).toString('hex')).toBe(
      babbageTxBody.inputs[0].txId
    );
    expect(collateralReturnCoin!.to_str()).toBe(babbageTxBody.collateralReturn!.value.coins.toString());
    expect(collateralReturnCoin!.to_str()).toBe(babbageTxBody.collateralReturn!.value.coins.toString());
    expect(scope.manage(collateralReturn!.address()).to_bech32()).toBe(
      babbageTxBody.collateralReturn!.address.toString()
    );
  });
  it('tx', () => {
    const cmlTx = coreToCml.tx(scope, tx);
    expect(cmlTx.body()).toBeInstanceOf(CML.TransactionBody);
    const witnessSet = scope.manage(cmlTx.witness_set());
    const vKeys = scope.manage(witnessSet.vkeys());
    const witness = scope.manage(vKeys!.get(0)!);
    const witnessSignature = scope.manage(witness.signature());
    const vKey = scope.manage(witness.vkey());
    const vKeyPublicKey = scope.manage(vKey.public_key());
    expect(Buffer.from(vKeyPublicKey.as_bytes()).toString('hex')).toBe(vkey);
    expect(witnessSignature.to_hex()).toBe(signature);
  });
  it('nativeScript', () => {
    const baseScript = coreToCml.nativeScript(scope, script);
    // eslint-disable-next-line @typescript-eslint/no-non-null-asserted-optional-chain
    const scriptAny = scope.manage(baseScript.as_script_any());
    const nativeScripts = scope.manage(scriptAny?.native_scripts());
    const firstSubScript = scope.manage(nativeScripts?.get(0));
    const firstSubScriptPubKey = scope.manage(firstSubScript?.as_script_pubkey());
    const secondSubScript = scope.manage(nativeScripts?.get(1));
    const secondSubScriptScriptAll = scope.manage(secondSubScript?.as_script_all());
    const secondSubScriptScriptAllNativeScripts = scope.manage(secondSubScriptScriptAll?.native_scripts());
    const secondSubScriptScriptAllNativeScripts0 = scope.manage(secondSubScriptScriptAllNativeScripts!.get(0));
    const secondSubScriptScriptAllNativeScripts1 = scope.manage(secondSubScriptScriptAllNativeScripts!.get(1));
    const secondSubScriptScriptAllNativeScripts2 = scope.manage(secondSubScriptScriptAllNativeScripts!.get(2));
    const secondSubScriptScriptAllNativeScripts1PubKey = scope.manage(
      secondSubScriptScriptAllNativeScripts1.as_script_pubkey()
    );

    expect(nativeScripts?.len()).toBe(2);
    expect(scope.manage(firstSubScriptPubKey?.addr_keyhash())?.to_bytes()).toStrictEqual(
      Uint8Array.from(Buffer.from('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538', 'hex'))
    );
    expect(secondSubScriptScriptAllNativeScripts!.len()).toEqual(3);
    expect(
      Number(scope.manage(scope.manage(secondSubScriptScriptAllNativeScripts0.as_timelock_expiry())?.slot())?.to_str())
    ).toEqual(3000);
    expect(scope.manage(secondSubScriptScriptAllNativeScripts1PubKey!.addr_keyhash()).to_bytes()).toStrictEqual(
      Uint8Array.from(Buffer.from('966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c37', 'hex'))
    );
    expect(
      Number(scope.manage(scope.manage(secondSubScriptScriptAllNativeScripts2.as_timelock_start())?.slot())?.to_str())
    ).toEqual(4000);
  });
  describe('txAuxiliaryData', () => {
    it('returns undefined for undefined data', () => expect(coreToCml.txAuxiliaryData(scope)).toBeUndefined());

    describe('txMetadata', () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping, @typescript-eslint/no-explicit-any
      const convertMetadatum = (metadatum: any) => {
        const label = 123n;
        const auxiliaryData = coreToCml.txAuxiliaryData(scope, { body: { blob: new Map([[label, metadatum]]) } });
        const metadata = scope.manage(auxiliaryData?.metadata());
        return scope.manage(metadata?.get(scope.manage(BigNum.from_str(label.toString()))));
      };

      const str64Len = 'looooooooooooooooooooooooooooooooooooooooooooooooooooooooooogstr';
      const str65Len = 'loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooogstr';

      it('converts number', () => {
        const number = 1234n;
        const metadatum = convertMetadatum(number);
        const metadatumAsInt = scope.manage(metadatum?.as_int());
        expect(scope.manage(metadatumAsInt!.as_positive())?.to_str()).toBe(number.toString());
      });

      it('converts text', () => {
        const str = str64Len;
        const metadatum = convertMetadatum(str);
        expect(metadatum?.as_text()).toBe(str);
      });

      it('converts list', () => {
        const list = [str64Len, 'str2'];
        const metadatum = convertMetadatum(list);
        const cmlList = scope.manage(metadatum?.as_list());
        expect(cmlList?.len()).toBe(list.length);
        expect(scope.manage(cmlList?.get(0))!.as_text()).toBe(list[0]);
        expect(scope.manage(cmlList?.get(1))!.as_text()).toBe(list[1]);
      });

      test('converts bytes', () => {
        const bytes = Buffer.from(str64Len);
        const metadatum = convertMetadatum(bytes);
        expect(metadatum?.as_bytes().buffer).toEqual(bytes.buffer);
      });

      it('converts map', () => {
        const key = new Map<Cardano.Metadatum, Cardano.Metadatum>([[567n, 'eight']]);
        const map = new Map<Cardano.Metadatum, Cardano.Metadatum>([
          [123n, 1234n],
          ['key', 'value'],
          [key, new Map<Cardano.Metadatum, Cardano.Metadatum>([[666n, 'cake']])]
        ]);
        const metadatum = convertMetadatum(map);
        const cmlMap = scope.manage(metadatum?.as_map());
        const metadatum1 = scope.manage(cmlMap?.get(convertMetadatum(123n)!));
        const metadatum2 = scope.manage(cmlMap?.get(convertMetadatum('key')!));
        const metadatum3 = scope.manage(cmlMap?.get(convertMetadatum(key)!));
        const metadatum1AsInt = scope.manage(metadatum1!.as_int());
        const metadatum3AsMap = scope.manage(metadatum3!.as_map());
        expect(cmlMap?.len()).toBe(map.size);
        expect(scope.manage(metadatum1AsInt.as_positive())?.to_str()).toBe('1234');
        expect(metadatum2!.as_text()).toBe('value');
        expect(scope.manage(metadatum3AsMap.get_i32(666)).as_text()).toBe('cake');
      });

      test('bytes too long throws error', () => {
        const bytes = Buffer.from(str65Len, 'utf8');
        expect(() => convertMetadatum(bytes)).toThrow(SerializationFailure.MaxLengthLimit);
      });

      it('text too long throws error', () => {
        expect(() => convertMetadatum(str65Len)).toThrow(SerializationFailure.MaxLengthLimit);
      });

      it('bool throws error', () => {
        expect(() => convertMetadatum(true)).toThrowError(SerializationFailure.InvalidType);
      });

      it('undefined throws error', () => {
        // eslint-disable-next-line unicorn/no-useless-undefined
        expect(() => convertMetadatum(undefined)).toThrowError(SerializationFailure.InvalidType);
      });

      it('null throws error', () => {
        expect(() => convertMetadatum(null)).toThrowError(SerializationFailure.InvalidType);
      });
    });

    it.todo('txScripts');
  });
});
