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

const handlDatum = Serialization.PlutusData.fromCbor(
  HexBlob(
    // https://preview.cexplorer.io/datum/ff1a404ece117cc4482d26b072e30b5a6b3cd055a22debda3f90d704957e273a
    'd8799faa446e616d654524686e646c45696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d73627162317366736356365970496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468044a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a623272685a6a4c4a545838615a6d4a7a42424862366b7535446d6e6650674d47375a6d7362716231736673635636597046706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584032646465376163633062376532333931626633326133646537643566313763356365663231633336626432333564636663643738376463663439656661363339537374616e646172645f696d6167655f686173685840326464653761636330623765323339316266333261336465376435663137633563656632316333366264323335646366636437383764636634396566613633394b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff'
  )
).toCore();

const subhandlDatum = Serialization.PlutusData.fromCbor(
  HexBlob(
    // https://preview.cexplorer.io/datum/29294f077464c36e67b304ad22547fb3dfa946623b0b2cbae8acea7fb299353c
    'd8799faa446e616d65492473756240686e646c45696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d3534726472455032776366496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e677468084a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a6232726862426e7a6e4e48716748624a58786d71596a47714663377947314a444e6741664d353472647245503277636646706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900f541f0822d4794e6d1ddc3c0d5e932585bfcce2d869b1c2ee05b1dc7c37bace64b57b50a044bbafa593811a6f49c9d8d8c0b187932e2df404c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14a696d6167655f68617368584034333831373362613630333931353466646232643137383763363765633636333863393462643331633835336630643964356166343365626462313864623934537374616e646172645f696d6167655f686173685840343338313733626136303339313534666462326431373837633637656336363338633934626433316338353366306439643561663433656264623138646239344b7376675f76657273696f6e45322e302e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff'
  )
).toCore();

const virtualhandlDatum = Serialization.PlutusData.fromCbor(
  HexBlob(
    // https://preview.cexplorer.io/datum/e87d179ddf8ca2365fdb342101cc0f94f525d5e2ae2cb94085f28b84641c97e8
    'd8799faf446e616d654d247669727475616c40686e646c45696d6167655838697066733a2f2f7a623272686b52636a5471546e5a387462704635485a474e4c4e355473324554633558477039576264614b415134335472496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e6774680c4a63686172616374657273476c657474657273516e756d657269635f6d6f64696669657273404a7375625f7261726974794562617369634a7375625f6c656e677468074e7375625f63686172616374657273476c657474657273557375625f6e756d657269635f6d6f64696669657273404b68616e646c655f74797065517669727475616c5f73756268616e646c654776657273696f6e0101a94e7374616e646172645f696d6167655838697066733a2f2f7a623272686b52636a5471546e5a387462704635485a474e4c4e355473324554633558477039576264614b41513433547246706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f616464726573735839007ad324c4fb08709dd997f6b2ba7980d5007103a2aa3f7a7eb8b44bc6f1a8e379127b811583070faf74db00d880d45027fe6171b1b69bd9ca4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1527265736f6c7665645f616464726573736573a1436164615839007ad324c4fb08709dd997f6b2ba7980d5007103a2aa3f7a7eb8b44bc6f1a8e379127b811583070faf74db00d880d45027fe6171b1b69bd9caff'
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

export const handleNames: Handle[] = ['handle1', 'handle2', 'handl', 'sub@handl', 'virtual@handl'];

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
  datum?: Cardano.PlutusData,
  isNFTHandle = true
  // eslint-disable-next-line max-params
) => {
  const knownAddresses = await firstValueFrom(wallet.addresses$);
  const [{ address }] = knownAddresses;
  const { policyScript, policySigner } = await createHandlePolicy(keyAgent);

  const auxiliaryData = {
    blob: new Map([[721n, txMetadatum]])
  };

  const outputs: Set<Cardano.TxOut> = new Set();

  if (isNFTHandle) {
    outputs.add({
      address,
      datum,
      value: {
        assets: tokens,
        coins: coinsRequiredByHandleMint
      }
    });
  }

  const txProps: InitializeTxProps = {
    auxiliaryData,
    mint: tokens,
    outputs,
    signingOptions: {
      extraSigners: [policySigner]
    },
    witness: { scripts: [policyScript] }
  };

  const unsignedTx = await wallet.initializeTx(txProps);

  const finalizeProps: FinalizeTxProps = {
    auxiliaryData,
    signingOptions: {
      extraSigners: [policySigner]
    },
    tx: unsignedTx,
    witness: { scripts: [policyScript] }
  };

  const signedTx = await wallet.finalizeTx(finalizeProps);
  await submitAndConfirm(wallet, signedTx);
};

export const mintCIP25andCIP68Handles = async (
  wallet: ObservableWallet,
  keyAgent: KeyAgent,
  policyId: Cardano.PolicyId
) => {
  const [cip25handle, cip68handle, parentHandle, subHandle, virtualHandle] = handleNames;
  const decodedCIP68HandleAssetName = Cardano.AssetName(util.utf8ToHex(cip68handle));
  const cip68UserTokenAssetId = Cardano.AssetId.fromParts(
    policyId,
    Asset.AssetNameLabel.encode(decodedCIP68HandleAssetName, Asset.AssetNameLabelNum.UserNFT)
  );
  const cip68ReferenceTokenAssetId = Cardano.AssetId.fromParts(
    policyId,
    Asset.AssetNameLabel.encode(decodedCIP68HandleAssetName, Asset.AssetNameLabelNum.ReferenceNFT)
  );

  const decodedParentHandleAssetName = Cardano.AssetName(util.utf8ToHex(parentHandle));
  const cip68ParentHandleAssetId = Cardano.AssetId.fromParts(
    policyId,
    Asset.AssetNameLabel.encode(decodedParentHandleAssetName, Asset.AssetNameLabelNum.UserNFT)
  );

  const decodedSubHandleAssetName = Cardano.AssetName(util.utf8ToHex(subHandle));
  const cip68SubHandleAssetId = Cardano.AssetId.fromParts(
    policyId,
    Asset.AssetNameLabel.encode(decodedSubHandleAssetName, Asset.AssetNameLabelNum.UserNFT)
  );

  const decodedVirtualHandleAssetName = Cardano.AssetName(util.utf8ToHex(virtualHandle));
  const cip68VirtualHandleAssetId = Cardano.AssetId.fromParts(
    policyId,
    Asset.AssetNameLabel.encode(decodedVirtualHandleAssetName, Asset.AssetNameLabelNum.VirtualHandle)
  );

  const cip25AssetId = Cardano.AssetId.fromParts(policyId, Cardano.AssetName(util.utf8ToHex(cip25handle)));
  const tokens = new Map([
    [cip25AssetId, 1n],
    [cip68ReferenceTokenAssetId, 1n],
    [cip68UserTokenAssetId, 1n]
  ]);
  const txMetadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [cip25handle]));
  await mint(wallet, keyAgent, tokens, txMetadatum, handleDatum);

  const parentHandleTxMetadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [parentHandle]));
  const subHandleTxMetadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [subHandle]));
  const virtualHandleTxMetadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [virtualHandle]));

  await mint(wallet, keyAgent, new Map([[cip68ParentHandleAssetId, 1n]]), parentHandleTxMetadatum, handlDatum);
  await mint(wallet, keyAgent, new Map([[cip68SubHandleAssetId, 1n]]), subHandleTxMetadatum, subhandlDatum);
  await mint(
    wallet,
    keyAgent,
    new Map([[cip68VirtualHandleAssetId, 1n]]),
    virtualHandleTxMetadatum,
    virtualhandlDatum,
    false
  );
};
