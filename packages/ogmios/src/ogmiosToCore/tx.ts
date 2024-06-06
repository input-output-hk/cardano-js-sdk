import * as Crypto from '@cardano-sdk/crypto';
import {
  BYRON_TX_FEE_COEFFICIENT,
  BYRON_TX_FEE_CONSTANT,
  isAlonzoOrAbove,
  isExpiresAt,
  isMaryOrAbove,
  isNativeScript,
  isPlutusV1Script,
  isPlutusV2Script,
  isRequireAllOf,
  isRequireAnyOf,
  isRequireNOf,
  isShelleyTx,
  isStartsAt
} from './util.js';
import { Base64Blob, HexBlob } from '@cardano-sdk/util';
import {
  Cardano,
  NotImplementedError,
  Serialization,
  SerializationError,
  SerializationFailure
} from '@cardano-sdk/core';
import Fraction from 'fraction.js';
import omit from 'lodash/omit.js';
import type { BlockKind, CommonBlock } from './types.js';
import type { Schema } from '@cardano-ogmios/client';

const mapMargin = (margin: string): Cardano.Fraction => {
  const { n: numerator, d: denominator } = new Fraction(margin);
  return { denominator, numerator };
};

const mapRelay = (relay: Schema.Relay): Cardano.Relay => {
  const port = relay.port || undefined;
  if ('hostname' in relay)
    return {
      // TODO: enum for typename
      __typename: 'RelayByName',
      hostname: relay.hostname,
      port
    };
  return {
    __typename: 'RelayByAddress',
    ipv4: relay.ipv4 || undefined,
    ipv6: relay.ipv6 || undefined,
    port
  };
};

const mapPoolParameters = (poolParameters: Schema.PoolParameters): Cardano.PoolParameters => {
  const rewardAccount = Cardano.RewardAccount(poolParameters.rewardAccount);
  return {
    ...omit(poolParameters, 'metadata'),
    // TODO: consider just casting without validation for better performance
    id: Cardano.PoolId(poolParameters.id),
    margin: mapMargin(poolParameters.margin),
    metadataJson: poolParameters.metadata
      ? {
          hash: Crypto.Hash32ByteBase16(poolParameters.metadata.hash),
          url: poolParameters.metadata.url
        }
      : undefined,
    owners: poolParameters.owners.map((ownerKeyHash) =>
      Cardano.createRewardAccount(Crypto.Ed25519KeyHashHex(ownerKeyHash), Cardano.addressNetworkId(rewardAccount))
    ),
    relays: poolParameters.relays.map(mapRelay),
    rewardAccount,
    vrf: Cardano.VrfVkHex(poolParameters.vrf)
  };
};

const mapCertificate = (certificate: Schema.Certificate): Cardano.Certificate => {
  if ('stakeDelegation' in certificate) {
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId: Cardano.PoolId(certificate.stakeDelegation.delegatee),
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16(certificate.stakeDelegation.delegator),
        type: Cardano.CredentialType.KeyHash
      }
    };
  }
  if ('stakeKeyRegistration' in certificate) {
    return {
      __typename: Cardano.CertificateType.StakeRegistration,
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16(certificate.stakeKeyRegistration),
        type: Cardano.CredentialType.KeyHash
      }
    };
  }
  if ('stakeKeyDeregistration' in certificate) {
    return {
      __typename: Cardano.CertificateType.StakeDeregistration,
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16(certificate.stakeKeyDeregistration),
        type: Cardano.CredentialType.KeyHash
      }
    };
  }
  if ('poolRegistration' in certificate) {
    return {
      __typename: Cardano.CertificateType.PoolRegistration,
      poolParameters: mapPoolParameters(certificate.poolRegistration)
    } as Cardano.PoolRegistrationCertificate;
  }
  if ('poolRetirement' in certificate) {
    return {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: Cardano.EpochNo(certificate.poolRetirement.retirementEpoch),
      poolId: Cardano.PoolId(certificate.poolRetirement.poolId)
    };
  }
  if ('genesisDelegation' in certificate) {
    return {
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: Crypto.Hash28ByteBase16(certificate.genesisDelegation.delegateKeyHash),
      genesisHash: Crypto.Hash28ByteBase16(certificate.genesisDelegation.verificationKeyHash),
      vrfKeyHash: Crypto.Hash32ByteBase16(certificate.genesisDelegation.vrfVerificationKeyHash)
    };
  }
  if ('moveInstantaneousRewards' in certificate) {
    return {
      __typename: Cardano.CertificateType.MIR,
      pot:
        certificate.moveInstantaneousRewards.pot === 'reserves'
          ? Cardano.MirCertificatePot.Reserves
          : Cardano.MirCertificatePot.Treasury,
      quantity: certificate.moveInstantaneousRewards.value || 0n
      // TODO: update MIR certificate type to support 'rewards' (multiple reward acc map to coins)
      // This is currently not compatible with core type (missing 'rewardAccount' which doesnt exist in ogmios)
      // rewardAccount: certificate.moveInstantaneousRewards.rewards.
      // Add test for it too.
    } as Cardano.MirCertificate;
  }
  throw new NotImplementedError('Unknown certificate mapping');
};

