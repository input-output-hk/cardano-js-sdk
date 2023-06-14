import * as Cardano from '../../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { AssetId, PlutusLanguageVersion, ScriptType } from '../../Cardano';
import { Base64Blob, HexBlob, ManagedFreeableScope, usingAutoFree } from '@cardano-sdk/util';
import { CML } from '../CML';
import { NotImplementedError, SerializationError, SerializationFailure } from '../../errors';
import { PlutusDataKind, ScriptKind } from '@dcspark/cardano-multiplatform-lib-nodejs';
import { bytesToHex } from '../../util/misc';
import { createCertificate } from './certificate';

/**
 * @returns {string} concatenated hex-encoded policy id and asset name
 */
export const createAssetId = (scriptHash: CML.ScriptHash, assetName: CML.AssetName): AssetId =>
  AssetId(bytesToHex(scriptHash.to_bytes()) + bytesToHex(assetName.name()));

export const txRequiredExtraSignatures = (
  signatures: CML.Ed25519KeyHashes | undefined
): Crypto.Ed25519KeyHashHex[] | undefined =>
  usingAutoFree((scope) => {
    if (!signatures) return;
    const requiredSignatures: Crypto.Ed25519KeyHashHex[] = [];
    for (let i = 0; i < signatures.len(); i++) {
      const signature = scope.manage(signatures.get(i));
      const cardanoSignature = Crypto.Ed25519KeyHashHex(Buffer.from(signature.to_bytes()).toString('hex'));
      requiredSignatures.push(cardanoSignature);
    }
    return requiredSignatures;
  });

export const txWithdrawals = (withdrawals?: CML.Withdrawals): Cardano.Withdrawal[] | undefined =>
  usingAutoFree((scope) => {
    if (!withdrawals) return;
    const result: Cardano.Withdrawal[] = [];
    const keys = scope.manage(withdrawals.keys());
    for (let i = 0; i < keys.len(); i++) {
      const key = scope.manage(keys.get(i));
      const value = scope.manage(withdrawals.get(key)!);
      const rewardAccount = Cardano.RewardAccount(scope.manage(key.to_address()).to_bech32());
      result.push({ quantity: BigInt(value!.to_str()), stakeAddress: rewardAccount });
    }
    return result;
  });

export const value = (cslValue: CML.Value): Cardano.Value =>
  usingAutoFree((scope) => {
    const result: Cardano.Value = {
      coins: BigInt(scope.manage(cslValue.coin()).to_str())
    };
    const multiasset = scope.manage(cslValue.multiasset());
    if (!multiasset) {
      return result;
    }
    result.assets = new Map();
    const scriptHashes = scope.manage(multiasset.keys());
    for (let scriptHashIdx = 0; scriptHashIdx < scriptHashes.len(); scriptHashIdx++) {
      const scriptHash = scope.manage(scriptHashes.get(scriptHashIdx));
      const assets = scope.manage(multiasset.get(scriptHash)!);
      const assetKeys = scope.manage(assets.keys());
      for (let assetIdx = 0; assetIdx < assetKeys.len(); assetIdx++) {
        const assetName = scope.manage(assetKeys.get(assetIdx));
        const assetAmount = BigInt(scope.manage(assets.get(assetName)!).to_str());
        if (assetAmount > 0n) {
          result.assets.set(createAssetId(scriptHash, assetName), assetAmount);
        }
      }
    }
    return result;
  });

