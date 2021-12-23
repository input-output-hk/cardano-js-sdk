import { Cardano, NotImplementedError, util } from '@cardano-sdk/core';
import { GetExactlyOneObject } from '../../util/getExactlyOneObject';
import { TransactionsByHashesQuery } from '../../sdk';
import { graphqlPoolParametersToCore } from '../../util/graphqlPoolParametersToCore';

type GraphqlTransaction = NonNullable<NonNullable<TransactionsByHashesQuery['queryTransaction']>[0]>;
type GraphqlScript = NonNullable<GraphqlTransaction['witness']['scripts']>[0]['script'];

const nativeScriptToCore = (script: GraphqlScript): Cardano.ScriptNative => {
  if (script.__typename === 'PlutusScript') throw new Error('use scriptToCore');
  if (script.all) {
    return { all: script.all.map(nativeScriptToCore) };
  } else if (script.any) {
    return { any: script.any.map(nativeScriptToCore) };
  } else if (script.nof) {
    return script.nof.reduce(
      (nof, { key, scripts }) => ({ ...nof, [key]: scripts.map(nativeScriptToCore) }),
      {} as Cardano.NativeScriptType.NOf
    );
  } else if (script.expiresAt) {
    return { expiresAt: script.expiresAt.number };
  } else if (script.startsAt) {
    return { startsAt: script.startsAt.number };
  } else if (script.vkey) {
    return script.vkey.key;
  }
  throw new NotImplementedError('Unknown native script type');
};

const scriptToCore = (script: GraphqlScript): Cardano.Script => {
  if (script.__typename === 'NativeScript') {
    return { native: nativeScriptToCore(script) };
  } else if (script.__typename === 'PlutusScript') {
    return {
      plutus: script.cborHex
    };
  }
  throw new NotImplementedError(script);
};

const witnessScriptsToCore = (scripts: GraphqlTransaction['witness']['scripts']) =>
  scripts?.reduce(
    (result, { key, script }) => ({
      ...result,
      [key]: scriptToCore(script)
    }),
    {} as Record<string, Cardano.Script>
  );

type GraphqlAuxiliaryDataBody = NonNullable<GraphqlTransaction['auxiliaryData']>['body'];
const auxiliaryScriptsToCore = (scripts: GraphqlAuxiliaryDataBody['scripts']): Cardano.Script[] | undefined =>
  scripts?.map(({ script }) => scriptToCore(script));

const inputsToCore = (inputs: GraphqlTransaction['inputs'], txId: Cardano.TransactionId) =>
  inputs.map(
    ({ address: { address }, index }): Cardano.TxIn => ({
      address: Cardano.Address(address),
      index,
      txId
    })
  );

const outputsToCore = (outputs: GraphqlTransaction['outputs']) =>
  outputs.map(
    ({ address: { address }, value: { coin, assets }, datumHash }): Cardano.TxOut => ({
      address: Cardano.Address(address),
      datum: datumHash ? Cardano.Hash32ByteBase16(datumHash) : undefined,
      value: {
        assets: new Map(assets?.map(({ asset, quantity }) => [Cardano.AssetId(asset.assetId), BigInt(quantity)])),
        coins: coin
      }
    })
  );

const withdrawalsToCore = (withdrawals: GraphqlTransaction['withdrawals']) =>
  withdrawals?.map(
    (withdrawal): Cardano.Withdrawal => ({
      quantity: withdrawal.quantity,
      stakeAddress: Cardano.RewardAccount(withdrawal.rewardAccount.address)
    })
  );

const mintToCore = (mint: GraphqlTransaction['mint']) =>
  mint
    ? new Map(mint.map(({ quantity, asset: { assetId } }) => [Cardano.AssetId(assetId), BigInt(quantity)]))
    : undefined;

const requiredExtraSignaturesToCore = (requiredExtraSignatures: GraphqlTransaction['requiredExtraSignatures']) =>
  requiredExtraSignatures?.map(({ hash }) => Cardano.Ed25519KeyHash(hash));

type GraphqlMetadatum = NonNullable<GraphqlAuxiliaryDataBody['blob']>[0]['metadatum'];
const metadatumToCore = (metadatum: GraphqlMetadatum): Cardano.Metadatum => {
  switch (metadatum.__typename) {
    case 'BytesMetadatum':
      return Buffer.from(metadatum.bytes, 'hex');
    case 'IntegerMetadatum':
      return BigInt(metadatum.int);
    case 'MetadatumArray':
      return (metadatum.array || []).map((md) => metadatumToCore(md as GraphqlMetadatum));
    case 'MetadatumMap':
      return (metadatum.map || {}).reduce(
        (map, { label, metadatum: md }) => ({ ...map, [label]: metadatumToCore(md as GraphqlMetadatum) }),
        {} as Cardano.MetadatumMap
      );
    case 'StringMetadatum':
      return metadatum.string;
    default:
      throw new NotImplementedError(metadatum);
  }
};

const auxiliaryDataToCore = (auxiliaryData: GraphqlTransaction['auxiliaryData']): Cardano.AuxiliaryData | undefined =>
  auxiliaryData
    ? {
        body: {
          blob: auxiliaryData.body.blob?.reduce(
            (blob, { label, metadatum }) => ({ ...blob, [label]: metadatumToCore(metadatum) }),
            {} as Cardano.MetadatumMap
          ),
          scripts: auxiliaryScriptsToCore(auxiliaryData.body.scripts)
        },
        hash: Cardano.Hash32ByteBase16(auxiliaryData.hash)
      }
    : undefined;