export const nativeScript = (script: Schema.ScriptNative): Cardano.NativeScript => {
  let coreScript: Cardano.NativeScript;

  if (typeof script === 'string') {
    coreScript = {
      __type: Cardano.ScriptType.Native,
      keyHash: Crypto.Ed25519KeyHashHex(script),
      kind: Cardano.NativeScriptKind.RequireSignature
    };
  } else if (isRequireAllOf(script)) {
    coreScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: new Array<Cardano.NativeScript>()
    };
    for (let i = 0; i < script.all.length; ++i) {
      coreScript.scripts.push(nativeScript(script.all[i]));
    }
  } else if (isRequireAnyOf(script)) {
    coreScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAnyOf,
      scripts: new Array<Cardano.NativeScript>()
    };
    for (let i = 0; i < script.any.length; ++i) {
      coreScript.scripts.push(nativeScript(script.any[i]));
    }
  } else if (isRequireNOf(script)) {
    const required = Number.parseInt(Object.keys(script)[0]);
    coreScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireNOf,
      required,
      scripts: new Array<Cardano.NativeScript>()
    };

    for (let i = 0; i < script[required].length; ++i) {
      coreScript.scripts.push(nativeScript(script[required][i]));
    }
  } else if (isExpiresAt(script)) {
    coreScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireTimeBefore,
      slot: Cardano.Slot(script.expiresAt)
    };
  } else if (isStartsAt(script)) {
    coreScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireTimeAfter,
      slot: Cardano.Slot(script.startsAt)
    };
  } else {
    throw new SerializationError(
      SerializationFailure.InvalidNativeScriptKind,
      `Native Script value '${script}' is not supported.`
    );
  }

  return coreScript;
};

const mapPlutusScript = (script: Schema.PlutusV1 | Schema.PlutusV2): Cardano.PlutusScript => {
  const version = isPlutusV1Script(script) ? Cardano.PlutusLanguageVersion.V1 : Cardano.PlutusLanguageVersion.V2;
  const plutusScript = isPlutusV1Script(script) ? script['plutus:v1'] : script['plutus:v2'];
  return {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob(plutusScript),
    version
  };
};

export const mapScript = (script: Schema.Script): Cardano.Script => {
  if (isNativeScript(script)) {
    return nativeScript(script.native);
  } else if (isPlutusV1Script(script) || isPlutusV2Script(script)) return mapPlutusScript(script);

  throw new SerializationError(SerializationFailure.InvalidScriptType, `Script '${script}' is not supported.`);
};

const mapBootstrapWitness = (b: Schema.BootstrapWitness): Cardano.BootstrapWitness => ({
  // Based on the Ogmios maintainer answer  https://github.com/CardanoSolutions/ogmios/discussions/285#discussioncomment-4271726
  addressAttributes: b.addressAttributes ? Base64Blob(b.addressAttributes) : undefined,
  chainCode: b.chainCode ? HexBlob(b.chainCode) : undefined,
  key: Crypto.Ed25519PublicKeyHex(b.key!),
  signature: Crypto.Ed25519SignatureHex(HexBlob.fromBase64(b.signature!))
});

