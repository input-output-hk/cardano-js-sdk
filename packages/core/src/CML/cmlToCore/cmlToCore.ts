import * as Cardano from '../../Cardano';
import { CML } from '../CML';
import { ManagedFreeableScope, usingAutoFree } from '@cardano-sdk/util';
import { SerializationError, SerializationFailure } from '../../errors';
import { bytesToHex } from '../../util/misc/bytesToHex';
import { createAssetId } from '../../Asset/util/assetId';
import { createCertificate } from './certificate';

export const txRequiredExtraSignatures = (
  signatures: CML.Ed25519KeyHashes | undefined
): Cardano.Ed25519KeyHash[] | undefined =>
  usingAutoFree((scope) => {
    if (!signatures) return;
    const requiredSignatures: Cardano.Ed25519KeyHash[] = [];
    for (let i = 0; i < signatures.len(); i++) {
      const signature = scope.manage(signatures.get(i));
      const cardanoSignature = Cardano.Ed25519KeyHash(Buffer.from(signature.to_bytes()).toString('hex'));
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

export const txIn = (input: CML.TransactionInput): Cardano.TxIn =>
  usingAutoFree((scope) => ({
    index: Number(scope.manage(input.index()).to_str()),
    txId: Cardano.TransactionId.fromHexBlob(bytesToHex(scope.manage(input.transaction_id()).to_bytes()))
  }));

export const txOut = (output: CML.TransactionOutput): Cardano.TxOut =>
  usingAutoFree((scope) => {
    const dataHashBytes = scope.manage(scope.manage(output.datum())?.as_data_hash())?.to_bytes();
    const cmlAddress = scope.manage(output.address());
    const byronAddress = scope.manage(cmlAddress.as_byron());
    const address = byronAddress ? byronAddress.to_base58() : cmlAddress.to_bech32();

    return {
      address: Cardano.Address(address),
      datum: dataHashBytes ? Cardano.util.Hash32ByteBase16.fromHexBlob(bytesToHex(dataHashBytes)) : undefined,
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

    return {
      certificates: txCertificates(scope.manage(body.certs())),
      collaterals: cslCollaterals && txInputs(cslCollaterals),
      fee: BigInt(scope.manage(body.fee()).to_str()),
      inputs: txInputs(scope.manage(body.inputs())),
      mint: txMint(scope.manage(body.multiassets())),
      outputs: txOutputs(scope.manage(body.outputs())),
      requiredExtraSignatures: txRequiredExtraSignatures(scope.manage(body.required_signers())),
      scriptIntegrityHash:
        cslScriptDataHash && Cardano.util.Hash32ByteBase16(Buffer.from(cslScriptDataHash.to_bytes()).toString('hex')),
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
        addressAttributes: attributes?.length > 0 ? Cardano.util.Base64Blob.fromBytes(attributes) : undefined,
        chainCode: chainCode?.length > 0 ? Cardano.util.HexBlob.fromBytes(chainCode) : undefined,
        key: Cardano.Ed25519PublicKey(
          Buffer.from(scope.manage(scope.manage(bootstrap.vkey()).public_key()).as_bytes()).toString('hex')
        ),
        signature: Cardano.Ed25519Signature(scope.manage(bootstrap.signature()).to_hex())
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
      const index = scope.manage(reedeemer.index());
      const data = scope.manage(reedeemer.data());
      const exUnits = scope.manage(reedeemer.ex_units());

      /**
       * CML.RedeemerTagKind = Spend, Mint, Cert, Reward
       * should we modify Cardano.Redeemer.purpose to match or just map reward to withdrawal ??
       */
      const redeemerTagKind = scope.manage(reedeemer.tag()).kind();

      result.push({
        data: Cardano.util.HexBlob(Buffer.from(data.to_bytes()).toString()),
        executionUnits: { memory: Number(scope.manage(exUnits.mem())), steps: Number(scope.manage(exUnits.steps())) },
        index: Number(index),
        purpose: Object.values(Cardano.RedeemerPurpose)[redeemerTagKind]
      });
    }
    return result;
  });

export const txWitnessSet = (witnessSet: CML.TransactionWitnessSet): Cardano.Witness =>
  usingAutoFree((scope) => {
    const vkeys: CML.Vkeywitnesses | undefined = scope.manage(witnessSet.vkeys())!;
    const redeemers: CML.Redeemers | undefined = scope.manage(witnessSet.redeemers());
    const bootstraps: CML.BootstrapWitnesses | undefined = scope.manage(witnessSet.bootstraps());

    const txSignatures: Cardano.Signatures = new Map();
    if (vkeys) {
      for (let i = 0; i < vkeys!.len(); i++) {
        const witness = scope.manage(vkeys.get(i));
        txSignatures.set(
          Cardano.Ed25519PublicKey(
            Buffer.from(scope.manage(scope.manage(witness.vkey()).public_key()).as_bytes()).toString('hex')
          ),
          Cardano.Ed25519Signature(scope.manage(witness.signature()).to_hex())
        );
      }
    }

    return {
      // TODO: add support for scripts
      bootstrap: txWitnessBootstrap(bootstraps),
      // TODO: implement datums
      redeemers: txWitnessRedeemers(redeemers),
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
    const metadataKeys = auxiliaryMetadata.keys();
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
    // TODO: create hash
    const auxiliaryMetadata = scope.manage(auxiliaryData.metadata());
    return {
      body: {
        blob: txMetadata(auxiliaryMetadata)
      }
    };
  });

export const utxo = (cslUtxos: CML.TransactionUnspentOutput[]) =>
  usingAutoFree((scope) =>
    cslUtxos.map((cslUtxo) => [txIn(scope.manage(cslUtxo.input())), txOut(scope.manage(cslUtxo.output()))])
  );

export const newTx = (cslTx: CML.Transaction): Cardano.Tx =>
  usingAutoFree((scope) => {
    const transactionHash = Cardano.TransactionId.fromHexBlob(
      bytesToHex(scope.manage(CML.hash_transaction(scope.manage(cslTx.body()))).to_bytes())
    );
    const auxiliary_data = scope.manage(cslTx.auxiliary_data());

    const witnessSet = scope.manage(cslTx.witness_set());

    return {
      auxiliaryData: txAuxiliaryData(auxiliary_data),
      body: txBody(scope.manage(cslTx.body())),
      id: transactionHash,
      witness: txWitnessSet(witnessSet)
    };
  });

export const nativeScript = (script: CML.NativeScript): Cardano.NativeScript =>
  usingAutoFree((scope) => {
    let coreScript: Cardano.NativeScript;
    const scriptKind = script.kind();

    switch (scriptKind) {
      case Cardano.NativeScriptKind.RequireSignature: {
        coreScript = {
          __type: Cardano.ScriptType.Native,
          keyHash: Cardano.Ed25519KeyHash(
            bytesToHex(scope.manage(scope.manage(script.as_script_pubkey())!.addr_keyhash()).to_bytes()).toString()
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
