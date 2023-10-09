import { Asset, Cardano, Handle, Serialization, metadatum, nativeScriptPolicyId, util } from '@cardano-sdk/core';
import { FinalizeTxProps, ObservableWallet } from '@cardano-sdk/wallet';
import { HexBlob } from '@cardano-sdk/util';
import { InitializeTxProps } from '@cardano-sdk/tx-construction';
import { KeyAgent, KeyRole, util as keyManagementUtil } from '@cardano-sdk/key-management';
import { firstValueFrom } from 'rxjs';
import { readFile } from 'fs/promises';
import { submitAndConfirm } from './util';
import path from 'path';

const handleDatum = Serialization.PlutusData.fromCbor(
  HexBlob(
    // https://cexplorer.io/datum/8b828de43929ce9a10ac218cc690360f69eb50b42e6a3a2f92d05ea8ca6bf288
    'd8799faa446e616d654a24706861726d6572733245696d6167655838697066733a2f2f7a646a37576d6f5a3656793564334b3675714253525a50527a5365625678624c326e315741514e4158336f4c6157655974496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468094a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101b34862675f696d6167655835697066733a2f2f516d59365869714272394a4e6e75677554527378336f63766b51656d4e4a356943524d6965383577717a39344a6f497066705f696d6167655835697066733a2f2f516d57676a58437856555357507931576d5556336a6f505031735a4d765a3731736f3671793643325a756b52424446706f7274616c404864657369676e65725838697066733a2f2f7a623272686b3278453154755757787448547a6f356774446945784136547276534b69596e6176704552334c66446b6f4b47736f6369616c73404676656e646f72404764656661756c74004e7374616e646172645f696d6167655838697066733a2f2f7a62327268696b435674535a7a4b756935336b76574c387974564374637a67457239424c6a466258423454585578684879536c6173745f7570646174655f61646472657373583901e80fd3030bfb17f25bfee50d2e71c9ece68292915698f955ea6645ea2b7be012268a95ebaefe5305164405df22ce4119a4a3549bbf1cda3d4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f686173685820bcd58c0dceea97b717bcbe0edc40b2e65fc2329a4db9ce3716b47b90eb5167de537374616e646172645f696d6167655f686173685820b3d06b8604acc91729e4d10ff5f42da4137cbb6b943291f703eb97761673c9804b7376675f76657273696f6e46312e31352e304c6167726565645f7465726d7340546d6967726174655f7369675f726571756972656400446e7366770045747269616c00497066705f61737365745823e74862a09d17a9cb03174a6bd5fa305b8684475c4c36021591c606e0445030363831364862675f6173736574582c9bdf437b6831d46d92d0db80f19f1b702145e9fdcc43c6264f7a04dc001bc2805468652046726565204f6e65ff'
  )
).toCore();

export type HandleMetadata = {
  [policyId: string]: {
    [handleName: string]: {
      augmentations: [];
      core: {
        handleEncoding: string;
        og: number;
        prefix: string;
        termsofuse: string;
        version: number;
      };
      description: string;
      image: string;
      name: string;
      website: string;
    };
  };
};

export const createHandleMetadata = (handlePolicyId: string, handleNames: string[]): HandleMetadata => {
  const result: HandleMetadata[0] = {};
  for (const key of handleNames) {
    result[key] = {
      augmentations: [],
      core: {
        handleEncoding: 'utf-8',
        og: 0,
        prefix: '$',
        termsofuse: 'https://cardanofoundation.org/en/terms-and-conditions/',
        version: 0
      },
      description: 'The Handle Standard',
      image: 'ipfs://some-hash',
      name: `$${key}`,
      website: 'https://cardano.org/'
    };
  }
  return { [handlePolicyId]: result };
};

export const createHandlePolicy = async (keyAgent: KeyAgent) => {
  const derivationPath = {
    index: 0,
    role: KeyRole.External
  };
  const pubKey = await keyAgent.derivePublicKey(derivationPath);
  const keyHash = await keyAgent.bip32Ed25519.getPubKeyHash(pubKey);
  const policySigner = new keyManagementUtil.KeyAgentTransactionSigner(keyAgent, derivationPath);
  const policyScript: Cardano.NativeScript = {
    __type: Cardano.ScriptType.Native,
    keyHash,
    kind: Cardano.NativeScriptKind.RequireSignature
  };
  const policyId = nativeScriptPolicyId(policyScript);
  return { policyId, policyScript, policySigner };
};

export const handleNames: Handle[] = ['handle1', 'handle2'];

export const getHandlePolicyId = async (pathToSdkIpc: string): Promise<Cardano.PolicyId> => {
  const handleProviderPolicyId = (await readFile(path.join(pathToSdkIpc, 'handle_policy_ids')))
    .toString('utf8')
    .replace(/\s/g, '');
  return Cardano.PolicyId(handleProviderPolicyId);
};

export const coinsRequiredByHandleMint = 10_000_000n;

export const mint = async (
  wallet: ObservableWallet,
  keyAgent: KeyAgent,
  tokens: Cardano.TokenMap,
  txMetadatum: Cardano.Metadatum,
  datum?: Cardano.PlutusData
) => {
  const [{ address }] = await firstValueFrom(wallet.addresses$);
  const { policyScript, policySigner } = await createHandlePolicy(keyAgent);

  const auxiliaryData = {
    blob: new Map([[721n, txMetadatum]])
  };

  const txProps: InitializeTxProps = {
    auxiliaryData,
    mint: tokens,
    outputs: new Set([
      {
        address,
        datum,
        value: {
          assets: tokens,
          coins: coinsRequiredByHandleMint
        }
      }
    ]),
    witness: { extraSigners: [policySigner], scripts: [policyScript] }
  };

  const unsignedTx = await wallet.initializeTx(txProps);

  const finalizeProps: FinalizeTxProps = {
    auxiliaryData,
    tx: unsignedTx,
    witness: { extraSigners: [policySigner], scripts: [policyScript] }
  };

  const signedTx = await wallet.finalizeTx(finalizeProps);
  await submitAndConfirm(wallet, signedTx);
};

export const mintCIP25andCIP68Handles = async (
  wallet: ObservableWallet,
  keyAgent: KeyAgent,
  policyId: Cardano.PolicyId
) => {
  const [cip25handle, cip68handle] = handleNames;
  const decodedCIP68HandleAssetName = Cardano.AssetName(util.utf8ToHex(cip68handle));
  const cip68UserTokenAssetId = Cardano.AssetId.fromParts(
    policyId,
    Asset.AssetNameLabel.encode(decodedCIP68HandleAssetName, Asset.AssetNameLabelNum.UserNFT)
  );
  const cip68ReferenceTokenAssetId = Cardano.AssetId.fromParts(
    policyId,
    Asset.AssetNameLabel.encode(decodedCIP68HandleAssetName, Asset.AssetNameLabelNum.ReferenceNFT)
  );
  const cip25AssetId = Cardano.AssetId.fromParts(policyId, Cardano.AssetName(util.utf8ToHex(cip25handle)));
  const tokens = new Map([
    [cip25AssetId, 1n],
    [cip68ReferenceTokenAssetId, 1n],
    [cip68UserTokenAssetId, 1n]
  ]);
  const txMetadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [cip25handle]));
  await mint(wallet, keyAgent, tokens, txMetadatum, handleDatum);
};
