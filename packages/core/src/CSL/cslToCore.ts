import { Asset, CSL, Cardano, util } from '..';
import { Transaction } from '@emurgo/cardano-serialization-lib-nodejs';

export const tx = (_input: Transaction): Cardano.TxAlonzo => {
  throw new Error('Not implemented');
};

export const value = (cslValue: CSL.Value): Cardano.Value => {
  const result: Cardano.Value = {
    coins: BigInt(cslValue.coin().to_str())
  };
  const multiasset = cslValue.multiasset();
  if (!multiasset) {
    return result;
  }
  result.assets = new Map();
  const scriptHashes = multiasset.keys();
  for (let scriptHashIdx = 0; scriptHashIdx < scriptHashes.len(); scriptHashIdx++) {
    const scriptHash = scriptHashes.get(scriptHashIdx);
    const assets = multiasset.get(scriptHash)!;
    const assetKeys = assets.keys();
    for (let assetIdx = 0; assetIdx < assetKeys.len(); assetIdx++) {
      const assetName = assetKeys.get(assetIdx);
      const assetAmount = BigInt(assets.get(assetName)!.to_str());
      if (assetAmount > 0n) {
        result.assets.set(Asset.util.createAssetId(scriptHash, assetName), assetAmount);
      }
    }
  }
  return result;
};

export const txIn = (input: CSL.TransactionInput, address: Cardano.Address): Cardano.TxIn => ({
  address,
  index: input.index(),
  txId: Cardano.TransactionId.fromHexBlob(util.bytesToHex(input.transaction_id().to_bytes()))
});

export const txOut = (output: CSL.TransactionOutput): Cardano.TxOut => {
  const dataHashBytes = output.data_hash()?.to_bytes();
  return {
    address: Cardano.Address(output.address().to_bech32()),
    datum: dataHashBytes ? Cardano.Hash32ByteBase16.fromHexBlob(util.bytesToHex(dataHashBytes)) : undefined,
    value: value(output.amount())
  };
};

export const txInputs = (inputs: CSL.TransactionInputs, address: Cardano.Address): Cardano.TxIn[] => {
  const result: Cardano.TxIn[] = [];
  for (let i = 0; i < inputs.len(); i++) {
    result.push(txIn(inputs.get(i), address));
  }
  return result;
};
