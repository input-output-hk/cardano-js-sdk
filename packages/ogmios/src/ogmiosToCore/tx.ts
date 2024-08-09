import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob } from '@cardano-sdk/util';
import {
  Cardano,
  NotImplementedError,
  Serialization,
  SerializationError,
  SerializationFailure,
  TxCBOR
} from '@cardano-sdk/core';
import { CommonBlock } from './types';
import { Schema } from '@cardano-ogmios/client';
import { Transaction } from '@cardano-ogmios/schema';
import Fraction from 'fraction.js';

export const BYRON_TX_FEE_COEFFICIENT = 43_946_000_000;
export const BYRON_TX_FEE_CONSTANT = 155_381_000_000_000;

const mapMargin = (margin: string): Cardano.Fraction => {
  const { n: numerator, d: denominator } = new Fraction(margin);
  return { denominator, numerator };
};

const mapRelay = (relay: Schema.Relay): Cardano.Relay => {
  const port = relay.port || undefined;
  if (relay.type === 'hostname')
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

const mapPoolParameters = (poolParameters: Schema.StakePool): Cardano.PoolParameters => {
  const rewardAccount = Cardano.RewardAccount(poolParameters.rewardAccount);
  return {
    cost: poolParameters.cost.ada.lovelace,
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
    pledge: poolParameters.pledge.ada.lovelace,
    relays: poolParameters.relays.map(mapRelay),
    rewardAccount,
    vrf: Cardano.VrfVkHex(poolParameters.vrfVerificationKeyHash)
  };
};

// TODO: Below certificates must be completed + unit tests
// eslint-disable-next-line complexity
const mapCertificate = (certificate: Schema.Certificate): Cardano.Certificate => {
  switch (certificate.type) {
    case 'stakeDelegation':
      return certificate.stakePool !== undefined
        ? // stake delegation to stake pool
          ({
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: Cardano.PoolId(certificate.stakePool.id),
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16(certificate.credential),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeDelegationCertificate)
        : ({
            __typename: Cardano.CertificateType.VoteDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16(certificate.credential),
              type: Cardano.CredentialType.KeyHash
            }
            // TODO: Conway `certificate.delegateRepresentative`
          } as Cardano.VoteDelegationCertificate);
    case 'stakeCredentialRegistration':
      return {
        __typename: Cardano.CertificateType.StakeRegistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16(certificate.credential),
          type: Cardano.CredentialType.KeyHash
        }
        // TODO: Conway `certificate.deposit`
      };
    case 'stakeCredentialDeregistration':
      return {
        __typename: Cardano.CertificateType.StakeDeregistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16(certificate.credential),
          type: Cardano.CredentialType.KeyHash
        }
        // TODO: Conway `certificate.deposit`
      };
    case 'stakePoolRegistration':
      return {
        __typename: Cardano.CertificateType.PoolRegistration,
        poolParameters: mapPoolParameters(certificate.stakePool)
      } as Cardano.PoolRegistrationCertificate;
    case 'stakePoolRetirement':
      return {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(certificate.stakePool.retirementEpoch),
        poolId: Cardano.PoolId(certificate.stakePool.id)
      } as Cardano.PoolRetirementCertificate;
    case 'genesisDelegation':
      return {
        __typename: Cardano.CertificateType.GenesisKeyDelegation,
        genesisDelegateHash: Crypto.Hash28ByteBase16(certificate.delegate.id),
        genesisHash: Crypto.Hash28ByteBase16(certificate.issuer.id),
        vrfKeyHash: Crypto.Hash32ByteBase16(certificate.delegate.vrfVerificationKeyHash)
      };
    case 'constitutionalCommitteeDelegation':
      // TODO: Conway rest of fields
      return {
        __typename: Cardano.CertificateType.AuthorizeCommitteeHot
      } as Cardano.AuthorizeCommitteeHotCertificate;
    case 'constitutionalCommitteeRetirement':
      // TODO: Conway rest of fields
      return {
        __typename: Cardano.CertificateType.ResignCommitteeCold
      } as Cardano.ResignCommitteeColdCertificate;
    case 'delegateRepresentativeRegistration':
      return {
        __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
        // TODO: parse anchor.
        // REVIEW: anchor fields are optional in ogmios schema, but required in our data model
        anchor: null
      } as Cardano.RegisterDelegateRepresentativeCertificate;
    case 'delegateRepresentativeRetirement':
      return {
        __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
        deposit: certificate.deposit.ada.lovelace
        // TODO: dRepCredential: certificate.delegateRepresentative.type
      } as unknown as Cardano.UnRegisterDelegateRepresentativeCertificate;
    case 'delegateRepresentativeUpdate':
      return {
        __typename: Cardano.CertificateType.UpdateDelegateRepresentative
        // TODO: Conway deposit
        // TODO: Conway dRepCredential
      } as unknown as Cardano.UnRegisterDelegateRepresentativeCertificate;
    default:
      throw new NotImplementedError(`Unknown certificate mapping: ${certificate}`);
  }

  // MIR certificates are now part of the proposals as gov actions
  // https://github.com/CardanoSolutions/ogmios/blob/master/architectural-decisions/accepted/017-api-version-6-major-rewrite.md#treasury-transfers)

  // TODO: translate code below from proposal into MIR certificate

  //   if ('moveInstantaneousRewards' in certificate) {
  //     return {
  //       __typename: Cardano.CertificateType.MIR,
  //       pot:
  //         certificate.moveInstantaneousRewards.pot === 'reserves'
  //           ? Cardano.MirCertificatePot.Reserves
  //           : Cardano.MirCertificatePot.Treasury,
  //       quantity: certificate.moveInstantaneousRewards.value || 0n
  //       // TODO: update MIR certificate type to support 'rewards' (multiple reward acc map to coins)
  //       // This is currently not compatible with core type (missing 'rewardAccount' which doesnt exist in ogmios)
  //       // rewardAccount: certificate.moveInstantaneousRewards.rewards.
  //       // Add test for it too.
  //     } as Cardano.MirCertificate;
  //   }
};