const mapRedeemer = (key: string, redeemer: Schema.Redeemer): Cardano.Redeemer => {
  const purposeAndIndex = key.split(':');

  return {
    data: Serialization.PlutusData.fromCbor(HexBlob(redeemer.redeemer)).toCore(),
    executionUnits: redeemer.executionUnits,
    index: Number(purposeAndIndex[1]),
    purpose: purposeAndIndex[0] as Cardano.RedeemerPurpose
  };
};

const mapMetadatum = (obj: Schema.Metadatum): Cardano.Metadatum => {
  if ('string' in obj) {
    return obj.string;
  } else if ('map' in obj) {
    return new Map(obj.map.map(({ k, v }) => [mapMetadatum(k), mapMetadatum(v)]));
  } else if ('list' in obj) {
    return obj.list.map(mapMetadatum);
  } else if ('int' in obj) {
    return obj.int;
  } else if ('bytes' in obj) {
    return Buffer.from(obj.bytes, 'hex');
  }
  throw new NotImplementedError(
    `Unknown metadatum type: ${typeof obj === 'object' ? Object.keys(obj).join(',') : obj}`
  );
};

const mapAuxiliaryData = (
  data: Schema.AuxiliaryData | null
): { auxiliaryData: Cardano.AuxiliaryData | undefined; auxiliaryDataHash: Crypto.Hash32ByteBase16 | undefined } => {
  if (data === null) return { auxiliaryData: undefined, auxiliaryDataHash: undefined };

  const auxiliaryData = {
    blob: data.body.blob
      ? new Map(Object.entries(data.body.blob).map(([key, value]) => [BigInt(key), mapMetadatum(value)]))
      : undefined,
    scripts: data.body.scripts ? data.body.scripts.map(mapScript) : undefined
  };
  const auxiliaryDataHash = Crypto.Hash32ByteBase16(data.hash);

  return { auxiliaryData, auxiliaryDataHash };
};

const mapTxIn = (txIn: Schema.TxIn): Cardano.TxIn => ({
  index: txIn.index,
  txId: Cardano.TransactionId(txIn.txId)
});

const mapInlineDatum = (datum: Schema.TxOut['datum']) => {
  if (typeof datum !== 'string') return;
  return Serialization.PlutusData.fromCbor(HexBlob(datum)).toCore();
};

const mapDatumHash = (datum: Schema.TxOut['datumHash']) => {
  if (!datum) return;
  return Crypto.Hash32ByteBase16(datum);
};

const mapTxOut = (txOut: Schema.TxOut): Cardano.TxOut => ({
  address: Cardano.PaymentAddress(txOut.address),
  // From ogmios v5.5.0 release notes:
  // Similarly, Alonzo transaction outputs will now contain a datumHash field, carrying the datum hash digest.
  // However, they will also contain a datum field with the exact same value for backward compatibility reason.
  datum: txOut.datum === txOut.datumHash ? undefined : mapInlineDatum(txOut.datum),
  datumHash: mapDatumHash(txOut.datumHash),
  scriptReference: txOut.script ? mapScript(txOut.script) : undefined,
  value: {
    assets: txOut.value.assets
      ? new Map(Object.entries(txOut.value.assets).map(([key, value]) => [Cardano.AssetId(key), value]))
      : undefined,
    coins: txOut.value.coins
  }
});

const mapMint = (tx: Schema.TxMary): Cardano.TokenMap | undefined => {
  if (tx.body.mint.assets === undefined) return undefined;
  return new Map(Object.entries(tx.body.mint.assets).map(([key, value]) => [Cardano.AssetId(key), value]));
};

const mapScriptIntegrityHash = ({
  body: { scriptIntegrityHash }
}: Schema.TxAlonzo): Crypto.Hash32ByteBase16 | undefined => {
  if (scriptIntegrityHash === null) return undefined;
  return Crypto.Hash32ByteBase16(scriptIntegrityHash);
};

const mapValidityInterval = ({
  invalidBefore,
  invalidHereafter
}: Schema.ValidityInterval): Cardano.ValidityInterval => ({
  invalidBefore: invalidBefore ? Cardano.Slot(invalidBefore) : undefined,
  invalidHereafter: invalidHereafter ? Cardano.Slot(invalidHereafter) : undefined
});

