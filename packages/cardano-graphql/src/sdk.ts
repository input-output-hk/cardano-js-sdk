import { GraphQLClient } from 'graphql-request';
import * as Dom from 'graphql-request/dist/types.dom';
import gql from 'graphql-tag';
export type Maybe<T> = T | null;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  /**
   * The DateTime scalar type represents date and time as a string in RFC3339 format.
   * For example: "1985-04-12T23:20:50.52Z" represents 20 minutes and 50.52 seconds after the 23rd hour of April 12th, 1985 in UTC.
   */
  DateTime: string;
  /**
   * The Int64 scalar type represents a signed 64‐bit numeric non‐fractional value.
   * Int64 can represent values in range [-(2^63),(2^63 - 1)].
   */
  Int64: bigint;
};

export type ActiveStake = {
  __typename?: 'ActiveStake';
  epoch: Epoch;
  quantity: Scalars['Int64'];
  rewardAccount: RewardAccount;
  stakePool: StakePool;
};


export type ActiveStakeEpochArgs = {
  filter?: Maybe<EpochFilter>;
};


export type ActiveStakeRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type ActiveStakeStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
};

export type ActiveStakeAggregateResult = {
  __typename?: 'ActiveStakeAggregateResult';
  count?: Maybe<Scalars['Int']>;
  quantityAvg?: Maybe<Scalars['Float']>;
  quantityMax?: Maybe<Scalars['Int64']>;
  quantityMin?: Maybe<Scalars['Int64']>;
  quantitySum?: Maybe<Scalars['Int64']>;
};

export type ActiveStakeFilter = {
  and?: Maybe<Array<Maybe<ActiveStakeFilter>>>;
  has?: Maybe<Array<Maybe<ActiveStakeHasFilter>>>;
  not?: Maybe<ActiveStakeFilter>;
  or?: Maybe<Array<Maybe<ActiveStakeFilter>>>;
};

export enum ActiveStakeHasFilter {
  Epoch = 'epoch',
  Quantity = 'quantity',
  RewardAccount = 'rewardAccount',
  StakePool = 'stakePool'
}

export type ActiveStakeOrder = {
  asc?: Maybe<ActiveStakeOrderable>;
  desc?: Maybe<ActiveStakeOrderable>;
  then?: Maybe<ActiveStakeOrder>;
};

export enum ActiveStakeOrderable {
  Quantity = 'quantity'
}

export type ActiveStakePatch = {
  epoch?: Maybe<EpochRef>;
  quantity?: Maybe<Scalars['Int64']>;
  rewardAccount?: Maybe<RewardAccountRef>;
  stakePool?: Maybe<StakePoolRef>;
};

export type ActiveStakeRef = {
  epoch?: Maybe<EpochRef>;
  quantity?: Maybe<Scalars['Int64']>;
  rewardAccount?: Maybe<RewardAccountRef>;
  stakePool?: Maybe<StakePoolRef>;
};

export type Ada = {
  __typename?: 'Ada';
  supply: AssetSupply;
};


export type AdaSupplyArgs = {
  filter?: Maybe<AssetSupplyFilter>;
};

export type AdaAggregateResult = {
  __typename?: 'AdaAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type AdaFilter = {
  and?: Maybe<Array<Maybe<AdaFilter>>>;
  has?: Maybe<Array<Maybe<AdaHasFilter>>>;
  not?: Maybe<AdaFilter>;
  or?: Maybe<Array<Maybe<AdaFilter>>>;
};

export enum AdaHasFilter {
  Supply = 'supply'
}

export type AdaPatch = {
  supply?: Maybe<AssetSupplyRef>;
};

export type AdaPots = {
  __typename?: 'AdaPots';
  deposits: Scalars['Int64'];
  fees: Scalars['Int64'];
  reserves: Scalars['Int64'];
  rewards: Scalars['Int64'];
  slot: Slot;
  treasury: Scalars['Int64'];
  utxo: Scalars['Int64'];
};


export type AdaPotsSlotArgs = {
  filter?: Maybe<SlotFilter>;
};

export type AdaPotsAggregateResult = {
  __typename?: 'AdaPotsAggregateResult';
  count?: Maybe<Scalars['Int']>;
  depositsAvg?: Maybe<Scalars['Float']>;
  depositsMax?: Maybe<Scalars['Int64']>;
  depositsMin?: Maybe<Scalars['Int64']>;
  depositsSum?: Maybe<Scalars['Int64']>;
  feesAvg?: Maybe<Scalars['Float']>;
  feesMax?: Maybe<Scalars['Int64']>;
  feesMin?: Maybe<Scalars['Int64']>;
  feesSum?: Maybe<Scalars['Int64']>;
  reservesAvg?: Maybe<Scalars['Float']>;
  reservesMax?: Maybe<Scalars['Int64']>;
  reservesMin?: Maybe<Scalars['Int64']>;
  reservesSum?: Maybe<Scalars['Int64']>;
  rewardsAvg?: Maybe<Scalars['Float']>;
  rewardsMax?: Maybe<Scalars['Int64']>;
  rewardsMin?: Maybe<Scalars['Int64']>;
  rewardsSum?: Maybe<Scalars['Int64']>;
  treasuryAvg?: Maybe<Scalars['Float']>;
  treasuryMax?: Maybe<Scalars['Int64']>;
  treasuryMin?: Maybe<Scalars['Int64']>;
  treasurySum?: Maybe<Scalars['Int64']>;
  utxoAvg?: Maybe<Scalars['Float']>;
  utxoMax?: Maybe<Scalars['Int64']>;
  utxoMin?: Maybe<Scalars['Int64']>;
  utxoSum?: Maybe<Scalars['Int64']>;
};

export type AdaPotsFilter = {
  and?: Maybe<Array<Maybe<AdaPotsFilter>>>;
  has?: Maybe<Array<Maybe<AdaPotsHasFilter>>>;
  not?: Maybe<AdaPotsFilter>;
  or?: Maybe<Array<Maybe<AdaPotsFilter>>>;
};

export enum AdaPotsHasFilter {
  Deposits = 'deposits',
  Fees = 'fees',
  Reserves = 'reserves',
  Rewards = 'rewards',
  Slot = 'slot',
  Treasury = 'treasury',
  Utxo = 'utxo'
}

export type AdaPotsOrder = {
  asc?: Maybe<AdaPotsOrderable>;
  desc?: Maybe<AdaPotsOrderable>;
  then?: Maybe<AdaPotsOrder>;
};

export enum AdaPotsOrderable {
  Deposits = 'deposits',
  Fees = 'fees',
  Reserves = 'reserves',
  Rewards = 'rewards',
  Treasury = 'treasury',
  Utxo = 'utxo'
}

export type AdaPotsPatch = {
  deposits?: Maybe<Scalars['Int64']>;
  fees?: Maybe<Scalars['Int64']>;
  reserves?: Maybe<Scalars['Int64']>;
  rewards?: Maybe<Scalars['Int64']>;
  slot?: Maybe<SlotRef>;
  treasury?: Maybe<Scalars['Int64']>;
  utxo?: Maybe<Scalars['Int64']>;
};

export type AdaPotsRef = {
  deposits?: Maybe<Scalars['Int64']>;
  fees?: Maybe<Scalars['Int64']>;
  reserves?: Maybe<Scalars['Int64']>;
  rewards?: Maybe<Scalars['Int64']>;
  slot?: Maybe<SlotRef>;
  treasury?: Maybe<Scalars['Int64']>;
  utxo?: Maybe<Scalars['Int64']>;
};

export type AdaRef = {
  supply?: Maybe<AssetSupplyRef>;
};

export type AddActiveStakeInput = {
  epoch: EpochRef;
  quantity: Scalars['Int64'];
  rewardAccount: RewardAccountRef;
  stakePool: StakePoolRef;
};

export type AddActiveStakePayload = {
  __typename?: 'AddActiveStakePayload';
  activeStake?: Maybe<Array<Maybe<ActiveStake>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddActiveStakePayloadActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ActiveStakeOrder>;
};

export type AddAdaInput = {
  supply: AssetSupplyRef;
};