export const nativeScript = (script: Schema.ScriptNative): Cardano.NativeScript => {
  let coreScript: Cardano.NativeScript;

  switch (script.clause) {
    case 'signature':
      coreScript = {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex(script.from),
        kind: Cardano.NativeScriptKind.RequireSignature
      };
      break;
    case 'all':
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAllOf,
        scripts: script.from.map(nativeScript)
      };
      break;
    case 'any':
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAnyOf,
        scripts: script.from.map(nativeScript)
      };
      break;
    case 'some':
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireNOf,
        // TODO: script.atLeast is a bigint. Update `required` to also be a bigint
        required: Number(script.atLeast),
        scripts: script.from.map(nativeScript)
      };
      break;
    case 'before':
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeBefore,
        slot: Cardano.Slot(script.slot)
      };
      break;
    case 'after':
      coreScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireTimeAfter,
        slot: Cardano.Slot(script.slot)
      };
      break;
    default:
      throw new SerializationError(
        SerializationFailure.InvalidNativeScriptKind,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        `Native Script value '${(script as any).clause}' is not supported.`
      );
  }

  return coreScript;
};

export const mapScript = (script: Schema.Script): Cardano.Script => {
  switch (script.language) {
    case 'native':
      return nativeScript(script.json);
    case 'plutus:v1':
    case 'plutus:v2':
    case 'plutus:v3':
      return {
        __type: Cardano.ScriptType.Plutus,
        bytes: HexBlob(script.cbor),
        version:
          script.language === 'plutus:v1'
            ? Cardano.PlutusLanguageVersion.V1
            : script.language === 'plutus:v2'
            ? Cardano.PlutusLanguageVersion.V2
            : Cardano.PlutusLanguageVersion.V3
      };
    default:
      throw new SerializationError(SerializationFailure.InvalidScriptType, `Script '${script}' is not supported.`);
  }
};

const mapBootstrapWitness = (b: Schema.Signatory): Cardano.BootstrapWitness => ({
  // Based on the Ogmios maintainer answer  https://github.com/CardanoSolutions/ogmios/discussions/285#discussioncomment-4271726
  addressAttributes: b.addressAttributes ? Base64Blob.fromBytes(Buffer.from(b.addressAttributes, 'hex')) : undefined,
  chainCode: b.chainCode ? HexBlob(b.chainCode) : undefined,
  key: Crypto.Ed25519PublicKeyHex(b.key),
  signature: Crypto.Ed25519SignatureHex(b.signature)
});

const mapRedeemer = (redeemer: Schema.Redeemer): Cardano.Redeemer => {
  const { memory, cpu: steps } = redeemer.executionUnits;

  let purpose: Cardano.RedeemerPurpose;
  switch (redeemer.validator.purpose) {
    case 'spend':
      purpose = Cardano.RedeemerPurpose.spend;
      break;
    case 'mint':
      purpose = Cardano.RedeemerPurpose.mint;
      break;
    case 'publish':
      purpose = Cardano.RedeemerPurpose.certificate;
      break;
    case 'withdraw':
      purpose = Cardano.RedeemerPurpose.withdrawal;
      break;
    case 'propose':
      purpose = Cardano.RedeemerPurpose.propose;
      break;
    case 'vote':
      purpose = Cardano.RedeemerPurpose.vote;
      break;
  }

  return {
    data: Serialization.PlutusData.fromCbor(HexBlob(redeemer.redeemer)).toCore(),
    executionUnits: { memory, steps },
    index: redeemer.validator.index,
    purpose
  };
};