const mapWitnessDatums = ({ witness: { datums } }: Schema.TxAlonzo): Cardano.PlutusData[] =>
  // Possible optimization: we're discarding the object keys, which are datum hashes.
  // Might be useful to save those to not need to re-hash when projecting.
  Object.values(datums).map((datum) => Serialization.PlutusData.fromCbor(HexBlob(datum)).toCore());

const mapCommonTx = (tx: CommonBlock['body'][0], kind: BlockKind): Cardano.OnChainTx => {
  const { auxiliaryData, auxiliaryDataHash } = mapAuxiliaryData(tx.metadata);
  return {
    auxiliaryData,
    body: {
      auxiliaryDataHash,
      certificates: tx.body.certificates.map(mapCertificate),
      collaterals: isAlonzoOrAbove(kind) ? (tx as Schema.TxAlonzo).body.collaterals.map(mapTxIn) : undefined,
      fee: tx.body.fee,
      inputs: tx.body.inputs.map(mapTxIn),
      mint: isMaryOrAbove(kind) ? mapMint(tx as Schema.TxMary) : undefined,
      outputs: tx.body.outputs.map(mapTxOut),
      requiredExtraSignatures: isAlonzoOrAbove(kind)
        ? (tx as Schema.TxAlonzo).body.requiredExtraSignatures.map(Crypto.Ed25519KeyHashHex)
        : undefined,
      scriptIntegrityHash: isAlonzoOrAbove(kind) ? mapScriptIntegrityHash(tx as Schema.TxAlonzo) : undefined,
      validityInterval: isShelleyTx(kind)
        ? undefined
        : mapValidityInterval((tx as Schema.TxAlonzo).body.validityInterval),
      withdrawals: Object.entries(tx.body.withdrawals).map(([key, value]) => ({
        quantity: value,
        stakeAddress: Cardano.RewardAccount(key)
      }))
    },
    id: Cardano.TransactionId(tx.id),
    inputSource: isAlonzoOrAbove(kind)
      ? Cardano.InputSource[(tx as Schema.TxAlonzo).inputSource]
      : Cardano.InputSource.inputs,
    witness: {
      bootstrap: tx.witness.bootstrap.map(mapBootstrapWitness),
      datums: isAlonzoOrAbove(kind) ? mapWitnessDatums(tx as Schema.TxAlonzo) : undefined,
      redeemers: isAlonzoOrAbove(kind)
        ? Object.entries((tx as Schema.TxAlonzo).witness.redeemers).map(([key, value]) => mapRedeemer(key, value))
        : undefined,
      scripts: [...Object.values(tx.witness.scripts).map(mapScript)],
      signatures: new Map(
        Object.entries(tx.witness.signatures).map(([key, value]) => [
          Crypto.Ed25519PublicKeyHex(key),
          Crypto.Ed25519SignatureHex(HexBlob.fromBase64(value))
        ])
      )
    }
  };
};

export const mapCommonBlockBody = ({ body }: CommonBlock, kind: BlockKind): Cardano.Block['body'] =>
  body.map((blockBody) => mapCommonTx(blockBody, kind));

export const mapByronTxFee = ({ raw }: Schema.TxByron) => {
  const txSize = Buffer.from(Base64Blob(raw), 'base64').length;
  return BigInt(BYRON_TX_FEE_COEFFICIENT * txSize + BYRON_TX_FEE_CONSTANT);
};

const mapByronTx = (tx: Schema.TxByron): Cardano.OnChainTx => ({
  body: {
    fee: mapByronTxFee(tx),
    inputs: tx.body.inputs.map(mapTxIn),
    outputs: tx.body.outputs.map(mapTxOut)
  },
  id: Cardano.TransactionId(tx.id),
  inputSource: Cardano.InputSource.inputs,
  witness: {
    signatures: new Map()
  }
});

export const mapByronBlockBody = ({ body }: Schema.StandardBlock): Cardano.Block['body'] =>
  body.txPayload.map((txPayload) => mapByronTx(txPayload));
