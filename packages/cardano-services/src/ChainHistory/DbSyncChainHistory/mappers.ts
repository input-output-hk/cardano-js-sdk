import * as Crypto from '@cardano-sdk/crypto';
import { BigIntMath } from '@cardano-sdk/util';
import {
  BlockModel,
  BlockOutputModel,
  CertificateModel,
  MultiAssetModel,
  RedeemerModel,
  TipModel,
  TxIdModel,
  TxInput,
  TxInputModel,
  TxModel,
  TxOutMultiAssetModel,
  TxOutTokenMap,
  TxOutput,
  TxOutputModel,
  TxTokenMap,
  WithCertIndex,
  WithCertType,
  WithdrawalModel
} from './types';
import { Cardano } from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import {
  isDelegationCertModel,
  isMirCertModel,
  isPoolRegisterCertModel,
  isPoolRetireCertModel,
  isStakeCertModel
} from './util';

const addMultiAssetToTokenMap = (multiAsset: MultiAssetModel, tokenMap: Cardano.TokenMap): Cardano.TokenMap => {
  const tokens = new Map(tokenMap);
  const assetId = Cardano.AssetId.fromParts(
    multiAsset.policy_id.toString('hex') as unknown as Cardano.PolicyId,
    multiAsset.asset_name.toString('hex') as unknown as Cardano.AssetName
  );
  const currentQuantity = tokens.get(assetId) ?? 0n;
  tokens.set(assetId, BigIntMath.sum([currentQuantity, BigInt(multiAsset.quantity)]));
  return tokens;
};

export const mapTxTokenMap = (multiAssetModels: MultiAssetModel[]): TxTokenMap => {
  const txTokenMap: TxTokenMap = new Map();
  for (const multiAsset of multiAssetModels) {
    const txId = multiAsset.tx_id.toString('hex') as unknown as Cardano.TransactionId;
    const currentTokenMap = txTokenMap.get(txId) ?? new Map();
    const tokenMap = addMultiAssetToTokenMap(multiAsset, currentTokenMap);
    txTokenMap.set(txId, tokenMap);
  }
  return txTokenMap;
};

export const mapTxOutTokenMap = (multiAssetModels: TxOutMultiAssetModel[]): TxOutTokenMap => {
  const txTokenMap: TxOutTokenMap = new Map();
  for (const multiAsset of multiAssetModels) {
    const currentTokenMap = txTokenMap.get(multiAsset.tx_out_id) ?? new Map();
    const tokenMap = addMultiAssetToTokenMap(multiAsset, currentTokenMap);
    txTokenMap.set(multiAsset.tx_out_id, tokenMap);
  }
  return txTokenMap;
};

export const mapTxIn = (txIn: TxInput): Cardano.HydratedTxIn => ({
  address: txIn.address,
  index: txIn.index,
  txId: txIn.txSourceId
});

export const mapTxInModel = (txInModel: TxInputModel): TxInput => ({
  address: txInModel.address as unknown as Cardano.PaymentAddress,
  id: txInModel.id,
  index: txInModel.index,
  txInputId: txInModel.tx_input_id.toString('hex') as unknown as Cardano.TransactionId,
  txSourceId: txInModel.tx_source_id.toString('hex') as unknown as Cardano.TransactionId
});

export const mapTxOut = (txOut: TxOutput): Cardano.TxOut => ({
  address: txOut.address,
  datum: txOut.datum,
  datumHash: txOut.datumHash,
  scriptReference: txOut.scriptReference,
  value: txOut.value
});

export const mapTxOutModel = (txOutModel: TxOutputModel, assets?: Cardano.TokenMap): TxOutput => ({
  address: txOutModel.address as unknown as Cardano.PaymentAddress,
  // Inline datums are missing, but for now it's ok on ChainHistoryProvider
  datumHash: txOutModel.datum ? (txOutModel.datum.toString('hex') as unknown as Hash32ByteBase16) : undefined,
  index: txOutModel.index,
  txId: txOutModel.tx_id.toString('hex') as unknown as Cardano.TransactionId,
  value: {
    assets: assets && assets.size > 0 ? assets : undefined,
    coins: BigInt(txOutModel.coin_value)
  }
});

export const mapWithdrawal = (withdrawalModel: WithdrawalModel): Cardano.Withdrawal => ({
  quantity: BigInt(withdrawalModel.quantity),
  stakeAddress: withdrawalModel.stake_address as unknown as Cardano.RewardAccount
});

// TODO: unfortunately this is not nullable and not implemented.
// Remove this and select the actual redeemer data from `redeemer_data` table.
const stubRedeemerData = Buffer.from('not implemented');

export const mapRedeemer = (redeemerModel: RedeemerModel): Cardano.Redeemer => ({
  data: stubRedeemerData,
  executionUnits: {
    memory: Number(redeemerModel.unit_mem),
    steps: Number(redeemerModel.unit_steps)
  },
  index: redeemerModel.index,
  purpose: redeemerModel.purpose as Cardano.RedeemerPurpose
});

