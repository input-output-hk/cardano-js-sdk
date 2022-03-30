import * as Asset from '../Asset';
import * as Cardano from '../Cardano';
import {
  Address,
  AssetName,
  Assets,
  AuxiliaryData,
  BigNum,
  Certificates,
  Ed25519Signature,
  GeneralTransactionMetadata,
  Int,
  MetadataList,
  MetadataMap,
  Mint,
  MintAssets,
  MultiAsset,
  PublicKey,
  RewardAddress,
  ScriptHash,
  Transaction,
  TransactionBody,
  TransactionHash,
  TransactionInput,
  TransactionInputs,
  TransactionMetadatum,
  TransactionOutput,
  TransactionOutputs,
  TransactionUnspentOutput,
  TransactionWitnessSet,
  Value,
  Vkey,
  Vkeywitness,
  Vkeywitnesses,
  Withdrawals,
  hash_auxiliary_data
} from '@emurgo/cardano-serialization-lib-nodejs';

import * as certificate from './certificate';
import { SerializationError } from '../errors';
import { SerializationFailure } from '..';
import { parseCslAddress } from './parseCslAddress';
export * as certificate from './certificate';

export const tokenMap = (assets: Cardano.TokenMap) => {
  const multiasset = MultiAsset.new();
  for (const assetId of assets.keys()) {
    const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
    const assetsObj = Assets.new();
    const amount = BigNum.from_str(assets.get(assetId)!.toString());
    assetsObj.insert(assetName, amount);
    multiasset.insert(scriptHash, assetsObj);
  }
  return multiasset;
};

export const value = ({ coins, assets }: Cardano.Value): Value => {
  const result = Value.new(BigNum.from_str(coins.toString()));
  if (!assets) {
    return result;
  }
  if (assets.size > 0) {
    result.set_multiasset(tokenMap(assets));
  }
  return result;
};

export const txIn = (core: Cardano.TxIn): TransactionInput =>
  TransactionInput.new(TransactionHash.from_bytes(Buffer.from(core.txId, 'hex')), core.index);

export const txOut = (core: Cardano.TxOut): TransactionOutput =>
  TransactionOutput.new(parseCslAddress(core.address.toString())!, value(core.value));

export const utxo = (core: Cardano.Utxo[]): TransactionUnspentOutput[] =>
  core.map((item) => TransactionUnspentOutput.new(txIn(item[0]), txOut(item[1])));

const check64Length = (metadatum: string | Uint8Array): void => {
  const len = typeof metadatum === 'string' ? Buffer.from(metadatum, 'utf8').length : metadatum.length;
  if (len > 64)
    throw new SerializationError(
      SerializationFailure.MaxLengthLimit,
      `Metadatum value '${metadatum}' is too long. Length is ${len}. Max length is 64 bytes`
    );
};

export const txMetadatum = (metadatum: Cardano.Metadatum): TransactionMetadatum => {
  if (metadatum === null) throw new SerializationError(SerializationFailure.InvalidType);
  switch (typeof metadatum) {
    case 'number':
    case 'boolean':
    case 'undefined':
      throw new SerializationError(SerializationFailure.InvalidType);
    case 'bigint':
      return TransactionMetadatum.new_int(Int.new(BigNum.from_str(metadatum.toString())));
    case 'string':
      check64Length(metadatum);
      return TransactionMetadatum.new_text(metadatum);
    default: {
      if (Array.isArray(metadatum)) {
        const metadataList = MetadataList.new();
        for (const metadataItem of metadatum) {
          metadataList.add(txMetadatum(metadataItem));
        }
        return TransactionMetadatum.new_list(metadataList);
      } else if (ArrayBuffer.isView(metadatum)) {
        check64Length(metadatum);
        return TransactionMetadatum.new_bytes(metadatum);
      }
      const metadataMap = MetadataMap.new();
      for (const [key, data] of metadatum.entries()) {
        metadataMap.insert(txMetadatum(key), txMetadatum(data));
      }
      return TransactionMetadatum.new_map(metadataMap);
    }
  }
};

export const txMetadata = (blob: Map<bigint, Cardano.Metadatum>): GeneralTransactionMetadata => {
  const metadata = GeneralTransactionMetadata.new();
  for (const [key, data] of blob.entries()) {
    metadata.insert(BigNum.from_str(key.toString()), txMetadatum(data));
  }
  return metadata;
};

