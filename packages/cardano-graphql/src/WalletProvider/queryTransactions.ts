import { Cardano, NotImplementedError, WalletProvider, util } from '@cardano-sdk/core';
import { TransactionsByHashesQuery } from '../sdk';
import { WalletProviderFnProps } from './WalletProviderFnProps';
import { toCorePoolParameters } from '../util';

type GraphQlTransaction = NonNullable<NonNullable<TransactionsByHashesQuery['queryTransaction']>[0]>;
type GraphQlScript = NonNullable<GraphQlTransaction['witness']['scripts']>[0]['script'];

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const scriptsToCore = (scripts: any[]): Cardano.ScriptNative[] =>
  scripts
    .filter(util.isNotNil)
    // TODO: test this
    // eslint-disable-next-line no-use-before-define
    .map((nestedScript) => scriptToCore(nestedScript) as unknown as Cardano.ScriptNative);

const scriptToCore = (script: GraphQlScript): Cardano.Script => {
  if (script.__typename === 'NativeScript') {
    if (script.all) {
      return { native: { all: scriptsToCore(script.all) } };
    } else if (script.any) {
      return { native: { any: scriptsToCore(script.any) } };
    } else if (script.nof) {
      return {
        native: script.nof.reduce(
          (nof, { key, scripts }) => ({ ...nof, [key]: scriptsToCore(scripts) }),
          {} as Cardano.NativeScriptType.NOf
        )
      };
    } else if (script.expiresAt) {
      return { native: { expiresAt: script.expiresAt.number } };
    } else if (script.startsAt) {
      return { native: { startsAt: script.startsAt.number } };
    } else if (script.vkey) {
      return { native: script.vkey.key };
    }
  } else if (script.__typename === 'PlutusScript') {
    return {
      plutus: script.cborHex
    };
  }
  throw new NotImplementedError(script.__typename);
};

const inputsToCore = (inputs: GraphQlTransaction['inputs'], txId: Cardano.TransactionId) =>
  inputs.map(
    ({ address: { address }, index }): Cardano.TxIn => ({
      address: Cardano.Address(address),
      index,
      txId
    })
  );

const withdrawalsToCore = (withdrawals: GraphQlTransaction['withdrawals']) =>
  withdrawals?.map(
    (withdrawal): Cardano.Withdrawal => ({
      quantity: withdrawal.quantity,
      stakeAddress: Cardano.RewardAccount(withdrawal.rewardAccount.address)
    })
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
          poolParameters: toCorePoolParameters(cert.poolParameters, poolId.toString())
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

export const queryTransactionsByHashesProvider =
  ({ sdk, getExactlyOneObject }: WalletProviderFnProps): WalletProvider['queryTransactionsByHashes'] =>
  async (hashes) => {
    const { queryProtocolParametersAlonzo, queryTransaction } = await sdk.TransactionsByHashes({
      hashes: hashes as unknown as string[]
    });
    if (!queryTransaction) return [];
    const protocolParameters = getExactlyOneObject(queryProtocolParametersAlonzo, 'ProtocolPrametersAlonzo');
    // TODO: refactor moving out functions converting to core types
    return queryTransaction
      .filter(util.isNotNil)
      .map(util.replaceNullsWithUndefineds)
      .map((tx): Cardano.TxAlonzo => {
        const txId = Cardano.TransactionId(tx.hash);
        const certificates = certificatesToCore(tx.certificates);
        const withdrawals = withdrawalsToCore(tx.withdrawals);
        const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals });
        return {
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
            outputs: tx.outputs.map(
              ({ address: { address }, value: { coin, assets }, datumHash }): Cardano.TxOut => ({
                address: Cardano.Address(address),
                datum: datumHash ? Cardano.Hash32ByteBase16(datumHash) : undefined,
                value: {
                  assets: new Map(
                    assets?.map(({ asset, quantity }) => [Cardano.AssetId(asset.assetId), BigInt(quantity)])
                  ),
                  coins: coin
                }
              })
            ),
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
            datums: tx.witness.datums?.reduce(
              (datums, { datum, hash }) => ({
                ...datums,
                [hash]: datum
              }),
              {} as Record<string, string>
            ),
            redeemers: tx.witness.redeemers?.map((redeemer) => ({
              executionUnits: redeemer.executionUnits,
              index: redeemer.index,
              purpose: redeemer.purpose as Cardano.Redeemer['purpose'],
              scriptHash: Cardano.Hash28ByteBase16(redeemer.scriptHash)
            })),
            scripts: tx.witness.scripts?.reduce(
              (scripts, { key, script }) => ({
                ...scripts,
                // eslint-disable-next-line sonarjs/no-use-of-empty-return-value
                [key]: scriptToCore(script)
              }),
              {} as Cardano.Script
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
            ) as any,
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
