import * as Cardano from '../../Cardano';
import {
  AddrAttributes,
  Address,
  AssetName,
  Assets,
  AuxiliaryData,
  BigNum,
  BootstrapWitness,
  BootstrapWitnesses,
  Certificates,
  DataHash,
  Datum,
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
  PlutusV1Scripts,
  PlutusV2Scripts,
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
} from '@dcspark/cardano-multiplatform-lib-nodejs';

import * as certificate from './certificate';
import { ManagedFreeableScope } from '@cardano-sdk/util';
import { SerializationError, SerializationFailure } from '../../errors';
import { assetNameFromAssetId, parseAssetId, policyIdFromAssetId } from '../../Asset/util/assetId';
import { parseCmlAddress } from '../parseCmlAddress';

export const tokenMap = (scope: ManagedFreeableScope, map: Cardano.TokenMap) => {
  const multiasset = scope.manage(MultiAsset.new());
  const policyMap: Map<string, { assetsMap: Map<AssetName, BigNum>; scriptHash: ScriptHash }> = new Map();

  for (const assetId of map.keys()) {
    const { assetName, scriptHash } = parseAssetId(assetId);
    scope.manage(assetName);
    scope.manage(scriptHash);

    const policyId = policyIdFromAssetId(assetId).toString();
    const amount = scope.manage(BigNum.from_str(map.get(assetId)!.toString()));
    if (!policyMap.has(policyId)) {
      policyMap.set(policyId, { assetsMap: new Map([[assetName, amount]]), scriptHash });
    } else {
      const { assetsMap } = policyMap.get(policyId)!;
      policyMap.set(policyId, { assetsMap: assetsMap.set(assetName, amount), scriptHash });
    }
  }

  for (const { assetsMap, scriptHash } of policyMap.values()) {
    const assets = scope.manage(Assets.new());
    for (const [assetName, amount] of assetsMap.entries()) {
      scope.manage(assets.insert(assetName, amount));
    }
    scope.manage(multiasset.insert(scriptHash, assets));
  }
  return multiasset;
};

export const value = (scope: ManagedFreeableScope, { coins, assets }: Cardano.Value): Value => {
  const result = scope.manage(Value.new(scope.manage(BigNum.from_str(coins.toString()))));
  if (!assets) {
    return result;
  }
  if (assets.size > 0) {
    result.set_multiasset(tokenMap(scope, assets));
  }
  return result;
};

export const txIn = (scope: ManagedFreeableScope, core: Cardano.NewTxIn): TransactionInput =>
  scope.manage(
    TransactionInput.new(
      scope.manage(TransactionHash.from_bytes(Buffer.from(core.txId, 'hex'))),
      scope.manage(BigNum.from_str(core.index.toString()))
    )
  );

export const txOut = (scope: ManagedFreeableScope, core: Cardano.TxOut): TransactionOutput => {
  const cslTxOut = scope.manage(
    TransactionOutput.new(parseCmlAddress(scope, core.address.toString())!, value(scope, core.value))
  );

  if (core.datum !== undefined) {
    cslTxOut.set_datum(
      scope.manage(Datum.new_data_hash(scope.manage(DataHash.from_bytes(Buffer.from(core.datum.toString(), 'hex')))))
    );
  }

  return cslTxOut;
};

export const utxo = (scope: ManagedFreeableScope, core: Cardano.Utxo[]): TransactionUnspentOutput[] =>
  core.map((item) => scope.manage(TransactionUnspentOutput.new(txIn(scope, item[0]), txOut(scope, item[1]))));

const check64Length = (metadatum: string | Uint8Array): void => {
  const len = typeof metadatum === 'string' ? Buffer.from(metadatum, 'utf8').length : metadatum.length;
  if (len > 64)
    throw new SerializationError(
      SerializationFailure.MaxLengthLimit,
      `Metadatum value '${metadatum}' is too long. Length is ${len}. Max length is 64 bytes`
    );
};