const mapJsonMetadatum = (obj: Schema.Metadatum): Cardano.Metadatum => {
  if (typeof obj === 'string' || typeof obj === 'bigint') {
    return obj;
  } else if (Array.isArray(obj)) {
    return obj.map(mapJsonMetadatum);
  } else if (typeof obj === 'object' && obj !== null) {
    return new Map(Object.entries(obj).map(([k, v]) => [k, mapJsonMetadatum(v)]));
  }

  throw new NotImplementedError(`Unknown metadatum type: ${obj}`);
};

const mapMetadata = (ogmiosMetadata: Schema.MetadataLabels[0]): Cardano.Metadatum => {
  if (ogmiosMetadata.cbor !== undefined)
    return Serialization.TransactionMetadatum.fromCbor(ogmiosMetadata.cbor as HexBlob).toCore();
  if (ogmiosMetadata.json !== undefined) return mapJsonMetadatum(ogmiosMetadata.json);
  throw new NotImplementedError(`Metadata format not recognized: ${JSON.stringify(ogmiosMetadata)}`);
};

const mapAuxiliaryData = (
  data: Transaction['metadata']
): {
  auxiliaryData: Omit<Cardano.AuxiliaryData, 'scripts'> | undefined;
  auxiliaryDataHash: Crypto.Hash32ByteBase16 | undefined;
} => {
  if (!data) return { auxiliaryData: undefined, auxiliaryDataHash: undefined };

  const auxiliaryData = {
    blob: data.labels
      ? new Map(Object.entries(data.labels).map(([key, value]) => [BigInt(key), mapMetadata(value)]))
      : undefined
    // Extra scripts have been moved to the scripts field and merged with witness scripts.
    // https://github.com/CardanoSolutions/ogmios/blob/master/architectural-decisions/accepted/017-api-version-6-major-rewrite.md#transaction
    // Removed 'auxiliaryData.scripts' from `OnChainTx`
    // https://github.com/input-output-hk/cardano-js-sdk/pull/927#discussion_r1352081210
    // scripts: undefined
  };
  const auxiliaryDataHash = Crypto.Hash32ByteBase16(data.hash);

  return { auxiliaryData, auxiliaryDataHash };
};

export const mapTxIn = (txIn: Schema.TransactionOutputReference): Cardano.TxIn => ({
  index: txIn.index,
  txId: Cardano.TransactionId(txIn.transaction.id)
});

const mapInlineDatum = (datum: Schema.TransactionOutput['datum']) => {
  if (typeof datum !== 'string') return;
  return Serialization.PlutusData.fromCbor(HexBlob(datum)).toCore();
};

const mapDatumHash = (datum: Schema.TransactionOutput['datumHash']) => {
  if (!datum) return;
  return Crypto.Hash32ByteBase16(datum);
};

const mapAssets = (ogmiosAssets: Schema.Assets): Cardano.TokenMap =>
  new Map(
    Object.entries(ogmiosAssets)
      .filter(([policyId]) => policyId !== 'ada')
      .flatMap(([policyId, assets]) =>
        Object.entries(assets).map(([assetName, quantity]) => [
          Cardano.AssetId.fromParts(policyId as Cardano.PolicyId, assetName as Cardano.AssetName),
          quantity
        ])
      )
  );

export const mapValue = (value: Schema.Value): Cardano.Value => ({
  assets: mapAssets(value),
  coins: value.ada.lovelace
});

const mapTxOut = (txOut: Schema.TransactionOutput): Cardano.TxOut => ({
  address: Cardano.PaymentAddress(txOut.address),
  // From ogmios v5.5.0 release notes:
  // Similarly, Alonzo transaction outputs will now contain a datumHash field, carrying the datum hash digest.
  // However, they will also contain a datum field with the exact same value for backward compatibility reason.
  datum: txOut.datum === txOut.datumHash ? undefined : mapInlineDatum(txOut.datum),
  datumHash: mapDatumHash(txOut.datumHash),
  scriptReference: txOut.script ? mapScript(txOut.script) : undefined,
  value: mapValue(txOut.value)
});

const mapInputSource = (source: 'inputs' | 'collaterals'): Cardano.InputSource => Cardano.InputSource[source];