export type AddAdaPayload = {
  __typename?: 'AddAdaPayload';
  ada?: Maybe<Array<Maybe<Ada>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAdaPayloadAdaArgs = {
  filter?: Maybe<AdaFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddAdaPotsInput = {
  deposits: Scalars['Int64'];
  fees: Scalars['Int64'];
  reserves: Scalars['Int64'];
  rewards: Scalars['Int64'];
  slot: SlotRef;
  treasury: Scalars['Int64'];
  utxo: Scalars['Int64'];
};

export type AddAdaPotsPayload = {
  __typename?: 'AddAdaPotsPayload';
  adaPots?: Maybe<Array<Maybe<AdaPots>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAdaPotsPayloadAdaPotsArgs = {
  filter?: Maybe<AdaPotsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AdaPotsOrder>;
};

export type AddAddressInput = {
  address: Scalars['String'];
  addressType: AddressType;
  inputs: Array<TransactionInputRef>;
  rewardAccount?: Maybe<RewardAccountRef>;
  utxo: Array<TransactionOutputRef>;
};

export type AddAddressPayload = {
  __typename?: 'AddAddressPayload';
  address?: Maybe<Array<Maybe<Address>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAddressPayloadAddressArgs = {
  filter?: Maybe<AddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AddressOrder>;
};

export type AddAlonzoGenesisInput = {
  collateralPercentage: Scalars['Int'];
  executionPrices: ExecutionPricesRef;
  lovelacePerUTxOWord: Scalars['Int'];
  maxBlockExUnits: ExecutionUnitsRef;
  maxCollateralInputs: Scalars['Int'];
  maxTxExUnits: ExecutionUnitsRef;
  maxValueSize: Scalars['Int'];
};

export type AddAlonzoGenesisPayload = {
  __typename?: 'AddAlonzoGenesisPayload';
  alonzoGenesis?: Maybe<Array<Maybe<AlonzoGenesis>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAlonzoGenesisPayloadAlonzoGenesisArgs = {
  filter?: Maybe<AlonzoGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AlonzoGenesisOrder>;
};

export type AddAssetInput = {
  assetId: Scalars['String'];
  assetName: Scalars['String'];
  decimals: Scalars['Int'];
  description: Scalars['String'];
  fingerprint: Scalars['String'];
};

export type AddAssetPayload = {
  __typename?: 'AddAssetPayload';
  asset?: Maybe<Array<Maybe<Asset>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAssetPayloadAssetArgs = {
  filter?: Maybe<AssetFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetOrder>;
};

export type AddAssetSupplyInput = {
  circulating: Scalars['String'];
  max: Scalars['String'];
  total?: Maybe<Scalars['String']>;
};

export type AddAssetSupplyPayload = {
  __typename?: 'AddAssetSupplyPayload';
  assetSupply?: Maybe<Array<Maybe<AssetSupply>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAssetSupplyPayloadAssetSupplyArgs = {
  filter?: Maybe<AssetSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetSupplyOrder>;
};

export type AddAuxiliaryDataBodyInput = {
  auxiliaryData: AuxiliaryDataRef;
  blob?: Maybe<Array<MetadatumRef>>;
  scripts?: Maybe<Array<ScriptRef>>;
};

export type AddAuxiliaryDataBodyPayload = {
  __typename?: 'AddAuxiliaryDataBodyPayload';
  auxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAuxiliaryDataBodyPayloadAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddAuxiliaryDataInput = {
  body: AuxiliaryDataBodyRef;
  hash: Scalars['String'];
  transaction: TransactionRef;
};

export type AddAuxiliaryDataPayload = {
  __typename?: 'AddAuxiliaryDataPayload';
  auxiliaryData?: Maybe<Array<Maybe<AuxiliaryData>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAuxiliaryDataPayloadAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AuxiliaryDataOrder>;
};

export type AddBlockInput = {
  blockNo: Scalars['Int'];
  confirmations: Scalars['Int'];
  epoch: EpochRef;
  fees: Scalars['Int64'];
  hash: Scalars['String'];
  issuer: StakePoolRef;
  nextBlock: BlockRef;
  nextBlockProtocolVersion: ProtocolVersionRef;
  opCert: Scalars['String'];
  previousBlock: BlockRef;
  size: Scalars['Int64'];
  slot: SlotRef;
  totalOutput: Scalars['Int64'];
  transactions: Array<TransactionRef>;
};

export type AddBlockPayload = {
  __typename?: 'AddBlockPayload';
  block?: Maybe<Array<Maybe<Block>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddBlockPayloadBlockArgs = {
  filter?: Maybe<BlockFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BlockOrder>;
};

export type AddByronBlockVersionDataInput = {
  heavyDelThd: Scalars['String'];
  maxBlockSize: Scalars['Int'];
  maxHeaderSize: Scalars['Int'];
  maxProposalSize: Scalars['Int'];
  maxTxSize: Scalars['Int'];
  mpcThd: Scalars['String'];
  scriptVerson: Scalars['Int'];
  slotDuration: Scalars['Int'];
  softforkRule: ByronSoftForkRuleRef;
  txFeePolicy: ByronTxFeePolicyRef;
  unlockStakeEpoch: Scalars['String'];
  updateImplicit: Scalars['String'];
  updateProposalThd: Scalars['String'];
  updateVoteThd: Scalars['String'];
};

export type AddByronBlockVersionDataPayload = {
  __typename?: 'AddByronBlockVersionDataPayload';
  byronBlockVersionData?: Maybe<Array<Maybe<ByronBlockVersionData>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddByronBlockVersionDataPayloadByronBlockVersionDataArgs = {
  filter?: Maybe<ByronBlockVersionDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronBlockVersionDataOrder>;
};

export type AddByronGenesisInput = {
  avvmDistr: Scalars['String'];
  blockVersionData: ByronBlockVersionDataRef;
  bootStakeholders: Scalars['String'];
  heavyDelegation: Scalars['String'];
  nonAvvmBalances: Scalars['String'];
  protocolConsts: ByronProtocolConstsRef;
  startTime: Scalars['DateTime'];
};

export type AddByronGenesisPayload = {
  __typename?: 'AddByronGenesisPayload';
  byronGenesis?: Maybe<Array<Maybe<ByronGenesis>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddByronGenesisPayloadByronGenesisArgs = {
  filter?: Maybe<ByronGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronGenesisOrder>;
};

export type AddByronProtocolConstsInput = {
  k: Scalars['Int'];
  protocolMagic?: Maybe<Scalars['Int']>;
};

export type AddByronProtocolConstsPayload = {
  __typename?: 'AddByronProtocolConstsPayload';
  byronProtocolConsts?: Maybe<Array<Maybe<ByronProtocolConsts>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddByronProtocolConstsPayloadByronProtocolConstsArgs = {
  filter?: Maybe<ByronProtocolConstsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronProtocolConstsOrder>;
};

export type AddByronSoftForkRuleInput = {
  initThd: Scalars['String'];
  minThd: Scalars['String'];
  thdDecrement: Scalars['String'];
};

export type AddByronSoftForkRulePayload = {
  __typename?: 'AddByronSoftForkRulePayload';
  byronSoftForkRule?: Maybe<Array<Maybe<ByronSoftForkRule>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddByronSoftForkRulePayloadByronSoftForkRuleArgs = {
  filter?: Maybe<ByronSoftForkRuleFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronSoftForkRuleOrder>;
};

export type AddByronTxFeePolicyInput = {
  minThd: Scalars['String'];
  summand: Scalars['String'];
};

export type AddByronTxFeePolicyPayload = {
  __typename?: 'AddByronTxFeePolicyPayload';
  byronTxFeePolicy?: Maybe<Array<Maybe<ByronTxFeePolicy>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddByronTxFeePolicyPayloadByronTxFeePolicyArgs = {
  filter?: Maybe<ByronTxFeePolicyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronTxFeePolicyOrder>;
};

export type AddBytesMetadatumInput = {
  value: Scalars['String'];
  valueType: MetadatumStringType;
};

export type AddBytesMetadatumPayload = {
  __typename?: 'AddBytesMetadatumPayload';
  bytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddBytesMetadatumPayloadBytesMetadatumArgs = {
  filter?: Maybe<BytesMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BytesMetadatumOrder>;
};

export type AddEpochInput = {
  activeStake: Array<ActiveStakeRef>;
  adaPots: AdaPotsRef;
  blocks: Array<BlockRef>;
  endedAt: SlotRef;
  fees: Scalars['Int64'];
  nonce: Scalars['String'];
  number: Scalars['Int'];
  output: Scalars['Int64'];
  protocolParams: ProtocolParametersRef;
  startedAt: SlotRef;
};

export type AddEpochPayload = {
  __typename?: 'AddEpochPayload';
  epoch?: Maybe<Array<Maybe<Epoch>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddEpochPayloadEpochArgs = {
  filter?: Maybe<EpochFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<EpochOrder>;
};

export type AddExecutionPriceInput = {
  denominator: Scalars['Int'];
  numerator: Scalars['Int'];
};

export type AddExecutionPricePayload = {
  __typename?: 'AddExecutionPricePayload';
  executionPrice?: Maybe<Array<Maybe<ExecutionPrice>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddExecutionPricePayloadExecutionPriceArgs = {
  filter?: Maybe<ExecutionPriceFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionPriceOrder>;
};

export type AddExecutionPricesInput = {
  prMem: ExecutionPriceRef;
  prSteps: ExecutionPriceRef;
};

export type AddExecutionPricesPayload = {
  __typename?: 'AddExecutionPricesPayload';
  executionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddExecutionPricesPayloadExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddExecutionUnitsInput = {
  memory: Scalars['Int'];
  steps: Scalars['Int'];
};

export type AddExecutionUnitsPayload = {
  __typename?: 'AddExecutionUnitsPayload';
  executionUnits?: Maybe<Array<Maybe<ExecutionUnits>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddExecutionUnitsPayloadExecutionUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionUnitsOrder>;
};

export type AddExtendedStakePoolMetadataFieldsInput = {
  contact?: Maybe<PoolContactDataRef>;
  country?: Maybe<Scalars['String']>;
  id: Scalars['String'];
  itn?: Maybe<ItnVerificationRef>;
  media_assets?: Maybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: Maybe<ExtendedPoolStatus>;
};

export type AddExtendedStakePoolMetadataFieldsPayload = {
  __typename?: 'AddExtendedStakePoolMetadataFieldsPayload';
  extendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddExtendedStakePoolMetadataFieldsPayloadExtendedStakePoolMetadataFieldsArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataFieldsOrder>;
};

export type AddExtendedStakePoolMetadataInput = {
  metadata: StakePoolMetadataRef;
  pool: ExtendedStakePoolMetadataFieldsRef;
  serial: Scalars['Int'];
};

export type AddExtendedStakePoolMetadataPayload = {
  __typename?: 'AddExtendedStakePoolMetadataPayload';
  extendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddExtendedStakePoolMetadataPayloadExtendedStakePoolMetadataArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataOrder>;
};

export type AddFractionInput = {
  denominator: Scalars['Int'];
  numerator: Scalars['Int'];
};

export type AddFractionPayload = {
  __typename?: 'AddFractionPayload';
  fraction?: Maybe<Array<Maybe<Fraction>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddFractionPayloadFractionArgs = {
  filter?: Maybe<FractionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<FractionOrder>;
};

export type AddGenesisInput = {
  alonzo: AlonzoGenesisRef;
  byron: ByronGenesisRef;
  shelley: ShelleyGenesisRef;
};

export type AddGenesisPayload = {
  __typename?: 'AddGenesisPayload';
  genesis?: Maybe<Array<Maybe<Genesis>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddGenesisPayloadGenesisArgs = {
  filter?: Maybe<GenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddItnVerificationInput = {
  owner: Scalars['String'];
  witness: Scalars['String'];
};

export type AddItnVerificationPayload = {
  __typename?: 'AddITNVerificationPayload';
  iTNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddItnVerificationPayloadITnVerificationArgs = {
  filter?: Maybe<ItnVerificationFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ItnVerificationOrder>;
};

export type AddIntegerMetadatumInput = {
  value: Scalars['Int'];
};

export type AddIntegerMetadatumPayload = {
  __typename?: 'AddIntegerMetadatumPayload';
  integerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddIntegerMetadatumPayloadIntegerMetadatumArgs = {
  filter?: Maybe<IntegerMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<IntegerMetadatumOrder>;
};

export type AddKeyValueMetadatumInput = {
  key: Scalars['String'];
  metadatum: MetadatumRef;
};

export type AddKeyValueMetadatumPayload = {
  __typename?: 'AddKeyValueMetadatumPayload';
  keyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddKeyValueMetadatumPayloadKeyValueMetadatumArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<KeyValueMetadatumOrder>;
};

export type AddMetadatumArrayInput = {
  value: Array<MetadatumRef>;
  valueType: MetadatumArrayType;
};

export type AddMetadatumArrayPayload = {
  __typename?: 'AddMetadatumArrayPayload';
  metadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddMetadatumArrayPayloadMetadatumArrayArgs = {
  filter?: Maybe<MetadatumArrayFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddMetadatumMapInput = {
  value: Array<KeyValueMetadatumRef>;
  valueType: MetadatumArrayType;
};

export type AddMetadatumMapPayload = {
  __typename?: 'AddMetadatumMapPayload';
  metadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddMetadatumMapPayloadMetadatumMapArgs = {
  filter?: Maybe<MetadatumMapFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddPoolContactDataInput = {
  email?: Maybe<Scalars['String']>;
  facebook?: Maybe<Scalars['String']>;
  feed?: Maybe<Scalars['String']>;
  github?: Maybe<Scalars['String']>;
  primary: Scalars['String'];
  telegram?: Maybe<Scalars['String']>;
  twitter?: Maybe<Scalars['String']>;
};

export type AddPoolContactDataPayload = {
  __typename?: 'AddPoolContactDataPayload';
  numUids?: Maybe<Scalars['Int']>;
  poolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
};


export type AddPoolContactDataPayloadPoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolContactDataOrder>;
};

export type AddProtocolParametersInput = {
  a0: Scalars['Float'];
  coinsPerUtxoWord?: Maybe<Scalars['Int']>;
  collateralPercent?: Maybe<Scalars['Int']>;
  costModels?: Maybe<Scalars['String']>;
  decentralizationParam: Scalars['Float'];
  eMax: Scalars['Int'];
  executionPrices?: Maybe<ExecutionPricesRef>;
  extraEntropy?: Maybe<Scalars['String']>;
  keyDeposit: Scalars['Int'];
  maxBlockBodySize: Scalars['Int'];
  maxBlockExUnits?: Maybe<ExecutionUnitsRef>;
  maxBlockHeaderSize: Scalars['Int'];
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxTxExUnits?: Maybe<ExecutionUnitsRef>;
  maxTxSize: Scalars['Int'];
  maxValSize: Scalars['Int'];
  minFeeA: Scalars['Int'];
  minFeeB: Scalars['Int'];
  minPoolCost: Scalars['Int'];
  minUTxOValue: Scalars['Int'];
  nOpt: Scalars['Int'];
  poolDeposit: Scalars['Int'];
  protocolVersion: ProtocolVersionRef;
  rho: Scalars['Float'];
  tau: Scalars['Float'];
};

export type AddProtocolParametersPayload = {
  __typename?: 'AddProtocolParametersPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParameters?: Maybe<Array<Maybe<ProtocolParameters>>>;
};


export type AddProtocolParametersPayloadProtocolParametersArgs = {
  filter?: Maybe<ProtocolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersOrder>;
};

export type AddProtocolVersionInput = {
  major: Scalars['Int'];
  minor: Scalars['Int'];
  patch?: Maybe<Scalars['Int']>;
};

export type AddProtocolVersionPayload = {
  __typename?: 'AddProtocolVersionPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
};


export type AddProtocolVersionPayloadProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolVersionOrder>;
};

export type AddRedeemerInput = {
  executionUnits: ExecutionUnitsRef;
  fee: Scalars['Int64'];
  index: Scalars['Int'];
  purpose: Scalars['String'];
  scriptHash: Scalars['String'];
  transaction: TransactionRef;
};

export type AddRedeemerPayload = {
  __typename?: 'AddRedeemerPayload';
  numUids?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<Array<Maybe<Redeemer>>>;
};


export type AddRedeemerPayloadRedeemerArgs = {
  filter?: Maybe<RedeemerFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RedeemerOrder>;
};

export type AddRelayByAddressInput = {
  ipv4?: Maybe<Scalars['String']>;
  ipv6?: Maybe<Scalars['String']>;
  port?: Maybe<Scalars['Int']>;
};

export type AddRelayByAddressPayload = {
  __typename?: 'AddRelayByAddressPayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
};


export type AddRelayByAddressPayloadRelayByAddressArgs = {
  filter?: Maybe<RelayByAddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByAddressOrder>;
};

export type AddRelayByNameInput = {
  hostname: Scalars['String'];
  port?: Maybe<Scalars['Int']>;
};

export type AddRelayByNameMultihostInput = {
  dnsName: Scalars['String'];
};

export type AddRelayByNameMultihostPayload = {
  __typename?: 'AddRelayByNameMultihostPayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByNameMultihost?: Maybe<Array<Maybe<RelayByNameMultihost>>>;
};


export type AddRelayByNameMultihostPayloadRelayByNameMultihostArgs = {
  filter?: Maybe<RelayByNameMultihostFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameMultihostOrder>;
};

export type AddRelayByNamePayload = {
  __typename?: 'AddRelayByNamePayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByName?: Maybe<Array<Maybe<RelayByName>>>;
};


export type AddRelayByNamePayloadRelayByNameArgs = {
  filter?: Maybe<RelayByNameFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameOrder>;
};

export type AddRewardAccountInput = {
  activeStake: ActiveStakeRef;
  address: Scalars['String'];
  addresses: AddressRef;
};

export type AddRewardAccountPayload = {
  __typename?: 'AddRewardAccountPayload';
  numUids?: Maybe<Scalars['Int']>;
  rewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
};


export type AddRewardAccountPayloadRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RewardAccountOrder>;
};

export type AddScriptInput = {
  auxiliaryDataBody: AuxiliaryDataBodyRef;
  hash: Scalars['String'];
  serializedSize: Scalars['Int64'];
  type: Scalars['String'];
};

export type AddScriptPayload = {
  __typename?: 'AddScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  script?: Maybe<Array<Maybe<Script>>>;
};


export type AddScriptPayloadScriptArgs = {
  filter?: Maybe<ScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ScriptOrder>;
};

export type AddShelleyGenesisInput = {
  activeSlotsCoeff: Scalars['Float'];
  epochLength: Scalars['Int'];
  genDelegs?: Maybe<Scalars['String']>;
  initialFunds: Scalars['String'];
  maxKESEvolutions: Scalars['Int'];
  maxLovelaceSupply: Scalars['Int64'];
  networkId: Scalars['String'];
  networkMagic: Scalars['Int'];
  protocolParams: ProtocolParametersRef;
  securityParam: Scalars['Int'];
  slotLength: Scalars['Int'];
  slotsPerKESPeriod: Scalars['Int'];
  staking: ShelleyGenesisStakingRef;
  systemStart: Scalars['DateTime'];
  updateQuorum: Scalars['Int'];
};

export type AddShelleyGenesisPayload = {
  __typename?: 'AddShelleyGenesisPayload';
  numUids?: Maybe<Scalars['Int']>;
  shelleyGenesis?: Maybe<Array<Maybe<ShelleyGenesis>>>;
};


export type AddShelleyGenesisPayloadShelleyGenesisArgs = {
  filter?: Maybe<ShelleyGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisOrder>;
};

export type AddShelleyGenesisStakingInput = {
  pools: Scalars['String'];
  stake: Scalars['String'];
};

export type AddShelleyGenesisStakingPayload = {
  __typename?: 'AddShelleyGenesisStakingPayload';
  numUids?: Maybe<Scalars['Int']>;
  shelleyGenesisStaking?: Maybe<Array<Maybe<ShelleyGenesisStaking>>>;
};


export type AddShelleyGenesisStakingPayloadShelleyGenesisStakingArgs = {
  filter?: Maybe<ShelleyGenesisStakingFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisStakingOrder>;
};

export type AddSlotInput = {
  block?: Maybe<BlockRef>;
  date: Scalars['DateTime'];
  number: Scalars['Int'];
  slotInEpoch: Scalars['Int'];
};

export type AddSlotPayload = {
  __typename?: 'AddSlotPayload';
  numUids?: Maybe<Scalars['Int']>;
  slot?: Maybe<Array<Maybe<Slot>>>;
};


export type AddSlotPayloadSlotArgs = {
  filter?: Maybe<SlotFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SlotOrder>;
};

export type AddStakePoolInput = {
  /** Coin quantity */
  cost: Scalars['String'];
  hexId: Scalars['String'];
  id: Scalars['String'];
  margin: FractionRef;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  metrics: StakePoolMetricsRef;
  owners: Array<Scalars['String']>;
  /** Coin quantity */
  pledge: Scalars['String'];
  relays: Array<SearchResultRef>;
  rewardAccount: Scalars['String'];
  /** active | retired | retiring */
  status: StakePoolStatus;
  transactions: StakePoolTransactionsRef;
  vrf: Scalars['String'];
};

export type AddStakePoolMetadataInput = {
  description: Scalars['String'];
  ext?: Maybe<ExtendedStakePoolMetadataRef>;
  extDataUrl?: Maybe<Scalars['String']>;
  extSigUrl?: Maybe<Scalars['String']>;
  extVkey?: Maybe<Scalars['String']>;
  homepage: Scalars['String'];
  name: Scalars['String'];
  stakePool: StakePoolRef;
  stakePoolId: Scalars['String'];
  ticker: Scalars['String'];
};

export type AddStakePoolMetadataJsonInput = {
  hash: Scalars['String'];
  url: Scalars['String'];
};

export type AddStakePoolMetadataJsonPayload = {
  __typename?: 'AddStakePoolMetadataJsonPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
};


export type AddStakePoolMetadataJsonPayloadStakePoolMetadataJsonArgs = {
  filter?: Maybe<StakePoolMetadataJsonFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataJsonOrder>;
};

export type AddStakePoolMetadataPayload = {
  __typename?: 'AddStakePoolMetadataPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
};


export type AddStakePoolMetadataPayloadStakePoolMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataOrder>;
};

export type AddStakePoolMetricsInput = {
  blocksCreated: Scalars['Int'];
  delegators: Scalars['Int'];
  /** Coin quantity */
  livePledge: Scalars['String'];
  saturation: Scalars['Float'];
  size: StakePoolMetricsSizeRef;
  stake: StakePoolMetricsStakeRef;
};

export type AddStakePoolMetricsPayload = {
  __typename?: 'AddStakePoolMetricsPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
};


export type AddStakePoolMetricsPayloadStakePoolMetricsArgs = {
  filter?: Maybe<StakePoolMetricsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsOrder>;
};

export type AddStakePoolMetricsSizeInput = {
  /** Percentage in range [0; 1] */
  active: Scalars['Float'];
  /** Percentage in range [0; 1] */
  live: Scalars['Float'];
};

export type AddStakePoolMetricsSizePayload = {
  __typename?: 'AddStakePoolMetricsSizePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
};


export type AddStakePoolMetricsSizePayloadStakePoolMetricsSizeArgs = {
  filter?: Maybe<StakePoolMetricsSizeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsSizeOrder>;
};

export type AddStakePoolMetricsStakeInput = {
  /** Coin quantity */
  active: Scalars['String'];
  /** Coin quantity */
  live: Scalars['String'];
};

export type AddStakePoolMetricsStakePayload = {
  __typename?: 'AddStakePoolMetricsStakePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
};


export type AddStakePoolMetricsStakePayloadStakePoolMetricsStakeArgs = {
  filter?: Maybe<StakePoolMetricsStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsStakeOrder>;
};

export type AddStakePoolPayload = {
  __typename?: 'AddStakePoolPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<Array<Maybe<StakePool>>>;
};


export type AddStakePoolPayloadStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolOrder>;
};

export type AddStakePoolTransactionsInput = {
  registration: Array<Scalars['String']>;
  retirement: Array<Scalars['String']>;
};

export type AddStakePoolTransactionsPayload = {
  __typename?: 'AddStakePoolTransactionsPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolTransactions?: Maybe<Array<Maybe<StakePoolTransactions>>>;
};


export type AddStakePoolTransactionsPayloadStakePoolTransactionsArgs = {
  filter?: Maybe<StakePoolTransactionsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddStringMetadatumInput = {
  value: Scalars['String'];
  valueType: MetadatumStringType;
};

export type AddStringMetadatumPayload = {
  __typename?: 'AddStringMetadatumPayload';
  numUids?: Maybe<Scalars['Int']>;
  stringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
};


export type AddStringMetadatumPayloadStringMetadatumArgs = {
  filter?: Maybe<StringMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StringMetadatumOrder>;
};

export type AddThePoolsMediaAssetsInput = {
  color_bg?: Maybe<Scalars['String']>;
  color_fg?: Maybe<Scalars['String']>;
  icon_png_64x64: Scalars['String'];
  logo_png?: Maybe<Scalars['String']>;
  logo_svg?: Maybe<Scalars['String']>;
};

export type AddThePoolsMediaAssetsPayload = {
  __typename?: 'AddThePoolsMediaAssetsPayload';
  numUids?: Maybe<Scalars['Int']>;
  thePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
};


export type AddThePoolsMediaAssetsPayloadThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ThePoolsMediaAssetsOrder>;
};

export type AddTokenInput = {
  asset: AssetRef;
  quantity: Scalars['String'];
  transactionOutput: TransactionOutputRef;
};

export type AddTokenPayload = {
  __typename?: 'AddTokenPayload';
  numUids?: Maybe<Scalars['Int']>;
  token?: Maybe<Array<Maybe<Token>>>;
};


export type AddTokenPayloadTokenArgs = {
  filter?: Maybe<TokenFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TokenOrder>;
};

export type AddTransactionInput = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  block: BlockRef;
  blockIndex: Scalars['Int'];
  collateral?: Maybe<Array<TransactionInputRef>>;
  deposit: Scalars['Int64'];
  fee: Scalars['Int64'];
  hash: Scalars['String'];
  inputs: Array<TransactionInputRef>;
  invalidBefore?: Maybe<Scalars['Int']>;
  invalidHereafter?: Maybe<Scalars['Int']>;
  mint?: Maybe<Array<TokenRef>>;
  outputs: Array<TransactionOutputRef>;
  redeemers?: Maybe<Array<RedeemerRef>>;
  size: Scalars['Int64'];
  totalOutputCoin: Scalars['Int64'];
  validContract: Scalars['Boolean'];
  withdrawals?: Maybe<Array<WithdrawalRef>>;
};

export type AddTransactionInputInput = {
  address: AddressRef;
  index: Scalars['Int'];
  redeemer?: Maybe<RedeemerRef>;
  sourceTransaction: TransactionRef;
  transaction: TransactionRef;
  value: ValueRef;
};

export type AddTransactionInputPayload = {
  __typename?: 'AddTransactionInputPayload';
  numUids?: Maybe<Scalars['Int']>;
  transactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
};


export type AddTransactionInputPayloadTransactionInputArgs = {
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};

export type AddTransactionOutputInput = {
  address: AddressRef;
  index: Scalars['Int'];
  transaction: TransactionRef;
  value: ValueRef;
};

export type AddTransactionOutputPayload = {
  __typename?: 'AddTransactionOutputPayload';
  numUids?: Maybe<Scalars['Int']>;
  transactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
};


export type AddTransactionOutputPayloadTransactionOutputArgs = {
  filter?: Maybe<TransactionOutputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOutputOrder>;
};

export type AddTransactionPayload = {
  __typename?: 'AddTransactionPayload';
  numUids?: Maybe<Scalars['Int']>;
  transaction?: Maybe<Array<Maybe<Transaction>>>;
};


export type AddTransactionPayloadTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOrder>;
};

export type AddValueInput = {
  assets?: Maybe<Array<TokenRef>>;
  coin: Scalars['Int64'];
};

export type AddValuePayload = {
  __typename?: 'AddValuePayload';
  numUids?: Maybe<Scalars['Int']>;
  value?: Maybe<Array<Maybe<Value>>>;
};


export type AddValuePayloadValueArgs = {
  filter?: Maybe<ValueFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ValueOrder>;
};

export type AddWithdrawalInput = {
  quantity: Scalars['Int64'];
  redeemer?: Maybe<Scalars['String']>;
  rewardAccount: RewardAccountRef;
  transaction: TransactionRef;
};

export type AddWithdrawalPayload = {
  __typename?: 'AddWithdrawalPayload';
  numUids?: Maybe<Scalars['Int']>;
  withdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
};


export type AddWithdrawalPayloadWithdrawalArgs = {
  filter?: Maybe<WithdrawalFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WithdrawalOrder>;
};

export type Address = {
  __typename?: 'Address';
  address: Scalars['String'];
  addressType: AddressType;
  /** Spending history */
  inputs: Array<TransactionInput>;
  inputsAggregate?: Maybe<TransactionInputAggregateResult>;
  rewardAccount?: Maybe<RewardAccount>;
  /** Balance */
  utxo: Array<TransactionOutput>;
  utxoAggregate?: Maybe<TransactionOutputAggregateResult>;
};


export type AddressInputsArgs = {
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};


export type AddressInputsAggregateArgs = {
  filter?: Maybe<TransactionInputFilter>;
};


export type AddressRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type AddressUtxoArgs = {
  filter?: Maybe<TransactionOutputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOutputOrder>;
};


export type AddressUtxoAggregateArgs = {
  filter?: Maybe<TransactionOutputFilter>;
};

export type AddressAggregateResult = {
  __typename?: 'AddressAggregateResult';
  addressMax?: Maybe<Scalars['String']>;
  addressMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
};

export type AddressFilter = {
  and?: Maybe<Array<Maybe<AddressFilter>>>;
  has?: Maybe<Array<Maybe<AddressHasFilter>>>;
  not?: Maybe<AddressFilter>;
  or?: Maybe<Array<Maybe<AddressFilter>>>;
};

export enum AddressHasFilter {
  Address = 'address',
  AddressType = 'addressType',
  Inputs = 'inputs',
  RewardAccount = 'rewardAccount',
  Utxo = 'utxo'
}

export type AddressOrder = {
  asc?: Maybe<AddressOrderable>;
  desc?: Maybe<AddressOrderable>;
  then?: Maybe<AddressOrder>;
};

export enum AddressOrderable {
  Address = 'address'
}

export type AddressPatch = {
  address?: Maybe<Scalars['String']>;
  addressType?: Maybe<AddressType>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  rewardAccount?: Maybe<RewardAccountRef>;
  utxo?: Maybe<Array<TransactionOutputRef>>;
};

export type AddressRef = {
  address?: Maybe<Scalars['String']>;
  addressType?: Maybe<AddressType>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  rewardAccount?: Maybe<RewardAccountRef>;
  utxo?: Maybe<Array<TransactionOutputRef>>;
};

export enum AddressType {
  Byron = 'byron',
  Shelley = 'shelley'
}

export type AlonzoGenesis = {
  __typename?: 'AlonzoGenesis';
  collateralPercentage: Scalars['Int'];
  executionPrices: ExecutionPrices;
  lovelacePerUTxOWord: Scalars['Int'];
  maxBlockExUnits: ExecutionUnits;
  maxCollateralInputs: Scalars['Int'];
  maxTxExUnits: ExecutionUnits;
  maxValueSize: Scalars['Int'];
};


export type AlonzoGenesisExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
};


export type AlonzoGenesisMaxBlockExUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type AlonzoGenesisMaxTxExUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};

export type AlonzoGenesisAggregateResult = {
  __typename?: 'AlonzoGenesisAggregateResult';
  collateralPercentageAvg?: Maybe<Scalars['Float']>;
  collateralPercentageMax?: Maybe<Scalars['Int']>;
  collateralPercentageMin?: Maybe<Scalars['Int']>;
  collateralPercentageSum?: Maybe<Scalars['Int']>;
  count?: Maybe<Scalars['Int']>;
  lovelacePerUTxOWordAvg?: Maybe<Scalars['Float']>;
  lovelacePerUTxOWordMax?: Maybe<Scalars['Int']>;
  lovelacePerUTxOWordMin?: Maybe<Scalars['Int']>;
  lovelacePerUTxOWordSum?: Maybe<Scalars['Int']>;
  maxCollateralInputsAvg?: Maybe<Scalars['Float']>;
  maxCollateralInputsMax?: Maybe<Scalars['Int']>;
  maxCollateralInputsMin?: Maybe<Scalars['Int']>;
  maxCollateralInputsSum?: Maybe<Scalars['Int']>;
  maxValueSizeAvg?: Maybe<Scalars['Float']>;
  maxValueSizeMax?: Maybe<Scalars['Int']>;
  maxValueSizeMin?: Maybe<Scalars['Int']>;
  maxValueSizeSum?: Maybe<Scalars['Int']>;
};

export type AlonzoGenesisFilter = {
  and?: Maybe<Array<Maybe<AlonzoGenesisFilter>>>;
  has?: Maybe<Array<Maybe<AlonzoGenesisHasFilter>>>;
  not?: Maybe<AlonzoGenesisFilter>;
  or?: Maybe<Array<Maybe<AlonzoGenesisFilter>>>;
};

export enum AlonzoGenesisHasFilter {
  CollateralPercentage = 'collateralPercentage',
  ExecutionPrices = 'executionPrices',
  LovelacePerUTxOWord = 'lovelacePerUTxOWord',
  MaxBlockExUnits = 'maxBlockExUnits',
  MaxCollateralInputs = 'maxCollateralInputs',
  MaxTxExUnits = 'maxTxExUnits',
  MaxValueSize = 'maxValueSize'
}

export type AlonzoGenesisOrder = {
  asc?: Maybe<AlonzoGenesisOrderable>;
  desc?: Maybe<AlonzoGenesisOrderable>;
  then?: Maybe<AlonzoGenesisOrder>;
};

export enum AlonzoGenesisOrderable {
  CollateralPercentage = 'collateralPercentage',
  LovelacePerUTxOWord = 'lovelacePerUTxOWord',
  MaxCollateralInputs = 'maxCollateralInputs',
  MaxValueSize = 'maxValueSize'
}

export type AlonzoGenesisPatch = {
  collateralPercentage?: Maybe<Scalars['Int']>;
  executionPrices?: Maybe<ExecutionPricesRef>;
  lovelacePerUTxOWord?: Maybe<Scalars['Int']>;
  maxBlockExUnits?: Maybe<ExecutionUnitsRef>;
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxTxExUnits?: Maybe<ExecutionUnitsRef>;
  maxValueSize?: Maybe<Scalars['Int']>;
};

export type AlonzoGenesisRef = {
  collateralPercentage?: Maybe<Scalars['Int']>;
  executionPrices?: Maybe<ExecutionPricesRef>;
  lovelacePerUTxOWord?: Maybe<Scalars['Int']>;
  maxBlockExUnits?: Maybe<ExecutionUnitsRef>;
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxTxExUnits?: Maybe<ExecutionUnitsRef>;
  maxValueSize?: Maybe<Scalars['Int']>;
};

export type Asset = {
  __typename?: 'Asset';
  assetId: Scalars['String'];
  assetName: Scalars['String'];
  decimals: Scalars['Int'];
  description: Scalars['String'];
  fingerprint: Scalars['String'];
};

export type AssetAggregateResult = {
  __typename?: 'AssetAggregateResult';
  assetIdMax?: Maybe<Scalars['String']>;
  assetIdMin?: Maybe<Scalars['String']>;
  assetNameMax?: Maybe<Scalars['String']>;
  assetNameMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  decimalsAvg?: Maybe<Scalars['Float']>;
  decimalsMax?: Maybe<Scalars['Int']>;
  decimalsMin?: Maybe<Scalars['Int']>;
  decimalsSum?: Maybe<Scalars['Int']>;
  descriptionMax?: Maybe<Scalars['String']>;
  descriptionMin?: Maybe<Scalars['String']>;
  fingerprintMax?: Maybe<Scalars['String']>;
  fingerprintMin?: Maybe<Scalars['String']>;
};

export type AssetFilter = {
  and?: Maybe<Array<Maybe<AssetFilter>>>;
  has?: Maybe<Array<Maybe<AssetHasFilter>>>;
  not?: Maybe<AssetFilter>;
  or?: Maybe<Array<Maybe<AssetFilter>>>;
};

export enum AssetHasFilter {
  AssetId = 'assetId',
  AssetName = 'assetName',
  Decimals = 'decimals',
  Description = 'description',
  Fingerprint = 'fingerprint'
}

export type AssetOrder = {
  asc?: Maybe<AssetOrderable>;
  desc?: Maybe<AssetOrderable>;
  then?: Maybe<AssetOrder>;
};

export enum AssetOrderable {
  AssetId = 'assetId',
  AssetName = 'assetName',
  Decimals = 'decimals',
  Description = 'description',
  Fingerprint = 'fingerprint'
}

export type AssetPatch = {
  assetId?: Maybe<Scalars['String']>;
  assetName?: Maybe<Scalars['String']>;
  decimals?: Maybe<Scalars['Int']>;
  description?: Maybe<Scalars['String']>;
  fingerprint?: Maybe<Scalars['String']>;
};

export type AssetRef = {
  assetId?: Maybe<Scalars['String']>;
  assetName?: Maybe<Scalars['String']>;
  decimals?: Maybe<Scalars['Int']>;
  description?: Maybe<Scalars['String']>;
  fingerprint?: Maybe<Scalars['String']>;
};

export type AssetSupply = {
  __typename?: 'AssetSupply';
  circulating: Scalars['String'];
  max: Scalars['String'];
  total?: Maybe<Scalars['String']>;
};

export type AssetSupplyAggregateResult = {
  __typename?: 'AssetSupplyAggregateResult';
  circulatingMax?: Maybe<Scalars['String']>;
  circulatingMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  maxMax?: Maybe<Scalars['String']>;
  maxMin?: Maybe<Scalars['String']>;
  totalMax?: Maybe<Scalars['String']>;
  totalMin?: Maybe<Scalars['String']>;
};

export type AssetSupplyFilter = {
  and?: Maybe<Array<Maybe<AssetSupplyFilter>>>;
  has?: Maybe<Array<Maybe<AssetSupplyHasFilter>>>;
  not?: Maybe<AssetSupplyFilter>;
  or?: Maybe<Array<Maybe<AssetSupplyFilter>>>;
};

export enum AssetSupplyHasFilter {
  Circulating = 'circulating',
  Max = 'max',
  Total = 'total'
}

export type AssetSupplyOrder = {
  asc?: Maybe<AssetSupplyOrderable>;
  desc?: Maybe<AssetSupplyOrderable>;
  then?: Maybe<AssetSupplyOrder>;
};

export enum AssetSupplyOrderable {
  Circulating = 'circulating',
  Max = 'max',
  Total = 'total'
}

export type AssetSupplyPatch = {
  circulating?: Maybe<Scalars['String']>;
  max?: Maybe<Scalars['String']>;
  total?: Maybe<Scalars['String']>;
};

export type AssetSupplyRef = {
  circulating?: Maybe<Scalars['String']>;
  max?: Maybe<Scalars['String']>;
  total?: Maybe<Scalars['String']>;
};

export type AuthRule = {
  and?: Maybe<Array<Maybe<AuthRule>>>;
  not?: Maybe<AuthRule>;
  or?: Maybe<Array<Maybe<AuthRule>>>;
  rule?: Maybe<Scalars['String']>;
};

export type AuxiliaryData = {
  __typename?: 'AuxiliaryData';
  body: AuxiliaryDataBody;
  hash: Scalars['String'];
  transaction: Transaction;
};


export type AuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
};


export type AuxiliaryDataTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type AuxiliaryDataAggregateResult = {
  __typename?: 'AuxiliaryDataAggregateResult';
  count?: Maybe<Scalars['Int']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
};

export type AuxiliaryDataBody = {
  __typename?: 'AuxiliaryDataBody';
  auxiliaryData: AuxiliaryData;
  blob?: Maybe<Array<Metadatum>>;
  scripts?: Maybe<Array<Script>>;
  scriptsAggregate?: Maybe<ScriptAggregateResult>;
};


export type AuxiliaryDataBodyAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
};


export type AuxiliaryDataBodyBlobArgs = {
  filter?: Maybe<MetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type AuxiliaryDataBodyScriptsArgs = {
  filter?: Maybe<ScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ScriptOrder>;
};


export type AuxiliaryDataBodyScriptsAggregateArgs = {
  filter?: Maybe<ScriptFilter>;
};

export type AuxiliaryDataBodyAggregateResult = {
  __typename?: 'AuxiliaryDataBodyAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type AuxiliaryDataBodyFilter = {
  and?: Maybe<Array<Maybe<AuxiliaryDataBodyFilter>>>;
  has?: Maybe<Array<Maybe<AuxiliaryDataBodyHasFilter>>>;
  not?: Maybe<AuxiliaryDataBodyFilter>;
  or?: Maybe<Array<Maybe<AuxiliaryDataBodyFilter>>>;
};

export enum AuxiliaryDataBodyHasFilter {
  AuxiliaryData = 'auxiliaryData',
  Blob = 'blob',
  Scripts = 'scripts'
}

export type AuxiliaryDataBodyPatch = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  blob?: Maybe<Array<MetadatumRef>>;
  scripts?: Maybe<Array<ScriptRef>>;
};

export type AuxiliaryDataBodyRef = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  blob?: Maybe<Array<MetadatumRef>>;
  scripts?: Maybe<Array<ScriptRef>>;
};

export type AuxiliaryDataFilter = {
  and?: Maybe<Array<Maybe<AuxiliaryDataFilter>>>;
  has?: Maybe<Array<Maybe<AuxiliaryDataHasFilter>>>;
  not?: Maybe<AuxiliaryDataFilter>;
  or?: Maybe<Array<Maybe<AuxiliaryDataFilter>>>;
};

export enum AuxiliaryDataHasFilter {
  Body = 'body',
  Hash = 'hash',
  Transaction = 'transaction'
}

export type AuxiliaryDataOrder = {
  asc?: Maybe<AuxiliaryDataOrderable>;
  desc?: Maybe<AuxiliaryDataOrderable>;
  then?: Maybe<AuxiliaryDataOrder>;
};

export enum AuxiliaryDataOrderable {
  Hash = 'hash'
}

export type AuxiliaryDataPatch = {
  body?: Maybe<AuxiliaryDataBodyRef>;
  hash?: Maybe<Scalars['String']>;
  transaction?: Maybe<TransactionRef>;
};

export type AuxiliaryDataRef = {
  body?: Maybe<AuxiliaryDataBodyRef>;
  hash?: Maybe<Scalars['String']>;
  transaction?: Maybe<TransactionRef>;
};

export type Block = {
  __typename?: 'Block';
  blockNo: Scalars['Int'];
  confirmations: Scalars['Int'];
  epoch: Epoch;
  fees: Scalars['Int64'];
  hash: Scalars['String'];
  issuer: StakePool;
  nextBlock: Block;
  nextBlockProtocolVersion: ProtocolVersion;
  opCert: Scalars['String'];
  previousBlock: Block;
  size: Scalars['Int64'];
  slot: Slot;
  totalOutput: Scalars['Int64'];
  transactions: Array<Transaction>;
  transactionsAggregate?: Maybe<TransactionAggregateResult>;
};


export type BlockEpochArgs = {
  filter?: Maybe<EpochFilter>;
};


export type BlockIssuerArgs = {
  filter?: Maybe<StakePoolFilter>;
};


export type BlockNextBlockArgs = {
  filter?: Maybe<BlockFilter>;
};


export type BlockNextBlockProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
};


export type BlockPreviousBlockArgs = {
  filter?: Maybe<BlockFilter>;
};


export type BlockSlotArgs = {
  filter?: Maybe<SlotFilter>;
};


export type BlockTransactionsArgs = {
  filter?: Maybe<TransactionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOrder>;
};


export type BlockTransactionsAggregateArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type BlockAggregateResult = {
  __typename?: 'BlockAggregateResult';
  blockNoAvg?: Maybe<Scalars['Float']>;
  blockNoMax?: Maybe<Scalars['Int']>;
  blockNoMin?: Maybe<Scalars['Int']>;
  blockNoSum?: Maybe<Scalars['Int']>;
  confirmationsAvg?: Maybe<Scalars['Float']>;
  confirmationsMax?: Maybe<Scalars['Int']>;
  confirmationsMin?: Maybe<Scalars['Int']>;
  confirmationsSum?: Maybe<Scalars['Int']>;
  count?: Maybe<Scalars['Int']>;
  feesAvg?: Maybe<Scalars['Float']>;
  feesMax?: Maybe<Scalars['Int64']>;
  feesMin?: Maybe<Scalars['Int64']>;
  feesSum?: Maybe<Scalars['Int64']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
  opCertMax?: Maybe<Scalars['String']>;
  opCertMin?: Maybe<Scalars['String']>;
  sizeAvg?: Maybe<Scalars['Float']>;
  sizeMax?: Maybe<Scalars['Int64']>;
  sizeMin?: Maybe<Scalars['Int64']>;
  sizeSum?: Maybe<Scalars['Int64']>;
  totalOutputAvg?: Maybe<Scalars['Float']>;
  totalOutputMax?: Maybe<Scalars['Int64']>;
  totalOutputMin?: Maybe<Scalars['Int64']>;
  totalOutputSum?: Maybe<Scalars['Int64']>;
};

export type BlockFilter = {
  and?: Maybe<Array<Maybe<BlockFilter>>>;
  has?: Maybe<Array<Maybe<BlockHasFilter>>>;
  hash?: Maybe<StringHashFilter>;
  not?: Maybe<BlockFilter>;
  or?: Maybe<Array<Maybe<BlockFilter>>>;
};

export enum BlockHasFilter {
  BlockNo = 'blockNo',
  Confirmations = 'confirmations',
  Epoch = 'epoch',
  Fees = 'fees',
  Hash = 'hash',
  Issuer = 'issuer',
  NextBlock = 'nextBlock',
  NextBlockProtocolVersion = 'nextBlockProtocolVersion',
  OpCert = 'opCert',
  PreviousBlock = 'previousBlock',
  Size = 'size',
  Slot = 'slot',
  TotalOutput = 'totalOutput',
  Transactions = 'transactions'
}

export type BlockOrder = {
  asc?: Maybe<BlockOrderable>;
  desc?: Maybe<BlockOrderable>;
  then?: Maybe<BlockOrder>;
};

export enum BlockOrderable {
  BlockNo = 'blockNo',
  Confirmations = 'confirmations',
  Fees = 'fees',
  Hash = 'hash',
  OpCert = 'opCert',
  Size = 'size',
  TotalOutput = 'totalOutput'
}

export type BlockPatch = {
  blockNo?: Maybe<Scalars['Int']>;
  confirmations?: Maybe<Scalars['Int']>;
  epoch?: Maybe<EpochRef>;
  fees?: Maybe<Scalars['Int64']>;
  issuer?: Maybe<StakePoolRef>;
  nextBlock?: Maybe<BlockRef>;
  nextBlockProtocolVersion?: Maybe<ProtocolVersionRef>;
  opCert?: Maybe<Scalars['String']>;
  previousBlock?: Maybe<BlockRef>;
  size?: Maybe<Scalars['Int64']>;
  slot?: Maybe<SlotRef>;
  totalOutput?: Maybe<Scalars['Int64']>;
  transactions?: Maybe<Array<TransactionRef>>;
};

export type BlockRef = {
  blockNo?: Maybe<Scalars['Int']>;
  confirmations?: Maybe<Scalars['Int']>;
  epoch?: Maybe<EpochRef>;
  fees?: Maybe<Scalars['Int64']>;
  hash?: Maybe<Scalars['String']>;
  issuer?: Maybe<StakePoolRef>;
  nextBlock?: Maybe<BlockRef>;
  nextBlockProtocolVersion?: Maybe<ProtocolVersionRef>;
  opCert?: Maybe<Scalars['String']>;
  previousBlock?: Maybe<BlockRef>;
  size?: Maybe<Scalars['Int64']>;
  slot?: Maybe<SlotRef>;
  totalOutput?: Maybe<Scalars['Int64']>;
  transactions?: Maybe<Array<TransactionRef>>;
};

export type ByronBlockVersionData = {
  __typename?: 'ByronBlockVersionData';
  heavyDelThd: Scalars['String'];
  maxBlockSize: Scalars['Int'];
  maxHeaderSize: Scalars['Int'];
  maxProposalSize: Scalars['Int'];
  maxTxSize: Scalars['Int'];
  mpcThd: Scalars['String'];
  scriptVerson: Scalars['Int'];
  slotDuration: Scalars['Int'];
  softforkRule: ByronSoftForkRule;
  txFeePolicy: ByronTxFeePolicy;
  unlockStakeEpoch: Scalars['String'];
  updateImplicit: Scalars['String'];
  updateProposalThd: Scalars['String'];
  updateVoteThd: Scalars['String'];
};


export type ByronBlockVersionDataSoftforkRuleArgs = {
  filter?: Maybe<ByronSoftForkRuleFilter>;
};


export type ByronBlockVersionDataTxFeePolicyArgs = {
  filter?: Maybe<ByronTxFeePolicyFilter>;
};

export type ByronBlockVersionDataAggregateResult = {
  __typename?: 'ByronBlockVersionDataAggregateResult';
  count?: Maybe<Scalars['Int']>;
  heavyDelThdMax?: Maybe<Scalars['String']>;
  heavyDelThdMin?: Maybe<Scalars['String']>;
  maxBlockSizeAvg?: Maybe<Scalars['Float']>;
  maxBlockSizeMax?: Maybe<Scalars['Int']>;
  maxBlockSizeMin?: Maybe<Scalars['Int']>;
  maxBlockSizeSum?: Maybe<Scalars['Int']>;
  maxHeaderSizeAvg?: Maybe<Scalars['Float']>;
  maxHeaderSizeMax?: Maybe<Scalars['Int']>;
  maxHeaderSizeMin?: Maybe<Scalars['Int']>;
  maxHeaderSizeSum?: Maybe<Scalars['Int']>;
  maxProposalSizeAvg?: Maybe<Scalars['Float']>;
  maxProposalSizeMax?: Maybe<Scalars['Int']>;
  maxProposalSizeMin?: Maybe<Scalars['Int']>;
  maxProposalSizeSum?: Maybe<Scalars['Int']>;
  maxTxSizeAvg?: Maybe<Scalars['Float']>;
  maxTxSizeMax?: Maybe<Scalars['Int']>;
  maxTxSizeMin?: Maybe<Scalars['Int']>;
  maxTxSizeSum?: Maybe<Scalars['Int']>;
  mpcThdMax?: Maybe<Scalars['String']>;
  mpcThdMin?: Maybe<Scalars['String']>;
  scriptVersonAvg?: Maybe<Scalars['Float']>;
  scriptVersonMax?: Maybe<Scalars['Int']>;
  scriptVersonMin?: Maybe<Scalars['Int']>;
  scriptVersonSum?: Maybe<Scalars['Int']>;
  slotDurationAvg?: Maybe<Scalars['Float']>;
  slotDurationMax?: Maybe<Scalars['Int']>;
  slotDurationMin?: Maybe<Scalars['Int']>;
  slotDurationSum?: Maybe<Scalars['Int']>;
  unlockStakeEpochMax?: Maybe<Scalars['String']>;
  unlockStakeEpochMin?: Maybe<Scalars['String']>;
  updateImplicitMax?: Maybe<Scalars['String']>;
  updateImplicitMin?: Maybe<Scalars['String']>;
  updateProposalThdMax?: Maybe<Scalars['String']>;
  updateProposalThdMin?: Maybe<Scalars['String']>;
  updateVoteThdMax?: Maybe<Scalars['String']>;
  updateVoteThdMin?: Maybe<Scalars['String']>;
};

export type ByronBlockVersionDataFilter = {
  and?: Maybe<Array<Maybe<ByronBlockVersionDataFilter>>>;
  has?: Maybe<Array<Maybe<ByronBlockVersionDataHasFilter>>>;
  not?: Maybe<ByronBlockVersionDataFilter>;
  or?: Maybe<Array<Maybe<ByronBlockVersionDataFilter>>>;
};

export enum ByronBlockVersionDataHasFilter {
  HeavyDelThd = 'heavyDelThd',
  MaxBlockSize = 'maxBlockSize',
  MaxHeaderSize = 'maxHeaderSize',
  MaxProposalSize = 'maxProposalSize',
  MaxTxSize = 'maxTxSize',
  MpcThd = 'mpcThd',
  ScriptVerson = 'scriptVerson',
  SlotDuration = 'slotDuration',
  SoftforkRule = 'softforkRule',
  TxFeePolicy = 'txFeePolicy',
  UnlockStakeEpoch = 'unlockStakeEpoch',
  UpdateImplicit = 'updateImplicit',
  UpdateProposalThd = 'updateProposalThd',
  UpdateVoteThd = 'updateVoteThd'
}

export type ByronBlockVersionDataOrder = {
  asc?: Maybe<ByronBlockVersionDataOrderable>;
  desc?: Maybe<ByronBlockVersionDataOrderable>;
  then?: Maybe<ByronBlockVersionDataOrder>;
};

export enum ByronBlockVersionDataOrderable {
  HeavyDelThd = 'heavyDelThd',
  MaxBlockSize = 'maxBlockSize',
  MaxHeaderSize = 'maxHeaderSize',
  MaxProposalSize = 'maxProposalSize',
  MaxTxSize = 'maxTxSize',
  MpcThd = 'mpcThd',
  ScriptVerson = 'scriptVerson',
  SlotDuration = 'slotDuration',
  UnlockStakeEpoch = 'unlockStakeEpoch',
  UpdateImplicit = 'updateImplicit',
  UpdateProposalThd = 'updateProposalThd',
  UpdateVoteThd = 'updateVoteThd'
}

export type ByronBlockVersionDataPatch = {
  heavyDelThd?: Maybe<Scalars['String']>;
  maxBlockSize?: Maybe<Scalars['Int']>;
  maxHeaderSize?: Maybe<Scalars['Int']>;
  maxProposalSize?: Maybe<Scalars['Int']>;
  maxTxSize?: Maybe<Scalars['Int']>;
  mpcThd?: Maybe<Scalars['String']>;
  scriptVerson?: Maybe<Scalars['Int']>;
  slotDuration?: Maybe<Scalars['Int']>;
  softforkRule?: Maybe<ByronSoftForkRuleRef>;
  txFeePolicy?: Maybe<ByronTxFeePolicyRef>;
  unlockStakeEpoch?: Maybe<Scalars['String']>;
  updateImplicit?: Maybe<Scalars['String']>;
  updateProposalThd?: Maybe<Scalars['String']>;
  updateVoteThd?: Maybe<Scalars['String']>;
};

export type ByronBlockVersionDataRef = {
  heavyDelThd?: Maybe<Scalars['String']>;
  maxBlockSize?: Maybe<Scalars['Int']>;
  maxHeaderSize?: Maybe<Scalars['Int']>;
  maxProposalSize?: Maybe<Scalars['Int']>;
  maxTxSize?: Maybe<Scalars['Int']>;
  mpcThd?: Maybe<Scalars['String']>;
  scriptVerson?: Maybe<Scalars['Int']>;
  slotDuration?: Maybe<Scalars['Int']>;
  softforkRule?: Maybe<ByronSoftForkRuleRef>;
  txFeePolicy?: Maybe<ByronTxFeePolicyRef>;
  unlockStakeEpoch?: Maybe<Scalars['String']>;
  updateImplicit?: Maybe<Scalars['String']>;
  updateProposalThd?: Maybe<Scalars['String']>;
  updateVoteThd?: Maybe<Scalars['String']>;
};

export type ByronGenesis = {
  __typename?: 'ByronGenesis';
  avvmDistr: Scalars['String'];
  blockVersionData: ByronBlockVersionData;
  bootStakeholders: Scalars['String'];
  heavyDelegation: Scalars['String'];
  nonAvvmBalances: Scalars['String'];
  protocolConsts: ByronProtocolConsts;
  startTime: Scalars['DateTime'];
};


export type ByronGenesisBlockVersionDataArgs = {
  filter?: Maybe<ByronBlockVersionDataFilter>;
};


export type ByronGenesisProtocolConstsArgs = {
  filter?: Maybe<ByronProtocolConstsFilter>;
};

export type ByronGenesisAggregateResult = {
  __typename?: 'ByronGenesisAggregateResult';
  avvmDistrMax?: Maybe<Scalars['String']>;
  avvmDistrMin?: Maybe<Scalars['String']>;
  bootStakeholdersMax?: Maybe<Scalars['String']>;
  bootStakeholdersMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  heavyDelegationMax?: Maybe<Scalars['String']>;
  heavyDelegationMin?: Maybe<Scalars['String']>;
  nonAvvmBalancesMax?: Maybe<Scalars['String']>;
  nonAvvmBalancesMin?: Maybe<Scalars['String']>;
  startTimeMax?: Maybe<Scalars['DateTime']>;
  startTimeMin?: Maybe<Scalars['DateTime']>;
};

export type ByronGenesisFilter = {
  and?: Maybe<Array<Maybe<ByronGenesisFilter>>>;
  has?: Maybe<Array<Maybe<ByronGenesisHasFilter>>>;
  not?: Maybe<ByronGenesisFilter>;
  or?: Maybe<Array<Maybe<ByronGenesisFilter>>>;
};

export enum ByronGenesisHasFilter {
  AvvmDistr = 'avvmDistr',
  BlockVersionData = 'blockVersionData',
  BootStakeholders = 'bootStakeholders',
  HeavyDelegation = 'heavyDelegation',
  NonAvvmBalances = 'nonAvvmBalances',
  ProtocolConsts = 'protocolConsts',
  StartTime = 'startTime'
}

export type ByronGenesisOrder = {
  asc?: Maybe<ByronGenesisOrderable>;
  desc?: Maybe<ByronGenesisOrderable>;
  then?: Maybe<ByronGenesisOrder>;
};

export enum ByronGenesisOrderable {
  AvvmDistr = 'avvmDistr',
  BootStakeholders = 'bootStakeholders',
  HeavyDelegation = 'heavyDelegation',
  NonAvvmBalances = 'nonAvvmBalances',
  StartTime = 'startTime'
}

export type ByronGenesisPatch = {
  avvmDistr?: Maybe<Scalars['String']>;
  blockVersionData?: Maybe<ByronBlockVersionDataRef>;
  bootStakeholders?: Maybe<Scalars['String']>;
  heavyDelegation?: Maybe<Scalars['String']>;
  nonAvvmBalances?: Maybe<Scalars['String']>;
  protocolConsts?: Maybe<ByronProtocolConstsRef>;
  startTime?: Maybe<Scalars['DateTime']>;
};

export type ByronGenesisRef = {
  avvmDistr?: Maybe<Scalars['String']>;
  blockVersionData?: Maybe<ByronBlockVersionDataRef>;
  bootStakeholders?: Maybe<Scalars['String']>;
  heavyDelegation?: Maybe<Scalars['String']>;
  nonAvvmBalances?: Maybe<Scalars['String']>;
  protocolConsts?: Maybe<ByronProtocolConstsRef>;
  startTime?: Maybe<Scalars['DateTime']>;
};

export type ByronProtocolConsts = {
  __typename?: 'ByronProtocolConsts';
  k: Scalars['Int'];
  protocolMagic?: Maybe<Scalars['Int']>;
};

export type ByronProtocolConstsAggregateResult = {
  __typename?: 'ByronProtocolConstsAggregateResult';
  count?: Maybe<Scalars['Int']>;
  kAvg?: Maybe<Scalars['Float']>;
  kMax?: Maybe<Scalars['Int']>;
  kMin?: Maybe<Scalars['Int']>;
  kSum?: Maybe<Scalars['Int']>;
  protocolMagicAvg?: Maybe<Scalars['Float']>;
  protocolMagicMax?: Maybe<Scalars['Int']>;
  protocolMagicMin?: Maybe<Scalars['Int']>;
  protocolMagicSum?: Maybe<Scalars['Int']>;
};

export type ByronProtocolConstsFilter = {
  and?: Maybe<Array<Maybe<ByronProtocolConstsFilter>>>;
  has?: Maybe<Array<Maybe<ByronProtocolConstsHasFilter>>>;
  not?: Maybe<ByronProtocolConstsFilter>;
  or?: Maybe<Array<Maybe<ByronProtocolConstsFilter>>>;
};

export enum ByronProtocolConstsHasFilter {
  K = 'k',
  ProtocolMagic = 'protocolMagic'
}

export type ByronProtocolConstsOrder = {
  asc?: Maybe<ByronProtocolConstsOrderable>;
  desc?: Maybe<ByronProtocolConstsOrderable>;
  then?: Maybe<ByronProtocolConstsOrder>;
};

export enum ByronProtocolConstsOrderable {
  K = 'k',
  ProtocolMagic = 'protocolMagic'
}

export type ByronProtocolConstsPatch = {
  k?: Maybe<Scalars['Int']>;
  protocolMagic?: Maybe<Scalars['Int']>;
};

export type ByronProtocolConstsRef = {
  k?: Maybe<Scalars['Int']>;
  protocolMagic?: Maybe<Scalars['Int']>;
};

export type ByronSoftForkRule = {
  __typename?: 'ByronSoftForkRule';
  initThd: Scalars['String'];
  minThd: Scalars['String'];
  thdDecrement: Scalars['String'];
};

export type ByronSoftForkRuleAggregateResult = {
  __typename?: 'ByronSoftForkRuleAggregateResult';
  count?: Maybe<Scalars['Int']>;
  initThdMax?: Maybe<Scalars['String']>;
  initThdMin?: Maybe<Scalars['String']>;
  minThdMax?: Maybe<Scalars['String']>;
  minThdMin?: Maybe<Scalars['String']>;
  thdDecrementMax?: Maybe<Scalars['String']>;
  thdDecrementMin?: Maybe<Scalars['String']>;
};

export type ByronSoftForkRuleFilter = {
  and?: Maybe<Array<Maybe<ByronSoftForkRuleFilter>>>;
  has?: Maybe<Array<Maybe<ByronSoftForkRuleHasFilter>>>;
  not?: Maybe<ByronSoftForkRuleFilter>;
  or?: Maybe<Array<Maybe<ByronSoftForkRuleFilter>>>;
};

export enum ByronSoftForkRuleHasFilter {
  InitThd = 'initThd',
  MinThd = 'minThd',
  ThdDecrement = 'thdDecrement'
}

export type ByronSoftForkRuleOrder = {
  asc?: Maybe<ByronSoftForkRuleOrderable>;
  desc?: Maybe<ByronSoftForkRuleOrderable>;
  then?: Maybe<ByronSoftForkRuleOrder>;
};

export enum ByronSoftForkRuleOrderable {
  InitThd = 'initThd',
  MinThd = 'minThd',
  ThdDecrement = 'thdDecrement'
}

export type ByronSoftForkRulePatch = {
  initThd?: Maybe<Scalars['String']>;
  minThd?: Maybe<Scalars['String']>;
  thdDecrement?: Maybe<Scalars['String']>;
};

export type ByronSoftForkRuleRef = {
  initThd?: Maybe<Scalars['String']>;
  minThd?: Maybe<Scalars['String']>;
  thdDecrement?: Maybe<Scalars['String']>;
};

export type ByronTxFeePolicy = {
  __typename?: 'ByronTxFeePolicy';
  minThd: Scalars['String'];
  summand: Scalars['String'];
};

export type ByronTxFeePolicyAggregateResult = {
  __typename?: 'ByronTxFeePolicyAggregateResult';
  count?: Maybe<Scalars['Int']>;
  minThdMax?: Maybe<Scalars['String']>;
  minThdMin?: Maybe<Scalars['String']>;
  summandMax?: Maybe<Scalars['String']>;
  summandMin?: Maybe<Scalars['String']>;
};

export type ByronTxFeePolicyFilter = {
  and?: Maybe<Array<Maybe<ByronTxFeePolicyFilter>>>;
  has?: Maybe<Array<Maybe<ByronTxFeePolicyHasFilter>>>;
  not?: Maybe<ByronTxFeePolicyFilter>;
  or?: Maybe<Array<Maybe<ByronTxFeePolicyFilter>>>;
};

export enum ByronTxFeePolicyHasFilter {
  MinThd = 'minThd',
  Summand = 'summand'
}

export type ByronTxFeePolicyOrder = {
  asc?: Maybe<ByronTxFeePolicyOrderable>;
  desc?: Maybe<ByronTxFeePolicyOrderable>;
  then?: Maybe<ByronTxFeePolicyOrder>;
};

export enum ByronTxFeePolicyOrderable {
  MinThd = 'minThd',
  Summand = 'summand'
}

export type ByronTxFeePolicyPatch = {
  minThd?: Maybe<Scalars['String']>;
  summand?: Maybe<Scalars['String']>;
};

export type ByronTxFeePolicyRef = {
  minThd?: Maybe<Scalars['String']>;
  summand?: Maybe<Scalars['String']>;
};

export type BytesMetadatum = {
  __typename?: 'BytesMetadatum';
  value: Scalars['String'];
  valueType: MetadatumStringType;
};

export type BytesMetadatumAggregateResult = {
  __typename?: 'BytesMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  valueMax?: Maybe<Scalars['String']>;
  valueMin?: Maybe<Scalars['String']>;
};

export type BytesMetadatumFilter = {
  and?: Maybe<Array<Maybe<BytesMetadatumFilter>>>;
  has?: Maybe<Array<Maybe<BytesMetadatumHasFilter>>>;
  not?: Maybe<BytesMetadatumFilter>;
  or?: Maybe<Array<Maybe<BytesMetadatumFilter>>>;
};

export enum BytesMetadatumHasFilter {
  Value = 'value',
  ValueType = 'valueType'
}

export type BytesMetadatumOrder = {
  asc?: Maybe<BytesMetadatumOrderable>;
  desc?: Maybe<BytesMetadatumOrderable>;
  then?: Maybe<BytesMetadatumOrder>;
};

export enum BytesMetadatumOrderable {
  Value = 'value'
}

export type BytesMetadatumPatch = {
  value?: Maybe<Scalars['String']>;
  valueType?: Maybe<MetadatumStringType>;
};

export type BytesMetadatumRef = {
  value?: Maybe<Scalars['String']>;
  valueType?: Maybe<MetadatumStringType>;
};

export type ContainsFilter = {
  point?: Maybe<PointRef>;
  polygon?: Maybe<PolygonRef>;
};

export type CustomHttp = {
  body?: Maybe<Scalars['String']>;
  forwardHeaders?: Maybe<Array<Scalars['String']>>;
  graphql?: Maybe<Scalars['String']>;
  introspectionHeaders?: Maybe<Array<Scalars['String']>>;
  method: HttpMethod;
  mode?: Maybe<Mode>;
  secretHeaders?: Maybe<Array<Scalars['String']>>;
  skipIntrospection?: Maybe<Scalars['Boolean']>;
  url: Scalars['String'];
};

export type DateTimeFilter = {
  between?: Maybe<DateTimeRange>;
  eq?: Maybe<Scalars['DateTime']>;
  ge?: Maybe<Scalars['DateTime']>;
  gt?: Maybe<Scalars['DateTime']>;
  in?: Maybe<Array<Maybe<Scalars['DateTime']>>>;
  le?: Maybe<Scalars['DateTime']>;
  lt?: Maybe<Scalars['DateTime']>;
};

export type DateTimeRange = {
  max: Scalars['DateTime'];
  min: Scalars['DateTime'];
};

export type DeleteActiveStakePayload = {
  __typename?: 'DeleteActiveStakePayload';
  activeStake?: Maybe<Array<Maybe<ActiveStake>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteActiveStakePayloadActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ActiveStakeOrder>;
};

export type DeleteAdaPayload = {
  __typename?: 'DeleteAdaPayload';
  ada?: Maybe<Array<Maybe<Ada>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAdaPayloadAdaArgs = {
  filter?: Maybe<AdaFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteAdaPotsPayload = {
  __typename?: 'DeleteAdaPotsPayload';
  adaPots?: Maybe<Array<Maybe<AdaPots>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAdaPotsPayloadAdaPotsArgs = {
  filter?: Maybe<AdaPotsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AdaPotsOrder>;
};

export type DeleteAddressPayload = {
  __typename?: 'DeleteAddressPayload';
  address?: Maybe<Array<Maybe<Address>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAddressPayloadAddressArgs = {
  filter?: Maybe<AddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AddressOrder>;
};

export type DeleteAlonzoGenesisPayload = {
  __typename?: 'DeleteAlonzoGenesisPayload';
  alonzoGenesis?: Maybe<Array<Maybe<AlonzoGenesis>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAlonzoGenesisPayloadAlonzoGenesisArgs = {
  filter?: Maybe<AlonzoGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AlonzoGenesisOrder>;
};

export type DeleteAssetPayload = {
  __typename?: 'DeleteAssetPayload';
  asset?: Maybe<Array<Maybe<Asset>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAssetPayloadAssetArgs = {
  filter?: Maybe<AssetFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetOrder>;
};

export type DeleteAssetSupplyPayload = {
  __typename?: 'DeleteAssetSupplyPayload';
  assetSupply?: Maybe<Array<Maybe<AssetSupply>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAssetSupplyPayloadAssetSupplyArgs = {
  filter?: Maybe<AssetSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetSupplyOrder>;
};

export type DeleteAuxiliaryDataBodyPayload = {
  __typename?: 'DeleteAuxiliaryDataBodyPayload';
  auxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAuxiliaryDataBodyPayloadAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteAuxiliaryDataPayload = {
  __typename?: 'DeleteAuxiliaryDataPayload';
  auxiliaryData?: Maybe<Array<Maybe<AuxiliaryData>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAuxiliaryDataPayloadAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AuxiliaryDataOrder>;
};

export type DeleteBlockPayload = {
  __typename?: 'DeleteBlockPayload';
  block?: Maybe<Array<Maybe<Block>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteBlockPayloadBlockArgs = {
  filter?: Maybe<BlockFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BlockOrder>;
};

export type DeleteByronBlockVersionDataPayload = {
  __typename?: 'DeleteByronBlockVersionDataPayload';
  byronBlockVersionData?: Maybe<Array<Maybe<ByronBlockVersionData>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteByronBlockVersionDataPayloadByronBlockVersionDataArgs = {
  filter?: Maybe<ByronBlockVersionDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronBlockVersionDataOrder>;
};

export type DeleteByronGenesisPayload = {
  __typename?: 'DeleteByronGenesisPayload';
  byronGenesis?: Maybe<Array<Maybe<ByronGenesis>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteByronGenesisPayloadByronGenesisArgs = {
  filter?: Maybe<ByronGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronGenesisOrder>;
};

export type DeleteByronProtocolConstsPayload = {
  __typename?: 'DeleteByronProtocolConstsPayload';
  byronProtocolConsts?: Maybe<Array<Maybe<ByronProtocolConsts>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteByronProtocolConstsPayloadByronProtocolConstsArgs = {
  filter?: Maybe<ByronProtocolConstsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronProtocolConstsOrder>;
};

export type DeleteByronSoftForkRulePayload = {
  __typename?: 'DeleteByronSoftForkRulePayload';
  byronSoftForkRule?: Maybe<Array<Maybe<ByronSoftForkRule>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteByronSoftForkRulePayloadByronSoftForkRuleArgs = {
  filter?: Maybe<ByronSoftForkRuleFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronSoftForkRuleOrder>;
};

export type DeleteByronTxFeePolicyPayload = {
  __typename?: 'DeleteByronTxFeePolicyPayload';
  byronTxFeePolicy?: Maybe<Array<Maybe<ByronTxFeePolicy>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteByronTxFeePolicyPayloadByronTxFeePolicyArgs = {
  filter?: Maybe<ByronTxFeePolicyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronTxFeePolicyOrder>;
};

export type DeleteBytesMetadatumPayload = {
  __typename?: 'DeleteBytesMetadatumPayload';
  bytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteBytesMetadatumPayloadBytesMetadatumArgs = {
  filter?: Maybe<BytesMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BytesMetadatumOrder>;
};

export type DeleteEpochPayload = {
  __typename?: 'DeleteEpochPayload';
  epoch?: Maybe<Array<Maybe<Epoch>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteEpochPayloadEpochArgs = {
  filter?: Maybe<EpochFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<EpochOrder>;
};

export type DeleteExecutionPricePayload = {
  __typename?: 'DeleteExecutionPricePayload';
  executionPrice?: Maybe<Array<Maybe<ExecutionPrice>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExecutionPricePayloadExecutionPriceArgs = {
  filter?: Maybe<ExecutionPriceFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionPriceOrder>;
};

export type DeleteExecutionPricesPayload = {
  __typename?: 'DeleteExecutionPricesPayload';
  executionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExecutionPricesPayloadExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteExecutionUnitsPayload = {
  __typename?: 'DeleteExecutionUnitsPayload';
  executionUnits?: Maybe<Array<Maybe<ExecutionUnits>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExecutionUnitsPayloadExecutionUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionUnitsOrder>;
};

export type DeleteExtendedStakePoolMetadataFieldsPayload = {
  __typename?: 'DeleteExtendedStakePoolMetadataFieldsPayload';
  extendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExtendedStakePoolMetadataFieldsPayloadExtendedStakePoolMetadataFieldsArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataFieldsOrder>;
};

export type DeleteExtendedStakePoolMetadataPayload = {
  __typename?: 'DeleteExtendedStakePoolMetadataPayload';
  extendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExtendedStakePoolMetadataPayloadExtendedStakePoolMetadataArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataOrder>;
};

export type DeleteFractionPayload = {
  __typename?: 'DeleteFractionPayload';
  fraction?: Maybe<Array<Maybe<Fraction>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteFractionPayloadFractionArgs = {
  filter?: Maybe<FractionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<FractionOrder>;
};

export type DeleteGenesisPayload = {
  __typename?: 'DeleteGenesisPayload';
  genesis?: Maybe<Array<Maybe<Genesis>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteGenesisPayloadGenesisArgs = {
  filter?: Maybe<GenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteItnVerificationPayload = {
  __typename?: 'DeleteITNVerificationPayload';
  iTNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteItnVerificationPayloadITnVerificationArgs = {
  filter?: Maybe<ItnVerificationFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ItnVerificationOrder>;
};

export type DeleteIntegerMetadatumPayload = {
  __typename?: 'DeleteIntegerMetadatumPayload';
  integerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteIntegerMetadatumPayloadIntegerMetadatumArgs = {
  filter?: Maybe<IntegerMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<IntegerMetadatumOrder>;
};

export type DeleteKeyValueMetadatumPayload = {
  __typename?: 'DeleteKeyValueMetadatumPayload';
  keyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteKeyValueMetadatumPayloadKeyValueMetadatumArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<KeyValueMetadatumOrder>;
};

export type DeleteMetadatumArrayPayload = {
  __typename?: 'DeleteMetadatumArrayPayload';
  metadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteMetadatumArrayPayloadMetadatumArrayArgs = {
  filter?: Maybe<MetadatumArrayFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteMetadatumMapPayload = {
  __typename?: 'DeleteMetadatumMapPayload';
  metadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteMetadatumMapPayloadMetadatumMapArgs = {
  filter?: Maybe<MetadatumMapFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeletePoolContactDataPayload = {
  __typename?: 'DeletePoolContactDataPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
};


export type DeletePoolContactDataPayloadPoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolContactDataOrder>;
};

export type DeleteProtocolParametersPayload = {
  __typename?: 'DeleteProtocolParametersPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  protocolParameters?: Maybe<Array<Maybe<ProtocolParameters>>>;
};


export type DeleteProtocolParametersPayloadProtocolParametersArgs = {
  filter?: Maybe<ProtocolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersOrder>;
};

export type DeleteProtocolVersionPayload = {
  __typename?: 'DeleteProtocolVersionPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
};


export type DeleteProtocolVersionPayloadProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolVersionOrder>;
};

export type DeleteRedeemerPayload = {
  __typename?: 'DeleteRedeemerPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<Array<Maybe<Redeemer>>>;
};


export type DeleteRedeemerPayloadRedeemerArgs = {
  filter?: Maybe<RedeemerFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RedeemerOrder>;
};

export type DeleteRelayByAddressPayload = {
  __typename?: 'DeleteRelayByAddressPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  relayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
};


export type DeleteRelayByAddressPayloadRelayByAddressArgs = {
  filter?: Maybe<RelayByAddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByAddressOrder>;
};

export type DeleteRelayByNameMultihostPayload = {
  __typename?: 'DeleteRelayByNameMultihostPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  relayByNameMultihost?: Maybe<Array<Maybe<RelayByNameMultihost>>>;
};


export type DeleteRelayByNameMultihostPayloadRelayByNameMultihostArgs = {
  filter?: Maybe<RelayByNameMultihostFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameMultihostOrder>;
};

export type DeleteRelayByNamePayload = {
  __typename?: 'DeleteRelayByNamePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  relayByName?: Maybe<Array<Maybe<RelayByName>>>;
};


export type DeleteRelayByNamePayloadRelayByNameArgs = {
  filter?: Maybe<RelayByNameFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameOrder>;
};

export type DeleteRewardAccountPayload = {
  __typename?: 'DeleteRewardAccountPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  rewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
};


export type DeleteRewardAccountPayloadRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RewardAccountOrder>;
};

export type DeleteScriptPayload = {
  __typename?: 'DeleteScriptPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  script?: Maybe<Array<Maybe<Script>>>;
};


export type DeleteScriptPayloadScriptArgs = {
  filter?: Maybe<ScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ScriptOrder>;
};

export type DeleteShelleyGenesisPayload = {
  __typename?: 'DeleteShelleyGenesisPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  shelleyGenesis?: Maybe<Array<Maybe<ShelleyGenesis>>>;
};


export type DeleteShelleyGenesisPayloadShelleyGenesisArgs = {
  filter?: Maybe<ShelleyGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisOrder>;
};

export type DeleteShelleyGenesisStakingPayload = {
  __typename?: 'DeleteShelleyGenesisStakingPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  shelleyGenesisStaking?: Maybe<Array<Maybe<ShelleyGenesisStaking>>>;
};


export type DeleteShelleyGenesisStakingPayloadShelleyGenesisStakingArgs = {
  filter?: Maybe<ShelleyGenesisStakingFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisStakingOrder>;
};

export type DeleteSlotPayload = {
  __typename?: 'DeleteSlotPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  slot?: Maybe<Array<Maybe<Slot>>>;
};


export type DeleteSlotPayloadSlotArgs = {
  filter?: Maybe<SlotFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SlotOrder>;
};

export type DeleteStakePoolMetadataJsonPayload = {
  __typename?: 'DeleteStakePoolMetadataJsonPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
};


export type DeleteStakePoolMetadataJsonPayloadStakePoolMetadataJsonArgs = {
  filter?: Maybe<StakePoolMetadataJsonFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataJsonOrder>;
};

export type DeleteStakePoolMetadataPayload = {
  __typename?: 'DeleteStakePoolMetadataPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
};


export type DeleteStakePoolMetadataPayloadStakePoolMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataOrder>;
};

export type DeleteStakePoolMetricsPayload = {
  __typename?: 'DeleteStakePoolMetricsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
};


export type DeleteStakePoolMetricsPayloadStakePoolMetricsArgs = {
  filter?: Maybe<StakePoolMetricsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsOrder>;
};

export type DeleteStakePoolMetricsSizePayload = {
  __typename?: 'DeleteStakePoolMetricsSizePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
};


export type DeleteStakePoolMetricsSizePayloadStakePoolMetricsSizeArgs = {
  filter?: Maybe<StakePoolMetricsSizeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsSizeOrder>;
};

export type DeleteStakePoolMetricsStakePayload = {
  __typename?: 'DeleteStakePoolMetricsStakePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
};


export type DeleteStakePoolMetricsStakePayloadStakePoolMetricsStakeArgs = {
  filter?: Maybe<StakePoolMetricsStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsStakeOrder>;
};

export type DeleteStakePoolPayload = {
  __typename?: 'DeleteStakePoolPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<Array<Maybe<StakePool>>>;
};


export type DeleteStakePoolPayloadStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolOrder>;
};

export type DeleteStakePoolTransactionsPayload = {
  __typename?: 'DeleteStakePoolTransactionsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolTransactions?: Maybe<Array<Maybe<StakePoolTransactions>>>;
};


export type DeleteStakePoolTransactionsPayloadStakePoolTransactionsArgs = {
  filter?: Maybe<StakePoolTransactionsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteStringMetadatumPayload = {
  __typename?: 'DeleteStringMetadatumPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
};


export type DeleteStringMetadatumPayloadStringMetadatumArgs = {
  filter?: Maybe<StringMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StringMetadatumOrder>;
};

export type DeleteThePoolsMediaAssetsPayload = {
  __typename?: 'DeleteThePoolsMediaAssetsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  thePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
};


export type DeleteThePoolsMediaAssetsPayloadThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ThePoolsMediaAssetsOrder>;
};

export type DeleteTokenPayload = {
  __typename?: 'DeleteTokenPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  token?: Maybe<Array<Maybe<Token>>>;
};


export type DeleteTokenPayloadTokenArgs = {
  filter?: Maybe<TokenFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TokenOrder>;
};

export type DeleteTransactionInputPayload = {
  __typename?: 'DeleteTransactionInputPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  transactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
};


export type DeleteTransactionInputPayloadTransactionInputArgs = {
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};

export type DeleteTransactionOutputPayload = {
  __typename?: 'DeleteTransactionOutputPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  transactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
};


export type DeleteTransactionOutputPayloadTransactionOutputArgs = {
  filter?: Maybe<TransactionOutputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOutputOrder>;
};

export type DeleteTransactionPayload = {
  __typename?: 'DeleteTransactionPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  transaction?: Maybe<Array<Maybe<Transaction>>>;
};


export type DeleteTransactionPayloadTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOrder>;
};

export type DeleteValuePayload = {
  __typename?: 'DeleteValuePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  value?: Maybe<Array<Maybe<Value>>>;
};


export type DeleteValuePayloadValueArgs = {
  filter?: Maybe<ValueFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ValueOrder>;
};

export type DeleteWithdrawalPayload = {
  __typename?: 'DeleteWithdrawalPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  withdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
};


export type DeleteWithdrawalPayloadWithdrawalArgs = {
  filter?: Maybe<WithdrawalFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WithdrawalOrder>;
};

export enum DgraphIndex {
  Bool = 'bool',
  Day = 'day',
  Exact = 'exact',
  Float = 'float',
  Fulltext = 'fulltext',
  Geo = 'geo',
  Hash = 'hash',
  Hour = 'hour',
  Int = 'int',
  Int64 = 'int64',
  Month = 'month',
  Regexp = 'regexp',
  Term = 'term',
  Trigram = 'trigram',
  Year = 'year'
}

export type Epoch = {
  __typename?: 'Epoch';
  activeStake: Array<ActiveStake>;
  activeStakeAggregate?: Maybe<ActiveStakeAggregateResult>;
  adaPots: AdaPots;
  blocks: Array<Block>;
  blocksAggregate?: Maybe<BlockAggregateResult>;
  endedAt: Slot;
  fees: Scalars['Int64'];
  nonce: Scalars['String'];
  number: Scalars['Int'];
  output: Scalars['Int64'];
  protocolParams: ProtocolParameters;
  startedAt: Slot;
};


export type EpochActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ActiveStakeOrder>;
};


export type EpochActiveStakeAggregateArgs = {
  filter?: Maybe<ActiveStakeFilter>;
};


export type EpochAdaPotsArgs = {
  filter?: Maybe<AdaPotsFilter>;
};


export type EpochBlocksArgs = {
  filter?: Maybe<BlockFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BlockOrder>;
};


export type EpochBlocksAggregateArgs = {
  filter?: Maybe<BlockFilter>;
};


export type EpochEndedAtArgs = {
  filter?: Maybe<SlotFilter>;
};


export type EpochProtocolParamsArgs = {
  filter?: Maybe<ProtocolParametersFilter>;
};


export type EpochStartedAtArgs = {
  filter?: Maybe<SlotFilter>;
};

export type EpochAggregateResult = {
  __typename?: 'EpochAggregateResult';
  count?: Maybe<Scalars['Int']>;
  feesAvg?: Maybe<Scalars['Float']>;
  feesMax?: Maybe<Scalars['Int64']>;
  feesMin?: Maybe<Scalars['Int64']>;
  feesSum?: Maybe<Scalars['Int64']>;
  nonceMax?: Maybe<Scalars['String']>;
  nonceMin?: Maybe<Scalars['String']>;
  numberAvg?: Maybe<Scalars['Float']>;
  numberMax?: Maybe<Scalars['Int']>;
  numberMin?: Maybe<Scalars['Int']>;
  numberSum?: Maybe<Scalars['Int']>;
  outputAvg?: Maybe<Scalars['Float']>;
  outputMax?: Maybe<Scalars['Int64']>;
  outputMin?: Maybe<Scalars['Int64']>;
  outputSum?: Maybe<Scalars['Int64']>;
};

export type EpochFilter = {
  and?: Maybe<Array<Maybe<EpochFilter>>>;
  has?: Maybe<Array<Maybe<EpochHasFilter>>>;
  not?: Maybe<EpochFilter>;
  number?: Maybe<IntFilter>;
  or?: Maybe<Array<Maybe<EpochFilter>>>;
};

export enum EpochHasFilter {
  ActiveStake = 'activeStake',
  AdaPots = 'adaPots',
  Blocks = 'blocks',
  EndedAt = 'endedAt',
  Fees = 'fees',
  Nonce = 'nonce',
  Number = 'number',
  Output = 'output',
  ProtocolParams = 'protocolParams',
  StartedAt = 'startedAt'
}

export type EpochOrder = {
  asc?: Maybe<EpochOrderable>;
  desc?: Maybe<EpochOrderable>;
  then?: Maybe<EpochOrder>;
};

export enum EpochOrderable {
  Fees = 'fees',
  Nonce = 'nonce',
  Number = 'number',
  Output = 'output'
}

export type EpochPatch = {
  activeStake?: Maybe<Array<ActiveStakeRef>>;
  adaPots?: Maybe<AdaPotsRef>;
  blocks?: Maybe<Array<BlockRef>>;
  endedAt?: Maybe<SlotRef>;
  fees?: Maybe<Scalars['Int64']>;
  nonce?: Maybe<Scalars['String']>;
  output?: Maybe<Scalars['Int64']>;
  protocolParams?: Maybe<ProtocolParametersRef>;
  startedAt?: Maybe<SlotRef>;
};

export type EpochRef = {
  activeStake?: Maybe<Array<ActiveStakeRef>>;
  adaPots?: Maybe<AdaPotsRef>;
  blocks?: Maybe<Array<BlockRef>>;
  endedAt?: Maybe<SlotRef>;
  fees?: Maybe<Scalars['Int64']>;
  nonce?: Maybe<Scalars['String']>;
  number?: Maybe<Scalars['Int']>;
  output?: Maybe<Scalars['Int64']>;
  protocolParams?: Maybe<ProtocolParametersRef>;
  startedAt?: Maybe<SlotRef>;
};

export type ExecutionPrice = {
  __typename?: 'ExecutionPrice';
  denominator: Scalars['Int'];
  numerator: Scalars['Int'];
};

export type ExecutionPriceAggregateResult = {
  __typename?: 'ExecutionPriceAggregateResult';
  count?: Maybe<Scalars['Int']>;
  denominatorAvg?: Maybe<Scalars['Float']>;
  denominatorMax?: Maybe<Scalars['Int']>;
  denominatorMin?: Maybe<Scalars['Int']>;
  denominatorSum?: Maybe<Scalars['Int']>;
  numeratorAvg?: Maybe<Scalars['Float']>;
  numeratorMax?: Maybe<Scalars['Int']>;
  numeratorMin?: Maybe<Scalars['Int']>;
  numeratorSum?: Maybe<Scalars['Int']>;
};

export type ExecutionPriceFilter = {
  and?: Maybe<Array<Maybe<ExecutionPriceFilter>>>;
  has?: Maybe<Array<Maybe<ExecutionPriceHasFilter>>>;
  not?: Maybe<ExecutionPriceFilter>;
  or?: Maybe<Array<Maybe<ExecutionPriceFilter>>>;
};

export enum ExecutionPriceHasFilter {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type ExecutionPriceOrder = {
  asc?: Maybe<ExecutionPriceOrderable>;
  desc?: Maybe<ExecutionPriceOrderable>;
  then?: Maybe<ExecutionPriceOrder>;
};

export enum ExecutionPriceOrderable {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type ExecutionPricePatch = {
  denominator?: Maybe<Scalars['Int']>;
  numerator?: Maybe<Scalars['Int']>;
};

export type ExecutionPriceRef = {
  denominator?: Maybe<Scalars['Int']>;
  numerator?: Maybe<Scalars['Int']>;
};

export type ExecutionPrices = {
  __typename?: 'ExecutionPrices';
  prMem: ExecutionPrice;
  prSteps: ExecutionPrice;
};


export type ExecutionPricesPrMemArgs = {
  filter?: Maybe<ExecutionPriceFilter>;
};


export type ExecutionPricesPrStepsArgs = {
  filter?: Maybe<ExecutionPriceFilter>;
};

export type ExecutionPricesAggregateResult = {
  __typename?: 'ExecutionPricesAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type ExecutionPricesFilter = {
  and?: Maybe<Array<Maybe<ExecutionPricesFilter>>>;
  has?: Maybe<Array<Maybe<ExecutionPricesHasFilter>>>;
  not?: Maybe<ExecutionPricesFilter>;
  or?: Maybe<Array<Maybe<ExecutionPricesFilter>>>;
};

export enum ExecutionPricesHasFilter {
  PrMem = 'prMem',
  PrSteps = 'prSteps'
}

export type ExecutionPricesPatch = {
  prMem?: Maybe<ExecutionPriceRef>;
  prSteps?: Maybe<ExecutionPriceRef>;
};

export type ExecutionPricesRef = {
  prMem?: Maybe<ExecutionPriceRef>;
  prSteps?: Maybe<ExecutionPriceRef>;
};

export type ExecutionUnits = {
  __typename?: 'ExecutionUnits';
  memory: Scalars['Int'];
  steps: Scalars['Int'];
};

export type ExecutionUnitsAggregateResult = {
  __typename?: 'ExecutionUnitsAggregateResult';
  count?: Maybe<Scalars['Int']>;
  memoryAvg?: Maybe<Scalars['Float']>;
  memoryMax?: Maybe<Scalars['Int']>;
  memoryMin?: Maybe<Scalars['Int']>;
  memorySum?: Maybe<Scalars['Int']>;
  stepsAvg?: Maybe<Scalars['Float']>;
  stepsMax?: Maybe<Scalars['Int']>;
  stepsMin?: Maybe<Scalars['Int']>;
  stepsSum?: Maybe<Scalars['Int']>;
};

export type ExecutionUnitsFilter = {
  and?: Maybe<Array<Maybe<ExecutionUnitsFilter>>>;
  has?: Maybe<Array<Maybe<ExecutionUnitsHasFilter>>>;
  not?: Maybe<ExecutionUnitsFilter>;
  or?: Maybe<Array<Maybe<ExecutionUnitsFilter>>>;
};

export enum ExecutionUnitsHasFilter {
  Memory = 'memory',
  Steps = 'steps'
}

export type ExecutionUnitsOrder = {
  asc?: Maybe<ExecutionUnitsOrderable>;
  desc?: Maybe<ExecutionUnitsOrderable>;
  then?: Maybe<ExecutionUnitsOrder>;
};

export enum ExecutionUnitsOrderable {
  Memory = 'memory',
  Steps = 'steps'
}

export type ExecutionUnitsPatch = {
  memory?: Maybe<Scalars['Int']>;
  steps?: Maybe<Scalars['Int']>;
};

export type ExecutionUnitsRef = {
  memory?: Maybe<Scalars['Int']>;
  steps?: Maybe<Scalars['Int']>;
};

export enum ExtendedPoolStatus {
  Active = 'active',
  Experimental = 'experimental',
  Offline = 'offline',
  Private = 'private',
  Retired = 'retired'
}

export type ExtendedStakePoolMetadata = {
  __typename?: 'ExtendedStakePoolMetadata';
  metadata: StakePoolMetadata;
  pool: ExtendedStakePoolMetadataFields;
  serial: Scalars['Int'];
};


export type ExtendedStakePoolMetadataMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
};


export type ExtendedStakePoolMetadataPoolArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
};

export type ExtendedStakePoolMetadataAggregateResult = {
  __typename?: 'ExtendedStakePoolMetadataAggregateResult';
  count?: Maybe<Scalars['Int']>;
  serialAvg?: Maybe<Scalars['Float']>;
  serialMax?: Maybe<Scalars['Int']>;
  serialMin?: Maybe<Scalars['Int']>;
  serialSum?: Maybe<Scalars['Int']>;
};

export type ExtendedStakePoolMetadataFields = {
  __typename?: 'ExtendedStakePoolMetadataFields';
  contact?: Maybe<PoolContactData>;
  country?: Maybe<Scalars['String']>;
  id: Scalars['String'];
  itn?: Maybe<ItnVerification>;
  media_assets?: Maybe<ThePoolsMediaAssets>;
  /** active | retired | offline | experimental | private */
  status?: Maybe<ExtendedPoolStatus>;
};


export type ExtendedStakePoolMetadataFieldsContactArgs = {
  filter?: Maybe<PoolContactDataFilter>;
};


export type ExtendedStakePoolMetadataFieldsItnArgs = {
  filter?: Maybe<ItnVerificationFilter>;
};


export type ExtendedStakePoolMetadataFieldsMedia_AssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
};

export type ExtendedStakePoolMetadataFieldsAggregateResult = {
  __typename?: 'ExtendedStakePoolMetadataFieldsAggregateResult';
  count?: Maybe<Scalars['Int']>;
  countryMax?: Maybe<Scalars['String']>;
  countryMin?: Maybe<Scalars['String']>;
  idMax?: Maybe<Scalars['String']>;
  idMin?: Maybe<Scalars['String']>;
};

export type ExtendedStakePoolMetadataFieldsFilter = {
  and?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFieldsFilter>>>;
  has?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFieldsHasFilter>>>;
  id?: Maybe<StringHashFilter>;
  not?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
  or?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFieldsFilter>>>;
};

export enum ExtendedStakePoolMetadataFieldsHasFilter {
  Contact = 'contact',
  Country = 'country',
  Id = 'id',
  Itn = 'itn',
  MediaAssets = 'media_assets',
  Status = 'status'
}

export type ExtendedStakePoolMetadataFieldsOrder = {
  asc?: Maybe<ExtendedStakePoolMetadataFieldsOrderable>;
  desc?: Maybe<ExtendedStakePoolMetadataFieldsOrderable>;
  then?: Maybe<ExtendedStakePoolMetadataFieldsOrder>;
};

export enum ExtendedStakePoolMetadataFieldsOrderable {
  Country = 'country',
  Id = 'id'
}

export type ExtendedStakePoolMetadataFieldsPatch = {
  contact?: Maybe<PoolContactDataRef>;
  country?: Maybe<Scalars['String']>;
  itn?: Maybe<ItnVerificationRef>;
  media_assets?: Maybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: Maybe<ExtendedPoolStatus>;
};

export type ExtendedStakePoolMetadataFieldsRef = {
  contact?: Maybe<PoolContactDataRef>;
  country?: Maybe<Scalars['String']>;
  id?: Maybe<Scalars['String']>;
  itn?: Maybe<ItnVerificationRef>;
  media_assets?: Maybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: Maybe<ExtendedPoolStatus>;
};

export type ExtendedStakePoolMetadataFilter = {
  and?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFilter>>>;
  has?: Maybe<Array<Maybe<ExtendedStakePoolMetadataHasFilter>>>;
  not?: Maybe<ExtendedStakePoolMetadataFilter>;
  or?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFilter>>>;
};

export enum ExtendedStakePoolMetadataHasFilter {
  Metadata = 'metadata',
  Pool = 'pool',
  Serial = 'serial'
}

export type ExtendedStakePoolMetadataOrder = {
  asc?: Maybe<ExtendedStakePoolMetadataOrderable>;
  desc?: Maybe<ExtendedStakePoolMetadataOrderable>;
  then?: Maybe<ExtendedStakePoolMetadataOrder>;
};

export enum ExtendedStakePoolMetadataOrderable {
  Serial = 'serial'
}

export type ExtendedStakePoolMetadataPatch = {
  metadata?: Maybe<StakePoolMetadataRef>;
  pool?: Maybe<ExtendedStakePoolMetadataFieldsRef>;
  serial?: Maybe<Scalars['Int']>;
};

export type ExtendedStakePoolMetadataRef = {
  metadata?: Maybe<StakePoolMetadataRef>;
  pool?: Maybe<ExtendedStakePoolMetadataFieldsRef>;
  serial?: Maybe<Scalars['Int']>;
};

export type FloatFilter = {
  between?: Maybe<FloatRange>;
  eq?: Maybe<Scalars['Float']>;
  ge?: Maybe<Scalars['Float']>;
  gt?: Maybe<Scalars['Float']>;
  in?: Maybe<Array<Maybe<Scalars['Float']>>>;
  le?: Maybe<Scalars['Float']>;
  lt?: Maybe<Scalars['Float']>;
};

export type FloatRange = {
  max: Scalars['Float'];
  min: Scalars['Float'];
};

export type Fraction = {
  __typename?: 'Fraction';
  denominator: Scalars['Int'];
  numerator: Scalars['Int'];
};

export type FractionAggregateResult = {
  __typename?: 'FractionAggregateResult';
  count?: Maybe<Scalars['Int']>;
  denominatorAvg?: Maybe<Scalars['Float']>;
  denominatorMax?: Maybe<Scalars['Int']>;
  denominatorMin?: Maybe<Scalars['Int']>;
  denominatorSum?: Maybe<Scalars['Int']>;
  numeratorAvg?: Maybe<Scalars['Float']>;
  numeratorMax?: Maybe<Scalars['Int']>;
  numeratorMin?: Maybe<Scalars['Int']>;
  numeratorSum?: Maybe<Scalars['Int']>;
};

export type FractionFilter = {
  and?: Maybe<Array<Maybe<FractionFilter>>>;
  has?: Maybe<Array<Maybe<FractionHasFilter>>>;
  not?: Maybe<FractionFilter>;
  or?: Maybe<Array<Maybe<FractionFilter>>>;
};

export enum FractionHasFilter {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type FractionOrder = {
  asc?: Maybe<FractionOrderable>;
  desc?: Maybe<FractionOrderable>;
  then?: Maybe<FractionOrder>;
};

export enum FractionOrderable {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type FractionPatch = {
  denominator?: Maybe<Scalars['Int']>;
  numerator?: Maybe<Scalars['Int']>;
};

export type FractionRef = {
  denominator?: Maybe<Scalars['Int']>;
  numerator?: Maybe<Scalars['Int']>;
};

export type GenerateMutationParams = {
  add?: Maybe<Scalars['Boolean']>;
  delete?: Maybe<Scalars['Boolean']>;
  update?: Maybe<Scalars['Boolean']>;
};

export type GenerateQueryParams = {
  aggregate?: Maybe<Scalars['Boolean']>;
  get?: Maybe<Scalars['Boolean']>;
  password?: Maybe<Scalars['Boolean']>;
  query?: Maybe<Scalars['Boolean']>;
};

export type Genesis = {
  __typename?: 'Genesis';
  alonzo: AlonzoGenesis;
  byron: ByronGenesis;
  shelley: ShelleyGenesis;
};


export type GenesisAlonzoArgs = {
  filter?: Maybe<AlonzoGenesisFilter>;
};


export type GenesisByronArgs = {
  filter?: Maybe<ByronGenesisFilter>;
};


export type GenesisShelleyArgs = {
  filter?: Maybe<ShelleyGenesisFilter>;
};

export type GenesisAggregateResult = {
  __typename?: 'GenesisAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type GenesisFilter = {
  and?: Maybe<Array<Maybe<GenesisFilter>>>;
  has?: Maybe<Array<Maybe<GenesisHasFilter>>>;
  not?: Maybe<GenesisFilter>;
  or?: Maybe<Array<Maybe<GenesisFilter>>>;
};

export enum GenesisHasFilter {
  Alonzo = 'alonzo',
  Byron = 'byron',
  Shelley = 'shelley'
}

export type GenesisPatch = {
  alonzo?: Maybe<AlonzoGenesisRef>;
  byron?: Maybe<ByronGenesisRef>;
  shelley?: Maybe<ShelleyGenesisRef>;
};

export type GenesisRef = {
  alonzo?: Maybe<AlonzoGenesisRef>;
  byron?: Maybe<ByronGenesisRef>;
  shelley?: Maybe<ShelleyGenesisRef>;
};

export enum HttpMethod {
  Delete = 'DELETE',
  Get = 'GET',
  Patch = 'PATCH',
  Post = 'POST',
  Put = 'PUT'
}

export type ItnVerification = {
  __typename?: 'ITNVerification';
  owner: Scalars['String'];
  witness: Scalars['String'];
};

export type ItnVerificationAggregateResult = {
  __typename?: 'ITNVerificationAggregateResult';
  count?: Maybe<Scalars['Int']>;
  ownerMax?: Maybe<Scalars['String']>;
  ownerMin?: Maybe<Scalars['String']>;
  witnessMax?: Maybe<Scalars['String']>;
  witnessMin?: Maybe<Scalars['String']>;
};

export type ItnVerificationFilter = {
  and?: Maybe<Array<Maybe<ItnVerificationFilter>>>;
  has?: Maybe<Array<Maybe<ItnVerificationHasFilter>>>;
  not?: Maybe<ItnVerificationFilter>;
  or?: Maybe<Array<Maybe<ItnVerificationFilter>>>;
};

export enum ItnVerificationHasFilter {
  Owner = 'owner',
  Witness = 'witness'
}

export type ItnVerificationOrder = {
  asc?: Maybe<ItnVerificationOrderable>;
  desc?: Maybe<ItnVerificationOrderable>;
  then?: Maybe<ItnVerificationOrder>;
};

export enum ItnVerificationOrderable {
  Owner = 'owner',
  Witness = 'witness'
}

export type ItnVerificationPatch = {
  owner?: Maybe<Scalars['String']>;
  witness?: Maybe<Scalars['String']>;
};

export type ItnVerificationRef = {
  owner?: Maybe<Scalars['String']>;
  witness?: Maybe<Scalars['String']>;
};

export type Int64Filter = {
  between?: Maybe<Int64Range>;
  eq?: Maybe<Scalars['Int64']>;
  ge?: Maybe<Scalars['Int64']>;
  gt?: Maybe<Scalars['Int64']>;
  in?: Maybe<Array<Maybe<Scalars['Int64']>>>;
  le?: Maybe<Scalars['Int64']>;
  lt?: Maybe<Scalars['Int64']>;
};

export type Int64Range = {
  max: Scalars['Int64'];
  min: Scalars['Int64'];
};

export type IntFilter = {
  between?: Maybe<IntRange>;
  eq?: Maybe<Scalars['Int']>;
  ge?: Maybe<Scalars['Int']>;
  gt?: Maybe<Scalars['Int']>;
  in?: Maybe<Array<Maybe<Scalars['Int']>>>;
  le?: Maybe<Scalars['Int']>;
  lt?: Maybe<Scalars['Int']>;
};

export type IntRange = {
  max: Scalars['Int'];
  min: Scalars['Int'];
};

export type IntegerMetadatum = {
  __typename?: 'IntegerMetadatum';
  value: Scalars['Int'];
};

export type IntegerMetadatumAggregateResult = {
  __typename?: 'IntegerMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  valueAvg?: Maybe<Scalars['Float']>;
  valueMax?: Maybe<Scalars['Int']>;
  valueMin?: Maybe<Scalars['Int']>;
  valueSum?: Maybe<Scalars['Int']>;
};

export type IntegerMetadatumFilter = {
  and?: Maybe<Array<Maybe<IntegerMetadatumFilter>>>;
  has?: Maybe<Array<Maybe<IntegerMetadatumHasFilter>>>;
  not?: Maybe<IntegerMetadatumFilter>;
  or?: Maybe<Array<Maybe<IntegerMetadatumFilter>>>;
};

export enum IntegerMetadatumHasFilter {
  Value = 'value'
}

export type IntegerMetadatumOrder = {
  asc?: Maybe<IntegerMetadatumOrderable>;
  desc?: Maybe<IntegerMetadatumOrderable>;
  then?: Maybe<IntegerMetadatumOrder>;
};

export enum IntegerMetadatumOrderable {
  Value = 'value'
}

export type IntegerMetadatumPatch = {
  value?: Maybe<Scalars['Int']>;
};

export type IntegerMetadatumRef = {
  value?: Maybe<Scalars['Int']>;
};

export type IntersectsFilter = {
  multiPolygon?: Maybe<MultiPolygonRef>;
  polygon?: Maybe<PolygonRef>;
};

export type KeyValueMetadatum = {
  __typename?: 'KeyValueMetadatum';
  key: Scalars['String'];
  metadatum: Metadatum;
};


export type KeyValueMetadatumMetadatumArgs = {
  filter?: Maybe<MetadatumFilter>;
};

export type KeyValueMetadatumAggregateResult = {
  __typename?: 'KeyValueMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  keyMax?: Maybe<Scalars['String']>;
  keyMin?: Maybe<Scalars['String']>;
};

export type KeyValueMetadatumFilter = {
  and?: Maybe<Array<Maybe<KeyValueMetadatumFilter>>>;
  has?: Maybe<Array<Maybe<KeyValueMetadatumHasFilter>>>;
  not?: Maybe<KeyValueMetadatumFilter>;
  or?: Maybe<Array<Maybe<KeyValueMetadatumFilter>>>;
};

export enum KeyValueMetadatumHasFilter {
  Key = 'key',
  Metadatum = 'metadatum'
}

export type KeyValueMetadatumOrder = {
  asc?: Maybe<KeyValueMetadatumOrderable>;
  desc?: Maybe<KeyValueMetadatumOrderable>;
  then?: Maybe<KeyValueMetadatumOrder>;
};

export enum KeyValueMetadatumOrderable {
  Key = 'key'
}

export type KeyValueMetadatumPatch = {
  key?: Maybe<Scalars['String']>;
  metadatum?: Maybe<MetadatumRef>;
};

export type KeyValueMetadatumRef = {
  key?: Maybe<Scalars['String']>;
  metadatum?: Maybe<MetadatumRef>;
};

export type Metadatum = BytesMetadatum | IntegerMetadatum | MetadatumArray | MetadatumMap | StringMetadatum;

export type MetadatumArray = {
  __typename?: 'MetadatumArray';
  value: Array<Metadatum>;
  valueType: MetadatumArrayType;
};


export type MetadatumArrayValueArgs = {
  filter?: Maybe<MetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type MetadatumArrayAggregateResult = {
  __typename?: 'MetadatumArrayAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type MetadatumArrayFilter = {
  and?: Maybe<Array<Maybe<MetadatumArrayFilter>>>;
  has?: Maybe<Array<Maybe<MetadatumArrayHasFilter>>>;
  not?: Maybe<MetadatumArrayFilter>;
  or?: Maybe<Array<Maybe<MetadatumArrayFilter>>>;
};

export enum MetadatumArrayHasFilter {
  Value = 'value',
  ValueType = 'valueType'
}

export type MetadatumArrayPatch = {
  value?: Maybe<Array<MetadatumRef>>;
  valueType?: Maybe<MetadatumArrayType>;
};

export type MetadatumArrayRef = {
  value?: Maybe<Array<MetadatumRef>>;
  valueType?: Maybe<MetadatumArrayType>;
};

export enum MetadatumArrayType {
  Array = 'array',
  Map = 'map'
}

export type MetadatumFilter = {
  bytesMetadatumFilter?: Maybe<BytesMetadatumFilter>;
  integerMetadatumFilter?: Maybe<IntegerMetadatumFilter>;
  memberTypes?: Maybe<Array<MetadatumType>>;
  metadatumArrayFilter?: Maybe<MetadatumArrayFilter>;
  metadatumMapFilter?: Maybe<MetadatumMapFilter>;
  stringMetadatumFilter?: Maybe<StringMetadatumFilter>;
};

export type MetadatumMap = {
  __typename?: 'MetadatumMap';
  value: Array<KeyValueMetadatum>;
  valueAggregate?: Maybe<KeyValueMetadatumAggregateResult>;
  valueType: MetadatumArrayType;
};


export type MetadatumMapValueArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<KeyValueMetadatumOrder>;
};


export type MetadatumMapValueAggregateArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
};

export type MetadatumMapAggregateResult = {
  __typename?: 'MetadatumMapAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type MetadatumMapFilter = {
  and?: Maybe<Array<Maybe<MetadatumMapFilter>>>;
  has?: Maybe<Array<Maybe<MetadatumMapHasFilter>>>;
  not?: Maybe<MetadatumMapFilter>;
  or?: Maybe<Array<Maybe<MetadatumMapFilter>>>;
};

export enum MetadatumMapHasFilter {
  Value = 'value',
  ValueType = 'valueType'
}

export type MetadatumMapPatch = {
  value?: Maybe<Array<KeyValueMetadatumRef>>;
  valueType?: Maybe<MetadatumArrayType>;
};

export type MetadatumMapRef = {
  value?: Maybe<Array<KeyValueMetadatumRef>>;
  valueType?: Maybe<MetadatumArrayType>;
};

export type MetadatumRef = {
  bytesMetadatumRef?: Maybe<BytesMetadatumRef>;
  integerMetadatumRef?: Maybe<IntegerMetadatumRef>;
  metadatumArrayRef?: Maybe<MetadatumArrayRef>;
  metadatumMapRef?: Maybe<MetadatumMapRef>;
  stringMetadatumRef?: Maybe<StringMetadatumRef>;
};

export enum MetadatumStringType {
  Bytes = 'bytes',
  Other = 'other'
}

export enum MetadatumType {
  BytesMetadatum = 'BytesMetadatum',
  IntegerMetadatum = 'IntegerMetadatum',
  MetadatumArray = 'MetadatumArray',
  MetadatumMap = 'MetadatumMap',
  StringMetadatum = 'StringMetadatum'
}

export enum Mode {
  Batch = 'BATCH',
  Single = 'SINGLE'
}

export type MultiPolygon = {
  __typename?: 'MultiPolygon';
  polygons: Array<Polygon>;
};

export type MultiPolygonRef = {
  polygons: Array<PolygonRef>;
};

export type Mutation = {
  __typename?: 'Mutation';
  addActiveStake?: Maybe<AddActiveStakePayload>;
  addAda?: Maybe<AddAdaPayload>;
  addAdaPots?: Maybe<AddAdaPotsPayload>;
  addAddress?: Maybe<AddAddressPayload>;
  addAlonzoGenesis?: Maybe<AddAlonzoGenesisPayload>;
  addAsset?: Maybe<AddAssetPayload>;
  addAssetSupply?: Maybe<AddAssetSupplyPayload>;
  addAuxiliaryData?: Maybe<AddAuxiliaryDataPayload>;
  addAuxiliaryDataBody?: Maybe<AddAuxiliaryDataBodyPayload>;
  addBlock?: Maybe<AddBlockPayload>;
  addByronBlockVersionData?: Maybe<AddByronBlockVersionDataPayload>;
  addByronGenesis?: Maybe<AddByronGenesisPayload>;
  addByronProtocolConsts?: Maybe<AddByronProtocolConstsPayload>;
  addByronSoftForkRule?: Maybe<AddByronSoftForkRulePayload>;
  addByronTxFeePolicy?: Maybe<AddByronTxFeePolicyPayload>;
  addBytesMetadatum?: Maybe<AddBytesMetadatumPayload>;
  addEpoch?: Maybe<AddEpochPayload>;
  addExecutionPrice?: Maybe<AddExecutionPricePayload>;
  addExecutionPrices?: Maybe<AddExecutionPricesPayload>;
  addExecutionUnits?: Maybe<AddExecutionUnitsPayload>;
  addExtendedStakePoolMetadata?: Maybe<AddExtendedStakePoolMetadataPayload>;
  addExtendedStakePoolMetadataFields?: Maybe<AddExtendedStakePoolMetadataFieldsPayload>;
  addFraction?: Maybe<AddFractionPayload>;
  addGenesis?: Maybe<AddGenesisPayload>;
  addITNVerification?: Maybe<AddItnVerificationPayload>;
  addIntegerMetadatum?: Maybe<AddIntegerMetadatumPayload>;
  addKeyValueMetadatum?: Maybe<AddKeyValueMetadatumPayload>;
  addMetadatumArray?: Maybe<AddMetadatumArrayPayload>;
  addMetadatumMap?: Maybe<AddMetadatumMapPayload>;
  addPoolContactData?: Maybe<AddPoolContactDataPayload>;
  addProtocolParameters?: Maybe<AddProtocolParametersPayload>;
  addProtocolVersion?: Maybe<AddProtocolVersionPayload>;
  addRedeemer?: Maybe<AddRedeemerPayload>;
  addRelayByAddress?: Maybe<AddRelayByAddressPayload>;
  addRelayByName?: Maybe<AddRelayByNamePayload>;
  addRelayByNameMultihost?: Maybe<AddRelayByNameMultihostPayload>;
  addRewardAccount?: Maybe<AddRewardAccountPayload>;
  addScript?: Maybe<AddScriptPayload>;
  addShelleyGenesis?: Maybe<AddShelleyGenesisPayload>;
  addShelleyGenesisStaking?: Maybe<AddShelleyGenesisStakingPayload>;
  addSlot?: Maybe<AddSlotPayload>;
  addStakePool?: Maybe<AddStakePoolPayload>;
  addStakePoolMetadata?: Maybe<AddStakePoolMetadataPayload>;
  addStakePoolMetadataJson?: Maybe<AddStakePoolMetadataJsonPayload>;
  addStakePoolMetrics?: Maybe<AddStakePoolMetricsPayload>;
  addStakePoolMetricsSize?: Maybe<AddStakePoolMetricsSizePayload>;
  addStakePoolMetricsStake?: Maybe<AddStakePoolMetricsStakePayload>;
  addStakePoolTransactions?: Maybe<AddStakePoolTransactionsPayload>;
  addStringMetadatum?: Maybe<AddStringMetadatumPayload>;
  addThePoolsMediaAssets?: Maybe<AddThePoolsMediaAssetsPayload>;
  addToken?: Maybe<AddTokenPayload>;
  addTransaction?: Maybe<AddTransactionPayload>;
  addTransactionInput?: Maybe<AddTransactionInputPayload>;
  addTransactionOutput?: Maybe<AddTransactionOutputPayload>;
  addValue?: Maybe<AddValuePayload>;
  addWithdrawal?: Maybe<AddWithdrawalPayload>;
  deleteActiveStake?: Maybe<DeleteActiveStakePayload>;
  deleteAda?: Maybe<DeleteAdaPayload>;
  deleteAdaPots?: Maybe<DeleteAdaPotsPayload>;
  deleteAddress?: Maybe<DeleteAddressPayload>;
  deleteAlonzoGenesis?: Maybe<DeleteAlonzoGenesisPayload>;
  deleteAsset?: Maybe<DeleteAssetPayload>;
  deleteAssetSupply?: Maybe<DeleteAssetSupplyPayload>;
  deleteAuxiliaryData?: Maybe<DeleteAuxiliaryDataPayload>;
  deleteAuxiliaryDataBody?: Maybe<DeleteAuxiliaryDataBodyPayload>;
  deleteBlock?: Maybe<DeleteBlockPayload>;
  deleteByronBlockVersionData?: Maybe<DeleteByronBlockVersionDataPayload>;
  deleteByronGenesis?: Maybe<DeleteByronGenesisPayload>;
  deleteByronProtocolConsts?: Maybe<DeleteByronProtocolConstsPayload>;
  deleteByronSoftForkRule?: Maybe<DeleteByronSoftForkRulePayload>;
  deleteByronTxFeePolicy?: Maybe<DeleteByronTxFeePolicyPayload>;
  deleteBytesMetadatum?: Maybe<DeleteBytesMetadatumPayload>;
  deleteEpoch?: Maybe<DeleteEpochPayload>;
  deleteExecutionPrice?: Maybe<DeleteExecutionPricePayload>;
  deleteExecutionPrices?: Maybe<DeleteExecutionPricesPayload>;
  deleteExecutionUnits?: Maybe<DeleteExecutionUnitsPayload>;
  deleteExtendedStakePoolMetadata?: Maybe<DeleteExtendedStakePoolMetadataPayload>;
  deleteExtendedStakePoolMetadataFields?: Maybe<DeleteExtendedStakePoolMetadataFieldsPayload>;
  deleteFraction?: Maybe<DeleteFractionPayload>;
  deleteGenesis?: Maybe<DeleteGenesisPayload>;
  deleteITNVerification?: Maybe<DeleteItnVerificationPayload>;
  deleteIntegerMetadatum?: Maybe<DeleteIntegerMetadatumPayload>;
  deleteKeyValueMetadatum?: Maybe<DeleteKeyValueMetadatumPayload>;
  deleteMetadatumArray?: Maybe<DeleteMetadatumArrayPayload>;
  deleteMetadatumMap?: Maybe<DeleteMetadatumMapPayload>;
  deletePoolContactData?: Maybe<DeletePoolContactDataPayload>;
  deleteProtocolParameters?: Maybe<DeleteProtocolParametersPayload>;
  deleteProtocolVersion?: Maybe<DeleteProtocolVersionPayload>;
  deleteRedeemer?: Maybe<DeleteRedeemerPayload>;
  deleteRelayByAddress?: Maybe<DeleteRelayByAddressPayload>;
  deleteRelayByName?: Maybe<DeleteRelayByNamePayload>;
  deleteRelayByNameMultihost?: Maybe<DeleteRelayByNameMultihostPayload>;
  deleteRewardAccount?: Maybe<DeleteRewardAccountPayload>;
  deleteScript?: Maybe<DeleteScriptPayload>;
  deleteShelleyGenesis?: Maybe<DeleteShelleyGenesisPayload>;
  deleteShelleyGenesisStaking?: Maybe<DeleteShelleyGenesisStakingPayload>;
  deleteSlot?: Maybe<DeleteSlotPayload>;
  deleteStakePool?: Maybe<DeleteStakePoolPayload>;
  deleteStakePoolMetadata?: Maybe<DeleteStakePoolMetadataPayload>;
  deleteStakePoolMetadataJson?: Maybe<DeleteStakePoolMetadataJsonPayload>;
  deleteStakePoolMetrics?: Maybe<DeleteStakePoolMetricsPayload>;
  deleteStakePoolMetricsSize?: Maybe<DeleteStakePoolMetricsSizePayload>;
  deleteStakePoolMetricsStake?: Maybe<DeleteStakePoolMetricsStakePayload>;
  deleteStakePoolTransactions?: Maybe<DeleteStakePoolTransactionsPayload>;
  deleteStringMetadatum?: Maybe<DeleteStringMetadatumPayload>;
  deleteThePoolsMediaAssets?: Maybe<DeleteThePoolsMediaAssetsPayload>;
  deleteToken?: Maybe<DeleteTokenPayload>;
  deleteTransaction?: Maybe<DeleteTransactionPayload>;
  deleteTransactionInput?: Maybe<DeleteTransactionInputPayload>;
  deleteTransactionOutput?: Maybe<DeleteTransactionOutputPayload>;
  deleteValue?: Maybe<DeleteValuePayload>;
  deleteWithdrawal?: Maybe<DeleteWithdrawalPayload>;
  updateActiveStake?: Maybe<UpdateActiveStakePayload>;
  updateAda?: Maybe<UpdateAdaPayload>;
  updateAdaPots?: Maybe<UpdateAdaPotsPayload>;
  updateAddress?: Maybe<UpdateAddressPayload>;
  updateAlonzoGenesis?: Maybe<UpdateAlonzoGenesisPayload>;
  updateAsset?: Maybe<UpdateAssetPayload>;
  updateAssetSupply?: Maybe<UpdateAssetSupplyPayload>;
  updateAuxiliaryData?: Maybe<UpdateAuxiliaryDataPayload>;
  updateAuxiliaryDataBody?: Maybe<UpdateAuxiliaryDataBodyPayload>;
  updateBlock?: Maybe<UpdateBlockPayload>;
  updateByronBlockVersionData?: Maybe<UpdateByronBlockVersionDataPayload>;
  updateByronGenesis?: Maybe<UpdateByronGenesisPayload>;
  updateByronProtocolConsts?: Maybe<UpdateByronProtocolConstsPayload>;
  updateByronSoftForkRule?: Maybe<UpdateByronSoftForkRulePayload>;
  updateByronTxFeePolicy?: Maybe<UpdateByronTxFeePolicyPayload>;
  updateBytesMetadatum?: Maybe<UpdateBytesMetadatumPayload>;
  updateEpoch?: Maybe<UpdateEpochPayload>;
  updateExecutionPrice?: Maybe<UpdateExecutionPricePayload>;
  updateExecutionPrices?: Maybe<UpdateExecutionPricesPayload>;
  updateExecutionUnits?: Maybe<UpdateExecutionUnitsPayload>;
  updateExtendedStakePoolMetadata?: Maybe<UpdateExtendedStakePoolMetadataPayload>;
  updateExtendedStakePoolMetadataFields?: Maybe<UpdateExtendedStakePoolMetadataFieldsPayload>;
  updateFraction?: Maybe<UpdateFractionPayload>;
  updateGenesis?: Maybe<UpdateGenesisPayload>;
  updateITNVerification?: Maybe<UpdateItnVerificationPayload>;
  updateIntegerMetadatum?: Maybe<UpdateIntegerMetadatumPayload>;
  updateKeyValueMetadatum?: Maybe<UpdateKeyValueMetadatumPayload>;
  updateMetadatumArray?: Maybe<UpdateMetadatumArrayPayload>;
  updateMetadatumMap?: Maybe<UpdateMetadatumMapPayload>;
  updatePoolContactData?: Maybe<UpdatePoolContactDataPayload>;
  updateProtocolParameters?: Maybe<UpdateProtocolParametersPayload>;
  updateProtocolVersion?: Maybe<UpdateProtocolVersionPayload>;
  updateRedeemer?: Maybe<UpdateRedeemerPayload>;
  updateRelayByAddress?: Maybe<UpdateRelayByAddressPayload>;
  updateRelayByName?: Maybe<UpdateRelayByNamePayload>;
  updateRelayByNameMultihost?: Maybe<UpdateRelayByNameMultihostPayload>;
  updateRewardAccount?: Maybe<UpdateRewardAccountPayload>;
  updateScript?: Maybe<UpdateScriptPayload>;
  updateShelleyGenesis?: Maybe<UpdateShelleyGenesisPayload>;
  updateShelleyGenesisStaking?: Maybe<UpdateShelleyGenesisStakingPayload>;
  updateSlot?: Maybe<UpdateSlotPayload>;
  updateStakePool?: Maybe<UpdateStakePoolPayload>;
  updateStakePoolMetadata?: Maybe<UpdateStakePoolMetadataPayload>;
  updateStakePoolMetadataJson?: Maybe<UpdateStakePoolMetadataJsonPayload>;
  updateStakePoolMetrics?: Maybe<UpdateStakePoolMetricsPayload>;
  updateStakePoolMetricsSize?: Maybe<UpdateStakePoolMetricsSizePayload>;
  updateStakePoolMetricsStake?: Maybe<UpdateStakePoolMetricsStakePayload>;
  updateStakePoolTransactions?: Maybe<UpdateStakePoolTransactionsPayload>;
  updateStringMetadatum?: Maybe<UpdateStringMetadatumPayload>;
  updateThePoolsMediaAssets?: Maybe<UpdateThePoolsMediaAssetsPayload>;
  updateToken?: Maybe<UpdateTokenPayload>;
  updateTransaction?: Maybe<UpdateTransactionPayload>;
  updateTransactionInput?: Maybe<UpdateTransactionInputPayload>;
  updateTransactionOutput?: Maybe<UpdateTransactionOutputPayload>;
  updateValue?: Maybe<UpdateValuePayload>;
  updateWithdrawal?: Maybe<UpdateWithdrawalPayload>;
};


export type MutationAddActiveStakeArgs = {
  input: Array<AddActiveStakeInput>;
};


export type MutationAddAdaArgs = {
  input: Array<AddAdaInput>;
};


export type MutationAddAdaPotsArgs = {
  input: Array<AddAdaPotsInput>;
};


export type MutationAddAddressArgs = {
  input: Array<AddAddressInput>;
};


export type MutationAddAlonzoGenesisArgs = {
  input: Array<AddAlonzoGenesisInput>;
};


export type MutationAddAssetArgs = {
  input: Array<AddAssetInput>;
};


export type MutationAddAssetSupplyArgs = {
  input: Array<AddAssetSupplyInput>;
};


export type MutationAddAuxiliaryDataArgs = {
  input: Array<AddAuxiliaryDataInput>;
};


export type MutationAddAuxiliaryDataBodyArgs = {
  input: Array<AddAuxiliaryDataBodyInput>;
};


export type MutationAddBlockArgs = {
  input: Array<AddBlockInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddByronBlockVersionDataArgs = {
  input: Array<AddByronBlockVersionDataInput>;
};


export type MutationAddByronGenesisArgs = {
  input: Array<AddByronGenesisInput>;
};


export type MutationAddByronProtocolConstsArgs = {
  input: Array<AddByronProtocolConstsInput>;
};


export type MutationAddByronSoftForkRuleArgs = {
  input: Array<AddByronSoftForkRuleInput>;
};


export type MutationAddByronTxFeePolicyArgs = {
  input: Array<AddByronTxFeePolicyInput>;
};


export type MutationAddBytesMetadatumArgs = {
  input: Array<AddBytesMetadatumInput>;
};


export type MutationAddEpochArgs = {
  input: Array<AddEpochInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddExecutionPriceArgs = {
  input: Array<AddExecutionPriceInput>;
};


export type MutationAddExecutionPricesArgs = {
  input: Array<AddExecutionPricesInput>;
};


export type MutationAddExecutionUnitsArgs = {
  input: Array<AddExecutionUnitsInput>;
};


export type MutationAddExtendedStakePoolMetadataArgs = {
  input: Array<AddExtendedStakePoolMetadataInput>;
};


export type MutationAddExtendedStakePoolMetadataFieldsArgs = {
  input: Array<AddExtendedStakePoolMetadataFieldsInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddFractionArgs = {
  input: Array<AddFractionInput>;
};


export type MutationAddGenesisArgs = {
  input: Array<AddGenesisInput>;
};


export type MutationAddItnVerificationArgs = {
  input: Array<AddItnVerificationInput>;
};


export type MutationAddIntegerMetadatumArgs = {
  input: Array<AddIntegerMetadatumInput>;
};


export type MutationAddKeyValueMetadatumArgs = {
  input: Array<AddKeyValueMetadatumInput>;
};


export type MutationAddMetadatumArrayArgs = {
  input: Array<AddMetadatumArrayInput>;
};


export type MutationAddMetadatumMapArgs = {
  input: Array<AddMetadatumMapInput>;
};


export type MutationAddPoolContactDataArgs = {
  input: Array<AddPoolContactDataInput>;
};


export type MutationAddProtocolParametersArgs = {
  input: Array<AddProtocolParametersInput>;
};


export type MutationAddProtocolVersionArgs = {
  input: Array<AddProtocolVersionInput>;
};


export type MutationAddRedeemerArgs = {
  input: Array<AddRedeemerInput>;
};


export type MutationAddRelayByAddressArgs = {
  input: Array<AddRelayByAddressInput>;
};


export type MutationAddRelayByNameArgs = {
  input: Array<AddRelayByNameInput>;
};


export type MutationAddRelayByNameMultihostArgs = {
  input: Array<AddRelayByNameMultihostInput>;
};


export type MutationAddRewardAccountArgs = {
  input: Array<AddRewardAccountInput>;
};


export type MutationAddScriptArgs = {
  input: Array<AddScriptInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddShelleyGenesisArgs = {
  input: Array<AddShelleyGenesisInput>;
};


export type MutationAddShelleyGenesisStakingArgs = {
  input: Array<AddShelleyGenesisStakingInput>;
};


export type MutationAddSlotArgs = {
  input: Array<AddSlotInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddStakePoolArgs = {
  input: Array<AddStakePoolInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddStakePoolMetadataArgs = {
  input: Array<AddStakePoolMetadataInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddStakePoolMetadataJsonArgs = {
  input: Array<AddStakePoolMetadataJsonInput>;
};


export type MutationAddStakePoolMetricsArgs = {
  input: Array<AddStakePoolMetricsInput>;
};


export type MutationAddStakePoolMetricsSizeArgs = {
  input: Array<AddStakePoolMetricsSizeInput>;
};


export type MutationAddStakePoolMetricsStakeArgs = {
  input: Array<AddStakePoolMetricsStakeInput>;
};


export type MutationAddStakePoolTransactionsArgs = {
  input: Array<AddStakePoolTransactionsInput>;
};


export type MutationAddStringMetadatumArgs = {
  input: Array<AddStringMetadatumInput>;
};


export type MutationAddThePoolsMediaAssetsArgs = {
  input: Array<AddThePoolsMediaAssetsInput>;
};


export type MutationAddTokenArgs = {
  input: Array<AddTokenInput>;
};


export type MutationAddTransactionArgs = {
  input: Array<AddTransactionInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddTransactionInputArgs = {
  input: Array<AddTransactionInputInput>;
};


export type MutationAddTransactionOutputArgs = {
  input: Array<AddTransactionOutputInput>;
};


export type MutationAddValueArgs = {
  input: Array<AddValueInput>;
};


export type MutationAddWithdrawalArgs = {
  input: Array<AddWithdrawalInput>;
};


export type MutationDeleteActiveStakeArgs = {
  filter: ActiveStakeFilter;
};


export type MutationDeleteAdaArgs = {
  filter: AdaFilter;
};


export type MutationDeleteAdaPotsArgs = {
  filter: AdaPotsFilter;
};


export type MutationDeleteAddressArgs = {
  filter: AddressFilter;
};


export type MutationDeleteAlonzoGenesisArgs = {
  filter: AlonzoGenesisFilter;
};


export type MutationDeleteAssetArgs = {
  filter: AssetFilter;
};


export type MutationDeleteAssetSupplyArgs = {
  filter: AssetSupplyFilter;
};


export type MutationDeleteAuxiliaryDataArgs = {
  filter: AuxiliaryDataFilter;
};


export type MutationDeleteAuxiliaryDataBodyArgs = {
  filter: AuxiliaryDataBodyFilter;
};


export type MutationDeleteBlockArgs = {
  filter: BlockFilter;
};


export type MutationDeleteByronBlockVersionDataArgs = {
  filter: ByronBlockVersionDataFilter;
};


export type MutationDeleteByronGenesisArgs = {
  filter: ByronGenesisFilter;
};


export type MutationDeleteByronProtocolConstsArgs = {
  filter: ByronProtocolConstsFilter;
};


export type MutationDeleteByronSoftForkRuleArgs = {
  filter: ByronSoftForkRuleFilter;
};


export type MutationDeleteByronTxFeePolicyArgs = {
  filter: ByronTxFeePolicyFilter;
};


export type MutationDeleteBytesMetadatumArgs = {
  filter: BytesMetadatumFilter;
};


export type MutationDeleteEpochArgs = {
  filter: EpochFilter;
};


export type MutationDeleteExecutionPriceArgs = {
  filter: ExecutionPriceFilter;
};


export type MutationDeleteExecutionPricesArgs = {
  filter: ExecutionPricesFilter;
};


export type MutationDeleteExecutionUnitsArgs = {
  filter: ExecutionUnitsFilter;
};


export type MutationDeleteExtendedStakePoolMetadataArgs = {
  filter: ExtendedStakePoolMetadataFilter;
};


export type MutationDeleteExtendedStakePoolMetadataFieldsArgs = {
  filter: ExtendedStakePoolMetadataFieldsFilter;
};


export type MutationDeleteFractionArgs = {
  filter: FractionFilter;
};


export type MutationDeleteGenesisArgs = {
  filter: GenesisFilter;
};


export type MutationDeleteItnVerificationArgs = {
  filter: ItnVerificationFilter;
};


export type MutationDeleteIntegerMetadatumArgs = {
  filter: IntegerMetadatumFilter;
};


export type MutationDeleteKeyValueMetadatumArgs = {
  filter: KeyValueMetadatumFilter;
};


export type MutationDeleteMetadatumArrayArgs = {
  filter: MetadatumArrayFilter;
};


export type MutationDeleteMetadatumMapArgs = {
  filter: MetadatumMapFilter;
};


export type MutationDeletePoolContactDataArgs = {
  filter: PoolContactDataFilter;
};


export type MutationDeleteProtocolParametersArgs = {
  filter: ProtocolParametersFilter;
};


export type MutationDeleteProtocolVersionArgs = {
  filter: ProtocolVersionFilter;
};


export type MutationDeleteRedeemerArgs = {
  filter: RedeemerFilter;
};


export type MutationDeleteRelayByAddressArgs = {
  filter: RelayByAddressFilter;
};


export type MutationDeleteRelayByNameArgs = {
  filter: RelayByNameFilter;
};


export type MutationDeleteRelayByNameMultihostArgs = {
  filter: RelayByNameMultihostFilter;
};


export type MutationDeleteRewardAccountArgs = {
  filter: RewardAccountFilter;
};


export type MutationDeleteScriptArgs = {
  filter: ScriptFilter;
};


export type MutationDeleteShelleyGenesisArgs = {
  filter: ShelleyGenesisFilter;
};


export type MutationDeleteShelleyGenesisStakingArgs = {
  filter: ShelleyGenesisStakingFilter;
};


export type MutationDeleteSlotArgs = {
  filter: SlotFilter;
};


export type MutationDeleteStakePoolArgs = {
  filter: StakePoolFilter;
};


export type MutationDeleteStakePoolMetadataArgs = {
  filter: StakePoolMetadataFilter;
};


export type MutationDeleteStakePoolMetadataJsonArgs = {
  filter: StakePoolMetadataJsonFilter;
};


export type MutationDeleteStakePoolMetricsArgs = {
  filter: StakePoolMetricsFilter;
};


export type MutationDeleteStakePoolMetricsSizeArgs = {
  filter: StakePoolMetricsSizeFilter;
};


export type MutationDeleteStakePoolMetricsStakeArgs = {
  filter: StakePoolMetricsStakeFilter;
};


export type MutationDeleteStakePoolTransactionsArgs = {
  filter: StakePoolTransactionsFilter;
};


export type MutationDeleteStringMetadatumArgs = {
  filter: StringMetadatumFilter;
};


export type MutationDeleteThePoolsMediaAssetsArgs = {
  filter: ThePoolsMediaAssetsFilter;
};


export type MutationDeleteTokenArgs = {
  filter: TokenFilter;
};


export type MutationDeleteTransactionArgs = {
  filter: TransactionFilter;
};


export type MutationDeleteTransactionInputArgs = {
  filter: TransactionInputFilter;
};


export type MutationDeleteTransactionOutputArgs = {
  filter: TransactionOutputFilter;
};


export type MutationDeleteValueArgs = {
  filter: ValueFilter;
};


export type MutationDeleteWithdrawalArgs = {
  filter: WithdrawalFilter;
};


export type MutationUpdateActiveStakeArgs = {
  input: UpdateActiveStakeInput;
};


export type MutationUpdateAdaArgs = {
  input: UpdateAdaInput;
};


export type MutationUpdateAdaPotsArgs = {
  input: UpdateAdaPotsInput;
};


export type MutationUpdateAddressArgs = {
  input: UpdateAddressInput;
};


export type MutationUpdateAlonzoGenesisArgs = {
  input: UpdateAlonzoGenesisInput;
};


export type MutationUpdateAssetArgs = {
  input: UpdateAssetInput;
};


export type MutationUpdateAssetSupplyArgs = {
  input: UpdateAssetSupplyInput;
};


export type MutationUpdateAuxiliaryDataArgs = {
  input: UpdateAuxiliaryDataInput;
};


export type MutationUpdateAuxiliaryDataBodyArgs = {
  input: UpdateAuxiliaryDataBodyInput;
};


export type MutationUpdateBlockArgs = {
  input: UpdateBlockInput;
};


export type MutationUpdateByronBlockVersionDataArgs = {
  input: UpdateByronBlockVersionDataInput;
};


export type MutationUpdateByronGenesisArgs = {
  input: UpdateByronGenesisInput;
};


export type MutationUpdateByronProtocolConstsArgs = {
  input: UpdateByronProtocolConstsInput;
};


export type MutationUpdateByronSoftForkRuleArgs = {
  input: UpdateByronSoftForkRuleInput;
};


export type MutationUpdateByronTxFeePolicyArgs = {
  input: UpdateByronTxFeePolicyInput;
};


export type MutationUpdateBytesMetadatumArgs = {
  input: UpdateBytesMetadatumInput;
};


export type MutationUpdateEpochArgs = {
  input: UpdateEpochInput;
};


export type MutationUpdateExecutionPriceArgs = {
  input: UpdateExecutionPriceInput;
};


export type MutationUpdateExecutionPricesArgs = {
  input: UpdateExecutionPricesInput;
};


export type MutationUpdateExecutionUnitsArgs = {
  input: UpdateExecutionUnitsInput;
};


export type MutationUpdateExtendedStakePoolMetadataArgs = {
  input: UpdateExtendedStakePoolMetadataInput;
};


export type MutationUpdateExtendedStakePoolMetadataFieldsArgs = {
  input: UpdateExtendedStakePoolMetadataFieldsInput;
};


export type MutationUpdateFractionArgs = {
  input: UpdateFractionInput;
};


export type MutationUpdateGenesisArgs = {
  input: UpdateGenesisInput;
};


export type MutationUpdateItnVerificationArgs = {
  input: UpdateItnVerificationInput;
};


export type MutationUpdateIntegerMetadatumArgs = {
  input: UpdateIntegerMetadatumInput;
};


export type MutationUpdateKeyValueMetadatumArgs = {
  input: UpdateKeyValueMetadatumInput;
};


export type MutationUpdateMetadatumArrayArgs = {
  input: UpdateMetadatumArrayInput;
};


export type MutationUpdateMetadatumMapArgs = {
  input: UpdateMetadatumMapInput;
};


export type MutationUpdatePoolContactDataArgs = {
  input: UpdatePoolContactDataInput;
};


export type MutationUpdateProtocolParametersArgs = {
  input: UpdateProtocolParametersInput;
};


export type MutationUpdateProtocolVersionArgs = {
  input: UpdateProtocolVersionInput;
};


export type MutationUpdateRedeemerArgs = {
  input: UpdateRedeemerInput;
};


export type MutationUpdateRelayByAddressArgs = {
  input: UpdateRelayByAddressInput;
};


export type MutationUpdateRelayByNameArgs = {
  input: UpdateRelayByNameInput;
};


export type MutationUpdateRelayByNameMultihostArgs = {
  input: UpdateRelayByNameMultihostInput;
};


export type MutationUpdateRewardAccountArgs = {
  input: UpdateRewardAccountInput;
};


export type MutationUpdateScriptArgs = {
  input: UpdateScriptInput;
};


export type MutationUpdateShelleyGenesisArgs = {
  input: UpdateShelleyGenesisInput;
};


export type MutationUpdateShelleyGenesisStakingArgs = {
  input: UpdateShelleyGenesisStakingInput;
};


export type MutationUpdateSlotArgs = {
  input: UpdateSlotInput;
};


export type MutationUpdateStakePoolArgs = {
  input: UpdateStakePoolInput;
};


export type MutationUpdateStakePoolMetadataArgs = {
  input: UpdateStakePoolMetadataInput;
};


export type MutationUpdateStakePoolMetadataJsonArgs = {
  input: UpdateStakePoolMetadataJsonInput;
};


export type MutationUpdateStakePoolMetricsArgs = {
  input: UpdateStakePoolMetricsInput;
};


export type MutationUpdateStakePoolMetricsSizeArgs = {
  input: UpdateStakePoolMetricsSizeInput;
};


export type MutationUpdateStakePoolMetricsStakeArgs = {
  input: UpdateStakePoolMetricsStakeInput;
};


export type MutationUpdateStakePoolTransactionsArgs = {
  input: UpdateStakePoolTransactionsInput;
};


export type MutationUpdateStringMetadatumArgs = {
  input: UpdateStringMetadatumInput;
};


export type MutationUpdateThePoolsMediaAssetsArgs = {
  input: UpdateThePoolsMediaAssetsInput;
};


export type MutationUpdateTokenArgs = {
  input: UpdateTokenInput;
};


export type MutationUpdateTransactionArgs = {
  input: UpdateTransactionInput;
};


export type MutationUpdateTransactionInputArgs = {
  input: UpdateTransactionInputInput;
};


export type MutationUpdateTransactionOutputArgs = {
  input: UpdateTransactionOutputInput;
};


export type MutationUpdateValueArgs = {
  input: UpdateValueInput;
};


export type MutationUpdateWithdrawalArgs = {
  input: UpdateWithdrawalInput;
};

export type NearFilter = {
  coordinate: PointRef;
  distance: Scalars['Float'];
};

export type Point = {
  __typename?: 'Point';
  latitude: Scalars['Float'];
  longitude: Scalars['Float'];
};

export type PointGeoFilter = {
  near?: Maybe<NearFilter>;
  within?: Maybe<WithinFilter>;
};

export type PointList = {
  __typename?: 'PointList';
  points: Array<Point>;
};

export type PointListRef = {
  points: Array<PointRef>;
};

export type PointRef = {
  latitude: Scalars['Float'];
  longitude: Scalars['Float'];
};

export type Polygon = {
  __typename?: 'Polygon';
  coordinates: Array<PointList>;
};

export type PolygonGeoFilter = {
  contains?: Maybe<ContainsFilter>;
  intersects?: Maybe<IntersectsFilter>;
  near?: Maybe<NearFilter>;
  within?: Maybe<WithinFilter>;
};

export type PolygonRef = {
  coordinates: Array<PointListRef>;
};

export type PoolContactData = {
  __typename?: 'PoolContactData';
  email?: Maybe<Scalars['String']>;
  facebook?: Maybe<Scalars['String']>;
  feed?: Maybe<Scalars['String']>;
  github?: Maybe<Scalars['String']>;
  primary: Scalars['String'];
  telegram?: Maybe<Scalars['String']>;
  twitter?: Maybe<Scalars['String']>;
};

export type PoolContactDataAggregateResult = {
  __typename?: 'PoolContactDataAggregateResult';
  count?: Maybe<Scalars['Int']>;
  emailMax?: Maybe<Scalars['String']>;
  emailMin?: Maybe<Scalars['String']>;
  facebookMax?: Maybe<Scalars['String']>;
  facebookMin?: Maybe<Scalars['String']>;
  feedMax?: Maybe<Scalars['String']>;
  feedMin?: Maybe<Scalars['String']>;
  githubMax?: Maybe<Scalars['String']>;
  githubMin?: Maybe<Scalars['String']>;
  primaryMax?: Maybe<Scalars['String']>;
  primaryMin?: Maybe<Scalars['String']>;
  telegramMax?: Maybe<Scalars['String']>;
  telegramMin?: Maybe<Scalars['String']>;
  twitterMax?: Maybe<Scalars['String']>;
  twitterMin?: Maybe<Scalars['String']>;
};

export type PoolContactDataFilter = {
  and?: Maybe<Array<Maybe<PoolContactDataFilter>>>;
  has?: Maybe<Array<Maybe<PoolContactDataHasFilter>>>;
  not?: Maybe<PoolContactDataFilter>;
  or?: Maybe<Array<Maybe<PoolContactDataFilter>>>;
};

export enum PoolContactDataHasFilter {
  Email = 'email',
  Facebook = 'facebook',
  Feed = 'feed',
  Github = 'github',
  Primary = 'primary',
  Telegram = 'telegram',
  Twitter = 'twitter'
}

export type PoolContactDataOrder = {
  asc?: Maybe<PoolContactDataOrderable>;
  desc?: Maybe<PoolContactDataOrderable>;
  then?: Maybe<PoolContactDataOrder>;
};

export enum PoolContactDataOrderable {
  Email = 'email',
  Facebook = 'facebook',
  Feed = 'feed',
  Github = 'github',
  Primary = 'primary',
  Telegram = 'telegram',
  Twitter = 'twitter'
}

export type PoolContactDataPatch = {
  email?: Maybe<Scalars['String']>;
  facebook?: Maybe<Scalars['String']>;
  feed?: Maybe<Scalars['String']>;
  github?: Maybe<Scalars['String']>;
  primary?: Maybe<Scalars['String']>;
  telegram?: Maybe<Scalars['String']>;
  twitter?: Maybe<Scalars['String']>;
};

export type PoolContactDataRef = {
  email?: Maybe<Scalars['String']>;
  facebook?: Maybe<Scalars['String']>;
  feed?: Maybe<Scalars['String']>;
  github?: Maybe<Scalars['String']>;
  primary?: Maybe<Scalars['String']>;
  telegram?: Maybe<Scalars['String']>;
  twitter?: Maybe<Scalars['String']>;
};

export type ProtocolParameters = {
  __typename?: 'ProtocolParameters';
  a0: Scalars['Float'];
  coinsPerUtxoWord?: Maybe<Scalars['Int']>;
  collateralPercent?: Maybe<Scalars['Int']>;
  costModels?: Maybe<Scalars['String']>;
  decentralizationParam: Scalars['Float'];
  eMax: Scalars['Int'];
  executionPrices?: Maybe<ExecutionPrices>;
  extraEntropy?: Maybe<Scalars['String']>;
  keyDeposit: Scalars['Int'];
  maxBlockBodySize: Scalars['Int'];
  maxBlockExUnits?: Maybe<ExecutionUnits>;
  maxBlockHeaderSize: Scalars['Int'];
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxTxExUnits?: Maybe<ExecutionUnits>;
  maxTxSize: Scalars['Int'];
  maxValSize: Scalars['Int'];
  minFeeA: Scalars['Int'];
  minFeeB: Scalars['Int'];
  minPoolCost: Scalars['Int'];
  minUTxOValue: Scalars['Int'];
  nOpt: Scalars['Int'];
  poolDeposit: Scalars['Int'];
  protocolVersion: ProtocolVersion;
  rho: Scalars['Float'];
  tau: Scalars['Float'];
};


export type ProtocolParametersExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
};


export type ProtocolParametersMaxBlockExUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type ProtocolParametersMaxTxExUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type ProtocolParametersProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
};

export type ProtocolParametersAggregateResult = {
  __typename?: 'ProtocolParametersAggregateResult';
  a0Avg?: Maybe<Scalars['Float']>;
  a0Max?: Maybe<Scalars['Float']>;
  a0Min?: Maybe<Scalars['Float']>;
  a0Sum?: Maybe<Scalars['Float']>;
  coinsPerUtxoWordAvg?: Maybe<Scalars['Float']>;
  coinsPerUtxoWordMax?: Maybe<Scalars['Int']>;
  coinsPerUtxoWordMin?: Maybe<Scalars['Int']>;
  coinsPerUtxoWordSum?: Maybe<Scalars['Int']>;
  collateralPercentAvg?: Maybe<Scalars['Float']>;
  collateralPercentMax?: Maybe<Scalars['Int']>;
  collateralPercentMin?: Maybe<Scalars['Int']>;
  collateralPercentSum?: Maybe<Scalars['Int']>;
  costModelsMax?: Maybe<Scalars['String']>;
  costModelsMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  decentralizationParamAvg?: Maybe<Scalars['Float']>;
  decentralizationParamMax?: Maybe<Scalars['Float']>;
  decentralizationParamMin?: Maybe<Scalars['Float']>;
  decentralizationParamSum?: Maybe<Scalars['Float']>;
  eMaxAvg?: Maybe<Scalars['Float']>;
  eMaxMax?: Maybe<Scalars['Int']>;
  eMaxMin?: Maybe<Scalars['Int']>;
  eMaxSum?: Maybe<Scalars['Int']>;
  extraEntropyMax?: Maybe<Scalars['String']>;
  extraEntropyMin?: Maybe<Scalars['String']>;
  keyDepositAvg?: Maybe<Scalars['Float']>;
  keyDepositMax?: Maybe<Scalars['Int']>;
  keyDepositMin?: Maybe<Scalars['Int']>;
  keyDepositSum?: Maybe<Scalars['Int']>;
  maxBlockBodySizeAvg?: Maybe<Scalars['Float']>;
  maxBlockBodySizeMax?: Maybe<Scalars['Int']>;
  maxBlockBodySizeMin?: Maybe<Scalars['Int']>;
  maxBlockBodySizeSum?: Maybe<Scalars['Int']>;
  maxBlockHeaderSizeAvg?: Maybe<Scalars['Float']>;
  maxBlockHeaderSizeMax?: Maybe<Scalars['Int']>;
  maxBlockHeaderSizeMin?: Maybe<Scalars['Int']>;
  maxBlockHeaderSizeSum?: Maybe<Scalars['Int']>;
  maxCollateralInputsAvg?: Maybe<Scalars['Float']>;
  maxCollateralInputsMax?: Maybe<Scalars['Int']>;
  maxCollateralInputsMin?: Maybe<Scalars['Int']>;
  maxCollateralInputsSum?: Maybe<Scalars['Int']>;
  maxTxSizeAvg?: Maybe<Scalars['Float']>;
  maxTxSizeMax?: Maybe<Scalars['Int']>;
  maxTxSizeMin?: Maybe<Scalars['Int']>;
  maxTxSizeSum?: Maybe<Scalars['Int']>;
  maxValSizeAvg?: Maybe<Scalars['Float']>;
  maxValSizeMax?: Maybe<Scalars['Int']>;
  maxValSizeMin?: Maybe<Scalars['Int']>;
  maxValSizeSum?: Maybe<Scalars['Int']>;
  minFeeAAvg?: Maybe<Scalars['Float']>;
  minFeeAMax?: Maybe<Scalars['Int']>;
  minFeeAMin?: Maybe<Scalars['Int']>;
  minFeeASum?: Maybe<Scalars['Int']>;
  minFeeBAvg?: Maybe<Scalars['Float']>;
  minFeeBMax?: Maybe<Scalars['Int']>;
  minFeeBMin?: Maybe<Scalars['Int']>;
  minFeeBSum?: Maybe<Scalars['Int']>;
  minPoolCostAvg?: Maybe<Scalars['Float']>;
  minPoolCostMax?: Maybe<Scalars['Int']>;
  minPoolCostMin?: Maybe<Scalars['Int']>;
  minPoolCostSum?: Maybe<Scalars['Int']>;
  minUTxOValueAvg?: Maybe<Scalars['Float']>;
  minUTxOValueMax?: Maybe<Scalars['Int']>;
  minUTxOValueMin?: Maybe<Scalars['Int']>;
  minUTxOValueSum?: Maybe<Scalars['Int']>;
  nOptAvg?: Maybe<Scalars['Float']>;
  nOptMax?: Maybe<Scalars['Int']>;
  nOptMin?: Maybe<Scalars['Int']>;
  nOptSum?: Maybe<Scalars['Int']>;
  poolDepositAvg?: Maybe<Scalars['Float']>;
  poolDepositMax?: Maybe<Scalars['Int']>;
  poolDepositMin?: Maybe<Scalars['Int']>;
  poolDepositSum?: Maybe<Scalars['Int']>;
  rhoAvg?: Maybe<Scalars['Float']>;
  rhoMax?: Maybe<Scalars['Float']>;
  rhoMin?: Maybe<Scalars['Float']>;
  rhoSum?: Maybe<Scalars['Float']>;
  tauAvg?: Maybe<Scalars['Float']>;
  tauMax?: Maybe<Scalars['Float']>;
  tauMin?: Maybe<Scalars['Float']>;
  tauSum?: Maybe<Scalars['Float']>;
};

export type ProtocolParametersFilter = {
  and?: Maybe<Array<Maybe<ProtocolParametersFilter>>>;
  has?: Maybe<Array<Maybe<ProtocolParametersHasFilter>>>;
  not?: Maybe<ProtocolParametersFilter>;
  or?: Maybe<Array<Maybe<ProtocolParametersFilter>>>;
};

export enum ProtocolParametersHasFilter {
  A0 = 'a0',
  CoinsPerUtxoWord = 'coinsPerUtxoWord',
  CollateralPercent = 'collateralPercent',
  CostModels = 'costModels',
  DecentralizationParam = 'decentralizationParam',
  EMax = 'eMax',
  ExecutionPrices = 'executionPrices',
  ExtraEntropy = 'extraEntropy',
  KeyDeposit = 'keyDeposit',
  MaxBlockBodySize = 'maxBlockBodySize',
  MaxBlockExUnits = 'maxBlockExUnits',
  MaxBlockHeaderSize = 'maxBlockHeaderSize',
  MaxCollateralInputs = 'maxCollateralInputs',
  MaxTxExUnits = 'maxTxExUnits',
  MaxTxSize = 'maxTxSize',
  MaxValSize = 'maxValSize',
  MinFeeA = 'minFeeA',
  MinFeeB = 'minFeeB',
  MinPoolCost = 'minPoolCost',
  MinUTxOValue = 'minUTxOValue',
  NOpt = 'nOpt',
  PoolDeposit = 'poolDeposit',
  ProtocolVersion = 'protocolVersion',
  Rho = 'rho',
  Tau = 'tau'
}

export type ProtocolParametersOrder = {
  asc?: Maybe<ProtocolParametersOrderable>;
  desc?: Maybe<ProtocolParametersOrderable>;
  then?: Maybe<ProtocolParametersOrder>;
};

export enum ProtocolParametersOrderable {
  A0 = 'a0',
  CoinsPerUtxoWord = 'coinsPerUtxoWord',
  CollateralPercent = 'collateralPercent',
  CostModels = 'costModels',
  DecentralizationParam = 'decentralizationParam',
  EMax = 'eMax',
  ExtraEntropy = 'extraEntropy',
  KeyDeposit = 'keyDeposit',
  MaxBlockBodySize = 'maxBlockBodySize',
  MaxBlockHeaderSize = 'maxBlockHeaderSize',
  MaxCollateralInputs = 'maxCollateralInputs',
  MaxTxSize = 'maxTxSize',
  MaxValSize = 'maxValSize',
  MinFeeA = 'minFeeA',
  MinFeeB = 'minFeeB',
  MinPoolCost = 'minPoolCost',
  MinUTxOValue = 'minUTxOValue',
  NOpt = 'nOpt',
  PoolDeposit = 'poolDeposit',
  Rho = 'rho',
  Tau = 'tau'
}

export type ProtocolParametersPatch = {
  a0?: Maybe<Scalars['Float']>;
  coinsPerUtxoWord?: Maybe<Scalars['Int']>;
  collateralPercent?: Maybe<Scalars['Int']>;
  costModels?: Maybe<Scalars['String']>;
  decentralizationParam?: Maybe<Scalars['Float']>;
  eMax?: Maybe<Scalars['Int']>;
  executionPrices?: Maybe<ExecutionPricesRef>;
  extraEntropy?: Maybe<Scalars['String']>;
  keyDeposit?: Maybe<Scalars['Int']>;
  maxBlockBodySize?: Maybe<Scalars['Int']>;
  maxBlockExUnits?: Maybe<ExecutionUnitsRef>;
  maxBlockHeaderSize?: Maybe<Scalars['Int']>;
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxTxExUnits?: Maybe<ExecutionUnitsRef>;
  maxTxSize?: Maybe<Scalars['Int']>;
  maxValSize?: Maybe<Scalars['Int']>;
  minFeeA?: Maybe<Scalars['Int']>;
  minFeeB?: Maybe<Scalars['Int']>;
  minPoolCost?: Maybe<Scalars['Int']>;
  minUTxOValue?: Maybe<Scalars['Int']>;
  nOpt?: Maybe<Scalars['Int']>;
  poolDeposit?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<ProtocolVersionRef>;
  rho?: Maybe<Scalars['Float']>;
  tau?: Maybe<Scalars['Float']>;
};

export type ProtocolParametersRef = {
  a0?: Maybe<Scalars['Float']>;
  coinsPerUtxoWord?: Maybe<Scalars['Int']>;
  collateralPercent?: Maybe<Scalars['Int']>;
  costModels?: Maybe<Scalars['String']>;
  decentralizationParam?: Maybe<Scalars['Float']>;
  eMax?: Maybe<Scalars['Int']>;
  executionPrices?: Maybe<ExecutionPricesRef>;
  extraEntropy?: Maybe<Scalars['String']>;
  keyDeposit?: Maybe<Scalars['Int']>;
  maxBlockBodySize?: Maybe<Scalars['Int']>;
  maxBlockExUnits?: Maybe<ExecutionUnitsRef>;
  maxBlockHeaderSize?: Maybe<Scalars['Int']>;
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxTxExUnits?: Maybe<ExecutionUnitsRef>;
  maxTxSize?: Maybe<Scalars['Int']>;
  maxValSize?: Maybe<Scalars['Int']>;
  minFeeA?: Maybe<Scalars['Int']>;
  minFeeB?: Maybe<Scalars['Int']>;
  minPoolCost?: Maybe<Scalars['Int']>;
  minUTxOValue?: Maybe<Scalars['Int']>;
  nOpt?: Maybe<Scalars['Int']>;
  poolDeposit?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<ProtocolVersionRef>;
  rho?: Maybe<Scalars['Float']>;
  tau?: Maybe<Scalars['Float']>;
};

export type ProtocolVersion = {
  __typename?: 'ProtocolVersion';
  major: Scalars['Int'];
  minor: Scalars['Int'];
  patch?: Maybe<Scalars['Int']>;
};

export type ProtocolVersionAggregateResult = {
  __typename?: 'ProtocolVersionAggregateResult';
  count?: Maybe<Scalars['Int']>;
  majorAvg?: Maybe<Scalars['Float']>;
  majorMax?: Maybe<Scalars['Int']>;
  majorMin?: Maybe<Scalars['Int']>;
  majorSum?: Maybe<Scalars['Int']>;
  minorAvg?: Maybe<Scalars['Float']>;
  minorMax?: Maybe<Scalars['Int']>;
  minorMin?: Maybe<Scalars['Int']>;
  minorSum?: Maybe<Scalars['Int']>;
  patchAvg?: Maybe<Scalars['Float']>;
  patchMax?: Maybe<Scalars['Int']>;
  patchMin?: Maybe<Scalars['Int']>;
  patchSum?: Maybe<Scalars['Int']>;
};

export type ProtocolVersionFilter = {
  and?: Maybe<Array<Maybe<ProtocolVersionFilter>>>;
  has?: Maybe<Array<Maybe<ProtocolVersionHasFilter>>>;
  not?: Maybe<ProtocolVersionFilter>;
  or?: Maybe<Array<Maybe<ProtocolVersionFilter>>>;
};

export enum ProtocolVersionHasFilter {
  Major = 'major',
  Minor = 'minor',
  Patch = 'patch'
}

export type ProtocolVersionOrder = {
  asc?: Maybe<ProtocolVersionOrderable>;
  desc?: Maybe<ProtocolVersionOrderable>;
  then?: Maybe<ProtocolVersionOrder>;
};

export enum ProtocolVersionOrderable {
  Major = 'major',
  Minor = 'minor',
  Patch = 'patch'
}

export type ProtocolVersionPatch = {
  major?: Maybe<Scalars['Int']>;
  minor?: Maybe<Scalars['Int']>;
  patch?: Maybe<Scalars['Int']>;
};

export type ProtocolVersionRef = {
  major?: Maybe<Scalars['Int']>;
  minor?: Maybe<Scalars['Int']>;
  patch?: Maybe<Scalars['Int']>;
};

export type Query = {
  __typename?: 'Query';
  aggregateActiveStake?: Maybe<ActiveStakeAggregateResult>;
  aggregateAda?: Maybe<AdaAggregateResult>;
  aggregateAdaPots?: Maybe<AdaPotsAggregateResult>;
  aggregateAddress?: Maybe<AddressAggregateResult>;
  aggregateAlonzoGenesis?: Maybe<AlonzoGenesisAggregateResult>;
  aggregateAsset?: Maybe<AssetAggregateResult>;
  aggregateAssetSupply?: Maybe<AssetSupplyAggregateResult>;
  aggregateAuxiliaryData?: Maybe<AuxiliaryDataAggregateResult>;
  aggregateAuxiliaryDataBody?: Maybe<AuxiliaryDataBodyAggregateResult>;
  aggregateBlock?: Maybe<BlockAggregateResult>;
  aggregateByronBlockVersionData?: Maybe<ByronBlockVersionDataAggregateResult>;
  aggregateByronGenesis?: Maybe<ByronGenesisAggregateResult>;
  aggregateByronProtocolConsts?: Maybe<ByronProtocolConstsAggregateResult>;
  aggregateByronSoftForkRule?: Maybe<ByronSoftForkRuleAggregateResult>;
  aggregateByronTxFeePolicy?: Maybe<ByronTxFeePolicyAggregateResult>;
  aggregateBytesMetadatum?: Maybe<BytesMetadatumAggregateResult>;
  aggregateEpoch?: Maybe<EpochAggregateResult>;
  aggregateExecutionPrice?: Maybe<ExecutionPriceAggregateResult>;
  aggregateExecutionPrices?: Maybe<ExecutionPricesAggregateResult>;
  aggregateExecutionUnits?: Maybe<ExecutionUnitsAggregateResult>;
  aggregateExtendedStakePoolMetadata?: Maybe<ExtendedStakePoolMetadataAggregateResult>;
  aggregateExtendedStakePoolMetadataFields?: Maybe<ExtendedStakePoolMetadataFieldsAggregateResult>;
  aggregateFraction?: Maybe<FractionAggregateResult>;
  aggregateGenesis?: Maybe<GenesisAggregateResult>;
  aggregateITNVerification?: Maybe<ItnVerificationAggregateResult>;
  aggregateIntegerMetadatum?: Maybe<IntegerMetadatumAggregateResult>;
  aggregateKeyValueMetadatum?: Maybe<KeyValueMetadatumAggregateResult>;
  aggregateMetadatumArray?: Maybe<MetadatumArrayAggregateResult>;
  aggregateMetadatumMap?: Maybe<MetadatumMapAggregateResult>;
  aggregatePoolContactData?: Maybe<PoolContactDataAggregateResult>;
  aggregateProtocolParameters?: Maybe<ProtocolParametersAggregateResult>;
  aggregateProtocolVersion?: Maybe<ProtocolVersionAggregateResult>;
  aggregateRedeemer?: Maybe<RedeemerAggregateResult>;
  aggregateRelayByAddress?: Maybe<RelayByAddressAggregateResult>;
  aggregateRelayByName?: Maybe<RelayByNameAggregateResult>;
  aggregateRelayByNameMultihost?: Maybe<RelayByNameMultihostAggregateResult>;
  aggregateRewardAccount?: Maybe<RewardAccountAggregateResult>;
  aggregateScript?: Maybe<ScriptAggregateResult>;
  aggregateShelleyGenesis?: Maybe<ShelleyGenesisAggregateResult>;
  aggregateShelleyGenesisStaking?: Maybe<ShelleyGenesisStakingAggregateResult>;
  aggregateSlot?: Maybe<SlotAggregateResult>;
  aggregateStakePool?: Maybe<StakePoolAggregateResult>;
  aggregateStakePoolMetadata?: Maybe<StakePoolMetadataAggregateResult>;
  aggregateStakePoolMetadataJson?: Maybe<StakePoolMetadataJsonAggregateResult>;
  aggregateStakePoolMetrics?: Maybe<StakePoolMetricsAggregateResult>;
  aggregateStakePoolMetricsSize?: Maybe<StakePoolMetricsSizeAggregateResult>;
  aggregateStakePoolMetricsStake?: Maybe<StakePoolMetricsStakeAggregateResult>;
  aggregateStakePoolTransactions?: Maybe<StakePoolTransactionsAggregateResult>;
  aggregateStringMetadatum?: Maybe<StringMetadatumAggregateResult>;
  aggregateThePoolsMediaAssets?: Maybe<ThePoolsMediaAssetsAggregateResult>;
  aggregateToken?: Maybe<TokenAggregateResult>;
  aggregateTransaction?: Maybe<TransactionAggregateResult>;
  aggregateTransactionInput?: Maybe<TransactionInputAggregateResult>;
  aggregateTransactionOutput?: Maybe<TransactionOutputAggregateResult>;
  aggregateValue?: Maybe<ValueAggregateResult>;
  aggregateWithdrawal?: Maybe<WithdrawalAggregateResult>;
  getBlock?: Maybe<Block>;
  getEpoch?: Maybe<Epoch>;
  getExtendedStakePoolMetadataFields?: Maybe<ExtendedStakePoolMetadataFields>;
  getScript?: Maybe<Script>;
  getSlot?: Maybe<Slot>;
  getStakePool?: Maybe<StakePool>;
  getStakePoolMetadata?: Maybe<StakePoolMetadata>;
  getTransaction?: Maybe<Transaction>;
  queryActiveStake?: Maybe<Array<Maybe<ActiveStake>>>;
  queryAda?: Maybe<Array<Maybe<Ada>>>;
  queryAdaPots?: Maybe<Array<Maybe<AdaPots>>>;
  queryAddress?: Maybe<Array<Maybe<Address>>>;
  queryAlonzoGenesis?: Maybe<Array<Maybe<AlonzoGenesis>>>;
  queryAsset?: Maybe<Array<Maybe<Asset>>>;
  queryAssetSupply?: Maybe<Array<Maybe<AssetSupply>>>;
  queryAuxiliaryData?: Maybe<Array<Maybe<AuxiliaryData>>>;
  queryAuxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  queryBlock?: Maybe<Array<Maybe<Block>>>;
  queryByronBlockVersionData?: Maybe<Array<Maybe<ByronBlockVersionData>>>;
  queryByronGenesis?: Maybe<Array<Maybe<ByronGenesis>>>;
  queryByronProtocolConsts?: Maybe<Array<Maybe<ByronProtocolConsts>>>;
  queryByronSoftForkRule?: Maybe<Array<Maybe<ByronSoftForkRule>>>;
  queryByronTxFeePolicy?: Maybe<Array<Maybe<ByronTxFeePolicy>>>;
  queryBytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  queryEpoch?: Maybe<Array<Maybe<Epoch>>>;
  queryExecutionPrice?: Maybe<Array<Maybe<ExecutionPrice>>>;
  queryExecutionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  queryExecutionUnits?: Maybe<Array<Maybe<ExecutionUnits>>>;
  queryExtendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  queryExtendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  queryFraction?: Maybe<Array<Maybe<Fraction>>>;
  queryGenesis?: Maybe<Array<Maybe<Genesis>>>;
  queryITNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  queryIntegerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  queryKeyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  queryMetadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  queryMetadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  queryPoolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
  queryProtocolParameters?: Maybe<Array<Maybe<ProtocolParameters>>>;
  queryProtocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
  queryRedeemer?: Maybe<Array<Maybe<Redeemer>>>;
  queryRelayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
  queryRelayByName?: Maybe<Array<Maybe<RelayByName>>>;
  queryRelayByNameMultihost?: Maybe<Array<Maybe<RelayByNameMultihost>>>;
  queryRewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
  queryScript?: Maybe<Array<Maybe<Script>>>;
  queryShelleyGenesis?: Maybe<Array<Maybe<ShelleyGenesis>>>;
  queryShelleyGenesisStaking?: Maybe<Array<Maybe<ShelleyGenesisStaking>>>;
  querySlot?: Maybe<Array<Maybe<Slot>>>;
  queryStakePool?: Maybe<Array<Maybe<StakePool>>>;
  queryStakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
  queryStakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
  queryStakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
  queryStakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
  queryStakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
  queryStakePoolTransactions?: Maybe<Array<Maybe<StakePoolTransactions>>>;
  queryStringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
  queryThePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
  queryToken?: Maybe<Array<Maybe<Token>>>;
  queryTransaction?: Maybe<Array<Maybe<Transaction>>>;
  queryTransactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
  queryTransactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
  queryValue?: Maybe<Array<Maybe<Value>>>;
  queryWithdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
};


export type QueryAggregateActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
};


export type QueryAggregateAdaArgs = {
  filter?: Maybe<AdaFilter>;
};


export type QueryAggregateAdaPotsArgs = {
  filter?: Maybe<AdaPotsFilter>;
};


export type QueryAggregateAddressArgs = {
  filter?: Maybe<AddressFilter>;
};


export type QueryAggregateAlonzoGenesisArgs = {
  filter?: Maybe<AlonzoGenesisFilter>;
};


export type QueryAggregateAssetArgs = {
  filter?: Maybe<AssetFilter>;
};


export type QueryAggregateAssetSupplyArgs = {
  filter?: Maybe<AssetSupplyFilter>;
};


export type QueryAggregateAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
};


export type QueryAggregateAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
};


export type QueryAggregateBlockArgs = {
  filter?: Maybe<BlockFilter>;
};


export type QueryAggregateByronBlockVersionDataArgs = {
  filter?: Maybe<ByronBlockVersionDataFilter>;
};


export type QueryAggregateByronGenesisArgs = {
  filter?: Maybe<ByronGenesisFilter>;
};


export type QueryAggregateByronProtocolConstsArgs = {
  filter?: Maybe<ByronProtocolConstsFilter>;
};


export type QueryAggregateByronSoftForkRuleArgs = {
  filter?: Maybe<ByronSoftForkRuleFilter>;
};


export type QueryAggregateByronTxFeePolicyArgs = {
  filter?: Maybe<ByronTxFeePolicyFilter>;
};


export type QueryAggregateBytesMetadatumArgs = {
  filter?: Maybe<BytesMetadatumFilter>;
};


export type QueryAggregateEpochArgs = {
  filter?: Maybe<EpochFilter>;
};


export type QueryAggregateExecutionPriceArgs = {
  filter?: Maybe<ExecutionPriceFilter>;
};


export type QueryAggregateExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
};


export type QueryAggregateExecutionUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type QueryAggregateExtendedStakePoolMetadataArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
};


export type QueryAggregateExtendedStakePoolMetadataFieldsArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
};


export type QueryAggregateFractionArgs = {
  filter?: Maybe<FractionFilter>;
};


export type QueryAggregateGenesisArgs = {
  filter?: Maybe<GenesisFilter>;
};


export type QueryAggregateItnVerificationArgs = {
  filter?: Maybe<ItnVerificationFilter>;
};


export type QueryAggregateIntegerMetadatumArgs = {
  filter?: Maybe<IntegerMetadatumFilter>;
};


export type QueryAggregateKeyValueMetadatumArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
};


export type QueryAggregateMetadatumArrayArgs = {
  filter?: Maybe<MetadatumArrayFilter>;
};


export type QueryAggregateMetadatumMapArgs = {
  filter?: Maybe<MetadatumMapFilter>;
};


export type QueryAggregatePoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
};


export type QueryAggregateProtocolParametersArgs = {
  filter?: Maybe<ProtocolParametersFilter>;
};


export type QueryAggregateProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
};


export type QueryAggregateRedeemerArgs = {
  filter?: Maybe<RedeemerFilter>;
};


export type QueryAggregateRelayByAddressArgs = {
  filter?: Maybe<RelayByAddressFilter>;
};


export type QueryAggregateRelayByNameArgs = {
  filter?: Maybe<RelayByNameFilter>;
};


export type QueryAggregateRelayByNameMultihostArgs = {
  filter?: Maybe<RelayByNameMultihostFilter>;
};


export type QueryAggregateRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type QueryAggregateScriptArgs = {
  filter?: Maybe<ScriptFilter>;
};


export type QueryAggregateShelleyGenesisArgs = {
  filter?: Maybe<ShelleyGenesisFilter>;
};


export type QueryAggregateShelleyGenesisStakingArgs = {
  filter?: Maybe<ShelleyGenesisStakingFilter>;
};


export type QueryAggregateSlotArgs = {
  filter?: Maybe<SlotFilter>;
};


export type QueryAggregateStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
};


export type QueryAggregateStakePoolMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
};


export type QueryAggregateStakePoolMetadataJsonArgs = {
  filter?: Maybe<StakePoolMetadataJsonFilter>;
};


export type QueryAggregateStakePoolMetricsArgs = {
  filter?: Maybe<StakePoolMetricsFilter>;
};


export type QueryAggregateStakePoolMetricsSizeArgs = {
  filter?: Maybe<StakePoolMetricsSizeFilter>;
};


export type QueryAggregateStakePoolMetricsStakeArgs = {
  filter?: Maybe<StakePoolMetricsStakeFilter>;
};


export type QueryAggregateStakePoolTransactionsArgs = {
  filter?: Maybe<StakePoolTransactionsFilter>;
};


export type QueryAggregateStringMetadatumArgs = {
  filter?: Maybe<StringMetadatumFilter>;
};


export type QueryAggregateThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
};


export type QueryAggregateTokenArgs = {
  filter?: Maybe<TokenFilter>;
};


export type QueryAggregateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};


export type QueryAggregateTransactionInputArgs = {
  filter?: Maybe<TransactionInputFilter>;
};


export type QueryAggregateTransactionOutputArgs = {
  filter?: Maybe<TransactionOutputFilter>;
};


export type QueryAggregateValueArgs = {
  filter?: Maybe<ValueFilter>;
};


export type QueryAggregateWithdrawalArgs = {
  filter?: Maybe<WithdrawalFilter>;
};


export type QueryGetBlockArgs = {
  hash: Scalars['String'];
};


export type QueryGetEpochArgs = {
  number: Scalars['Int'];
};


export type QueryGetExtendedStakePoolMetadataFieldsArgs = {
  id: Scalars['String'];
};


export type QueryGetScriptArgs = {
  hash: Scalars['String'];
};


export type QueryGetSlotArgs = {
  number: Scalars['Int'];
};


export type QueryGetStakePoolArgs = {
  id: Scalars['String'];
};


export type QueryGetStakePoolMetadataArgs = {
  stakePoolId: Scalars['String'];
};


export type QueryGetTransactionArgs = {
  hash: Scalars['String'];
};


export type QueryQueryActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ActiveStakeOrder>;
};


export type QueryQueryAdaArgs = {
  filter?: Maybe<AdaFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryAdaPotsArgs = {
  filter?: Maybe<AdaPotsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AdaPotsOrder>;
};


export type QueryQueryAddressArgs = {
  filter?: Maybe<AddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AddressOrder>;
};


export type QueryQueryAlonzoGenesisArgs = {
  filter?: Maybe<AlonzoGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AlonzoGenesisOrder>;
};


export type QueryQueryAssetArgs = {
  filter?: Maybe<AssetFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetOrder>;
};


export type QueryQueryAssetSupplyArgs = {
  filter?: Maybe<AssetSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetSupplyOrder>;
};


export type QueryQueryAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AuxiliaryDataOrder>;
};


export type QueryQueryAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryBlockArgs = {
  filter?: Maybe<BlockFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BlockOrder>;
};


export type QueryQueryByronBlockVersionDataArgs = {
  filter?: Maybe<ByronBlockVersionDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronBlockVersionDataOrder>;
};


export type QueryQueryByronGenesisArgs = {
  filter?: Maybe<ByronGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronGenesisOrder>;
};


export type QueryQueryByronProtocolConstsArgs = {
  filter?: Maybe<ByronProtocolConstsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronProtocolConstsOrder>;
};


export type QueryQueryByronSoftForkRuleArgs = {
  filter?: Maybe<ByronSoftForkRuleFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronSoftForkRuleOrder>;
};


export type QueryQueryByronTxFeePolicyArgs = {
  filter?: Maybe<ByronTxFeePolicyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronTxFeePolicyOrder>;
};


export type QueryQueryBytesMetadatumArgs = {
  filter?: Maybe<BytesMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BytesMetadatumOrder>;
};


export type QueryQueryEpochArgs = {
  filter?: Maybe<EpochFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<EpochOrder>;
};


export type QueryQueryExecutionPriceArgs = {
  filter?: Maybe<ExecutionPriceFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionPriceOrder>;
};


export type QueryQueryExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryExecutionUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionUnitsOrder>;
};


export type QueryQueryExtendedStakePoolMetadataArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataOrder>;
};


export type QueryQueryExtendedStakePoolMetadataFieldsArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataFieldsOrder>;
};


export type QueryQueryFractionArgs = {
  filter?: Maybe<FractionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<FractionOrder>;
};


export type QueryQueryGenesisArgs = {
  filter?: Maybe<GenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryItnVerificationArgs = {
  filter?: Maybe<ItnVerificationFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ItnVerificationOrder>;
};


export type QueryQueryIntegerMetadatumArgs = {
  filter?: Maybe<IntegerMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<IntegerMetadatumOrder>;
};


export type QueryQueryKeyValueMetadatumArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<KeyValueMetadatumOrder>;
};


export type QueryQueryMetadatumArrayArgs = {
  filter?: Maybe<MetadatumArrayFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryMetadatumMapArgs = {
  filter?: Maybe<MetadatumMapFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryPoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolContactDataOrder>;
};


export type QueryQueryProtocolParametersArgs = {
  filter?: Maybe<ProtocolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersOrder>;
};


export type QueryQueryProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolVersionOrder>;
};


export type QueryQueryRedeemerArgs = {
  filter?: Maybe<RedeemerFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RedeemerOrder>;
};


export type QueryQueryRelayByAddressArgs = {
  filter?: Maybe<RelayByAddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByAddressOrder>;
};


export type QueryQueryRelayByNameArgs = {
  filter?: Maybe<RelayByNameFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameOrder>;
};


export type QueryQueryRelayByNameMultihostArgs = {
  filter?: Maybe<RelayByNameMultihostFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameMultihostOrder>;
};


export type QueryQueryRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RewardAccountOrder>;
};


export type QueryQueryScriptArgs = {
  filter?: Maybe<ScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ScriptOrder>;
};


export type QueryQueryShelleyGenesisArgs = {
  filter?: Maybe<ShelleyGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisOrder>;
};


export type QueryQueryShelleyGenesisStakingArgs = {
  filter?: Maybe<ShelleyGenesisStakingFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisStakingOrder>;
};


export type QueryQuerySlotArgs = {
  filter?: Maybe<SlotFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SlotOrder>;
};


export type QueryQueryStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolOrder>;
};


export type QueryQueryStakePoolMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataOrder>;
};


export type QueryQueryStakePoolMetadataJsonArgs = {
  filter?: Maybe<StakePoolMetadataJsonFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataJsonOrder>;
};


export type QueryQueryStakePoolMetricsArgs = {
  filter?: Maybe<StakePoolMetricsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsOrder>;
};


export type QueryQueryStakePoolMetricsSizeArgs = {
  filter?: Maybe<StakePoolMetricsSizeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsSizeOrder>;
};


export type QueryQueryStakePoolMetricsStakeArgs = {
  filter?: Maybe<StakePoolMetricsStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsStakeOrder>;
};


export type QueryQueryStakePoolTransactionsArgs = {
  filter?: Maybe<StakePoolTransactionsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryStringMetadatumArgs = {
  filter?: Maybe<StringMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StringMetadatumOrder>;
};


export type QueryQueryThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ThePoolsMediaAssetsOrder>;
};


export type QueryQueryTokenArgs = {
  filter?: Maybe<TokenFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TokenOrder>;
};


export type QueryQueryTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOrder>;
};


export type QueryQueryTransactionInputArgs = {
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};


export type QueryQueryTransactionOutputArgs = {
  filter?: Maybe<TransactionOutputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOutputOrder>;
};


export type QueryQueryValueArgs = {
  filter?: Maybe<ValueFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ValueOrder>;
};


export type QueryQueryWithdrawalArgs = {
  filter?: Maybe<WithdrawalFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WithdrawalOrder>;
};

export type Redeemer = {
  __typename?: 'Redeemer';
  executionUnits: ExecutionUnits;
  fee: Scalars['Int64'];
  index: Scalars['Int'];
  purpose: Scalars['String'];
  scriptHash: Scalars['String'];
  transaction: Transaction;
};


export type RedeemerExecutionUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type RedeemerTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type RedeemerAggregateResult = {
  __typename?: 'RedeemerAggregateResult';
  count?: Maybe<Scalars['Int']>;
  feeAvg?: Maybe<Scalars['Float']>;
  feeMax?: Maybe<Scalars['Int64']>;
  feeMin?: Maybe<Scalars['Int64']>;
  feeSum?: Maybe<Scalars['Int64']>;
  indexAvg?: Maybe<Scalars['Float']>;
  indexMax?: Maybe<Scalars['Int']>;
  indexMin?: Maybe<Scalars['Int']>;
  indexSum?: Maybe<Scalars['Int']>;
  purposeMax?: Maybe<Scalars['String']>;
  purposeMin?: Maybe<Scalars['String']>;
  scriptHashMax?: Maybe<Scalars['String']>;
  scriptHashMin?: Maybe<Scalars['String']>;
};

export type RedeemerFilter = {
  and?: Maybe<Array<Maybe<RedeemerFilter>>>;
  has?: Maybe<Array<Maybe<RedeemerHasFilter>>>;
  not?: Maybe<RedeemerFilter>;
  or?: Maybe<Array<Maybe<RedeemerFilter>>>;
};

export enum RedeemerHasFilter {
  ExecutionUnits = 'executionUnits',
  Fee = 'fee',
  Index = 'index',
  Purpose = 'purpose',
  ScriptHash = 'scriptHash',
  Transaction = 'transaction'
}

export type RedeemerOrder = {
  asc?: Maybe<RedeemerOrderable>;
  desc?: Maybe<RedeemerOrderable>;
  then?: Maybe<RedeemerOrder>;
};

export enum RedeemerOrderable {
  Fee = 'fee',
  Index = 'index',
  Purpose = 'purpose',
  ScriptHash = 'scriptHash'
}

export type RedeemerPatch = {
  executionUnits?: Maybe<ExecutionUnitsRef>;
  fee?: Maybe<Scalars['Int64']>;
  index?: Maybe<Scalars['Int']>;
  purpose?: Maybe<Scalars['String']>;
  scriptHash?: Maybe<Scalars['String']>;
  transaction?: Maybe<TransactionRef>;
};

export type RedeemerRef = {
  executionUnits?: Maybe<ExecutionUnitsRef>;
  fee?: Maybe<Scalars['Int64']>;
  index?: Maybe<Scalars['Int']>;
  purpose?: Maybe<Scalars['String']>;
  scriptHash?: Maybe<Scalars['String']>;
  transaction?: Maybe<TransactionRef>;
};

export type RelayByAddress = {
  __typename?: 'RelayByAddress';
  ipv4?: Maybe<Scalars['String']>;
  ipv6?: Maybe<Scalars['String']>;
  port?: Maybe<Scalars['Int']>;
};

export type RelayByAddressAggregateResult = {
  __typename?: 'RelayByAddressAggregateResult';
  count?: Maybe<Scalars['Int']>;
  ipv4Max?: Maybe<Scalars['String']>;
  ipv4Min?: Maybe<Scalars['String']>;
  ipv6Max?: Maybe<Scalars['String']>;
  ipv6Min?: Maybe<Scalars['String']>;
  portAvg?: Maybe<Scalars['Float']>;
  portMax?: Maybe<Scalars['Int']>;
  portMin?: Maybe<Scalars['Int']>;
  portSum?: Maybe<Scalars['Int']>;
};

export type RelayByAddressFilter = {
  and?: Maybe<Array<Maybe<RelayByAddressFilter>>>;
  has?: Maybe<Array<Maybe<RelayByAddressHasFilter>>>;
  not?: Maybe<RelayByAddressFilter>;
  or?: Maybe<Array<Maybe<RelayByAddressFilter>>>;
};

export enum RelayByAddressHasFilter {
  Ipv4 = 'ipv4',
  Ipv6 = 'ipv6',
  Port = 'port'
}

export type RelayByAddressOrder = {
  asc?: Maybe<RelayByAddressOrderable>;
  desc?: Maybe<RelayByAddressOrderable>;
  then?: Maybe<RelayByAddressOrder>;
};

export enum RelayByAddressOrderable {
  Ipv4 = 'ipv4',
  Ipv6 = 'ipv6',
  Port = 'port'
}

export type RelayByAddressPatch = {
  ipv4?: Maybe<Scalars['String']>;
  ipv6?: Maybe<Scalars['String']>;
  port?: Maybe<Scalars['Int']>;
};

export type RelayByAddressRef = {
  ipv4?: Maybe<Scalars['String']>;
  ipv6?: Maybe<Scalars['String']>;
  port?: Maybe<Scalars['Int']>;
};

export type RelayByName = {
  __typename?: 'RelayByName';
  hostname: Scalars['String'];
  port?: Maybe<Scalars['Int']>;
};

export type RelayByNameAggregateResult = {
  __typename?: 'RelayByNameAggregateResult';
  count?: Maybe<Scalars['Int']>;
  hostnameMax?: Maybe<Scalars['String']>;
  hostnameMin?: Maybe<Scalars['String']>;
  portAvg?: Maybe<Scalars['Float']>;
  portMax?: Maybe<Scalars['Int']>;
  portMin?: Maybe<Scalars['Int']>;
  portSum?: Maybe<Scalars['Int']>;
};

export type RelayByNameFilter = {
  and?: Maybe<Array<Maybe<RelayByNameFilter>>>;
  has?: Maybe<Array<Maybe<RelayByNameHasFilter>>>;
  not?: Maybe<RelayByNameFilter>;
  or?: Maybe<Array<Maybe<RelayByNameFilter>>>;
};

export enum RelayByNameHasFilter {
  Hostname = 'hostname',
  Port = 'port'
}

export type RelayByNameMultihost = {
  __typename?: 'RelayByNameMultihost';
  dnsName: Scalars['String'];
};

export type RelayByNameMultihostAggregateResult = {
  __typename?: 'RelayByNameMultihostAggregateResult';
  count?: Maybe<Scalars['Int']>;
  dnsNameMax?: Maybe<Scalars['String']>;
  dnsNameMin?: Maybe<Scalars['String']>;
};

export type RelayByNameMultihostFilter = {
  and?: Maybe<Array<Maybe<RelayByNameMultihostFilter>>>;
  has?: Maybe<Array<Maybe<RelayByNameMultihostHasFilter>>>;
  not?: Maybe<RelayByNameMultihostFilter>;
  or?: Maybe<Array<Maybe<RelayByNameMultihostFilter>>>;
};

export enum RelayByNameMultihostHasFilter {
  DnsName = 'dnsName'
}

export type RelayByNameMultihostOrder = {
  asc?: Maybe<RelayByNameMultihostOrderable>;
  desc?: Maybe<RelayByNameMultihostOrderable>;
  then?: Maybe<RelayByNameMultihostOrder>;
};

export enum RelayByNameMultihostOrderable {
  DnsName = 'dnsName'
}

export type RelayByNameMultihostPatch = {
  dnsName?: Maybe<Scalars['String']>;
};

export type RelayByNameMultihostRef = {
  dnsName?: Maybe<Scalars['String']>;
};

export type RelayByNameOrder = {
  asc?: Maybe<RelayByNameOrderable>;
  desc?: Maybe<RelayByNameOrderable>;
  then?: Maybe<RelayByNameOrder>;
};

export enum RelayByNameOrderable {
  Hostname = 'hostname',
  Port = 'port'
}

export type RelayByNamePatch = {
  hostname?: Maybe<Scalars['String']>;
  port?: Maybe<Scalars['Int']>;
};

export type RelayByNameRef = {
  hostname?: Maybe<Scalars['String']>;
  port?: Maybe<Scalars['Int']>;
};

export type RewardAccount = {
  __typename?: 'RewardAccount';
  activeStake: ActiveStake;
  address: Scalars['String'];
  addresses: Address;
};


export type RewardAccountActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
};


export type RewardAccountAddressesArgs = {
  filter?: Maybe<AddressFilter>;
};

export type RewardAccountAggregateResult = {
  __typename?: 'RewardAccountAggregateResult';
  addressMax?: Maybe<Scalars['String']>;
  addressMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
};

export type RewardAccountFilter = {
  and?: Maybe<Array<Maybe<RewardAccountFilter>>>;
  has?: Maybe<Array<Maybe<RewardAccountHasFilter>>>;
  not?: Maybe<RewardAccountFilter>;
  or?: Maybe<Array<Maybe<RewardAccountFilter>>>;
};

export enum RewardAccountHasFilter {
  ActiveStake = 'activeStake',
  Address = 'address',
  Addresses = 'addresses'
}

export type RewardAccountOrder = {
  asc?: Maybe<RewardAccountOrderable>;
  desc?: Maybe<RewardAccountOrderable>;
  then?: Maybe<RewardAccountOrder>;
};

export enum RewardAccountOrderable {
  Address = 'address'
}

export type RewardAccountPatch = {
  activeStake?: Maybe<ActiveStakeRef>;
  address?: Maybe<Scalars['String']>;
  addresses?: Maybe<AddressRef>;
};

export type RewardAccountRef = {
  activeStake?: Maybe<ActiveStakeRef>;
  address?: Maybe<Scalars['String']>;
  addresses?: Maybe<AddressRef>;
};

export type Script = {
  __typename?: 'Script';
  auxiliaryDataBody: AuxiliaryDataBody;
  hash: Scalars['String'];
  serializedSize: Scalars['Int64'];
  type: Scalars['String'];
};


export type ScriptAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
};

export type ScriptAggregateResult = {
  __typename?: 'ScriptAggregateResult';
  count?: Maybe<Scalars['Int']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
  serializedSizeAvg?: Maybe<Scalars['Float']>;
  serializedSizeMax?: Maybe<Scalars['Int64']>;
  serializedSizeMin?: Maybe<Scalars['Int64']>;
  serializedSizeSum?: Maybe<Scalars['Int64']>;
  typeMax?: Maybe<Scalars['String']>;
  typeMin?: Maybe<Scalars['String']>;
};

export type ScriptFilter = {
  and?: Maybe<Array<Maybe<ScriptFilter>>>;
  has?: Maybe<Array<Maybe<ScriptHasFilter>>>;
  hash?: Maybe<StringHashFilter>;
  not?: Maybe<ScriptFilter>;
  or?: Maybe<Array<Maybe<ScriptFilter>>>;
};

export enum ScriptHasFilter {
  AuxiliaryDataBody = 'auxiliaryDataBody',
  Hash = 'hash',
  SerializedSize = 'serializedSize',
  Type = 'type'
}

export type ScriptOrder = {
  asc?: Maybe<ScriptOrderable>;
  desc?: Maybe<ScriptOrderable>;
  then?: Maybe<ScriptOrder>;
};

export enum ScriptOrderable {
  Hash = 'hash',
  SerializedSize = 'serializedSize',
  Type = 'type'
}

export type ScriptPatch = {
  auxiliaryDataBody?: Maybe<AuxiliaryDataBodyRef>;
  serializedSize?: Maybe<Scalars['Int64']>;
  type?: Maybe<Scalars['String']>;
};

export type ScriptRef = {
  auxiliaryDataBody?: Maybe<AuxiliaryDataBodyRef>;
  hash?: Maybe<Scalars['String']>;
  serializedSize?: Maybe<Scalars['Int64']>;
  type?: Maybe<Scalars['String']>;
};

export type SearchResult = RelayByAddress | RelayByName | RelayByNameMultihost;

export type SearchResultFilter = {
  memberTypes?: Maybe<Array<SearchResultType>>;
  relayByAddressFilter?: Maybe<RelayByAddressFilter>;
  relayByNameFilter?: Maybe<RelayByNameFilter>;
  relayByNameMultihostFilter?: Maybe<RelayByNameMultihostFilter>;
};

export type SearchResultRef = {
  relayByAddressRef?: Maybe<RelayByAddressRef>;
  relayByNameMultihostRef?: Maybe<RelayByNameMultihostRef>;
  relayByNameRef?: Maybe<RelayByNameRef>;
};

export enum SearchResultType {
  RelayByAddress = 'RelayByAddress',
  RelayByName = 'RelayByName',
  RelayByNameMultihost = 'RelayByNameMultihost'
}

export type ShelleyGenesis = {
  __typename?: 'ShelleyGenesis';
  activeSlotsCoeff: Scalars['Float'];
  epochLength: Scalars['Int'];
  genDelegs?: Maybe<Scalars['String']>;
  initialFunds: Scalars['String'];
  maxKESEvolutions: Scalars['Int'];
  maxLovelaceSupply: Scalars['Int64'];
  networkId: Scalars['String'];
  networkMagic: Scalars['Int'];
  protocolParams: ProtocolParameters;
  securityParam: Scalars['Int'];
  slotLength: Scalars['Int'];
  slotsPerKESPeriod: Scalars['Int'];
  staking: ShelleyGenesisStaking;
  systemStart: Scalars['DateTime'];
  updateQuorum: Scalars['Int'];
};


export type ShelleyGenesisProtocolParamsArgs = {
  filter?: Maybe<ProtocolParametersFilter>;
};


export type ShelleyGenesisStakingArgs = {
  filter?: Maybe<ShelleyGenesisStakingFilter>;
};

export type ShelleyGenesisAggregateResult = {
  __typename?: 'ShelleyGenesisAggregateResult';
  activeSlotsCoeffAvg?: Maybe<Scalars['Float']>;
  activeSlotsCoeffMax?: Maybe<Scalars['Float']>;
  activeSlotsCoeffMin?: Maybe<Scalars['Float']>;
  activeSlotsCoeffSum?: Maybe<Scalars['Float']>;
  count?: Maybe<Scalars['Int']>;
  epochLengthAvg?: Maybe<Scalars['Float']>;
  epochLengthMax?: Maybe<Scalars['Int']>;
  epochLengthMin?: Maybe<Scalars['Int']>;
  epochLengthSum?: Maybe<Scalars['Int']>;
  genDelegsMax?: Maybe<Scalars['String']>;
  genDelegsMin?: Maybe<Scalars['String']>;
  initialFundsMax?: Maybe<Scalars['String']>;
  initialFundsMin?: Maybe<Scalars['String']>;
  maxKESEvolutionsAvg?: Maybe<Scalars['Float']>;
  maxKESEvolutionsMax?: Maybe<Scalars['Int']>;
  maxKESEvolutionsMin?: Maybe<Scalars['Int']>;
  maxKESEvolutionsSum?: Maybe<Scalars['Int']>;
  maxLovelaceSupplyAvg?: Maybe<Scalars['Float']>;
  maxLovelaceSupplyMax?: Maybe<Scalars['Int64']>;
  maxLovelaceSupplyMin?: Maybe<Scalars['Int64']>;
  maxLovelaceSupplySum?: Maybe<Scalars['Int64']>;
  networkIdMax?: Maybe<Scalars['String']>;
  networkIdMin?: Maybe<Scalars['String']>;
  networkMagicAvg?: Maybe<Scalars['Float']>;
  networkMagicMax?: Maybe<Scalars['Int']>;
  networkMagicMin?: Maybe<Scalars['Int']>;
  networkMagicSum?: Maybe<Scalars['Int']>;
  securityParamAvg?: Maybe<Scalars['Float']>;
  securityParamMax?: Maybe<Scalars['Int']>;
  securityParamMin?: Maybe<Scalars['Int']>;
  securityParamSum?: Maybe<Scalars['Int']>;
  slotLengthAvg?: Maybe<Scalars['Float']>;
  slotLengthMax?: Maybe<Scalars['Int']>;
  slotLengthMin?: Maybe<Scalars['Int']>;
  slotLengthSum?: Maybe<Scalars['Int']>;
  slotsPerKESPeriodAvg?: Maybe<Scalars['Float']>;
  slotsPerKESPeriodMax?: Maybe<Scalars['Int']>;
  slotsPerKESPeriodMin?: Maybe<Scalars['Int']>;
  slotsPerKESPeriodSum?: Maybe<Scalars['Int']>;
  systemStartMax?: Maybe<Scalars['DateTime']>;
  systemStartMin?: Maybe<Scalars['DateTime']>;
  updateQuorumAvg?: Maybe<Scalars['Float']>;
  updateQuorumMax?: Maybe<Scalars['Int']>;
  updateQuorumMin?: Maybe<Scalars['Int']>;
  updateQuorumSum?: Maybe<Scalars['Int']>;
};

export type ShelleyGenesisFilter = {
  and?: Maybe<Array<Maybe<ShelleyGenesisFilter>>>;
  has?: Maybe<Array<Maybe<ShelleyGenesisHasFilter>>>;
  not?: Maybe<ShelleyGenesisFilter>;
  or?: Maybe<Array<Maybe<ShelleyGenesisFilter>>>;
};

export enum ShelleyGenesisHasFilter {
  ActiveSlotsCoeff = 'activeSlotsCoeff',
  EpochLength = 'epochLength',
  GenDelegs = 'genDelegs',
  InitialFunds = 'initialFunds',
  MaxKesEvolutions = 'maxKESEvolutions',
  MaxLovelaceSupply = 'maxLovelaceSupply',
  NetworkId = 'networkId',
  NetworkMagic = 'networkMagic',
  ProtocolParams = 'protocolParams',
  SecurityParam = 'securityParam',
  SlotLength = 'slotLength',
  SlotsPerKesPeriod = 'slotsPerKESPeriod',
  Staking = 'staking',
  SystemStart = 'systemStart',
  UpdateQuorum = 'updateQuorum'
}

export type ShelleyGenesisOrder = {
  asc?: Maybe<ShelleyGenesisOrderable>;
  desc?: Maybe<ShelleyGenesisOrderable>;
  then?: Maybe<ShelleyGenesisOrder>;
};

export enum ShelleyGenesisOrderable {
  ActiveSlotsCoeff = 'activeSlotsCoeff',
  EpochLength = 'epochLength',
  GenDelegs = 'genDelegs',
  InitialFunds = 'initialFunds',
  MaxKesEvolutions = 'maxKESEvolutions',
  MaxLovelaceSupply = 'maxLovelaceSupply',
  NetworkId = 'networkId',
  NetworkMagic = 'networkMagic',
  SecurityParam = 'securityParam',
  SlotLength = 'slotLength',
  SlotsPerKesPeriod = 'slotsPerKESPeriod',
  SystemStart = 'systemStart',
  UpdateQuorum = 'updateQuorum'
}

export type ShelleyGenesisPatch = {
  activeSlotsCoeff?: Maybe<Scalars['Float']>;
  epochLength?: Maybe<Scalars['Int']>;
  genDelegs?: Maybe<Scalars['String']>;
  initialFunds?: Maybe<Scalars['String']>;
  maxKESEvolutions?: Maybe<Scalars['Int']>;
  maxLovelaceSupply?: Maybe<Scalars['Int64']>;
  networkId?: Maybe<Scalars['String']>;
  networkMagic?: Maybe<Scalars['Int']>;
  protocolParams?: Maybe<ProtocolParametersRef>;
  securityParam?: Maybe<Scalars['Int']>;
  slotLength?: Maybe<Scalars['Int']>;
  slotsPerKESPeriod?: Maybe<Scalars['Int']>;
  staking?: Maybe<ShelleyGenesisStakingRef>;
  systemStart?: Maybe<Scalars['DateTime']>;
  updateQuorum?: Maybe<Scalars['Int']>;
};

export type ShelleyGenesisRef = {
  activeSlotsCoeff?: Maybe<Scalars['Float']>;
  epochLength?: Maybe<Scalars['Int']>;
  genDelegs?: Maybe<Scalars['String']>;
  initialFunds?: Maybe<Scalars['String']>;
  maxKESEvolutions?: Maybe<Scalars['Int']>;
  maxLovelaceSupply?: Maybe<Scalars['Int64']>;
  networkId?: Maybe<Scalars['String']>;
  networkMagic?: Maybe<Scalars['Int']>;
  protocolParams?: Maybe<ProtocolParametersRef>;
  securityParam?: Maybe<Scalars['Int']>;
  slotLength?: Maybe<Scalars['Int']>;
  slotsPerKESPeriod?: Maybe<Scalars['Int']>;
  staking?: Maybe<ShelleyGenesisStakingRef>;
  systemStart?: Maybe<Scalars['DateTime']>;
  updateQuorum?: Maybe<Scalars['Int']>;
};

export type ShelleyGenesisStaking = {
  __typename?: 'ShelleyGenesisStaking';
  pools: Scalars['String'];
  stake: Scalars['String'];
};

export type ShelleyGenesisStakingAggregateResult = {
  __typename?: 'ShelleyGenesisStakingAggregateResult';
  count?: Maybe<Scalars['Int']>;
  poolsMax?: Maybe<Scalars['String']>;
  poolsMin?: Maybe<Scalars['String']>;
  stakeMax?: Maybe<Scalars['String']>;
  stakeMin?: Maybe<Scalars['String']>;
};

export type ShelleyGenesisStakingFilter = {
  and?: Maybe<Array<Maybe<ShelleyGenesisStakingFilter>>>;
  has?: Maybe<Array<Maybe<ShelleyGenesisStakingHasFilter>>>;
  not?: Maybe<ShelleyGenesisStakingFilter>;
  or?: Maybe<Array<Maybe<ShelleyGenesisStakingFilter>>>;
};

export enum ShelleyGenesisStakingHasFilter {
  Pools = 'pools',
  Stake = 'stake'
}

export type ShelleyGenesisStakingOrder = {
  asc?: Maybe<ShelleyGenesisStakingOrderable>;
  desc?: Maybe<ShelleyGenesisStakingOrderable>;
  then?: Maybe<ShelleyGenesisStakingOrder>;
};

export enum ShelleyGenesisStakingOrderable {
  Pools = 'pools',
  Stake = 'stake'
}

export type ShelleyGenesisStakingPatch = {
  pools?: Maybe<Scalars['String']>;
  stake?: Maybe<Scalars['String']>;
};

export type ShelleyGenesisStakingRef = {
  pools?: Maybe<Scalars['String']>;
  stake?: Maybe<Scalars['String']>;
};

export type Slot = {
  __typename?: 'Slot';
  block?: Maybe<Block>;
  date: Scalars['DateTime'];
  number: Scalars['Int'];
  slotInEpoch: Scalars['Int'];
};


export type SlotBlockArgs = {
  filter?: Maybe<BlockFilter>;
};

export type SlotAggregateResult = {
  __typename?: 'SlotAggregateResult';
  count?: Maybe<Scalars['Int']>;
  dateMax?: Maybe<Scalars['DateTime']>;
  dateMin?: Maybe<Scalars['DateTime']>;
  numberAvg?: Maybe<Scalars['Float']>;
  numberMax?: Maybe<Scalars['Int']>;
  numberMin?: Maybe<Scalars['Int']>;
  numberSum?: Maybe<Scalars['Int']>;
  slotInEpochAvg?: Maybe<Scalars['Float']>;
  slotInEpochMax?: Maybe<Scalars['Int']>;
  slotInEpochMin?: Maybe<Scalars['Int']>;
  slotInEpochSum?: Maybe<Scalars['Int']>;
};

export type SlotFilter = {
  and?: Maybe<Array<Maybe<SlotFilter>>>;
  has?: Maybe<Array<Maybe<SlotHasFilter>>>;
  not?: Maybe<SlotFilter>;
  number?: Maybe<IntFilter>;
  or?: Maybe<Array<Maybe<SlotFilter>>>;
};

export enum SlotHasFilter {
  Block = 'block',
  Date = 'date',
  Number = 'number',
  SlotInEpoch = 'slotInEpoch'
}

export type SlotOrder = {
  asc?: Maybe<SlotOrderable>;
  desc?: Maybe<SlotOrderable>;
  then?: Maybe<SlotOrder>;
};

export enum SlotOrderable {
  Date = 'date',
  Number = 'number',
  SlotInEpoch = 'slotInEpoch'
}

export type SlotPatch = {
  block?: Maybe<BlockRef>;
  date?: Maybe<Scalars['DateTime']>;
  slotInEpoch?: Maybe<Scalars['Int']>;
};

export type SlotRef = {
  block?: Maybe<BlockRef>;
  date?: Maybe<Scalars['DateTime']>;
  number?: Maybe<Scalars['Int']>;
  slotInEpoch?: Maybe<Scalars['Int']>;
};

export type StakePool = {
  __typename?: 'StakePool';
  /** Coin quantity */
  cost: Scalars['String'];
  hexId: Scalars['String'];
  id: Scalars['String'];
  margin: Fraction;
  metadata?: Maybe<StakePoolMetadata>;
  metadataJson?: Maybe<StakePoolMetadataJson>;
  metrics: StakePoolMetrics;
  owners: Array<Scalars['String']>;
  /** Coin quantity */
  pledge: Scalars['String'];
  relays: Array<SearchResult>;
  rewardAccount: Scalars['String'];
  /** active | retired | retiring */
  status: StakePoolStatus;
  transactions: StakePoolTransactions;
  vrf: Scalars['String'];
};


export type StakePoolMarginArgs = {
  filter?: Maybe<FractionFilter>;
};


export type StakePoolMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
};


export type StakePoolMetadataJsonArgs = {
  filter?: Maybe<StakePoolMetadataJsonFilter>;
};


export type StakePoolMetricsArgs = {
  filter?: Maybe<StakePoolMetricsFilter>;
};


export type StakePoolRelaysArgs = {
  filter?: Maybe<SearchResultFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type StakePoolTransactionsArgs = {
  filter?: Maybe<StakePoolTransactionsFilter>;
};

export type StakePoolAggregateResult = {
  __typename?: 'StakePoolAggregateResult';
  costMax?: Maybe<Scalars['String']>;
  costMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  hexIdMax?: Maybe<Scalars['String']>;
  hexIdMin?: Maybe<Scalars['String']>;
  idMax?: Maybe<Scalars['String']>;
  idMin?: Maybe<Scalars['String']>;
  pledgeMax?: Maybe<Scalars['String']>;
  pledgeMin?: Maybe<Scalars['String']>;
  rewardAccountMax?: Maybe<Scalars['String']>;
  rewardAccountMin?: Maybe<Scalars['String']>;
  vrfMax?: Maybe<Scalars['String']>;
  vrfMin?: Maybe<Scalars['String']>;
};

export type StakePoolFilter = {
  and?: Maybe<Array<Maybe<StakePoolFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolHasFilter>>>;
  id?: Maybe<StringFullTextFilter_StringHashFilter>;
  not?: Maybe<StakePoolFilter>;
  or?: Maybe<Array<Maybe<StakePoolFilter>>>;
};

export enum StakePoolHasFilter {
  Cost = 'cost',
  HexId = 'hexId',
  Id = 'id',
  Margin = 'margin',
  Metadata = 'metadata',
  MetadataJson = 'metadataJson',
  Metrics = 'metrics',
  Owners = 'owners',
  Pledge = 'pledge',
  Relays = 'relays',
  RewardAccount = 'rewardAccount',
  Status = 'status',
  Transactions = 'transactions',
  Vrf = 'vrf'
}

export type StakePoolMetadata = {
  __typename?: 'StakePoolMetadata';
  description: Scalars['String'];
  ext?: Maybe<ExtendedStakePoolMetadata>;
  extDataUrl?: Maybe<Scalars['String']>;
  extSigUrl?: Maybe<Scalars['String']>;
  extVkey?: Maybe<Scalars['String']>;
  homepage: Scalars['String'];
  name: Scalars['String'];
  stakePool: StakePool;
  stakePoolId: Scalars['String'];
  ticker: Scalars['String'];
};


export type StakePoolMetadataExtArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
};


export type StakePoolMetadataStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
};

export type StakePoolMetadataAggregateResult = {
  __typename?: 'StakePoolMetadataAggregateResult';
  count?: Maybe<Scalars['Int']>;
  descriptionMax?: Maybe<Scalars['String']>;
  descriptionMin?: Maybe<Scalars['String']>;
  extDataUrlMax?: Maybe<Scalars['String']>;
  extDataUrlMin?: Maybe<Scalars['String']>;
  extSigUrlMax?: Maybe<Scalars['String']>;
  extSigUrlMin?: Maybe<Scalars['String']>;
  extVkeyMax?: Maybe<Scalars['String']>;
  extVkeyMin?: Maybe<Scalars['String']>;
  homepageMax?: Maybe<Scalars['String']>;
  homepageMin?: Maybe<Scalars['String']>;
  nameMax?: Maybe<Scalars['String']>;
  nameMin?: Maybe<Scalars['String']>;
  stakePoolIdMax?: Maybe<Scalars['String']>;
  stakePoolIdMin?: Maybe<Scalars['String']>;
  tickerMax?: Maybe<Scalars['String']>;
  tickerMin?: Maybe<Scalars['String']>;
};

export type StakePoolMetadataFilter = {
  and?: Maybe<Array<Maybe<StakePoolMetadataFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolMetadataHasFilter>>>;
  name?: Maybe<StringFullTextFilter>;
  not?: Maybe<StakePoolMetadataFilter>;
  or?: Maybe<Array<Maybe<StakePoolMetadataFilter>>>;
  stakePoolId?: Maybe<StringHashFilter>;
  ticker?: Maybe<StringFullTextFilter>;
};

export enum StakePoolMetadataHasFilter {
  Description = 'description',
  Ext = 'ext',
  ExtDataUrl = 'extDataUrl',
  ExtSigUrl = 'extSigUrl',
  ExtVkey = 'extVkey',
  Homepage = 'homepage',
  Name = 'name',
  StakePool = 'stakePool',
  StakePoolId = 'stakePoolId',
  Ticker = 'ticker'
}

export type StakePoolMetadataJson = {
  __typename?: 'StakePoolMetadataJson';
  hash: Scalars['String'];
  url: Scalars['String'];
};

export type StakePoolMetadataJsonAggregateResult = {
  __typename?: 'StakePoolMetadataJsonAggregateResult';
  count?: Maybe<Scalars['Int']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
  urlMax?: Maybe<Scalars['String']>;
  urlMin?: Maybe<Scalars['String']>;
};

export type StakePoolMetadataJsonFilter = {
  and?: Maybe<Array<Maybe<StakePoolMetadataJsonFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolMetadataJsonHasFilter>>>;
  not?: Maybe<StakePoolMetadataJsonFilter>;
  or?: Maybe<Array<Maybe<StakePoolMetadataJsonFilter>>>;
};

export enum StakePoolMetadataJsonHasFilter {
  Hash = 'hash',
  Url = 'url'
}

export type StakePoolMetadataJsonOrder = {
  asc?: Maybe<StakePoolMetadataJsonOrderable>;
  desc?: Maybe<StakePoolMetadataJsonOrderable>;
  then?: Maybe<StakePoolMetadataJsonOrder>;
};

export enum StakePoolMetadataJsonOrderable {
  Hash = 'hash',
  Url = 'url'
}

export type StakePoolMetadataJsonPatch = {
  hash?: Maybe<Scalars['String']>;
  url?: Maybe<Scalars['String']>;
};

export type StakePoolMetadataJsonRef = {
  hash?: Maybe<Scalars['String']>;
  url?: Maybe<Scalars['String']>;
};

export type StakePoolMetadataOrder = {
  asc?: Maybe<StakePoolMetadataOrderable>;
  desc?: Maybe<StakePoolMetadataOrderable>;
  then?: Maybe<StakePoolMetadataOrder>;
};

export enum StakePoolMetadataOrderable {
  Description = 'description',
  ExtDataUrl = 'extDataUrl',
  ExtSigUrl = 'extSigUrl',
  ExtVkey = 'extVkey',
  Homepage = 'homepage',
  Name = 'name',
  StakePoolId = 'stakePoolId',
  Ticker = 'ticker'
}

export type StakePoolMetadataPatch = {
  description?: Maybe<Scalars['String']>;
  ext?: Maybe<ExtendedStakePoolMetadataRef>;
  extDataUrl?: Maybe<Scalars['String']>;
  extSigUrl?: Maybe<Scalars['String']>;
  extVkey?: Maybe<Scalars['String']>;
  homepage?: Maybe<Scalars['String']>;
  name?: Maybe<Scalars['String']>;
  stakePool?: Maybe<StakePoolRef>;
  ticker?: Maybe<Scalars['String']>;
};

export type StakePoolMetadataRef = {
  description?: Maybe<Scalars['String']>;
  ext?: Maybe<ExtendedStakePoolMetadataRef>;
  extDataUrl?: Maybe<Scalars['String']>;
  extSigUrl?: Maybe<Scalars['String']>;
  extVkey?: Maybe<Scalars['String']>;
  homepage?: Maybe<Scalars['String']>;
  name?: Maybe<Scalars['String']>;
  stakePool?: Maybe<StakePoolRef>;
  stakePoolId?: Maybe<Scalars['String']>;
  ticker?: Maybe<Scalars['String']>;
};

export type StakePoolMetrics = {
  __typename?: 'StakePoolMetrics';
  blocksCreated: Scalars['Int'];
  delegators: Scalars['Int'];
  /** Coin quantity */
  livePledge: Scalars['String'];
  saturation: Scalars['Float'];
  size: StakePoolMetricsSize;
  stake: StakePoolMetricsStake;
};


export type StakePoolMetricsSizeArgs = {
  filter?: Maybe<StakePoolMetricsSizeFilter>;
};


export type StakePoolMetricsStakeArgs = {
  filter?: Maybe<StakePoolMetricsStakeFilter>;
};

export type StakePoolMetricsAggregateResult = {
  __typename?: 'StakePoolMetricsAggregateResult';
  blocksCreatedAvg?: Maybe<Scalars['Float']>;
  blocksCreatedMax?: Maybe<Scalars['Int']>;
  blocksCreatedMin?: Maybe<Scalars['Int']>;
  blocksCreatedSum?: Maybe<Scalars['Int']>;
  count?: Maybe<Scalars['Int']>;
  delegatorsAvg?: Maybe<Scalars['Float']>;
  delegatorsMax?: Maybe<Scalars['Int']>;
  delegatorsMin?: Maybe<Scalars['Int']>;
  delegatorsSum?: Maybe<Scalars['Int']>;
  livePledgeMax?: Maybe<Scalars['String']>;
  livePledgeMin?: Maybe<Scalars['String']>;
  saturationAvg?: Maybe<Scalars['Float']>;
  saturationMax?: Maybe<Scalars['Float']>;
  saturationMin?: Maybe<Scalars['Float']>;
  saturationSum?: Maybe<Scalars['Float']>;
};

export type StakePoolMetricsFilter = {
  and?: Maybe<Array<Maybe<StakePoolMetricsFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolMetricsHasFilter>>>;
  not?: Maybe<StakePoolMetricsFilter>;
  or?: Maybe<Array<Maybe<StakePoolMetricsFilter>>>;
};

export enum StakePoolMetricsHasFilter {
  BlocksCreated = 'blocksCreated',
  Delegators = 'delegators',
  LivePledge = 'livePledge',
  Saturation = 'saturation',
  Size = 'size',
  Stake = 'stake'
}

export type StakePoolMetricsOrder = {
  asc?: Maybe<StakePoolMetricsOrderable>;
  desc?: Maybe<StakePoolMetricsOrderable>;
  then?: Maybe<StakePoolMetricsOrder>;
};

export enum StakePoolMetricsOrderable {
  BlocksCreated = 'blocksCreated',
  Delegators = 'delegators',
  LivePledge = 'livePledge',
  Saturation = 'saturation'
}

export type StakePoolMetricsPatch = {
  blocksCreated?: Maybe<Scalars['Int']>;
  delegators?: Maybe<Scalars['Int']>;
  /** Coin quantity */
  livePledge?: Maybe<Scalars['String']>;
  saturation?: Maybe<Scalars['Float']>;
  size?: Maybe<StakePoolMetricsSizeRef>;
  stake?: Maybe<StakePoolMetricsStakeRef>;
};

export type StakePoolMetricsRef = {
  blocksCreated?: Maybe<Scalars['Int']>;
  delegators?: Maybe<Scalars['Int']>;
  /** Coin quantity */
  livePledge?: Maybe<Scalars['String']>;
  saturation?: Maybe<Scalars['Float']>;
  size?: Maybe<StakePoolMetricsSizeRef>;
  stake?: Maybe<StakePoolMetricsStakeRef>;
};

export type StakePoolMetricsSize = {
  __typename?: 'StakePoolMetricsSize';
  /** Percentage in range [0; 1] */
  active: Scalars['Float'];
  /** Percentage in range [0; 1] */
  live: Scalars['Float'];
};

export type StakePoolMetricsSizeAggregateResult = {
  __typename?: 'StakePoolMetricsSizeAggregateResult';
  activeAvg?: Maybe<Scalars['Float']>;
  activeMax?: Maybe<Scalars['Float']>;
  activeMin?: Maybe<Scalars['Float']>;
  activeSum?: Maybe<Scalars['Float']>;
  count?: Maybe<Scalars['Int']>;
  liveAvg?: Maybe<Scalars['Float']>;
  liveMax?: Maybe<Scalars['Float']>;
  liveMin?: Maybe<Scalars['Float']>;
  liveSum?: Maybe<Scalars['Float']>;
};

export type StakePoolMetricsSizeFilter = {
  and?: Maybe<Array<Maybe<StakePoolMetricsSizeFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolMetricsSizeHasFilter>>>;
  not?: Maybe<StakePoolMetricsSizeFilter>;
  or?: Maybe<Array<Maybe<StakePoolMetricsSizeFilter>>>;
};

export enum StakePoolMetricsSizeHasFilter {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsSizeOrder = {
  asc?: Maybe<StakePoolMetricsSizeOrderable>;
  desc?: Maybe<StakePoolMetricsSizeOrderable>;
  then?: Maybe<StakePoolMetricsSizeOrder>;
};

export enum StakePoolMetricsSizeOrderable {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsSizePatch = {
  /** Percentage in range [0; 1] */
  active?: Maybe<Scalars['Float']>;
  /** Percentage in range [0; 1] */
  live?: Maybe<Scalars['Float']>;
};

export type StakePoolMetricsSizeRef = {
  /** Percentage in range [0; 1] */
  active?: Maybe<Scalars['Float']>;
  /** Percentage in range [0; 1] */
  live?: Maybe<Scalars['Float']>;
};

export type StakePoolMetricsStake = {
  __typename?: 'StakePoolMetricsStake';
  /** Coin quantity */
  active: Scalars['String'];
  /** Coin quantity */
  live: Scalars['String'];
};

export type StakePoolMetricsStakeAggregateResult = {
  __typename?: 'StakePoolMetricsStakeAggregateResult';
  activeMax?: Maybe<Scalars['String']>;
  activeMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  liveMax?: Maybe<Scalars['String']>;
  liveMin?: Maybe<Scalars['String']>;
};

export type StakePoolMetricsStakeFilter = {
  and?: Maybe<Array<Maybe<StakePoolMetricsStakeFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolMetricsStakeHasFilter>>>;
  not?: Maybe<StakePoolMetricsStakeFilter>;
  or?: Maybe<Array<Maybe<StakePoolMetricsStakeFilter>>>;
};

export enum StakePoolMetricsStakeHasFilter {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsStakeOrder = {
  asc?: Maybe<StakePoolMetricsStakeOrderable>;
  desc?: Maybe<StakePoolMetricsStakeOrderable>;
  then?: Maybe<StakePoolMetricsStakeOrder>;
};

export enum StakePoolMetricsStakeOrderable {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsStakePatch = {
  /** Coin quantity */
  active?: Maybe<Scalars['String']>;
  /** Coin quantity */
  live?: Maybe<Scalars['String']>;
};

export type StakePoolMetricsStakeRef = {
  /** Coin quantity */
  active?: Maybe<Scalars['String']>;
  /** Coin quantity */
  live?: Maybe<Scalars['String']>;
};

export type StakePoolOrder = {
  asc?: Maybe<StakePoolOrderable>;
  desc?: Maybe<StakePoolOrderable>;
  then?: Maybe<StakePoolOrder>;
};

export enum StakePoolOrderable {
  Cost = 'cost',
  HexId = 'hexId',
  Id = 'id',
  Pledge = 'pledge',
  RewardAccount = 'rewardAccount',
  Vrf = 'vrf'
}

export type StakePoolPatch = {
  /** Coin quantity */
  cost?: Maybe<Scalars['String']>;
  hexId?: Maybe<Scalars['String']>;
  margin?: Maybe<FractionRef>;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  metrics?: Maybe<StakePoolMetricsRef>;
  owners?: Maybe<Array<Scalars['String']>>;
  /** Coin quantity */
  pledge?: Maybe<Scalars['String']>;
  relays?: Maybe<Array<SearchResultRef>>;
  rewardAccount?: Maybe<Scalars['String']>;
  /** active | retired | retiring */
  status?: Maybe<StakePoolStatus>;
  transactions?: Maybe<StakePoolTransactionsRef>;
  vrf?: Maybe<Scalars['String']>;
};

export type StakePoolRef = {
  /** Coin quantity */
  cost?: Maybe<Scalars['String']>;
  hexId?: Maybe<Scalars['String']>;
  id?: Maybe<Scalars['String']>;
  margin?: Maybe<FractionRef>;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  metrics?: Maybe<StakePoolMetricsRef>;
  owners?: Maybe<Array<Scalars['String']>>;
  /** Coin quantity */
  pledge?: Maybe<Scalars['String']>;
  relays?: Maybe<Array<SearchResultRef>>;
  rewardAccount?: Maybe<Scalars['String']>;
  /** active | retired | retiring */
  status?: Maybe<StakePoolStatus>;
  transactions?: Maybe<StakePoolTransactionsRef>;
  vrf?: Maybe<Scalars['String']>;
};

export enum StakePoolStatus {
  Active = 'active',
  Retired = 'retired',
  Retiring = 'retiring'
}

export type StakePoolTransactions = {
  __typename?: 'StakePoolTransactions';
  registration: Array<Scalars['String']>;
  retirement: Array<Scalars['String']>;
};

export type StakePoolTransactionsAggregateResult = {
  __typename?: 'StakePoolTransactionsAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type StakePoolTransactionsFilter = {
  and?: Maybe<Array<Maybe<StakePoolTransactionsFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolTransactionsHasFilter>>>;
  not?: Maybe<StakePoolTransactionsFilter>;
  or?: Maybe<Array<Maybe<StakePoolTransactionsFilter>>>;
};

export enum StakePoolTransactionsHasFilter {
  Registration = 'registration',
  Retirement = 'retirement'
}

export type StakePoolTransactionsPatch = {
  registration?: Maybe<Array<Scalars['String']>>;
  retirement?: Maybe<Array<Scalars['String']>>;
};

export type StakePoolTransactionsRef = {
  registration?: Maybe<Array<Scalars['String']>>;
  retirement?: Maybe<Array<Scalars['String']>>;
};

export type StringExactFilter = {
  between?: Maybe<StringRange>;
  eq?: Maybe<Scalars['String']>;
  ge?: Maybe<Scalars['String']>;
  gt?: Maybe<Scalars['String']>;
  in?: Maybe<Array<Maybe<Scalars['String']>>>;
  le?: Maybe<Scalars['String']>;
  lt?: Maybe<Scalars['String']>;
};

export type StringFullTextFilter = {
  alloftext?: Maybe<Scalars['String']>;
  anyoftext?: Maybe<Scalars['String']>;
};

export type StringFullTextFilter_StringHashFilter = {
  alloftext?: Maybe<Scalars['String']>;
  anyoftext?: Maybe<Scalars['String']>;
  eq?: Maybe<Scalars['String']>;
  in?: Maybe<Array<Maybe<Scalars['String']>>>;
};

export type StringHashFilter = {
  eq?: Maybe<Scalars['String']>;
  in?: Maybe<Array<Maybe<Scalars['String']>>>;
};

export type StringMetadatum = {
  __typename?: 'StringMetadatum';
  value: Scalars['String'];
  valueType: MetadatumStringType;
};

export type StringMetadatumAggregateResult = {
  __typename?: 'StringMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  valueMax?: Maybe<Scalars['String']>;
  valueMin?: Maybe<Scalars['String']>;
};

export type StringMetadatumFilter = {
  and?: Maybe<Array<Maybe<StringMetadatumFilter>>>;
  has?: Maybe<Array<Maybe<StringMetadatumHasFilter>>>;
  not?: Maybe<StringMetadatumFilter>;
  or?: Maybe<Array<Maybe<StringMetadatumFilter>>>;
};

export enum StringMetadatumHasFilter {
  Value = 'value',
  ValueType = 'valueType'
}

export type StringMetadatumOrder = {
  asc?: Maybe<StringMetadatumOrderable>;
  desc?: Maybe<StringMetadatumOrderable>;
  then?: Maybe<StringMetadatumOrder>;
};

export enum StringMetadatumOrderable {
  Value = 'value'
}

export type StringMetadatumPatch = {
  value?: Maybe<Scalars['String']>;
  valueType?: Maybe<MetadatumStringType>;
};

export type StringMetadatumRef = {
  value?: Maybe<Scalars['String']>;
  valueType?: Maybe<MetadatumStringType>;
};

export type StringRange = {
  max: Scalars['String'];
  min: Scalars['String'];
};

export type StringRegExpFilter = {
  regexp?: Maybe<Scalars['String']>;
};

export type StringTermFilter = {
  allofterms?: Maybe<Scalars['String']>;
  anyofterms?: Maybe<Scalars['String']>;
};

export type ThePoolsMediaAssets = {
  __typename?: 'ThePoolsMediaAssets';
  color_bg?: Maybe<Scalars['String']>;
  color_fg?: Maybe<Scalars['String']>;
  icon_png_64x64: Scalars['String'];
  logo_png?: Maybe<Scalars['String']>;
  logo_svg?: Maybe<Scalars['String']>;
};

export type ThePoolsMediaAssetsAggregateResult = {
  __typename?: 'ThePoolsMediaAssetsAggregateResult';
  color_bgMax?: Maybe<Scalars['String']>;
  color_bgMin?: Maybe<Scalars['String']>;
  color_fgMax?: Maybe<Scalars['String']>;
  color_fgMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  icon_png_64x64Max?: Maybe<Scalars['String']>;
  icon_png_64x64Min?: Maybe<Scalars['String']>;
  logo_pngMax?: Maybe<Scalars['String']>;
  logo_pngMin?: Maybe<Scalars['String']>;
  logo_svgMax?: Maybe<Scalars['String']>;
  logo_svgMin?: Maybe<Scalars['String']>;
};

export type ThePoolsMediaAssetsFilter = {
  and?: Maybe<Array<Maybe<ThePoolsMediaAssetsFilter>>>;
  has?: Maybe<Array<Maybe<ThePoolsMediaAssetsHasFilter>>>;
  not?: Maybe<ThePoolsMediaAssetsFilter>;
  or?: Maybe<Array<Maybe<ThePoolsMediaAssetsFilter>>>;
};

export enum ThePoolsMediaAssetsHasFilter {
  ColorBg = 'color_bg',
  ColorFg = 'color_fg',
  IconPng_64x64 = 'icon_png_64x64',
  LogoPng = 'logo_png',
  LogoSvg = 'logo_svg'
}

export type ThePoolsMediaAssetsOrder = {
  asc?: Maybe<ThePoolsMediaAssetsOrderable>;
  desc?: Maybe<ThePoolsMediaAssetsOrderable>;
  then?: Maybe<ThePoolsMediaAssetsOrder>;
};

export enum ThePoolsMediaAssetsOrderable {
  ColorBg = 'color_bg',
  ColorFg = 'color_fg',
  IconPng_64x64 = 'icon_png_64x64',
  LogoPng = 'logo_png',
  LogoSvg = 'logo_svg'
}

export type ThePoolsMediaAssetsPatch = {
  color_bg?: Maybe<Scalars['String']>;
  color_fg?: Maybe<Scalars['String']>;
  icon_png_64x64?: Maybe<Scalars['String']>;
  logo_png?: Maybe<Scalars['String']>;
  logo_svg?: Maybe<Scalars['String']>;
};

export type ThePoolsMediaAssetsRef = {
  color_bg?: Maybe<Scalars['String']>;
  color_fg?: Maybe<Scalars['String']>;
  icon_png_64x64?: Maybe<Scalars['String']>;
  logo_png?: Maybe<Scalars['String']>;
  logo_svg?: Maybe<Scalars['String']>;
};

export type Token = {
  __typename?: 'Token';
  asset: Asset;
  quantity: Scalars['String'];
  transactionOutput: TransactionOutput;
};


export type TokenAssetArgs = {
  filter?: Maybe<AssetFilter>;
};


export type TokenTransactionOutputArgs = {
  filter?: Maybe<TransactionOutputFilter>;
};

export type TokenAggregateResult = {
  __typename?: 'TokenAggregateResult';
  count?: Maybe<Scalars['Int']>;
  quantityMax?: Maybe<Scalars['String']>;
  quantityMin?: Maybe<Scalars['String']>;
};

export type TokenFilter = {
  and?: Maybe<Array<Maybe<TokenFilter>>>;
  has?: Maybe<Array<Maybe<TokenHasFilter>>>;
  not?: Maybe<TokenFilter>;
  or?: Maybe<Array<Maybe<TokenFilter>>>;
};

export enum TokenHasFilter {
  Asset = 'asset',
  Quantity = 'quantity',
  TransactionOutput = 'transactionOutput'
}

export type TokenOrder = {
  asc?: Maybe<TokenOrderable>;
  desc?: Maybe<TokenOrderable>;
  then?: Maybe<TokenOrder>;
};

export enum TokenOrderable {
  Quantity = 'quantity'
}

export type TokenPatch = {
  asset?: Maybe<AssetRef>;
  quantity?: Maybe<Scalars['String']>;
  transactionOutput?: Maybe<TransactionOutputRef>;
};

export type TokenRef = {
  asset?: Maybe<AssetRef>;
  quantity?: Maybe<Scalars['String']>;
  transactionOutput?: Maybe<TransactionOutputRef>;
};

export type Transaction = {
  __typename?: 'Transaction';
  auxiliaryData?: Maybe<AuxiliaryData>;
  block: Block;
  blockIndex: Scalars['Int'];
  collateral?: Maybe<Array<TransactionInput>>;
  collateralAggregate?: Maybe<TransactionInputAggregateResult>;
  deposit: Scalars['Int64'];
  fee: Scalars['Int64'];
  hash: Scalars['String'];
  inputs: Array<TransactionInput>;
  inputsAggregate?: Maybe<TransactionInputAggregateResult>;
  invalidBefore?: Maybe<Scalars['Int']>;
  invalidHereafter?: Maybe<Scalars['Int']>;
  mint?: Maybe<Array<Token>>;
  mintAggregate?: Maybe<TokenAggregateResult>;
  outputs: Array<TransactionOutput>;
  outputsAggregate?: Maybe<TransactionOutputAggregateResult>;
  redeemers?: Maybe<Array<Redeemer>>;
  redeemersAggregate?: Maybe<RedeemerAggregateResult>;
  size: Scalars['Int64'];
  totalOutputCoin: Scalars['Int64'];
  validContract: Scalars['Boolean'];
  withdrawals?: Maybe<Array<Withdrawal>>;
  withdrawalsAggregate?: Maybe<WithdrawalAggregateResult>;
};


export type TransactionAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
};


export type TransactionBlockArgs = {
  filter?: Maybe<BlockFilter>;
};


export type TransactionCollateralArgs = {
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};


export type TransactionCollateralAggregateArgs = {
  filter?: Maybe<TransactionInputFilter>;
};


export type TransactionInputsArgs = {
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};


export type TransactionInputsAggregateArgs = {
  filter?: Maybe<TransactionInputFilter>;
};


export type TransactionMintArgs = {
  filter?: Maybe<TokenFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TokenOrder>;
};


export type TransactionMintAggregateArgs = {
  filter?: Maybe<TokenFilter>;
};


export type TransactionOutputsArgs = {
  filter?: Maybe<TransactionOutputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOutputOrder>;
};


export type TransactionOutputsAggregateArgs = {
  filter?: Maybe<TransactionOutputFilter>;
};


export type TransactionRedeemersArgs = {
  filter?: Maybe<RedeemerFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RedeemerOrder>;
};


export type TransactionRedeemersAggregateArgs = {
  filter?: Maybe<RedeemerFilter>;
};


export type TransactionWithdrawalsArgs = {
  filter?: Maybe<WithdrawalFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WithdrawalOrder>;
};


export type TransactionWithdrawalsAggregateArgs = {
  filter?: Maybe<WithdrawalFilter>;
};

export type TransactionAggregateResult = {
  __typename?: 'TransactionAggregateResult';
  blockIndexAvg?: Maybe<Scalars['Float']>;
  blockIndexMax?: Maybe<Scalars['Int']>;
  blockIndexMin?: Maybe<Scalars['Int']>;
  blockIndexSum?: Maybe<Scalars['Int']>;
  count?: Maybe<Scalars['Int']>;
  depositAvg?: Maybe<Scalars['Float']>;
  depositMax?: Maybe<Scalars['Int64']>;
  depositMin?: Maybe<Scalars['Int64']>;
  depositSum?: Maybe<Scalars['Int64']>;
  feeAvg?: Maybe<Scalars['Float']>;
  feeMax?: Maybe<Scalars['Int64']>;
  feeMin?: Maybe<Scalars['Int64']>;
  feeSum?: Maybe<Scalars['Int64']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
  invalidBeforeAvg?: Maybe<Scalars['Float']>;
  invalidBeforeMax?: Maybe<Scalars['Int']>;
  invalidBeforeMin?: Maybe<Scalars['Int']>;
  invalidBeforeSum?: Maybe<Scalars['Int']>;
  invalidHereafterAvg?: Maybe<Scalars['Float']>;
  invalidHereafterMax?: Maybe<Scalars['Int']>;
  invalidHereafterMin?: Maybe<Scalars['Int']>;
  invalidHereafterSum?: Maybe<Scalars['Int']>;
  sizeAvg?: Maybe<Scalars['Float']>;
  sizeMax?: Maybe<Scalars['Int64']>;
  sizeMin?: Maybe<Scalars['Int64']>;
  sizeSum?: Maybe<Scalars['Int64']>;
  totalOutputCoinAvg?: Maybe<Scalars['Float']>;
  totalOutputCoinMax?: Maybe<Scalars['Int64']>;
  totalOutputCoinMin?: Maybe<Scalars['Int64']>;
  totalOutputCoinSum?: Maybe<Scalars['Int64']>;
};

export type TransactionFilter = {
  and?: Maybe<Array<Maybe<TransactionFilter>>>;
  has?: Maybe<Array<Maybe<TransactionHasFilter>>>;
  hash?: Maybe<StringHashFilter>;
  not?: Maybe<TransactionFilter>;
  or?: Maybe<Array<Maybe<TransactionFilter>>>;
};

export enum TransactionHasFilter {
  AuxiliaryData = 'auxiliaryData',
  Block = 'block',
  BlockIndex = 'blockIndex',
  Collateral = 'collateral',
  Deposit = 'deposit',
  Fee = 'fee',
  Hash = 'hash',
  Inputs = 'inputs',
  InvalidBefore = 'invalidBefore',
  InvalidHereafter = 'invalidHereafter',
  Mint = 'mint',
  Outputs = 'outputs',
  Redeemers = 'redeemers',
  Size = 'size',
  TotalOutputCoin = 'totalOutputCoin',
  ValidContract = 'validContract',
  Withdrawals = 'withdrawals'
}

export type TransactionInput = {
  __typename?: 'TransactionInput';
  address: Address;
  index: Scalars['Int'];
  redeemer?: Maybe<Redeemer>;
  /** Output of */
  sourceTransaction: Transaction;
  transaction: Transaction;
  value: Value;
};


export type TransactionInputAddressArgs = {
  filter?: Maybe<AddressFilter>;
};


export type TransactionInputRedeemerArgs = {
  filter?: Maybe<RedeemerFilter>;
};


export type TransactionInputSourceTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};


export type TransactionInputTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};


export type TransactionInputValueArgs = {
  filter?: Maybe<ValueFilter>;
};

export type TransactionInputAggregateResult = {
  __typename?: 'TransactionInputAggregateResult';
  count?: Maybe<Scalars['Int']>;
  indexAvg?: Maybe<Scalars['Float']>;
  indexMax?: Maybe<Scalars['Int']>;
  indexMin?: Maybe<Scalars['Int']>;
  indexSum?: Maybe<Scalars['Int']>;
};

export type TransactionInputFilter = {
  and?: Maybe<Array<Maybe<TransactionInputFilter>>>;
  has?: Maybe<Array<Maybe<TransactionInputHasFilter>>>;
  not?: Maybe<TransactionInputFilter>;
  or?: Maybe<Array<Maybe<TransactionInputFilter>>>;
};

export enum TransactionInputHasFilter {
  Address = 'address',
  Index = 'index',
  Redeemer = 'redeemer',
  SourceTransaction = 'sourceTransaction',
  Transaction = 'transaction',
  Value = 'value'
}

export type TransactionInputOrder = {
  asc?: Maybe<TransactionInputOrderable>;
  desc?: Maybe<TransactionInputOrderable>;
  then?: Maybe<TransactionInputOrder>;
};

export enum TransactionInputOrderable {
  Index = 'index'
}

export type TransactionInputPatch = {
  address?: Maybe<AddressRef>;
  index?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<RedeemerRef>;
  sourceTransaction?: Maybe<TransactionRef>;
  transaction?: Maybe<TransactionRef>;
  value?: Maybe<ValueRef>;
};

export type TransactionInputRef = {
  address?: Maybe<AddressRef>;
  index?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<RedeemerRef>;
  sourceTransaction?: Maybe<TransactionRef>;
  transaction?: Maybe<TransactionRef>;
  value?: Maybe<ValueRef>;
};

export type TransactionOrder = {
  asc?: Maybe<TransactionOrderable>;
  desc?: Maybe<TransactionOrderable>;
  then?: Maybe<TransactionOrder>;
};

export enum TransactionOrderable {
  BlockIndex = 'blockIndex',
  Deposit = 'deposit',
  Fee = 'fee',
  Hash = 'hash',
  InvalidBefore = 'invalidBefore',
  InvalidHereafter = 'invalidHereafter',
  Size = 'size',
  TotalOutputCoin = 'totalOutputCoin'
}

export type TransactionOutput = {
  __typename?: 'TransactionOutput';
  address: Address;
  index: Scalars['Int'];
  transaction: Transaction;
  value: Value;
};


export type TransactionOutputAddressArgs = {
  filter?: Maybe<AddressFilter>;
};


export type TransactionOutputTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};


export type TransactionOutputValueArgs = {
  filter?: Maybe<ValueFilter>;
};

export type TransactionOutputAggregateResult = {
  __typename?: 'TransactionOutputAggregateResult';
  count?: Maybe<Scalars['Int']>;
  indexAvg?: Maybe<Scalars['Float']>;
  indexMax?: Maybe<Scalars['Int']>;
  indexMin?: Maybe<Scalars['Int']>;
  indexSum?: Maybe<Scalars['Int']>;
};

export type TransactionOutputFilter = {
  and?: Maybe<Array<Maybe<TransactionOutputFilter>>>;
  has?: Maybe<Array<Maybe<TransactionOutputHasFilter>>>;
  not?: Maybe<TransactionOutputFilter>;
  or?: Maybe<Array<Maybe<TransactionOutputFilter>>>;
};

export enum TransactionOutputHasFilter {
  Address = 'address',
  Index = 'index',
  Transaction = 'transaction',
  Value = 'value'
}

export type TransactionOutputOrder = {
  asc?: Maybe<TransactionOutputOrderable>;
  desc?: Maybe<TransactionOutputOrderable>;
  then?: Maybe<TransactionOutputOrder>;
};

export enum TransactionOutputOrderable {
  Index = 'index'
}

export type TransactionOutputPatch = {
  address?: Maybe<AddressRef>;
  index?: Maybe<Scalars['Int']>;
  transaction?: Maybe<TransactionRef>;
  value?: Maybe<ValueRef>;
};

export type TransactionOutputRef = {
  address?: Maybe<AddressRef>;
  index?: Maybe<Scalars['Int']>;
  transaction?: Maybe<TransactionRef>;
  value?: Maybe<ValueRef>;
};

export type TransactionPatch = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  block?: Maybe<BlockRef>;
  blockIndex?: Maybe<Scalars['Int']>;
  collateral?: Maybe<Array<TransactionInputRef>>;
  deposit?: Maybe<Scalars['Int64']>;
  fee?: Maybe<Scalars['Int64']>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  invalidBefore?: Maybe<Scalars['Int']>;
  invalidHereafter?: Maybe<Scalars['Int']>;
  mint?: Maybe<Array<TokenRef>>;
  outputs?: Maybe<Array<TransactionOutputRef>>;
  redeemers?: Maybe<Array<RedeemerRef>>;
  size?: Maybe<Scalars['Int64']>;
  totalOutputCoin?: Maybe<Scalars['Int64']>;
  validContract?: Maybe<Scalars['Boolean']>;
  withdrawals?: Maybe<Array<WithdrawalRef>>;
};

export type TransactionRef = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  block?: Maybe<BlockRef>;
  blockIndex?: Maybe<Scalars['Int']>;
  collateral?: Maybe<Array<TransactionInputRef>>;
  deposit?: Maybe<Scalars['Int64']>;
  fee?: Maybe<Scalars['Int64']>;
  hash?: Maybe<Scalars['String']>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  invalidBefore?: Maybe<Scalars['Int']>;
  invalidHereafter?: Maybe<Scalars['Int']>;
  mint?: Maybe<Array<TokenRef>>;
  outputs?: Maybe<Array<TransactionOutputRef>>;
  redeemers?: Maybe<Array<RedeemerRef>>;
  size?: Maybe<Scalars['Int64']>;
  totalOutputCoin?: Maybe<Scalars['Int64']>;
  validContract?: Maybe<Scalars['Boolean']>;
  withdrawals?: Maybe<Array<WithdrawalRef>>;
};

export type UpdateActiveStakeInput = {
  filter: ActiveStakeFilter;
  remove?: Maybe<ActiveStakePatch>;
  set?: Maybe<ActiveStakePatch>;
};

export type UpdateActiveStakePayload = {
  __typename?: 'UpdateActiveStakePayload';
  activeStake?: Maybe<Array<Maybe<ActiveStake>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateActiveStakePayloadActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ActiveStakeOrder>;
};

export type UpdateAdaInput = {
  filter: AdaFilter;
  remove?: Maybe<AdaPatch>;
  set?: Maybe<AdaPatch>;
};

export type UpdateAdaPayload = {
  __typename?: 'UpdateAdaPayload';
  ada?: Maybe<Array<Maybe<Ada>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAdaPayloadAdaArgs = {
  filter?: Maybe<AdaFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateAdaPotsInput = {
  filter: AdaPotsFilter;
  remove?: Maybe<AdaPotsPatch>;
  set?: Maybe<AdaPotsPatch>;
};

export type UpdateAdaPotsPayload = {
  __typename?: 'UpdateAdaPotsPayload';
  adaPots?: Maybe<Array<Maybe<AdaPots>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAdaPotsPayloadAdaPotsArgs = {
  filter?: Maybe<AdaPotsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AdaPotsOrder>;
};

export type UpdateAddressInput = {
  filter: AddressFilter;
  remove?: Maybe<AddressPatch>;
  set?: Maybe<AddressPatch>;
};

export type UpdateAddressPayload = {
  __typename?: 'UpdateAddressPayload';
  address?: Maybe<Array<Maybe<Address>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAddressPayloadAddressArgs = {
  filter?: Maybe<AddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AddressOrder>;
};

export type UpdateAlonzoGenesisInput = {
  filter: AlonzoGenesisFilter;
  remove?: Maybe<AlonzoGenesisPatch>;
  set?: Maybe<AlonzoGenesisPatch>;
};

export type UpdateAlonzoGenesisPayload = {
  __typename?: 'UpdateAlonzoGenesisPayload';
  alonzoGenesis?: Maybe<Array<Maybe<AlonzoGenesis>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAlonzoGenesisPayloadAlonzoGenesisArgs = {
  filter?: Maybe<AlonzoGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AlonzoGenesisOrder>;
};

export type UpdateAssetInput = {
  filter: AssetFilter;
  remove?: Maybe<AssetPatch>;
  set?: Maybe<AssetPatch>;
};

export type UpdateAssetPayload = {
  __typename?: 'UpdateAssetPayload';
  asset?: Maybe<Array<Maybe<Asset>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAssetPayloadAssetArgs = {
  filter?: Maybe<AssetFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetOrder>;
};

export type UpdateAssetSupplyInput = {
  filter: AssetSupplyFilter;
  remove?: Maybe<AssetSupplyPatch>;
  set?: Maybe<AssetSupplyPatch>;
};

export type UpdateAssetSupplyPayload = {
  __typename?: 'UpdateAssetSupplyPayload';
  assetSupply?: Maybe<Array<Maybe<AssetSupply>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAssetSupplyPayloadAssetSupplyArgs = {
  filter?: Maybe<AssetSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetSupplyOrder>;
};

export type UpdateAuxiliaryDataBodyInput = {
  filter: AuxiliaryDataBodyFilter;
  remove?: Maybe<AuxiliaryDataBodyPatch>;
  set?: Maybe<AuxiliaryDataBodyPatch>;
};

export type UpdateAuxiliaryDataBodyPayload = {
  __typename?: 'UpdateAuxiliaryDataBodyPayload';
  auxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAuxiliaryDataBodyPayloadAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateAuxiliaryDataInput = {
  filter: AuxiliaryDataFilter;
  remove?: Maybe<AuxiliaryDataPatch>;
  set?: Maybe<AuxiliaryDataPatch>;
};

export type UpdateAuxiliaryDataPayload = {
  __typename?: 'UpdateAuxiliaryDataPayload';
  auxiliaryData?: Maybe<Array<Maybe<AuxiliaryData>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAuxiliaryDataPayloadAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AuxiliaryDataOrder>;
};

export type UpdateBlockInput = {
  filter: BlockFilter;
  remove?: Maybe<BlockPatch>;
  set?: Maybe<BlockPatch>;
};

export type UpdateBlockPayload = {
  __typename?: 'UpdateBlockPayload';
  block?: Maybe<Array<Maybe<Block>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateBlockPayloadBlockArgs = {
  filter?: Maybe<BlockFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BlockOrder>;
};

export type UpdateByronBlockVersionDataInput = {
  filter: ByronBlockVersionDataFilter;
  remove?: Maybe<ByronBlockVersionDataPatch>;
  set?: Maybe<ByronBlockVersionDataPatch>;
};

export type UpdateByronBlockVersionDataPayload = {
  __typename?: 'UpdateByronBlockVersionDataPayload';
  byronBlockVersionData?: Maybe<Array<Maybe<ByronBlockVersionData>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateByronBlockVersionDataPayloadByronBlockVersionDataArgs = {
  filter?: Maybe<ByronBlockVersionDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronBlockVersionDataOrder>;
};

export type UpdateByronGenesisInput = {
  filter: ByronGenesisFilter;
  remove?: Maybe<ByronGenesisPatch>;
  set?: Maybe<ByronGenesisPatch>;
};

export type UpdateByronGenesisPayload = {
  __typename?: 'UpdateByronGenesisPayload';
  byronGenesis?: Maybe<Array<Maybe<ByronGenesis>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateByronGenesisPayloadByronGenesisArgs = {
  filter?: Maybe<ByronGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronGenesisOrder>;
};

export type UpdateByronProtocolConstsInput = {
  filter: ByronProtocolConstsFilter;
  remove?: Maybe<ByronProtocolConstsPatch>;
  set?: Maybe<ByronProtocolConstsPatch>;
};

export type UpdateByronProtocolConstsPayload = {
  __typename?: 'UpdateByronProtocolConstsPayload';
  byronProtocolConsts?: Maybe<Array<Maybe<ByronProtocolConsts>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateByronProtocolConstsPayloadByronProtocolConstsArgs = {
  filter?: Maybe<ByronProtocolConstsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronProtocolConstsOrder>;
};

export type UpdateByronSoftForkRuleInput = {
  filter: ByronSoftForkRuleFilter;
  remove?: Maybe<ByronSoftForkRulePatch>;
  set?: Maybe<ByronSoftForkRulePatch>;
};

export type UpdateByronSoftForkRulePayload = {
  __typename?: 'UpdateByronSoftForkRulePayload';
  byronSoftForkRule?: Maybe<Array<Maybe<ByronSoftForkRule>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateByronSoftForkRulePayloadByronSoftForkRuleArgs = {
  filter?: Maybe<ByronSoftForkRuleFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronSoftForkRuleOrder>;
};

export type UpdateByronTxFeePolicyInput = {
  filter: ByronTxFeePolicyFilter;
  remove?: Maybe<ByronTxFeePolicyPatch>;
  set?: Maybe<ByronTxFeePolicyPatch>;
};

export type UpdateByronTxFeePolicyPayload = {
  __typename?: 'UpdateByronTxFeePolicyPayload';
  byronTxFeePolicy?: Maybe<Array<Maybe<ByronTxFeePolicy>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateByronTxFeePolicyPayloadByronTxFeePolicyArgs = {
  filter?: Maybe<ByronTxFeePolicyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ByronTxFeePolicyOrder>;
};

export type UpdateBytesMetadatumInput = {
  filter: BytesMetadatumFilter;
  remove?: Maybe<BytesMetadatumPatch>;
  set?: Maybe<BytesMetadatumPatch>;
};

export type UpdateBytesMetadatumPayload = {
  __typename?: 'UpdateBytesMetadatumPayload';
  bytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateBytesMetadatumPayloadBytesMetadatumArgs = {
  filter?: Maybe<BytesMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BytesMetadatumOrder>;
};

export type UpdateEpochInput = {
  filter: EpochFilter;
  remove?: Maybe<EpochPatch>;
  set?: Maybe<EpochPatch>;
};

export type UpdateEpochPayload = {
  __typename?: 'UpdateEpochPayload';
  epoch?: Maybe<Array<Maybe<Epoch>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateEpochPayloadEpochArgs = {
  filter?: Maybe<EpochFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<EpochOrder>;
};

export type UpdateExecutionPriceInput = {
  filter: ExecutionPriceFilter;
  remove?: Maybe<ExecutionPricePatch>;
  set?: Maybe<ExecutionPricePatch>;
};

export type UpdateExecutionPricePayload = {
  __typename?: 'UpdateExecutionPricePayload';
  executionPrice?: Maybe<Array<Maybe<ExecutionPrice>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExecutionPricePayloadExecutionPriceArgs = {
  filter?: Maybe<ExecutionPriceFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionPriceOrder>;
};

export type UpdateExecutionPricesInput = {
  filter: ExecutionPricesFilter;
  remove?: Maybe<ExecutionPricesPatch>;
  set?: Maybe<ExecutionPricesPatch>;
};

export type UpdateExecutionPricesPayload = {
  __typename?: 'UpdateExecutionPricesPayload';
  executionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExecutionPricesPayloadExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateExecutionUnitsInput = {
  filter: ExecutionUnitsFilter;
  remove?: Maybe<ExecutionUnitsPatch>;
  set?: Maybe<ExecutionUnitsPatch>;
};

export type UpdateExecutionUnitsPayload = {
  __typename?: 'UpdateExecutionUnitsPayload';
  executionUnits?: Maybe<Array<Maybe<ExecutionUnits>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExecutionUnitsPayloadExecutionUnitsArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExecutionUnitsOrder>;
};

export type UpdateExtendedStakePoolMetadataFieldsInput = {
  filter: ExtendedStakePoolMetadataFieldsFilter;
  remove?: Maybe<ExtendedStakePoolMetadataFieldsPatch>;
  set?: Maybe<ExtendedStakePoolMetadataFieldsPatch>;
};

export type UpdateExtendedStakePoolMetadataFieldsPayload = {
  __typename?: 'UpdateExtendedStakePoolMetadataFieldsPayload';
  extendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExtendedStakePoolMetadataFieldsPayloadExtendedStakePoolMetadataFieldsArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataFieldsOrder>;
};

export type UpdateExtendedStakePoolMetadataInput = {
  filter: ExtendedStakePoolMetadataFilter;
  remove?: Maybe<ExtendedStakePoolMetadataPatch>;
  set?: Maybe<ExtendedStakePoolMetadataPatch>;
};

export type UpdateExtendedStakePoolMetadataPayload = {
  __typename?: 'UpdateExtendedStakePoolMetadataPayload';
  extendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExtendedStakePoolMetadataPayloadExtendedStakePoolMetadataArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ExtendedStakePoolMetadataOrder>;
};

export type UpdateFractionInput = {
  filter: FractionFilter;
  remove?: Maybe<FractionPatch>;
  set?: Maybe<FractionPatch>;
};

export type UpdateFractionPayload = {
  __typename?: 'UpdateFractionPayload';
  fraction?: Maybe<Array<Maybe<Fraction>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateFractionPayloadFractionArgs = {
  filter?: Maybe<FractionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<FractionOrder>;
};

export type UpdateGenesisInput = {
  filter: GenesisFilter;
  remove?: Maybe<GenesisPatch>;
  set?: Maybe<GenesisPatch>;
};

export type UpdateGenesisPayload = {
  __typename?: 'UpdateGenesisPayload';
  genesis?: Maybe<Array<Maybe<Genesis>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateGenesisPayloadGenesisArgs = {
  filter?: Maybe<GenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateItnVerificationInput = {
  filter: ItnVerificationFilter;
  remove?: Maybe<ItnVerificationPatch>;
  set?: Maybe<ItnVerificationPatch>;
};

export type UpdateItnVerificationPayload = {
  __typename?: 'UpdateITNVerificationPayload';
  iTNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateItnVerificationPayloadITnVerificationArgs = {
  filter?: Maybe<ItnVerificationFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ItnVerificationOrder>;
};

export type UpdateIntegerMetadatumInput = {
  filter: IntegerMetadatumFilter;
  remove?: Maybe<IntegerMetadatumPatch>;
  set?: Maybe<IntegerMetadatumPatch>;
};

export type UpdateIntegerMetadatumPayload = {
  __typename?: 'UpdateIntegerMetadatumPayload';
  integerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateIntegerMetadatumPayloadIntegerMetadatumArgs = {
  filter?: Maybe<IntegerMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<IntegerMetadatumOrder>;
};

export type UpdateKeyValueMetadatumInput = {
  filter: KeyValueMetadatumFilter;
  remove?: Maybe<KeyValueMetadatumPatch>;
  set?: Maybe<KeyValueMetadatumPatch>;
};

export type UpdateKeyValueMetadatumPayload = {
  __typename?: 'UpdateKeyValueMetadatumPayload';
  keyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateKeyValueMetadatumPayloadKeyValueMetadatumArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<KeyValueMetadatumOrder>;
};

export type UpdateMetadatumArrayInput = {
  filter: MetadatumArrayFilter;
  remove?: Maybe<MetadatumArrayPatch>;
  set?: Maybe<MetadatumArrayPatch>;
};

export type UpdateMetadatumArrayPayload = {
  __typename?: 'UpdateMetadatumArrayPayload';
  metadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateMetadatumArrayPayloadMetadatumArrayArgs = {
  filter?: Maybe<MetadatumArrayFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateMetadatumMapInput = {
  filter: MetadatumMapFilter;
  remove?: Maybe<MetadatumMapPatch>;
  set?: Maybe<MetadatumMapPatch>;
};

export type UpdateMetadatumMapPayload = {
  __typename?: 'UpdateMetadatumMapPayload';
  metadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateMetadatumMapPayloadMetadatumMapArgs = {
  filter?: Maybe<MetadatumMapFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdatePoolContactDataInput = {
  filter: PoolContactDataFilter;
  remove?: Maybe<PoolContactDataPatch>;
  set?: Maybe<PoolContactDataPatch>;
};

export type UpdatePoolContactDataPayload = {
  __typename?: 'UpdatePoolContactDataPayload';
  numUids?: Maybe<Scalars['Int']>;
  poolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
};


export type UpdatePoolContactDataPayloadPoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolContactDataOrder>;
};

export type UpdateProtocolParametersInput = {
  filter: ProtocolParametersFilter;
  remove?: Maybe<ProtocolParametersPatch>;
  set?: Maybe<ProtocolParametersPatch>;
};

export type UpdateProtocolParametersPayload = {
  __typename?: 'UpdateProtocolParametersPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParameters?: Maybe<Array<Maybe<ProtocolParameters>>>;
};


export type UpdateProtocolParametersPayloadProtocolParametersArgs = {
  filter?: Maybe<ProtocolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersOrder>;
};

export type UpdateProtocolVersionInput = {
  filter: ProtocolVersionFilter;
  remove?: Maybe<ProtocolVersionPatch>;
  set?: Maybe<ProtocolVersionPatch>;
};

export type UpdateProtocolVersionPayload = {
  __typename?: 'UpdateProtocolVersionPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
};


export type UpdateProtocolVersionPayloadProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolVersionOrder>;
};

export type UpdateRedeemerInput = {
  filter: RedeemerFilter;
  remove?: Maybe<RedeemerPatch>;
  set?: Maybe<RedeemerPatch>;
};

export type UpdateRedeemerPayload = {
  __typename?: 'UpdateRedeemerPayload';
  numUids?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<Array<Maybe<Redeemer>>>;
};


export type UpdateRedeemerPayloadRedeemerArgs = {
  filter?: Maybe<RedeemerFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RedeemerOrder>;
};

export type UpdateRelayByAddressInput = {
  filter: RelayByAddressFilter;
  remove?: Maybe<RelayByAddressPatch>;
  set?: Maybe<RelayByAddressPatch>;
};

export type UpdateRelayByAddressPayload = {
  __typename?: 'UpdateRelayByAddressPayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
};


export type UpdateRelayByAddressPayloadRelayByAddressArgs = {
  filter?: Maybe<RelayByAddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByAddressOrder>;
};

export type UpdateRelayByNameInput = {
  filter: RelayByNameFilter;
  remove?: Maybe<RelayByNamePatch>;
  set?: Maybe<RelayByNamePatch>;
};

export type UpdateRelayByNameMultihostInput = {
  filter: RelayByNameMultihostFilter;
  remove?: Maybe<RelayByNameMultihostPatch>;
  set?: Maybe<RelayByNameMultihostPatch>;
};

export type UpdateRelayByNameMultihostPayload = {
  __typename?: 'UpdateRelayByNameMultihostPayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByNameMultihost?: Maybe<Array<Maybe<RelayByNameMultihost>>>;
};


export type UpdateRelayByNameMultihostPayloadRelayByNameMultihostArgs = {
  filter?: Maybe<RelayByNameMultihostFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameMultihostOrder>;
};

export type UpdateRelayByNamePayload = {
  __typename?: 'UpdateRelayByNamePayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByName?: Maybe<Array<Maybe<RelayByName>>>;
};


export type UpdateRelayByNamePayloadRelayByNameArgs = {
  filter?: Maybe<RelayByNameFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RelayByNameOrder>;
};

export type UpdateRewardAccountInput = {
  filter: RewardAccountFilter;
  remove?: Maybe<RewardAccountPatch>;
  set?: Maybe<RewardAccountPatch>;
};

export type UpdateRewardAccountPayload = {
  __typename?: 'UpdateRewardAccountPayload';
  numUids?: Maybe<Scalars['Int']>;
  rewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
};


export type UpdateRewardAccountPayloadRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RewardAccountOrder>;
};

export type UpdateScriptInput = {
  filter: ScriptFilter;
  remove?: Maybe<ScriptPatch>;
  set?: Maybe<ScriptPatch>;
};

export type UpdateScriptPayload = {
  __typename?: 'UpdateScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  script?: Maybe<Array<Maybe<Script>>>;
};


export type UpdateScriptPayloadScriptArgs = {
  filter?: Maybe<ScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ScriptOrder>;
};

export type UpdateShelleyGenesisInput = {
  filter: ShelleyGenesisFilter;
  remove?: Maybe<ShelleyGenesisPatch>;
  set?: Maybe<ShelleyGenesisPatch>;
};

export type UpdateShelleyGenesisPayload = {
  __typename?: 'UpdateShelleyGenesisPayload';
  numUids?: Maybe<Scalars['Int']>;
  shelleyGenesis?: Maybe<Array<Maybe<ShelleyGenesis>>>;
};


export type UpdateShelleyGenesisPayloadShelleyGenesisArgs = {
  filter?: Maybe<ShelleyGenesisFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisOrder>;
};

export type UpdateShelleyGenesisStakingInput = {
  filter: ShelleyGenesisStakingFilter;
  remove?: Maybe<ShelleyGenesisStakingPatch>;
  set?: Maybe<ShelleyGenesisStakingPatch>;
};

export type UpdateShelleyGenesisStakingPayload = {
  __typename?: 'UpdateShelleyGenesisStakingPayload';
  numUids?: Maybe<Scalars['Int']>;
  shelleyGenesisStaking?: Maybe<Array<Maybe<ShelleyGenesisStaking>>>;
};


export type UpdateShelleyGenesisStakingPayloadShelleyGenesisStakingArgs = {
  filter?: Maybe<ShelleyGenesisStakingFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ShelleyGenesisStakingOrder>;
};

export type UpdateSlotInput = {
  filter: SlotFilter;
  remove?: Maybe<SlotPatch>;
  set?: Maybe<SlotPatch>;
};

export type UpdateSlotPayload = {
  __typename?: 'UpdateSlotPayload';
  numUids?: Maybe<Scalars['Int']>;
  slot?: Maybe<Array<Maybe<Slot>>>;
};


export type UpdateSlotPayloadSlotArgs = {
  filter?: Maybe<SlotFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SlotOrder>;
};

export type UpdateStakePoolInput = {
  filter: StakePoolFilter;
  remove?: Maybe<StakePoolPatch>;
  set?: Maybe<StakePoolPatch>;
};

export type UpdateStakePoolMetadataInput = {
  filter: StakePoolMetadataFilter;
  remove?: Maybe<StakePoolMetadataPatch>;
  set?: Maybe<StakePoolMetadataPatch>;
};

export type UpdateStakePoolMetadataJsonInput = {
  filter: StakePoolMetadataJsonFilter;
  remove?: Maybe<StakePoolMetadataJsonPatch>;
  set?: Maybe<StakePoolMetadataJsonPatch>;
};

export type UpdateStakePoolMetadataJsonPayload = {
  __typename?: 'UpdateStakePoolMetadataJsonPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
};


export type UpdateStakePoolMetadataJsonPayloadStakePoolMetadataJsonArgs = {
  filter?: Maybe<StakePoolMetadataJsonFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataJsonOrder>;
};

export type UpdateStakePoolMetadataPayload = {
  __typename?: 'UpdateStakePoolMetadataPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
};


export type UpdateStakePoolMetadataPayloadStakePoolMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetadataOrder>;
};

export type UpdateStakePoolMetricsInput = {
  filter: StakePoolMetricsFilter;
  remove?: Maybe<StakePoolMetricsPatch>;
  set?: Maybe<StakePoolMetricsPatch>;
};

export type UpdateStakePoolMetricsPayload = {
  __typename?: 'UpdateStakePoolMetricsPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
};


export type UpdateStakePoolMetricsPayloadStakePoolMetricsArgs = {
  filter?: Maybe<StakePoolMetricsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsOrder>;
};

export type UpdateStakePoolMetricsSizeInput = {
  filter: StakePoolMetricsSizeFilter;
  remove?: Maybe<StakePoolMetricsSizePatch>;
  set?: Maybe<StakePoolMetricsSizePatch>;
};

export type UpdateStakePoolMetricsSizePayload = {
  __typename?: 'UpdateStakePoolMetricsSizePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
};


export type UpdateStakePoolMetricsSizePayloadStakePoolMetricsSizeArgs = {
  filter?: Maybe<StakePoolMetricsSizeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsSizeOrder>;
};

export type UpdateStakePoolMetricsStakeInput = {
  filter: StakePoolMetricsStakeFilter;
  remove?: Maybe<StakePoolMetricsStakePatch>;
  set?: Maybe<StakePoolMetricsStakePatch>;
};

export type UpdateStakePoolMetricsStakePayload = {
  __typename?: 'UpdateStakePoolMetricsStakePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
};


export type UpdateStakePoolMetricsStakePayloadStakePoolMetricsStakeArgs = {
  filter?: Maybe<StakePoolMetricsStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolMetricsStakeOrder>;
};

export type UpdateStakePoolPayload = {
  __typename?: 'UpdateStakePoolPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<Array<Maybe<StakePool>>>;
};


export type UpdateStakePoolPayloadStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StakePoolOrder>;
};

export type UpdateStakePoolTransactionsInput = {
  filter: StakePoolTransactionsFilter;
  remove?: Maybe<StakePoolTransactionsPatch>;
  set?: Maybe<StakePoolTransactionsPatch>;
};

export type UpdateStakePoolTransactionsPayload = {
  __typename?: 'UpdateStakePoolTransactionsPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolTransactions?: Maybe<Array<Maybe<StakePoolTransactions>>>;
};


export type UpdateStakePoolTransactionsPayloadStakePoolTransactionsArgs = {
  filter?: Maybe<StakePoolTransactionsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateStringMetadatumInput = {
  filter: StringMetadatumFilter;
  remove?: Maybe<StringMetadatumPatch>;
  set?: Maybe<StringMetadatumPatch>;
};

export type UpdateStringMetadatumPayload = {
  __typename?: 'UpdateStringMetadatumPayload';
  numUids?: Maybe<Scalars['Int']>;
  stringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
};


export type UpdateStringMetadatumPayloadStringMetadatumArgs = {
  filter?: Maybe<StringMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<StringMetadatumOrder>;
};

export type UpdateThePoolsMediaAssetsInput = {
  filter: ThePoolsMediaAssetsFilter;
  remove?: Maybe<ThePoolsMediaAssetsPatch>;
  set?: Maybe<ThePoolsMediaAssetsPatch>;
};

export type UpdateThePoolsMediaAssetsPayload = {
  __typename?: 'UpdateThePoolsMediaAssetsPayload';
  numUids?: Maybe<Scalars['Int']>;
  thePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
};


export type UpdateThePoolsMediaAssetsPayloadThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ThePoolsMediaAssetsOrder>;
};

export type UpdateTokenInput = {
  filter: TokenFilter;
  remove?: Maybe<TokenPatch>;
  set?: Maybe<TokenPatch>;
};

export type UpdateTokenPayload = {
  __typename?: 'UpdateTokenPayload';
  numUids?: Maybe<Scalars['Int']>;
  token?: Maybe<Array<Maybe<Token>>>;
};


export type UpdateTokenPayloadTokenArgs = {
  filter?: Maybe<TokenFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TokenOrder>;
};

export type UpdateTransactionInput = {
  filter: TransactionFilter;
  remove?: Maybe<TransactionPatch>;
  set?: Maybe<TransactionPatch>;
};

export type UpdateTransactionInputInput = {
  filter: TransactionInputFilter;
  remove?: Maybe<TransactionInputPatch>;
  set?: Maybe<TransactionInputPatch>;
};

export type UpdateTransactionInputPayload = {
  __typename?: 'UpdateTransactionInputPayload';
  numUids?: Maybe<Scalars['Int']>;
  transactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
};


export type UpdateTransactionInputPayloadTransactionInputArgs = {
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};

export type UpdateTransactionOutputInput = {
  filter: TransactionOutputFilter;
  remove?: Maybe<TransactionOutputPatch>;
  set?: Maybe<TransactionOutputPatch>;
};

export type UpdateTransactionOutputPayload = {
  __typename?: 'UpdateTransactionOutputPayload';
  numUids?: Maybe<Scalars['Int']>;
  transactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
};


export type UpdateTransactionOutputPayloadTransactionOutputArgs = {
  filter?: Maybe<TransactionOutputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOutputOrder>;
};

export type UpdateTransactionPayload = {
  __typename?: 'UpdateTransactionPayload';
  numUids?: Maybe<Scalars['Int']>;
  transaction?: Maybe<Array<Maybe<Transaction>>>;
};


export type UpdateTransactionPayloadTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOrder>;
};

export type UpdateValueInput = {
  filter: ValueFilter;
  remove?: Maybe<ValuePatch>;
  set?: Maybe<ValuePatch>;
};

export type UpdateValuePayload = {
  __typename?: 'UpdateValuePayload';
  numUids?: Maybe<Scalars['Int']>;
  value?: Maybe<Array<Maybe<Value>>>;
};


export type UpdateValuePayloadValueArgs = {
  filter?: Maybe<ValueFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ValueOrder>;
};

export type UpdateWithdrawalInput = {
  filter: WithdrawalFilter;
  remove?: Maybe<WithdrawalPatch>;
  set?: Maybe<WithdrawalPatch>;
};

export type UpdateWithdrawalPayload = {
  __typename?: 'UpdateWithdrawalPayload';
  numUids?: Maybe<Scalars['Int']>;
  withdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
};


export type UpdateWithdrawalPayloadWithdrawalArgs = {
  filter?: Maybe<WithdrawalFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WithdrawalOrder>;
};

export type Value = {
  __typename?: 'Value';
  assets?: Maybe<Array<Token>>;
  assetsAggregate?: Maybe<TokenAggregateResult>;
  coin: Scalars['Int64'];
};


export type ValueAssetsArgs = {
  filter?: Maybe<TokenFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TokenOrder>;
};


export type ValueAssetsAggregateArgs = {
  filter?: Maybe<TokenFilter>;
};

export type ValueAggregateResult = {
  __typename?: 'ValueAggregateResult';
  coinAvg?: Maybe<Scalars['Float']>;
  coinMax?: Maybe<Scalars['Int64']>;
  coinMin?: Maybe<Scalars['Int64']>;
  coinSum?: Maybe<Scalars['Int64']>;
  count?: Maybe<Scalars['Int']>;
};

export type ValueFilter = {
  and?: Maybe<Array<Maybe<ValueFilter>>>;
  has?: Maybe<Array<Maybe<ValueHasFilter>>>;
  not?: Maybe<ValueFilter>;
  or?: Maybe<Array<Maybe<ValueFilter>>>;
};

export enum ValueHasFilter {
  Assets = 'assets',
  Coin = 'coin'
}

export type ValueOrder = {
  asc?: Maybe<ValueOrderable>;
  desc?: Maybe<ValueOrderable>;
  then?: Maybe<ValueOrder>;
};

export enum ValueOrderable {
  Coin = 'coin'
}

export type ValuePatch = {
  assets?: Maybe<Array<TokenRef>>;
  coin?: Maybe<Scalars['Int64']>;
};

export type ValueRef = {
  assets?: Maybe<Array<TokenRef>>;
  coin?: Maybe<Scalars['Int64']>;
};

export type Withdrawal = {
  __typename?: 'Withdrawal';
  quantity: Scalars['Int64'];
  redeemer?: Maybe<Scalars['String']>;
  rewardAccount: RewardAccount;
  transaction: Transaction;
};


export type WithdrawalRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type WithdrawalTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type WithdrawalAggregateResult = {
  __typename?: 'WithdrawalAggregateResult';
  count?: Maybe<Scalars['Int']>;
  quantityAvg?: Maybe<Scalars['Float']>;
  quantityMax?: Maybe<Scalars['Int64']>;
  quantityMin?: Maybe<Scalars['Int64']>;
  quantitySum?: Maybe<Scalars['Int64']>;
  redeemerMax?: Maybe<Scalars['String']>;
  redeemerMin?: Maybe<Scalars['String']>;
};

export type WithdrawalFilter = {
  and?: Maybe<Array<Maybe<WithdrawalFilter>>>;
  has?: Maybe<Array<Maybe<WithdrawalHasFilter>>>;
  not?: Maybe<WithdrawalFilter>;
  or?: Maybe<Array<Maybe<WithdrawalFilter>>>;
};

export enum WithdrawalHasFilter {
  Quantity = 'quantity',
  Redeemer = 'redeemer',
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type WithdrawalOrder = {
  asc?: Maybe<WithdrawalOrderable>;
  desc?: Maybe<WithdrawalOrderable>;
  then?: Maybe<WithdrawalOrder>;
};

export enum WithdrawalOrderable {
  Quantity = 'quantity',
  Redeemer = 'redeemer'
}

export type WithdrawalPatch = {
  quantity?: Maybe<Scalars['Int64']>;
  redeemer?: Maybe<Scalars['String']>;
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
};

export type WithdrawalRef = {
  quantity?: Maybe<Scalars['Int64']>;
  redeemer?: Maybe<Scalars['String']>;
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
};

export type WithinFilter = {
  polygon: PolygonRef;
};

export type BlocksByHashesQueryVariables = Exact<{
  hashes: Array<Scalars['String']> | Scalars['String'];
}>;


export type BlocksByHashesQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', size: bigint, totalOutput: bigint, fees: bigint, hash: string, blockNo: number, confirmations: number, slot: { __typename?: 'Slot', number: number, date: string, slotInEpoch: number }, issuer: { __typename?: 'StakePool', id: string, vrf: string }, transactionsAggregate?: { __typename?: 'TransactionAggregateResult', count?: number | null | undefined } | null | undefined, epoch: { __typename?: 'Epoch', number: number }, previousBlock: { __typename?: 'Block', hash: string }, nextBlock: { __typename?: 'Block', hash: string } } | null | undefined> | null | undefined };

export type GenesisParametersQueryVariables = Exact<{ [key: string]: never; }>;


export type GenesisParametersQuery = { __typename?: 'Query', queryShelleyGenesis?: Array<{ __typename?: 'ShelleyGenesis', systemStart: string, networkMagic: number, activeSlotsCoeff: number, securityParam: number, epochLength: number, slotsPerKESPeriod: number, maxKESEvolutions: number, slotLength: number, updateQuorum: number, maxLovelaceSupply: bigint } | null | undefined> | null | undefined };

export type NetworkInfoQueryVariables = Exact<{ [key: string]: never; }>;


export type NetworkInfoQuery = { __typename?: 'Query', queryEpoch?: Array<{ __typename?: 'Epoch', number: number, startedAt: { __typename?: 'Slot', date: string }, activeStakeAggregate?: { __typename?: 'ActiveStakeAggregateResult', quantitySum?: bigint | null | undefined } | null | undefined } | null | undefined> | null | undefined, queryShelleyGenesis?: Array<{ __typename?: 'ShelleyGenesis', slotLength: number, epochLength: number } | null | undefined> | null | undefined, queryAda?: Array<{ __typename?: 'Ada', supply: { __typename?: 'AssetSupply', circulating: string, max: string, total?: string | null | undefined } } | null | undefined> | null | undefined };

export type ProtocolParametersQueryVariables = Exact<{ [key: string]: never; }>;


export type ProtocolParametersQuery = { __typename?: 'Query', queryProtocolParameters?: Array<{ __typename?: 'ProtocolParameters', coinsPerUtxoWord?: number | null | undefined, maxTxSize: number, maxValSize: number, keyDeposit: number, poolDeposit: number, maxCollateralInputs?: number | null | undefined, minFeeA: number, minFeeB: number, minPoolCost: number, protocolVersion: { __typename?: 'ProtocolVersion', major: number, minor: number, patch?: number | null | undefined } } | null | undefined> | null | undefined };

export type AllStakePoolFieldsFragment = { __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, owners: Array<string>, cost: string, vrf: string, rewardAccount: string, pledge: string, margin: { __typename?: 'Fraction', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: string, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: string, active: string }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, transactions: { __typename?: 'StakePoolTransactions', registration: Array<string>, retirement: Array<string> }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined };

export type StakePoolsByMetadataQueryVariables = Exact<{
  query: Scalars['String'];
  omit?: Maybe<Array<Scalars['String']> | Scalars['String']>;
}>;


export type StakePoolsByMetadataQuery = { __typename?: 'Query', queryStakePoolMetadata?: Array<{ __typename?: 'StakePoolMetadata', stakePool: { __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, owners: Array<string>, cost: string, vrf: string, rewardAccount: string, pledge: string, margin: { __typename?: 'Fraction', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: string, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: string, active: string }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, transactions: { __typename?: 'StakePoolTransactions', registration: Array<string>, retirement: Array<string> }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined } } | null | undefined> | null | undefined };

export type StakePoolsQueryVariables = Exact<{
  query: Scalars['String'];
}>;


export type StakePoolsQuery = { __typename?: 'Query', queryStakePool?: Array<{ __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, owners: Array<string>, cost: string, vrf: string, rewardAccount: string, pledge: string, margin: { __typename?: 'Fraction', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: string, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: string, active: string }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, transactions: { __typename?: 'StakePoolTransactions', registration: Array<string>, retirement: Array<string> }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined } | null | undefined> | null | undefined };

export type TipQueryVariables = Exact<{ [key: string]: never; }>;


export type TipQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', hash: string, blockNo: number, slot: { __typename?: 'Slot', number: number } } | null | undefined> | null | undefined };

export const AllStakePoolFieldsFragmentDoc = gql`
    fragment allStakePoolFields on StakePool {
  id
  hexId
  status
  owners
  cost
  margin {
    numerator
    denominator
  }
  vrf
  relays {
    __typename
    ... on RelayByName {
      hostname
      port
    }
    ... on RelayByAddress {
      ipv4
      ipv6
      port
    }
    ... on RelayByNameMultihost {
      dnsName
    }
  }
  rewardAccount
  pledge
  metrics {
    blocksCreated
    livePledge
    stake {
      live
      active
    }
    size {
      live
      active
    }
    saturation
    delegators
  }
  transactions {
    registration
    retirement
  }
  metadataJson {
    hash
    url
  }
  metadata {
    ticker
    name
    description
    homepage
    extDataUrl
    extSigUrl
    extVkey
    ext {
      serial
      pool {
        id
        country
        status
        contact {
          primary
          email
          facebook
          github
          feed
          telegram
          twitter
        }
        media_assets {
          icon_png_64x64
          logo_png
          logo_svg
          color_fg
          color_bg
        }
        itn {
          owner
          witness
        }
      }
    }
  }
}
    `;
export const BlocksByHashesDocument = gql`
    query BlocksByHashes($hashes: [String!]!) {
  queryBlock(filter: {hash: {in: $hashes}}) {
    slot {
      number
      date
      slotInEpoch
    }
    issuer {
      id
      vrf
    }
    size
    transactionsAggregate {
      count
    }
    totalOutput
    fees
    epoch {
      number
    }
    hash
    blockNo
    previousBlock {
      hash
    }
    nextBlock {
      hash
    }
    confirmations
  }
}
    `;
export const GenesisParametersDocument = gql`
    query GenesisParameters {
  queryShelleyGenesis {
    systemStart
    networkMagic
    activeSlotsCoeff
    securityParam
    epochLength
    slotsPerKESPeriod
    maxKESEvolutions
    slotLength
    updateQuorum
    maxLovelaceSupply
  }
}
    `;
export const NetworkInfoDocument = gql`
    query NetworkInfo {
  queryEpoch(order: {desc: number}, first: 1) {
    number
    startedAt {
      date
    }
    activeStakeAggregate {
      quantitySum
    }
  }
  queryShelleyGenesis(first: 1) {
    slotLength
    epochLength
  }
  queryAda(first: 1) {
    supply {
      circulating
      max
      total
    }
  }
}
    `;
export const ProtocolParametersDocument = gql`
    query ProtocolParameters {
  queryProtocolParameters(first: 1) {
    coinsPerUtxoWord
    maxTxSize
    maxValSize
    keyDeposit
    poolDeposit
    maxCollateralInputs
    minFeeA
    minFeeB
    minPoolCost
    protocolVersion {
      major
      minor
      patch
    }
  }
}
    `;
export const StakePoolsByMetadataDocument = gql`
    query StakePoolsByMetadata($query: String!, $omit: [String!] = ["NEED_THIS_BECAUSE_IN_OPERATOR_WONT_WORK_WITH_EMPTY_ARR"]) {
  queryStakePoolMetadata(
    filter: {and: [{or: [{name: {anyoftext: $query}}, {ticker: {anyoftext: $query}}]}, {not: {stakePoolId: {in: $omit}}}]}
  ) {
    stakePool {
      ...allStakePoolFields
    }
  }
}
    ${AllStakePoolFieldsFragmentDoc}`;
export const StakePoolsDocument = gql`
    query StakePools($query: String!) {
  queryStakePool(filter: {id: {anyoftext: $query}}) {
    ...allStakePoolFields
  }
}
    ${AllStakePoolFieldsFragmentDoc}`;
export const TipDocument = gql`
    query Tip {
  queryBlock(order: {desc: blockNo}, first: 1) {
    slot {
      number
    }
    hash
    blockNo
  }
}
    `;

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName) => action();

export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    BlocksByHashes(variables: BlocksByHashesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<BlocksByHashesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<BlocksByHashesQuery>(BlocksByHashesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'BlocksByHashes');
    },
    GenesisParameters(variables?: GenesisParametersQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GenesisParametersQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GenesisParametersQuery>(GenesisParametersDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'GenesisParameters');
    },
    NetworkInfo(variables?: NetworkInfoQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<NetworkInfoQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<NetworkInfoQuery>(NetworkInfoDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'NetworkInfo');
    },
    ProtocolParameters(variables?: ProtocolParametersQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<ProtocolParametersQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<ProtocolParametersQuery>(ProtocolParametersDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'ProtocolParameters');
    },
    StakePoolsByMetadata(variables: StakePoolsByMetadataQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<StakePoolsByMetadataQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<StakePoolsByMetadataQuery>(StakePoolsByMetadataDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'StakePoolsByMetadata');
    },
    StakePools(variables: StakePoolsQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<StakePoolsQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<StakePoolsQuery>(StakePoolsDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'StakePools');
    },
    Tip(variables?: TipQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<TipQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<TipQuery>(TipDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'Tip');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;