export const txMint = (mint: Cardano.TokenMap) => {
  const cslMint = Mint.new();
  const mintMap = new Map<Cardano.PolicyId, [ScriptHash, MintAssets]>();
  for (const [assetId, quantity] of mint.entries()) {
    const policyId = Asset.util.policyIdFromAssetId(assetId);
    const assetName = Asset.util.assetNameFromAssetId(assetId);
    let [scriptHash, mintAssets] = mintMap.get(policyId) || [];
    if (!scriptHash || !mintAssets) {
      scriptHash = ScriptHash.from_bytes(Buffer.from(policyId, 'hex'));
      mintAssets = MintAssets.new();
      mintMap.set(policyId, [scriptHash, mintAssets]);
    }
    const intQuantity =
      quantity >= 0n
        ? Int.new(BigNum.from_str(quantity.toString()))
        : Int.new_negative(BigNum.from_str((quantity * -1n).toString()));
    mintAssets.insert(AssetName.new(Buffer.from(assetName, 'hex')), intQuantity);
  }
  for (const [scriptHash, mintAssets] of mintMap.values()) {
    cslMint.insert(scriptHash, mintAssets);
  }
  return cslMint;
};

export const txAuxiliaryData = (auxiliaryData?: Cardano.AuxiliaryData): AuxiliaryData | undefined => {
  if (!auxiliaryData) return;
  const result = AuxiliaryData.new();
  // TODO: add support for auxiliaryData.scripts
  const { blob } = auxiliaryData.body;
  if (blob) {
    result.set_metadata(txMetadata(blob));
  }
  return result;
};

export const txBody = (
  { inputs, outputs, fee, validityInterval, certificates, withdrawals, mint }: Cardano.TxBodyAlonzo,
  auxiliaryData?: Cardano.AuxiliaryData
): TransactionBody => {
  const cslInputs = TransactionInputs.new();
  for (const input of inputs) {
    cslInputs.add(txIn(input));
  }
  const cslOutputs = TransactionOutputs.new();
  for (const output of outputs) {
    cslOutputs.add(txOut(output));
  }
  const cslBody = TransactionBody.new(
    cslInputs,
    cslOutputs,
    BigNum.from_str(fee.toString()),
    validityInterval.invalidHereafter
  );
  if (validityInterval.invalidBefore) {
    cslBody.set_validity_start_interval(validityInterval.invalidBefore);
  }
  if (mint) {
    cslBody.set_mint(txMint(mint));
  }
  if (certificates?.length) {
    const certs = Certificates.new();
    for (const cert of certificates) {
      certs.add(certificate.create(cert));
    }
    cslBody.set_certs(certs);
  }
  if (withdrawals?.length) {
    const cslWithdrawals = Withdrawals.new();
    for (const { stakeAddress, quantity } of withdrawals) {
      const cslAddress = RewardAddress.from_address(Address.from_bech32(stakeAddress.toString()));
      if (!cslAddress) {
        throw new SerializationError(
          SerializationFailure.InvalidAddress,
          `Invalid withdrawal address: ${stakeAddress}`
        );
      }
      cslWithdrawals.insert(cslAddress, BigNum.from_str(quantity.toString()));
    }
    cslBody.set_withdrawals(cslWithdrawals);
  }
  const cslAuxiliaryData = txAuxiliaryData(auxiliaryData);
  if (cslAuxiliaryData) {
    cslBody.set_auxiliary_data_hash(hash_auxiliary_data(cslAuxiliaryData));
  }
  return cslBody;
};

export const witnessSet = (signatures: Cardano.Signatures): TransactionWitnessSet => {
  const cslWitnessSet = TransactionWitnessSet.new();
  const vkeyWitnesses = Vkeywitnesses.new();
  for (const [vkey, signature] of signatures.entries()) {
    const publicKey = PublicKey.from_bytes(Buffer.from(vkey, 'hex'));
    const vkeyWitness = Vkeywitness.new(Vkey.new(publicKey), Ed25519Signature.from_hex(signature.toString()));
    vkeyWitnesses.add(vkeyWitness);
  }
  cslWitnessSet.set_vkeys(vkeyWitnesses);
  return cslWitnessSet;
};

export const tx = ({ body, witness, auxiliaryData }: Cardano.NewTxAlonzo): Transaction => {
  const txWitnessSet = witnessSet(witness.signatures);
  // Possible optimization: only convert auxiliary data once
  return Transaction.new(txBody(body, auxiliaryData), txWitnessSet, txAuxiliaryData(auxiliaryData));
};
