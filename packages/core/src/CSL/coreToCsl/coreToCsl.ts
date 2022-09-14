import * as Asset from '../../Asset';
import * as Cardano from '../../Cardano';
import {
  Address,
  AssetName,
  Assets,
  AuxiliaryData,
  BigNum,
  BootstrapWitness,
  BootstrapWitnesses,
  Certificates,
  Ed25519KeyHash,
  Ed25519KeyHashes,
  Ed25519Signature,
  GeneralTransactionMetadata,
  Int,
  MetadataList,
  MetadataMap,
  Mint,
  MintAssets,
  MultiAsset,
  NativeScript,
  NativeScripts,
  PlutusScripts,
  PublicKey,
  RewardAddress,
  ScriptAll,
  ScriptAny,
  ScriptDataHash,
  ScriptHash,
  ScriptNOfK,
  ScriptPubkey,
  TimelockExpiry,
  TimelockStart,
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
import { SerializationError, SerializationFailure } from '../..';
import { parseCslAddress } from '../parseCslAddress';

export const tokenMap = (map: Cardano.TokenMap) => {
  const multiasset = MultiAsset.new();
  const policyMap: Map<string, { assetsMap: Map<AssetName, BigNum>; scriptHash: ScriptHash }> = new Map();

  for (const assetId of map.keys()) {
    const { assetName, scriptHash } = Asset.util.parseAssetId(assetId);
    const policyId = Asset.util.policyIdFromAssetId(assetId).toString();
    const amount = BigNum.from_str(map.get(assetId)!.toString());
    if (!policyMap.has(policyId)) {
      policyMap.set(policyId, { assetsMap: new Map([[assetName, amount]]), scriptHash });
    } else {
      const { assetsMap } = policyMap.get(policyId)!;
      policyMap.set(policyId, { assetsMap: assetsMap.set(assetName, amount), scriptHash });
    }
  }

  for (const { assetsMap, scriptHash } of policyMap.values()) {
    const assets = Assets.new();
    for (const [assetName, amount] of assetsMap.entries()) {
      assets.insert(assetName, amount);
    }
    multiasset.insert(scriptHash, assets);
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

export const txIn = (core: Cardano.NewTxIn): TransactionInput =>
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

// eslint-disable-next-line complexity
export const txMetadatum = (metadatum: Cardano.Metadatum): TransactionMetadatum => {
  if (metadatum === null) throw new SerializationError(SerializationFailure.InvalidType);
  switch (typeof metadatum) {
    case 'number':
    case 'boolean':
    case 'undefined':
      throw new SerializationError(SerializationFailure.InvalidType);
    case 'bigint': {
      const cslInt =
        metadatum >= 0
          ? Int.new(BigNum.from_str(metadatum.toString()))
          : Int.new_negative(BigNum.from_str((metadatum * -1n).toString()));
      return TransactionMetadatum.new_int(cslInt);
    }
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

export const nativeScript = (script: Cardano.NativeScript): NativeScript => {
  let cslScript: NativeScript;
  const kind = script.kind;

  switch (kind) {
    case Cardano.NativeScriptKind.RequireSignature: {
      cslScript = NativeScript.new_script_pubkey(
        ScriptPubkey.new(Ed25519KeyHash.from_bytes(Buffer.from(script.keyHash, 'hex')))
      );
      break;
    }
    case Cardano.NativeScriptKind.RequireAllOf: {
      const cslScripts = NativeScripts.new();
      for (const subscript of script.scripts) {
        cslScripts.add(nativeScript(subscript));
      }
      cslScript = NativeScript.new_script_all(ScriptAll.new(cslScripts));
      break;
    }
    case Cardano.NativeScriptKind.RequireAnyOf: {
      const cslScripts2 = NativeScripts.new();
      for (const subscript of script.scripts) {
        cslScripts2.add(nativeScript(subscript));
      }
      cslScript = NativeScript.new_script_any(ScriptAny.new(cslScripts2));
      break;
    }
    case Cardano.NativeScriptKind.RequireMOf: {
      const cslScripts3 = NativeScripts.new();
      for (const subscript of script.scripts) {
        cslScripts3.add(nativeScript(subscript));
      }
      cslScript = NativeScript.new_script_n_of_k(ScriptNOfK.new(script.required, cslScripts3));
      break;
    }
    case Cardano.NativeScriptKind.RequireTimeBefore: {
      cslScript = NativeScript.new_timelock_expiry(
        TimelockExpiry.new_timelockexpiry(BigNum.from_str(script.slot.toString()))
      );
      break;
    }
    case Cardano.NativeScriptKind.RequireTimeAfter: {
      cslScript = NativeScript.new_timelock_start(
        TimelockStart.new_timelockstart(BigNum.from_str(script.slot.toString()))
      );
      break;
    }
    default:
      throw new SerializationError(
        SerializationFailure.InvalidNativeScriptKind,
        `Native Script Type value '${kind}' is not supported.`
      );
  }

  return cslScript;
};

export const getScripts = (
  scripts: Cardano.Script[]
): { nativeScripts: NativeScripts; plutusScripts: PlutusScripts } => {
  const nativeScripts: NativeScripts = NativeScripts.new();
  const plutusScripts: PlutusScripts = PlutusScripts.new();

  for (const script of scripts) {
    switch (script.__type) {
      case Cardano.ScriptType.Native:
        nativeScripts.add(nativeScript(script));
        break;
      // TODO: add support for Plutus scripts.
      case Cardano.ScriptType.Plutus:
      default:
        throw new SerializationError(
          SerializationFailure.InvalidScriptType,
          `Script Type value '${script.__type}' is not supported.`
        );
    }
  }

  return { nativeScripts, plutusScripts };
};

export const txAuxiliaryData = (auxiliaryData?: Cardano.AuxiliaryData): AuxiliaryData | undefined => {
  if (!auxiliaryData) return;
  const result = AuxiliaryData.new();

  const { blob, scripts } = auxiliaryData.body;
  if (blob) {
    result.set_metadata(txMetadata(blob));
  }

  if (scripts) {
    const { nativeScripts, plutusScripts } = getScripts(scripts);

    result.set_native_scripts(nativeScripts);
    result.set_plutus_scripts(plutusScripts);
  }

  return result;
};

const txInputs = (coreInputs: Cardano.NewTxIn[]) => {
  const cslInputs = TransactionInputs.new();
  for (const input of coreInputs) {
    cslInputs.add(txIn(input));
  }
  return cslInputs;
};

const keyHashes = (coreHashes: Cardano.Ed25519KeyHash[]) => {
  const cslKeyHashes = Ed25519KeyHashes.new();
  for (const signature of coreHashes) {
    cslKeyHashes.add(Ed25519KeyHash.from_bytes(Buffer.from(signature, 'hex')));
  }
  return cslKeyHashes;
};

const txWithdrawals = (coreWithdrawals: Cardano.Withdrawal[]) => {
  const cslWithdrawals = Withdrawals.new();
  for (const { stakeAddress, quantity } of coreWithdrawals) {
    const cslAddress = RewardAddress.from_address(Address.from_bech32(stakeAddress.toString()));
    if (!cslAddress) {
      throw new SerializationError(SerializationFailure.InvalidAddress, `Invalid withdrawal address: ${stakeAddress}`);
    }
    cslWithdrawals.insert(cslAddress, BigNum.from_str(quantity.toString()));
  }
  return cslWithdrawals;
};

// eslint-disable-next-line complexity
export const txBody = (
  {
    inputs,
    outputs,
    fee,
    validityInterval,
    certificates,
    withdrawals,
    mint,
    collaterals,
    requiredExtraSignatures,
    scriptIntegrityHash
  }: Cardano.NewTxBodyAlonzo,
  auxiliaryData?: Cardano.AuxiliaryData
): TransactionBody => {
  const cslOutputs = TransactionOutputs.new();
  for (const output of outputs) {
    cslOutputs.add(txOut(output));
  }
  const cslBody = TransactionBody.new(
    txInputs(inputs),
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
  if (collaterals) {
    cslBody.set_collateral(txInputs(collaterals));
  }
  if (requiredExtraSignatures?.length) {
    cslBody.set_required_signers(keyHashes(requiredExtraSignatures));
  }
  if (scriptIntegrityHash) {
    cslBody.set_script_data_hash(ScriptDataHash.from_bytes(Buffer.from(scriptIntegrityHash, 'hex')));
  }
  if (certificates?.length) {
    const certs = Certificates.new();
    for (const cert of certificates) {
      certs.add(certificate.create(cert));
    }
    cslBody.set_certs(certs);
  }
  if (withdrawals?.length) {
    cslBody.set_withdrawals(txWithdrawals(withdrawals));
  }
  const cslAuxiliaryData = txAuxiliaryData(auxiliaryData);
  if (cslAuxiliaryData) {
    cslBody.set_auxiliary_data_hash(hash_auxiliary_data(cslAuxiliaryData));
  }

  return cslBody;
};

export const txWitnessBootstrap = (bootstrap: Cardano.BootstrapWitness[]): BootstrapWitnesses => {
  const witnesses = BootstrapWitnesses.new();
  for (const coreWitness of bootstrap) {
    witnesses.add(
      BootstrapWitness.new(
        Vkey.new(PublicKey.from_bytes(Buffer.from(coreWitness.key.toString(), 'hex'))),
        Ed25519Signature.from_hex(coreWitness.signature.toString()),
        Buffer.from(coreWitness.chainCode || '', 'hex'),
        Buffer.from(coreWitness.addressAttributes || '', 'base64')
      )
    );
  }
  return witnesses;
};

export const witnessSet = (witness: Cardano.Witness): TransactionWitnessSet => {
  const cslWitnessSet = TransactionWitnessSet.new();
  const vkeyWitnesses = Vkeywitnesses.new();

  if (witness.scripts) {
    const { nativeScripts, plutusScripts } = getScripts(witness.scripts);

    cslWitnessSet.set_native_scripts(nativeScripts);
    cslWitnessSet.set_plutus_scripts(plutusScripts);
  }

  for (const [vkey, signature] of witness.signatures.entries()) {
    const publicKey = PublicKey.from_bytes(Buffer.from(vkey, 'hex'));
    const vkeyWitness = Vkeywitness.new(Vkey.new(publicKey), Ed25519Signature.from_hex(signature.toString()));
    vkeyWitnesses.add(vkeyWitness);
  }
  cslWitnessSet.set_vkeys(vkeyWitnesses);

  if (witness.bootstrap) {
    cslWitnessSet.set_bootstraps(txWitnessBootstrap(witness.bootstrap));
  }

  return cslWitnessSet;
};

export const tx = ({ body, witness, auxiliaryData }: Cardano.NewTxAlonzo): Transaction => {
  const txWitnessSet = witnessSet(witness);
  // Possible optimization: only convert auxiliary data once
  return Transaction.new(txBody(body, auxiliaryData), txWitnessSet, txAuxiliaryData(auxiliaryData));
};
