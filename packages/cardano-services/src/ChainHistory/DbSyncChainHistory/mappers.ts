import * as Crypto from '@cardano-sdk/crypto';
import { BigIntMath, HexBlob } from '@cardano-sdk/util';
import {
  BlockModel,
  BlockOutputModel,
  CertificateModel,
  MultiAssetModel,
  PoolRegisterCertModel,
  ProtocolParametersUpdateModel,
  RedeemerModel,
  ScriptModel,
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
  VoteDelegationCertModel,
  WithCertIndex,
  WithCertType,
  WithdrawalModel
} from './types';
import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import { Hash28ByteBase16, Hash32ByteBase16 } from '@cardano-sdk/crypto';
import {
  isAuthorizeCommitteeHotCertModel,
  isDelegationCertModel,
  isDrepRegistrationCertModel,
  isDrepUnregistrationCertModel,
  isMirCertModel,
  isPoolRegisterCertModel,
  isPoolRetireCertModel,
  isResignCommitteeColdCertModel,
  isStakeCertModel,
  isStakeRegistrationDelegationCertModel,
  isStakeVoteDelegationCertModel,
  isStakeVoteRegistrationDelegationCertModel,
  isUpdateDrepCertModel,
  isVoteDelegationCertModel,
  isVoteRegistrationDelegationCertModel
} from './util';
import { mapCostModels } from '../../NetworkInfo/DbSyncNetworkInfoProvider/mappers';

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

export const mapTxOutModel = (
  txOutModel: TxOutputModel,
  props: { assets?: Cardano.TokenMap; script?: Cardano.Script }
): TxOutput => ({
  address: txOutModel.address as unknown as Cardano.PaymentAddress,
  // Inline datums are missing, but for now it's ok on ChainHistoryProvider
  datumHash: txOutModel.datum ? (txOutModel.datum.toString('hex') as unknown as Hash32ByteBase16) : undefined,
  index: txOutModel.index,
  scriptReference: props.script,
  txId: txOutModel.tx_id.toString('hex') as unknown as Cardano.TransactionId,
  value: {
    assets: props.assets && props.assets.size > 0 ? props.assets : undefined,
    coins: BigInt(txOutModel.coin_value)
  }
});

export const mapWithdrawal = (withdrawalModel: WithdrawalModel): Cardano.Withdrawal => ({
  quantity: BigInt(withdrawalModel.quantity),
  stakeAddress: withdrawalModel.stake_address as unknown as Cardano.RewardAccount
});

export const mapPlutusScript = (scriptModel: ScriptModel): Cardano.Script => {
  const cbor = scriptModel.bytes.toString('hex') as HexBlob;

  return {
    __type: Cardano.ScriptType.Plutus,
    bytes: cbor,
    version:
      scriptModel.type === 'plutusV1'
        ? Cardano.PlutusLanguageVersion.V1
        : scriptModel.type === 'plutusV2'
        ? Cardano.PlutusLanguageVersion.V2
        : Cardano.PlutusLanguageVersion.V3
  };
};

// TODO: unfortunately this is not nullable and not implemented.
// Remove this and select the actual redeemer data from `redeemer_data` table.
const stubRedeemerData = Buffer.from('not implemented');

const redeemerPurposeMap: Record<RedeemerModel['purpose'], Cardano.RedeemerPurpose> = {
  cert: Cardano.RedeemerPurpose.certificate,
  mint: Cardano.RedeemerPurpose.mint,
  propose: Cardano.RedeemerPurpose.propose,
  reward: Cardano.RedeemerPurpose.withdrawal,
  spend: Cardano.RedeemerPurpose.spend,
  vote: Cardano.RedeemerPurpose.vote
};

const mapRedeemerPurpose = (purpose: RedeemerModel['purpose']): Cardano.RedeemerPurpose =>
  redeemerPurposeMap[purpose] ||
  (() => {
    throw new NotImplementedError(`Failed to map redeemer "purpose": ${purpose}`);
  })();