const datumsToCore = (datums: GraphqlTransaction['witness']['datums']) =>
  datums?.reduce(
    (result, { datum, hash }) => ({
      ...result,
      [hash]: datum
    }),
    {} as Record<string, string>
  );

type GraphQlCertificates = NonNullable<NonNullable<TransactionsByHashesQuery['queryTransaction']>[0]>['certificates'];
const certificatesToCore = (certificates: GraphQlCertificates) =>
  certificates?.map((cert): Cardano.Certificate => {
    switch (cert.__typename) {
      case 'GenesisKeyDelegationCertificate':
        return {
          __typename: Cardano.CertificateType.GenesisKeyDelegation,
          genesisDelegateHash: Cardano.Hash32ByteBase16(cert.genesisDelegateHash),
          genesisHash: Cardano.Hash32ByteBase16(cert.genesisHash),
          vrfKeyHash: Cardano.Hash32ByteBase16(cert.vrfKeyHash)
        };
      case 'MirCertificate':
        return {
          __typename: Cardano.CertificateType.MIR,
          pot: cert.pot as Cardano.MirCertificate['pot'],
          quantity: cert.quantity,
          rewardAccount: Cardano.RewardAccount(cert.rewardAccount.address)
        };
      case 'PoolRegistrationCertificate': {
        const poolId = Cardano.PoolId(cert.poolParameters.stakePool.id);
        return {
          __typename: Cardano.CertificateType.PoolRegistration,
          epoch: cert.epoch.number,
          poolId,
          poolParameters: graphqlPoolParametersToCore(cert.poolParameters, poolId.toString())
        };
      }
      case 'PoolRetirementCertificate':
        return {
          __typename: Cardano.CertificateType.PoolRetirement,
          epoch: cert.epoch.number,
          poolId: Cardano.PoolId(cert.stakePool.id)
        };
      case 'StakeDelegationCertificate':
        return {
          __typename: Cardano.CertificateType.StakeDelegation,
          epoch: cert.epoch.number,
          poolId: Cardano.PoolId(cert.stakePool.id),
          rewardAccount: Cardano.RewardAccount(cert.rewardAccount.address)
        };
      case 'StakeKeyDeregistrationCertificate':
        return {
          __typename: Cardano.CertificateType.StakeKeyDeregistration,
          rewardAccount: Cardano.RewardAccount(cert.rewardAccount.address)
        };
      case 'StakeKeyRegistrationCertificate':
        return {
          __typename: Cardano.CertificateType.StakeKeyRegistration,
          rewardAccount: Cardano.RewardAccount(cert.rewardAccount.address)
        };
      default:
        throw new NotImplementedError(cert);
    }
  });

export const graphqlTransactionsToCore = (
  queryTransaction: TransactionsByHashesQuery['queryTransaction'],
  queryProtocolParametersAlonzo: TransactionsByHashesQuery['queryProtocolParametersAlonzo'],
  getExactlyOneObject: GetExactlyOneObject
) => {
  if (!queryTransaction) return [];
  const protocolParameters = getExactlyOneObject(queryProtocolParametersAlonzo, 'ProtocolPrametersAlonzo');
  return queryTransaction
    .filter(util.isNotNil)
    .map(util.replaceNullsWithUndefineds)
    .map((tx): Cardano.TxAlonzo => {
      const txId = Cardano.TransactionId(tx.hash);
      const certificates = certificatesToCore(tx.certificates);
      const withdrawals = withdrawalsToCore(tx.withdrawals);
      const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals });
      return {
        auxiliaryData: auxiliaryDataToCore(tx.auxiliaryData),
        blockHeader: {
          blockNo: tx.block.blockNo,
          hash: Cardano.BlockId(tx.block.hash),
          slot: tx.block.slot.number
        },
        body: {
          certificates,
          collaterals: tx.collateral ? inputsToCore(tx.collateral, txId) : undefined,
          fee: tx.fee,
          inputs: inputsToCore(tx.inputs, txId),
          mint: mintToCore(tx.mint),
          outputs: outputsToCore(tx.outputs),
          requiredExtraSignatures: requiredExtraSignaturesToCore(tx.requiredExtraSignatures),
          scriptIntegrityHash: tx.scriptIntegrityHash ? Cardano.Hash28ByteBase16(tx.scriptIntegrityHash) : undefined,
          validityInterval: {
            invalidBefore: tx.invalidBefore?.slotNo,
            invalidHereafter: tx.invalidHereafter?.slotNo
          },
          withdrawals
        },
        id: Cardano.TransactionId(tx.hash),
        implicitCoin,
        index: tx.index,
        txSize: Number(tx.size),
        witness: {
          bootstrap: tx.witness.bootstrap?.map((bootstrap) => ({
            addressAttributes: bootstrap.addressAttributes,
            chainCode: bootstrap.chainCode,
            key: bootstrap.key?.key,
            signature: bootstrap.signature
          })),
          datums: datumsToCore(tx.witness.datums),
          redeemers: tx.witness.redeemers?.map((redeemer) => ({
            executionUnits: redeemer.executionUnits,
            index: redeemer.index,
            purpose: redeemer.purpose as Cardano.Redeemer['purpose'],
            scriptHash: Cardano.Hash28ByteBase16(redeemer.scriptHash)
          })),
          scripts: witnessScriptsToCore(tx.witness.scripts),
          signatures: new Map(
            tx.witness.signatures.map(({ publicKey: { key }, signature }) => [
              Cardano.Ed25519PublicKey(key),
              Cardano.Ed25519Signature(signature)
            ])
          )
        }
      };
    });
};