// eslint-disable-next-line complexity
export const txMetadatum = (scope: ManagedFreeableScope, metadatum: Cardano.Metadatum): TransactionMetadatum => {
  if (metadatum === null) throw new SerializationError(SerializationFailure.InvalidType);
  switch (typeof metadatum) {
    case 'number':
    case 'boolean':
    case 'undefined':
      throw new SerializationError(SerializationFailure.InvalidType);
    case 'bigint': {
      const cslInt =
        metadatum >= 0
          ? scope.manage(Int.new(scope.manage(BigNum.from_str(metadatum.toString()))))
          : scope.manage(Int.new_negative(scope.manage(BigNum.from_str((metadatum * -1n).toString()))));
      return scope.manage(TransactionMetadatum.new_int(cslInt));
    }
    case 'string':
      check64Length(metadatum);
      return scope.manage(TransactionMetadatum.new_text(metadatum));
    default: {
      if (Array.isArray(metadatum)) {
        const metadataList = scope.manage(MetadataList.new());
        for (const metadataItem of metadatum) {
          metadataList.add(txMetadatum(scope, metadataItem));
        }
        return scope.manage(TransactionMetadatum.new_list(metadataList));
      } else if (ArrayBuffer.isView(metadatum)) {
        check64Length(metadatum);
        return scope.manage(TransactionMetadatum.new_bytes(metadatum));
      }
      const metadataMap = scope.manage(MetadataMap.new());
      for (const [key, data] of metadatum.entries()) {
        metadataMap.insert(txMetadatum(scope, key), txMetadatum(scope, data));
      }
      return scope.manage(TransactionMetadatum.new_map(metadataMap));
    }
  }
};

export const txMetadata = (
  scope: ManagedFreeableScope,
  blob: Map<bigint, Cardano.Metadatum>
): GeneralTransactionMetadata => {
  const metadata = scope.manage(GeneralTransactionMetadata.new());
  for (const [key, data] of blob.entries()) {
    metadata.insert(scope.manage(BigNum.from_str(key.toString())), txMetadatum(scope, data));
  }
  return metadata;
};

export const txMint = (scope: ManagedFreeableScope, mint: Cardano.TokenMap) => {
  const cslMint = scope.manage(Mint.new());
  const mintMap = new Map<Cardano.PolicyId, [ScriptHash, MintAssets]>();
  for (const [assetId, quantity] of mint.entries()) {
    const policyId = policyIdFromAssetId(assetId);
    const assetName = assetNameFromAssetId(assetId);
    let [scriptHash, mintAssets] = mintMap.get(policyId) || [];
    if (!scriptHash || !mintAssets) {
      scriptHash = scope.manage(ScriptHash.from_bytes(Buffer.from(policyId, 'hex')));
      mintAssets = scope.manage(MintAssets.new());
      mintMap.set(policyId, [scriptHash, mintAssets]);
    }
    const intQuantity =
      quantity >= 0n
        ? scope.manage(Int.new(scope.manage(BigNum.from_str(quantity.toString()))))
        : scope.manage(Int.new_negative(scope.manage(BigNum.from_str((quantity * -1n).toString()))));
    mintAssets.insert(scope.manage(AssetName.new(Buffer.from(assetName, 'hex'))), intQuantity);
  }
  for (const [scriptHash, mintAssets] of mintMap.values()) {
    cslMint.insert(scriptHash, mintAssets);
  }
  return cslMint;
};

