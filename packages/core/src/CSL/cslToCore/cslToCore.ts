import { Asset, CSL, Cardano, SerializationFailure, util } from '../..';
import { SerializationError } from '../../errors';
import { createCertificate } from './certificate';

export const txRequiredExtraSignatures = (
  signatures: CSL.Ed25519KeyHashes | undefined
): Cardano.Ed25519KeyHash[] | undefined => {
  if (!signatures) return;
  const requiredSignatures: Cardano.Ed25519KeyHash[] = [];
  for (let i = 0; i < signatures.len(); i++) {
    const signature = signatures.get(i);
    const cardanoSignature = Cardano.Ed25519KeyHash(Buffer.from(signature.to_bytes()).toString('hex'));
    requiredSignatures.push(cardanoSignature);
  }
  return requiredSignatures;
};

export const txWithdrawals = (withdrawals?: CSL.Withdrawals): Cardano.Withdrawal[] | undefined => {
  if (!withdrawals) return;
  const result: Cardano.Withdrawal[] = [];
  const keys = withdrawals.keys();
  for (let i = 0; i < keys.len(); i++) {
    const key = keys.get(i);
    const value = withdrawals.get(key);
    const rewardAccount = Cardano.RewardAccount(key.to_address().to_bech32());
    result.push({ quantity: BigInt(value!.to_str()), stakeAddress: rewardAccount });
  }
  return result;
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

export const txIn = (input: CSL.TransactionInput): Cardano.NewTxIn => ({
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

export const txOutputs = (outputs: CSL.TransactionOutputs): Cardano.TxOut[] => {
  const result: Cardano.TxOut[] = [];
  for (let i = 0; i < outputs.len(); i++) {
    result.push(txOut(outputs.get(i)));
  }
  return result;
};

export const txInputs = (inputs: CSL.TransactionInputs): Cardano.NewTxIn[] => {
  const result: Cardano.NewTxIn[] = [];
  for (let i = 0; i < inputs.len(); i++) {
    result.push(txIn(inputs.get(i)));
  }
  return result;
};

export const txCertificates = (certificates?: CSL.Certificates): Cardano.Certificate[] | undefined => {
  if (!certificates) return;
  const result: Cardano.Certificate[] = [];
  for (let i = 0; i < certificates.len(); i++) {
    const cslCertificate = certificates.get(i);
    result.push(createCertificate(cslCertificate));
  }
  return result;
};

export const txMint = (assets?: CSL.Mint): Cardano.TokenMap | undefined => {
  if (!assets) return;
  const assetMap: Cardano.TokenMap = new Map();
  const keys = assets.keys();
  for (let i = 0; i < keys.len(); i++) {
    const scriptHash = keys.get(i);
    const mintAssets = assets.get(scriptHash);
    if (!mintAssets) continue;
    const mintKeys = mintAssets.keys();
    for (let k = 0; k < mintKeys.len(); k++) {
      const assetName = mintKeys.get(k);
      const assetValueInt = mintAssets.get(assetName);
      const assetId = Asset.util.createAssetId(scriptHash, assetName);
      if (!assetValueInt) continue;
      const quantity = assetValueInt.is_positive()
        ? BigInt(assetValueInt.as_positive()!.to_str())
        : BigInt(assetValueInt.as_negative()!.to_str()) * -1n;
      assetMap.set(assetId, quantity);
    }
  }
  return assetMap;
};

export const txBody = (body: CSL.TransactionBody): Cardano.NewTxBodyAlonzo => {
  const cslScriptDataHash = body.script_data_hash();
  const cslCollaterals = body.collateral();

  return {
    certificates: txCertificates(body.certs()),
    collaterals: cslCollaterals && txInputs(cslCollaterals),
    fee: BigInt(body.fee().to_str()),
    inputs: txInputs(body.inputs()),
    mint: txMint(body.multiassets()),
    outputs: txOutputs(body.outputs()),
    requiredExtraSignatures: txRequiredExtraSignatures(body.required_signers()),
    scriptIntegrityHash:
      cslScriptDataHash && Cardano.util.Hash32ByteBase16(Buffer.from(cslScriptDataHash.to_bytes()).toString('hex')),
    validityInterval: {
      invalidBefore: body.validity_start_interval(),
      invalidHereafter: body.ttl()
    },
    withdrawals: txWithdrawals(body.withdrawals())
  };
};

export const txBootstrap = (bootstraps?: CSL.BootstrapWitnesses): Cardano.BootstrapWitness[] | undefined => {
  if (!bootstraps) return;
  const result: Cardano.BootstrapWitness[] = [];
  for (let i = 0; i < bootstraps.len(); i++) {
    const bootstrap = bootstraps.get(i);
    result.push({
      addressAttributes: bootstrap.attributes().toString(),
      chainCode: bootstrap.chain_code().toString(),
      key: Cardano.Ed25519PublicKey(bootstrap.vkey.toString()),
      signature: Cardano.Ed25519Signature(bootstrap.signature.toString())
    });
  }
  return result;
};

export const txRedeemers = (redeemers?: CSL.Redeemers): Cardano.Redeemer[] | undefined => {
  if (!redeemers) return;
  const result: Cardano.Redeemer[] = [];
  for (let j = 0; j < redeemers.len(); j++) {
    const reedeemer = redeemers.get(j);
    const index = reedeemer.index();
    const data = reedeemer.data();
    const exUnits = reedeemer.ex_units();

    /**
     * CSL.RedeemerTagKind = Spend, Mint, Cert, Reward
     * should we modify Cardano.Redeemer.purpose to match or just map reward to withdrawal ??
     */
    const redeemerTagKind = reedeemer.tag().kind();

    result.push({
      executionUnits: { memory: Number(exUnits.mem()), steps: Number(exUnits.steps()) },
      index: Number(index),
      purpose: Object.values(Cardano.RedeemerPurpose)[redeemerTagKind],
      scriptHash: Cardano.Hash28ByteBase16(Buffer.from(data.to_bytes()).toString())
    });
  }
  return result;
};

export const txWitnessSet = (witnessSet: CSL.TransactionWitnessSet): Cardano.Witness => {
  const vkeys: CSL.Vkeywitnesses | undefined = witnessSet.vkeys()!;
  const redeemers: CSL.Redeemers | undefined = witnessSet.redeemers();
  const bootstraps: CSL.BootstrapWitnesses | undefined = witnessSet.bootstraps();

  const txSignatures: Cardano.Signatures = new Map();
  if (vkeys) {
    for (let i = 0; i < vkeys!.len(); i++) {
      const witness = vkeys.get(i);
      txSignatures.set(
        Cardano.Ed25519PublicKey(Buffer.from(witness.vkey().public_key().as_bytes()).toString('hex')),
        Cardano.Ed25519Signature(witness.signature().to_hex())
      );
    }
  }

  return {
    // TODO: add support for scripts
    bootstrap: txBootstrap(bootstraps),
    // TODO: implement datums
    redeemers: txRedeemers(redeemers),
    signatures: txSignatures
  };
};

export const txMetadatum = (transactionMetadatum: CSL.TransactionMetadatum): Cardano.Metadatum => {
  switch (transactionMetadatum.kind()) {
    case CSL.TransactionMetadatumKind.Bytes:
      return transactionMetadatum.as_bytes();
    case CSL.TransactionMetadatumKind.Int: {
      const int = transactionMetadatum.as_int()!;
      if (int.is_positive()) return BigInt(int.as_positive()!.to_str());
      return BigInt(int.as_negative()!.to_str()) * -1n;
    }
    case CSL.TransactionMetadatumKind.MetadataList: {
      const list = transactionMetadatum.as_list();
      const metaDatumList: Cardano.Metadatum[] = [];
      for (let j = 0; j < list.len(); j++) {
        const listItem = list.get(j);
        metaDatumList.push(txMetadatum(listItem));
      }
      return metaDatumList;
    }
    case CSL.TransactionMetadatumKind.MetadataMap: {
      const txMap = transactionMetadatum.as_map();
      const metdatumMap = new Map<Cardano.Metadatum, Cardano.Metadatum>();
      for (let i = 0; i < txMap.keys().len(); i++) {
        const mapKey = txMap.keys().get(i);
        const mapValue = txMap.get(mapKey);
        metdatumMap.set(txMetadatum(mapKey), txMetadatum(mapValue));
      }
      return metdatumMap;
    }
    case CSL.TransactionMetadatumKind.Text:
      return transactionMetadatum.as_text();
    default:
      throw new SerializationError(SerializationFailure.InvalidType);
  }
};

export const txMetadata = (auxiliaryMetadata?: CSL.GeneralTransactionMetadata): Cardano.TxMetadata | undefined => {
  if (!auxiliaryMetadata) return;
  const auxiliaryMetadataMap: Cardano.TxMetadata = new Map();
  const metadataKeys = auxiliaryMetadata.keys();
  for (let i = 0; i < metadataKeys.len(); i++) {
    const key = metadataKeys.get(i);
    const transactionMetadatum = auxiliaryMetadata.get(key);
    if (transactionMetadatum) {
      auxiliaryMetadataMap.set(BigInt(key.to_str()), txMetadatum(transactionMetadatum));
    }
  }
  return auxiliaryMetadataMap;
};

export const txAuxiliaryData = (auxiliaryData?: CSL.AuxiliaryData): Cardano.AuxiliaryData | undefined => {
  if (!auxiliaryData) return;
  // TODO: create hash
  const auxiliaryMetadata = auxiliaryData.metadata();
  return {
    body: {
      blob: txMetadata(auxiliaryMetadata)
    }
  };
};

export const utxo = (cslUtxos: CSL.TransactionUnspentOutput[]) =>
  cslUtxos.map((cslUtxo) => [txIn(cslUtxo.input()), txOut(cslUtxo.output())]);

export const newTx = (cslTx: CSL.Transaction): Cardano.NewTxAlonzo => {
  const transactionHash = Cardano.TransactionId.fromHexBlob(
    util.bytesToHex(CSL.hash_transaction(cslTx.body()).to_bytes())
  );
  const auxiliary_data = cslTx.auxiliary_data();

  const witnessSet = cslTx.witness_set();

  return {
    auxiliaryData: txAuxiliaryData(auxiliary_data),
    body: txBody(cslTx.body()),
    id: transactionHash,
    witness: txWitnessSet(witnessSet)
  };
};

export const nativeScript = (script: CSL.NativeScript): Cardano.NativeScript => {
  let coreScript: Cardano.NativeScript;
  const scriptKind = script.kind();

  switch (scriptKind) {
    case Cardano.NativeScriptKind.RequireSignature: {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        keyHash: Cardano.Ed25519KeyHash(
          util.bytesToHex(script.as_script_pubkey()!.addr_keyhash().to_bytes()).toString()
        ),
        kind: Cardano.NativeScriptKind.RequireSignature
      };
      break;
    }
    case Cardano.NativeScriptKind.RequireAllOf: {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAllOf,
        scripts: new Array<Cardano.NativeScript>()
      };
      const scriptAll = script.as_script_all();
      for (let i = 0; i < scriptAll!.native_scripts().len(); ++i) {
        coreScript.scripts.push(nativeScript(scriptAll!.native_scripts().get(i)));
      }
      break;
    }
    case Cardano.NativeScriptKind.RequireAnyOf: {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAnyOf,
        scripts: new Array<Cardano.NativeScript>()
      };
      const scriptAny = script.as_script_any();
      for (let i = 0; i < scriptAny!.native_scripts().len(); ++i) {
        coreScript.scripts.push(nativeScript(scriptAny!.native_scripts().get(i)));
      }
      break;
    }
    case Cardano.NativeScriptKind.RequireMOf: {
      const scriptMofK = script.as_script_n_of_k();
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireMOf,
        required: scriptMofK!.n(),
        scripts: new Array<Cardano.NativeScript>()
      };

      for (let i = 0; i < scriptMofK!.native_scripts().len(); ++i) {
        coreScript.scripts.push(nativeScript(scriptMofK!.native_scripts().get(i)));
      }
      break;
    }
    case Cardano.NativeScriptKind.RequireTimeBefore: {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeBefore,
        slot: script.as_timelock_expiry()!.slot()
      };
      break;
    }
    case Cardano.NativeScriptKind.RequireTimeAfter: {
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeAfter,
        slot: script.as_timelock_start()!.slot()
      };
      break;
    }
    default:
      throw new SerializationError(
        SerializationFailure.InvalidNativeScriptKind,
        `Native Script Kind value '${scriptKind}' is not supported.`
      );
  }
  return coreScript;
};
