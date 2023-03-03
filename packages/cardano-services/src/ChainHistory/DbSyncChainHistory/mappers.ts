import { Asset, Cardano } from '@cardano-sdk/core';
import { BigIntMath, HexBlob } from '@cardano-sdk/util';
import {
  BlockModel,
  BlockOutputModel,
  CertificateModel,
  MultiAssetModel,
  RedeemerModel,
  TipModel,
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
  const assetId = Asset.util.assetIdFromPolicyAndName(
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

export const mapRedeemer = (redeemerModel: RedeemerModel): Cardano.Redeemer => ({
  data: redeemerModel.script_hash.toString('hex') as unknown as HexBlob,
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

  if (isMirCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.MIR,
      cert_index: certModel.cert_index,
      pot: certModel.pot === 'reserve' ? Cardano.MirCertificatePot.Reserves : Cardano.MirCertificatePot.Treasury,
      quantity: BigInt(certModel.amount),
      rewardAccount: certModel.address as unknown as Cardano.RewardAccount
    } as WithCertIndex<Cardano.MirCertificate>;

  if (isStakeCertModel(certModel))
    return {
      __typename: certModel.registration
        ? Cardano.CertificateType.StakeKeyRegistration
        : Cardano.CertificateType.StakeKeyDeregistration,
      cert_index: certModel.cert_index,
      stakeKeyHash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(certModel.address))
    } as WithCertIndex<Cardano.StakeAddressCertificate>;

  if (isDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      cert_index: certModel.cert_index,
      poolId: certModel.pool_id as unknown as Cardano.PoolId,
      stakeKeyHash: Cardano.RewardAccount.toHash(Cardano.RewardAccount(certModel.address))
    } as WithCertIndex<Cardano.StakeDelegationCertificate>;

  return null;
};

interface TxAlonzoData {
  inputs: Cardano.HydratedTxIn[];
  outputs: Cardano.TxOut[];
  mint?: Cardano.TokenMap;
  withdrawals?: Cardano.Withdrawal[];
  redeemers?: Cardano.Redeemer[];
  metadata?: Cardano.TxMetadata;
  collaterals?: Cardano.HydratedTxIn[];
  certificates?: Cardano.Certificate[];
}

export const mapTxAlonzo = (
  txModel: TxModel,
  { inputs, outputs, mint, withdrawals, redeemers, metadata, collaterals, certificates }: TxAlonzoData
): Cardano.HydratedTx => ({
  auxiliaryData:
    metadata && metadata.size > 0
      ? {
          body: {
            blob: metadata
          }
        }
      : undefined,
  blockHeader: {
    blockNo: Cardano.BlockNo(txModel.block_no),
    hash: txModel.block_hash.toString('hex') as unknown as Cardano.BlockId,
    slot: Cardano.Slot(Number(txModel.block_slot_no))
  },
  body: {
    certificates,
    collaterals,
    fee: BigInt(txModel.fee),
    inputs,
    mint,
    outputs,
    validityInterval: {
      invalidBefore: Cardano.Slot(Number(txModel.invalid_before)) || undefined,
      invalidHereafter: Cardano.Slot(Number(txModel.invalid_hereafter)) || undefined
    },
    withdrawals
  },
  id: txModel.id.toString('hex') as unknown as Cardano.TransactionId,
  index: txModel.index,
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