export const nativeScript = (scope: ManagedFreeableScope, script: Cardano.NativeScript): NativeScript => {
  let cslScript: NativeScript;
  const kind = script.kind;

  // cslScript scope is managed last. Only internal objects should be added to the scope within the switch
  switch (kind) {
    case Cardano.NativeScriptKind.RequireSignature: {
      cslScript = scope.manage(
        NativeScript.new_script_pubkey(
          scope.manage(ScriptPubkey.new(scope.manage(Ed25519KeyHash.from_bytes(Buffer.from(script.keyHash, 'hex')))))
        )
      );
      break;
    }
    case Cardano.NativeScriptKind.RequireAllOf: {
      const cslScripts = scope.manage(NativeScripts.new());
      for (const subscript of script.scripts) {
        cslScripts.add(nativeScript(scope, subscript));
      }
      cslScript = scope.manage(NativeScript.new_script_all(scope.manage(ScriptAll.new(cslScripts))));
      break;
    }
    case Cardano.NativeScriptKind.RequireAnyOf: {
      const cslScripts2 = scope.manage(NativeScripts.new());
      for (const subscript of script.scripts) {
        cslScripts2.add(nativeScript(scope, subscript));
      }
      cslScript = scope.manage(NativeScript.new_script_any(scope.manage(ScriptAny.new(cslScripts2))));
      break;
    }
    case Cardano.NativeScriptKind.RequireMOf: {
      const cslScripts3 = scope.manage(NativeScripts.new());
      for (const subscript of script.scripts) {
        cslScripts3.add(nativeScript(scope, subscript));
      }
      cslScript = scope.manage(
        NativeScript.new_script_n_of_k(scope.manage(ScriptNOfK.new(script.required, cslScripts3)))
      );
      break;
    }
    case Cardano.NativeScriptKind.RequireTimeBefore: {
      cslScript = scope.manage(
        NativeScript.new_timelock_expiry(
          scope.manage(TimelockExpiry.new(scope.manage(BigNum.from_str(script.slot.toString()))))
        )
      );
      break;
    }
    case Cardano.NativeScriptKind.RequireTimeAfter: {
      cslScript = scope.manage(
        NativeScript.new_timelock_start(
          scope.manage(TimelockStart.new(scope.manage(BigNum.from_str(script.slot.toString()))))
        )
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
  scope: ManagedFreeableScope,
  scripts: Cardano.Script[]
): { nativeScripts: NativeScripts; plutusV1Scripts: PlutusV1Scripts; plutusV2Scripts: PlutusV2Scripts } => {
  const nativeScripts: NativeScripts = scope.manage(NativeScripts.new());
  const plutusV1Scripts: PlutusV1Scripts = scope.manage(PlutusV1Scripts.new());
  const plutusV2Scripts: PlutusV2Scripts = scope.manage(PlutusV2Scripts.new());

  for (const script of scripts) {
    switch (script.__type) {
      case Cardano.ScriptType.Native:
        nativeScripts.add(nativeScript(scope, script));
        break;
      // TODO: add support for Plutus scripts. Use script.version to add as V1 or V2.
      case Cardano.ScriptType.Plutus:
      default:
        throw new SerializationError(
          SerializationFailure.InvalidScriptType,
          `Script Type value '${script.__type}' is not supported.`
        );
    }
  }

  return { nativeScripts, plutusV1Scripts, plutusV2Scripts };
};

export const txAuxiliaryData = (
  scope: ManagedFreeableScope,
  auxiliaryData?: Cardano.AuxiliaryData
): AuxiliaryData | undefined => {
  if (!auxiliaryData) return;
  const result = scope.manage(AuxiliaryData.new());

  const { blob, scripts } = auxiliaryData.body;
  if (blob) {
    result.set_metadata(txMetadata(scope, blob));
  }

  if (scripts) {
    const { nativeScripts, plutusV1Scripts, plutusV2Scripts } = getScripts(scope, scripts);

    result.set_native_scripts(nativeScripts);
    result.set_plutus_v1_scripts(plutusV1Scripts);
    result.set_plutus_v2_scripts(plutusV2Scripts);
  }

  return result;
};

const txInputs = (scope: ManagedFreeableScope, coreInputs: Cardano.NewTxIn[]) => {
  const cslInputs = scope.manage(TransactionInputs.new());
  for (const input of coreInputs) {
    cslInputs.add(txIn(scope, input));
  }
  return cslInputs;
};

const keyHashes = (scope: ManagedFreeableScope, coreHashes: Cardano.Ed25519KeyHash[]) => {
  const cslKeyHashes = scope.manage(Ed25519KeyHashes.new());
  for (const signature of coreHashes) {
    cslKeyHashes.add(scope.manage(Ed25519KeyHash.from_bytes(Buffer.from(signature, 'hex'))));
  }
  return cslKeyHashes;
};

const txWithdrawals = (scope: ManagedFreeableScope, coreWithdrawals: Cardano.Withdrawal[]) => {
  const cslWithdrawals = scope.manage(Withdrawals.new());
  for (const { stakeAddress, quantity } of coreWithdrawals) {
    const cslAddress = RewardAddress.from_address(scope.manage(Address.from_bech32(stakeAddress.toString())));
    if (!cslAddress) {
      throw new SerializationError(SerializationFailure.InvalidAddress, `Invalid withdrawal address: ${stakeAddress}`);
    }
    cslWithdrawals.insert(scope.manage(cslAddress), scope.manage(BigNum.from_str(quantity.toString())));
  }
  return cslWithdrawals;
};

// eslint-disable-next-line complexity
export const txBody = (
  scope: ManagedFreeableScope,
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
  const cslOutputs = scope.manage(TransactionOutputs.new());
  for (const output of outputs) {
    cslOutputs.add(txOut(scope, output));
  }
  const cslBody = scope.manage(
    TransactionBody.new(
      txInputs(scope, inputs),
      cslOutputs,
      scope.manage(BigNum.from_str(fee.toString())),
      BigNum.from_str(validityInterval.invalidHereafter ? validityInterval.invalidHereafter.toString() : '0')
    )
  );

  if (validityInterval.invalidBefore) {
    cslBody.set_validity_start_interval(
      BigNum.from_str(validityInterval.invalidBefore ? validityInterval.invalidBefore.toString() : '0')
    );
  }
  if (mint) {
    cslBody.set_mint(txMint(scope, mint));
  }
  if (collaterals) {
    cslBody.set_collateral(txInputs(scope, collaterals));
  }
  if (requiredExtraSignatures?.length) {
    cslBody.set_required_signers(keyHashes(scope, requiredExtraSignatures));
  }
  if (scriptIntegrityHash) {
    cslBody.set_script_data_hash(scope.manage(ScriptDataHash.from_bytes(Buffer.from(scriptIntegrityHash, 'hex'))));
  }
  if (certificates?.length) {
    const certs = scope.manage(Certificates.new());
    for (const cert of certificates) {
      certs.add(certificate.create(scope, cert));
    }
    cslBody.set_certs(certs);
  }
  if (withdrawals?.length) {
    cslBody.set_withdrawals(txWithdrawals(scope, withdrawals));
  }
  const cslAuxiliaryData = txAuxiliaryData(scope, auxiliaryData);
  if (cslAuxiliaryData) {
    cslBody.set_auxiliary_data_hash(scope.manage(hash_auxiliary_data(cslAuxiliaryData)));
  }

  return cslBody;
};

export const txWitnessBootstrap = (
  scope: ManagedFreeableScope,
  bootstrap: Cardano.BootstrapWitness[]
): BootstrapWitnesses => {
  const witnesses = scope.manage(BootstrapWitnesses.new());
  for (const coreWitness of bootstrap) {
    witnesses.add(
      scope.manage(
        BootstrapWitness.new(
          scope.manage(Vkey.new(scope.manage(PublicKey.from_bytes(Buffer.from(coreWitness.key.toString(), 'hex'))))),
          scope.manage(Ed25519Signature.from_hex(coreWitness.signature.toString())),
          Buffer.from(coreWitness.chainCode || '', 'hex'),
          scope.manage(AddrAttributes.from_bytes(Buffer.from(coreWitness.addressAttributes || '', 'base64')))
        )
      )
    );
  }
  return witnesses;
};

export const witnessSet = (scope: ManagedFreeableScope, witness: Cardano.Witness): TransactionWitnessSet => {
  const cslWitnessSet = scope.manage(TransactionWitnessSet.new());
  const vkeyWitnesses = scope.manage(Vkeywitnesses.new());

  if (witness.scripts) {
    const { nativeScripts, plutusV1Scripts, plutusV2Scripts } = getScripts(scope, witness.scripts);

    cslWitnessSet.set_native_scripts(nativeScripts);
    cslWitnessSet.set_plutus_v1_scripts(plutusV1Scripts);
    cslWitnessSet.set_plutus_v2_scripts(plutusV2Scripts);
  }

  for (const [vkey, signature] of witness.signatures.entries()) {
    const publicKey = scope.manage(PublicKey.from_bytes(Buffer.from(vkey, 'hex')));
    const vkeyWitness = scope.manage(
      Vkeywitness.new(scope.manage(Vkey.new(publicKey)), scope.manage(Ed25519Signature.from_hex(signature.toString())))
    );
    vkeyWitnesses.add(vkeyWitness);
  }
  cslWitnessSet.set_vkeys(vkeyWitnesses);

  if (witness.bootstrap) {
    cslWitnessSet.set_bootstraps(txWitnessBootstrap(scope, witness.bootstrap));
  }

  return cslWitnessSet;
};

export const tx = (scope: ManagedFreeableScope, { body, witness, auxiliaryData }: Cardano.NewTxAlonzo): Transaction => {
  const txWitnessSet = witnessSet(scope, witness);
  // Possible optimization: only convert auxiliary data once
  return scope.manage(
    Transaction.new(txBody(scope, body, auxiliaryData), txWitnessSet, txAuxiliaryData(scope, auxiliaryData))
  );
};