export const nativeScript = (script: CML.NativeScript): Cardano.NativeScript =>
  usingAutoFree((scope) => {
    let coreScript: Cardano.NativeScript;
    const scriptKind = script.kind();

    switch (scriptKind) {
      case Cardano.NativeScriptKind.RequireSignature: {
        coreScript = {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex(
            bytesToHex(scope.manage(scope.manage(script.as_script_pubkey())!.addr_keyhash()).to_bytes())
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
        const scriptAll = scope.manage(script.as_script_all());
        for (let i = 0; i < scope.manage(scriptAll!.native_scripts()).len(); ++i) {
          coreScript.scripts.push(nativeScript(scope.manage(scope.manage(scriptAll!.native_scripts()).get(i))));
        }
        break;
      }
      case Cardano.NativeScriptKind.RequireAnyOf: {
        coreScript = {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireAnyOf,
          scripts: new Array<Cardano.NativeScript>()
        };
        const scriptAny = scope.manage(script.as_script_any());
        for (let i = 0; i < scope.manage(scriptAny!.native_scripts()).len(); ++i) {
          coreScript.scripts.push(nativeScript(scope.manage(scope.manage(scriptAny!.native_scripts()).get(i))));
        }
        break;
      }
      case Cardano.NativeScriptKind.RequireNOf: {
        const scriptMofK = scope.manage(script.as_script_n_of_k());
        coreScript = {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireNOf,
          required: scriptMofK!.n(),
          scripts: new Array<Cardano.NativeScript>()
        };

        for (let i = 0; i < scope.manage(scriptMofK!.native_scripts()).len(); ++i) {
          coreScript.scripts.push(nativeScript(scope.manage(scope.manage(scriptMofK!.native_scripts()).get(i))));
        }
        break;
      }
      case Cardano.NativeScriptKind.RequireTimeBefore: {
        coreScript = {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireTimeBefore,
          slot: Cardano.Slot(Number(scope.manage(scope.manage(script.as_timelock_expiry())!.slot()).to_str()))
        };
        break;
      }
      case Cardano.NativeScriptKind.RequireTimeAfter: {
        coreScript = {
          __type: Cardano.ScriptType.Native,
          kind: Cardano.NativeScriptKind.RequireTimeAfter,
          slot: Cardano.Slot(Number(scope.manage(scope.manage(script.as_timelock_start())!.slot()).to_str()))
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
  });

export const txIn = (input: CML.TransactionInput): Cardano.TxIn =>
  usingAutoFree((scope) => ({
    index: Number(scope.manage(input.index()).to_str()),
    txId: Cardano.TransactionId.fromHexBlob(bytesToHex(scope.manage(input.transaction_id()).to_bytes()))
  }));

export const getCoreScript = (scope: ManagedFreeableScope, script: CML.Script): Cardano.Script => {
  let coreScriptRef: Cardano.Script;
  switch (script.kind()) {
    case ScriptKind.NativeScript:
      coreScriptRef = nativeScript(scope.manage(script.as_native()!));
      break;
    case ScriptKind.PlutusScriptV1:
      coreScriptRef = {
        __type: ScriptType.Plutus,
        bytes: HexBlob.fromBytes(scope.manage(script.as_plutus_v1()!).to_bytes()),
        version: PlutusLanguageVersion.V1
      };
      break;
    case ScriptKind.PlutusScriptV2:
      coreScriptRef = {
        __type: ScriptType.Plutus,
        bytes: HexBlob.fromBytes(scope.manage(script.as_plutus_v2()!).to_bytes()),
        version: PlutusLanguageVersion.V2
      };
      break;
    default:
      throw new SerializationError(
        SerializationFailure.InvalidScriptType,
        `Script Kind value '${script.kind()}' is not supported.`
      );
  }
  return coreScriptRef;
};

const mapPlutusList = (plutusList: CML.PlutusList): Cardano.PlutusList =>
  usingAutoFree((scope) => {
    const items: Cardano.PlutusData[] = [];
    for (let i = 0; i < plutusList.len(); i++) {
      const element = scope.manage(plutusList.get(i));
      // eslint-disable-next-line no-use-before-define
      items.push(plutusData(element));
    }
    return { cbor: HexBlob(Buffer.from(plutusList.to_bytes()).toString('hex')), items };
  });

export const plutusData = (data: CML.PlutusData): Cardano.PlutusData =>
  usingAutoFree((scope) => {
    switch (data.kind()) {
      case PlutusDataKind.Bytes:
        return data.as_bytes()!;
      case PlutusDataKind.ConstrPlutusData: {
        const constrPlutusData = scope.manage(data.as_constr_plutus_data()!);
        return {
          cbor: HexBlob(Buffer.from(data.to_bytes()).toString('hex')),
          constructor: BigInt(scope.manage(constrPlutusData.alternative()).to_str()),
          fields: mapPlutusList(scope.manage(constrPlutusData.data()))
        } as Cardano.ConstrPlutusData;
      }
      case PlutusDataKind.Integer:
        return BigInt(scope.manage(data.as_integer()!).to_str());
      case PlutusDataKind.List:
        return mapPlutusList(scope.manage(data.as_list()!));
      case PlutusDataKind.Map: {
        const cmlPlutusMap = scope.manage(data.as_map()!);
        const coreMap = new Map<Cardano.PlutusData, Cardano.PlutusData>();
        const cmlKeys = scope.manage(cmlPlutusMap.keys());
        for (let i = 0; i < cmlKeys.len(); i++) {
          const cmlKey = scope.manage(cmlKeys.get(i));
          coreMap.set(plutusData(cmlKey), plutusData(scope.manage(cmlPlutusMap.get(cmlKey))!));
        }
        return { cbor: HexBlob(Buffer.from(data.to_bytes()).toString('hex')), data: coreMap } as Cardano.PlutusMap;
      }
      default:
        throw new NotImplementedError(`PlutusData mapping for kind ${data.kind()}`);
    }
  });

export const txOut = (output: CML.TransactionOutput): Cardano.TxOut =>
  usingAutoFree((scope) => {
    const cmlDatum = scope.manage(output.datum());
    const cmlInlineDatum = scope.manage(cmlDatum?.as_inline_data());
    const dataHashBytes = scope.manage(cmlDatum?.as_data_hash())?.to_bytes();
    const scriptRef = scope.manage(output.script_ref());
    const cmlAddress = scope.manage(output.address());
    const byronAddress = scope.manage(cmlAddress.as_byron());
    const address = byronAddress ? byronAddress.to_base58() : cmlAddress.to_bech32();

    return {
      address: Cardano.PaymentAddress(address),
      datum: cmlInlineDatum ? plutusData(cmlInlineDatum) : undefined,
      datumHash: dataHashBytes ? Crypto.Hash32ByteBase16.fromHexBlob(bytesToHex(dataHashBytes)) : undefined,
      scriptReference: scriptRef ? getCoreScript(scope, scope.manage(scriptRef.script())) : undefined,
      value: value(scope.manage(output.amount()))
    };
  });

export const txOutputs = (outputs: CML.TransactionOutputs): Cardano.TxOut[] =>
  usingAutoFree((scope) => {
    const result: Cardano.TxOut[] = [];
    for (let i = 0; i < outputs.len(); i++) {
      result.push(txOut(scope.manage(outputs.get(i))));
    }
    return result;
  });

export const txInputs = (inputs: CML.TransactionInputs): Cardano.TxIn[] =>
  usingAutoFree((scope) => {
    const result: Cardano.TxIn[] = [];
    for (let i = 0; i < inputs.len(); i++) {
      result.push(txIn(scope.manage(inputs.get(i))));
    }
    return result;
  });

export const txReferenceInputs = (referenceInputs: CML.TransactionInputs | undefined): Cardano.TxIn[] | undefined => {
  if (!referenceInputs) return;
  return txInputs(referenceInputs);
};

export const txCertificates = (certificates?: CML.Certificates): Cardano.Certificate[] | undefined =>
  usingAutoFree((scope) => {
    if (!certificates) return;
    const result: Cardano.Certificate[] = [];
    for (let i = 0; i < certificates.len(); i++) {
      const cslCertificate = scope.manage(certificates.get(i));
      result.push(createCertificate(cslCertificate));
    }
    return result;
  });

export const txMint = (assets?: CML.Mint): Cardano.TokenMap | undefined =>
  usingAutoFree((scope) => {
    if (!assets) return;
    const assetMap: Cardano.TokenMap = new Map();
    const keys = scope.manage(assets.keys());
    for (let i = 0; i < keys.len(); i++) {
      const scriptHash = scope.manage(keys.get(i));
      const mintAssets = scope.manage(assets.get(scriptHash));
      if (!mintAssets) continue;
      const mintKeys = scope.manage(mintAssets.keys());
      for (let k = 0; k < mintKeys.len(); k++) {
        const assetName = scope.manage(mintKeys.get(k));
        const assetValueInt = scope.manage(mintAssets.get(assetName)!);
        const assetId = createAssetId(scriptHash, assetName);
        if (!assetValueInt) continue;
        const quantity = assetValueInt.is_positive()
          ? BigInt(scope.manage(assetValueInt.as_positive())!.to_str())
          : BigInt(scope.manage(assetValueInt.as_negative())!.to_str()) * -1n;
        assetMap.set(assetId, quantity);
      }
    }
    return assetMap;
  });

const validityInterval = (scope: ManagedFreeableScope, body: CML.TransactionBody) => {
  const cmlInvalidBefore = body.validity_start_interval();
  const cmlInvalidHereafter = body.ttl();
  if (!cmlInvalidBefore && !cmlInvalidHereafter) return;
  return {
    invalidBefore: cmlInvalidBefore ? Cardano.Slot(Number(scope.manage(cmlInvalidBefore).to_str())) : undefined,
    invalidHereafter: cmlInvalidHereafter ? Cardano.Slot(Number(scope.manage(cmlInvalidHereafter).to_str())) : undefined
  };
};

export const txBody = (body: CML.TransactionBody): Cardano.TxBody =>
  usingAutoFree((scope) => {
    const cslScriptDataHash = scope.manage(body.script_data_hash());
    const cslCollaterals = scope.manage(body.collateral());
    const cslReferenceInputs = scope.manage(body.reference_inputs());
    const cslCollateralReturn = scope.manage(body.collateral_return());
    const cslTotalCollateral = scope.manage(body.total_collateral());
    const cslAuxiliaryDataHash = scope.manage(body.auxiliary_data_hash());
    const cslNetworkId = scope.manage(body.network_id());

    return {
      auxiliaryDataHash: cslAuxiliaryDataHash ? Crypto.Hash32ByteBase16(cslAuxiliaryDataHash.to_hex()) : undefined,
      certificates: txCertificates(scope.manage(body.certs())),
      collateralReturn: cslCollateralReturn ? txOut(cslCollateralReturn) : undefined,
      collaterals: cslCollaterals && txInputs(cslCollaterals),
      fee: BigInt(scope.manage(body.fee()).to_str()),
      inputs: txInputs(scope.manage(body.inputs())),
      mint: txMint(scope.manage(body.multiassets())),
      networkId: cslNetworkId ? cslNetworkId.kind() : undefined,
      outputs: txOutputs(scope.manage(body.outputs())),
      referenceInputs: cslReferenceInputs ? txInputs(cslReferenceInputs) : undefined,
      requiredExtraSignatures: txRequiredExtraSignatures(scope.manage(body.required_signers())),
      scriptIntegrityHash:
        cslScriptDataHash && Crypto.Hash32ByteBase16(Buffer.from(cslScriptDataHash.to_bytes()).toString('hex')),
      totalCollateral: cslTotalCollateral ? BigInt(cslTotalCollateral.to_str()) : undefined,
      validityInterval: validityInterval(scope, body),
      withdrawals: txWithdrawals(scope.manage(body.withdrawals()))
    };
  });

export const txWitnessBootstrap = (bootstraps?: CML.BootstrapWitnesses): Cardano.BootstrapWitness[] | undefined =>
  usingAutoFree((scope) => {
    if (!bootstraps) return;
    const result: Cardano.BootstrapWitness[] = [];
    for (let i = 0; i < bootstraps.len(); i++) {
      const bootstrap = scope.manage(bootstraps.get(i));
      const attributes = scope.manage(bootstrap.attributes()).to_bytes();
      const chainCode = bootstrap.chain_code();
      result.push({
        addressAttributes: attributes?.length > 0 ? Base64Blob.fromBytes(attributes) : undefined,
        chainCode: chainCode?.length > 0 ? HexBlob.fromBytes(chainCode) : undefined,
        key: Crypto.Ed25519PublicKeyHex(
          Buffer.from(scope.manage(scope.manage(bootstrap.vkey()).public_key()).as_bytes()).toString('hex')
        ),
        signature: Crypto.Ed25519SignatureHex(scope.manage(bootstrap.signature()).to_hex())
      });
    }
    return result;
  });

export const txWitnessRedeemers = (redeemers?: CML.Redeemers): Cardano.Redeemer[] | undefined =>
  usingAutoFree((scope) => {
    if (!redeemers) return;
    const result: Cardano.Redeemer[] = [];
    for (let j = 0; j < redeemers.len(); j++) {
      const reedeemer = scope.manage(redeemers.get(j));
      const exUnits = scope.manage(reedeemer.ex_units());

      /**
       * CML.RedeemerTagKind = Spend, Mint, Cert, Reward
       * should we modify Cardano.Redeemer.purpose to match or just map reward to withdrawal ??
       */
      const redeemerTagKind = scope.manage(reedeemer.tag()).kind();

      result.push({
        data: plutusData(scope.manage(reedeemer.data())),
        executionUnits: {
          memory: Number(scope.manage(exUnits.mem()).to_str()),
          steps: Number(scope.manage(exUnits.steps()).to_str())
        },
        index: Number(scope.manage(reedeemer.index()).to_str()),
        purpose: Object.values(Cardano.RedeemerPurpose)[redeemerTagKind]
      });
    }
    return result;
  });

export const txWitnessScripts = (witnessSet: CML.TransactionWitnessSet): Cardano.Script[] | undefined =>
  usingAutoFree((scope) => {
    const scripts: Cardano.Script[] = [];
    const plutusScriptsV1: CML.PlutusV1Scripts | undefined = scope.manage(witnessSet.plutus_v1_scripts());
    const plutusScriptsV2: CML.PlutusV2Scripts | undefined = scope.manage(witnessSet.plutus_v2_scripts());
    const nativeScripts: CML.NativeScripts | undefined = scope.manage(witnessSet.native_scripts());

    if (plutusScriptsV1) {
      for (let i = 0; i < plutusScriptsV1.len(); ++i) {
        scripts.push({
          __type: Cardano.ScriptType.Plutus,
          bytes: HexBlob(scope.manage(plutusScriptsV1.get(i)).to_js_value()),
          version: Cardano.PlutusLanguageVersion.V1
        });
      }
    }
    if (plutusScriptsV2) {
      for (let i = 0; i < plutusScriptsV2.len(); ++i) {
        scripts.push({
          __type: Cardano.ScriptType.Plutus,
          bytes: HexBlob(scope.manage(plutusScriptsV2.get(i)).to_js_value()),
          version: Cardano.PlutusLanguageVersion.V2
        });
      }
    }
    if (nativeScripts) {
      for (let i = 0; i < nativeScripts.len(); ++i) {
        scripts.push(nativeScript(scope.manage(nativeScripts.get(i))));
      }
    }
    return scripts.length === 0 ? undefined : scripts;
  });

export const txWitnessSet = (witnessSet: CML.TransactionWitnessSet): Cardano.Witness =>
  usingAutoFree((scope) => {
    const vkeys: CML.Vkeywitnesses | undefined = scope.manage(witnessSet.vkeys())!;
    const redeemers: CML.Redeemers | undefined = scope.manage(witnessSet.redeemers());
    const plutusDatums: CML.PlutusList | undefined = scope.manage(witnessSet.plutus_data());
    const bootstraps: CML.BootstrapWitnesses | undefined = scope.manage(witnessSet.bootstraps());

    const txSignatures: Cardano.Signatures = new Map();
    if (vkeys) {
      for (let i = 0; i < vkeys!.len(); i++) {
        const witness = scope.manage(vkeys.get(i));
        txSignatures.set(
          Crypto.Ed25519PublicKeyHex(
            Buffer.from(scope.manage(scope.manage(witness.vkey()).public_key()).as_bytes()).toString('hex')
          ),
          Crypto.Ed25519SignatureHex(scope.manage(witness.signature()).to_hex())
        );
      }
    }

    return {
      bootstrap: txWitnessBootstrap(bootstraps),
      datums: plutusDatums ? mapPlutusList(plutusDatums).items : undefined,
      redeemers: txWitnessRedeemers(redeemers),
      scripts: txWitnessScripts(witnessSet),
      signatures: txSignatures
    };
  });

export const txMetadatum = (transactionMetadatum: CML.TransactionMetadatum): Cardano.Metadatum =>
  usingAutoFree((scope) => {
    switch (transactionMetadatum.kind()) {
      case CML.TransactionMetadatumKind.Bytes:
        return transactionMetadatum.as_bytes();
      case CML.TransactionMetadatumKind.Int: {
        const int = scope.manage(transactionMetadatum.as_int())!;
        if (int.is_positive()) return BigInt(scope.manage(int.as_positive())!.to_str());
        return BigInt(scope.manage(int.as_negative())!.to_str()) * -1n;
      }
      case CML.TransactionMetadatumKind.MetadataList: {
        const list = scope.manage(transactionMetadatum.as_list());
        const metaDatumList: Cardano.Metadatum[] = [];
        for (let j = 0; j < list.len(); j++) {
          const listItem = scope.manage(list.get(j));
          metaDatumList.push(txMetadatum(listItem));
        }
        return metaDatumList;
      }
      case CML.TransactionMetadatumKind.MetadataMap: {
        const txMap = scope.manage(transactionMetadatum.as_map());
        const metdatumMap = new Map<Cardano.Metadatum, Cardano.Metadatum>();
        for (let i = 0; i < scope.manage(txMap.keys()).len(); i++) {
          const mapKey = scope.manage(scope.manage(txMap.keys()).get(i));
          const mapValue = scope.manage(txMap.get(mapKey));
          metdatumMap.set(txMetadatum(mapKey), txMetadatum(mapValue));
        }
        return metdatumMap;
      }
      case CML.TransactionMetadatumKind.Text:
        return transactionMetadatum.as_text();
      default:
        throw new SerializationError(SerializationFailure.InvalidType);
    }
  });

export const txMetadata = (auxiliaryMetadata?: CML.GeneralTransactionMetadata): Cardano.TxMetadata | undefined =>
  usingAutoFree((scope) => {
    if (!auxiliaryMetadata) return;
    const auxiliaryMetadataMap: Cardano.TxMetadata = new Map();
    const metadataKeys = scope.manage(auxiliaryMetadata.keys());
    for (let i = 0; i < metadataKeys.len(); i++) {
      const key = scope.manage(metadataKeys.get(i));
      const transactionMetadatum = scope.manage(auxiliaryMetadata.get(key));
      if (transactionMetadatum) {
        scope.manage(transactionMetadatum);
        auxiliaryMetadataMap.set(BigInt(key.to_str()), txMetadatum(transactionMetadatum));
      }
    }
    return auxiliaryMetadataMap;
  });

export const txAuxiliaryData = (auxiliaryData?: CML.AuxiliaryData): Cardano.AuxiliaryData | undefined =>
  usingAutoFree((scope) => {
    if (!auxiliaryData) return;
    const auxiliaryMetadata = scope.manage(auxiliaryData.metadata());
    return {
      blob: txMetadata(auxiliaryMetadata)
    };
  });

export const utxo = (cslUtxos: CML.TransactionUnspentOutput[]) =>
  usingAutoFree((scope) =>
    cslUtxos.map((cslUtxo) => [txIn(scope.manage(cslUtxo.input())), txOut(scope.manage(cslUtxo.output()))] as const)
  );