export const mapRedeemer = (redeemerModel: RedeemerModel): Cardano.Redeemer => ({
  data: stubRedeemerData,
  executionUnits: {
    memory: Number(redeemerModel.unit_mem),
    steps: Number(redeemerModel.unit_steps)
  },
  index: redeemerModel.index,
  purpose: mapRedeemerPurpose(redeemerModel.purpose)
});

export const mapAnchor = (anchorUrl: string, anchorDataHash: string): Cardano.Anchor | null => {
  if (!!anchorUrl && !!anchorDataHash) {
    return {
      dataHash: anchorDataHash as Hash32ByteBase16,
      url: anchorUrl
    };
  }
  return null;
};

const mapDrepDelegation = ({
  drep_hash,
  drep_view,
  has_script
}: Pick<VoteDelegationCertModel, 'drep_hash' | 'drep_view' | 'has_script'>): Cardano.DelegateRepresentative =>
  drep_hash
    ? {
        hash: drep_hash.toString('hex') as Hash28ByteBase16,
        type: Number(has_script) ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
      }
    : drep_view === 'drep_always_no_confidence'
    ? {
        __typename: 'AlwaysNoConfidence'
      }
    : {
        __typename: 'AlwaysAbstain'
      };

const mapPoolParameters = (certModel: WithCertType<PoolRegisterCertModel>): Cardano.PoolParameters => ({
  cost: BigInt(certModel.fixed_cost),
  id: certModel.pool_id as unknown as Cardano.PoolId,
  margin: Cardano.FractionUtils.toFraction(certModel.margin),
  owners: [],
  pledge: BigInt(certModel.pledge),
  relays: [],
  rewardAccount: certModel.reward_account as Cardano.RewardAccount,
  vrf: certModel.vrf_key_hash.toString('hex') as Cardano.VrfVkHex
});