const mapMint = (tx: Schema.Transaction): Cardano.TokenMap | undefined => {
  if (tx.mint === undefined) return undefined;
  return mapAssets(tx.mint);
};

const mapValidityInterval = ({ invalidBefore, invalidAfter }: Schema.ValidityInterval): Cardano.ValidityInterval => ({
  ...(invalidBefore && { invalidBefore: Cardano.Slot(invalidBefore) }),
  ...(invalidAfter && { invalidHereafter: Cardano.Slot(invalidAfter) })
});

const mapWitnessDatums = ({ datums }: Required<Pick<Schema.Transaction, 'datums'>>): Cardano.PlutusData[] =>
  // Possible optimization: we're discarding the object keys, which are datum hashes.
  // Might be useful to save those to not need to re-hash when projecting.
  Object.values(datums).map((datum) => Serialization.PlutusData.fromCbor(HexBlob(datum)).toCore());

export const mapByronTxFee = ({ cbor }: Schema.Transaction) => {
  const txSize = Buffer.from(HexBlob(cbor!), 'hex').length;
  return BigInt(BYRON_TX_FEE_COEFFICIENT * txSize + BYRON_TX_FEE_CONSTANT);
};

export const mapWithdrawals = (withdrawals: Schema.Withdrawals): Cardano.Withdrawal[] =>
  Object.entries(withdrawals).map(
    ([
      key,
      {
        ada: { lovelace }
      }
    ]) => ({
      quantity: lovelace,
      stakeAddress: Cardano.RewardAccount(key)
    })
  );

const mapCommonTx = (tx: Schema.Transaction): Cardano.OnChainTx => {
  const { auxiliaryData, auxiliaryDataHash } = mapAuxiliaryData(tx.metadata);
  return {
    auxiliaryData,
    body: {
      auxiliaryDataHash,
      certificates: tx.certificates?.map(mapCertificate),
      collaterals: tx.collaterals?.map(mapTxIn),
      fee: tx.fee?.ada.lovelace ?? mapByronTxFee(tx), // You were here. a common tx has fee but byron does not
      inputs: tx.inputs.map(mapTxIn),
      mint: mapMint(tx),
      outputs: tx.outputs.map(mapTxOut),
      requiredExtraSignatures: tx.requiredExtraSignatories?.map(Crypto.Ed25519KeyHashHex),
      ...(tx.scriptIntegrityHash && { scriptIntegrityHash: Crypto.Hash32ByteBase16(tx.scriptIntegrityHash) }),
      ...(tx.validityInterval && { validityInterval: mapValidityInterval(tx.validityInterval) }),
      ...(tx.withdrawals && {
        withdrawals: mapWithdrawals(tx.withdrawals)
      })
    },
    cbor: tx.cbor ? Serialization.TxCBOR(tx.cbor) : undefined,
    id: Cardano.TransactionId(tx.id),
    // At the time of writing Byron transactions didn't set this property
    inputSource: mapInputSource(tx.spends),
    witness: {
      bootstrap: tx.signatories
        .filter((signatory) => signatory.addressAttributes || signatory.chainCode)
        .map(mapBootstrapWitness),
      ...(tx.datums && { datums: mapWitnessDatums({ datums: tx.datums }) }),
      ...(tx.redeemers && { redeemers: tx.redeemers.map((redeemer) => mapRedeemer(redeemer)) }),
      // Removed `witness.scripts` from `OnChainTx`
      // https://github.com/input-output-hk/cardano-js-sdk/pull/927#discussion_r1352081210
      // ...(tx.scripts && { scripts: [...Object.values(tx.scripts).map(mapScript)] }),
      signatures: new Map(
        tx.signatories
          .filter((signatory) => !signatory.addressAttributes && !signatory.chainCode && signatory.key.length === 64)
          .map(({ key, signature }) => [Crypto.Ed25519PublicKeyHex(key), Crypto.Ed25519SignatureHex(signature)])
      )
    }
  };
};

const isByronEraBlock = ({ type }: CommonBlock | Schema.BlockBFT) => type === 'bft';

export const mapBlockBody = (block: CommonBlock | Schema.BlockBFT): Cardano.Block['body'] => {
  const { transactions } = block;
  return (transactions || []).map((transaction) =>
    !isByronEraBlock(block) && transaction.cbor
      ? {
          ...Serialization.Transaction.fromCbor(transaction.cbor as Serialization.TxCBOR).toCore(),
          inputSource: mapInputSource(transaction.spends)
        }
      : mapCommonTx(transaction)
  );
};