export const mapCertificate = (
  certModel: WithCertType<CertificateModel>
): WithCertIndex<Cardano.Certificate> | null => {
  if (isPoolRetireCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.PoolRetirement,
      cert_index: certModel.cert_index,
      epoch: Cardano.EpochNo(certModel.retiring_epoch),
      poolId: certModel.pool_id as unknown as Cardano.PoolId
    } as WithCertIndex<Cardano.PoolRetirementCertificate>;

  if (isPoolRegisterCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.PoolRegistration,
      cert_index: certModel.cert_index,
      poolParameters: null as unknown as Cardano.PoolParameters
    } as WithCertIndex<Cardano.PoolRegistrationCertificate>;

  if (isMirCertModel(certModel)) {
    const credential = Cardano.Address.fromString(certModel.address)?.asReward()?.getPaymentCredential();
    return {
      __typename: Cardano.CertificateType.MIR,
      cert_index: certModel.cert_index,
      kind: credential ? Cardano.MirCertificateKind.ToStakeCreds : Cardano.MirCertificateKind.ToOtherPot,
      pot: certModel.pot === 'reserve' ? Cardano.MirCertificatePot.Reserves : Cardano.MirCertificatePot.Treasury,
      quantity: BigInt(certModel.amount),
      stakeCredential: credential
    } as WithCertIndex<Cardano.MirCertificate>;
  }

  if (isStakeCertModel(certModel))
    return {
      __typename: certModel.registration
        ? Cardano.CertificateType.StakeRegistration
        : Cardano.CertificateType.StakeDeregistration,
      cert_index: certModel.cert_index,
      stakeCredential: {
        hash: Cardano.RewardAccount.toHash(
          Cardano.RewardAccount(certModel.address)
        ) as unknown as Crypto.Hash28ByteBase16,
        type: Cardano.CredentialType.KeyHash
      }
    } as WithCertIndex<Cardano.StakeAddressCertificate>;

  if (isDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      cert_index: certModel.cert_index,
      poolId: certModel.pool_id as unknown as Cardano.PoolId,
      stakeCredential: {
        hash: Cardano.RewardAccount.toHash(
          Cardano.RewardAccount(certModel.address)
        ) as unknown as Crypto.Hash28ByteBase16,
        type: Cardano.CredentialType.KeyHash
      }
    } as WithCertIndex<Cardano.StakeDelegationCertificate>;

  return null;
};

interface TxAlonzoData {
  inputSource: Cardano.InputSource;
  inputs: Cardano.HydratedTxIn[];
  outputs: Cardano.TxOut[];
  mint?: Cardano.TokenMap;
  withdrawals?: Cardano.Withdrawal[];
  redeemers?: Cardano.Redeemer[];
  metadata?: Cardano.TxMetadata;
  collaterals?: Cardano.HydratedTxIn[];
  certificates?: Cardano.Certificate[];
  collateralOutputs?: Cardano.TxOut[];
}

export const mapTxAlonzo = (
  txModel: TxModel,
  {
    inputSource,
    inputs,
    outputs,
    mint,
    withdrawals,
    redeemers,
    metadata,
    collaterals,
    certificates,
    collateralOutputs = []
  }: TxAlonzoData
): Cardano.HydratedTx => ({
  auxiliaryData:
    metadata && metadata.size > 0
      ? {
          blob: metadata
        }
      : undefined,
  blockHeader: {
    blockNo: Cardano.BlockNo(Number(txModel.block_no)),
    hash: txModel.block_hash.toString('hex') as unknown as Cardano.BlockId,
    slot: Cardano.Slot(Number(txModel.block_slot_no))
  },
  body: {
    ...(inputSource === Cardano.InputSource.collaterals
      ? {
          collateralReturn: outputs.length > 0 ? outputs[0] : undefined,
          collaterals: inputs,
          fee: BigInt(0),
          inputs: [],
          outputs: [],
          totalCollateral: BigInt(txModel.fee)
        }
      : {
          collateralReturn: collateralOutputs.length > 0 ? collateralOutputs[0] : undefined,
          collaterals,
          fee: BigInt(txModel.fee),
          inputs,
          outputs
        }),
    certificates,
    mint,
    totalCollateral: inputSource === Cardano.InputSource.collaterals ? BigInt(txModel.fee) : undefined,
    validityInterval: {
      invalidBefore: Cardano.Slot(Number(txModel.invalid_before)) || undefined,
      invalidHereafter: Cardano.Slot(Number(txModel.invalid_hereafter)) || undefined
    },
    withdrawals
  },
  id: txModel.id.toString('hex') as unknown as Cardano.TransactionId,
  index: txModel.index,
  inputSource,
  txSize: txModel.size,
  witness: {
    // TODO: fetch bootstrap witnesses, datums and scripts
    redeemers,
    // TODO: fetch signatures
    signatures: new Map()
  }
});

export const mapBlock = (
  blockModel: BlockModel,
  blockOutputModel: BlockOutputModel,
  tip: TipModel
): Cardano.ExtendedBlockInfo => ({
  confirmations: tip.block_no - blockModel.block_no,
  date: new Date(blockModel.time),
  epoch: Cardano.EpochNo(blockModel.epoch_no),
  epochSlot: blockModel.epoch_slot_no,
  fees: BigInt(blockOutputModel?.fees ?? 0),
  header: {
    blockNo: Cardano.BlockNo(blockModel.block_no),
    hash: blockModel.hash.toString('hex') as unknown as Cardano.BlockId,
    slot: Cardano.Slot(Number(blockModel.slot_no))
  },
  nextBlock: blockModel.next_block ? (blockModel.next_block.toString('hex') as unknown as Cardano.BlockId) : undefined,
  previousBlock: blockModel.previous_block
    ? (blockModel.previous_block.toString('hex') as unknown as Cardano.BlockId)
    : undefined,
  size: Cardano.BlockSize(blockModel.size),
  slotLeader: blockModel.slot_leader_pool
    ? Cardano.SlotLeader(blockModel.slot_leader_pool)
    : Cardano.SlotLeader(blockModel.slot_leader_hash.toString('hex')),
  totalOutput: BigInt(blockOutputModel?.output ?? 0),
  txCount: Number(blockModel.tx_count),
  vrf: blockModel.vrf as unknown as Cardano.VrfVkBech32
});

export const mapTxId = ({ tx_id }: TxIdModel) => tx_id;