// eslint-disable-next-line complexity
export const mapCertificate = (
  certModel: WithCertType<CertificateModel>
  // eslint-disable-next-line sonarjs/cognitive-complexity
): WithCertIndex<Cardano.HydratedCertificate> | null => {
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
      deposit: BigInt(certModel.deposit),
      poolParameters: mapPoolParameters(certModel)
    } as WithCertIndex<Cardano.HydratedPoolRegistrationCertificate>;

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
        ? Cardano.CertificateType.Registration
        : Cardano.CertificateType.Unregistration,
      cert_index: certModel.cert_index,
      deposit: BigInt(certModel.deposit),
      stakeCredential: Cardano.Address.fromBech32(certModel.address).asReward()!.getPaymentCredential()
    } as WithCertIndex<Cardano.NewStakeAddressCertificate>;

  if (isDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      cert_index: certModel.cert_index,
      poolId: certModel.pool_id as unknown as Cardano.PoolId,
      stakeCredential: Cardano.Address.fromBech32(certModel.address).asReward()!.getPaymentCredential()
    } as WithCertIndex<Cardano.StakeDelegationCertificate>;

  if (isDrepRegistrationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
      anchor:
        certModel.url && certModel.data_hash ? mapAnchor(certModel.url, certModel.data_hash.toString('hex')) : null,
      cert_index: certModel.cert_index,
      dRepCredential: {
        hash: certModel.drep_hash.toString('hex') as Hash28ByteBase16,
        type: Number(certModel.has_script) ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
      },
      deposit: BigInt(certModel.deposit)
    };

  if (isDrepUnregistrationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
      cert_index: certModel.cert_index,
      dRepCredential: {
        hash: certModel.drep_hash.toString('hex') as Hash28ByteBase16,
        type: Number(certModel.has_script) ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
      },
      deposit: BigInt(certModel.deposit)
    };

  if (isUpdateDrepCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.UpdateDelegateRepresentative,
      anchor:
        certModel.url && certModel.data_hash ? mapAnchor(certModel.url, certModel.data_hash.toString('hex')) : null,
      cert_index: certModel.cert_index,
      dRepCredential: {
        hash: certModel.drep_hash.toString('hex') as Hash28ByteBase16,
        type: Number(certModel.has_script) ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
      }
    };
  if (isVoteDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.VoteDelegation,
      cert_index: certModel.cert_index,
      dRep: mapDrepDelegation(certModel),
      stakeCredential: Cardano.Address.fromBech32(certModel.address).asReward()!.getPaymentCredential()
    };

  if (isVoteRegistrationDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.VoteRegistrationDelegation,
      cert_index: certModel.cert_index,
      dRep: mapDrepDelegation(certModel),
      deposit: BigInt(certModel.deposit),
      stakeCredential: Cardano.Address.fromBech32(certModel.address).asReward()!.getPaymentCredential()
    };

  if (isStakeVoteDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.StakeVoteDelegation,
      cert_index: certModel.cert_index,
      dRep: mapDrepDelegation(certModel),
      poolId: certModel.pool_id as unknown as Cardano.PoolId,
      stakeCredential: Cardano.Address.fromBech32(certModel.address).asReward()!.getPaymentCredential()
    };

  if (isStakeRegistrationDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.StakeRegistrationDelegation,
      cert_index: certModel.cert_index,
      deposit: BigInt(certModel.deposit),
      poolId: certModel.pool_id as unknown as Cardano.PoolId,
      stakeCredential: Cardano.Address.fromBech32(certModel.address).asReward()!.getPaymentCredential()
    };

  if (isStakeVoteRegistrationDelegationCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
      cert_index: certModel.cert_index,
      dRep: mapDrepDelegation(certModel),
      deposit: BigInt(certModel.deposit),
      poolId: certModel.pool_id as unknown as Cardano.PoolId,
      stakeCredential: Cardano.Address.fromBech32(certModel.address).asReward()!.getPaymentCredential()
    };

  if (isAuthorizeCommitteeHotCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.AuthorizeCommitteeHot,
      cert_index: certModel.cert_index,
      coldCredential: {
        hash: certModel.cold_key.toString('hex') as unknown as Crypto.Hash28ByteBase16,
        type: certModel.cold_key_has_script ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
      },
      hotCredential: {
        hash: certModel.hot_key.toString('hex') as unknown as Crypto.Hash28ByteBase16,
        type: certModel.hot_key_has_script ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
      }
    };

  if (isResignCommitteeColdCertModel(certModel))
    return {
      __typename: Cardano.CertificateType.ResignCommitteeCold,
      anchor: mapAnchor(certModel.url, certModel.data_hash),
      cert_index: certModel.cert_index,
      coldCredential: {
        hash: certModel.cold_key.toString('hex') as unknown as Crypto.Hash28ByteBase16,
        type: certModel.cold_key_has_script ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
      }
    };

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
  proposalProcedures?: Cardano.ProposalProcedure[];
  votingProcedures?: Cardano.VotingProcedures;
}

export const mapTxAlonzo = (
  txModel: TxModel,
  {
    certificates,
    collaterals,
    collateralOutputs = [],
    inputSource,
    inputs,
    metadata,
    mint,
    outputs,
    proposalProcedures,
    redeemers,
    votingProcedures,
    withdrawals
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
    proposalProcedures,
    validityInterval: {
      invalidBefore: Cardano.Slot(Number(txModel.invalid_before)) || undefined,
      invalidHereafter: Cardano.Slot(Number(txModel.invalid_hereafter)) || undefined
    },
    votingProcedures,
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

// eslint-disable-next-line complexity
export const mapProtocolParametersUpdateAction = (
  p: ProtocolParametersUpdateModel
): Cardano.ProtocolParametersUpdateConway => ({
  coinsPerUtxoByte: p.utxoCostPerByte,
  collateralPercentage: p.collateralPercentage,
  ...(p.committeeMaxTermLength !== undefined && { committeeTermLimit: Cardano.EpochNo(p.committeeMaxTermLength) }),
  ...(p.costModels !== undefined && { costModels: mapCostModels(p.costModels) }),
  dRepDeposit: p.dRepDeposit,
  ...(p.dRepActivity !== undefined && { dRepInactivityPeriod: Cardano.EpochNo(p.dRepActivity) }),
  ...(p.dRepVotingThresholds !== undefined && {
    dRepVotingThresholds: {
      committeeNoConfidence: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.committeeNoConfidence),
      committeeNormal: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.committeeNormal),
      hardForkInitiation: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.hardForkInitiation),
      motionNoConfidence: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.motionNoConfidence),
      ppEconomicGroup: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.ppEconomicGroup),
      ppGovernanceGroup: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.ppGovGroup),
      ppNetworkGroup: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.ppNetworkGroup),
      ppTechnicalGroup: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.ppTechnicalGroup),
      treasuryWithdrawal: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.treasuryWithdrawal),
      updateConstitution: Cardano.FractionUtils.toFraction(p.dRepVotingThresholds.updateToConstitution)
    }
  }),
  desiredNumberOfPools: p.stakePoolTargetNum,
  governanceActionDeposit: p.govActionDeposit,
  ...(p.govActionLifetime !== undefined && { governanceActionValidityPeriod: Cardano.EpochNo(p.govActionLifetime) }),
  maxBlockBodySize: p.maxBlockBodySize,
  maxBlockHeaderSize: p.maxBlockHeaderSize,
  maxCollateralInputs: p.maxCollateralInputs,
  ...(p.maxBlockExecutionUnits !== undefined && {
    maxExecutionUnitsPerBlock: {
      memory: p.maxBlockExecutionUnits.memory,
      steps: p.maxBlockExecutionUnits.memory
    }
  }),
  ...(p.maxTxExecutionUnits !== undefined && {
    maxExecutionUnitsPerTransaction: {
      memory: p.maxTxExecutionUnits.memory,
      steps: p.maxTxExecutionUnits.steps
    }
  }),
  maxTxSize: p.maxTxSize,
  maxValueSize: p.maxValueSize,
  minCommitteeSize: p.committeeMinSize,
  minFeeCoefficient: p.txFeePerByte,
  minFeeConstant: p.txFeeFixed,
  ...(p.minFeeRefScriptCostPerByte !== undefined && {
    minFeeRefScriptCostPerByte: Cardano.FractionUtils.toNumber(p.minFeeRefScriptCostPerByte).toString()
  }),
  minPoolCost: p.minPoolCost,
  ...(p.monetaryExpansion !== undefined && {
    monetaryExpansion: Cardano.FractionUtils.toNumber(p.monetaryExpansion).toString()
  }),
  poolDeposit: p.stakePoolDeposit,
  ...(p.poolPledgeInfluence !== undefined && {
    poolInfluence: Cardano.FractionUtils.toNumber(p.poolPledgeInfluence).toString()
  }),
  poolRetirementEpochBound: p.poolRetireMaxEpoch,
  ...(p.poolVotingThresholds !== undefined && {
    poolVotingThresholds: {
      committeeNoConfidence: Cardano.FractionUtils.toFraction(p.poolVotingThresholds.committeeNoConfidence),
      committeeNormal: Cardano.FractionUtils.toFraction(p.poolVotingThresholds.committeeNormal),
      hardForkInitiation: Cardano.FractionUtils.toFraction(p.poolVotingThresholds.hardForkInitiation),
      motionNoConfidence: Cardano.FractionUtils.toFraction(p.poolVotingThresholds.motionNoConfidence),
      securityRelevantParamVotingThreshold: Cardano.FractionUtils.toFraction(p.poolVotingThresholds.ppSecurityGroup)
    }
  }),
  ...(p.executionUnitPrices !== undefined && {
    prices: {
      memory: Cardano.FractionUtils.toNumber(p.executionUnitPrices.priceMemory),
      steps: Cardano.FractionUtils.toNumber(p.executionUnitPrices.priceSteps)
    }
  }),
  stakeKeyDeposit: p.stakeAddressDeposit,
  ...(p.treasuryCut !== undefined && { treasuryExpansion: Cardano.FractionUtils.toNumber(p.treasuryCut).toString() })
});
