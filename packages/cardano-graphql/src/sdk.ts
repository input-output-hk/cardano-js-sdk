import { GraphQLClient } from 'graphql-request';
import * as Dom from 'graphql-request/dist/types.dom';
import gql from 'graphql-tag';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
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
  Int64: number | bigint;
};

export type ActiveStake = {
  __typename?: 'ActiveStake';
  epoch: Epoch;
  epochNo: Scalars['Int'];
  quantity: Scalars['Int64'];
  rewardAccount: RewardAccount;
  stakePool: StakePool;
};


export type ActiveStakeEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type ActiveStakeRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type ActiveStakeStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
};

export type ActiveStakeAggregateResult = {
  __typename?: 'ActiveStakeAggregateResult';
  count?: Maybe<Scalars['Int']>;
  epochNoAvg?: Maybe<Scalars['Float']>;
  epochNoMax?: Maybe<Scalars['Int']>;
  epochNoMin?: Maybe<Scalars['Int']>;
  epochNoSum?: Maybe<Scalars['Int']>;
  quantityAvg?: Maybe<Scalars['Float']>;
  quantityMax?: Maybe<Scalars['Int64']>;
  quantityMin?: Maybe<Scalars['Int64']>;
  quantitySum?: Maybe<Scalars['Int64']>;
};

export type ActiveStakeFilter = {
  and?: InputMaybe<Array<InputMaybe<ActiveStakeFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ActiveStakeHasFilter>>>;
  not?: InputMaybe<ActiveStakeFilter>;
  or?: InputMaybe<Array<InputMaybe<ActiveStakeFilter>>>;
};

export enum ActiveStakeHasFilter {
  Epoch = 'epoch',
  EpochNo = 'epochNo',
  Quantity = 'quantity',
  RewardAccount = 'rewardAccount',
  StakePool = 'stakePool'
}

export type ActiveStakeOrder = {
  asc?: InputMaybe<ActiveStakeOrderable>;
  desc?: InputMaybe<ActiveStakeOrderable>;
  then?: InputMaybe<ActiveStakeOrder>;
};

export enum ActiveStakeOrderable {
  EpochNo = 'epochNo',
  Quantity = 'quantity'
}

export type ActiveStakePatch = {
  epoch?: InputMaybe<EpochRef>;
  epochNo?: InputMaybe<Scalars['Int']>;
  quantity?: InputMaybe<Scalars['Int64']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  stakePool?: InputMaybe<StakePoolRef>;
};

export type ActiveStakeRef = {
  epoch?: InputMaybe<EpochRef>;
  epochNo?: InputMaybe<Scalars['Int']>;
  quantity?: InputMaybe<Scalars['Int64']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  stakePool?: InputMaybe<StakePoolRef>;
};

export type Ada = {
  __typename?: 'Ada';
  sinceBlock: Block;
  sinceBlockNo: Scalars['Int'];
  supply: CoinSupply;
};


export type AdaSinceBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
};


export type AdaSupplyArgs = {
  filter?: InputMaybe<CoinSupplyFilter>;
};

export type AdaAggregateResult = {
  __typename?: 'AdaAggregateResult';
  count?: Maybe<Scalars['Int']>;
  sinceBlockNoAvg?: Maybe<Scalars['Float']>;
  sinceBlockNoMax?: Maybe<Scalars['Int']>;
  sinceBlockNoMin?: Maybe<Scalars['Int']>;
  sinceBlockNoSum?: Maybe<Scalars['Int']>;
};

export type AdaFilter = {
  and?: InputMaybe<Array<InputMaybe<AdaFilter>>>;
  has?: InputMaybe<Array<InputMaybe<AdaHasFilter>>>;
  not?: InputMaybe<AdaFilter>;
  or?: InputMaybe<Array<InputMaybe<AdaFilter>>>;
};

export enum AdaHasFilter {
  SinceBlock = 'sinceBlock',
  SinceBlockNo = 'sinceBlockNo',
  Supply = 'supply'
}

export type AdaOrder = {
  asc?: InputMaybe<AdaOrderable>;
  desc?: InputMaybe<AdaOrderable>;
  then?: InputMaybe<AdaOrder>;
};

export enum AdaOrderable {
  SinceBlockNo = 'sinceBlockNo'
}

export type AdaPatch = {
  sinceBlock?: InputMaybe<BlockRef>;
  sinceBlockNo?: InputMaybe<Scalars['Int']>;
  supply?: InputMaybe<CoinSupplyRef>;
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
  filter?: InputMaybe<SlotFilter>;
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
  and?: InputMaybe<Array<InputMaybe<AdaPotsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<AdaPotsHasFilter>>>;
  not?: InputMaybe<AdaPotsFilter>;
  or?: InputMaybe<Array<InputMaybe<AdaPotsFilter>>>;
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
  asc?: InputMaybe<AdaPotsOrderable>;
  desc?: InputMaybe<AdaPotsOrderable>;
  then?: InputMaybe<AdaPotsOrder>;
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
  deposits?: InputMaybe<Scalars['Int64']>;
  fees?: InputMaybe<Scalars['Int64']>;
  reserves?: InputMaybe<Scalars['Int64']>;
  rewards?: InputMaybe<Scalars['Int64']>;
  slot?: InputMaybe<SlotRef>;
  treasury?: InputMaybe<Scalars['Int64']>;
  utxo?: InputMaybe<Scalars['Int64']>;
};

export type AdaPotsRef = {
  deposits?: InputMaybe<Scalars['Int64']>;
  fees?: InputMaybe<Scalars['Int64']>;
  reserves?: InputMaybe<Scalars['Int64']>;
  rewards?: InputMaybe<Scalars['Int64']>;
  slot?: InputMaybe<SlotRef>;
  treasury?: InputMaybe<Scalars['Int64']>;
  utxo?: InputMaybe<Scalars['Int64']>;
};

export type AdaRef = {
  sinceBlock?: InputMaybe<BlockRef>;
  sinceBlockNo?: InputMaybe<Scalars['Int']>;
  supply?: InputMaybe<CoinSupplyRef>;
};

export type AddActiveStakeInput = {
  epoch: EpochRef;
  epochNo: Scalars['Int'];
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
  filter?: InputMaybe<ActiveStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ActiveStakeOrder>;
};

export type AddAdaInput = {
  sinceBlock: BlockRef;
  sinceBlockNo: Scalars['Int'];
  supply: CoinSupplyRef;
};

export type AddAdaPayload = {
  __typename?: 'AddAdaPayload';
  ada?: Maybe<Array<Maybe<Ada>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAdaPayloadAdaArgs = {
  filter?: InputMaybe<AdaFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaOrder>;
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
  filter?: InputMaybe<AdaPotsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaPotsOrder>;
};

export type AddAddressInput = {
  address: Scalars['String'];
  addressType: AddressType;
  inputs: Array<TransactionInputRef>;
  paymentPublicKey: PublicKeyRef;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  utxo: Array<TransactionOutputRef>;
};

export type AddAddressPayload = {
  __typename?: 'AddAddressPayload';
  address?: Maybe<Array<Maybe<Address>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAddressPayloadAddressArgs = {
  filter?: InputMaybe<AddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AddressOrder>;
};

export type AddAssetInput = {
  /** concatenated PolicyId and AssetName, hex-encoded */
  assetId: Scalars['String'];
  /** hex-encoded */
  assetName: Scalars['String'];
  assetNameUTF8: Scalars['String'];
  /** Fingerprint of a native asset for human comparison. CIP-0014 */
  fingerprint: Scalars['String'];
  history: Array<AssetMintOrBurnRef>;
  nftMetadata?: InputMaybe<NftMetadataRef>;
  policy: PolicyRef;
  tokenMetadata?: InputMaybe<TokenMetadataRef>;
  totalQuantity: Scalars['Int64'];
};

export type AddAssetMintOrBurnInput = {
  quantity: Scalars['Int64'];
  transaction: TransactionRef;
};

export type AddAssetMintOrBurnPayload = {
  __typename?: 'AddAssetMintOrBurnPayload';
  assetMintOrBurn?: Maybe<Array<Maybe<AssetMintOrBurn>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAssetMintOrBurnPayloadAssetMintOrBurnArgs = {
  filter?: InputMaybe<AssetMintOrBurnFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetMintOrBurnOrder>;
};

export type AddAssetPayload = {
  __typename?: 'AddAssetPayload';
  asset?: Maybe<Array<Maybe<Asset>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAssetPayloadAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetOrder>;
};

export type AddAuxiliaryDataBodyInput = {
  auxiliaryData: AuxiliaryDataRef;
  blob?: InputMaybe<Array<KeyValueMetadatumRef>>;
  scripts?: InputMaybe<Array<AuxiliaryScriptRef>>;
};

export type AddAuxiliaryDataBodyPayload = {
  __typename?: 'AddAuxiliaryDataBodyPayload';
  auxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAuxiliaryDataBodyPayloadAuxiliaryDataBodyArgs = {
  filter?: InputMaybe<AuxiliaryDataBodyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
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
  filter?: InputMaybe<AuxiliaryDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AuxiliaryDataOrder>;
};

export type AddAuxiliaryScriptInput = {
  auxiliaryDataBody: AuxiliaryDataBodyRef;
  script: ScriptRef;
};

export type AddAuxiliaryScriptPayload = {
  __typename?: 'AddAuxiliaryScriptPayload';
  auxiliaryScript?: Maybe<Array<Maybe<AuxiliaryScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddAuxiliaryScriptPayloadAuxiliaryScriptArgs = {
  filter?: InputMaybe<AuxiliaryScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddBlockInput = {
  blockNo: Scalars['Int'];
  confirmations: Scalars['Int'];
  epoch: EpochRef;
  hash: Scalars['String'];
  issuer: StakePoolRef;
  nextBlock: BlockRef;
  nextBlockProtocolVersion: ProtocolVersionRef;
  opCert: Scalars['String'];
  previousBlock: BlockRef;
  size: Scalars['Int64'];
  slot: SlotRef;
  totalFees: Scalars['Int64'];
  totalLiveStake: Scalars['Int64'];
  totalOutput: Scalars['Int64'];
  transactions: Array<TransactionRef>;
};

export type AddBlockPayload = {
  __typename?: 'AddBlockPayload';
  block?: Maybe<Array<Maybe<Block>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddBlockPayloadBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BlockOrder>;
};

export type AddBootstrapWitnessInput = {
  /** Extra attributes carried by Byron addresses (network magic and/or HD payload) */
  addressAttributes?: InputMaybe<Scalars['String']>;
  /** An Ed25519-BIP32 chain-code for key deriviation */
  chainCode?: InputMaybe<Scalars['String']>;
  key?: InputMaybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature: Scalars['String'];
};

export type AddBootstrapWitnessPayload = {
  __typename?: 'AddBootstrapWitnessPayload';
  bootstrapWitness?: Maybe<Array<Maybe<BootstrapWitness>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddBootstrapWitnessPayloadBootstrapWitnessArgs = {
  filter?: InputMaybe<BootstrapWitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BootstrapWitnessOrder>;
};

export type AddBytesMetadatumInput = {
  bytes: Scalars['String'];
};

export type AddBytesMetadatumPayload = {
  __typename?: 'AddBytesMetadatumPayload';
  bytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddBytesMetadatumPayloadBytesMetadatumArgs = {
  filter?: InputMaybe<BytesMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BytesMetadatumOrder>;
};

export type AddCoinSupplyInput = {
  circulating: Scalars['Int64'];
  max: Scalars['Int64'];
  total: Scalars['Int64'];
};

export type AddCoinSupplyPayload = {
  __typename?: 'AddCoinSupplyPayload';
  coinSupply?: Maybe<Array<Maybe<CoinSupply>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddCoinSupplyPayloadCoinSupplyArgs = {
  filter?: InputMaybe<CoinSupplyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CoinSupplyOrder>;
};

export type AddCostModelCoefficientInput = {
  coefficient: Scalars['Int'];
  key: Scalars['String'];
};

export type AddCostModelCoefficientPayload = {
  __typename?: 'AddCostModelCoefficientPayload';
  costModelCoefficient?: Maybe<Array<Maybe<CostModelCoefficient>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddCostModelCoefficientPayloadCostModelCoefficientArgs = {
  filter?: InputMaybe<CostModelCoefficientFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelCoefficientOrder>;
};

export type AddCostModelInput = {
  coefficients: Array<CostModelCoefficientRef>;
  language: Scalars['String'];
};

export type AddCostModelPayload = {
  __typename?: 'AddCostModelPayload';
  costModel?: Maybe<Array<Maybe<CostModel>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddCostModelPayloadCostModelArgs = {
  filter?: InputMaybe<CostModelFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelOrder>;
};

export type AddDatumInput = {
  datum: Scalars['String'];
  hash: Scalars['String'];
};

export type AddDatumPayload = {
  __typename?: 'AddDatumPayload';
  datum?: Maybe<Array<Maybe<Datum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddDatumPayloadDatumArgs = {
  filter?: InputMaybe<DatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<DatumOrder>;
};

export type AddEpochInput = {
  activeRewards: Array<RewardRef>;
  activeStake: Array<ActiveStakeRef>;
  adaPots: AdaPotsRef;
  blocks: Array<BlockRef>;
  endedAt: SlotRef;
  fees: Scalars['Int64'];
  liveRewards: Array<RewardRef>;
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
  filter?: InputMaybe<EpochFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<EpochOrder>;
};

export type AddExecutionPricesInput = {
  prMem: RatioRef;
  prSteps: RatioRef;
};

export type AddExecutionPricesPayload = {
  __typename?: 'AddExecutionPricesPayload';
  executionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddExecutionPricesPayloadExecutionPricesArgs = {
  filter?: InputMaybe<ExecutionPricesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
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
  filter?: InputMaybe<ExecutionUnitsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExecutionUnitsOrder>;
};

export type AddExtendedStakePoolMetadataFieldsInput = {
  contact?: InputMaybe<PoolContactDataRef>;
  country?: InputMaybe<Scalars['String']>;
  id: Scalars['String'];
  itn?: InputMaybe<ItnVerificationRef>;
  media_assets?: InputMaybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: InputMaybe<ExtendedPoolStatus>;
};

export type AddExtendedStakePoolMetadataFieldsPayload = {
  __typename?: 'AddExtendedStakePoolMetadataFieldsPayload';
  extendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddExtendedStakePoolMetadataFieldsPayloadExtendedStakePoolMetadataFieldsArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataFieldsOrder>;
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
  filter?: InputMaybe<ExtendedStakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataOrder>;
};

export type AddGenesisKeyDelegationCertificateInput = {
  genesisDelegateHash: Scalars['String'];
  genesisHash: Scalars['String'];
  transaction: TransactionRef;
  vrfKeyHash: Scalars['String'];
};

export type AddGenesisKeyDelegationCertificatePayload = {
  __typename?: 'AddGenesisKeyDelegationCertificatePayload';
  genesisKeyDelegationCertificate?: Maybe<Array<Maybe<GenesisKeyDelegationCertificate>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddGenesisKeyDelegationCertificatePayloadGenesisKeyDelegationCertificateArgs = {
  filter?: InputMaybe<GenesisKeyDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<GenesisKeyDelegationCertificateOrder>;
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
  filter?: InputMaybe<ItnVerificationFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ItnVerificationOrder>;
};

export type AddIntegerMetadatumInput = {
  int: Scalars['Int'];
};

export type AddIntegerMetadatumPayload = {
  __typename?: 'AddIntegerMetadatumPayload';
  integerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddIntegerMetadatumPayloadIntegerMetadatumArgs = {
  filter?: InputMaybe<IntegerMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<IntegerMetadatumOrder>;
};

export type AddKeyValueMetadatumInput = {
  label: Scalars['String'];
  metadatum: MetadatumRef;
};

export type AddKeyValueMetadatumPayload = {
  __typename?: 'AddKeyValueMetadatumPayload';
  keyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddKeyValueMetadatumPayloadKeyValueMetadatumArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<KeyValueMetadatumOrder>;
};

export type AddMetadatumArrayInput = {
  array: Array<MetadatumRef>;
};

export type AddMetadatumArrayPayload = {
  __typename?: 'AddMetadatumArrayPayload';
  metadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddMetadatumArrayPayloadMetadatumArrayArgs = {
  filter?: InputMaybe<MetadatumArrayFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddMetadatumMapInput = {
  map: Array<KeyValueMetadatumRef>;
};

export type AddMetadatumMapPayload = {
  __typename?: 'AddMetadatumMapPayload';
  metadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddMetadatumMapPayloadMetadatumMapArgs = {
  filter?: InputMaybe<MetadatumMapFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddMirCertificateInput = {
  pot: Scalars['String'];
  quantity: Scalars['Int64'];
  rewardAccount: RewardAccountRef;
  transaction: TransactionRef;
};

export type AddMirCertificatePayload = {
  __typename?: 'AddMirCertificatePayload';
  mirCertificate?: Maybe<Array<Maybe<MirCertificate>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddMirCertificatePayloadMirCertificateArgs = {
  filter?: InputMaybe<MirCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<MirCertificateOrder>;
};

export type AddNOfInput = {
  key: Scalars['String'];
  scripts: Array<NativeScriptRef>;
};

export type AddNOfPayload = {
  __typename?: 'AddNOfPayload';
  nOf?: Maybe<Array<Maybe<NOf>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddNOfPayloadNOfArgs = {
  filter?: InputMaybe<NOfFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NOfOrder>;
};

export type AddNativeScriptInput = {
  all?: InputMaybe<Array<NativeScriptRef>>;
  any?: InputMaybe<Array<NativeScriptRef>>;
  expiresAt?: InputMaybe<SlotRef>;
  nof?: InputMaybe<Array<NOfRef>>;
  startsAt?: InputMaybe<SlotRef>;
  vkey?: InputMaybe<PublicKeyRef>;
};

export type AddNativeScriptPayload = {
  __typename?: 'AddNativeScriptPayload';
  nativeScript?: Maybe<Array<Maybe<NativeScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddNativeScriptPayloadNativeScriptArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddNetworkConstantsInput = {
  activeSlotsCoefficient: Scalars['Float'];
  maxKESEvolutions: Scalars['Int'];
  networkMagic: Scalars['Int'];
  securityParameter: Scalars['Int'];
  slotsPerKESPeriod: Scalars['Int'];
  systemStart: Scalars['DateTime'];
  /** same as 'systemStart' */
  timestamp: Scalars['Int'];
  updateQuorum: Scalars['Int'];
};

export type AddNetworkConstantsPayload = {
  __typename?: 'AddNetworkConstantsPayload';
  networkConstants?: Maybe<Array<Maybe<NetworkConstants>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddNetworkConstantsPayloadNetworkConstantsArgs = {
  filter?: InputMaybe<NetworkConstantsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NetworkConstantsOrder>;
};

export type AddNftMetadataFileInput = {
  mediaType: Scalars['String'];
  name: Scalars['String'];
  src: Array<Scalars['String']>;
};

export type AddNftMetadataFilePayload = {
  __typename?: 'AddNftMetadataFilePayload';
  nftMetadataFile?: Maybe<Array<Maybe<NftMetadataFile>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddNftMetadataFilePayloadNftMetadataFileArgs = {
  filter?: InputMaybe<NftMetadataFileFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataFileOrder>;
};

export type AddNftMetadataInput = {
  asset: AssetRef;
  descriptions: Array<Scalars['String']>;
  files: Array<NftMetadataFileRef>;
  images: Array<Scalars['String']>;
  mediaType?: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
  version: Scalars['String'];
};

export type AddNftMetadataPayload = {
  __typename?: 'AddNftMetadataPayload';
  nftMetadata?: Maybe<Array<Maybe<NftMetadata>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddNftMetadataPayloadNftMetadataArgs = {
  filter?: InputMaybe<NftMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataOrder>;
};

export type AddPlutusScriptInput = {
  /** Serialized plutus-core program */
  cborHex: Scalars['String'];
  description: Scalars['String'];
  hash: Scalars['String'];
  /** 'PlutusScriptV1' | 'PlutusScriptV2' */
  type: Scalars['String'];
};

export type AddPlutusScriptPayload = {
  __typename?: 'AddPlutusScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  plutusScript?: Maybe<Array<Maybe<PlutusScript>>>;
};


export type AddPlutusScriptPayloadPlutusScriptArgs = {
  filter?: InputMaybe<PlutusScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PlutusScriptOrder>;
};

export type AddPolicyInput = {
  assets: Array<AssetRef>;
  id: Scalars['String'];
  publicKey: PublicKeyRef;
  script: ScriptRef;
};

export type AddPolicyPayload = {
  __typename?: 'AddPolicyPayload';
  numUids?: Maybe<Scalars['Int']>;
  policy?: Maybe<Array<Maybe<Policy>>>;
};


export type AddPolicyPayloadPolicyArgs = {
  filter?: InputMaybe<PolicyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PolicyOrder>;
};

export type AddPoolContactDataInput = {
  email?: InputMaybe<Scalars['String']>;
  facebook?: InputMaybe<Scalars['String']>;
  feed?: InputMaybe<Scalars['String']>;
  github?: InputMaybe<Scalars['String']>;
  primary: Scalars['String'];
  telegram?: InputMaybe<Scalars['String']>;
  twitter?: InputMaybe<Scalars['String']>;
};

export type AddPoolContactDataPayload = {
  __typename?: 'AddPoolContactDataPayload';
  numUids?: Maybe<Scalars['Int']>;
  poolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
};


export type AddPoolContactDataPayloadPoolContactDataArgs = {
  filter?: InputMaybe<PoolContactDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolContactDataOrder>;
};

export type AddPoolParametersInput = {
  cost: Scalars['Int64'];
  margin: RatioRef;
  metadata?: InputMaybe<StakePoolMetadataRef>;
  metadataJson?: InputMaybe<StakePoolMetadataJsonRef>;
  owners: Array<RewardAccountRef>;
  pledge: Scalars['Int64'];
  poolId: Scalars['String'];
  poolRegistrationCertificate: PoolRegistrationCertificateRef;
  relays: Array<SearchResultRef>;
  rewardAccount: RewardAccountRef;
  sinceEpochNo: Scalars['Int'];
  stakePool: StakePoolRef;
  transactionBlockNo: Scalars['Int'];
  /** hex-encoded 32 byte vrf vkey */
  vrf: Scalars['String'];
};

export type AddPoolParametersPayload = {
  __typename?: 'AddPoolParametersPayload';
  numUids?: Maybe<Scalars['Int']>;
  poolParameters?: Maybe<Array<Maybe<PoolParameters>>>;
};


export type AddPoolParametersPayloadPoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolParametersOrder>;
};

export type AddPoolRegistrationCertificateInput = {
  epoch: EpochRef;
  poolParameters: PoolParametersRef;
  transaction: TransactionRef;
};

export type AddPoolRegistrationCertificatePayload = {
  __typename?: 'AddPoolRegistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  poolRegistrationCertificate?: Maybe<Array<Maybe<PoolRegistrationCertificate>>>;
};


export type AddPoolRegistrationCertificatePayloadPoolRegistrationCertificateArgs = {
  filter?: InputMaybe<PoolRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddPoolRetirementCertificateInput = {
  epoch: EpochRef;
  stakePool: StakePoolRef;
  transaction: TransactionRef;
};

export type AddPoolRetirementCertificatePayload = {
  __typename?: 'AddPoolRetirementCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  poolRetirementCertificate?: Maybe<Array<Maybe<PoolRetirementCertificate>>>;
};


export type AddPoolRetirementCertificatePayloadPoolRetirementCertificateArgs = {
  filter?: InputMaybe<PoolRetirementCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddProtocolParametersAlonzoInput = {
  coinsPerUtxoWord: Scalars['Int'];
  collateralPercentage: Scalars['Int'];
  costModels: Array<CostModelRef>;
  decentralizationParameter: RatioRef;
  /** n_opt */
  desiredNumberOfPools: Scalars['Int'];
  executionPrices: ExecutionPricesRef;
  /** hex-encoded, null if neutral */
  extraEntropy?: InputMaybe<Scalars['String']>;
  maxBlockBodySize: Scalars['Int'];
  maxBlockHeaderSize: Scalars['Int'];
  maxCollateralInputs: Scalars['Int'];
  maxExecutionUnitsPerBlock: ExecutionUnitsRef;
  maxExecutionUnitsPerTransaction: ExecutionUnitsRef;
  maxTxSize: Scalars['Int'];
  maxValueSize: Scalars['Int'];
  /** minfee A */
  minFeeCoefficient: Scalars['Int'];
  /** minfee B */
  minFeeConstant: Scalars['Int'];
  minPoolCost: Scalars['Int'];
  minUtxoValue: Scalars['Int'];
  monetaryExpansion: RatioRef;
  poolDeposit: Scalars['Int'];
  poolInfluence: RatioRef;
  poolRetirementEpochBound: EpochRef;
  protocolVersion: ProtocolVersionRef;
  stakeKeyDeposit: Scalars['Int'];
  treasuryExpansion: RatioRef;
};

export type AddProtocolParametersAlonzoPayload = {
  __typename?: 'AddProtocolParametersAlonzoPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersAlonzo?: Maybe<Array<Maybe<ProtocolParametersAlonzo>>>;
};


export type AddProtocolParametersAlonzoPayloadProtocolParametersAlonzoArgs = {
  filter?: InputMaybe<ProtocolParametersAlonzoFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersAlonzoOrder>;
};

export type AddProtocolParametersShelleyInput = {
  decentralizationParameter: RatioRef;
  /** n_opt */
  desiredNumberOfPools: Scalars['Int'];
  /** hex-encoded, null if neutral */
  extraEntropy?: InputMaybe<Scalars['String']>;
  maxBlockBodySize: Scalars['Int'];
  maxBlockHeaderSize: Scalars['Int'];
  maxTxSize: Scalars['Int'];
  /** minfee A */
  minFeeCoefficient: Scalars['Int'];
  /** minfee B */
  minFeeConstant: Scalars['Int'];
  minUtxoValue: Scalars['Int'];
  monetaryExpansion: RatioRef;
  poolDeposit: Scalars['Int'];
  poolInfluence: RatioRef;
  poolRetirementEpochBound: EpochRef;
  protocolVersion: ProtocolVersionRef;
  stakeKeyDeposit: Scalars['Int'];
  treasuryExpansion: RatioRef;
};

export type AddProtocolParametersShelleyPayload = {
  __typename?: 'AddProtocolParametersShelleyPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersShelley?: Maybe<Array<Maybe<ProtocolParametersShelley>>>;
};


export type AddProtocolParametersShelleyPayloadProtocolParametersShelleyArgs = {
  filter?: InputMaybe<ProtocolParametersShelleyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersShelleyOrder>;
};

export type AddProtocolVersionInput = {
  major: Scalars['Int'];
  minor: Scalars['Int'];
  patch?: InputMaybe<Scalars['Int']>;
  protocolParameters: ProtocolParametersRef;
};

export type AddProtocolVersionPayload = {
  __typename?: 'AddProtocolVersionPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
};


export type AddProtocolVersionPayloadProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolVersionOrder>;
};

export type AddPublicKeyInput = {
  addresses?: InputMaybe<Array<AddressRef>>;
  /** hex-encoded Ed25519 public key hash */
  hash: Scalars['String'];
  /** hex-encoded Ed25519 public key */
  key: Scalars['String'];
  policies?: InputMaybe<Array<PolicyRef>>;
  requiredExtraSignatureInTransactions?: InputMaybe<Array<TransactionRef>>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  signatures: Array<SignatureRef>;
};

export type AddPublicKeyPayload = {
  __typename?: 'AddPublicKeyPayload';
  numUids?: Maybe<Scalars['Int']>;
  publicKey?: Maybe<Array<Maybe<PublicKey>>>;
};


export type AddPublicKeyPayloadPublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PublicKeyOrder>;
};

export type AddRatioInput = {
  denominator: Scalars['Int'];
  numerator: Scalars['Int'];
};

export type AddRatioPayload = {
  __typename?: 'AddRatioPayload';
  numUids?: Maybe<Scalars['Int']>;
  ratio?: Maybe<Array<Maybe<Ratio>>>;
};


export type AddRatioPayloadRatioArgs = {
  filter?: InputMaybe<RatioFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RatioOrder>;
};

export type AddRedeemerInput = {
  executionUnits: ExecutionUnitsRef;
  fee: Scalars['Int64'];
  index: Scalars['Int'];
  purpose: Scalars['String'];
  scriptHash: Scalars['String'];
  witness: WitnessRef;
};

export type AddRedeemerPayload = {
  __typename?: 'AddRedeemerPayload';
  numUids?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<Array<Maybe<Redeemer>>>;
};


export type AddRedeemerPayloadRedeemerArgs = {
  filter?: InputMaybe<RedeemerFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RedeemerOrder>;
};

export type AddRelayByAddressInput = {
  ipv4?: InputMaybe<Scalars['String']>;
  ipv6?: InputMaybe<Scalars['String']>;
  port?: InputMaybe<Scalars['Int']>;
};

export type AddRelayByAddressPayload = {
  __typename?: 'AddRelayByAddressPayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
};


export type AddRelayByAddressPayloadRelayByAddressArgs = {
  filter?: InputMaybe<RelayByAddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByAddressOrder>;
};

export type AddRelayByNameInput = {
  hostname: Scalars['String'];
  port?: InputMaybe<Scalars['Int']>;
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
  filter?: InputMaybe<RelayByNameMultihostFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameMultihostOrder>;
};

export type AddRelayByNamePayload = {
  __typename?: 'AddRelayByNamePayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByName?: Maybe<Array<Maybe<RelayByName>>>;
};


export type AddRelayByNamePayloadRelayByNameArgs = {
  filter?: InputMaybe<RelayByNameFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameOrder>;
};

export type AddRewardAccountInput = {
  activeStake: Array<ActiveStakeRef>;
  address: Scalars['String'];
  addresses: AddressRef;
  delegationCertificates?: InputMaybe<Array<StakeDelegationCertificateRef>>;
  deregistrationCertificates?: InputMaybe<Array<StakeKeyDeregistrationCertificateRef>>;
  mirCertificates?: InputMaybe<Array<MirCertificateRef>>;
  publicKey: PublicKeyRef;
  registrationCertificates: Array<StakeKeyRegistrationCertificateRef>;
  rewards: Array<RewardRef>;
  withdrawals: Array<WithdrawalRef>;
};

export type AddRewardAccountPayload = {
  __typename?: 'AddRewardAccountPayload';
  numUids?: Maybe<Scalars['Int']>;
  rewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
};


export type AddRewardAccountPayloadRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardAccountOrder>;
};

export type AddRewardInput = {
  epoch: EpochRef;
  epochNo: Scalars['Int'];
  quantity: Scalars['Int64'];
  rewardAccount: RewardAccountRef;
  /** member | leader | treasury | reserves */
  source: Scalars['String'];
  spendableAtEpochNo: Scalars['Int'];
  stakePool?: InputMaybe<StakePoolRef>;
};

export type AddRewardPayload = {
  __typename?: 'AddRewardPayload';
  numUids?: Maybe<Scalars['Int']>;
  reward?: Maybe<Array<Maybe<Reward>>>;
};


export type AddRewardPayloadRewardArgs = {
  filter?: InputMaybe<RewardFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardOrder>;
};

export type AddSignatureInput = {
  publicKey: PublicKeyRef;
  /** hex-encoded Ed25519 signature */
  signature: Scalars['String'];
  witness: WitnessRef;
};

export type AddSignaturePayload = {
  __typename?: 'AddSignaturePayload';
  numUids?: Maybe<Scalars['Int']>;
  signature?: Maybe<Array<Maybe<Signature>>>;
};


export type AddSignaturePayloadSignatureArgs = {
  filter?: InputMaybe<SignatureFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SignatureOrder>;
};

export type AddSlotInput = {
  block?: InputMaybe<BlockRef>;
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
  filter?: InputMaybe<SlotFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SlotOrder>;
};

export type AddStakeDelegationCertificateInput = {
  epoch: EpochRef;
  rewardAccount: RewardAccountRef;
  stakePool: StakePoolRef;
  transaction: TransactionRef;
};

export type AddStakeDelegationCertificatePayload = {
  __typename?: 'AddStakeDelegationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeDelegationCertificate?: Maybe<Array<Maybe<StakeDelegationCertificate>>>;
};


export type AddStakeDelegationCertificatePayloadStakeDelegationCertificateArgs = {
  filter?: InputMaybe<StakeDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddStakeKeyDeregistrationCertificateInput = {
  rewardAccount: RewardAccountRef;
  transaction: TransactionRef;
};

export type AddStakeKeyDeregistrationCertificatePayload = {
  __typename?: 'AddStakeKeyDeregistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyDeregistrationCertificate?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificate>>>;
};


export type AddStakeKeyDeregistrationCertificatePayloadStakeKeyDeregistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddStakeKeyRegistrationCertificateInput = {
  rewardAccount: RewardAccountRef;
  transaction: TransactionRef;
};

export type AddStakeKeyRegistrationCertificatePayload = {
  __typename?: 'AddStakeKeyRegistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyRegistrationCertificate?: Maybe<Array<Maybe<StakeKeyRegistrationCertificate>>>;
};


export type AddStakeKeyRegistrationCertificatePayloadStakeKeyRegistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddStakePoolEpochRewardsInput = {
  activeStake: Scalars['Int64'];
  epoch: EpochRef;
  epochLength: Scalars['Int'];
  epochNo: Scalars['Int'];
  /** rewards/activeStake, not annualized */
  memberROI: Scalars['Float'];
  operatorFees: Scalars['Int64'];
  /** Total rewards for the epoch */
  totalRewards: Scalars['Int64'];
};

export type AddStakePoolEpochRewardsPayload = {
  __typename?: 'AddStakePoolEpochRewardsPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolEpochRewards?: Maybe<Array<Maybe<StakePoolEpochRewards>>>;
};


export type AddStakePoolEpochRewardsPayloadStakePoolEpochRewardsArgs = {
  filter?: InputMaybe<StakePoolEpochRewardsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolEpochRewardsOrder>;
};

export type AddStakePoolInput = {
  epochRewards: Array<StakePoolEpochRewardsRef>;
  hexId: Scalars['String'];
  id: Scalars['String'];
  metrics: Array<StakePoolMetricsRef>;
  poolParameters: Array<PoolParametersRef>;
  poolRetirementCertificates: Array<PoolRetirementCertificateRef>;
  /** active | retired | retiring */
  status: StakePoolStatus;
};

export type AddStakePoolMetadataInput = {
  description: Scalars['String'];
  ext?: InputMaybe<ExtendedStakePoolMetadataRef>;
  extDataUrl?: InputMaybe<Scalars['String']>;
  extSigUrl?: InputMaybe<Scalars['String']>;
  extVkey?: InputMaybe<Scalars['String']>;
  homepage: Scalars['String'];
  name: Scalars['String'];
  poolParameters: PoolParametersRef;
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
  filter?: InputMaybe<StakePoolMetadataJsonFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataJsonOrder>;
};

export type AddStakePoolMetadataPayload = {
  __typename?: 'AddStakePoolMetadataPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
};


export type AddStakePoolMetadataPayloadStakePoolMetadataArgs = {
  filter?: InputMaybe<StakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataOrder>;
};

export type AddStakePoolMetricsInput = {
  block: BlockRef;
  blockNo: Scalars['Int'];
  blocksCreated: Scalars['Int'];
  delegators: Scalars['Int'];
  livePledge: Scalars['Int64'];
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
  filter?: InputMaybe<StakePoolMetricsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsOrder>;
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
  filter?: InputMaybe<StakePoolMetricsSizeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsSizeOrder>;
};

export type AddStakePoolMetricsStakeInput = {
  active: Scalars['Int64'];
  live: Scalars['Int64'];
};

export type AddStakePoolMetricsStakePayload = {
  __typename?: 'AddStakePoolMetricsStakePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
};


export type AddStakePoolMetricsStakePayloadStakePoolMetricsStakeArgs = {
  filter?: InputMaybe<StakePoolMetricsStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsStakeOrder>;
};

export type AddStakePoolPayload = {
  __typename?: 'AddStakePoolPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<Array<Maybe<StakePool>>>;
};


export type AddStakePoolPayloadStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolOrder>;
};

export type AddStringMetadatumInput = {
  string: Scalars['String'];
};

export type AddStringMetadatumPayload = {
  __typename?: 'AddStringMetadatumPayload';
  numUids?: Maybe<Scalars['Int']>;
  stringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
};


export type AddStringMetadatumPayloadStringMetadatumArgs = {
  filter?: InputMaybe<StringMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StringMetadatumOrder>;
};

export type AddThePoolsMediaAssetsInput = {
  color_bg?: InputMaybe<Scalars['String']>;
  color_fg?: InputMaybe<Scalars['String']>;
  icon_png_64x64: Scalars['String'];
  logo_png?: InputMaybe<Scalars['String']>;
  logo_svg?: InputMaybe<Scalars['String']>;
};

export type AddThePoolsMediaAssetsPayload = {
  __typename?: 'AddThePoolsMediaAssetsPayload';
  numUids?: Maybe<Scalars['Int']>;
  thePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
};


export type AddThePoolsMediaAssetsPayloadThePoolsMediaAssetsArgs = {
  filter?: InputMaybe<ThePoolsMediaAssetsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ThePoolsMediaAssetsOrder>;
};

export type AddTimeSettingsInput = {
  epochLength: Scalars['Int'];
  fromEpoch: EpochRef;
  fromEpochNo: Scalars['Int'];
  slotLength: Scalars['Int'];
};

export type AddTimeSettingsPayload = {
  __typename?: 'AddTimeSettingsPayload';
  numUids?: Maybe<Scalars['Int']>;
  timeSettings?: Maybe<Array<Maybe<TimeSettings>>>;
};


export type AddTimeSettingsPayloadTimeSettingsArgs = {
  filter?: InputMaybe<TimeSettingsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TimeSettingsOrder>;
};

export type AddTokenInput = {
  asset: AssetRef;
  quantity: Scalars['String'];
  transactionOutput: TransactionOutputRef;
};

export type AddTokenMetadataInput = {
  asset: AssetRef;
  /** how many decimal places should the token support? For ADA, this would be 6 e.g. 1 ADA is 10^6 Lovelace */
  decimals?: InputMaybe<Scalars['Int']>;
  /** additional description that defines the usage of the token */
  desc?: InputMaybe<Scalars['String']>;
  /** MUST be either https, ipfs, or data.  icon MUST be a browser supported image format. */
  icon?: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
  /** https only url that holds the metadata in the onchain format. */
  ref?: InputMaybe<Scalars['String']>;
  sizedIcons: Array<TokenMetadataSizedIconRef>;
  /** when present, field and overrides default ticker which is the asset name */
  ticker?: InputMaybe<Scalars['String']>;
  /** https only url that refers to metadata stored offchain. */
  url?: InputMaybe<Scalars['String']>;
  version?: InputMaybe<Scalars['String']>;
};

export type AddTokenMetadataPayload = {
  __typename?: 'AddTokenMetadataPayload';
  numUids?: Maybe<Scalars['Int']>;
  tokenMetadata?: Maybe<Array<Maybe<TokenMetadata>>>;
};


export type AddTokenMetadataPayloadTokenMetadataArgs = {
  filter?: InputMaybe<TokenMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataOrder>;
};

export type AddTokenMetadataSizedIconInput = {
  /** https only url that refers to metadata stored offchain. */
  icon: Scalars['String'];
  /** Most likely one of 16, 32, 64, 96, 128 */
  size: Scalars['Int'];
};

export type AddTokenMetadataSizedIconPayload = {
  __typename?: 'AddTokenMetadataSizedIconPayload';
  numUids?: Maybe<Scalars['Int']>;
  tokenMetadataSizedIcon?: Maybe<Array<Maybe<TokenMetadataSizedIcon>>>;
};


export type AddTokenMetadataSizedIconPayloadTokenMetadataSizedIconArgs = {
  filter?: InputMaybe<TokenMetadataSizedIconFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataSizedIconOrder>;
};

export type AddTokenPayload = {
  __typename?: 'AddTokenPayload';
  numUids?: Maybe<Scalars['Int']>;
  token?: Maybe<Array<Maybe<Token>>>;
};


export type AddTokenPayloadTokenArgs = {
  filter?: InputMaybe<TokenFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenOrder>;
};

export type AddTransactionInput = {
  auxiliaryData?: InputMaybe<AuxiliaryDataRef>;
  block: BlockRef;
  certificates?: InputMaybe<Array<CertificateRef>>;
  collateral?: InputMaybe<Array<TransactionInputRef>>;
  deposit: Scalars['Int64'];
  fee: Scalars['Int64'];
  hash: Scalars['String'];
  index: Scalars['Int'];
  inputs: Array<TransactionInputRef>;
  invalidBefore?: InputMaybe<SlotRef>;
  invalidHereafter?: InputMaybe<SlotRef>;
  mint?: InputMaybe<Array<TokenRef>>;
  outputs: Array<TransactionOutputRef>;
  requiredExtraSignatures?: InputMaybe<Array<PublicKeyRef>>;
  scriptIntegrityHash?: InputMaybe<Scalars['String']>;
  size: Scalars['Int64'];
  totalOutputCoin: Scalars['Int64'];
  validContract: Scalars['Boolean'];
  withdrawals?: InputMaybe<Array<WithdrawalRef>>;
  witness: WitnessRef;
};

export type AddTransactionInputInput = {
  address: AddressRef;
  index: Scalars['Int'];
  redeemer?: InputMaybe<RedeemerRef>;
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
  filter?: InputMaybe<TransactionInputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionInputOrder>;
};

export type AddTransactionOutputInput = {
  address: AddressRef;
  /** hex-encoded 32 byte hash */
  datumHash?: InputMaybe<Scalars['String']>;
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
  filter?: InputMaybe<TransactionOutputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOutputOrder>;
};

export type AddTransactionPayload = {
  __typename?: 'AddTransactionPayload';
  numUids?: Maybe<Scalars['Int']>;
  transaction?: Maybe<Array<Maybe<Transaction>>>;
};


export type AddTransactionPayloadTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOrder>;
};

export type AddValueInput = {
  assets?: InputMaybe<Array<TokenRef>>;
  coin: Scalars['Int64'];
};

export type AddValuePayload = {
  __typename?: 'AddValuePayload';
  numUids?: Maybe<Scalars['Int']>;
  value?: Maybe<Array<Maybe<Value>>>;
};


export type AddValuePayloadValueArgs = {
  filter?: InputMaybe<ValueFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ValueOrder>;
};

export type AddWithdrawalInput = {
  quantity: Scalars['Int64'];
  redeemer?: InputMaybe<Scalars['String']>;
  rewardAccount: RewardAccountRef;
  transaction: TransactionRef;
};

export type AddWithdrawalPayload = {
  __typename?: 'AddWithdrawalPayload';
  numUids?: Maybe<Scalars['Int']>;
  withdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
};


export type AddWithdrawalPayloadWithdrawalArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WithdrawalOrder>;
};

export type AddWitnessInput = {
  bootstrap?: InputMaybe<Array<BootstrapWitnessRef>>;
  datums?: InputMaybe<Array<DatumRef>>;
  redeemers?: InputMaybe<Array<RedeemerRef>>;
  scripts?: InputMaybe<Array<WitnessScriptRef>>;
  signatures: Array<SignatureRef>;
  transaction: TransactionRef;
};

export type AddWitnessPayload = {
  __typename?: 'AddWitnessPayload';
  numUids?: Maybe<Scalars['Int']>;
  witness?: Maybe<Array<Maybe<Witness>>>;
};


export type AddWitnessPayloadWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type AddWitnessScriptInput = {
  key: Scalars['String'];
  script: ScriptRef;
  witness: WitnessRef;
};

export type AddWitnessScriptPayload = {
  __typename?: 'AddWitnessScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  witnessScript?: Maybe<Array<Maybe<WitnessScript>>>;
};


export type AddWitnessScriptPayloadWitnessScriptArgs = {
  filter?: InputMaybe<WitnessScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WitnessScriptOrder>;
};

export type Address = {
  __typename?: 'Address';
  address: Scalars['String'];
  addressType: AddressType;
  /** Spending history */
  inputs: Array<TransactionInput>;
  inputsAggregate?: Maybe<TransactionInputAggregateResult>;
  paymentPublicKey: PublicKey;
  rewardAccount?: Maybe<RewardAccount>;
  /** Balance */
  utxo: Array<TransactionOutput>;
  utxoAggregate?: Maybe<TransactionOutputAggregateResult>;
};


export type AddressInputsArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionInputOrder>;
};


export type AddressInputsAggregateArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
};


export type AddressPaymentPublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};


export type AddressRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type AddressUtxoArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOutputOrder>;
};


export type AddressUtxoAggregateArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
};

export type AddressAggregateResult = {
  __typename?: 'AddressAggregateResult';
  addressMax?: Maybe<Scalars['String']>;
  addressMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
};

export type AddressFilter = {
  address?: InputMaybe<StringHashFilter>;
  and?: InputMaybe<Array<InputMaybe<AddressFilter>>>;
  has?: InputMaybe<Array<InputMaybe<AddressHasFilter>>>;
  not?: InputMaybe<AddressFilter>;
  or?: InputMaybe<Array<InputMaybe<AddressFilter>>>;
};

export enum AddressHasFilter {
  Address = 'address',
  AddressType = 'addressType',
  Inputs = 'inputs',
  PaymentPublicKey = 'paymentPublicKey',
  RewardAccount = 'rewardAccount',
  Utxo = 'utxo'
}

export type AddressOrder = {
  asc?: InputMaybe<AddressOrderable>;
  desc?: InputMaybe<AddressOrderable>;
  then?: InputMaybe<AddressOrder>;
};

export enum AddressOrderable {
  Address = 'address'
}

export type AddressPatch = {
  addressType?: InputMaybe<AddressType>;
  inputs?: InputMaybe<Array<TransactionInputRef>>;
  paymentPublicKey?: InputMaybe<PublicKeyRef>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  utxo?: InputMaybe<Array<TransactionOutputRef>>;
};

export type AddressRef = {
  address?: InputMaybe<Scalars['String']>;
  addressType?: InputMaybe<AddressType>;
  inputs?: InputMaybe<Array<TransactionInputRef>>;
  paymentPublicKey?: InputMaybe<PublicKeyRef>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  utxo?: InputMaybe<Array<TransactionOutputRef>>;
};

export enum AddressType {
  Byron = 'byron',
  Shelley = 'shelley'
}

export type Asset = {
  __typename?: 'Asset';
  /** concatenated PolicyId and AssetName, hex-encoded */
  assetId: Scalars['String'];
  /** hex-encoded */
  assetName: Scalars['String'];
  assetNameUTF8: Scalars['String'];
  /** Fingerprint of a native asset for human comparison. CIP-0014 */
  fingerprint: Scalars['String'];
  history: Array<AssetMintOrBurn>;
  historyAggregate?: Maybe<AssetMintOrBurnAggregateResult>;
  /** CIP-0025 */
  nftMetadata?: Maybe<NftMetadata>;
  policy: Policy;
  /** CIP-0035 */
  tokenMetadata?: Maybe<TokenMetadata>;
  totalQuantity: Scalars['Int64'];
};


export type AssetHistoryArgs = {
  filter?: InputMaybe<AssetMintOrBurnFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetMintOrBurnOrder>;
};


export type AssetHistoryAggregateArgs = {
  filter?: InputMaybe<AssetMintOrBurnFilter>;
};


export type AssetNftMetadataArgs = {
  filter?: InputMaybe<NftMetadataFilter>;
};


export type AssetPolicyArgs = {
  filter?: InputMaybe<PolicyFilter>;
};


export type AssetTokenMetadataArgs = {
  filter?: InputMaybe<TokenMetadataFilter>;
};

export type AssetAggregateResult = {
  __typename?: 'AssetAggregateResult';
  assetIdMax?: Maybe<Scalars['String']>;
  assetIdMin?: Maybe<Scalars['String']>;
  assetNameMax?: Maybe<Scalars['String']>;
  assetNameMin?: Maybe<Scalars['String']>;
  assetNameUTF8Max?: Maybe<Scalars['String']>;
  assetNameUTF8Min?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  fingerprintMax?: Maybe<Scalars['String']>;
  fingerprintMin?: Maybe<Scalars['String']>;
  totalQuantityAvg?: Maybe<Scalars['Float']>;
  totalQuantityMax?: Maybe<Scalars['Int64']>;
  totalQuantityMin?: Maybe<Scalars['Int64']>;
  totalQuantitySum?: Maybe<Scalars['Int64']>;
};

export type AssetFilter = {
  and?: InputMaybe<Array<InputMaybe<AssetFilter>>>;
  assetId?: InputMaybe<StringExactFilter>;
  has?: InputMaybe<Array<InputMaybe<AssetHasFilter>>>;
  not?: InputMaybe<AssetFilter>;
  or?: InputMaybe<Array<InputMaybe<AssetFilter>>>;
};

export enum AssetHasFilter {
  AssetId = 'assetId',
  AssetName = 'assetName',
  AssetNameUtf8 = 'assetNameUTF8',
  Fingerprint = 'fingerprint',
  History = 'history',
  NftMetadata = 'nftMetadata',
  Policy = 'policy',
  TokenMetadata = 'tokenMetadata',
  TotalQuantity = 'totalQuantity'
}

export type AssetMintOrBurn = {
  __typename?: 'AssetMintOrBurn';
  quantity: Scalars['Int64'];
  transaction: Transaction;
};


export type AssetMintOrBurnTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type AssetMintOrBurnAggregateResult = {
  __typename?: 'AssetMintOrBurnAggregateResult';
  count?: Maybe<Scalars['Int']>;
  quantityAvg?: Maybe<Scalars['Float']>;
  quantityMax?: Maybe<Scalars['Int64']>;
  quantityMin?: Maybe<Scalars['Int64']>;
  quantitySum?: Maybe<Scalars['Int64']>;
};

export type AssetMintOrBurnFilter = {
  and?: InputMaybe<Array<InputMaybe<AssetMintOrBurnFilter>>>;
  has?: InputMaybe<Array<InputMaybe<AssetMintOrBurnHasFilter>>>;
  not?: InputMaybe<AssetMintOrBurnFilter>;
  or?: InputMaybe<Array<InputMaybe<AssetMintOrBurnFilter>>>;
};

export enum AssetMintOrBurnHasFilter {
  Quantity = 'quantity',
  Transaction = 'transaction'
}

export type AssetMintOrBurnOrder = {
  asc?: InputMaybe<AssetMintOrBurnOrderable>;
  desc?: InputMaybe<AssetMintOrBurnOrderable>;
  then?: InputMaybe<AssetMintOrBurnOrder>;
};

export enum AssetMintOrBurnOrderable {
  Quantity = 'quantity'
}

export type AssetMintOrBurnPatch = {
  quantity?: InputMaybe<Scalars['Int64']>;
  transaction?: InputMaybe<TransactionRef>;
};

export type AssetMintOrBurnRef = {
  quantity?: InputMaybe<Scalars['Int64']>;
  transaction?: InputMaybe<TransactionRef>;
};

export type AssetOrder = {
  asc?: InputMaybe<AssetOrderable>;
  desc?: InputMaybe<AssetOrderable>;
  then?: InputMaybe<AssetOrder>;
};

export enum AssetOrderable {
  AssetId = 'assetId',
  AssetName = 'assetName',
  AssetNameUtf8 = 'assetNameUTF8',
  Fingerprint = 'fingerprint',
  TotalQuantity = 'totalQuantity'
}

export type AssetPatch = {
  /** hex-encoded */
  assetName?: InputMaybe<Scalars['String']>;
  assetNameUTF8?: InputMaybe<Scalars['String']>;
  /** Fingerprint of a native asset for human comparison. CIP-0014 */
  fingerprint?: InputMaybe<Scalars['String']>;
  history?: InputMaybe<Array<AssetMintOrBurnRef>>;
  nftMetadata?: InputMaybe<NftMetadataRef>;
  policy?: InputMaybe<PolicyRef>;
  tokenMetadata?: InputMaybe<TokenMetadataRef>;
  totalQuantity?: InputMaybe<Scalars['Int64']>;
};

export type AssetRef = {
  /** concatenated PolicyId and AssetName, hex-encoded */
  assetId?: InputMaybe<Scalars['String']>;
  /** hex-encoded */
  assetName?: InputMaybe<Scalars['String']>;
  assetNameUTF8?: InputMaybe<Scalars['String']>;
  /** Fingerprint of a native asset for human comparison. CIP-0014 */
  fingerprint?: InputMaybe<Scalars['String']>;
  history?: InputMaybe<Array<AssetMintOrBurnRef>>;
  nftMetadata?: InputMaybe<NftMetadataRef>;
  policy?: InputMaybe<PolicyRef>;
  tokenMetadata?: InputMaybe<TokenMetadataRef>;
  totalQuantity?: InputMaybe<Scalars['Int64']>;
};

export type AuthRule = {
  and?: InputMaybe<Array<InputMaybe<AuthRule>>>;
  not?: InputMaybe<AuthRule>;
  or?: InputMaybe<Array<InputMaybe<AuthRule>>>;
  rule?: InputMaybe<Scalars['String']>;
};

export type AuxiliaryData = {
  __typename?: 'AuxiliaryData';
  body: AuxiliaryDataBody;
  hash: Scalars['String'];
  transaction: Transaction;
};


export type AuxiliaryDataBodyArgs = {
  filter?: InputMaybe<AuxiliaryDataBodyFilter>;
};


export type AuxiliaryDataTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
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
  blob?: Maybe<Array<KeyValueMetadatum>>;
  blobAggregate?: Maybe<KeyValueMetadatumAggregateResult>;
  scripts?: Maybe<Array<AuxiliaryScript>>;
  scriptsAggregate?: Maybe<AuxiliaryScriptAggregateResult>;
};


export type AuxiliaryDataBodyAuxiliaryDataArgs = {
  filter?: InputMaybe<AuxiliaryDataFilter>;
};


export type AuxiliaryDataBodyBlobArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<KeyValueMetadatumOrder>;
};


export type AuxiliaryDataBodyBlobAggregateArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
};


export type AuxiliaryDataBodyScriptsArgs = {
  filter?: InputMaybe<AuxiliaryScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type AuxiliaryDataBodyScriptsAggregateArgs = {
  filter?: InputMaybe<AuxiliaryScriptFilter>;
};

export type AuxiliaryDataBodyAggregateResult = {
  __typename?: 'AuxiliaryDataBodyAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type AuxiliaryDataBodyFilter = {
  and?: InputMaybe<Array<InputMaybe<AuxiliaryDataBodyFilter>>>;
  has?: InputMaybe<Array<InputMaybe<AuxiliaryDataBodyHasFilter>>>;
  not?: InputMaybe<AuxiliaryDataBodyFilter>;
  or?: InputMaybe<Array<InputMaybe<AuxiliaryDataBodyFilter>>>;
};

export enum AuxiliaryDataBodyHasFilter {
  AuxiliaryData = 'auxiliaryData',
  Blob = 'blob',
  Scripts = 'scripts'
}

export type AuxiliaryDataBodyPatch = {
  auxiliaryData?: InputMaybe<AuxiliaryDataRef>;
  blob?: InputMaybe<Array<KeyValueMetadatumRef>>;
  scripts?: InputMaybe<Array<AuxiliaryScriptRef>>;
};

export type AuxiliaryDataBodyRef = {
  auxiliaryData?: InputMaybe<AuxiliaryDataRef>;
  blob?: InputMaybe<Array<KeyValueMetadatumRef>>;
  scripts?: InputMaybe<Array<AuxiliaryScriptRef>>;
};

export type AuxiliaryDataFilter = {
  and?: InputMaybe<Array<InputMaybe<AuxiliaryDataFilter>>>;
  has?: InputMaybe<Array<InputMaybe<AuxiliaryDataHasFilter>>>;
  not?: InputMaybe<AuxiliaryDataFilter>;
  or?: InputMaybe<Array<InputMaybe<AuxiliaryDataFilter>>>;
};

export enum AuxiliaryDataHasFilter {
  Body = 'body',
  Hash = 'hash',
  Transaction = 'transaction'
}

export type AuxiliaryDataOrder = {
  asc?: InputMaybe<AuxiliaryDataOrderable>;
  desc?: InputMaybe<AuxiliaryDataOrderable>;
  then?: InputMaybe<AuxiliaryDataOrder>;
};

export enum AuxiliaryDataOrderable {
  Hash = 'hash'
}

export type AuxiliaryDataPatch = {
  body?: InputMaybe<AuxiliaryDataBodyRef>;
  hash?: InputMaybe<Scalars['String']>;
  transaction?: InputMaybe<TransactionRef>;
};

export type AuxiliaryDataRef = {
  body?: InputMaybe<AuxiliaryDataBodyRef>;
  hash?: InputMaybe<Scalars['String']>;
  transaction?: InputMaybe<TransactionRef>;
};

export type AuxiliaryScript = {
  __typename?: 'AuxiliaryScript';
  auxiliaryDataBody: AuxiliaryDataBody;
  script: Script;
};


export type AuxiliaryScriptAuxiliaryDataBodyArgs = {
  filter?: InputMaybe<AuxiliaryDataBodyFilter>;
};


export type AuxiliaryScriptScriptArgs = {
  filter?: InputMaybe<ScriptFilter>;
};

export type AuxiliaryScriptAggregateResult = {
  __typename?: 'AuxiliaryScriptAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type AuxiliaryScriptFilter = {
  and?: InputMaybe<Array<InputMaybe<AuxiliaryScriptFilter>>>;
  has?: InputMaybe<Array<InputMaybe<AuxiliaryScriptHasFilter>>>;
  not?: InputMaybe<AuxiliaryScriptFilter>;
  or?: InputMaybe<Array<InputMaybe<AuxiliaryScriptFilter>>>;
};

export enum AuxiliaryScriptHasFilter {
  AuxiliaryDataBody = 'auxiliaryDataBody',
  Script = 'script'
}

export type AuxiliaryScriptPatch = {
  auxiliaryDataBody?: InputMaybe<AuxiliaryDataBodyRef>;
  script?: InputMaybe<ScriptRef>;
};

export type AuxiliaryScriptRef = {
  auxiliaryDataBody?: InputMaybe<AuxiliaryDataBodyRef>;
  script?: InputMaybe<ScriptRef>;
};

export type Block = {
  __typename?: 'Block';
  blockNo: Scalars['Int'];
  confirmations: Scalars['Int'];
  epoch: Epoch;
  hash: Scalars['String'];
  issuer: StakePool;
  nextBlock: Block;
  nextBlockProtocolVersion: ProtocolVersion;
  opCert: Scalars['String'];
  previousBlock: Block;
  size: Scalars['Int64'];
  slot: Slot;
  totalFees: Scalars['Int64'];
  totalLiveStake: Scalars['Int64'];
  totalOutput: Scalars['Int64'];
  transactions: Array<Transaction>;
  transactionsAggregate?: Maybe<TransactionAggregateResult>;
};


export type BlockEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type BlockIssuerArgs = {
  filter?: InputMaybe<StakePoolFilter>;
};


export type BlockNextBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
};


export type BlockNextBlockProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
};


export type BlockPreviousBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
};


export type BlockSlotArgs = {
  filter?: InputMaybe<SlotFilter>;
};


export type BlockTransactionsArgs = {
  filter?: InputMaybe<TransactionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOrder>;
};


export type BlockTransactionsAggregateArgs = {
  filter?: InputMaybe<TransactionFilter>;
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
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
  opCertMax?: Maybe<Scalars['String']>;
  opCertMin?: Maybe<Scalars['String']>;
  sizeAvg?: Maybe<Scalars['Float']>;
  sizeMax?: Maybe<Scalars['Int64']>;
  sizeMin?: Maybe<Scalars['Int64']>;
  sizeSum?: Maybe<Scalars['Int64']>;
  totalFeesAvg?: Maybe<Scalars['Float']>;
  totalFeesMax?: Maybe<Scalars['Int64']>;
  totalFeesMin?: Maybe<Scalars['Int64']>;
  totalFeesSum?: Maybe<Scalars['Int64']>;
  totalLiveStakeAvg?: Maybe<Scalars['Float']>;
  totalLiveStakeMax?: Maybe<Scalars['Int64']>;
  totalLiveStakeMin?: Maybe<Scalars['Int64']>;
  totalLiveStakeSum?: Maybe<Scalars['Int64']>;
  totalOutputAvg?: Maybe<Scalars['Float']>;
  totalOutputMax?: Maybe<Scalars['Int64']>;
  totalOutputMin?: Maybe<Scalars['Int64']>;
  totalOutputSum?: Maybe<Scalars['Int64']>;
};

export type BlockFilter = {
  and?: InputMaybe<Array<InputMaybe<BlockFilter>>>;
  has?: InputMaybe<Array<InputMaybe<BlockHasFilter>>>;
  hash?: InputMaybe<StringHashFilter>;
  not?: InputMaybe<BlockFilter>;
  or?: InputMaybe<Array<InputMaybe<BlockFilter>>>;
};

export enum BlockHasFilter {
  BlockNo = 'blockNo',
  Confirmations = 'confirmations',
  Epoch = 'epoch',
  Hash = 'hash',
  Issuer = 'issuer',
  NextBlock = 'nextBlock',
  NextBlockProtocolVersion = 'nextBlockProtocolVersion',
  OpCert = 'opCert',
  PreviousBlock = 'previousBlock',
  Size = 'size',
  Slot = 'slot',
  TotalFees = 'totalFees',
  TotalLiveStake = 'totalLiveStake',
  TotalOutput = 'totalOutput',
  Transactions = 'transactions'
}

export type BlockOrder = {
  asc?: InputMaybe<BlockOrderable>;
  desc?: InputMaybe<BlockOrderable>;
  then?: InputMaybe<BlockOrder>;
};

export enum BlockOrderable {
  BlockNo = 'blockNo',
  Confirmations = 'confirmations',
  Hash = 'hash',
  OpCert = 'opCert',
  Size = 'size',
  TotalFees = 'totalFees',
  TotalLiveStake = 'totalLiveStake',
  TotalOutput = 'totalOutput'
}

export type BlockPatch = {
  blockNo?: InputMaybe<Scalars['Int']>;
  confirmations?: InputMaybe<Scalars['Int']>;
  epoch?: InputMaybe<EpochRef>;
  issuer?: InputMaybe<StakePoolRef>;
  nextBlock?: InputMaybe<BlockRef>;
  nextBlockProtocolVersion?: InputMaybe<ProtocolVersionRef>;
  opCert?: InputMaybe<Scalars['String']>;
  previousBlock?: InputMaybe<BlockRef>;
  size?: InputMaybe<Scalars['Int64']>;
  slot?: InputMaybe<SlotRef>;
  totalFees?: InputMaybe<Scalars['Int64']>;
  totalLiveStake?: InputMaybe<Scalars['Int64']>;
  totalOutput?: InputMaybe<Scalars['Int64']>;
  transactions?: InputMaybe<Array<TransactionRef>>;
};

export type BlockRef = {
  blockNo?: InputMaybe<Scalars['Int']>;
  confirmations?: InputMaybe<Scalars['Int']>;
  epoch?: InputMaybe<EpochRef>;
  hash?: InputMaybe<Scalars['String']>;
  issuer?: InputMaybe<StakePoolRef>;
  nextBlock?: InputMaybe<BlockRef>;
  nextBlockProtocolVersion?: InputMaybe<ProtocolVersionRef>;
  opCert?: InputMaybe<Scalars['String']>;
  previousBlock?: InputMaybe<BlockRef>;
  size?: InputMaybe<Scalars['Int64']>;
  slot?: InputMaybe<SlotRef>;
  totalFees?: InputMaybe<Scalars['Int64']>;
  totalLiveStake?: InputMaybe<Scalars['Int64']>;
  totalOutput?: InputMaybe<Scalars['Int64']>;
  transactions?: InputMaybe<Array<TransactionRef>>;
};

export type BootstrapWitness = {
  __typename?: 'BootstrapWitness';
  /** Extra attributes carried by Byron addresses (network magic and/or HD payload) */
  addressAttributes?: Maybe<Scalars['String']>;
  /** An Ed25519-BIP32 chain-code for key deriviation */
  chainCode?: Maybe<Scalars['String']>;
  key?: Maybe<PublicKey>;
  /** hex-encoded Ed25519 signature */
  signature: Scalars['String'];
};


export type BootstrapWitnessKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};

export type BootstrapWitnessAggregateResult = {
  __typename?: 'BootstrapWitnessAggregateResult';
  addressAttributesMax?: Maybe<Scalars['String']>;
  addressAttributesMin?: Maybe<Scalars['String']>;
  chainCodeMax?: Maybe<Scalars['String']>;
  chainCodeMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  signatureMax?: Maybe<Scalars['String']>;
  signatureMin?: Maybe<Scalars['String']>;
};

export type BootstrapWitnessFilter = {
  and?: InputMaybe<Array<InputMaybe<BootstrapWitnessFilter>>>;
  has?: InputMaybe<Array<InputMaybe<BootstrapWitnessHasFilter>>>;
  not?: InputMaybe<BootstrapWitnessFilter>;
  or?: InputMaybe<Array<InputMaybe<BootstrapWitnessFilter>>>;
};

export enum BootstrapWitnessHasFilter {
  AddressAttributes = 'addressAttributes',
  ChainCode = 'chainCode',
  Key = 'key',
  Signature = 'signature'
}

export type BootstrapWitnessOrder = {
  asc?: InputMaybe<BootstrapWitnessOrderable>;
  desc?: InputMaybe<BootstrapWitnessOrderable>;
  then?: InputMaybe<BootstrapWitnessOrder>;
};

export enum BootstrapWitnessOrderable {
  AddressAttributes = 'addressAttributes',
  ChainCode = 'chainCode',
  Signature = 'signature'
}

export type BootstrapWitnessPatch = {
  /** Extra attributes carried by Byron addresses (network magic and/or HD payload) */
  addressAttributes?: InputMaybe<Scalars['String']>;
  /** An Ed25519-BIP32 chain-code for key deriviation */
  chainCode?: InputMaybe<Scalars['String']>;
  key?: InputMaybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: InputMaybe<Scalars['String']>;
};

export type BootstrapWitnessRef = {
  /** Extra attributes carried by Byron addresses (network magic and/or HD payload) */
  addressAttributes?: InputMaybe<Scalars['String']>;
  /** An Ed25519-BIP32 chain-code for key deriviation */
  chainCode?: InputMaybe<Scalars['String']>;
  key?: InputMaybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: InputMaybe<Scalars['String']>;
};

export type BytesMetadatum = {
  __typename?: 'BytesMetadatum';
  bytes: Scalars['String'];
};

export type BytesMetadatumAggregateResult = {
  __typename?: 'BytesMetadatumAggregateResult';
  bytesMax?: Maybe<Scalars['String']>;
  bytesMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
};

export type BytesMetadatumFilter = {
  and?: InputMaybe<Array<InputMaybe<BytesMetadatumFilter>>>;
  bytes?: InputMaybe<StringHashFilter>;
  has?: InputMaybe<Array<InputMaybe<BytesMetadatumHasFilter>>>;
  not?: InputMaybe<BytesMetadatumFilter>;
  or?: InputMaybe<Array<InputMaybe<BytesMetadatumFilter>>>;
};

export enum BytesMetadatumHasFilter {
  Bytes = 'bytes'
}

export type BytesMetadatumOrder = {
  asc?: InputMaybe<BytesMetadatumOrderable>;
  desc?: InputMaybe<BytesMetadatumOrderable>;
  then?: InputMaybe<BytesMetadatumOrder>;
};

export enum BytesMetadatumOrderable {
  Bytes = 'bytes'
}

export type BytesMetadatumPatch = {
  bytes?: InputMaybe<Scalars['String']>;
};

export type BytesMetadatumRef = {
  bytes?: InputMaybe<Scalars['String']>;
};

export type Certificate = GenesisKeyDelegationCertificate | MirCertificate | PoolRegistrationCertificate | PoolRetirementCertificate | StakeDelegationCertificate | StakeKeyDeregistrationCertificate | StakeKeyRegistrationCertificate;

export type CertificateFilter = {
  genesisKeyDelegationCertificateFilter?: InputMaybe<GenesisKeyDelegationCertificateFilter>;
  memberTypes?: InputMaybe<Array<CertificateType>>;
  mirCertificateFilter?: InputMaybe<MirCertificateFilter>;
  poolRegistrationCertificateFilter?: InputMaybe<PoolRegistrationCertificateFilter>;
  poolRetirementCertificateFilter?: InputMaybe<PoolRetirementCertificateFilter>;
  stakeDelegationCertificateFilter?: InputMaybe<StakeDelegationCertificateFilter>;
  stakeKeyDeregistrationCertificateFilter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
  stakeKeyRegistrationCertificateFilter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
};

export type CertificateRef = {
  genesisKeyDelegationCertificateRef?: InputMaybe<GenesisKeyDelegationCertificateRef>;
  mirCertificateRef?: InputMaybe<MirCertificateRef>;
  poolRegistrationCertificateRef?: InputMaybe<PoolRegistrationCertificateRef>;
  poolRetirementCertificateRef?: InputMaybe<PoolRetirementCertificateRef>;
  stakeDelegationCertificateRef?: InputMaybe<StakeDelegationCertificateRef>;
  stakeKeyDeregistrationCertificateRef?: InputMaybe<StakeKeyDeregistrationCertificateRef>;
  stakeKeyRegistrationCertificateRef?: InputMaybe<StakeKeyRegistrationCertificateRef>;
};

export enum CertificateType {
  GenesisKeyDelegationCertificate = 'GenesisKeyDelegationCertificate',
  MirCertificate = 'MirCertificate',
  PoolRegistrationCertificate = 'PoolRegistrationCertificate',
  PoolRetirementCertificate = 'PoolRetirementCertificate',
  StakeDelegationCertificate = 'StakeDelegationCertificate',
  StakeKeyDeregistrationCertificate = 'StakeKeyDeregistrationCertificate',
  StakeKeyRegistrationCertificate = 'StakeKeyRegistrationCertificate'
}

export type CoinSupply = {
  __typename?: 'CoinSupply';
  circulating: Scalars['Int64'];
  max: Scalars['Int64'];
  total: Scalars['Int64'];
};

export type CoinSupplyAggregateResult = {
  __typename?: 'CoinSupplyAggregateResult';
  circulatingAvg?: Maybe<Scalars['Float']>;
  circulatingMax?: Maybe<Scalars['Int64']>;
  circulatingMin?: Maybe<Scalars['Int64']>;
  circulatingSum?: Maybe<Scalars['Int64']>;
  count?: Maybe<Scalars['Int']>;
  maxAvg?: Maybe<Scalars['Float']>;
  maxMax?: Maybe<Scalars['Int64']>;
  maxMin?: Maybe<Scalars['Int64']>;
  maxSum?: Maybe<Scalars['Int64']>;
  totalAvg?: Maybe<Scalars['Float']>;
  totalMax?: Maybe<Scalars['Int64']>;
  totalMin?: Maybe<Scalars['Int64']>;
  totalSum?: Maybe<Scalars['Int64']>;
};

export type CoinSupplyFilter = {
  and?: InputMaybe<Array<InputMaybe<CoinSupplyFilter>>>;
  has?: InputMaybe<Array<InputMaybe<CoinSupplyHasFilter>>>;
  not?: InputMaybe<CoinSupplyFilter>;
  or?: InputMaybe<Array<InputMaybe<CoinSupplyFilter>>>;
};

export enum CoinSupplyHasFilter {
  Circulating = 'circulating',
  Max = 'max',
  Total = 'total'
}

export type CoinSupplyOrder = {
  asc?: InputMaybe<CoinSupplyOrderable>;
  desc?: InputMaybe<CoinSupplyOrderable>;
  then?: InputMaybe<CoinSupplyOrder>;
};

export enum CoinSupplyOrderable {
  Circulating = 'circulating',
  Max = 'max',
  Total = 'total'
}

export type CoinSupplyPatch = {
  circulating?: InputMaybe<Scalars['Int64']>;
  max?: InputMaybe<Scalars['Int64']>;
  total?: InputMaybe<Scalars['Int64']>;
};

export type CoinSupplyRef = {
  circulating?: InputMaybe<Scalars['Int64']>;
  max?: InputMaybe<Scalars['Int64']>;
  total?: InputMaybe<Scalars['Int64']>;
};

export type ContainsFilter = {
  point?: InputMaybe<PointRef>;
  polygon?: InputMaybe<PolygonRef>;
};

export type CostModel = {
  __typename?: 'CostModel';
  coefficients: Array<CostModelCoefficient>;
  coefficientsAggregate?: Maybe<CostModelCoefficientAggregateResult>;
  language: Scalars['String'];
};


export type CostModelCoefficientsArgs = {
  filter?: InputMaybe<CostModelCoefficientFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelCoefficientOrder>;
};


export type CostModelCoefficientsAggregateArgs = {
  filter?: InputMaybe<CostModelCoefficientFilter>;
};

export type CostModelAggregateResult = {
  __typename?: 'CostModelAggregateResult';
  count?: Maybe<Scalars['Int']>;
  languageMax?: Maybe<Scalars['String']>;
  languageMin?: Maybe<Scalars['String']>;
};

export type CostModelCoefficient = {
  __typename?: 'CostModelCoefficient';
  coefficient: Scalars['Int'];
  key: Scalars['String'];
};

export type CostModelCoefficientAggregateResult = {
  __typename?: 'CostModelCoefficientAggregateResult';
  coefficientAvg?: Maybe<Scalars['Float']>;
  coefficientMax?: Maybe<Scalars['Int']>;
  coefficientMin?: Maybe<Scalars['Int']>;
  coefficientSum?: Maybe<Scalars['Int']>;
  count?: Maybe<Scalars['Int']>;
  keyMax?: Maybe<Scalars['String']>;
  keyMin?: Maybe<Scalars['String']>;
};

export type CostModelCoefficientFilter = {
  and?: InputMaybe<Array<InputMaybe<CostModelCoefficientFilter>>>;
  has?: InputMaybe<Array<InputMaybe<CostModelCoefficientHasFilter>>>;
  not?: InputMaybe<CostModelCoefficientFilter>;
  or?: InputMaybe<Array<InputMaybe<CostModelCoefficientFilter>>>;
};

export enum CostModelCoefficientHasFilter {
  Coefficient = 'coefficient',
  Key = 'key'
}

export type CostModelCoefficientOrder = {
  asc?: InputMaybe<CostModelCoefficientOrderable>;
  desc?: InputMaybe<CostModelCoefficientOrderable>;
  then?: InputMaybe<CostModelCoefficientOrder>;
};

export enum CostModelCoefficientOrderable {
  Coefficient = 'coefficient',
  Key = 'key'
}

export type CostModelCoefficientPatch = {
  coefficient?: InputMaybe<Scalars['Int']>;
  key?: InputMaybe<Scalars['String']>;
};

export type CostModelCoefficientRef = {
  coefficient?: InputMaybe<Scalars['Int']>;
  key?: InputMaybe<Scalars['String']>;
};

export type CostModelFilter = {
  and?: InputMaybe<Array<InputMaybe<CostModelFilter>>>;
  has?: InputMaybe<Array<InputMaybe<CostModelHasFilter>>>;
  not?: InputMaybe<CostModelFilter>;
  or?: InputMaybe<Array<InputMaybe<CostModelFilter>>>;
};

export enum CostModelHasFilter {
  Coefficients = 'coefficients',
  Language = 'language'
}

export type CostModelOrder = {
  asc?: InputMaybe<CostModelOrderable>;
  desc?: InputMaybe<CostModelOrderable>;
  then?: InputMaybe<CostModelOrder>;
};

export enum CostModelOrderable {
  Language = 'language'
}

export type CostModelPatch = {
  coefficients?: InputMaybe<Array<CostModelCoefficientRef>>;
  language?: InputMaybe<Scalars['String']>;
};

export type CostModelRef = {
  coefficients?: InputMaybe<Array<CostModelCoefficientRef>>;
  language?: InputMaybe<Scalars['String']>;
};

export type CustomHttp = {
  body?: InputMaybe<Scalars['String']>;
  forwardHeaders?: InputMaybe<Array<Scalars['String']>>;
  graphql?: InputMaybe<Scalars['String']>;
  introspectionHeaders?: InputMaybe<Array<Scalars['String']>>;
  method: HttpMethod;
  mode?: InputMaybe<Mode>;
  secretHeaders?: InputMaybe<Array<Scalars['String']>>;
  skipIntrospection?: InputMaybe<Scalars['Boolean']>;
  url: Scalars['String'];
};

export type DateTimeFilter = {
  between?: InputMaybe<DateTimeRange>;
  eq?: InputMaybe<Scalars['DateTime']>;
  ge?: InputMaybe<Scalars['DateTime']>;
  gt?: InputMaybe<Scalars['DateTime']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['DateTime']>>>;
  le?: InputMaybe<Scalars['DateTime']>;
  lt?: InputMaybe<Scalars['DateTime']>;
};

export type DateTimeRange = {
  max: Scalars['DateTime'];
  min: Scalars['DateTime'];
};

export type Datum = {
  __typename?: 'Datum';
  datum: Scalars['String'];
  hash: Scalars['String'];
};

export type DatumAggregateResult = {
  __typename?: 'DatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  datumMax?: Maybe<Scalars['String']>;
  datumMin?: Maybe<Scalars['String']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
};

export type DatumFilter = {
  and?: InputMaybe<Array<InputMaybe<DatumFilter>>>;
  has?: InputMaybe<Array<InputMaybe<DatumHasFilter>>>;
  hash?: InputMaybe<StringHashFilter>;
  not?: InputMaybe<DatumFilter>;
  or?: InputMaybe<Array<InputMaybe<DatumFilter>>>;
};

export enum DatumHasFilter {
  Datum = 'datum',
  Hash = 'hash'
}

export type DatumOrder = {
  asc?: InputMaybe<DatumOrderable>;
  desc?: InputMaybe<DatumOrderable>;
  then?: InputMaybe<DatumOrder>;
};

export enum DatumOrderable {
  Datum = 'datum',
  Hash = 'hash'
}

export type DatumPatch = {
  datum?: InputMaybe<Scalars['String']>;
};

export type DatumRef = {
  datum?: InputMaybe<Scalars['String']>;
  hash?: InputMaybe<Scalars['String']>;
};

export type DeleteActiveStakePayload = {
  __typename?: 'DeleteActiveStakePayload';
  activeStake?: Maybe<Array<Maybe<ActiveStake>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteActiveStakePayloadActiveStakeArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ActiveStakeOrder>;
};

export type DeleteAdaPayload = {
  __typename?: 'DeleteAdaPayload';
  ada?: Maybe<Array<Maybe<Ada>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAdaPayloadAdaArgs = {
  filter?: InputMaybe<AdaFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaOrder>;
};

export type DeleteAdaPotsPayload = {
  __typename?: 'DeleteAdaPotsPayload';
  adaPots?: Maybe<Array<Maybe<AdaPots>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAdaPotsPayloadAdaPotsArgs = {
  filter?: InputMaybe<AdaPotsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaPotsOrder>;
};

export type DeleteAddressPayload = {
  __typename?: 'DeleteAddressPayload';
  address?: Maybe<Array<Maybe<Address>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAddressPayloadAddressArgs = {
  filter?: InputMaybe<AddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AddressOrder>;
};

export type DeleteAssetMintOrBurnPayload = {
  __typename?: 'DeleteAssetMintOrBurnPayload';
  assetMintOrBurn?: Maybe<Array<Maybe<AssetMintOrBurn>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAssetMintOrBurnPayloadAssetMintOrBurnArgs = {
  filter?: InputMaybe<AssetMintOrBurnFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetMintOrBurnOrder>;
};

export type DeleteAssetPayload = {
  __typename?: 'DeleteAssetPayload';
  asset?: Maybe<Array<Maybe<Asset>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAssetPayloadAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetOrder>;
};

export type DeleteAuxiliaryDataBodyPayload = {
  __typename?: 'DeleteAuxiliaryDataBodyPayload';
  auxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAuxiliaryDataBodyPayloadAuxiliaryDataBodyArgs = {
  filter?: InputMaybe<AuxiliaryDataBodyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteAuxiliaryDataPayload = {
  __typename?: 'DeleteAuxiliaryDataPayload';
  auxiliaryData?: Maybe<Array<Maybe<AuxiliaryData>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAuxiliaryDataPayloadAuxiliaryDataArgs = {
  filter?: InputMaybe<AuxiliaryDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AuxiliaryDataOrder>;
};

export type DeleteAuxiliaryScriptPayload = {
  __typename?: 'DeleteAuxiliaryScriptPayload';
  auxiliaryScript?: Maybe<Array<Maybe<AuxiliaryScript>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAuxiliaryScriptPayloadAuxiliaryScriptArgs = {
  filter?: InputMaybe<AuxiliaryScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteBlockPayload = {
  __typename?: 'DeleteBlockPayload';
  block?: Maybe<Array<Maybe<Block>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteBlockPayloadBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BlockOrder>;
};

export type DeleteBootstrapWitnessPayload = {
  __typename?: 'DeleteBootstrapWitnessPayload';
  bootstrapWitness?: Maybe<Array<Maybe<BootstrapWitness>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteBootstrapWitnessPayloadBootstrapWitnessArgs = {
  filter?: InputMaybe<BootstrapWitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BootstrapWitnessOrder>;
};

export type DeleteBytesMetadatumPayload = {
  __typename?: 'DeleteBytesMetadatumPayload';
  bytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteBytesMetadatumPayloadBytesMetadatumArgs = {
  filter?: InputMaybe<BytesMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BytesMetadatumOrder>;
};

export type DeleteCoinSupplyPayload = {
  __typename?: 'DeleteCoinSupplyPayload';
  coinSupply?: Maybe<Array<Maybe<CoinSupply>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteCoinSupplyPayloadCoinSupplyArgs = {
  filter?: InputMaybe<CoinSupplyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CoinSupplyOrder>;
};

export type DeleteCostModelCoefficientPayload = {
  __typename?: 'DeleteCostModelCoefficientPayload';
  costModelCoefficient?: Maybe<Array<Maybe<CostModelCoefficient>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteCostModelCoefficientPayloadCostModelCoefficientArgs = {
  filter?: InputMaybe<CostModelCoefficientFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelCoefficientOrder>;
};

export type DeleteCostModelPayload = {
  __typename?: 'DeleteCostModelPayload';
  costModel?: Maybe<Array<Maybe<CostModel>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteCostModelPayloadCostModelArgs = {
  filter?: InputMaybe<CostModelFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelOrder>;
};

export type DeleteDatumPayload = {
  __typename?: 'DeleteDatumPayload';
  datum?: Maybe<Array<Maybe<Datum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteDatumPayloadDatumArgs = {
  filter?: InputMaybe<DatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<DatumOrder>;
};

export type DeleteEpochPayload = {
  __typename?: 'DeleteEpochPayload';
  epoch?: Maybe<Array<Maybe<Epoch>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteEpochPayloadEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<EpochOrder>;
};

export type DeleteExecutionPricesPayload = {
  __typename?: 'DeleteExecutionPricesPayload';
  executionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExecutionPricesPayloadExecutionPricesArgs = {
  filter?: InputMaybe<ExecutionPricesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteExecutionUnitsPayload = {
  __typename?: 'DeleteExecutionUnitsPayload';
  executionUnits?: Maybe<Array<Maybe<ExecutionUnits>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExecutionUnitsPayloadExecutionUnitsArgs = {
  filter?: InputMaybe<ExecutionUnitsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExecutionUnitsOrder>;
};

export type DeleteExtendedStakePoolMetadataFieldsPayload = {
  __typename?: 'DeleteExtendedStakePoolMetadataFieldsPayload';
  extendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExtendedStakePoolMetadataFieldsPayloadExtendedStakePoolMetadataFieldsArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataFieldsOrder>;
};

export type DeleteExtendedStakePoolMetadataPayload = {
  __typename?: 'DeleteExtendedStakePoolMetadataPayload';
  extendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteExtendedStakePoolMetadataPayloadExtendedStakePoolMetadataArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataOrder>;
};

export type DeleteGenesisKeyDelegationCertificatePayload = {
  __typename?: 'DeleteGenesisKeyDelegationCertificatePayload';
  genesisKeyDelegationCertificate?: Maybe<Array<Maybe<GenesisKeyDelegationCertificate>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteGenesisKeyDelegationCertificatePayloadGenesisKeyDelegationCertificateArgs = {
  filter?: InputMaybe<GenesisKeyDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<GenesisKeyDelegationCertificateOrder>;
};

export type DeleteItnVerificationPayload = {
  __typename?: 'DeleteITNVerificationPayload';
  iTNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteItnVerificationPayloadITnVerificationArgs = {
  filter?: InputMaybe<ItnVerificationFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ItnVerificationOrder>;
};

export type DeleteIntegerMetadatumPayload = {
  __typename?: 'DeleteIntegerMetadatumPayload';
  integerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteIntegerMetadatumPayloadIntegerMetadatumArgs = {
  filter?: InputMaybe<IntegerMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<IntegerMetadatumOrder>;
};

export type DeleteKeyValueMetadatumPayload = {
  __typename?: 'DeleteKeyValueMetadatumPayload';
  keyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteKeyValueMetadatumPayloadKeyValueMetadatumArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<KeyValueMetadatumOrder>;
};

export type DeleteMetadatumArrayPayload = {
  __typename?: 'DeleteMetadatumArrayPayload';
  metadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteMetadatumArrayPayloadMetadatumArrayArgs = {
  filter?: InputMaybe<MetadatumArrayFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteMetadatumMapPayload = {
  __typename?: 'DeleteMetadatumMapPayload';
  metadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteMetadatumMapPayloadMetadatumMapArgs = {
  filter?: InputMaybe<MetadatumMapFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteMirCertificatePayload = {
  __typename?: 'DeleteMirCertificatePayload';
  mirCertificate?: Maybe<Array<Maybe<MirCertificate>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteMirCertificatePayloadMirCertificateArgs = {
  filter?: InputMaybe<MirCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<MirCertificateOrder>;
};

export type DeleteNOfPayload = {
  __typename?: 'DeleteNOfPayload';
  msg?: Maybe<Scalars['String']>;
  nOf?: Maybe<Array<Maybe<NOf>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNOfPayloadNOfArgs = {
  filter?: InputMaybe<NOfFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NOfOrder>;
};

export type DeleteNativeScriptPayload = {
  __typename?: 'DeleteNativeScriptPayload';
  msg?: Maybe<Scalars['String']>;
  nativeScript?: Maybe<Array<Maybe<NativeScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNativeScriptPayloadNativeScriptArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteNetworkConstantsPayload = {
  __typename?: 'DeleteNetworkConstantsPayload';
  msg?: Maybe<Scalars['String']>;
  networkConstants?: Maybe<Array<Maybe<NetworkConstants>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNetworkConstantsPayloadNetworkConstantsArgs = {
  filter?: InputMaybe<NetworkConstantsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NetworkConstantsOrder>;
};

export type DeleteNftMetadataFilePayload = {
  __typename?: 'DeleteNftMetadataFilePayload';
  msg?: Maybe<Scalars['String']>;
  nftMetadataFile?: Maybe<Array<Maybe<NftMetadataFile>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNftMetadataFilePayloadNftMetadataFileArgs = {
  filter?: InputMaybe<NftMetadataFileFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataFileOrder>;
};

export type DeleteNftMetadataPayload = {
  __typename?: 'DeleteNftMetadataPayload';
  msg?: Maybe<Scalars['String']>;
  nftMetadata?: Maybe<Array<Maybe<NftMetadata>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNftMetadataPayloadNftMetadataArgs = {
  filter?: InputMaybe<NftMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataOrder>;
};

export type DeletePlutusScriptPayload = {
  __typename?: 'DeletePlutusScriptPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  plutusScript?: Maybe<Array<Maybe<PlutusScript>>>;
};


export type DeletePlutusScriptPayloadPlutusScriptArgs = {
  filter?: InputMaybe<PlutusScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PlutusScriptOrder>;
};

export type DeletePolicyPayload = {
  __typename?: 'DeletePolicyPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  policy?: Maybe<Array<Maybe<Policy>>>;
};


export type DeletePolicyPayloadPolicyArgs = {
  filter?: InputMaybe<PolicyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PolicyOrder>;
};

export type DeletePoolContactDataPayload = {
  __typename?: 'DeletePoolContactDataPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
};


export type DeletePoolContactDataPayloadPoolContactDataArgs = {
  filter?: InputMaybe<PoolContactDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolContactDataOrder>;
};

export type DeletePoolParametersPayload = {
  __typename?: 'DeletePoolParametersPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolParameters?: Maybe<Array<Maybe<PoolParameters>>>;
};


export type DeletePoolParametersPayloadPoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolParametersOrder>;
};

export type DeletePoolRegistrationCertificatePayload = {
  __typename?: 'DeletePoolRegistrationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolRegistrationCertificate?: Maybe<Array<Maybe<PoolRegistrationCertificate>>>;
};


export type DeletePoolRegistrationCertificatePayloadPoolRegistrationCertificateArgs = {
  filter?: InputMaybe<PoolRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeletePoolRetirementCertificatePayload = {
  __typename?: 'DeletePoolRetirementCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolRetirementCertificate?: Maybe<Array<Maybe<PoolRetirementCertificate>>>;
};


export type DeletePoolRetirementCertificatePayloadPoolRetirementCertificateArgs = {
  filter?: InputMaybe<PoolRetirementCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteProtocolParametersAlonzoPayload = {
  __typename?: 'DeleteProtocolParametersAlonzoPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersAlonzo?: Maybe<Array<Maybe<ProtocolParametersAlonzo>>>;
};


export type DeleteProtocolParametersAlonzoPayloadProtocolParametersAlonzoArgs = {
  filter?: InputMaybe<ProtocolParametersAlonzoFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersAlonzoOrder>;
};

export type DeleteProtocolParametersShelleyPayload = {
  __typename?: 'DeleteProtocolParametersShelleyPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersShelley?: Maybe<Array<Maybe<ProtocolParametersShelley>>>;
};


export type DeleteProtocolParametersShelleyPayloadProtocolParametersShelleyArgs = {
  filter?: InputMaybe<ProtocolParametersShelleyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersShelleyOrder>;
};

export type DeleteProtocolVersionPayload = {
  __typename?: 'DeleteProtocolVersionPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
};


export type DeleteProtocolVersionPayloadProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolVersionOrder>;
};

export type DeletePublicKeyPayload = {
  __typename?: 'DeletePublicKeyPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  publicKey?: Maybe<Array<Maybe<PublicKey>>>;
};


export type DeletePublicKeyPayloadPublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PublicKeyOrder>;
};

export type DeleteRatioPayload = {
  __typename?: 'DeleteRatioPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  ratio?: Maybe<Array<Maybe<Ratio>>>;
};


export type DeleteRatioPayloadRatioArgs = {
  filter?: InputMaybe<RatioFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RatioOrder>;
};

export type DeleteRedeemerPayload = {
  __typename?: 'DeleteRedeemerPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<Array<Maybe<Redeemer>>>;
};


export type DeleteRedeemerPayloadRedeemerArgs = {
  filter?: InputMaybe<RedeemerFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RedeemerOrder>;
};

export type DeleteRelayByAddressPayload = {
  __typename?: 'DeleteRelayByAddressPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  relayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
};


export type DeleteRelayByAddressPayloadRelayByAddressArgs = {
  filter?: InputMaybe<RelayByAddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByAddressOrder>;
};

export type DeleteRelayByNameMultihostPayload = {
  __typename?: 'DeleteRelayByNameMultihostPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  relayByNameMultihost?: Maybe<Array<Maybe<RelayByNameMultihost>>>;
};


export type DeleteRelayByNameMultihostPayloadRelayByNameMultihostArgs = {
  filter?: InputMaybe<RelayByNameMultihostFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameMultihostOrder>;
};

export type DeleteRelayByNamePayload = {
  __typename?: 'DeleteRelayByNamePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  relayByName?: Maybe<Array<Maybe<RelayByName>>>;
};


export type DeleteRelayByNamePayloadRelayByNameArgs = {
  filter?: InputMaybe<RelayByNameFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameOrder>;
};

export type DeleteRewardAccountPayload = {
  __typename?: 'DeleteRewardAccountPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  rewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
};


export type DeleteRewardAccountPayloadRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardAccountOrder>;
};

export type DeleteRewardPayload = {
  __typename?: 'DeleteRewardPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  reward?: Maybe<Array<Maybe<Reward>>>;
};


export type DeleteRewardPayloadRewardArgs = {
  filter?: InputMaybe<RewardFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardOrder>;
};

export type DeleteSignaturePayload = {
  __typename?: 'DeleteSignaturePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  signature?: Maybe<Array<Maybe<Signature>>>;
};


export type DeleteSignaturePayloadSignatureArgs = {
  filter?: InputMaybe<SignatureFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SignatureOrder>;
};

export type DeleteSlotPayload = {
  __typename?: 'DeleteSlotPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  slot?: Maybe<Array<Maybe<Slot>>>;
};


export type DeleteSlotPayloadSlotArgs = {
  filter?: InputMaybe<SlotFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SlotOrder>;
};

export type DeleteStakeDelegationCertificatePayload = {
  __typename?: 'DeleteStakeDelegationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakeDelegationCertificate?: Maybe<Array<Maybe<StakeDelegationCertificate>>>;
};


export type DeleteStakeDelegationCertificatePayloadStakeDelegationCertificateArgs = {
  filter?: InputMaybe<StakeDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteStakeKeyDeregistrationCertificatePayload = {
  __typename?: 'DeleteStakeKeyDeregistrationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyDeregistrationCertificate?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificate>>>;
};


export type DeleteStakeKeyDeregistrationCertificatePayloadStakeKeyDeregistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteStakeKeyRegistrationCertificatePayload = {
  __typename?: 'DeleteStakeKeyRegistrationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyRegistrationCertificate?: Maybe<Array<Maybe<StakeKeyRegistrationCertificate>>>;
};


export type DeleteStakeKeyRegistrationCertificatePayloadStakeKeyRegistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteStakePoolEpochRewardsPayload = {
  __typename?: 'DeleteStakePoolEpochRewardsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolEpochRewards?: Maybe<Array<Maybe<StakePoolEpochRewards>>>;
};


export type DeleteStakePoolEpochRewardsPayloadStakePoolEpochRewardsArgs = {
  filter?: InputMaybe<StakePoolEpochRewardsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolEpochRewardsOrder>;
};

export type DeleteStakePoolMetadataJsonPayload = {
  __typename?: 'DeleteStakePoolMetadataJsonPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
};


export type DeleteStakePoolMetadataJsonPayloadStakePoolMetadataJsonArgs = {
  filter?: InputMaybe<StakePoolMetadataJsonFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataJsonOrder>;
};

export type DeleteStakePoolMetadataPayload = {
  __typename?: 'DeleteStakePoolMetadataPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
};


export type DeleteStakePoolMetadataPayloadStakePoolMetadataArgs = {
  filter?: InputMaybe<StakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataOrder>;
};

export type DeleteStakePoolMetricsPayload = {
  __typename?: 'DeleteStakePoolMetricsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
};


export type DeleteStakePoolMetricsPayloadStakePoolMetricsArgs = {
  filter?: InputMaybe<StakePoolMetricsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsOrder>;
};

export type DeleteStakePoolMetricsSizePayload = {
  __typename?: 'DeleteStakePoolMetricsSizePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
};


export type DeleteStakePoolMetricsSizePayloadStakePoolMetricsSizeArgs = {
  filter?: InputMaybe<StakePoolMetricsSizeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsSizeOrder>;
};

export type DeleteStakePoolMetricsStakePayload = {
  __typename?: 'DeleteStakePoolMetricsStakePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
};


export type DeleteStakePoolMetricsStakePayloadStakePoolMetricsStakeArgs = {
  filter?: InputMaybe<StakePoolMetricsStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsStakeOrder>;
};

export type DeleteStakePoolPayload = {
  __typename?: 'DeleteStakePoolPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<Array<Maybe<StakePool>>>;
};


export type DeleteStakePoolPayloadStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolOrder>;
};

export type DeleteStringMetadatumPayload = {
  __typename?: 'DeleteStringMetadatumPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
};


export type DeleteStringMetadatumPayloadStringMetadatumArgs = {
  filter?: InputMaybe<StringMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StringMetadatumOrder>;
};

export type DeleteThePoolsMediaAssetsPayload = {
  __typename?: 'DeleteThePoolsMediaAssetsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  thePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
};


export type DeleteThePoolsMediaAssetsPayloadThePoolsMediaAssetsArgs = {
  filter?: InputMaybe<ThePoolsMediaAssetsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ThePoolsMediaAssetsOrder>;
};

export type DeleteTimeSettingsPayload = {
  __typename?: 'DeleteTimeSettingsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  timeSettings?: Maybe<Array<Maybe<TimeSettings>>>;
};


export type DeleteTimeSettingsPayloadTimeSettingsArgs = {
  filter?: InputMaybe<TimeSettingsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TimeSettingsOrder>;
};

export type DeleteTokenMetadataPayload = {
  __typename?: 'DeleteTokenMetadataPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  tokenMetadata?: Maybe<Array<Maybe<TokenMetadata>>>;
};


export type DeleteTokenMetadataPayloadTokenMetadataArgs = {
  filter?: InputMaybe<TokenMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataOrder>;
};

export type DeleteTokenMetadataSizedIconPayload = {
  __typename?: 'DeleteTokenMetadataSizedIconPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  tokenMetadataSizedIcon?: Maybe<Array<Maybe<TokenMetadataSizedIcon>>>;
};


export type DeleteTokenMetadataSizedIconPayloadTokenMetadataSizedIconArgs = {
  filter?: InputMaybe<TokenMetadataSizedIconFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataSizedIconOrder>;
};

export type DeleteTokenPayload = {
  __typename?: 'DeleteTokenPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  token?: Maybe<Array<Maybe<Token>>>;
};


export type DeleteTokenPayloadTokenArgs = {
  filter?: InputMaybe<TokenFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenOrder>;
};

export type DeleteTransactionInputPayload = {
  __typename?: 'DeleteTransactionInputPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  transactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
};


export type DeleteTransactionInputPayloadTransactionInputArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionInputOrder>;
};

export type DeleteTransactionOutputPayload = {
  __typename?: 'DeleteTransactionOutputPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  transactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
};


export type DeleteTransactionOutputPayloadTransactionOutputArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOutputOrder>;
};

export type DeleteTransactionPayload = {
  __typename?: 'DeleteTransactionPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  transaction?: Maybe<Array<Maybe<Transaction>>>;
};


export type DeleteTransactionPayloadTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOrder>;
};

export type DeleteValuePayload = {
  __typename?: 'DeleteValuePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  value?: Maybe<Array<Maybe<Value>>>;
};


export type DeleteValuePayloadValueArgs = {
  filter?: InputMaybe<ValueFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ValueOrder>;
};

export type DeleteWithdrawalPayload = {
  __typename?: 'DeleteWithdrawalPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  withdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
};


export type DeleteWithdrawalPayloadWithdrawalArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WithdrawalOrder>;
};

export type DeleteWitnessPayload = {
  __typename?: 'DeleteWitnessPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  witness?: Maybe<Array<Maybe<Witness>>>;
};


export type DeleteWitnessPayloadWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type DeleteWitnessScriptPayload = {
  __typename?: 'DeleteWitnessScriptPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  witnessScript?: Maybe<Array<Maybe<WitnessScript>>>;
};


export type DeleteWitnessScriptPayloadWitnessScriptArgs = {
  filter?: InputMaybe<WitnessScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WitnessScriptOrder>;
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
  activeRewards: Array<Reward>;
  activeRewardsAggregate?: Maybe<RewardAggregateResult>;
  activeStake: Array<ActiveStake>;
  activeStakeAggregate?: Maybe<ActiveStakeAggregateResult>;
  adaPots: AdaPots;
  blocks: Array<Block>;
  blocksAggregate?: Maybe<BlockAggregateResult>;
  endedAt: Slot;
  fees: Scalars['Int64'];
  liveRewards: Array<Reward>;
  liveRewardsAggregate?: Maybe<RewardAggregateResult>;
  nonce: Scalars['String'];
  number: Scalars['Int'];
  output: Scalars['Int64'];
  protocolParams: ProtocolParameters;
  startedAt: Slot;
};


export type EpochActiveRewardsArgs = {
  filter?: InputMaybe<RewardFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardOrder>;
};


export type EpochActiveRewardsAggregateArgs = {
  filter?: InputMaybe<RewardFilter>;
};


export type EpochActiveStakeArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ActiveStakeOrder>;
};


export type EpochActiveStakeAggregateArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
};


export type EpochAdaPotsArgs = {
  filter?: InputMaybe<AdaPotsFilter>;
};


export type EpochBlocksArgs = {
  filter?: InputMaybe<BlockFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BlockOrder>;
};


export type EpochBlocksAggregateArgs = {
  filter?: InputMaybe<BlockFilter>;
};


export type EpochEndedAtArgs = {
  filter?: InputMaybe<SlotFilter>;
};


export type EpochLiveRewardsArgs = {
  filter?: InputMaybe<RewardFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardOrder>;
};


export type EpochLiveRewardsAggregateArgs = {
  filter?: InputMaybe<RewardFilter>;
};


export type EpochProtocolParamsArgs = {
  filter?: InputMaybe<ProtocolParametersFilter>;
};


export type EpochStartedAtArgs = {
  filter?: InputMaybe<SlotFilter>;
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
  and?: InputMaybe<Array<InputMaybe<EpochFilter>>>;
  has?: InputMaybe<Array<InputMaybe<EpochHasFilter>>>;
  not?: InputMaybe<EpochFilter>;
  number?: InputMaybe<IntFilter>;
  or?: InputMaybe<Array<InputMaybe<EpochFilter>>>;
};

export enum EpochHasFilter {
  ActiveRewards = 'activeRewards',
  ActiveStake = 'activeStake',
  AdaPots = 'adaPots',
  Blocks = 'blocks',
  EndedAt = 'endedAt',
  Fees = 'fees',
  LiveRewards = 'liveRewards',
  Nonce = 'nonce',
  Number = 'number',
  Output = 'output',
  ProtocolParams = 'protocolParams',
  StartedAt = 'startedAt'
}

export type EpochOrder = {
  asc?: InputMaybe<EpochOrderable>;
  desc?: InputMaybe<EpochOrderable>;
  then?: InputMaybe<EpochOrder>;
};

export enum EpochOrderable {
  Fees = 'fees',
  Nonce = 'nonce',
  Number = 'number',
  Output = 'output'
}

export type EpochPatch = {
  activeRewards?: InputMaybe<Array<RewardRef>>;
  activeStake?: InputMaybe<Array<ActiveStakeRef>>;
  adaPots?: InputMaybe<AdaPotsRef>;
  blocks?: InputMaybe<Array<BlockRef>>;
  endedAt?: InputMaybe<SlotRef>;
  fees?: InputMaybe<Scalars['Int64']>;
  liveRewards?: InputMaybe<Array<RewardRef>>;
  nonce?: InputMaybe<Scalars['String']>;
  output?: InputMaybe<Scalars['Int64']>;
  protocolParams?: InputMaybe<ProtocolParametersRef>;
  startedAt?: InputMaybe<SlotRef>;
};

export type EpochRef = {
  activeRewards?: InputMaybe<Array<RewardRef>>;
  activeStake?: InputMaybe<Array<ActiveStakeRef>>;
  adaPots?: InputMaybe<AdaPotsRef>;
  blocks?: InputMaybe<Array<BlockRef>>;
  endedAt?: InputMaybe<SlotRef>;
  fees?: InputMaybe<Scalars['Int64']>;
  liveRewards?: InputMaybe<Array<RewardRef>>;
  nonce?: InputMaybe<Scalars['String']>;
  number?: InputMaybe<Scalars['Int']>;
  output?: InputMaybe<Scalars['Int64']>;
  protocolParams?: InputMaybe<ProtocolParametersRef>;
  startedAt?: InputMaybe<SlotRef>;
};

export type ExecutionPrices = {
  __typename?: 'ExecutionPrices';
  prMem: Ratio;
  prSteps: Ratio;
};


export type ExecutionPricesPrMemArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type ExecutionPricesPrStepsArgs = {
  filter?: InputMaybe<RatioFilter>;
};

export type ExecutionPricesAggregateResult = {
  __typename?: 'ExecutionPricesAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type ExecutionPricesFilter = {
  and?: InputMaybe<Array<InputMaybe<ExecutionPricesFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ExecutionPricesHasFilter>>>;
  not?: InputMaybe<ExecutionPricesFilter>;
  or?: InputMaybe<Array<InputMaybe<ExecutionPricesFilter>>>;
};

export enum ExecutionPricesHasFilter {
  PrMem = 'prMem',
  PrSteps = 'prSteps'
}

export type ExecutionPricesPatch = {
  prMem?: InputMaybe<RatioRef>;
  prSteps?: InputMaybe<RatioRef>;
};

export type ExecutionPricesRef = {
  prMem?: InputMaybe<RatioRef>;
  prSteps?: InputMaybe<RatioRef>;
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
  and?: InputMaybe<Array<InputMaybe<ExecutionUnitsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ExecutionUnitsHasFilter>>>;
  not?: InputMaybe<ExecutionUnitsFilter>;
  or?: InputMaybe<Array<InputMaybe<ExecutionUnitsFilter>>>;
};

export enum ExecutionUnitsHasFilter {
  Memory = 'memory',
  Steps = 'steps'
}

export type ExecutionUnitsOrder = {
  asc?: InputMaybe<ExecutionUnitsOrderable>;
  desc?: InputMaybe<ExecutionUnitsOrderable>;
  then?: InputMaybe<ExecutionUnitsOrder>;
};

export enum ExecutionUnitsOrderable {
  Memory = 'memory',
  Steps = 'steps'
}

export type ExecutionUnitsPatch = {
  memory?: InputMaybe<Scalars['Int']>;
  steps?: InputMaybe<Scalars['Int']>;
};

export type ExecutionUnitsRef = {
  memory?: InputMaybe<Scalars['Int']>;
  steps?: InputMaybe<Scalars['Int']>;
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
  filter?: InputMaybe<StakePoolMetadataFilter>;
};


export type ExtendedStakePoolMetadataPoolArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFieldsFilter>;
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
  filter?: InputMaybe<PoolContactDataFilter>;
};


export type ExtendedStakePoolMetadataFieldsItnArgs = {
  filter?: InputMaybe<ItnVerificationFilter>;
};


export type ExtendedStakePoolMetadataFieldsMedia_AssetsArgs = {
  filter?: InputMaybe<ThePoolsMediaAssetsFilter>;
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
  and?: InputMaybe<Array<InputMaybe<ExtendedStakePoolMetadataFieldsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ExtendedStakePoolMetadataFieldsHasFilter>>>;
  id?: InputMaybe<StringHashFilter>;
  not?: InputMaybe<ExtendedStakePoolMetadataFieldsFilter>;
  or?: InputMaybe<Array<InputMaybe<ExtendedStakePoolMetadataFieldsFilter>>>;
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
  asc?: InputMaybe<ExtendedStakePoolMetadataFieldsOrderable>;
  desc?: InputMaybe<ExtendedStakePoolMetadataFieldsOrderable>;
  then?: InputMaybe<ExtendedStakePoolMetadataFieldsOrder>;
};

export enum ExtendedStakePoolMetadataFieldsOrderable {
  Country = 'country',
  Id = 'id'
}

export type ExtendedStakePoolMetadataFieldsPatch = {
  contact?: InputMaybe<PoolContactDataRef>;
  country?: InputMaybe<Scalars['String']>;
  itn?: InputMaybe<ItnVerificationRef>;
  media_assets?: InputMaybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: InputMaybe<ExtendedPoolStatus>;
};

export type ExtendedStakePoolMetadataFieldsRef = {
  contact?: InputMaybe<PoolContactDataRef>;
  country?: InputMaybe<Scalars['String']>;
  id?: InputMaybe<Scalars['String']>;
  itn?: InputMaybe<ItnVerificationRef>;
  media_assets?: InputMaybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: InputMaybe<ExtendedPoolStatus>;
};

export type ExtendedStakePoolMetadataFilter = {
  and?: InputMaybe<Array<InputMaybe<ExtendedStakePoolMetadataFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ExtendedStakePoolMetadataHasFilter>>>;
  not?: InputMaybe<ExtendedStakePoolMetadataFilter>;
  or?: InputMaybe<Array<InputMaybe<ExtendedStakePoolMetadataFilter>>>;
};

export enum ExtendedStakePoolMetadataHasFilter {
  Metadata = 'metadata',
  Pool = 'pool',
  Serial = 'serial'
}

export type ExtendedStakePoolMetadataOrder = {
  asc?: InputMaybe<ExtendedStakePoolMetadataOrderable>;
  desc?: InputMaybe<ExtendedStakePoolMetadataOrderable>;
  then?: InputMaybe<ExtendedStakePoolMetadataOrder>;
};

export enum ExtendedStakePoolMetadataOrderable {
  Serial = 'serial'
}

export type ExtendedStakePoolMetadataPatch = {
  metadata?: InputMaybe<StakePoolMetadataRef>;
  pool?: InputMaybe<ExtendedStakePoolMetadataFieldsRef>;
  serial?: InputMaybe<Scalars['Int']>;
};

export type ExtendedStakePoolMetadataRef = {
  metadata?: InputMaybe<StakePoolMetadataRef>;
  pool?: InputMaybe<ExtendedStakePoolMetadataFieldsRef>;
  serial?: InputMaybe<Scalars['Int']>;
};

export type FloatFilter = {
  between?: InputMaybe<FloatRange>;
  eq?: InputMaybe<Scalars['Float']>;
  ge?: InputMaybe<Scalars['Float']>;
  gt?: InputMaybe<Scalars['Float']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['Float']>>>;
  le?: InputMaybe<Scalars['Float']>;
  lt?: InputMaybe<Scalars['Float']>;
};

export type FloatRange = {
  max: Scalars['Float'];
  min: Scalars['Float'];
};

export type GenerateMutationParams = {
  add?: InputMaybe<Scalars['Boolean']>;
  delete?: InputMaybe<Scalars['Boolean']>;
  update?: InputMaybe<Scalars['Boolean']>;
};

export type GenerateQueryParams = {
  aggregate?: InputMaybe<Scalars['Boolean']>;
  get?: InputMaybe<Scalars['Boolean']>;
  password?: InputMaybe<Scalars['Boolean']>;
  query?: InputMaybe<Scalars['Boolean']>;
};

export type GenesisKeyDelegationCertificate = {
  __typename?: 'GenesisKeyDelegationCertificate';
  genesisDelegateHash: Scalars['String'];
  genesisHash: Scalars['String'];
  transaction: Transaction;
  vrfKeyHash: Scalars['String'];
};


export type GenesisKeyDelegationCertificateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type GenesisKeyDelegationCertificateAggregateResult = {
  __typename?: 'GenesisKeyDelegationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
  genesisDelegateHashMax?: Maybe<Scalars['String']>;
  genesisDelegateHashMin?: Maybe<Scalars['String']>;
  genesisHashMax?: Maybe<Scalars['String']>;
  genesisHashMin?: Maybe<Scalars['String']>;
  vrfKeyHashMax?: Maybe<Scalars['String']>;
  vrfKeyHashMin?: Maybe<Scalars['String']>;
};

export type GenesisKeyDelegationCertificateFilter = {
  and?: InputMaybe<Array<InputMaybe<GenesisKeyDelegationCertificateFilter>>>;
  has?: InputMaybe<Array<InputMaybe<GenesisKeyDelegationCertificateHasFilter>>>;
  not?: InputMaybe<GenesisKeyDelegationCertificateFilter>;
  or?: InputMaybe<Array<InputMaybe<GenesisKeyDelegationCertificateFilter>>>;
};

export enum GenesisKeyDelegationCertificateHasFilter {
  GenesisDelegateHash = 'genesisDelegateHash',
  GenesisHash = 'genesisHash',
  Transaction = 'transaction',
  VrfKeyHash = 'vrfKeyHash'
}

export type GenesisKeyDelegationCertificateOrder = {
  asc?: InputMaybe<GenesisKeyDelegationCertificateOrderable>;
  desc?: InputMaybe<GenesisKeyDelegationCertificateOrderable>;
  then?: InputMaybe<GenesisKeyDelegationCertificateOrder>;
};

export enum GenesisKeyDelegationCertificateOrderable {
  GenesisDelegateHash = 'genesisDelegateHash',
  GenesisHash = 'genesisHash',
  VrfKeyHash = 'vrfKeyHash'
}

export type GenesisKeyDelegationCertificatePatch = {
  genesisDelegateHash?: InputMaybe<Scalars['String']>;
  genesisHash?: InputMaybe<Scalars['String']>;
  transaction?: InputMaybe<TransactionRef>;
  vrfKeyHash?: InputMaybe<Scalars['String']>;
};

export type GenesisKeyDelegationCertificateRef = {
  genesisDelegateHash?: InputMaybe<Scalars['String']>;
  genesisHash?: InputMaybe<Scalars['String']>;
  transaction?: InputMaybe<TransactionRef>;
  vrfKeyHash?: InputMaybe<Scalars['String']>;
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
  and?: InputMaybe<Array<InputMaybe<ItnVerificationFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ItnVerificationHasFilter>>>;
  not?: InputMaybe<ItnVerificationFilter>;
  or?: InputMaybe<Array<InputMaybe<ItnVerificationFilter>>>;
};

export enum ItnVerificationHasFilter {
  Owner = 'owner',
  Witness = 'witness'
}

export type ItnVerificationOrder = {
  asc?: InputMaybe<ItnVerificationOrderable>;
  desc?: InputMaybe<ItnVerificationOrderable>;
  then?: InputMaybe<ItnVerificationOrder>;
};

export enum ItnVerificationOrderable {
  Owner = 'owner',
  Witness = 'witness'
}

export type ItnVerificationPatch = {
  owner?: InputMaybe<Scalars['String']>;
  witness?: InputMaybe<Scalars['String']>;
};

export type ItnVerificationRef = {
  owner?: InputMaybe<Scalars['String']>;
  witness?: InputMaybe<Scalars['String']>;
};

export type Int64Filter = {
  between?: InputMaybe<Int64Range>;
  eq?: InputMaybe<Scalars['Int64']>;
  ge?: InputMaybe<Scalars['Int64']>;
  gt?: InputMaybe<Scalars['Int64']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['Int64']>>>;
  le?: InputMaybe<Scalars['Int64']>;
  lt?: InputMaybe<Scalars['Int64']>;
};

export type Int64Range = {
  max: Scalars['Int64'];
  min: Scalars['Int64'];
};

export type IntFilter = {
  between?: InputMaybe<IntRange>;
  eq?: InputMaybe<Scalars['Int']>;
  ge?: InputMaybe<Scalars['Int']>;
  gt?: InputMaybe<Scalars['Int']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['Int']>>>;
  le?: InputMaybe<Scalars['Int']>;
  lt?: InputMaybe<Scalars['Int']>;
};

export type IntRange = {
  max: Scalars['Int'];
  min: Scalars['Int'];
};

export type IntegerMetadatum = {
  __typename?: 'IntegerMetadatum';
  int: Scalars['Int'];
};

export type IntegerMetadatumAggregateResult = {
  __typename?: 'IntegerMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  intAvg?: Maybe<Scalars['Float']>;
  intMax?: Maybe<Scalars['Int']>;
  intMin?: Maybe<Scalars['Int']>;
  intSum?: Maybe<Scalars['Int']>;
};

export type IntegerMetadatumFilter = {
  and?: InputMaybe<Array<InputMaybe<IntegerMetadatumFilter>>>;
  has?: InputMaybe<Array<InputMaybe<IntegerMetadatumHasFilter>>>;
  not?: InputMaybe<IntegerMetadatumFilter>;
  or?: InputMaybe<Array<InputMaybe<IntegerMetadatumFilter>>>;
};

export enum IntegerMetadatumHasFilter {
  Int = 'int'
}

export type IntegerMetadatumOrder = {
  asc?: InputMaybe<IntegerMetadatumOrderable>;
  desc?: InputMaybe<IntegerMetadatumOrderable>;
  then?: InputMaybe<IntegerMetadatumOrder>;
};

export enum IntegerMetadatumOrderable {
  Int = 'int'
}

export type IntegerMetadatumPatch = {
  int?: InputMaybe<Scalars['Int']>;
};

export type IntegerMetadatumRef = {
  int?: InputMaybe<Scalars['Int']>;
};

export type IntersectsFilter = {
  multiPolygon?: InputMaybe<MultiPolygonRef>;
  polygon?: InputMaybe<PolygonRef>;
};

export type KeyValueMetadatum = {
  __typename?: 'KeyValueMetadatum';
  label: Scalars['String'];
  metadatum: Metadatum;
};


export type KeyValueMetadatumMetadatumArgs = {
  filter?: InputMaybe<MetadatumFilter>;
};

export type KeyValueMetadatumAggregateResult = {
  __typename?: 'KeyValueMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  labelMax?: Maybe<Scalars['String']>;
  labelMin?: Maybe<Scalars['String']>;
};

export type KeyValueMetadatumFilter = {
  and?: InputMaybe<Array<InputMaybe<KeyValueMetadatumFilter>>>;
  has?: InputMaybe<Array<InputMaybe<KeyValueMetadatumHasFilter>>>;
  label?: InputMaybe<StringExactFilter_StringFullTextFilter>;
  not?: InputMaybe<KeyValueMetadatumFilter>;
  or?: InputMaybe<Array<InputMaybe<KeyValueMetadatumFilter>>>;
};

export enum KeyValueMetadatumHasFilter {
  Label = 'label',
  Metadatum = 'metadatum'
}

export type KeyValueMetadatumOrder = {
  asc?: InputMaybe<KeyValueMetadatumOrderable>;
  desc?: InputMaybe<KeyValueMetadatumOrderable>;
  then?: InputMaybe<KeyValueMetadatumOrder>;
};

export enum KeyValueMetadatumOrderable {
  Label = 'label'
}

export type KeyValueMetadatumPatch = {
  label?: InputMaybe<Scalars['String']>;
  metadatum?: InputMaybe<MetadatumRef>;
};

export type KeyValueMetadatumRef = {
  label?: InputMaybe<Scalars['String']>;
  metadatum?: InputMaybe<MetadatumRef>;
};

export type Metadatum = BytesMetadatum | IntegerMetadatum | MetadatumArray | MetadatumMap | StringMetadatum;

export type MetadatumArray = {
  __typename?: 'MetadatumArray';
  array: Array<Metadatum>;
};


export type MetadatumArrayArrayArgs = {
  filter?: InputMaybe<MetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type MetadatumArrayAggregateResult = {
  __typename?: 'MetadatumArrayAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type MetadatumArrayFilter = {
  and?: InputMaybe<Array<InputMaybe<MetadatumArrayFilter>>>;
  has?: InputMaybe<Array<InputMaybe<MetadatumArrayHasFilter>>>;
  not?: InputMaybe<MetadatumArrayFilter>;
  or?: InputMaybe<Array<InputMaybe<MetadatumArrayFilter>>>;
};

export enum MetadatumArrayHasFilter {
  Array = 'array'
}

export type MetadatumArrayPatch = {
  array?: InputMaybe<Array<MetadatumRef>>;
};

export type MetadatumArrayRef = {
  array?: InputMaybe<Array<MetadatumRef>>;
};

export type MetadatumFilter = {
  bytesMetadatumFilter?: InputMaybe<BytesMetadatumFilter>;
  integerMetadatumFilter?: InputMaybe<IntegerMetadatumFilter>;
  memberTypes?: InputMaybe<Array<MetadatumType>>;
  metadatumArrayFilter?: InputMaybe<MetadatumArrayFilter>;
  metadatumMapFilter?: InputMaybe<MetadatumMapFilter>;
  stringMetadatumFilter?: InputMaybe<StringMetadatumFilter>;
};

export type MetadatumMap = {
  __typename?: 'MetadatumMap';
  map: Array<KeyValueMetadatum>;
  mapAggregate?: Maybe<KeyValueMetadatumAggregateResult>;
};


export type MetadatumMapMapArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<KeyValueMetadatumOrder>;
};


export type MetadatumMapMapAggregateArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
};

export type MetadatumMapAggregateResult = {
  __typename?: 'MetadatumMapAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type MetadatumMapFilter = {
  and?: InputMaybe<Array<InputMaybe<MetadatumMapFilter>>>;
  has?: InputMaybe<Array<InputMaybe<MetadatumMapHasFilter>>>;
  not?: InputMaybe<MetadatumMapFilter>;
  or?: InputMaybe<Array<InputMaybe<MetadatumMapFilter>>>;
};

export enum MetadatumMapHasFilter {
  Map = 'map'
}

export type MetadatumMapPatch = {
  map?: InputMaybe<Array<KeyValueMetadatumRef>>;
};

export type MetadatumMapRef = {
  map?: InputMaybe<Array<KeyValueMetadatumRef>>;
};

export type MetadatumRef = {
  bytesMetadatumRef?: InputMaybe<BytesMetadatumRef>;
  integerMetadatumRef?: InputMaybe<IntegerMetadatumRef>;
  metadatumArrayRef?: InputMaybe<MetadatumArrayRef>;
  metadatumMapRef?: InputMaybe<MetadatumMapRef>;
  stringMetadatumRef?: InputMaybe<StringMetadatumRef>;
};

export enum MetadatumType {
  BytesMetadatum = 'BytesMetadatum',
  IntegerMetadatum = 'IntegerMetadatum',
  MetadatumArray = 'MetadatumArray',
  MetadatumMap = 'MetadatumMap',
  StringMetadatum = 'StringMetadatum'
}

export type MirCertificate = {
  __typename?: 'MirCertificate';
  pot: Scalars['String'];
  quantity: Scalars['Int64'];
  rewardAccount: RewardAccount;
  transaction: Transaction;
};


export type MirCertificateRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type MirCertificateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type MirCertificateAggregateResult = {
  __typename?: 'MirCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
  potMax?: Maybe<Scalars['String']>;
  potMin?: Maybe<Scalars['String']>;
  quantityAvg?: Maybe<Scalars['Float']>;
  quantityMax?: Maybe<Scalars['Int64']>;
  quantityMin?: Maybe<Scalars['Int64']>;
  quantitySum?: Maybe<Scalars['Int64']>;
};

export type MirCertificateFilter = {
  and?: InputMaybe<Array<InputMaybe<MirCertificateFilter>>>;
  has?: InputMaybe<Array<InputMaybe<MirCertificateHasFilter>>>;
  not?: InputMaybe<MirCertificateFilter>;
  or?: InputMaybe<Array<InputMaybe<MirCertificateFilter>>>;
};

export enum MirCertificateHasFilter {
  Pot = 'pot',
  Quantity = 'quantity',
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type MirCertificateOrder = {
  asc?: InputMaybe<MirCertificateOrderable>;
  desc?: InputMaybe<MirCertificateOrderable>;
  then?: InputMaybe<MirCertificateOrder>;
};

export enum MirCertificateOrderable {
  Pot = 'pot',
  Quantity = 'quantity'
}

export type MirCertificatePatch = {
  pot?: InputMaybe<Scalars['String']>;
  quantity?: InputMaybe<Scalars['Int64']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type MirCertificateRef = {
  pot?: InputMaybe<Scalars['String']>;
  quantity?: InputMaybe<Scalars['Int64']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

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
  addAsset?: Maybe<AddAssetPayload>;
  addAssetMintOrBurn?: Maybe<AddAssetMintOrBurnPayload>;
  addAuxiliaryData?: Maybe<AddAuxiliaryDataPayload>;
  addAuxiliaryDataBody?: Maybe<AddAuxiliaryDataBodyPayload>;
  addAuxiliaryScript?: Maybe<AddAuxiliaryScriptPayload>;
  addBlock?: Maybe<AddBlockPayload>;
  addBootstrapWitness?: Maybe<AddBootstrapWitnessPayload>;
  addBytesMetadatum?: Maybe<AddBytesMetadatumPayload>;
  addCoinSupply?: Maybe<AddCoinSupplyPayload>;
  addCostModel?: Maybe<AddCostModelPayload>;
  addCostModelCoefficient?: Maybe<AddCostModelCoefficientPayload>;
  addDatum?: Maybe<AddDatumPayload>;
  addEpoch?: Maybe<AddEpochPayload>;
  addExecutionPrices?: Maybe<AddExecutionPricesPayload>;
  addExecutionUnits?: Maybe<AddExecutionUnitsPayload>;
  addExtendedStakePoolMetadata?: Maybe<AddExtendedStakePoolMetadataPayload>;
  addExtendedStakePoolMetadataFields?: Maybe<AddExtendedStakePoolMetadataFieldsPayload>;
  addGenesisKeyDelegationCertificate?: Maybe<AddGenesisKeyDelegationCertificatePayload>;
  addITNVerification?: Maybe<AddItnVerificationPayload>;
  addIntegerMetadatum?: Maybe<AddIntegerMetadatumPayload>;
  addKeyValueMetadatum?: Maybe<AddKeyValueMetadatumPayload>;
  addMetadatumArray?: Maybe<AddMetadatumArrayPayload>;
  addMetadatumMap?: Maybe<AddMetadatumMapPayload>;
  addMirCertificate?: Maybe<AddMirCertificatePayload>;
  addNOf?: Maybe<AddNOfPayload>;
  addNativeScript?: Maybe<AddNativeScriptPayload>;
  addNetworkConstants?: Maybe<AddNetworkConstantsPayload>;
  addNftMetadata?: Maybe<AddNftMetadataPayload>;
  addNftMetadataFile?: Maybe<AddNftMetadataFilePayload>;
  addPlutusScript?: Maybe<AddPlutusScriptPayload>;
  addPolicy?: Maybe<AddPolicyPayload>;
  addPoolContactData?: Maybe<AddPoolContactDataPayload>;
  addPoolParameters?: Maybe<AddPoolParametersPayload>;
  addPoolRegistrationCertificate?: Maybe<AddPoolRegistrationCertificatePayload>;
  addPoolRetirementCertificate?: Maybe<AddPoolRetirementCertificatePayload>;
  addProtocolParametersAlonzo?: Maybe<AddProtocolParametersAlonzoPayload>;
  addProtocolParametersShelley?: Maybe<AddProtocolParametersShelleyPayload>;
  addProtocolVersion?: Maybe<AddProtocolVersionPayload>;
  addPublicKey?: Maybe<AddPublicKeyPayload>;
  addRatio?: Maybe<AddRatioPayload>;
  addRedeemer?: Maybe<AddRedeemerPayload>;
  addRelayByAddress?: Maybe<AddRelayByAddressPayload>;
  addRelayByName?: Maybe<AddRelayByNamePayload>;
  addRelayByNameMultihost?: Maybe<AddRelayByNameMultihostPayload>;
  addReward?: Maybe<AddRewardPayload>;
  addRewardAccount?: Maybe<AddRewardAccountPayload>;
  addSignature?: Maybe<AddSignaturePayload>;
  addSlot?: Maybe<AddSlotPayload>;
  addStakeDelegationCertificate?: Maybe<AddStakeDelegationCertificatePayload>;
  addStakeKeyDeregistrationCertificate?: Maybe<AddStakeKeyDeregistrationCertificatePayload>;
  addStakeKeyRegistrationCertificate?: Maybe<AddStakeKeyRegistrationCertificatePayload>;
  addStakePool?: Maybe<AddStakePoolPayload>;
  addStakePoolEpochRewards?: Maybe<AddStakePoolEpochRewardsPayload>;
  addStakePoolMetadata?: Maybe<AddStakePoolMetadataPayload>;
  addStakePoolMetadataJson?: Maybe<AddStakePoolMetadataJsonPayload>;
  addStakePoolMetrics?: Maybe<AddStakePoolMetricsPayload>;
  addStakePoolMetricsSize?: Maybe<AddStakePoolMetricsSizePayload>;
  addStakePoolMetricsStake?: Maybe<AddStakePoolMetricsStakePayload>;
  addStringMetadatum?: Maybe<AddStringMetadatumPayload>;
  addThePoolsMediaAssets?: Maybe<AddThePoolsMediaAssetsPayload>;
  addTimeSettings?: Maybe<AddTimeSettingsPayload>;
  addToken?: Maybe<AddTokenPayload>;
  addTokenMetadata?: Maybe<AddTokenMetadataPayload>;
  addTokenMetadataSizedIcon?: Maybe<AddTokenMetadataSizedIconPayload>;
  addTransaction?: Maybe<AddTransactionPayload>;
  addTransactionInput?: Maybe<AddTransactionInputPayload>;
  addTransactionOutput?: Maybe<AddTransactionOutputPayload>;
  addValue?: Maybe<AddValuePayload>;
  addWithdrawal?: Maybe<AddWithdrawalPayload>;
  addWitness?: Maybe<AddWitnessPayload>;
  addWitnessScript?: Maybe<AddWitnessScriptPayload>;
  deleteActiveStake?: Maybe<DeleteActiveStakePayload>;
  deleteAda?: Maybe<DeleteAdaPayload>;
  deleteAdaPots?: Maybe<DeleteAdaPotsPayload>;
  deleteAddress?: Maybe<DeleteAddressPayload>;
  deleteAsset?: Maybe<DeleteAssetPayload>;
  deleteAssetMintOrBurn?: Maybe<DeleteAssetMintOrBurnPayload>;
  deleteAuxiliaryData?: Maybe<DeleteAuxiliaryDataPayload>;
  deleteAuxiliaryDataBody?: Maybe<DeleteAuxiliaryDataBodyPayload>;
  deleteAuxiliaryScript?: Maybe<DeleteAuxiliaryScriptPayload>;
  deleteBlock?: Maybe<DeleteBlockPayload>;
  deleteBootstrapWitness?: Maybe<DeleteBootstrapWitnessPayload>;
  deleteBytesMetadatum?: Maybe<DeleteBytesMetadatumPayload>;
  deleteCoinSupply?: Maybe<DeleteCoinSupplyPayload>;
  deleteCostModel?: Maybe<DeleteCostModelPayload>;
  deleteCostModelCoefficient?: Maybe<DeleteCostModelCoefficientPayload>;
  deleteDatum?: Maybe<DeleteDatumPayload>;
  deleteEpoch?: Maybe<DeleteEpochPayload>;
  deleteExecutionPrices?: Maybe<DeleteExecutionPricesPayload>;
  deleteExecutionUnits?: Maybe<DeleteExecutionUnitsPayload>;
  deleteExtendedStakePoolMetadata?: Maybe<DeleteExtendedStakePoolMetadataPayload>;
  deleteExtendedStakePoolMetadataFields?: Maybe<DeleteExtendedStakePoolMetadataFieldsPayload>;
  deleteGenesisKeyDelegationCertificate?: Maybe<DeleteGenesisKeyDelegationCertificatePayload>;
  deleteITNVerification?: Maybe<DeleteItnVerificationPayload>;
  deleteIntegerMetadatum?: Maybe<DeleteIntegerMetadatumPayload>;
  deleteKeyValueMetadatum?: Maybe<DeleteKeyValueMetadatumPayload>;
  deleteMetadatumArray?: Maybe<DeleteMetadatumArrayPayload>;
  deleteMetadatumMap?: Maybe<DeleteMetadatumMapPayload>;
  deleteMirCertificate?: Maybe<DeleteMirCertificatePayload>;
  deleteNOf?: Maybe<DeleteNOfPayload>;
  deleteNativeScript?: Maybe<DeleteNativeScriptPayload>;
  deleteNetworkConstants?: Maybe<DeleteNetworkConstantsPayload>;
  deleteNftMetadata?: Maybe<DeleteNftMetadataPayload>;
  deleteNftMetadataFile?: Maybe<DeleteNftMetadataFilePayload>;
  deletePlutusScript?: Maybe<DeletePlutusScriptPayload>;
  deletePolicy?: Maybe<DeletePolicyPayload>;
  deletePoolContactData?: Maybe<DeletePoolContactDataPayload>;
  deletePoolParameters?: Maybe<DeletePoolParametersPayload>;
  deletePoolRegistrationCertificate?: Maybe<DeletePoolRegistrationCertificatePayload>;
  deletePoolRetirementCertificate?: Maybe<DeletePoolRetirementCertificatePayload>;
  deleteProtocolParametersAlonzo?: Maybe<DeleteProtocolParametersAlonzoPayload>;
  deleteProtocolParametersShelley?: Maybe<DeleteProtocolParametersShelleyPayload>;
  deleteProtocolVersion?: Maybe<DeleteProtocolVersionPayload>;
  deletePublicKey?: Maybe<DeletePublicKeyPayload>;
  deleteRatio?: Maybe<DeleteRatioPayload>;
  deleteRedeemer?: Maybe<DeleteRedeemerPayload>;
  deleteRelayByAddress?: Maybe<DeleteRelayByAddressPayload>;
  deleteRelayByName?: Maybe<DeleteRelayByNamePayload>;
  deleteRelayByNameMultihost?: Maybe<DeleteRelayByNameMultihostPayload>;
  deleteReward?: Maybe<DeleteRewardPayload>;
  deleteRewardAccount?: Maybe<DeleteRewardAccountPayload>;
  deleteSignature?: Maybe<DeleteSignaturePayload>;
  deleteSlot?: Maybe<DeleteSlotPayload>;
  deleteStakeDelegationCertificate?: Maybe<DeleteStakeDelegationCertificatePayload>;
  deleteStakeKeyDeregistrationCertificate?: Maybe<DeleteStakeKeyDeregistrationCertificatePayload>;
  deleteStakeKeyRegistrationCertificate?: Maybe<DeleteStakeKeyRegistrationCertificatePayload>;
  deleteStakePool?: Maybe<DeleteStakePoolPayload>;
  deleteStakePoolEpochRewards?: Maybe<DeleteStakePoolEpochRewardsPayload>;
  deleteStakePoolMetadata?: Maybe<DeleteStakePoolMetadataPayload>;
  deleteStakePoolMetadataJson?: Maybe<DeleteStakePoolMetadataJsonPayload>;
  deleteStakePoolMetrics?: Maybe<DeleteStakePoolMetricsPayload>;
  deleteStakePoolMetricsSize?: Maybe<DeleteStakePoolMetricsSizePayload>;
  deleteStakePoolMetricsStake?: Maybe<DeleteStakePoolMetricsStakePayload>;
  deleteStringMetadatum?: Maybe<DeleteStringMetadatumPayload>;
  deleteThePoolsMediaAssets?: Maybe<DeleteThePoolsMediaAssetsPayload>;
  deleteTimeSettings?: Maybe<DeleteTimeSettingsPayload>;
  deleteToken?: Maybe<DeleteTokenPayload>;
  deleteTokenMetadata?: Maybe<DeleteTokenMetadataPayload>;
  deleteTokenMetadataSizedIcon?: Maybe<DeleteTokenMetadataSizedIconPayload>;
  deleteTransaction?: Maybe<DeleteTransactionPayload>;
  deleteTransactionInput?: Maybe<DeleteTransactionInputPayload>;
  deleteTransactionOutput?: Maybe<DeleteTransactionOutputPayload>;
  deleteValue?: Maybe<DeleteValuePayload>;
  deleteWithdrawal?: Maybe<DeleteWithdrawalPayload>;
  deleteWitness?: Maybe<DeleteWitnessPayload>;
  deleteWitnessScript?: Maybe<DeleteWitnessScriptPayload>;
  updateActiveStake?: Maybe<UpdateActiveStakePayload>;
  updateAda?: Maybe<UpdateAdaPayload>;
  updateAdaPots?: Maybe<UpdateAdaPotsPayload>;
  updateAddress?: Maybe<UpdateAddressPayload>;
  updateAsset?: Maybe<UpdateAssetPayload>;
  updateAssetMintOrBurn?: Maybe<UpdateAssetMintOrBurnPayload>;
  updateAuxiliaryData?: Maybe<UpdateAuxiliaryDataPayload>;
  updateAuxiliaryDataBody?: Maybe<UpdateAuxiliaryDataBodyPayload>;
  updateAuxiliaryScript?: Maybe<UpdateAuxiliaryScriptPayload>;
  updateBlock?: Maybe<UpdateBlockPayload>;
  updateBootstrapWitness?: Maybe<UpdateBootstrapWitnessPayload>;
  updateBytesMetadatum?: Maybe<UpdateBytesMetadatumPayload>;
  updateCoinSupply?: Maybe<UpdateCoinSupplyPayload>;
  updateCostModel?: Maybe<UpdateCostModelPayload>;
  updateCostModelCoefficient?: Maybe<UpdateCostModelCoefficientPayload>;
  updateDatum?: Maybe<UpdateDatumPayload>;
  updateEpoch?: Maybe<UpdateEpochPayload>;
  updateExecutionPrices?: Maybe<UpdateExecutionPricesPayload>;
  updateExecutionUnits?: Maybe<UpdateExecutionUnitsPayload>;
  updateExtendedStakePoolMetadata?: Maybe<UpdateExtendedStakePoolMetadataPayload>;
  updateExtendedStakePoolMetadataFields?: Maybe<UpdateExtendedStakePoolMetadataFieldsPayload>;
  updateGenesisKeyDelegationCertificate?: Maybe<UpdateGenesisKeyDelegationCertificatePayload>;
  updateITNVerification?: Maybe<UpdateItnVerificationPayload>;
  updateIntegerMetadatum?: Maybe<UpdateIntegerMetadatumPayload>;
  updateKeyValueMetadatum?: Maybe<UpdateKeyValueMetadatumPayload>;
  updateMetadatumArray?: Maybe<UpdateMetadatumArrayPayload>;
  updateMetadatumMap?: Maybe<UpdateMetadatumMapPayload>;
  updateMirCertificate?: Maybe<UpdateMirCertificatePayload>;
  updateNOf?: Maybe<UpdateNOfPayload>;
  updateNativeScript?: Maybe<UpdateNativeScriptPayload>;
  updateNetworkConstants?: Maybe<UpdateNetworkConstantsPayload>;
  updateNftMetadata?: Maybe<UpdateNftMetadataPayload>;
  updateNftMetadataFile?: Maybe<UpdateNftMetadataFilePayload>;
  updatePlutusScript?: Maybe<UpdatePlutusScriptPayload>;
  updatePolicy?: Maybe<UpdatePolicyPayload>;
  updatePoolContactData?: Maybe<UpdatePoolContactDataPayload>;
  updatePoolParameters?: Maybe<UpdatePoolParametersPayload>;
  updatePoolRegistrationCertificate?: Maybe<UpdatePoolRegistrationCertificatePayload>;
  updatePoolRetirementCertificate?: Maybe<UpdatePoolRetirementCertificatePayload>;
  updateProtocolParametersAlonzo?: Maybe<UpdateProtocolParametersAlonzoPayload>;
  updateProtocolParametersShelley?: Maybe<UpdateProtocolParametersShelleyPayload>;
  updateProtocolVersion?: Maybe<UpdateProtocolVersionPayload>;
  updatePublicKey?: Maybe<UpdatePublicKeyPayload>;
  updateRatio?: Maybe<UpdateRatioPayload>;
  updateRedeemer?: Maybe<UpdateRedeemerPayload>;
  updateRelayByAddress?: Maybe<UpdateRelayByAddressPayload>;
  updateRelayByName?: Maybe<UpdateRelayByNamePayload>;
  updateRelayByNameMultihost?: Maybe<UpdateRelayByNameMultihostPayload>;
  updateReward?: Maybe<UpdateRewardPayload>;
  updateRewardAccount?: Maybe<UpdateRewardAccountPayload>;
  updateSignature?: Maybe<UpdateSignaturePayload>;
  updateSlot?: Maybe<UpdateSlotPayload>;
  updateStakeDelegationCertificate?: Maybe<UpdateStakeDelegationCertificatePayload>;
  updateStakeKeyDeregistrationCertificate?: Maybe<UpdateStakeKeyDeregistrationCertificatePayload>;
  updateStakeKeyRegistrationCertificate?: Maybe<UpdateStakeKeyRegistrationCertificatePayload>;
  updateStakePool?: Maybe<UpdateStakePoolPayload>;
  updateStakePoolEpochRewards?: Maybe<UpdateStakePoolEpochRewardsPayload>;
  updateStakePoolMetadata?: Maybe<UpdateStakePoolMetadataPayload>;
  updateStakePoolMetadataJson?: Maybe<UpdateStakePoolMetadataJsonPayload>;
  updateStakePoolMetrics?: Maybe<UpdateStakePoolMetricsPayload>;
  updateStakePoolMetricsSize?: Maybe<UpdateStakePoolMetricsSizePayload>;
  updateStakePoolMetricsStake?: Maybe<UpdateStakePoolMetricsStakePayload>;
  updateStringMetadatum?: Maybe<UpdateStringMetadatumPayload>;
  updateThePoolsMediaAssets?: Maybe<UpdateThePoolsMediaAssetsPayload>;
  updateTimeSettings?: Maybe<UpdateTimeSettingsPayload>;
  updateToken?: Maybe<UpdateTokenPayload>;
  updateTokenMetadata?: Maybe<UpdateTokenMetadataPayload>;
  updateTokenMetadataSizedIcon?: Maybe<UpdateTokenMetadataSizedIconPayload>;
  updateTransaction?: Maybe<UpdateTransactionPayload>;
  updateTransactionInput?: Maybe<UpdateTransactionInputPayload>;
  updateTransactionOutput?: Maybe<UpdateTransactionOutputPayload>;
  updateValue?: Maybe<UpdateValuePayload>;
  updateWithdrawal?: Maybe<UpdateWithdrawalPayload>;
  updateWitness?: Maybe<UpdateWitnessPayload>;
  updateWitnessScript?: Maybe<UpdateWitnessScriptPayload>;
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
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddAssetArgs = {
  input: Array<AddAssetInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddAssetMintOrBurnArgs = {
  input: Array<AddAssetMintOrBurnInput>;
};


export type MutationAddAuxiliaryDataArgs = {
  input: Array<AddAuxiliaryDataInput>;
};


export type MutationAddAuxiliaryDataBodyArgs = {
  input: Array<AddAuxiliaryDataBodyInput>;
};


export type MutationAddAuxiliaryScriptArgs = {
  input: Array<AddAuxiliaryScriptInput>;
};


export type MutationAddBlockArgs = {
  input: Array<AddBlockInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddBootstrapWitnessArgs = {
  input: Array<AddBootstrapWitnessInput>;
};


export type MutationAddBytesMetadatumArgs = {
  input: Array<AddBytesMetadatumInput>;
};


export type MutationAddCoinSupplyArgs = {
  input: Array<AddCoinSupplyInput>;
};


export type MutationAddCostModelArgs = {
  input: Array<AddCostModelInput>;
};


export type MutationAddCostModelCoefficientArgs = {
  input: Array<AddCostModelCoefficientInput>;
};


export type MutationAddDatumArgs = {
  input: Array<AddDatumInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddEpochArgs = {
  input: Array<AddEpochInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
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
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddGenesisKeyDelegationCertificateArgs = {
  input: Array<AddGenesisKeyDelegationCertificateInput>;
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


export type MutationAddMirCertificateArgs = {
  input: Array<AddMirCertificateInput>;
};


export type MutationAddNOfArgs = {
  input: Array<AddNOfInput>;
};


export type MutationAddNativeScriptArgs = {
  input: Array<AddNativeScriptInput>;
};


export type MutationAddNetworkConstantsArgs = {
  input: Array<AddNetworkConstantsInput>;
};


export type MutationAddNftMetadataArgs = {
  input: Array<AddNftMetadataInput>;
};


export type MutationAddNftMetadataFileArgs = {
  input: Array<AddNftMetadataFileInput>;
};


export type MutationAddPlutusScriptArgs = {
  input: Array<AddPlutusScriptInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddPolicyArgs = {
  input: Array<AddPolicyInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddPoolContactDataArgs = {
  input: Array<AddPoolContactDataInput>;
};


export type MutationAddPoolParametersArgs = {
  input: Array<AddPoolParametersInput>;
};


export type MutationAddPoolRegistrationCertificateArgs = {
  input: Array<AddPoolRegistrationCertificateInput>;
};


export type MutationAddPoolRetirementCertificateArgs = {
  input: Array<AddPoolRetirementCertificateInput>;
};


export type MutationAddProtocolParametersAlonzoArgs = {
  input: Array<AddProtocolParametersAlonzoInput>;
};


export type MutationAddProtocolParametersShelleyArgs = {
  input: Array<AddProtocolParametersShelleyInput>;
};


export type MutationAddProtocolVersionArgs = {
  input: Array<AddProtocolVersionInput>;
};


export type MutationAddPublicKeyArgs = {
  input: Array<AddPublicKeyInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddRatioArgs = {
  input: Array<AddRatioInput>;
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


export type MutationAddRewardArgs = {
  input: Array<AddRewardInput>;
};


export type MutationAddRewardAccountArgs = {
  input: Array<AddRewardAccountInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddSignatureArgs = {
  input: Array<AddSignatureInput>;
};


export type MutationAddSlotArgs = {
  input: Array<AddSlotInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddStakeDelegationCertificateArgs = {
  input: Array<AddStakeDelegationCertificateInput>;
};


export type MutationAddStakeKeyDeregistrationCertificateArgs = {
  input: Array<AddStakeKeyDeregistrationCertificateInput>;
};


export type MutationAddStakeKeyRegistrationCertificateArgs = {
  input: Array<AddStakeKeyRegistrationCertificateInput>;
};


export type MutationAddStakePoolArgs = {
  input: Array<AddStakePoolInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
};


export type MutationAddStakePoolEpochRewardsArgs = {
  input: Array<AddStakePoolEpochRewardsInput>;
};


export type MutationAddStakePoolMetadataArgs = {
  input: Array<AddStakePoolMetadataInput>;
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


export type MutationAddStringMetadatumArgs = {
  input: Array<AddStringMetadatumInput>;
};


export type MutationAddThePoolsMediaAssetsArgs = {
  input: Array<AddThePoolsMediaAssetsInput>;
};


export type MutationAddTimeSettingsArgs = {
  input: Array<AddTimeSettingsInput>;
};


export type MutationAddTokenArgs = {
  input: Array<AddTokenInput>;
};


export type MutationAddTokenMetadataArgs = {
  input: Array<AddTokenMetadataInput>;
};


export type MutationAddTokenMetadataSizedIconArgs = {
  input: Array<AddTokenMetadataSizedIconInput>;
};


export type MutationAddTransactionArgs = {
  input: Array<AddTransactionInput>;
  upsert?: InputMaybe<Scalars['Boolean']>;
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


export type MutationAddWitnessArgs = {
  input: Array<AddWitnessInput>;
};


export type MutationAddWitnessScriptArgs = {
  input: Array<AddWitnessScriptInput>;
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


export type MutationDeleteAssetArgs = {
  filter: AssetFilter;
};


export type MutationDeleteAssetMintOrBurnArgs = {
  filter: AssetMintOrBurnFilter;
};


export type MutationDeleteAuxiliaryDataArgs = {
  filter: AuxiliaryDataFilter;
};


export type MutationDeleteAuxiliaryDataBodyArgs = {
  filter: AuxiliaryDataBodyFilter;
};


export type MutationDeleteAuxiliaryScriptArgs = {
  filter: AuxiliaryScriptFilter;
};


export type MutationDeleteBlockArgs = {
  filter: BlockFilter;
};


export type MutationDeleteBootstrapWitnessArgs = {
  filter: BootstrapWitnessFilter;
};


export type MutationDeleteBytesMetadatumArgs = {
  filter: BytesMetadatumFilter;
};


export type MutationDeleteCoinSupplyArgs = {
  filter: CoinSupplyFilter;
};


export type MutationDeleteCostModelArgs = {
  filter: CostModelFilter;
};


export type MutationDeleteCostModelCoefficientArgs = {
  filter: CostModelCoefficientFilter;
};


export type MutationDeleteDatumArgs = {
  filter: DatumFilter;
};


export type MutationDeleteEpochArgs = {
  filter: EpochFilter;
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


export type MutationDeleteGenesisKeyDelegationCertificateArgs = {
  filter: GenesisKeyDelegationCertificateFilter;
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


export type MutationDeleteMirCertificateArgs = {
  filter: MirCertificateFilter;
};


export type MutationDeleteNOfArgs = {
  filter: NOfFilter;
};


export type MutationDeleteNativeScriptArgs = {
  filter: NativeScriptFilter;
};


export type MutationDeleteNetworkConstantsArgs = {
  filter: NetworkConstantsFilter;
};


export type MutationDeleteNftMetadataArgs = {
  filter: NftMetadataFilter;
};


export type MutationDeleteNftMetadataFileArgs = {
  filter: NftMetadataFileFilter;
};


export type MutationDeletePlutusScriptArgs = {
  filter: PlutusScriptFilter;
};


export type MutationDeletePolicyArgs = {
  filter: PolicyFilter;
};


export type MutationDeletePoolContactDataArgs = {
  filter: PoolContactDataFilter;
};


export type MutationDeletePoolParametersArgs = {
  filter: PoolParametersFilter;
};


export type MutationDeletePoolRegistrationCertificateArgs = {
  filter: PoolRegistrationCertificateFilter;
};


export type MutationDeletePoolRetirementCertificateArgs = {
  filter: PoolRetirementCertificateFilter;
};


export type MutationDeleteProtocolParametersAlonzoArgs = {
  filter: ProtocolParametersAlonzoFilter;
};


export type MutationDeleteProtocolParametersShelleyArgs = {
  filter: ProtocolParametersShelleyFilter;
};


export type MutationDeleteProtocolVersionArgs = {
  filter: ProtocolVersionFilter;
};


export type MutationDeletePublicKeyArgs = {
  filter: PublicKeyFilter;
};


export type MutationDeleteRatioArgs = {
  filter: RatioFilter;
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


export type MutationDeleteRewardArgs = {
  filter: RewardFilter;
};


export type MutationDeleteRewardAccountArgs = {
  filter: RewardAccountFilter;
};


export type MutationDeleteSignatureArgs = {
  filter: SignatureFilter;
};


export type MutationDeleteSlotArgs = {
  filter: SlotFilter;
};


export type MutationDeleteStakeDelegationCertificateArgs = {
  filter: StakeDelegationCertificateFilter;
};


export type MutationDeleteStakeKeyDeregistrationCertificateArgs = {
  filter: StakeKeyDeregistrationCertificateFilter;
};


export type MutationDeleteStakeKeyRegistrationCertificateArgs = {
  filter: StakeKeyRegistrationCertificateFilter;
};


export type MutationDeleteStakePoolArgs = {
  filter: StakePoolFilter;
};


export type MutationDeleteStakePoolEpochRewardsArgs = {
  filter: StakePoolEpochRewardsFilter;
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


export type MutationDeleteStringMetadatumArgs = {
  filter: StringMetadatumFilter;
};


export type MutationDeleteThePoolsMediaAssetsArgs = {
  filter: ThePoolsMediaAssetsFilter;
};


export type MutationDeleteTimeSettingsArgs = {
  filter: TimeSettingsFilter;
};


export type MutationDeleteTokenArgs = {
  filter: TokenFilter;
};


export type MutationDeleteTokenMetadataArgs = {
  filter: TokenMetadataFilter;
};


export type MutationDeleteTokenMetadataSizedIconArgs = {
  filter: TokenMetadataSizedIconFilter;
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


export type MutationDeleteWitnessArgs = {
  filter: WitnessFilter;
};


export type MutationDeleteWitnessScriptArgs = {
  filter: WitnessScriptFilter;
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


export type MutationUpdateAssetArgs = {
  input: UpdateAssetInput;
};


export type MutationUpdateAssetMintOrBurnArgs = {
  input: UpdateAssetMintOrBurnInput;
};


export type MutationUpdateAuxiliaryDataArgs = {
  input: UpdateAuxiliaryDataInput;
};


export type MutationUpdateAuxiliaryDataBodyArgs = {
  input: UpdateAuxiliaryDataBodyInput;
};


export type MutationUpdateAuxiliaryScriptArgs = {
  input: UpdateAuxiliaryScriptInput;
};


export type MutationUpdateBlockArgs = {
  input: UpdateBlockInput;
};


export type MutationUpdateBootstrapWitnessArgs = {
  input: UpdateBootstrapWitnessInput;
};


export type MutationUpdateBytesMetadatumArgs = {
  input: UpdateBytesMetadatumInput;
};


export type MutationUpdateCoinSupplyArgs = {
  input: UpdateCoinSupplyInput;
};


export type MutationUpdateCostModelArgs = {
  input: UpdateCostModelInput;
};


export type MutationUpdateCostModelCoefficientArgs = {
  input: UpdateCostModelCoefficientInput;
};


export type MutationUpdateDatumArgs = {
  input: UpdateDatumInput;
};


export type MutationUpdateEpochArgs = {
  input: UpdateEpochInput;
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


export type MutationUpdateGenesisKeyDelegationCertificateArgs = {
  input: UpdateGenesisKeyDelegationCertificateInput;
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


export type MutationUpdateMirCertificateArgs = {
  input: UpdateMirCertificateInput;
};


export type MutationUpdateNOfArgs = {
  input: UpdateNOfInput;
};


export type MutationUpdateNativeScriptArgs = {
  input: UpdateNativeScriptInput;
};


export type MutationUpdateNetworkConstantsArgs = {
  input: UpdateNetworkConstantsInput;
};


export type MutationUpdateNftMetadataArgs = {
  input: UpdateNftMetadataInput;
};


export type MutationUpdateNftMetadataFileArgs = {
  input: UpdateNftMetadataFileInput;
};


export type MutationUpdatePlutusScriptArgs = {
  input: UpdatePlutusScriptInput;
};


export type MutationUpdatePolicyArgs = {
  input: UpdatePolicyInput;
};


export type MutationUpdatePoolContactDataArgs = {
  input: UpdatePoolContactDataInput;
};


export type MutationUpdatePoolParametersArgs = {
  input: UpdatePoolParametersInput;
};


export type MutationUpdatePoolRegistrationCertificateArgs = {
  input: UpdatePoolRegistrationCertificateInput;
};


export type MutationUpdatePoolRetirementCertificateArgs = {
  input: UpdatePoolRetirementCertificateInput;
};


export type MutationUpdateProtocolParametersAlonzoArgs = {
  input: UpdateProtocolParametersAlonzoInput;
};


export type MutationUpdateProtocolParametersShelleyArgs = {
  input: UpdateProtocolParametersShelleyInput;
};


export type MutationUpdateProtocolVersionArgs = {
  input: UpdateProtocolVersionInput;
};


export type MutationUpdatePublicKeyArgs = {
  input: UpdatePublicKeyInput;
};


export type MutationUpdateRatioArgs = {
  input: UpdateRatioInput;
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


export type MutationUpdateRewardArgs = {
  input: UpdateRewardInput;
};


export type MutationUpdateRewardAccountArgs = {
  input: UpdateRewardAccountInput;
};


export type MutationUpdateSignatureArgs = {
  input: UpdateSignatureInput;
};


export type MutationUpdateSlotArgs = {
  input: UpdateSlotInput;
};


export type MutationUpdateStakeDelegationCertificateArgs = {
  input: UpdateStakeDelegationCertificateInput;
};


export type MutationUpdateStakeKeyDeregistrationCertificateArgs = {
  input: UpdateStakeKeyDeregistrationCertificateInput;
};


export type MutationUpdateStakeKeyRegistrationCertificateArgs = {
  input: UpdateStakeKeyRegistrationCertificateInput;
};


export type MutationUpdateStakePoolArgs = {
  input: UpdateStakePoolInput;
};


export type MutationUpdateStakePoolEpochRewardsArgs = {
  input: UpdateStakePoolEpochRewardsInput;
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


export type MutationUpdateStringMetadatumArgs = {
  input: UpdateStringMetadatumInput;
};


export type MutationUpdateThePoolsMediaAssetsArgs = {
  input: UpdateThePoolsMediaAssetsInput;
};


export type MutationUpdateTimeSettingsArgs = {
  input: UpdateTimeSettingsInput;
};


export type MutationUpdateTokenArgs = {
  input: UpdateTokenInput;
};


export type MutationUpdateTokenMetadataArgs = {
  input: UpdateTokenMetadataInput;
};


export type MutationUpdateTokenMetadataSizedIconArgs = {
  input: UpdateTokenMetadataSizedIconInput;
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


export type MutationUpdateWitnessArgs = {
  input: UpdateWitnessInput;
};


export type MutationUpdateWitnessScriptArgs = {
  input: UpdateWitnessScriptInput;
};

export type NOf = {
  __typename?: 'NOf';
  key: Scalars['String'];
  scripts: Array<NativeScript>;
  scriptsAggregate?: Maybe<NativeScriptAggregateResult>;
};


export type NOfScriptsArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type NOfScriptsAggregateArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
};

export type NOfAggregateResult = {
  __typename?: 'NOfAggregateResult';
  count?: Maybe<Scalars['Int']>;
  keyMax?: Maybe<Scalars['String']>;
  keyMin?: Maybe<Scalars['String']>;
};

export type NOfFilter = {
  and?: InputMaybe<Array<InputMaybe<NOfFilter>>>;
  has?: InputMaybe<Array<InputMaybe<NOfHasFilter>>>;
  not?: InputMaybe<NOfFilter>;
  or?: InputMaybe<Array<InputMaybe<NOfFilter>>>;
};

export enum NOfHasFilter {
  Key = 'key',
  Scripts = 'scripts'
}

export type NOfOrder = {
  asc?: InputMaybe<NOfOrderable>;
  desc?: InputMaybe<NOfOrderable>;
  then?: InputMaybe<NOfOrder>;
};

export enum NOfOrderable {
  Key = 'key'
}

export type NOfPatch = {
  key?: InputMaybe<Scalars['String']>;
  scripts?: InputMaybe<Array<NativeScriptRef>>;
};

export type NOfRef = {
  key?: InputMaybe<Scalars['String']>;
  scripts?: InputMaybe<Array<NativeScriptRef>>;
};

/** Exactly one field is not null */
export type NativeScript = {
  __typename?: 'NativeScript';
  all?: Maybe<Array<NativeScript>>;
  allAggregate?: Maybe<NativeScriptAggregateResult>;
  any?: Maybe<Array<NativeScript>>;
  anyAggregate?: Maybe<NativeScriptAggregateResult>;
  expiresAt?: Maybe<Slot>;
  nof?: Maybe<Array<NOf>>;
  nofAggregate?: Maybe<NOfAggregateResult>;
  startsAt?: Maybe<Slot>;
  vkey?: Maybe<PublicKey>;
};


/** Exactly one field is not null */
export type NativeScriptAllArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


/** Exactly one field is not null */
export type NativeScriptAllAggregateArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
};


/** Exactly one field is not null */
export type NativeScriptAnyArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


/** Exactly one field is not null */
export type NativeScriptAnyAggregateArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
};


/** Exactly one field is not null */
export type NativeScriptExpiresAtArgs = {
  filter?: InputMaybe<SlotFilter>;
};


/** Exactly one field is not null */
export type NativeScriptNofArgs = {
  filter?: InputMaybe<NOfFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NOfOrder>;
};


/** Exactly one field is not null */
export type NativeScriptNofAggregateArgs = {
  filter?: InputMaybe<NOfFilter>;
};


/** Exactly one field is not null */
export type NativeScriptStartsAtArgs = {
  filter?: InputMaybe<SlotFilter>;
};


/** Exactly one field is not null */
export type NativeScriptVkeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};

export type NativeScriptAggregateResult = {
  __typename?: 'NativeScriptAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type NativeScriptFilter = {
  and?: InputMaybe<Array<InputMaybe<NativeScriptFilter>>>;
  has?: InputMaybe<Array<InputMaybe<NativeScriptHasFilter>>>;
  not?: InputMaybe<NativeScriptFilter>;
  or?: InputMaybe<Array<InputMaybe<NativeScriptFilter>>>;
};

export enum NativeScriptHasFilter {
  All = 'all',
  Any = 'any',
  ExpiresAt = 'expiresAt',
  Nof = 'nof',
  StartsAt = 'startsAt',
  Vkey = 'vkey'
}

export type NativeScriptPatch = {
  all?: InputMaybe<Array<NativeScriptRef>>;
  any?: InputMaybe<Array<NativeScriptRef>>;
  expiresAt?: InputMaybe<SlotRef>;
  nof?: InputMaybe<Array<NOfRef>>;
  startsAt?: InputMaybe<SlotRef>;
  vkey?: InputMaybe<PublicKeyRef>;
};

export type NativeScriptRef = {
  all?: InputMaybe<Array<NativeScriptRef>>;
  any?: InputMaybe<Array<NativeScriptRef>>;
  expiresAt?: InputMaybe<SlotRef>;
  nof?: InputMaybe<Array<NOfRef>>;
  startsAt?: InputMaybe<SlotRef>;
  vkey?: InputMaybe<PublicKeyRef>;
};

export type NearFilter = {
  coordinate: PointRef;
  distance: Scalars['Float'];
};

export type NetworkConstants = {
  __typename?: 'NetworkConstants';
  activeSlotsCoefficient: Scalars['Float'];
  maxKESEvolutions: Scalars['Int'];
  networkMagic: Scalars['Int'];
  securityParameter: Scalars['Int'];
  slotsPerKESPeriod: Scalars['Int'];
  systemStart: Scalars['DateTime'];
  /** same as 'systemStart' */
  timestamp: Scalars['Int'];
  updateQuorum: Scalars['Int'];
};

export type NetworkConstantsAggregateResult = {
  __typename?: 'NetworkConstantsAggregateResult';
  activeSlotsCoefficientAvg?: Maybe<Scalars['Float']>;
  activeSlotsCoefficientMax?: Maybe<Scalars['Float']>;
  activeSlotsCoefficientMin?: Maybe<Scalars['Float']>;
  activeSlotsCoefficientSum?: Maybe<Scalars['Float']>;
  count?: Maybe<Scalars['Int']>;
  maxKESEvolutionsAvg?: Maybe<Scalars['Float']>;
  maxKESEvolutionsMax?: Maybe<Scalars['Int']>;
  maxKESEvolutionsMin?: Maybe<Scalars['Int']>;
  maxKESEvolutionsSum?: Maybe<Scalars['Int']>;
  networkMagicAvg?: Maybe<Scalars['Float']>;
  networkMagicMax?: Maybe<Scalars['Int']>;
  networkMagicMin?: Maybe<Scalars['Int']>;
  networkMagicSum?: Maybe<Scalars['Int']>;
  securityParameterAvg?: Maybe<Scalars['Float']>;
  securityParameterMax?: Maybe<Scalars['Int']>;
  securityParameterMin?: Maybe<Scalars['Int']>;
  securityParameterSum?: Maybe<Scalars['Int']>;
  slotsPerKESPeriodAvg?: Maybe<Scalars['Float']>;
  slotsPerKESPeriodMax?: Maybe<Scalars['Int']>;
  slotsPerKESPeriodMin?: Maybe<Scalars['Int']>;
  slotsPerKESPeriodSum?: Maybe<Scalars['Int']>;
  systemStartMax?: Maybe<Scalars['DateTime']>;
  systemStartMin?: Maybe<Scalars['DateTime']>;
  timestampAvg?: Maybe<Scalars['Float']>;
  timestampMax?: Maybe<Scalars['Int']>;
  timestampMin?: Maybe<Scalars['Int']>;
  timestampSum?: Maybe<Scalars['Int']>;
  updateQuorumAvg?: Maybe<Scalars['Float']>;
  updateQuorumMax?: Maybe<Scalars['Int']>;
  updateQuorumMin?: Maybe<Scalars['Int']>;
  updateQuorumSum?: Maybe<Scalars['Int']>;
};

export type NetworkConstantsFilter = {
  and?: InputMaybe<Array<InputMaybe<NetworkConstantsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<NetworkConstantsHasFilter>>>;
  not?: InputMaybe<NetworkConstantsFilter>;
  or?: InputMaybe<Array<InputMaybe<NetworkConstantsFilter>>>;
};

export enum NetworkConstantsHasFilter {
  ActiveSlotsCoefficient = 'activeSlotsCoefficient',
  MaxKesEvolutions = 'maxKESEvolutions',
  NetworkMagic = 'networkMagic',
  SecurityParameter = 'securityParameter',
  SlotsPerKesPeriod = 'slotsPerKESPeriod',
  SystemStart = 'systemStart',
  Timestamp = 'timestamp',
  UpdateQuorum = 'updateQuorum'
}

export type NetworkConstantsOrder = {
  asc?: InputMaybe<NetworkConstantsOrderable>;
  desc?: InputMaybe<NetworkConstantsOrderable>;
  then?: InputMaybe<NetworkConstantsOrder>;
};

export enum NetworkConstantsOrderable {
  ActiveSlotsCoefficient = 'activeSlotsCoefficient',
  MaxKesEvolutions = 'maxKESEvolutions',
  NetworkMagic = 'networkMagic',
  SecurityParameter = 'securityParameter',
  SlotsPerKesPeriod = 'slotsPerKESPeriod',
  SystemStart = 'systemStart',
  Timestamp = 'timestamp',
  UpdateQuorum = 'updateQuorum'
}

export type NetworkConstantsPatch = {
  activeSlotsCoefficient?: InputMaybe<Scalars['Float']>;
  maxKESEvolutions?: InputMaybe<Scalars['Int']>;
  networkMagic?: InputMaybe<Scalars['Int']>;
  securityParameter?: InputMaybe<Scalars['Int']>;
  slotsPerKESPeriod?: InputMaybe<Scalars['Int']>;
  systemStart?: InputMaybe<Scalars['DateTime']>;
  /** same as 'systemStart' */
  timestamp?: InputMaybe<Scalars['Int']>;
  updateQuorum?: InputMaybe<Scalars['Int']>;
};

export type NetworkConstantsRef = {
  activeSlotsCoefficient?: InputMaybe<Scalars['Float']>;
  maxKESEvolutions?: InputMaybe<Scalars['Int']>;
  networkMagic?: InputMaybe<Scalars['Int']>;
  securityParameter?: InputMaybe<Scalars['Int']>;
  slotsPerKESPeriod?: InputMaybe<Scalars['Int']>;
  systemStart?: InputMaybe<Scalars['DateTime']>;
  /** same as 'systemStart' */
  timestamp?: InputMaybe<Scalars['Int']>;
  updateQuorum?: InputMaybe<Scalars['Int']>;
};

/** CIP-0025 */
export type NftMetadata = {
  __typename?: 'NftMetadata';
  asset: Asset;
  descriptions: Array<Scalars['String']>;
  files: Array<NftMetadataFile>;
  filesAggregate?: Maybe<NftMetadataFileAggregateResult>;
  images: Array<Scalars['String']>;
  mediaType?: Maybe<Scalars['String']>;
  name: Scalars['String'];
  version: Scalars['String'];
};


/** CIP-0025 */
export type NftMetadataAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
};


/** CIP-0025 */
export type NftMetadataFilesArgs = {
  filter?: InputMaybe<NftMetadataFileFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataFileOrder>;
};


/** CIP-0025 */
export type NftMetadataFilesAggregateArgs = {
  filter?: InputMaybe<NftMetadataFileFilter>;
};

export type NftMetadataAggregateResult = {
  __typename?: 'NftMetadataAggregateResult';
  count?: Maybe<Scalars['Int']>;
  mediaTypeMax?: Maybe<Scalars['String']>;
  mediaTypeMin?: Maybe<Scalars['String']>;
  nameMax?: Maybe<Scalars['String']>;
  nameMin?: Maybe<Scalars['String']>;
  versionMax?: Maybe<Scalars['String']>;
  versionMin?: Maybe<Scalars['String']>;
};

export type NftMetadataFile = {
  __typename?: 'NftMetadataFile';
  mediaType: Scalars['String'];
  name: Scalars['String'];
  src: Array<Scalars['String']>;
};

export type NftMetadataFileAggregateResult = {
  __typename?: 'NftMetadataFileAggregateResult';
  count?: Maybe<Scalars['Int']>;
  mediaTypeMax?: Maybe<Scalars['String']>;
  mediaTypeMin?: Maybe<Scalars['String']>;
  nameMax?: Maybe<Scalars['String']>;
  nameMin?: Maybe<Scalars['String']>;
};

export type NftMetadataFileFilter = {
  and?: InputMaybe<Array<InputMaybe<NftMetadataFileFilter>>>;
  has?: InputMaybe<Array<InputMaybe<NftMetadataFileHasFilter>>>;
  not?: InputMaybe<NftMetadataFileFilter>;
  or?: InputMaybe<Array<InputMaybe<NftMetadataFileFilter>>>;
};

export enum NftMetadataFileHasFilter {
  MediaType = 'mediaType',
  Name = 'name',
  Src = 'src'
}

export type NftMetadataFileOrder = {
  asc?: InputMaybe<NftMetadataFileOrderable>;
  desc?: InputMaybe<NftMetadataFileOrderable>;
  then?: InputMaybe<NftMetadataFileOrder>;
};

export enum NftMetadataFileOrderable {
  MediaType = 'mediaType',
  Name = 'name'
}

export type NftMetadataFilePatch = {
  mediaType?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  src?: InputMaybe<Array<Scalars['String']>>;
};

export type NftMetadataFileRef = {
  mediaType?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  src?: InputMaybe<Array<Scalars['String']>>;
};

export type NftMetadataFilter = {
  and?: InputMaybe<Array<InputMaybe<NftMetadataFilter>>>;
  has?: InputMaybe<Array<InputMaybe<NftMetadataHasFilter>>>;
  not?: InputMaybe<NftMetadataFilter>;
  or?: InputMaybe<Array<InputMaybe<NftMetadataFilter>>>;
};

export enum NftMetadataHasFilter {
  Asset = 'asset',
  Descriptions = 'descriptions',
  Files = 'files',
  Images = 'images',
  MediaType = 'mediaType',
  Name = 'name',
  Version = 'version'
}

export type NftMetadataOrder = {
  asc?: InputMaybe<NftMetadataOrderable>;
  desc?: InputMaybe<NftMetadataOrderable>;
  then?: InputMaybe<NftMetadataOrder>;
};

export enum NftMetadataOrderable {
  MediaType = 'mediaType',
  Name = 'name',
  Version = 'version'
}

export type NftMetadataPatch = {
  asset?: InputMaybe<AssetRef>;
  descriptions?: InputMaybe<Array<Scalars['String']>>;
  files?: InputMaybe<Array<NftMetadataFileRef>>;
  images?: InputMaybe<Array<Scalars['String']>>;
  mediaType?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  version?: InputMaybe<Scalars['String']>;
};

export type NftMetadataRef = {
  asset?: InputMaybe<AssetRef>;
  descriptions?: InputMaybe<Array<Scalars['String']>>;
  files?: InputMaybe<Array<NftMetadataFileRef>>;
  images?: InputMaybe<Array<Scalars['String']>>;
  mediaType?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  version?: InputMaybe<Scalars['String']>;
};

export type PlutusScript = {
  __typename?: 'PlutusScript';
  /** Serialized plutus-core program */
  cborHex: Scalars['String'];
  description: Scalars['String'];
  hash: Scalars['String'];
  /** 'PlutusScriptV1' | 'PlutusScriptV2' */
  type: Scalars['String'];
};

export type PlutusScriptAggregateResult = {
  __typename?: 'PlutusScriptAggregateResult';
  cborHexMax?: Maybe<Scalars['String']>;
  cborHexMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  descriptionMax?: Maybe<Scalars['String']>;
  descriptionMin?: Maybe<Scalars['String']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
  typeMax?: Maybe<Scalars['String']>;
  typeMin?: Maybe<Scalars['String']>;
};

export type PlutusScriptFilter = {
  and?: InputMaybe<Array<InputMaybe<PlutusScriptFilter>>>;
  has?: InputMaybe<Array<InputMaybe<PlutusScriptHasFilter>>>;
  hash?: InputMaybe<StringHashFilter>;
  not?: InputMaybe<PlutusScriptFilter>;
  or?: InputMaybe<Array<InputMaybe<PlutusScriptFilter>>>;
};

export enum PlutusScriptHasFilter {
  CborHex = 'cborHex',
  Description = 'description',
  Hash = 'hash',
  Type = 'type'
}

export type PlutusScriptOrder = {
  asc?: InputMaybe<PlutusScriptOrderable>;
  desc?: InputMaybe<PlutusScriptOrderable>;
  then?: InputMaybe<PlutusScriptOrder>;
};

export enum PlutusScriptOrderable {
  CborHex = 'cborHex',
  Description = 'description',
  Hash = 'hash',
  Type = 'type'
}

export type PlutusScriptPatch = {
  /** Serialized plutus-core program */
  cborHex?: InputMaybe<Scalars['String']>;
  description?: InputMaybe<Scalars['String']>;
  /** 'PlutusScriptV1' | 'PlutusScriptV2' */
  type?: InputMaybe<Scalars['String']>;
};

export type PlutusScriptRef = {
  /** Serialized plutus-core program */
  cborHex?: InputMaybe<Scalars['String']>;
  description?: InputMaybe<Scalars['String']>;
  hash?: InputMaybe<Scalars['String']>;
  /** 'PlutusScriptV1' | 'PlutusScriptV2' */
  type?: InputMaybe<Scalars['String']>;
};

export type Point = {
  __typename?: 'Point';
  latitude: Scalars['Float'];
  longitude: Scalars['Float'];
};

export type PointGeoFilter = {
  near?: InputMaybe<NearFilter>;
  within?: InputMaybe<WithinFilter>;
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

export type Policy = {
  __typename?: 'Policy';
  assets: Array<Asset>;
  assetsAggregate?: Maybe<AssetAggregateResult>;
  id: Scalars['String'];
  publicKey: PublicKey;
  script: Script;
};


export type PolicyAssetsArgs = {
  filter?: InputMaybe<AssetFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetOrder>;
};


export type PolicyAssetsAggregateArgs = {
  filter?: InputMaybe<AssetFilter>;
};


export type PolicyPublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};


export type PolicyScriptArgs = {
  filter?: InputMaybe<ScriptFilter>;
};

export type PolicyAggregateResult = {
  __typename?: 'PolicyAggregateResult';
  count?: Maybe<Scalars['Int']>;
  idMax?: Maybe<Scalars['String']>;
  idMin?: Maybe<Scalars['String']>;
};

export type PolicyFilter = {
  and?: InputMaybe<Array<InputMaybe<PolicyFilter>>>;
  has?: InputMaybe<Array<InputMaybe<PolicyHasFilter>>>;
  id?: InputMaybe<StringHashFilter>;
  not?: InputMaybe<PolicyFilter>;
  or?: InputMaybe<Array<InputMaybe<PolicyFilter>>>;
};

export enum PolicyHasFilter {
  Assets = 'assets',
  Id = 'id',
  PublicKey = 'publicKey',
  Script = 'script'
}

export type PolicyOrder = {
  asc?: InputMaybe<PolicyOrderable>;
  desc?: InputMaybe<PolicyOrderable>;
  then?: InputMaybe<PolicyOrder>;
};

export enum PolicyOrderable {
  Id = 'id'
}

export type PolicyPatch = {
  assets?: InputMaybe<Array<AssetRef>>;
  publicKey?: InputMaybe<PublicKeyRef>;
  script?: InputMaybe<ScriptRef>;
};

export type PolicyRef = {
  assets?: InputMaybe<Array<AssetRef>>;
  id?: InputMaybe<Scalars['String']>;
  publicKey?: InputMaybe<PublicKeyRef>;
  script?: InputMaybe<ScriptRef>;
};

export type Polygon = {
  __typename?: 'Polygon';
  coordinates: Array<PointList>;
};

export type PolygonGeoFilter = {
  contains?: InputMaybe<ContainsFilter>;
  intersects?: InputMaybe<IntersectsFilter>;
  near?: InputMaybe<NearFilter>;
  within?: InputMaybe<WithinFilter>;
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
  and?: InputMaybe<Array<InputMaybe<PoolContactDataFilter>>>;
  has?: InputMaybe<Array<InputMaybe<PoolContactDataHasFilter>>>;
  not?: InputMaybe<PoolContactDataFilter>;
  or?: InputMaybe<Array<InputMaybe<PoolContactDataFilter>>>;
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
  asc?: InputMaybe<PoolContactDataOrderable>;
  desc?: InputMaybe<PoolContactDataOrderable>;
  then?: InputMaybe<PoolContactDataOrder>;
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
  email?: InputMaybe<Scalars['String']>;
  facebook?: InputMaybe<Scalars['String']>;
  feed?: InputMaybe<Scalars['String']>;
  github?: InputMaybe<Scalars['String']>;
  primary?: InputMaybe<Scalars['String']>;
  telegram?: InputMaybe<Scalars['String']>;
  twitter?: InputMaybe<Scalars['String']>;
};

export type PoolContactDataRef = {
  email?: InputMaybe<Scalars['String']>;
  facebook?: InputMaybe<Scalars['String']>;
  feed?: InputMaybe<Scalars['String']>;
  github?: InputMaybe<Scalars['String']>;
  primary?: InputMaybe<Scalars['String']>;
  telegram?: InputMaybe<Scalars['String']>;
  twitter?: InputMaybe<Scalars['String']>;
};

export type PoolParameters = {
  __typename?: 'PoolParameters';
  cost: Scalars['Int64'];
  margin: Ratio;
  metadata?: Maybe<StakePoolMetadata>;
  metadataJson?: Maybe<StakePoolMetadataJson>;
  owners: Array<RewardAccount>;
  ownersAggregate?: Maybe<RewardAccountAggregateResult>;
  pledge: Scalars['Int64'];
  poolId: Scalars['String'];
  poolRegistrationCertificate: PoolRegistrationCertificate;
  relays: Array<SearchResult>;
  rewardAccount: RewardAccount;
  sinceEpochNo: Scalars['Int'];
  stakePool: StakePool;
  transactionBlockNo: Scalars['Int'];
  /** hex-encoded 32 byte vrf vkey */
  vrf: Scalars['String'];
};


export type PoolParametersMarginArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type PoolParametersMetadataArgs = {
  filter?: InputMaybe<StakePoolMetadataFilter>;
};


export type PoolParametersMetadataJsonArgs = {
  filter?: InputMaybe<StakePoolMetadataJsonFilter>;
};


export type PoolParametersOwnersArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardAccountOrder>;
};


export type PoolParametersOwnersAggregateArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type PoolParametersPoolRegistrationCertificateArgs = {
  filter?: InputMaybe<PoolRegistrationCertificateFilter>;
};


export type PoolParametersRelaysArgs = {
  filter?: InputMaybe<SearchResultFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type PoolParametersRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type PoolParametersStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
};

export type PoolParametersAggregateResult = {
  __typename?: 'PoolParametersAggregateResult';
  costAvg?: Maybe<Scalars['Float']>;
  costMax?: Maybe<Scalars['Int64']>;
  costMin?: Maybe<Scalars['Int64']>;
  costSum?: Maybe<Scalars['Int64']>;
  count?: Maybe<Scalars['Int']>;
  pledgeAvg?: Maybe<Scalars['Float']>;
  pledgeMax?: Maybe<Scalars['Int64']>;
  pledgeMin?: Maybe<Scalars['Int64']>;
  pledgeSum?: Maybe<Scalars['Int64']>;
  poolIdMax?: Maybe<Scalars['String']>;
  poolIdMin?: Maybe<Scalars['String']>;
  sinceEpochNoAvg?: Maybe<Scalars['Float']>;
  sinceEpochNoMax?: Maybe<Scalars['Int']>;
  sinceEpochNoMin?: Maybe<Scalars['Int']>;
  sinceEpochNoSum?: Maybe<Scalars['Int']>;
  transactionBlockNoAvg?: Maybe<Scalars['Float']>;
  transactionBlockNoMax?: Maybe<Scalars['Int']>;
  transactionBlockNoMin?: Maybe<Scalars['Int']>;
  transactionBlockNoSum?: Maybe<Scalars['Int']>;
  vrfMax?: Maybe<Scalars['String']>;
  vrfMin?: Maybe<Scalars['String']>;
};

export type PoolParametersFilter = {
  and?: InputMaybe<Array<InputMaybe<PoolParametersFilter>>>;
  has?: InputMaybe<Array<InputMaybe<PoolParametersHasFilter>>>;
  not?: InputMaybe<PoolParametersFilter>;
  or?: InputMaybe<Array<InputMaybe<PoolParametersFilter>>>;
};

export enum PoolParametersHasFilter {
  Cost = 'cost',
  Margin = 'margin',
  Metadata = 'metadata',
  MetadataJson = 'metadataJson',
  Owners = 'owners',
  Pledge = 'pledge',
  PoolId = 'poolId',
  PoolRegistrationCertificate = 'poolRegistrationCertificate',
  Relays = 'relays',
  RewardAccount = 'rewardAccount',
  SinceEpochNo = 'sinceEpochNo',
  StakePool = 'stakePool',
  TransactionBlockNo = 'transactionBlockNo',
  Vrf = 'vrf'
}

export type PoolParametersOrder = {
  asc?: InputMaybe<PoolParametersOrderable>;
  desc?: InputMaybe<PoolParametersOrderable>;
  then?: InputMaybe<PoolParametersOrder>;
};

export enum PoolParametersOrderable {
  Cost = 'cost',
  Pledge = 'pledge',
  PoolId = 'poolId',
  SinceEpochNo = 'sinceEpochNo',
  TransactionBlockNo = 'transactionBlockNo',
  Vrf = 'vrf'
}

export type PoolParametersPatch = {
  cost?: InputMaybe<Scalars['Int64']>;
  margin?: InputMaybe<RatioRef>;
  metadata?: InputMaybe<StakePoolMetadataRef>;
  metadataJson?: InputMaybe<StakePoolMetadataJsonRef>;
  owners?: InputMaybe<Array<RewardAccountRef>>;
  pledge?: InputMaybe<Scalars['Int64']>;
  poolId?: InputMaybe<Scalars['String']>;
  poolRegistrationCertificate?: InputMaybe<PoolRegistrationCertificateRef>;
  relays?: InputMaybe<Array<SearchResultRef>>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  sinceEpochNo?: InputMaybe<Scalars['Int']>;
  stakePool?: InputMaybe<StakePoolRef>;
  transactionBlockNo?: InputMaybe<Scalars['Int']>;
  /** hex-encoded 32 byte vrf vkey */
  vrf?: InputMaybe<Scalars['String']>;
};

export type PoolParametersRef = {
  cost?: InputMaybe<Scalars['Int64']>;
  margin?: InputMaybe<RatioRef>;
  metadata?: InputMaybe<StakePoolMetadataRef>;
  metadataJson?: InputMaybe<StakePoolMetadataJsonRef>;
  owners?: InputMaybe<Array<RewardAccountRef>>;
  pledge?: InputMaybe<Scalars['Int64']>;
  poolId?: InputMaybe<Scalars['String']>;
  poolRegistrationCertificate?: InputMaybe<PoolRegistrationCertificateRef>;
  relays?: InputMaybe<Array<SearchResultRef>>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  sinceEpochNo?: InputMaybe<Scalars['Int']>;
  stakePool?: InputMaybe<StakePoolRef>;
  transactionBlockNo?: InputMaybe<Scalars['Int']>;
  /** hex-encoded 32 byte vrf vkey */
  vrf?: InputMaybe<Scalars['String']>;
};

export type PoolRegistrationCertificate = {
  __typename?: 'PoolRegistrationCertificate';
  epoch: Epoch;
  poolParameters: PoolParameters;
  transaction: Transaction;
};


export type PoolRegistrationCertificateEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type PoolRegistrationCertificatePoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
};


export type PoolRegistrationCertificateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type PoolRegistrationCertificateAggregateResult = {
  __typename?: 'PoolRegistrationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type PoolRegistrationCertificateFilter = {
  and?: InputMaybe<Array<InputMaybe<PoolRegistrationCertificateFilter>>>;
  has?: InputMaybe<Array<InputMaybe<PoolRegistrationCertificateHasFilter>>>;
  not?: InputMaybe<PoolRegistrationCertificateFilter>;
  or?: InputMaybe<Array<InputMaybe<PoolRegistrationCertificateFilter>>>;
};

export enum PoolRegistrationCertificateHasFilter {
  Epoch = 'epoch',
  PoolParameters = 'poolParameters',
  Transaction = 'transaction'
}

export type PoolRegistrationCertificatePatch = {
  epoch?: InputMaybe<EpochRef>;
  poolParameters?: InputMaybe<PoolParametersRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type PoolRegistrationCertificateRef = {
  epoch?: InputMaybe<EpochRef>;
  poolParameters?: InputMaybe<PoolParametersRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type PoolRetirementCertificate = {
  __typename?: 'PoolRetirementCertificate';
  epoch: Epoch;
  stakePool: StakePool;
  transaction: Transaction;
};


export type PoolRetirementCertificateEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type PoolRetirementCertificateStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
};


export type PoolRetirementCertificateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type PoolRetirementCertificateAggregateResult = {
  __typename?: 'PoolRetirementCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type PoolRetirementCertificateFilter = {
  and?: InputMaybe<Array<InputMaybe<PoolRetirementCertificateFilter>>>;
  has?: InputMaybe<Array<InputMaybe<PoolRetirementCertificateHasFilter>>>;
  not?: InputMaybe<PoolRetirementCertificateFilter>;
  or?: InputMaybe<Array<InputMaybe<PoolRetirementCertificateFilter>>>;
};

export enum PoolRetirementCertificateHasFilter {
  Epoch = 'epoch',
  StakePool = 'stakePool',
  Transaction = 'transaction'
}

export type PoolRetirementCertificatePatch = {
  epoch?: InputMaybe<EpochRef>;
  stakePool?: InputMaybe<StakePoolRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type PoolRetirementCertificateRef = {
  epoch?: InputMaybe<EpochRef>;
  stakePool?: InputMaybe<StakePoolRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type ProtocolParameters = ProtocolParametersAlonzo | ProtocolParametersShelley;

export type ProtocolParametersAlonzo = {
  __typename?: 'ProtocolParametersAlonzo';
  coinsPerUtxoWord: Scalars['Int'];
  collateralPercentage: Scalars['Int'];
  costModels: Array<CostModel>;
  costModelsAggregate?: Maybe<CostModelAggregateResult>;
  /** d. decentralization constant */
  decentralizationParameter: Ratio;
  /** n_opt */
  desiredNumberOfPools: Scalars['Int'];
  executionPrices: ExecutionPrices;
  /** hex-encoded, null if neutral */
  extraEntropy?: Maybe<Scalars['String']>;
  maxBlockBodySize: Scalars['Int'];
  maxBlockHeaderSize: Scalars['Int'];
  maxCollateralInputs: Scalars['Int'];
  maxExecutionUnitsPerBlock: ExecutionUnits;
  maxExecutionUnitsPerTransaction: ExecutionUnits;
  maxTxSize: Scalars['Int'];
  maxValueSize: Scalars['Int'];
  /** minfee A */
  minFeeCoefficient: Scalars['Int'];
  /** minfee B */
  minFeeConstant: Scalars['Int'];
  minPoolCost: Scalars['Int'];
  minUtxoValue: Scalars['Int'];
  /** expansion rate */
  monetaryExpansion: Ratio;
  poolDeposit: Scalars['Int'];
  /** pool pledge influence */
  poolInfluence: Ratio;
  /** maximum epoch */
  poolRetirementEpochBound: Epoch;
  protocolVersion: ProtocolVersion;
  stakeKeyDeposit: Scalars['Int'];
  /** treasury growth rate */
  treasuryExpansion: Ratio;
};


export type ProtocolParametersAlonzoCostModelsArgs = {
  filter?: InputMaybe<CostModelFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelOrder>;
};


export type ProtocolParametersAlonzoCostModelsAggregateArgs = {
  filter?: InputMaybe<CostModelFilter>;
};


export type ProtocolParametersAlonzoDecentralizationParameterArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type ProtocolParametersAlonzoExecutionPricesArgs = {
  filter?: InputMaybe<ExecutionPricesFilter>;
};


export type ProtocolParametersAlonzoMaxExecutionUnitsPerBlockArgs = {
  filter?: InputMaybe<ExecutionUnitsFilter>;
};


export type ProtocolParametersAlonzoMaxExecutionUnitsPerTransactionArgs = {
  filter?: InputMaybe<ExecutionUnitsFilter>;
};


export type ProtocolParametersAlonzoMonetaryExpansionArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type ProtocolParametersAlonzoPoolInfluenceArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type ProtocolParametersAlonzoPoolRetirementEpochBoundArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type ProtocolParametersAlonzoProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
};


export type ProtocolParametersAlonzoTreasuryExpansionArgs = {
  filter?: InputMaybe<RatioFilter>;
};

export type ProtocolParametersAlonzoAggregateResult = {
  __typename?: 'ProtocolParametersAlonzoAggregateResult';
  coinsPerUtxoWordAvg?: Maybe<Scalars['Float']>;
  coinsPerUtxoWordMax?: Maybe<Scalars['Int']>;
  coinsPerUtxoWordMin?: Maybe<Scalars['Int']>;
  coinsPerUtxoWordSum?: Maybe<Scalars['Int']>;
  collateralPercentageAvg?: Maybe<Scalars['Float']>;
  collateralPercentageMax?: Maybe<Scalars['Int']>;
  collateralPercentageMin?: Maybe<Scalars['Int']>;
  collateralPercentageSum?: Maybe<Scalars['Int']>;
  count?: Maybe<Scalars['Int']>;
  desiredNumberOfPoolsAvg?: Maybe<Scalars['Float']>;
  desiredNumberOfPoolsMax?: Maybe<Scalars['Int']>;
  desiredNumberOfPoolsMin?: Maybe<Scalars['Int']>;
  desiredNumberOfPoolsSum?: Maybe<Scalars['Int']>;
  extraEntropyMax?: Maybe<Scalars['String']>;
  extraEntropyMin?: Maybe<Scalars['String']>;
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
  maxValueSizeAvg?: Maybe<Scalars['Float']>;
  maxValueSizeMax?: Maybe<Scalars['Int']>;
  maxValueSizeMin?: Maybe<Scalars['Int']>;
  maxValueSizeSum?: Maybe<Scalars['Int']>;
  minFeeCoefficientAvg?: Maybe<Scalars['Float']>;
  minFeeCoefficientMax?: Maybe<Scalars['Int']>;
  minFeeCoefficientMin?: Maybe<Scalars['Int']>;
  minFeeCoefficientSum?: Maybe<Scalars['Int']>;
  minFeeConstantAvg?: Maybe<Scalars['Float']>;
  minFeeConstantMax?: Maybe<Scalars['Int']>;
  minFeeConstantMin?: Maybe<Scalars['Int']>;
  minFeeConstantSum?: Maybe<Scalars['Int']>;
  minPoolCostAvg?: Maybe<Scalars['Float']>;
  minPoolCostMax?: Maybe<Scalars['Int']>;
  minPoolCostMin?: Maybe<Scalars['Int']>;
  minPoolCostSum?: Maybe<Scalars['Int']>;
  minUtxoValueAvg?: Maybe<Scalars['Float']>;
  minUtxoValueMax?: Maybe<Scalars['Int']>;
  minUtxoValueMin?: Maybe<Scalars['Int']>;
  minUtxoValueSum?: Maybe<Scalars['Int']>;
  poolDepositAvg?: Maybe<Scalars['Float']>;
  poolDepositMax?: Maybe<Scalars['Int']>;
  poolDepositMin?: Maybe<Scalars['Int']>;
  poolDepositSum?: Maybe<Scalars['Int']>;
  stakeKeyDepositAvg?: Maybe<Scalars['Float']>;
  stakeKeyDepositMax?: Maybe<Scalars['Int']>;
  stakeKeyDepositMin?: Maybe<Scalars['Int']>;
  stakeKeyDepositSum?: Maybe<Scalars['Int']>;
};

export type ProtocolParametersAlonzoFilter = {
  and?: InputMaybe<Array<InputMaybe<ProtocolParametersAlonzoFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ProtocolParametersAlonzoHasFilter>>>;
  not?: InputMaybe<ProtocolParametersAlonzoFilter>;
  or?: InputMaybe<Array<InputMaybe<ProtocolParametersAlonzoFilter>>>;
};

export enum ProtocolParametersAlonzoHasFilter {
  CoinsPerUtxoWord = 'coinsPerUtxoWord',
  CollateralPercentage = 'collateralPercentage',
  CostModels = 'costModels',
  DecentralizationParameter = 'decentralizationParameter',
  DesiredNumberOfPools = 'desiredNumberOfPools',
  ExecutionPrices = 'executionPrices',
  ExtraEntropy = 'extraEntropy',
  MaxBlockBodySize = 'maxBlockBodySize',
  MaxBlockHeaderSize = 'maxBlockHeaderSize',
  MaxCollateralInputs = 'maxCollateralInputs',
  MaxExecutionUnitsPerBlock = 'maxExecutionUnitsPerBlock',
  MaxExecutionUnitsPerTransaction = 'maxExecutionUnitsPerTransaction',
  MaxTxSize = 'maxTxSize',
  MaxValueSize = 'maxValueSize',
  MinFeeCoefficient = 'minFeeCoefficient',
  MinFeeConstant = 'minFeeConstant',
  MinPoolCost = 'minPoolCost',
  MinUtxoValue = 'minUtxoValue',
  MonetaryExpansion = 'monetaryExpansion',
  PoolDeposit = 'poolDeposit',
  PoolInfluence = 'poolInfluence',
  PoolRetirementEpochBound = 'poolRetirementEpochBound',
  ProtocolVersion = 'protocolVersion',
  StakeKeyDeposit = 'stakeKeyDeposit',
  TreasuryExpansion = 'treasuryExpansion'
}

export type ProtocolParametersAlonzoOrder = {
  asc?: InputMaybe<ProtocolParametersAlonzoOrderable>;
  desc?: InputMaybe<ProtocolParametersAlonzoOrderable>;
  then?: InputMaybe<ProtocolParametersAlonzoOrder>;
};

export enum ProtocolParametersAlonzoOrderable {
  CoinsPerUtxoWord = 'coinsPerUtxoWord',
  CollateralPercentage = 'collateralPercentage',
  DesiredNumberOfPools = 'desiredNumberOfPools',
  ExtraEntropy = 'extraEntropy',
  MaxBlockBodySize = 'maxBlockBodySize',
  MaxBlockHeaderSize = 'maxBlockHeaderSize',
  MaxCollateralInputs = 'maxCollateralInputs',
  MaxTxSize = 'maxTxSize',
  MaxValueSize = 'maxValueSize',
  MinFeeCoefficient = 'minFeeCoefficient',
  MinFeeConstant = 'minFeeConstant',
  MinPoolCost = 'minPoolCost',
  MinUtxoValue = 'minUtxoValue',
  PoolDeposit = 'poolDeposit',
  StakeKeyDeposit = 'stakeKeyDeposit'
}

export type ProtocolParametersAlonzoPatch = {
  coinsPerUtxoWord?: InputMaybe<Scalars['Int']>;
  collateralPercentage?: InputMaybe<Scalars['Int']>;
  costModels?: InputMaybe<Array<CostModelRef>>;
  decentralizationParameter?: InputMaybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: InputMaybe<Scalars['Int']>;
  executionPrices?: InputMaybe<ExecutionPricesRef>;
  /** hex-encoded, null if neutral */
  extraEntropy?: InputMaybe<Scalars['String']>;
  maxBlockBodySize?: InputMaybe<Scalars['Int']>;
  maxBlockHeaderSize?: InputMaybe<Scalars['Int']>;
  maxCollateralInputs?: InputMaybe<Scalars['Int']>;
  maxExecutionUnitsPerBlock?: InputMaybe<ExecutionUnitsRef>;
  maxExecutionUnitsPerTransaction?: InputMaybe<ExecutionUnitsRef>;
  maxTxSize?: InputMaybe<Scalars['Int']>;
  maxValueSize?: InputMaybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: InputMaybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: InputMaybe<Scalars['Int']>;
  minPoolCost?: InputMaybe<Scalars['Int']>;
  minUtxoValue?: InputMaybe<Scalars['Int']>;
  monetaryExpansion?: InputMaybe<RatioRef>;
  poolDeposit?: InputMaybe<Scalars['Int']>;
  poolInfluence?: InputMaybe<RatioRef>;
  poolRetirementEpochBound?: InputMaybe<EpochRef>;
  protocolVersion?: InputMaybe<ProtocolVersionRef>;
  stakeKeyDeposit?: InputMaybe<Scalars['Int']>;
  treasuryExpansion?: InputMaybe<RatioRef>;
};

export type ProtocolParametersAlonzoRef = {
  coinsPerUtxoWord?: InputMaybe<Scalars['Int']>;
  collateralPercentage?: InputMaybe<Scalars['Int']>;
  costModels?: InputMaybe<Array<CostModelRef>>;
  decentralizationParameter?: InputMaybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: InputMaybe<Scalars['Int']>;
  executionPrices?: InputMaybe<ExecutionPricesRef>;
  /** hex-encoded, null if neutral */
  extraEntropy?: InputMaybe<Scalars['String']>;
  maxBlockBodySize?: InputMaybe<Scalars['Int']>;
  maxBlockHeaderSize?: InputMaybe<Scalars['Int']>;
  maxCollateralInputs?: InputMaybe<Scalars['Int']>;
  maxExecutionUnitsPerBlock?: InputMaybe<ExecutionUnitsRef>;
  maxExecutionUnitsPerTransaction?: InputMaybe<ExecutionUnitsRef>;
  maxTxSize?: InputMaybe<Scalars['Int']>;
  maxValueSize?: InputMaybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: InputMaybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: InputMaybe<Scalars['Int']>;
  minPoolCost?: InputMaybe<Scalars['Int']>;
  minUtxoValue?: InputMaybe<Scalars['Int']>;
  monetaryExpansion?: InputMaybe<RatioRef>;
  poolDeposit?: InputMaybe<Scalars['Int']>;
  poolInfluence?: InputMaybe<RatioRef>;
  poolRetirementEpochBound?: InputMaybe<EpochRef>;
  protocolVersion?: InputMaybe<ProtocolVersionRef>;
  stakeKeyDeposit?: InputMaybe<Scalars['Int']>;
  treasuryExpansion?: InputMaybe<RatioRef>;
};

export type ProtocolParametersFilter = {
  memberTypes?: InputMaybe<Array<ProtocolParametersType>>;
  protocolParametersAlonzoFilter?: InputMaybe<ProtocolParametersAlonzoFilter>;
  protocolParametersShelleyFilter?: InputMaybe<ProtocolParametersShelleyFilter>;
};

export type ProtocolParametersRef = {
  protocolParametersAlonzoRef?: InputMaybe<ProtocolParametersAlonzoRef>;
  protocolParametersShelleyRef?: InputMaybe<ProtocolParametersShelleyRef>;
};

export type ProtocolParametersShelley = {
  __typename?: 'ProtocolParametersShelley';
  /** d. decentralization constant */
  decentralizationParameter: Ratio;
  /** n_opt */
  desiredNumberOfPools: Scalars['Int'];
  /** hex-encoded, null if neutral */
  extraEntropy?: Maybe<Scalars['String']>;
  maxBlockBodySize: Scalars['Int'];
  maxBlockHeaderSize: Scalars['Int'];
  maxTxSize: Scalars['Int'];
  /** minfee A */
  minFeeCoefficient: Scalars['Int'];
  /** minfee B */
  minFeeConstant: Scalars['Int'];
  minUtxoValue: Scalars['Int'];
  /** expansion rate */
  monetaryExpansion: Ratio;
  poolDeposit: Scalars['Int'];
  /** pool pledge influence */
  poolInfluence: Ratio;
  /** maximum epoch */
  poolRetirementEpochBound: Epoch;
  protocolVersion: ProtocolVersion;
  stakeKeyDeposit: Scalars['Int'];
  /** treasury growth rate */
  treasuryExpansion: Ratio;
};


export type ProtocolParametersShelleyDecentralizationParameterArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type ProtocolParametersShelleyMonetaryExpansionArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type ProtocolParametersShelleyPoolInfluenceArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type ProtocolParametersShelleyPoolRetirementEpochBoundArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type ProtocolParametersShelleyProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
};


export type ProtocolParametersShelleyTreasuryExpansionArgs = {
  filter?: InputMaybe<RatioFilter>;
};

export type ProtocolParametersShelleyAggregateResult = {
  __typename?: 'ProtocolParametersShelleyAggregateResult';
  count?: Maybe<Scalars['Int']>;
  desiredNumberOfPoolsAvg?: Maybe<Scalars['Float']>;
  desiredNumberOfPoolsMax?: Maybe<Scalars['Int']>;
  desiredNumberOfPoolsMin?: Maybe<Scalars['Int']>;
  desiredNumberOfPoolsSum?: Maybe<Scalars['Int']>;
  extraEntropyMax?: Maybe<Scalars['String']>;
  extraEntropyMin?: Maybe<Scalars['String']>;
  maxBlockBodySizeAvg?: Maybe<Scalars['Float']>;
  maxBlockBodySizeMax?: Maybe<Scalars['Int']>;
  maxBlockBodySizeMin?: Maybe<Scalars['Int']>;
  maxBlockBodySizeSum?: Maybe<Scalars['Int']>;
  maxBlockHeaderSizeAvg?: Maybe<Scalars['Float']>;
  maxBlockHeaderSizeMax?: Maybe<Scalars['Int']>;
  maxBlockHeaderSizeMin?: Maybe<Scalars['Int']>;
  maxBlockHeaderSizeSum?: Maybe<Scalars['Int']>;
  maxTxSizeAvg?: Maybe<Scalars['Float']>;
  maxTxSizeMax?: Maybe<Scalars['Int']>;
  maxTxSizeMin?: Maybe<Scalars['Int']>;
  maxTxSizeSum?: Maybe<Scalars['Int']>;
  minFeeCoefficientAvg?: Maybe<Scalars['Float']>;
  minFeeCoefficientMax?: Maybe<Scalars['Int']>;
  minFeeCoefficientMin?: Maybe<Scalars['Int']>;
  minFeeCoefficientSum?: Maybe<Scalars['Int']>;
  minFeeConstantAvg?: Maybe<Scalars['Float']>;
  minFeeConstantMax?: Maybe<Scalars['Int']>;
  minFeeConstantMin?: Maybe<Scalars['Int']>;
  minFeeConstantSum?: Maybe<Scalars['Int']>;
  minUtxoValueAvg?: Maybe<Scalars['Float']>;
  minUtxoValueMax?: Maybe<Scalars['Int']>;
  minUtxoValueMin?: Maybe<Scalars['Int']>;
  minUtxoValueSum?: Maybe<Scalars['Int']>;
  poolDepositAvg?: Maybe<Scalars['Float']>;
  poolDepositMax?: Maybe<Scalars['Int']>;
  poolDepositMin?: Maybe<Scalars['Int']>;
  poolDepositSum?: Maybe<Scalars['Int']>;
  stakeKeyDepositAvg?: Maybe<Scalars['Float']>;
  stakeKeyDepositMax?: Maybe<Scalars['Int']>;
  stakeKeyDepositMin?: Maybe<Scalars['Int']>;
  stakeKeyDepositSum?: Maybe<Scalars['Int']>;
};

export type ProtocolParametersShelleyFilter = {
  and?: InputMaybe<Array<InputMaybe<ProtocolParametersShelleyFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ProtocolParametersShelleyHasFilter>>>;
  not?: InputMaybe<ProtocolParametersShelleyFilter>;
  or?: InputMaybe<Array<InputMaybe<ProtocolParametersShelleyFilter>>>;
};

export enum ProtocolParametersShelleyHasFilter {
  DecentralizationParameter = 'decentralizationParameter',
  DesiredNumberOfPools = 'desiredNumberOfPools',
  ExtraEntropy = 'extraEntropy',
  MaxBlockBodySize = 'maxBlockBodySize',
  MaxBlockHeaderSize = 'maxBlockHeaderSize',
  MaxTxSize = 'maxTxSize',
  MinFeeCoefficient = 'minFeeCoefficient',
  MinFeeConstant = 'minFeeConstant',
  MinUtxoValue = 'minUtxoValue',
  MonetaryExpansion = 'monetaryExpansion',
  PoolDeposit = 'poolDeposit',
  PoolInfluence = 'poolInfluence',
  PoolRetirementEpochBound = 'poolRetirementEpochBound',
  ProtocolVersion = 'protocolVersion',
  StakeKeyDeposit = 'stakeKeyDeposit',
  TreasuryExpansion = 'treasuryExpansion'
}

export type ProtocolParametersShelleyOrder = {
  asc?: InputMaybe<ProtocolParametersShelleyOrderable>;
  desc?: InputMaybe<ProtocolParametersShelleyOrderable>;
  then?: InputMaybe<ProtocolParametersShelleyOrder>;
};

export enum ProtocolParametersShelleyOrderable {
  DesiredNumberOfPools = 'desiredNumberOfPools',
  ExtraEntropy = 'extraEntropy',
  MaxBlockBodySize = 'maxBlockBodySize',
  MaxBlockHeaderSize = 'maxBlockHeaderSize',
  MaxTxSize = 'maxTxSize',
  MinFeeCoefficient = 'minFeeCoefficient',
  MinFeeConstant = 'minFeeConstant',
  MinUtxoValue = 'minUtxoValue',
  PoolDeposit = 'poolDeposit',
  StakeKeyDeposit = 'stakeKeyDeposit'
}

export type ProtocolParametersShelleyPatch = {
  decentralizationParameter?: InputMaybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: InputMaybe<Scalars['Int']>;
  /** hex-encoded, null if neutral */
  extraEntropy?: InputMaybe<Scalars['String']>;
  maxBlockBodySize?: InputMaybe<Scalars['Int']>;
  maxBlockHeaderSize?: InputMaybe<Scalars['Int']>;
  maxTxSize?: InputMaybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: InputMaybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: InputMaybe<Scalars['Int']>;
  minUtxoValue?: InputMaybe<Scalars['Int']>;
  monetaryExpansion?: InputMaybe<RatioRef>;
  poolDeposit?: InputMaybe<Scalars['Int']>;
  poolInfluence?: InputMaybe<RatioRef>;
  poolRetirementEpochBound?: InputMaybe<EpochRef>;
  protocolVersion?: InputMaybe<ProtocolVersionRef>;
  stakeKeyDeposit?: InputMaybe<Scalars['Int']>;
  treasuryExpansion?: InputMaybe<RatioRef>;
};

export type ProtocolParametersShelleyRef = {
  decentralizationParameter?: InputMaybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: InputMaybe<Scalars['Int']>;
  /** hex-encoded, null if neutral */
  extraEntropy?: InputMaybe<Scalars['String']>;
  maxBlockBodySize?: InputMaybe<Scalars['Int']>;
  maxBlockHeaderSize?: InputMaybe<Scalars['Int']>;
  maxTxSize?: InputMaybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: InputMaybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: InputMaybe<Scalars['Int']>;
  minUtxoValue?: InputMaybe<Scalars['Int']>;
  monetaryExpansion?: InputMaybe<RatioRef>;
  poolDeposit?: InputMaybe<Scalars['Int']>;
  poolInfluence?: InputMaybe<RatioRef>;
  poolRetirementEpochBound?: InputMaybe<EpochRef>;
  protocolVersion?: InputMaybe<ProtocolVersionRef>;
  stakeKeyDeposit?: InputMaybe<Scalars['Int']>;
  treasuryExpansion?: InputMaybe<RatioRef>;
};

export enum ProtocolParametersType {
  ProtocolParametersAlonzo = 'ProtocolParametersAlonzo',
  ProtocolParametersShelley = 'ProtocolParametersShelley'
}

export type ProtocolVersion = {
  __typename?: 'ProtocolVersion';
  major: Scalars['Int'];
  minor: Scalars['Int'];
  patch?: Maybe<Scalars['Int']>;
  protocolParameters: ProtocolParameters;
};


export type ProtocolVersionProtocolParametersArgs = {
  filter?: InputMaybe<ProtocolParametersFilter>;
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
  and?: InputMaybe<Array<InputMaybe<ProtocolVersionFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ProtocolVersionHasFilter>>>;
  not?: InputMaybe<ProtocolVersionFilter>;
  or?: InputMaybe<Array<InputMaybe<ProtocolVersionFilter>>>;
};

export enum ProtocolVersionHasFilter {
  Major = 'major',
  Minor = 'minor',
  Patch = 'patch',
  ProtocolParameters = 'protocolParameters'
}

export type ProtocolVersionOrder = {
  asc?: InputMaybe<ProtocolVersionOrderable>;
  desc?: InputMaybe<ProtocolVersionOrderable>;
  then?: InputMaybe<ProtocolVersionOrder>;
};

export enum ProtocolVersionOrderable {
  Major = 'major',
  Minor = 'minor',
  Patch = 'patch'
}

export type ProtocolVersionPatch = {
  major?: InputMaybe<Scalars['Int']>;
  minor?: InputMaybe<Scalars['Int']>;
  patch?: InputMaybe<Scalars['Int']>;
  protocolParameters?: InputMaybe<ProtocolParametersRef>;
};

export type ProtocolVersionRef = {
  major?: InputMaybe<Scalars['Int']>;
  minor?: InputMaybe<Scalars['Int']>;
  patch?: InputMaybe<Scalars['Int']>;
  protocolParameters?: InputMaybe<ProtocolParametersRef>;
};

export type PublicKey = {
  __typename?: 'PublicKey';
  addresses?: Maybe<Array<Address>>;
  addressesAggregate?: Maybe<AddressAggregateResult>;
  /** hex-encoded Ed25519 public key hash */
  hash: Scalars['String'];
  /** hex-encoded Ed25519 public key */
  key: Scalars['String'];
  policies?: Maybe<Array<Policy>>;
  policiesAggregate?: Maybe<PolicyAggregateResult>;
  requiredExtraSignatureInTransactions?: Maybe<Array<Transaction>>;
  requiredExtraSignatureInTransactionsAggregate?: Maybe<TransactionAggregateResult>;
  rewardAccount?: Maybe<RewardAccount>;
  signatures: Array<Signature>;
  signaturesAggregate?: Maybe<SignatureAggregateResult>;
};


export type PublicKeyAddressesArgs = {
  filter?: InputMaybe<AddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AddressOrder>;
};


export type PublicKeyAddressesAggregateArgs = {
  filter?: InputMaybe<AddressFilter>;
};


export type PublicKeyPoliciesArgs = {
  filter?: InputMaybe<PolicyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PolicyOrder>;
};


export type PublicKeyPoliciesAggregateArgs = {
  filter?: InputMaybe<PolicyFilter>;
};


export type PublicKeyRequiredExtraSignatureInTransactionsArgs = {
  filter?: InputMaybe<TransactionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOrder>;
};


export type PublicKeyRequiredExtraSignatureInTransactionsAggregateArgs = {
  filter?: InputMaybe<TransactionFilter>;
};


export type PublicKeyRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type PublicKeySignaturesArgs = {
  filter?: InputMaybe<SignatureFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SignatureOrder>;
};


export type PublicKeySignaturesAggregateArgs = {
  filter?: InputMaybe<SignatureFilter>;
};

export type PublicKeyAggregateResult = {
  __typename?: 'PublicKeyAggregateResult';
  count?: Maybe<Scalars['Int']>;
  hashMax?: Maybe<Scalars['String']>;
  hashMin?: Maybe<Scalars['String']>;
  keyMax?: Maybe<Scalars['String']>;
  keyMin?: Maybe<Scalars['String']>;
};

export type PublicKeyFilter = {
  and?: InputMaybe<Array<InputMaybe<PublicKeyFilter>>>;
  has?: InputMaybe<Array<InputMaybe<PublicKeyHasFilter>>>;
  hash?: InputMaybe<StringHashFilter>;
  not?: InputMaybe<PublicKeyFilter>;
  or?: InputMaybe<Array<InputMaybe<PublicKeyFilter>>>;
};

export enum PublicKeyHasFilter {
  Addresses = 'addresses',
  Hash = 'hash',
  Key = 'key',
  Policies = 'policies',
  RequiredExtraSignatureInTransactions = 'requiredExtraSignatureInTransactions',
  RewardAccount = 'rewardAccount',
  Signatures = 'signatures'
}

export type PublicKeyOrder = {
  asc?: InputMaybe<PublicKeyOrderable>;
  desc?: InputMaybe<PublicKeyOrderable>;
  then?: InputMaybe<PublicKeyOrder>;
};

export enum PublicKeyOrderable {
  Hash = 'hash',
  Key = 'key'
}

export type PublicKeyPatch = {
  addresses?: InputMaybe<Array<AddressRef>>;
  /** hex-encoded Ed25519 public key */
  key?: InputMaybe<Scalars['String']>;
  policies?: InputMaybe<Array<PolicyRef>>;
  requiredExtraSignatureInTransactions?: InputMaybe<Array<TransactionRef>>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  signatures?: InputMaybe<Array<SignatureRef>>;
};

export type PublicKeyRef = {
  addresses?: InputMaybe<Array<AddressRef>>;
  /** hex-encoded Ed25519 public key hash */
  hash?: InputMaybe<Scalars['String']>;
  /** hex-encoded Ed25519 public key */
  key?: InputMaybe<Scalars['String']>;
  policies?: InputMaybe<Array<PolicyRef>>;
  requiredExtraSignatureInTransactions?: InputMaybe<Array<TransactionRef>>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  signatures?: InputMaybe<Array<SignatureRef>>;
};

export type Query = {
  __typename?: 'Query';
  aggregateActiveStake?: Maybe<ActiveStakeAggregateResult>;
  aggregateAda?: Maybe<AdaAggregateResult>;
  aggregateAdaPots?: Maybe<AdaPotsAggregateResult>;
  aggregateAddress?: Maybe<AddressAggregateResult>;
  aggregateAsset?: Maybe<AssetAggregateResult>;
  aggregateAssetMintOrBurn?: Maybe<AssetMintOrBurnAggregateResult>;
  aggregateAuxiliaryData?: Maybe<AuxiliaryDataAggregateResult>;
  aggregateAuxiliaryDataBody?: Maybe<AuxiliaryDataBodyAggregateResult>;
  aggregateAuxiliaryScript?: Maybe<AuxiliaryScriptAggregateResult>;
  aggregateBlock?: Maybe<BlockAggregateResult>;
  aggregateBootstrapWitness?: Maybe<BootstrapWitnessAggregateResult>;
  aggregateBytesMetadatum?: Maybe<BytesMetadatumAggregateResult>;
  aggregateCoinSupply?: Maybe<CoinSupplyAggregateResult>;
  aggregateCostModel?: Maybe<CostModelAggregateResult>;
  aggregateCostModelCoefficient?: Maybe<CostModelCoefficientAggregateResult>;
  aggregateDatum?: Maybe<DatumAggregateResult>;
  aggregateEpoch?: Maybe<EpochAggregateResult>;
  aggregateExecutionPrices?: Maybe<ExecutionPricesAggregateResult>;
  aggregateExecutionUnits?: Maybe<ExecutionUnitsAggregateResult>;
  aggregateExtendedStakePoolMetadata?: Maybe<ExtendedStakePoolMetadataAggregateResult>;
  aggregateExtendedStakePoolMetadataFields?: Maybe<ExtendedStakePoolMetadataFieldsAggregateResult>;
  aggregateGenesisKeyDelegationCertificate?: Maybe<GenesisKeyDelegationCertificateAggregateResult>;
  aggregateITNVerification?: Maybe<ItnVerificationAggregateResult>;
  aggregateIntegerMetadatum?: Maybe<IntegerMetadatumAggregateResult>;
  aggregateKeyValueMetadatum?: Maybe<KeyValueMetadatumAggregateResult>;
  aggregateMetadatumArray?: Maybe<MetadatumArrayAggregateResult>;
  aggregateMetadatumMap?: Maybe<MetadatumMapAggregateResult>;
  aggregateMirCertificate?: Maybe<MirCertificateAggregateResult>;
  aggregateNOf?: Maybe<NOfAggregateResult>;
  aggregateNativeScript?: Maybe<NativeScriptAggregateResult>;
  aggregateNetworkConstants?: Maybe<NetworkConstantsAggregateResult>;
  aggregateNftMetadata?: Maybe<NftMetadataAggregateResult>;
  aggregateNftMetadataFile?: Maybe<NftMetadataFileAggregateResult>;
  aggregatePlutusScript?: Maybe<PlutusScriptAggregateResult>;
  aggregatePolicy?: Maybe<PolicyAggregateResult>;
  aggregatePoolContactData?: Maybe<PoolContactDataAggregateResult>;
  aggregatePoolParameters?: Maybe<PoolParametersAggregateResult>;
  aggregatePoolRegistrationCertificate?: Maybe<PoolRegistrationCertificateAggregateResult>;
  aggregatePoolRetirementCertificate?: Maybe<PoolRetirementCertificateAggregateResult>;
  aggregateProtocolParametersAlonzo?: Maybe<ProtocolParametersAlonzoAggregateResult>;
  aggregateProtocolParametersShelley?: Maybe<ProtocolParametersShelleyAggregateResult>;
  aggregateProtocolVersion?: Maybe<ProtocolVersionAggregateResult>;
  aggregatePublicKey?: Maybe<PublicKeyAggregateResult>;
  aggregateRatio?: Maybe<RatioAggregateResult>;
  aggregateRedeemer?: Maybe<RedeemerAggregateResult>;
  aggregateRelayByAddress?: Maybe<RelayByAddressAggregateResult>;
  aggregateRelayByName?: Maybe<RelayByNameAggregateResult>;
  aggregateRelayByNameMultihost?: Maybe<RelayByNameMultihostAggregateResult>;
  aggregateReward?: Maybe<RewardAggregateResult>;
  aggregateRewardAccount?: Maybe<RewardAccountAggregateResult>;
  aggregateSignature?: Maybe<SignatureAggregateResult>;
  aggregateSlot?: Maybe<SlotAggregateResult>;
  aggregateStakeDelegationCertificate?: Maybe<StakeDelegationCertificateAggregateResult>;
  aggregateStakeKeyDeregistrationCertificate?: Maybe<StakeKeyDeregistrationCertificateAggregateResult>;
  aggregateStakeKeyRegistrationCertificate?: Maybe<StakeKeyRegistrationCertificateAggregateResult>;
  aggregateStakePool?: Maybe<StakePoolAggregateResult>;
  aggregateStakePoolEpochRewards?: Maybe<StakePoolEpochRewardsAggregateResult>;
  aggregateStakePoolMetadata?: Maybe<StakePoolMetadataAggregateResult>;
  aggregateStakePoolMetadataJson?: Maybe<StakePoolMetadataJsonAggregateResult>;
  aggregateStakePoolMetrics?: Maybe<StakePoolMetricsAggregateResult>;
  aggregateStakePoolMetricsSize?: Maybe<StakePoolMetricsSizeAggregateResult>;
  aggregateStakePoolMetricsStake?: Maybe<StakePoolMetricsStakeAggregateResult>;
  aggregateStringMetadatum?: Maybe<StringMetadatumAggregateResult>;
  aggregateThePoolsMediaAssets?: Maybe<ThePoolsMediaAssetsAggregateResult>;
  aggregateTimeSettings?: Maybe<TimeSettingsAggregateResult>;
  aggregateToken?: Maybe<TokenAggregateResult>;
  aggregateTokenMetadata?: Maybe<TokenMetadataAggregateResult>;
  aggregateTokenMetadataSizedIcon?: Maybe<TokenMetadataSizedIconAggregateResult>;
  aggregateTransaction?: Maybe<TransactionAggregateResult>;
  aggregateTransactionInput?: Maybe<TransactionInputAggregateResult>;
  aggregateTransactionOutput?: Maybe<TransactionOutputAggregateResult>;
  aggregateValue?: Maybe<ValueAggregateResult>;
  aggregateWithdrawal?: Maybe<WithdrawalAggregateResult>;
  aggregateWitness?: Maybe<WitnessAggregateResult>;
  aggregateWitnessScript?: Maybe<WitnessScriptAggregateResult>;
  getAddress?: Maybe<Address>;
  getAsset?: Maybe<Asset>;
  getBlock?: Maybe<Block>;
  getDatum?: Maybe<Datum>;
  getEpoch?: Maybe<Epoch>;
  getExtendedStakePoolMetadataFields?: Maybe<ExtendedStakePoolMetadataFields>;
  getPlutusScript?: Maybe<PlutusScript>;
  getPolicy?: Maybe<Policy>;
  getPublicKey?: Maybe<PublicKey>;
  getRewardAccount?: Maybe<RewardAccount>;
  getSlot?: Maybe<Slot>;
  getStakePool?: Maybe<StakePool>;
  getTransaction?: Maybe<Transaction>;
  queryActiveStake?: Maybe<Array<Maybe<ActiveStake>>>;
  queryAda?: Maybe<Array<Maybe<Ada>>>;
  queryAdaPots?: Maybe<Array<Maybe<AdaPots>>>;
  queryAddress?: Maybe<Array<Maybe<Address>>>;
  queryAsset?: Maybe<Array<Maybe<Asset>>>;
  queryAssetMintOrBurn?: Maybe<Array<Maybe<AssetMintOrBurn>>>;
  queryAuxiliaryData?: Maybe<Array<Maybe<AuxiliaryData>>>;
  queryAuxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  queryAuxiliaryScript?: Maybe<Array<Maybe<AuxiliaryScript>>>;
  queryBlock?: Maybe<Array<Maybe<Block>>>;
  queryBootstrapWitness?: Maybe<Array<Maybe<BootstrapWitness>>>;
  queryBytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  queryCoinSupply?: Maybe<Array<Maybe<CoinSupply>>>;
  queryCostModel?: Maybe<Array<Maybe<CostModel>>>;
  queryCostModelCoefficient?: Maybe<Array<Maybe<CostModelCoefficient>>>;
  queryDatum?: Maybe<Array<Maybe<Datum>>>;
  queryEpoch?: Maybe<Array<Maybe<Epoch>>>;
  queryExecutionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  queryExecutionUnits?: Maybe<Array<Maybe<ExecutionUnits>>>;
  queryExtendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  queryExtendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  queryGenesisKeyDelegationCertificate?: Maybe<Array<Maybe<GenesisKeyDelegationCertificate>>>;
  queryITNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  queryIntegerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  queryKeyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  queryMetadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  queryMetadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  queryMirCertificate?: Maybe<Array<Maybe<MirCertificate>>>;
  queryNOf?: Maybe<Array<Maybe<NOf>>>;
  queryNativeScript?: Maybe<Array<Maybe<NativeScript>>>;
  queryNetworkConstants?: Maybe<Array<Maybe<NetworkConstants>>>;
  queryNftMetadata?: Maybe<Array<Maybe<NftMetadata>>>;
  queryNftMetadataFile?: Maybe<Array<Maybe<NftMetadataFile>>>;
  queryPlutusScript?: Maybe<Array<Maybe<PlutusScript>>>;
  queryPolicy?: Maybe<Array<Maybe<Policy>>>;
  queryPoolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
  queryPoolParameters?: Maybe<Array<Maybe<PoolParameters>>>;
  queryPoolRegistrationCertificate?: Maybe<Array<Maybe<PoolRegistrationCertificate>>>;
  queryPoolRetirementCertificate?: Maybe<Array<Maybe<PoolRetirementCertificate>>>;
  queryProtocolParametersAlonzo?: Maybe<Array<Maybe<ProtocolParametersAlonzo>>>;
  queryProtocolParametersShelley?: Maybe<Array<Maybe<ProtocolParametersShelley>>>;
  queryProtocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
  queryPublicKey?: Maybe<Array<Maybe<PublicKey>>>;
  queryRatio?: Maybe<Array<Maybe<Ratio>>>;
  queryRedeemer?: Maybe<Array<Maybe<Redeemer>>>;
  queryRelayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
  queryRelayByName?: Maybe<Array<Maybe<RelayByName>>>;
  queryRelayByNameMultihost?: Maybe<Array<Maybe<RelayByNameMultihost>>>;
  queryReward?: Maybe<Array<Maybe<Reward>>>;
  queryRewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
  querySignature?: Maybe<Array<Maybe<Signature>>>;
  querySlot?: Maybe<Array<Maybe<Slot>>>;
  queryStakeDelegationCertificate?: Maybe<Array<Maybe<StakeDelegationCertificate>>>;
  queryStakeKeyDeregistrationCertificate?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificate>>>;
  queryStakeKeyRegistrationCertificate?: Maybe<Array<Maybe<StakeKeyRegistrationCertificate>>>;
  queryStakePool?: Maybe<Array<Maybe<StakePool>>>;
  queryStakePoolEpochRewards?: Maybe<Array<Maybe<StakePoolEpochRewards>>>;
  queryStakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
  queryStakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
  queryStakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
  queryStakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
  queryStakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
  queryStringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
  queryThePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
  queryTimeSettings?: Maybe<Array<Maybe<TimeSettings>>>;
  queryToken?: Maybe<Array<Maybe<Token>>>;
  queryTokenMetadata?: Maybe<Array<Maybe<TokenMetadata>>>;
  queryTokenMetadataSizedIcon?: Maybe<Array<Maybe<TokenMetadataSizedIcon>>>;
  queryTransaction?: Maybe<Array<Maybe<Transaction>>>;
  queryTransactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
  queryTransactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
  queryValue?: Maybe<Array<Maybe<Value>>>;
  queryWithdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
  queryWitness?: Maybe<Array<Maybe<Witness>>>;
  queryWitnessScript?: Maybe<Array<Maybe<WitnessScript>>>;
};


export type QueryAggregateActiveStakeArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
};


export type QueryAggregateAdaArgs = {
  filter?: InputMaybe<AdaFilter>;
};


export type QueryAggregateAdaPotsArgs = {
  filter?: InputMaybe<AdaPotsFilter>;
};


export type QueryAggregateAddressArgs = {
  filter?: InputMaybe<AddressFilter>;
};


export type QueryAggregateAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
};


export type QueryAggregateAssetMintOrBurnArgs = {
  filter?: InputMaybe<AssetMintOrBurnFilter>;
};


export type QueryAggregateAuxiliaryDataArgs = {
  filter?: InputMaybe<AuxiliaryDataFilter>;
};


export type QueryAggregateAuxiliaryDataBodyArgs = {
  filter?: InputMaybe<AuxiliaryDataBodyFilter>;
};


export type QueryAggregateAuxiliaryScriptArgs = {
  filter?: InputMaybe<AuxiliaryScriptFilter>;
};


export type QueryAggregateBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
};


export type QueryAggregateBootstrapWitnessArgs = {
  filter?: InputMaybe<BootstrapWitnessFilter>;
};


export type QueryAggregateBytesMetadatumArgs = {
  filter?: InputMaybe<BytesMetadatumFilter>;
};


export type QueryAggregateCoinSupplyArgs = {
  filter?: InputMaybe<CoinSupplyFilter>;
};


export type QueryAggregateCostModelArgs = {
  filter?: InputMaybe<CostModelFilter>;
};


export type QueryAggregateCostModelCoefficientArgs = {
  filter?: InputMaybe<CostModelCoefficientFilter>;
};


export type QueryAggregateDatumArgs = {
  filter?: InputMaybe<DatumFilter>;
};


export type QueryAggregateEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type QueryAggregateExecutionPricesArgs = {
  filter?: InputMaybe<ExecutionPricesFilter>;
};


export type QueryAggregateExecutionUnitsArgs = {
  filter?: InputMaybe<ExecutionUnitsFilter>;
};


export type QueryAggregateExtendedStakePoolMetadataArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFilter>;
};


export type QueryAggregateExtendedStakePoolMetadataFieldsArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFieldsFilter>;
};


export type QueryAggregateGenesisKeyDelegationCertificateArgs = {
  filter?: InputMaybe<GenesisKeyDelegationCertificateFilter>;
};


export type QueryAggregateItnVerificationArgs = {
  filter?: InputMaybe<ItnVerificationFilter>;
};


export type QueryAggregateIntegerMetadatumArgs = {
  filter?: InputMaybe<IntegerMetadatumFilter>;
};


export type QueryAggregateKeyValueMetadatumArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
};


export type QueryAggregateMetadatumArrayArgs = {
  filter?: InputMaybe<MetadatumArrayFilter>;
};


export type QueryAggregateMetadatumMapArgs = {
  filter?: InputMaybe<MetadatumMapFilter>;
};


export type QueryAggregateMirCertificateArgs = {
  filter?: InputMaybe<MirCertificateFilter>;
};


export type QueryAggregateNOfArgs = {
  filter?: InputMaybe<NOfFilter>;
};


export type QueryAggregateNativeScriptArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
};


export type QueryAggregateNetworkConstantsArgs = {
  filter?: InputMaybe<NetworkConstantsFilter>;
};


export type QueryAggregateNftMetadataArgs = {
  filter?: InputMaybe<NftMetadataFilter>;
};


export type QueryAggregateNftMetadataFileArgs = {
  filter?: InputMaybe<NftMetadataFileFilter>;
};


export type QueryAggregatePlutusScriptArgs = {
  filter?: InputMaybe<PlutusScriptFilter>;
};


export type QueryAggregatePolicyArgs = {
  filter?: InputMaybe<PolicyFilter>;
};


export type QueryAggregatePoolContactDataArgs = {
  filter?: InputMaybe<PoolContactDataFilter>;
};


export type QueryAggregatePoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
};


export type QueryAggregatePoolRegistrationCertificateArgs = {
  filter?: InputMaybe<PoolRegistrationCertificateFilter>;
};


export type QueryAggregatePoolRetirementCertificateArgs = {
  filter?: InputMaybe<PoolRetirementCertificateFilter>;
};


export type QueryAggregateProtocolParametersAlonzoArgs = {
  filter?: InputMaybe<ProtocolParametersAlonzoFilter>;
};


export type QueryAggregateProtocolParametersShelleyArgs = {
  filter?: InputMaybe<ProtocolParametersShelleyFilter>;
};


export type QueryAggregateProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
};


export type QueryAggregatePublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};


export type QueryAggregateRatioArgs = {
  filter?: InputMaybe<RatioFilter>;
};


export type QueryAggregateRedeemerArgs = {
  filter?: InputMaybe<RedeemerFilter>;
};


export type QueryAggregateRelayByAddressArgs = {
  filter?: InputMaybe<RelayByAddressFilter>;
};


export type QueryAggregateRelayByNameArgs = {
  filter?: InputMaybe<RelayByNameFilter>;
};


export type QueryAggregateRelayByNameMultihostArgs = {
  filter?: InputMaybe<RelayByNameMultihostFilter>;
};


export type QueryAggregateRewardArgs = {
  filter?: InputMaybe<RewardFilter>;
};


export type QueryAggregateRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type QueryAggregateSignatureArgs = {
  filter?: InputMaybe<SignatureFilter>;
};


export type QueryAggregateSlotArgs = {
  filter?: InputMaybe<SlotFilter>;
};


export type QueryAggregateStakeDelegationCertificateArgs = {
  filter?: InputMaybe<StakeDelegationCertificateFilter>;
};


export type QueryAggregateStakeKeyDeregistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
};


export type QueryAggregateStakeKeyRegistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
};


export type QueryAggregateStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
};


export type QueryAggregateStakePoolEpochRewardsArgs = {
  filter?: InputMaybe<StakePoolEpochRewardsFilter>;
};


export type QueryAggregateStakePoolMetadataArgs = {
  filter?: InputMaybe<StakePoolMetadataFilter>;
};


export type QueryAggregateStakePoolMetadataJsonArgs = {
  filter?: InputMaybe<StakePoolMetadataJsonFilter>;
};


export type QueryAggregateStakePoolMetricsArgs = {
  filter?: InputMaybe<StakePoolMetricsFilter>;
};


export type QueryAggregateStakePoolMetricsSizeArgs = {
  filter?: InputMaybe<StakePoolMetricsSizeFilter>;
};


export type QueryAggregateStakePoolMetricsStakeArgs = {
  filter?: InputMaybe<StakePoolMetricsStakeFilter>;
};


export type QueryAggregateStringMetadatumArgs = {
  filter?: InputMaybe<StringMetadatumFilter>;
};


export type QueryAggregateThePoolsMediaAssetsArgs = {
  filter?: InputMaybe<ThePoolsMediaAssetsFilter>;
};


export type QueryAggregateTimeSettingsArgs = {
  filter?: InputMaybe<TimeSettingsFilter>;
};


export type QueryAggregateTokenArgs = {
  filter?: InputMaybe<TokenFilter>;
};


export type QueryAggregateTokenMetadataArgs = {
  filter?: InputMaybe<TokenMetadataFilter>;
};


export type QueryAggregateTokenMetadataSizedIconArgs = {
  filter?: InputMaybe<TokenMetadataSizedIconFilter>;
};


export type QueryAggregateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};


export type QueryAggregateTransactionInputArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
};


export type QueryAggregateTransactionOutputArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
};


export type QueryAggregateValueArgs = {
  filter?: InputMaybe<ValueFilter>;
};


export type QueryAggregateWithdrawalArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
};


export type QueryAggregateWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
};


export type QueryAggregateWitnessScriptArgs = {
  filter?: InputMaybe<WitnessScriptFilter>;
};


export type QueryGetAddressArgs = {
  address: Scalars['String'];
};


export type QueryGetAssetArgs = {
  assetId: Scalars['String'];
};


export type QueryGetBlockArgs = {
  hash: Scalars['String'];
};


export type QueryGetDatumArgs = {
  hash: Scalars['String'];
};


export type QueryGetEpochArgs = {
  number: Scalars['Int'];
};


export type QueryGetExtendedStakePoolMetadataFieldsArgs = {
  id: Scalars['String'];
};


export type QueryGetPlutusScriptArgs = {
  hash: Scalars['String'];
};


export type QueryGetPolicyArgs = {
  id: Scalars['String'];
};


export type QueryGetPublicKeyArgs = {
  hash: Scalars['String'];
};


export type QueryGetRewardAccountArgs = {
  address: Scalars['String'];
};


export type QueryGetSlotArgs = {
  number: Scalars['Int'];
};


export type QueryGetStakePoolArgs = {
  id: Scalars['String'];
};


export type QueryGetTransactionArgs = {
  hash: Scalars['String'];
};


export type QueryQueryActiveStakeArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ActiveStakeOrder>;
};


export type QueryQueryAdaArgs = {
  filter?: InputMaybe<AdaFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaOrder>;
};


export type QueryQueryAdaPotsArgs = {
  filter?: InputMaybe<AdaPotsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaPotsOrder>;
};


export type QueryQueryAddressArgs = {
  filter?: InputMaybe<AddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AddressOrder>;
};


export type QueryQueryAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetOrder>;
};


export type QueryQueryAssetMintOrBurnArgs = {
  filter?: InputMaybe<AssetMintOrBurnFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetMintOrBurnOrder>;
};


export type QueryQueryAuxiliaryDataArgs = {
  filter?: InputMaybe<AuxiliaryDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AuxiliaryDataOrder>;
};


export type QueryQueryAuxiliaryDataBodyArgs = {
  filter?: InputMaybe<AuxiliaryDataBodyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryAuxiliaryScriptArgs = {
  filter?: InputMaybe<AuxiliaryScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BlockOrder>;
};


export type QueryQueryBootstrapWitnessArgs = {
  filter?: InputMaybe<BootstrapWitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BootstrapWitnessOrder>;
};


export type QueryQueryBytesMetadatumArgs = {
  filter?: InputMaybe<BytesMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BytesMetadatumOrder>;
};


export type QueryQueryCoinSupplyArgs = {
  filter?: InputMaybe<CoinSupplyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CoinSupplyOrder>;
};


export type QueryQueryCostModelArgs = {
  filter?: InputMaybe<CostModelFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelOrder>;
};


export type QueryQueryCostModelCoefficientArgs = {
  filter?: InputMaybe<CostModelCoefficientFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelCoefficientOrder>;
};


export type QueryQueryDatumArgs = {
  filter?: InputMaybe<DatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<DatumOrder>;
};


export type QueryQueryEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<EpochOrder>;
};


export type QueryQueryExecutionPricesArgs = {
  filter?: InputMaybe<ExecutionPricesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryExecutionUnitsArgs = {
  filter?: InputMaybe<ExecutionUnitsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExecutionUnitsOrder>;
};


export type QueryQueryExtendedStakePoolMetadataArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataOrder>;
};


export type QueryQueryExtendedStakePoolMetadataFieldsArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataFieldsOrder>;
};


export type QueryQueryGenesisKeyDelegationCertificateArgs = {
  filter?: InputMaybe<GenesisKeyDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<GenesisKeyDelegationCertificateOrder>;
};


export type QueryQueryItnVerificationArgs = {
  filter?: InputMaybe<ItnVerificationFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ItnVerificationOrder>;
};


export type QueryQueryIntegerMetadatumArgs = {
  filter?: InputMaybe<IntegerMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<IntegerMetadatumOrder>;
};


export type QueryQueryKeyValueMetadatumArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<KeyValueMetadatumOrder>;
};


export type QueryQueryMetadatumArrayArgs = {
  filter?: InputMaybe<MetadatumArrayFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryMetadatumMapArgs = {
  filter?: InputMaybe<MetadatumMapFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryMirCertificateArgs = {
  filter?: InputMaybe<MirCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<MirCertificateOrder>;
};


export type QueryQueryNOfArgs = {
  filter?: InputMaybe<NOfFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NOfOrder>;
};


export type QueryQueryNativeScriptArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryNetworkConstantsArgs = {
  filter?: InputMaybe<NetworkConstantsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NetworkConstantsOrder>;
};


export type QueryQueryNftMetadataArgs = {
  filter?: InputMaybe<NftMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataOrder>;
};


export type QueryQueryNftMetadataFileArgs = {
  filter?: InputMaybe<NftMetadataFileFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataFileOrder>;
};


export type QueryQueryPlutusScriptArgs = {
  filter?: InputMaybe<PlutusScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PlutusScriptOrder>;
};


export type QueryQueryPolicyArgs = {
  filter?: InputMaybe<PolicyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PolicyOrder>;
};


export type QueryQueryPoolContactDataArgs = {
  filter?: InputMaybe<PoolContactDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolContactDataOrder>;
};


export type QueryQueryPoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolParametersOrder>;
};


export type QueryQueryPoolRegistrationCertificateArgs = {
  filter?: InputMaybe<PoolRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryPoolRetirementCertificateArgs = {
  filter?: InputMaybe<PoolRetirementCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryProtocolParametersAlonzoArgs = {
  filter?: InputMaybe<ProtocolParametersAlonzoFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersAlonzoOrder>;
};


export type QueryQueryProtocolParametersShelleyArgs = {
  filter?: InputMaybe<ProtocolParametersShelleyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersShelleyOrder>;
};


export type QueryQueryProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolVersionOrder>;
};


export type QueryQueryPublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PublicKeyOrder>;
};


export type QueryQueryRatioArgs = {
  filter?: InputMaybe<RatioFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RatioOrder>;
};


export type QueryQueryRedeemerArgs = {
  filter?: InputMaybe<RedeemerFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RedeemerOrder>;
};


export type QueryQueryRelayByAddressArgs = {
  filter?: InputMaybe<RelayByAddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByAddressOrder>;
};


export type QueryQueryRelayByNameArgs = {
  filter?: InputMaybe<RelayByNameFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameOrder>;
};


export type QueryQueryRelayByNameMultihostArgs = {
  filter?: InputMaybe<RelayByNameMultihostFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameMultihostOrder>;
};


export type QueryQueryRewardArgs = {
  filter?: InputMaybe<RewardFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardOrder>;
};


export type QueryQueryRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardAccountOrder>;
};


export type QueryQuerySignatureArgs = {
  filter?: InputMaybe<SignatureFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SignatureOrder>;
};


export type QueryQuerySlotArgs = {
  filter?: InputMaybe<SlotFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SlotOrder>;
};


export type QueryQueryStakeDelegationCertificateArgs = {
  filter?: InputMaybe<StakeDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryStakeKeyDeregistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryStakeKeyRegistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolOrder>;
};


export type QueryQueryStakePoolEpochRewardsArgs = {
  filter?: InputMaybe<StakePoolEpochRewardsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolEpochRewardsOrder>;
};


export type QueryQueryStakePoolMetadataArgs = {
  filter?: InputMaybe<StakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataOrder>;
};


export type QueryQueryStakePoolMetadataJsonArgs = {
  filter?: InputMaybe<StakePoolMetadataJsonFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataJsonOrder>;
};


export type QueryQueryStakePoolMetricsArgs = {
  filter?: InputMaybe<StakePoolMetricsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsOrder>;
};


export type QueryQueryStakePoolMetricsSizeArgs = {
  filter?: InputMaybe<StakePoolMetricsSizeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsSizeOrder>;
};


export type QueryQueryStakePoolMetricsStakeArgs = {
  filter?: InputMaybe<StakePoolMetricsStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsStakeOrder>;
};


export type QueryQueryStringMetadatumArgs = {
  filter?: InputMaybe<StringMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StringMetadatumOrder>;
};


export type QueryQueryThePoolsMediaAssetsArgs = {
  filter?: InputMaybe<ThePoolsMediaAssetsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ThePoolsMediaAssetsOrder>;
};


export type QueryQueryTimeSettingsArgs = {
  filter?: InputMaybe<TimeSettingsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TimeSettingsOrder>;
};


export type QueryQueryTokenArgs = {
  filter?: InputMaybe<TokenFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenOrder>;
};


export type QueryQueryTokenMetadataArgs = {
  filter?: InputMaybe<TokenMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataOrder>;
};


export type QueryQueryTokenMetadataSizedIconArgs = {
  filter?: InputMaybe<TokenMetadataSizedIconFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataSizedIconOrder>;
};


export type QueryQueryTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOrder>;
};


export type QueryQueryTransactionInputArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionInputOrder>;
};


export type QueryQueryTransactionOutputArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOutputOrder>;
};


export type QueryQueryValueArgs = {
  filter?: InputMaybe<ValueFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ValueOrder>;
};


export type QueryQueryWithdrawalArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WithdrawalOrder>;
};


export type QueryQueryWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type QueryQueryWitnessScriptArgs = {
  filter?: InputMaybe<WitnessScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WitnessScriptOrder>;
};

export type Ratio = {
  __typename?: 'Ratio';
  denominator: Scalars['Int'];
  numerator: Scalars['Int'];
};

export type RatioAggregateResult = {
  __typename?: 'RatioAggregateResult';
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

export type RatioFilter = {
  and?: InputMaybe<Array<InputMaybe<RatioFilter>>>;
  has?: InputMaybe<Array<InputMaybe<RatioHasFilter>>>;
  not?: InputMaybe<RatioFilter>;
  or?: InputMaybe<Array<InputMaybe<RatioFilter>>>;
};

export enum RatioHasFilter {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type RatioOrder = {
  asc?: InputMaybe<RatioOrderable>;
  desc?: InputMaybe<RatioOrderable>;
  then?: InputMaybe<RatioOrder>;
};

export enum RatioOrderable {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type RatioPatch = {
  denominator?: InputMaybe<Scalars['Int']>;
  numerator?: InputMaybe<Scalars['Int']>;
};

export type RatioRef = {
  denominator?: InputMaybe<Scalars['Int']>;
  numerator?: InputMaybe<Scalars['Int']>;
};

export type Redeemer = {
  __typename?: 'Redeemer';
  executionUnits: ExecutionUnits;
  fee: Scalars['Int64'];
  index: Scalars['Int'];
  purpose: Scalars['String'];
  scriptHash: Scalars['String'];
  witness: Witness;
};


export type RedeemerExecutionUnitsArgs = {
  filter?: InputMaybe<ExecutionUnitsFilter>;
};


export type RedeemerWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
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
  and?: InputMaybe<Array<InputMaybe<RedeemerFilter>>>;
  has?: InputMaybe<Array<InputMaybe<RedeemerHasFilter>>>;
  not?: InputMaybe<RedeemerFilter>;
  or?: InputMaybe<Array<InputMaybe<RedeemerFilter>>>;
};

export enum RedeemerHasFilter {
  ExecutionUnits = 'executionUnits',
  Fee = 'fee',
  Index = 'index',
  Purpose = 'purpose',
  ScriptHash = 'scriptHash',
  Witness = 'witness'
}

export type RedeemerOrder = {
  asc?: InputMaybe<RedeemerOrderable>;
  desc?: InputMaybe<RedeemerOrderable>;
  then?: InputMaybe<RedeemerOrder>;
};

export enum RedeemerOrderable {
  Fee = 'fee',
  Index = 'index',
  Purpose = 'purpose',
  ScriptHash = 'scriptHash'
}

export type RedeemerPatch = {
  executionUnits?: InputMaybe<ExecutionUnitsRef>;
  fee?: InputMaybe<Scalars['Int64']>;
  index?: InputMaybe<Scalars['Int']>;
  purpose?: InputMaybe<Scalars['String']>;
  scriptHash?: InputMaybe<Scalars['String']>;
  witness?: InputMaybe<WitnessRef>;
};

export type RedeemerRef = {
  executionUnits?: InputMaybe<ExecutionUnitsRef>;
  fee?: InputMaybe<Scalars['Int64']>;
  index?: InputMaybe<Scalars['Int']>;
  purpose?: InputMaybe<Scalars['String']>;
  scriptHash?: InputMaybe<Scalars['String']>;
  witness?: InputMaybe<WitnessRef>;
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
  and?: InputMaybe<Array<InputMaybe<RelayByAddressFilter>>>;
  has?: InputMaybe<Array<InputMaybe<RelayByAddressHasFilter>>>;
  not?: InputMaybe<RelayByAddressFilter>;
  or?: InputMaybe<Array<InputMaybe<RelayByAddressFilter>>>;
};

export enum RelayByAddressHasFilter {
  Ipv4 = 'ipv4',
  Ipv6 = 'ipv6',
  Port = 'port'
}

export type RelayByAddressOrder = {
  asc?: InputMaybe<RelayByAddressOrderable>;
  desc?: InputMaybe<RelayByAddressOrderable>;
  then?: InputMaybe<RelayByAddressOrder>;
};

export enum RelayByAddressOrderable {
  Ipv4 = 'ipv4',
  Ipv6 = 'ipv6',
  Port = 'port'
}

export type RelayByAddressPatch = {
  ipv4?: InputMaybe<Scalars['String']>;
  ipv6?: InputMaybe<Scalars['String']>;
  port?: InputMaybe<Scalars['Int']>;
};

export type RelayByAddressRef = {
  ipv4?: InputMaybe<Scalars['String']>;
  ipv6?: InputMaybe<Scalars['String']>;
  port?: InputMaybe<Scalars['Int']>;
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
  and?: InputMaybe<Array<InputMaybe<RelayByNameFilter>>>;
  has?: InputMaybe<Array<InputMaybe<RelayByNameHasFilter>>>;
  not?: InputMaybe<RelayByNameFilter>;
  or?: InputMaybe<Array<InputMaybe<RelayByNameFilter>>>;
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
  and?: InputMaybe<Array<InputMaybe<RelayByNameMultihostFilter>>>;
  has?: InputMaybe<Array<InputMaybe<RelayByNameMultihostHasFilter>>>;
  not?: InputMaybe<RelayByNameMultihostFilter>;
  or?: InputMaybe<Array<InputMaybe<RelayByNameMultihostFilter>>>;
};

export enum RelayByNameMultihostHasFilter {
  DnsName = 'dnsName'
}

export type RelayByNameMultihostOrder = {
  asc?: InputMaybe<RelayByNameMultihostOrderable>;
  desc?: InputMaybe<RelayByNameMultihostOrderable>;
  then?: InputMaybe<RelayByNameMultihostOrder>;
};

export enum RelayByNameMultihostOrderable {
  DnsName = 'dnsName'
}

export type RelayByNameMultihostPatch = {
  dnsName?: InputMaybe<Scalars['String']>;
};

export type RelayByNameMultihostRef = {
  dnsName?: InputMaybe<Scalars['String']>;
};

export type RelayByNameOrder = {
  asc?: InputMaybe<RelayByNameOrderable>;
  desc?: InputMaybe<RelayByNameOrderable>;
  then?: InputMaybe<RelayByNameOrder>;
};

export enum RelayByNameOrderable {
  Hostname = 'hostname',
  Port = 'port'
}

export type RelayByNamePatch = {
  hostname?: InputMaybe<Scalars['String']>;
  port?: InputMaybe<Scalars['Int']>;
};

export type RelayByNameRef = {
  hostname?: InputMaybe<Scalars['String']>;
  port?: InputMaybe<Scalars['Int']>;
};

export type Reward = {
  __typename?: 'Reward';
  epoch: Epoch;
  epochNo: Scalars['Int'];
  quantity: Scalars['Int64'];
  rewardAccount: RewardAccount;
  /** member | leader | treasury | reserves */
  source: Scalars['String'];
  spendableAtEpochNo: Scalars['Int'];
  /** null when source is 'treasury' or 'reserves' */
  stakePool?: Maybe<StakePool>;
};


export type RewardEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type RewardRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type RewardStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
};

export type RewardAccount = {
  __typename?: 'RewardAccount';
  activeStake: Array<ActiveStake>;
  activeStakeAggregate?: Maybe<ActiveStakeAggregateResult>;
  address: Scalars['String'];
  addresses: Address;
  delegationCertificates?: Maybe<Array<StakeDelegationCertificate>>;
  delegationCertificatesAggregate?: Maybe<StakeDelegationCertificateAggregateResult>;
  deregistrationCertificates?: Maybe<Array<StakeKeyDeregistrationCertificate>>;
  deregistrationCertificatesAggregate?: Maybe<StakeKeyDeregistrationCertificateAggregateResult>;
  mirCertificates?: Maybe<Array<MirCertificate>>;
  mirCertificatesAggregate?: Maybe<MirCertificateAggregateResult>;
  publicKey: PublicKey;
  registrationCertificates: Array<StakeKeyRegistrationCertificate>;
  registrationCertificatesAggregate?: Maybe<StakeKeyRegistrationCertificateAggregateResult>;
  rewards: Array<Reward>;
  rewardsAggregate?: Maybe<RewardAggregateResult>;
  withdrawals: Array<Withdrawal>;
  withdrawalsAggregate?: Maybe<WithdrawalAggregateResult>;
};


export type RewardAccountActiveStakeArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ActiveStakeOrder>;
};


export type RewardAccountActiveStakeAggregateArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
};


export type RewardAccountAddressesArgs = {
  filter?: InputMaybe<AddressFilter>;
};


export type RewardAccountDelegationCertificatesArgs = {
  filter?: InputMaybe<StakeDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type RewardAccountDelegationCertificatesAggregateArgs = {
  filter?: InputMaybe<StakeDelegationCertificateFilter>;
};


export type RewardAccountDeregistrationCertificatesArgs = {
  filter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type RewardAccountDeregistrationCertificatesAggregateArgs = {
  filter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
};


export type RewardAccountMirCertificatesArgs = {
  filter?: InputMaybe<MirCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<MirCertificateOrder>;
};


export type RewardAccountMirCertificatesAggregateArgs = {
  filter?: InputMaybe<MirCertificateFilter>;
};


export type RewardAccountPublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};


export type RewardAccountRegistrationCertificatesArgs = {
  filter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type RewardAccountRegistrationCertificatesAggregateArgs = {
  filter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
};


export type RewardAccountRewardsArgs = {
  filter?: InputMaybe<RewardFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardOrder>;
};


export type RewardAccountRewardsAggregateArgs = {
  filter?: InputMaybe<RewardFilter>;
};


export type RewardAccountWithdrawalsArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WithdrawalOrder>;
};


export type RewardAccountWithdrawalsAggregateArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
};

export type RewardAccountAggregateResult = {
  __typename?: 'RewardAccountAggregateResult';
  addressMax?: Maybe<Scalars['String']>;
  addressMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
};

export type RewardAccountFilter = {
  address?: InputMaybe<StringHashFilter>;
  and?: InputMaybe<Array<InputMaybe<RewardAccountFilter>>>;
  has?: InputMaybe<Array<InputMaybe<RewardAccountHasFilter>>>;
  not?: InputMaybe<RewardAccountFilter>;
  or?: InputMaybe<Array<InputMaybe<RewardAccountFilter>>>;
};

export enum RewardAccountHasFilter {
  ActiveStake = 'activeStake',
  Address = 'address',
  Addresses = 'addresses',
  DelegationCertificates = 'delegationCertificates',
  DeregistrationCertificates = 'deregistrationCertificates',
  MirCertificates = 'mirCertificates',
  PublicKey = 'publicKey',
  RegistrationCertificates = 'registrationCertificates',
  Rewards = 'rewards',
  Withdrawals = 'withdrawals'
}

export type RewardAccountOrder = {
  asc?: InputMaybe<RewardAccountOrderable>;
  desc?: InputMaybe<RewardAccountOrderable>;
  then?: InputMaybe<RewardAccountOrder>;
};

export enum RewardAccountOrderable {
  Address = 'address'
}

export type RewardAccountPatch = {
  activeStake?: InputMaybe<Array<ActiveStakeRef>>;
  addresses?: InputMaybe<AddressRef>;
  delegationCertificates?: InputMaybe<Array<StakeDelegationCertificateRef>>;
  deregistrationCertificates?: InputMaybe<Array<StakeKeyDeregistrationCertificateRef>>;
  mirCertificates?: InputMaybe<Array<MirCertificateRef>>;
  publicKey?: InputMaybe<PublicKeyRef>;
  registrationCertificates?: InputMaybe<Array<StakeKeyRegistrationCertificateRef>>;
  rewards?: InputMaybe<Array<RewardRef>>;
  withdrawals?: InputMaybe<Array<WithdrawalRef>>;
};

export type RewardAccountRef = {
  activeStake?: InputMaybe<Array<ActiveStakeRef>>;
  address?: InputMaybe<Scalars['String']>;
  addresses?: InputMaybe<AddressRef>;
  delegationCertificates?: InputMaybe<Array<StakeDelegationCertificateRef>>;
  deregistrationCertificates?: InputMaybe<Array<StakeKeyDeregistrationCertificateRef>>;
  mirCertificates?: InputMaybe<Array<MirCertificateRef>>;
  publicKey?: InputMaybe<PublicKeyRef>;
  registrationCertificates?: InputMaybe<Array<StakeKeyRegistrationCertificateRef>>;
  rewards?: InputMaybe<Array<RewardRef>>;
  withdrawals?: InputMaybe<Array<WithdrawalRef>>;
};

export type RewardAggregateResult = {
  __typename?: 'RewardAggregateResult';
  count?: Maybe<Scalars['Int']>;
  epochNoAvg?: Maybe<Scalars['Float']>;
  epochNoMax?: Maybe<Scalars['Int']>;
  epochNoMin?: Maybe<Scalars['Int']>;
  epochNoSum?: Maybe<Scalars['Int']>;
  quantityAvg?: Maybe<Scalars['Float']>;
  quantityMax?: Maybe<Scalars['Int64']>;
  quantityMin?: Maybe<Scalars['Int64']>;
  quantitySum?: Maybe<Scalars['Int64']>;
  sourceMax?: Maybe<Scalars['String']>;
  sourceMin?: Maybe<Scalars['String']>;
  spendableAtEpochNoAvg?: Maybe<Scalars['Float']>;
  spendableAtEpochNoMax?: Maybe<Scalars['Int']>;
  spendableAtEpochNoMin?: Maybe<Scalars['Int']>;
  spendableAtEpochNoSum?: Maybe<Scalars['Int']>;
};

export type RewardFilter = {
  and?: InputMaybe<Array<InputMaybe<RewardFilter>>>;
  epochNo?: InputMaybe<IntFilter>;
  has?: InputMaybe<Array<InputMaybe<RewardHasFilter>>>;
  not?: InputMaybe<RewardFilter>;
  or?: InputMaybe<Array<InputMaybe<RewardFilter>>>;
  source?: InputMaybe<StringExactFilter>;
};

export enum RewardHasFilter {
  Epoch = 'epoch',
  EpochNo = 'epochNo',
  Quantity = 'quantity',
  RewardAccount = 'rewardAccount',
  Source = 'source',
  SpendableAtEpochNo = 'spendableAtEpochNo',
  StakePool = 'stakePool'
}

export type RewardOrder = {
  asc?: InputMaybe<RewardOrderable>;
  desc?: InputMaybe<RewardOrderable>;
  then?: InputMaybe<RewardOrder>;
};

export enum RewardOrderable {
  EpochNo = 'epochNo',
  Quantity = 'quantity',
  Source = 'source',
  SpendableAtEpochNo = 'spendableAtEpochNo'
}

export type RewardPatch = {
  epoch?: InputMaybe<EpochRef>;
  epochNo?: InputMaybe<Scalars['Int']>;
  quantity?: InputMaybe<Scalars['Int64']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  /** member | leader | treasury | reserves */
  source?: InputMaybe<Scalars['String']>;
  spendableAtEpochNo?: InputMaybe<Scalars['Int']>;
  stakePool?: InputMaybe<StakePoolRef>;
};

export type RewardRef = {
  epoch?: InputMaybe<EpochRef>;
  epochNo?: InputMaybe<Scalars['Int']>;
  quantity?: InputMaybe<Scalars['Int64']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  /** member | leader | treasury | reserves */
  source?: InputMaybe<Scalars['String']>;
  spendableAtEpochNo?: InputMaybe<Scalars['Int']>;
  stakePool?: InputMaybe<StakePoolRef>;
};

export type Script = NativeScript | PlutusScript;

export type ScriptFilter = {
  memberTypes?: InputMaybe<Array<ScriptType>>;
  nativeScriptFilter?: InputMaybe<NativeScriptFilter>;
  plutusScriptFilter?: InputMaybe<PlutusScriptFilter>;
};

export type ScriptRef = {
  nativeScriptRef?: InputMaybe<NativeScriptRef>;
  plutusScriptRef?: InputMaybe<PlutusScriptRef>;
};

export enum ScriptType {
  NativeScript = 'NativeScript',
  PlutusScript = 'PlutusScript'
}

export type SearchResult = RelayByAddress | RelayByName | RelayByNameMultihost;

export type SearchResultFilter = {
  memberTypes?: InputMaybe<Array<SearchResultType>>;
  relayByAddressFilter?: InputMaybe<RelayByAddressFilter>;
  relayByNameFilter?: InputMaybe<RelayByNameFilter>;
  relayByNameMultihostFilter?: InputMaybe<RelayByNameMultihostFilter>;
};

export type SearchResultRef = {
  relayByAddressRef?: InputMaybe<RelayByAddressRef>;
  relayByNameMultihostRef?: InputMaybe<RelayByNameMultihostRef>;
  relayByNameRef?: InputMaybe<RelayByNameRef>;
};

export enum SearchResultType {
  RelayByAddress = 'RelayByAddress',
  RelayByName = 'RelayByName',
  RelayByNameMultihost = 'RelayByNameMultihost'
}

export type Signature = {
  __typename?: 'Signature';
  publicKey: PublicKey;
  /** hex-encoded Ed25519 signature */
  signature: Scalars['String'];
  witness: Witness;
};


export type SignaturePublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};


export type SignatureWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
};

export type SignatureAggregateResult = {
  __typename?: 'SignatureAggregateResult';
  count?: Maybe<Scalars['Int']>;
  signatureMax?: Maybe<Scalars['String']>;
  signatureMin?: Maybe<Scalars['String']>;
};

export type SignatureFilter = {
  and?: InputMaybe<Array<InputMaybe<SignatureFilter>>>;
  has?: InputMaybe<Array<InputMaybe<SignatureHasFilter>>>;
  not?: InputMaybe<SignatureFilter>;
  or?: InputMaybe<Array<InputMaybe<SignatureFilter>>>;
};

export enum SignatureHasFilter {
  PublicKey = 'publicKey',
  Signature = 'signature',
  Witness = 'witness'
}

export type SignatureOrder = {
  asc?: InputMaybe<SignatureOrderable>;
  desc?: InputMaybe<SignatureOrderable>;
  then?: InputMaybe<SignatureOrder>;
};

export enum SignatureOrderable {
  Signature = 'signature'
}

export type SignaturePatch = {
  publicKey?: InputMaybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: InputMaybe<Scalars['String']>;
  witness?: InputMaybe<WitnessRef>;
};

export type SignatureRef = {
  publicKey?: InputMaybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: InputMaybe<Scalars['String']>;
  witness?: InputMaybe<WitnessRef>;
};

export type Slot = {
  __typename?: 'Slot';
  block?: Maybe<Block>;
  date: Scalars['DateTime'];
  number: Scalars['Int'];
  slotInEpoch: Scalars['Int'];
};


export type SlotBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
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
  and?: InputMaybe<Array<InputMaybe<SlotFilter>>>;
  has?: InputMaybe<Array<InputMaybe<SlotHasFilter>>>;
  not?: InputMaybe<SlotFilter>;
  number?: InputMaybe<IntFilter>;
  or?: InputMaybe<Array<InputMaybe<SlotFilter>>>;
};

export enum SlotHasFilter {
  Block = 'block',
  Date = 'date',
  Number = 'number',
  SlotInEpoch = 'slotInEpoch'
}

export type SlotOrder = {
  asc?: InputMaybe<SlotOrderable>;
  desc?: InputMaybe<SlotOrderable>;
  then?: InputMaybe<SlotOrder>;
};

export enum SlotOrderable {
  Date = 'date',
  Number = 'number',
  SlotInEpoch = 'slotInEpoch'
}

export type SlotPatch = {
  block?: InputMaybe<BlockRef>;
  date?: InputMaybe<Scalars['DateTime']>;
  slotInEpoch?: InputMaybe<Scalars['Int']>;
};

export type SlotRef = {
  block?: InputMaybe<BlockRef>;
  date?: InputMaybe<Scalars['DateTime']>;
  number?: InputMaybe<Scalars['Int']>;
  slotInEpoch?: InputMaybe<Scalars['Int']>;
};

export type StakeDelegationCertificate = {
  __typename?: 'StakeDelegationCertificate';
  epoch: Epoch;
  rewardAccount: RewardAccount;
  stakePool: StakePool;
  transaction: Transaction;
};


export type StakeDelegationCertificateEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};


export type StakeDelegationCertificateRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type StakeDelegationCertificateStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
};


export type StakeDelegationCertificateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type StakeDelegationCertificateAggregateResult = {
  __typename?: 'StakeDelegationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type StakeDelegationCertificateFilter = {
  and?: InputMaybe<Array<InputMaybe<StakeDelegationCertificateFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakeDelegationCertificateHasFilter>>>;
  not?: InputMaybe<StakeDelegationCertificateFilter>;
  or?: InputMaybe<Array<InputMaybe<StakeDelegationCertificateFilter>>>;
};

export enum StakeDelegationCertificateHasFilter {
  Epoch = 'epoch',
  RewardAccount = 'rewardAccount',
  StakePool = 'stakePool',
  Transaction = 'transaction'
}

export type StakeDelegationCertificatePatch = {
  epoch?: InputMaybe<EpochRef>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  stakePool?: InputMaybe<StakePoolRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type StakeDelegationCertificateRef = {
  epoch?: InputMaybe<EpochRef>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  stakePool?: InputMaybe<StakePoolRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type StakeKeyDeregistrationCertificate = {
  __typename?: 'StakeKeyDeregistrationCertificate';
  rewardAccount: RewardAccount;
  transaction: Transaction;
};


export type StakeKeyDeregistrationCertificateRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type StakeKeyDeregistrationCertificateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type StakeKeyDeregistrationCertificateAggregateResult = {
  __typename?: 'StakeKeyDeregistrationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type StakeKeyDeregistrationCertificateFilter = {
  and?: InputMaybe<Array<InputMaybe<StakeKeyDeregistrationCertificateFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakeKeyDeregistrationCertificateHasFilter>>>;
  not?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
  or?: InputMaybe<Array<InputMaybe<StakeKeyDeregistrationCertificateFilter>>>;
};

export enum StakeKeyDeregistrationCertificateHasFilter {
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type StakeKeyDeregistrationCertificatePatch = {
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type StakeKeyDeregistrationCertificateRef = {
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type StakeKeyRegistrationCertificate = {
  __typename?: 'StakeKeyRegistrationCertificate';
  rewardAccount: RewardAccount;
  transaction: Transaction;
};


export type StakeKeyRegistrationCertificateRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type StakeKeyRegistrationCertificateTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type StakeKeyRegistrationCertificateAggregateResult = {
  __typename?: 'StakeKeyRegistrationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type StakeKeyRegistrationCertificateFilter = {
  and?: InputMaybe<Array<InputMaybe<StakeKeyRegistrationCertificateFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakeKeyRegistrationCertificateHasFilter>>>;
  not?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
  or?: InputMaybe<Array<InputMaybe<StakeKeyRegistrationCertificateFilter>>>;
};

export enum StakeKeyRegistrationCertificateHasFilter {
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type StakeKeyRegistrationCertificatePatch = {
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type StakeKeyRegistrationCertificateRef = {
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type StakePool = {
  __typename?: 'StakePool';
  epochRewards: Array<StakePoolEpochRewards>;
  epochRewardsAggregate?: Maybe<StakePoolEpochRewardsAggregateResult>;
  hexId: Scalars['String'];
  id: Scalars['String'];
  metrics: Array<StakePoolMetrics>;
  metricsAggregate?: Maybe<StakePoolMetricsAggregateResult>;
  poolParameters: Array<PoolParameters>;
  poolParametersAggregate?: Maybe<PoolParametersAggregateResult>;
  poolRetirementCertificates: Array<PoolRetirementCertificate>;
  poolRetirementCertificatesAggregate?: Maybe<PoolRetirementCertificateAggregateResult>;
  /** active | retired | retiring */
  status: StakePoolStatus;
};


export type StakePoolEpochRewardsArgs = {
  filter?: InputMaybe<StakePoolEpochRewardsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolEpochRewardsOrder>;
};


export type StakePoolEpochRewardsAggregateArgs = {
  filter?: InputMaybe<StakePoolEpochRewardsFilter>;
};


export type StakePoolMetricsArgs = {
  filter?: InputMaybe<StakePoolMetricsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsOrder>;
};


export type StakePoolMetricsAggregateArgs = {
  filter?: InputMaybe<StakePoolMetricsFilter>;
};


export type StakePoolPoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolParametersOrder>;
};


export type StakePoolPoolParametersAggregateArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
};


export type StakePoolPoolRetirementCertificatesArgs = {
  filter?: InputMaybe<PoolRetirementCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type StakePoolPoolRetirementCertificatesAggregateArgs = {
  filter?: InputMaybe<PoolRetirementCertificateFilter>;
};

export type StakePoolAggregateResult = {
  __typename?: 'StakePoolAggregateResult';
  count?: Maybe<Scalars['Int']>;
  hexIdMax?: Maybe<Scalars['String']>;
  hexIdMin?: Maybe<Scalars['String']>;
  idMax?: Maybe<Scalars['String']>;
  idMin?: Maybe<Scalars['String']>;
};

/** Stake pool performance per epoch, taken at epoch rollover */
export type StakePoolEpochRewards = {
  __typename?: 'StakePoolEpochRewards';
  activeStake: Scalars['Int64'];
  epoch: Epoch;
  epochLength: Scalars['Int'];
  epochNo: Scalars['Int'];
  /** rewards/activeStake, not annualized */
  memberROI: Scalars['Float'];
  operatorFees: Scalars['Int64'];
  /** Total rewards for the epoch */
  totalRewards: Scalars['Int64'];
};


/** Stake pool performance per epoch, taken at epoch rollover */
export type StakePoolEpochRewardsEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};

export type StakePoolEpochRewardsAggregateResult = {
  __typename?: 'StakePoolEpochRewardsAggregateResult';
  activeStakeAvg?: Maybe<Scalars['Float']>;
  activeStakeMax?: Maybe<Scalars['Int64']>;
  activeStakeMin?: Maybe<Scalars['Int64']>;
  activeStakeSum?: Maybe<Scalars['Int64']>;
  count?: Maybe<Scalars['Int']>;
  epochLengthAvg?: Maybe<Scalars['Float']>;
  epochLengthMax?: Maybe<Scalars['Int']>;
  epochLengthMin?: Maybe<Scalars['Int']>;
  epochLengthSum?: Maybe<Scalars['Int']>;
  epochNoAvg?: Maybe<Scalars['Float']>;
  epochNoMax?: Maybe<Scalars['Int']>;
  epochNoMin?: Maybe<Scalars['Int']>;
  epochNoSum?: Maybe<Scalars['Int']>;
  memberROIAvg?: Maybe<Scalars['Float']>;
  memberROIMax?: Maybe<Scalars['Float']>;
  memberROIMin?: Maybe<Scalars['Float']>;
  memberROISum?: Maybe<Scalars['Float']>;
  operatorFeesAvg?: Maybe<Scalars['Float']>;
  operatorFeesMax?: Maybe<Scalars['Int64']>;
  operatorFeesMin?: Maybe<Scalars['Int64']>;
  operatorFeesSum?: Maybe<Scalars['Int64']>;
  totalRewardsAvg?: Maybe<Scalars['Float']>;
  totalRewardsMax?: Maybe<Scalars['Int64']>;
  totalRewardsMin?: Maybe<Scalars['Int64']>;
  totalRewardsSum?: Maybe<Scalars['Int64']>;
};

export type StakePoolEpochRewardsFilter = {
  and?: InputMaybe<Array<InputMaybe<StakePoolEpochRewardsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakePoolEpochRewardsHasFilter>>>;
  not?: InputMaybe<StakePoolEpochRewardsFilter>;
  or?: InputMaybe<Array<InputMaybe<StakePoolEpochRewardsFilter>>>;
};

export enum StakePoolEpochRewardsHasFilter {
  ActiveStake = 'activeStake',
  Epoch = 'epoch',
  EpochLength = 'epochLength',
  EpochNo = 'epochNo',
  MemberRoi = 'memberROI',
  OperatorFees = 'operatorFees',
  TotalRewards = 'totalRewards'
}

export type StakePoolEpochRewardsOrder = {
  asc?: InputMaybe<StakePoolEpochRewardsOrderable>;
  desc?: InputMaybe<StakePoolEpochRewardsOrderable>;
  then?: InputMaybe<StakePoolEpochRewardsOrder>;
};

export enum StakePoolEpochRewardsOrderable {
  ActiveStake = 'activeStake',
  EpochLength = 'epochLength',
  EpochNo = 'epochNo',
  MemberRoi = 'memberROI',
  OperatorFees = 'operatorFees',
  TotalRewards = 'totalRewards'
}

export type StakePoolEpochRewardsPatch = {
  activeStake?: InputMaybe<Scalars['Int64']>;
  epoch?: InputMaybe<EpochRef>;
  epochLength?: InputMaybe<Scalars['Int']>;
  epochNo?: InputMaybe<Scalars['Int']>;
  /** rewards/activeStake, not annualized */
  memberROI?: InputMaybe<Scalars['Float']>;
  operatorFees?: InputMaybe<Scalars['Int64']>;
  /** Total rewards for the epoch */
  totalRewards?: InputMaybe<Scalars['Int64']>;
};

export type StakePoolEpochRewardsRef = {
  activeStake?: InputMaybe<Scalars['Int64']>;
  epoch?: InputMaybe<EpochRef>;
  epochLength?: InputMaybe<Scalars['Int']>;
  epochNo?: InputMaybe<Scalars['Int']>;
  /** rewards/activeStake, not annualized */
  memberROI?: InputMaybe<Scalars['Float']>;
  operatorFees?: InputMaybe<Scalars['Int64']>;
  /** Total rewards for the epoch */
  totalRewards?: InputMaybe<Scalars['Int64']>;
};

export type StakePoolFilter = {
  and?: InputMaybe<Array<InputMaybe<StakePoolFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakePoolHasFilter>>>;
  id?: InputMaybe<StringFullTextFilter_StringHashFilter>;
  not?: InputMaybe<StakePoolFilter>;
  or?: InputMaybe<Array<InputMaybe<StakePoolFilter>>>;
};

export enum StakePoolHasFilter {
  EpochRewards = 'epochRewards',
  HexId = 'hexId',
  Id = 'id',
  Metrics = 'metrics',
  PoolParameters = 'poolParameters',
  PoolRetirementCertificates = 'poolRetirementCertificates',
  Status = 'status'
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
  poolParameters: PoolParameters;
  stakePoolId: Scalars['String'];
  ticker: Scalars['String'];
};


export type StakePoolMetadataExtArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFilter>;
};


export type StakePoolMetadataPoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
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
  and?: InputMaybe<Array<InputMaybe<StakePoolMetadataFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakePoolMetadataHasFilter>>>;
  name?: InputMaybe<StringFullTextFilter>;
  not?: InputMaybe<StakePoolMetadataFilter>;
  or?: InputMaybe<Array<InputMaybe<StakePoolMetadataFilter>>>;
  stakePoolId?: InputMaybe<StringHashFilter>;
  ticker?: InputMaybe<StringFullTextFilter>;
};

export enum StakePoolMetadataHasFilter {
  Description = 'description',
  Ext = 'ext',
  ExtDataUrl = 'extDataUrl',
  ExtSigUrl = 'extSigUrl',
  ExtVkey = 'extVkey',
  Homepage = 'homepage',
  Name = 'name',
  PoolParameters = 'poolParameters',
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
  and?: InputMaybe<Array<InputMaybe<StakePoolMetadataJsonFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakePoolMetadataJsonHasFilter>>>;
  not?: InputMaybe<StakePoolMetadataJsonFilter>;
  or?: InputMaybe<Array<InputMaybe<StakePoolMetadataJsonFilter>>>;
};

export enum StakePoolMetadataJsonHasFilter {
  Hash = 'hash',
  Url = 'url'
}

export type StakePoolMetadataJsonOrder = {
  asc?: InputMaybe<StakePoolMetadataJsonOrderable>;
  desc?: InputMaybe<StakePoolMetadataJsonOrderable>;
  then?: InputMaybe<StakePoolMetadataJsonOrder>;
};

export enum StakePoolMetadataJsonOrderable {
  Hash = 'hash',
  Url = 'url'
}

export type StakePoolMetadataJsonPatch = {
  hash?: InputMaybe<Scalars['String']>;
  url?: InputMaybe<Scalars['String']>;
};

export type StakePoolMetadataJsonRef = {
  hash?: InputMaybe<Scalars['String']>;
  url?: InputMaybe<Scalars['String']>;
};

export type StakePoolMetadataOrder = {
  asc?: InputMaybe<StakePoolMetadataOrderable>;
  desc?: InputMaybe<StakePoolMetadataOrderable>;
  then?: InputMaybe<StakePoolMetadataOrder>;
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
  description?: InputMaybe<Scalars['String']>;
  ext?: InputMaybe<ExtendedStakePoolMetadataRef>;
  extDataUrl?: InputMaybe<Scalars['String']>;
  extSigUrl?: InputMaybe<Scalars['String']>;
  extVkey?: InputMaybe<Scalars['String']>;
  homepage?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  poolParameters?: InputMaybe<PoolParametersRef>;
  stakePoolId?: InputMaybe<Scalars['String']>;
  ticker?: InputMaybe<Scalars['String']>;
};

export type StakePoolMetadataRef = {
  description?: InputMaybe<Scalars['String']>;
  ext?: InputMaybe<ExtendedStakePoolMetadataRef>;
  extDataUrl?: InputMaybe<Scalars['String']>;
  extSigUrl?: InputMaybe<Scalars['String']>;
  extVkey?: InputMaybe<Scalars['String']>;
  homepage?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  poolParameters?: InputMaybe<PoolParametersRef>;
  stakePoolId?: InputMaybe<Scalars['String']>;
  ticker?: InputMaybe<Scalars['String']>;
};

export type StakePoolMetrics = {
  __typename?: 'StakePoolMetrics';
  block: Block;
  blockNo: Scalars['Int'];
  blocksCreated: Scalars['Int'];
  delegators: Scalars['Int'];
  livePledge: Scalars['Int64'];
  saturation: Scalars['Float'];
  size: StakePoolMetricsSize;
  stake: StakePoolMetricsStake;
};


export type StakePoolMetricsBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
};


export type StakePoolMetricsSizeArgs = {
  filter?: InputMaybe<StakePoolMetricsSizeFilter>;
};


export type StakePoolMetricsStakeArgs = {
  filter?: InputMaybe<StakePoolMetricsStakeFilter>;
};

export type StakePoolMetricsAggregateResult = {
  __typename?: 'StakePoolMetricsAggregateResult';
  blockNoAvg?: Maybe<Scalars['Float']>;
  blockNoMax?: Maybe<Scalars['Int']>;
  blockNoMin?: Maybe<Scalars['Int']>;
  blockNoSum?: Maybe<Scalars['Int']>;
  blocksCreatedAvg?: Maybe<Scalars['Float']>;
  blocksCreatedMax?: Maybe<Scalars['Int']>;
  blocksCreatedMin?: Maybe<Scalars['Int']>;
  blocksCreatedSum?: Maybe<Scalars['Int']>;
  count?: Maybe<Scalars['Int']>;
  delegatorsAvg?: Maybe<Scalars['Float']>;
  delegatorsMax?: Maybe<Scalars['Int']>;
  delegatorsMin?: Maybe<Scalars['Int']>;
  delegatorsSum?: Maybe<Scalars['Int']>;
  livePledgeAvg?: Maybe<Scalars['Float']>;
  livePledgeMax?: Maybe<Scalars['Int64']>;
  livePledgeMin?: Maybe<Scalars['Int64']>;
  livePledgeSum?: Maybe<Scalars['Int64']>;
  saturationAvg?: Maybe<Scalars['Float']>;
  saturationMax?: Maybe<Scalars['Float']>;
  saturationMin?: Maybe<Scalars['Float']>;
  saturationSum?: Maybe<Scalars['Float']>;
};

export type StakePoolMetricsFilter = {
  and?: InputMaybe<Array<InputMaybe<StakePoolMetricsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakePoolMetricsHasFilter>>>;
  not?: InputMaybe<StakePoolMetricsFilter>;
  or?: InputMaybe<Array<InputMaybe<StakePoolMetricsFilter>>>;
};

export enum StakePoolMetricsHasFilter {
  Block = 'block',
  BlockNo = 'blockNo',
  BlocksCreated = 'blocksCreated',
  Delegators = 'delegators',
  LivePledge = 'livePledge',
  Saturation = 'saturation',
  Size = 'size',
  Stake = 'stake'
}

export type StakePoolMetricsOrder = {
  asc?: InputMaybe<StakePoolMetricsOrderable>;
  desc?: InputMaybe<StakePoolMetricsOrderable>;
  then?: InputMaybe<StakePoolMetricsOrder>;
};

export enum StakePoolMetricsOrderable {
  BlockNo = 'blockNo',
  BlocksCreated = 'blocksCreated',
  Delegators = 'delegators',
  LivePledge = 'livePledge',
  Saturation = 'saturation'
}

export type StakePoolMetricsPatch = {
  block?: InputMaybe<BlockRef>;
  blockNo?: InputMaybe<Scalars['Int']>;
  blocksCreated?: InputMaybe<Scalars['Int']>;
  delegators?: InputMaybe<Scalars['Int']>;
  livePledge?: InputMaybe<Scalars['Int64']>;
  saturation?: InputMaybe<Scalars['Float']>;
  size?: InputMaybe<StakePoolMetricsSizeRef>;
  stake?: InputMaybe<StakePoolMetricsStakeRef>;
};

export type StakePoolMetricsRef = {
  block?: InputMaybe<BlockRef>;
  blockNo?: InputMaybe<Scalars['Int']>;
  blocksCreated?: InputMaybe<Scalars['Int']>;
  delegators?: InputMaybe<Scalars['Int']>;
  livePledge?: InputMaybe<Scalars['Int64']>;
  saturation?: InputMaybe<Scalars['Float']>;
  size?: InputMaybe<StakePoolMetricsSizeRef>;
  stake?: InputMaybe<StakePoolMetricsStakeRef>;
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
  and?: InputMaybe<Array<InputMaybe<StakePoolMetricsSizeFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakePoolMetricsSizeHasFilter>>>;
  not?: InputMaybe<StakePoolMetricsSizeFilter>;
  or?: InputMaybe<Array<InputMaybe<StakePoolMetricsSizeFilter>>>;
};

export enum StakePoolMetricsSizeHasFilter {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsSizeOrder = {
  asc?: InputMaybe<StakePoolMetricsSizeOrderable>;
  desc?: InputMaybe<StakePoolMetricsSizeOrderable>;
  then?: InputMaybe<StakePoolMetricsSizeOrder>;
};

export enum StakePoolMetricsSizeOrderable {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsSizePatch = {
  /** Percentage in range [0; 1] */
  active?: InputMaybe<Scalars['Float']>;
  /** Percentage in range [0; 1] */
  live?: InputMaybe<Scalars['Float']>;
};

export type StakePoolMetricsSizeRef = {
  /** Percentage in range [0; 1] */
  active?: InputMaybe<Scalars['Float']>;
  /** Percentage in range [0; 1] */
  live?: InputMaybe<Scalars['Float']>;
};

export type StakePoolMetricsStake = {
  __typename?: 'StakePoolMetricsStake';
  active: Scalars['Int64'];
  live: Scalars['Int64'];
};

export type StakePoolMetricsStakeAggregateResult = {
  __typename?: 'StakePoolMetricsStakeAggregateResult';
  activeAvg?: Maybe<Scalars['Float']>;
  activeMax?: Maybe<Scalars['Int64']>;
  activeMin?: Maybe<Scalars['Int64']>;
  activeSum?: Maybe<Scalars['Int64']>;
  count?: Maybe<Scalars['Int']>;
  liveAvg?: Maybe<Scalars['Float']>;
  liveMax?: Maybe<Scalars['Int64']>;
  liveMin?: Maybe<Scalars['Int64']>;
  liveSum?: Maybe<Scalars['Int64']>;
};

export type StakePoolMetricsStakeFilter = {
  and?: InputMaybe<Array<InputMaybe<StakePoolMetricsStakeFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StakePoolMetricsStakeHasFilter>>>;
  not?: InputMaybe<StakePoolMetricsStakeFilter>;
  or?: InputMaybe<Array<InputMaybe<StakePoolMetricsStakeFilter>>>;
};

export enum StakePoolMetricsStakeHasFilter {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsStakeOrder = {
  asc?: InputMaybe<StakePoolMetricsStakeOrderable>;
  desc?: InputMaybe<StakePoolMetricsStakeOrderable>;
  then?: InputMaybe<StakePoolMetricsStakeOrder>;
};

export enum StakePoolMetricsStakeOrderable {
  Active = 'active',
  Live = 'live'
}

export type StakePoolMetricsStakePatch = {
  active?: InputMaybe<Scalars['Int64']>;
  live?: InputMaybe<Scalars['Int64']>;
};

export type StakePoolMetricsStakeRef = {
  active?: InputMaybe<Scalars['Int64']>;
  live?: InputMaybe<Scalars['Int64']>;
};

export type StakePoolOrder = {
  asc?: InputMaybe<StakePoolOrderable>;
  desc?: InputMaybe<StakePoolOrderable>;
  then?: InputMaybe<StakePoolOrder>;
};

export enum StakePoolOrderable {
  HexId = 'hexId',
  Id = 'id'
}

export type StakePoolPatch = {
  epochRewards?: InputMaybe<Array<StakePoolEpochRewardsRef>>;
  hexId?: InputMaybe<Scalars['String']>;
  metrics?: InputMaybe<Array<StakePoolMetricsRef>>;
  poolParameters?: InputMaybe<Array<PoolParametersRef>>;
  poolRetirementCertificates?: InputMaybe<Array<PoolRetirementCertificateRef>>;
  /** active | retired | retiring */
  status?: InputMaybe<StakePoolStatus>;
};

export type StakePoolRef = {
  epochRewards?: InputMaybe<Array<StakePoolEpochRewardsRef>>;
  hexId?: InputMaybe<Scalars['String']>;
  id?: InputMaybe<Scalars['String']>;
  metrics?: InputMaybe<Array<StakePoolMetricsRef>>;
  poolParameters?: InputMaybe<Array<PoolParametersRef>>;
  poolRetirementCertificates?: InputMaybe<Array<PoolRetirementCertificateRef>>;
  /** active | retired | retiring */
  status?: InputMaybe<StakePoolStatus>;
};

export enum StakePoolStatus {
  Activating = 'activating',
  Active = 'active',
  Retired = 'retired',
  Retiring = 'retiring'
}

export type StringExactFilter = {
  between?: InputMaybe<StringRange>;
  eq?: InputMaybe<Scalars['String']>;
  ge?: InputMaybe<Scalars['String']>;
  gt?: InputMaybe<Scalars['String']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['String']>>>;
  le?: InputMaybe<Scalars['String']>;
  lt?: InputMaybe<Scalars['String']>;
};

export type StringExactFilter_StringFullTextFilter = {
  alloftext?: InputMaybe<Scalars['String']>;
  anyoftext?: InputMaybe<Scalars['String']>;
  between?: InputMaybe<StringRange>;
  eq?: InputMaybe<Scalars['String']>;
  ge?: InputMaybe<Scalars['String']>;
  gt?: InputMaybe<Scalars['String']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['String']>>>;
  le?: InputMaybe<Scalars['String']>;
  lt?: InputMaybe<Scalars['String']>;
};

export type StringFullTextFilter = {
  alloftext?: InputMaybe<Scalars['String']>;
  anyoftext?: InputMaybe<Scalars['String']>;
};

export type StringFullTextFilter_StringHashFilter = {
  alloftext?: InputMaybe<Scalars['String']>;
  anyoftext?: InputMaybe<Scalars['String']>;
  eq?: InputMaybe<Scalars['String']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['String']>>>;
};

export type StringHashFilter = {
  eq?: InputMaybe<Scalars['String']>;
  in?: InputMaybe<Array<InputMaybe<Scalars['String']>>>;
};

export type StringMetadatum = {
  __typename?: 'StringMetadatum';
  string: Scalars['String'];
};

export type StringMetadatumAggregateResult = {
  __typename?: 'StringMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  stringMax?: Maybe<Scalars['String']>;
  stringMin?: Maybe<Scalars['String']>;
};

export type StringMetadatumFilter = {
  and?: InputMaybe<Array<InputMaybe<StringMetadatumFilter>>>;
  has?: InputMaybe<Array<InputMaybe<StringMetadatumHasFilter>>>;
  not?: InputMaybe<StringMetadatumFilter>;
  or?: InputMaybe<Array<InputMaybe<StringMetadatumFilter>>>;
  string?: InputMaybe<StringExactFilter_StringFullTextFilter>;
};

export enum StringMetadatumHasFilter {
  String = 'string'
}

export type StringMetadatumOrder = {
  asc?: InputMaybe<StringMetadatumOrderable>;
  desc?: InputMaybe<StringMetadatumOrderable>;
  then?: InputMaybe<StringMetadatumOrder>;
};

export enum StringMetadatumOrderable {
  String = 'string'
}

export type StringMetadatumPatch = {
  string?: InputMaybe<Scalars['String']>;
};

export type StringMetadatumRef = {
  string?: InputMaybe<Scalars['String']>;
};

export type StringRange = {
  max: Scalars['String'];
  min: Scalars['String'];
};

export type StringRegExpFilter = {
  regexp?: InputMaybe<Scalars['String']>;
};

export type StringTermFilter = {
  allofterms?: InputMaybe<Scalars['String']>;
  anyofterms?: InputMaybe<Scalars['String']>;
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
  and?: InputMaybe<Array<InputMaybe<ThePoolsMediaAssetsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ThePoolsMediaAssetsHasFilter>>>;
  not?: InputMaybe<ThePoolsMediaAssetsFilter>;
  or?: InputMaybe<Array<InputMaybe<ThePoolsMediaAssetsFilter>>>;
};

export enum ThePoolsMediaAssetsHasFilter {
  ColorBg = 'color_bg',
  ColorFg = 'color_fg',
  IconPng_64x64 = 'icon_png_64x64',
  LogoPng = 'logo_png',
  LogoSvg = 'logo_svg'
}

export type ThePoolsMediaAssetsOrder = {
  asc?: InputMaybe<ThePoolsMediaAssetsOrderable>;
  desc?: InputMaybe<ThePoolsMediaAssetsOrderable>;
  then?: InputMaybe<ThePoolsMediaAssetsOrder>;
};

export enum ThePoolsMediaAssetsOrderable {
  ColorBg = 'color_bg',
  ColorFg = 'color_fg',
  IconPng_64x64 = 'icon_png_64x64',
  LogoPng = 'logo_png',
  LogoSvg = 'logo_svg'
}

export type ThePoolsMediaAssetsPatch = {
  color_bg?: InputMaybe<Scalars['String']>;
  color_fg?: InputMaybe<Scalars['String']>;
  icon_png_64x64?: InputMaybe<Scalars['String']>;
  logo_png?: InputMaybe<Scalars['String']>;
  logo_svg?: InputMaybe<Scalars['String']>;
};

export type ThePoolsMediaAssetsRef = {
  color_bg?: InputMaybe<Scalars['String']>;
  color_fg?: InputMaybe<Scalars['String']>;
  icon_png_64x64?: InputMaybe<Scalars['String']>;
  logo_png?: InputMaybe<Scalars['String']>;
  logo_svg?: InputMaybe<Scalars['String']>;
};

export type TimeSettings = {
  __typename?: 'TimeSettings';
  epochLength: Scalars['Int'];
  fromEpoch: Epoch;
  fromEpochNo: Scalars['Int'];
  slotLength: Scalars['Int'];
};


export type TimeSettingsFromEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
};

export type TimeSettingsAggregateResult = {
  __typename?: 'TimeSettingsAggregateResult';
  count?: Maybe<Scalars['Int']>;
  epochLengthAvg?: Maybe<Scalars['Float']>;
  epochLengthMax?: Maybe<Scalars['Int']>;
  epochLengthMin?: Maybe<Scalars['Int']>;
  epochLengthSum?: Maybe<Scalars['Int']>;
  fromEpochNoAvg?: Maybe<Scalars['Float']>;
  fromEpochNoMax?: Maybe<Scalars['Int']>;
  fromEpochNoMin?: Maybe<Scalars['Int']>;
  fromEpochNoSum?: Maybe<Scalars['Int']>;
  slotLengthAvg?: Maybe<Scalars['Float']>;
  slotLengthMax?: Maybe<Scalars['Int']>;
  slotLengthMin?: Maybe<Scalars['Int']>;
  slotLengthSum?: Maybe<Scalars['Int']>;
};

export type TimeSettingsFilter = {
  and?: InputMaybe<Array<InputMaybe<TimeSettingsFilter>>>;
  has?: InputMaybe<Array<InputMaybe<TimeSettingsHasFilter>>>;
  not?: InputMaybe<TimeSettingsFilter>;
  or?: InputMaybe<Array<InputMaybe<TimeSettingsFilter>>>;
};

export enum TimeSettingsHasFilter {
  EpochLength = 'epochLength',
  FromEpoch = 'fromEpoch',
  FromEpochNo = 'fromEpochNo',
  SlotLength = 'slotLength'
}

export type TimeSettingsOrder = {
  asc?: InputMaybe<TimeSettingsOrderable>;
  desc?: InputMaybe<TimeSettingsOrderable>;
  then?: InputMaybe<TimeSettingsOrder>;
};

export enum TimeSettingsOrderable {
  EpochLength = 'epochLength',
  FromEpochNo = 'fromEpochNo',
  SlotLength = 'slotLength'
}

export type TimeSettingsPatch = {
  epochLength?: InputMaybe<Scalars['Int']>;
  fromEpoch?: InputMaybe<EpochRef>;
  fromEpochNo?: InputMaybe<Scalars['Int']>;
  slotLength?: InputMaybe<Scalars['Int']>;
};

export type TimeSettingsRef = {
  epochLength?: InputMaybe<Scalars['Int']>;
  fromEpoch?: InputMaybe<EpochRef>;
  fromEpochNo?: InputMaybe<Scalars['Int']>;
  slotLength?: InputMaybe<Scalars['Int']>;
};

export type Token = {
  __typename?: 'Token';
  asset: Asset;
  quantity: Scalars['String'];
  transactionOutput: TransactionOutput;
};


export type TokenAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
};


export type TokenTransactionOutputArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
};

export type TokenAggregateResult = {
  __typename?: 'TokenAggregateResult';
  count?: Maybe<Scalars['Int']>;
  quantityMax?: Maybe<Scalars['String']>;
  quantityMin?: Maybe<Scalars['String']>;
};

export type TokenFilter = {
  and?: InputMaybe<Array<InputMaybe<TokenFilter>>>;
  has?: InputMaybe<Array<InputMaybe<TokenHasFilter>>>;
  not?: InputMaybe<TokenFilter>;
  or?: InputMaybe<Array<InputMaybe<TokenFilter>>>;
};

export enum TokenHasFilter {
  Asset = 'asset',
  Quantity = 'quantity',
  TransactionOutput = 'transactionOutput'
}

/** CIP-0035 */
export type TokenMetadata = {
  __typename?: 'TokenMetadata';
  asset: Asset;
  /** how many decimal places should the token support? For ADA, this would be 6 e.g. 1 ADA is 10^6 Lovelace */
  decimals?: Maybe<Scalars['Int']>;
  /** additional description that defines the usage of the token */
  desc?: Maybe<Scalars['String']>;
  /** MUST be either https, ipfs, or data.  icon MUST be a browser supported image format. */
  icon?: Maybe<Scalars['String']>;
  name: Scalars['String'];
  /** https only url that holds the metadata in the onchain format. */
  ref?: Maybe<Scalars['String']>;
  sizedIcons: Array<TokenMetadataSizedIcon>;
  sizedIconsAggregate?: Maybe<TokenMetadataSizedIconAggregateResult>;
  /** when present, field and overrides default ticker which is the asset name */
  ticker?: Maybe<Scalars['String']>;
  /** https only url that refers to metadata stored offchain. */
  url?: Maybe<Scalars['String']>;
  version?: Maybe<Scalars['String']>;
};


/** CIP-0035 */
export type TokenMetadataAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
};


/** CIP-0035 */
export type TokenMetadataSizedIconsArgs = {
  filter?: InputMaybe<TokenMetadataSizedIconFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataSizedIconOrder>;
};


/** CIP-0035 */
export type TokenMetadataSizedIconsAggregateArgs = {
  filter?: InputMaybe<TokenMetadataSizedIconFilter>;
};

export type TokenMetadataAggregateResult = {
  __typename?: 'TokenMetadataAggregateResult';
  count?: Maybe<Scalars['Int']>;
  decimalsAvg?: Maybe<Scalars['Float']>;
  decimalsMax?: Maybe<Scalars['Int']>;
  decimalsMin?: Maybe<Scalars['Int']>;
  decimalsSum?: Maybe<Scalars['Int']>;
  descMax?: Maybe<Scalars['String']>;
  descMin?: Maybe<Scalars['String']>;
  iconMax?: Maybe<Scalars['String']>;
  iconMin?: Maybe<Scalars['String']>;
  nameMax?: Maybe<Scalars['String']>;
  nameMin?: Maybe<Scalars['String']>;
  refMax?: Maybe<Scalars['String']>;
  refMin?: Maybe<Scalars['String']>;
  tickerMax?: Maybe<Scalars['String']>;
  tickerMin?: Maybe<Scalars['String']>;
  urlMax?: Maybe<Scalars['String']>;
  urlMin?: Maybe<Scalars['String']>;
  versionMax?: Maybe<Scalars['String']>;
  versionMin?: Maybe<Scalars['String']>;
};

export type TokenMetadataFilter = {
  and?: InputMaybe<Array<InputMaybe<TokenMetadataFilter>>>;
  has?: InputMaybe<Array<InputMaybe<TokenMetadataHasFilter>>>;
  not?: InputMaybe<TokenMetadataFilter>;
  or?: InputMaybe<Array<InputMaybe<TokenMetadataFilter>>>;
};

export enum TokenMetadataHasFilter {
  Asset = 'asset',
  Decimals = 'decimals',
  Desc = 'desc',
  Icon = 'icon',
  Name = 'name',
  Ref = 'ref',
  SizedIcons = 'sizedIcons',
  Ticker = 'ticker',
  Url = 'url',
  Version = 'version'
}

export type TokenMetadataOrder = {
  asc?: InputMaybe<TokenMetadataOrderable>;
  desc?: InputMaybe<TokenMetadataOrderable>;
  then?: InputMaybe<TokenMetadataOrder>;
};

export enum TokenMetadataOrderable {
  Decimals = 'decimals',
  Desc = 'desc',
  Icon = 'icon',
  Name = 'name',
  Ref = 'ref',
  Ticker = 'ticker',
  Url = 'url',
  Version = 'version'
}

export type TokenMetadataPatch = {
  asset?: InputMaybe<AssetRef>;
  /** how many decimal places should the token support? For ADA, this would be 6 e.g. 1 ADA is 10^6 Lovelace */
  decimals?: InputMaybe<Scalars['Int']>;
  /** additional description that defines the usage of the token */
  desc?: InputMaybe<Scalars['String']>;
  /** MUST be either https, ipfs, or data.  icon MUST be a browser supported image format. */
  icon?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  /** https only url that holds the metadata in the onchain format. */
  ref?: InputMaybe<Scalars['String']>;
  sizedIcons?: InputMaybe<Array<TokenMetadataSizedIconRef>>;
  /** when present, field and overrides default ticker which is the asset name */
  ticker?: InputMaybe<Scalars['String']>;
  /** https only url that refers to metadata stored offchain. */
  url?: InputMaybe<Scalars['String']>;
  version?: InputMaybe<Scalars['String']>;
};

export type TokenMetadataRef = {
  asset?: InputMaybe<AssetRef>;
  /** how many decimal places should the token support? For ADA, this would be 6 e.g. 1 ADA is 10^6 Lovelace */
  decimals?: InputMaybe<Scalars['Int']>;
  /** additional description that defines the usage of the token */
  desc?: InputMaybe<Scalars['String']>;
  /** MUST be either https, ipfs, or data.  icon MUST be a browser supported image format. */
  icon?: InputMaybe<Scalars['String']>;
  name?: InputMaybe<Scalars['String']>;
  /** https only url that holds the metadata in the onchain format. */
  ref?: InputMaybe<Scalars['String']>;
  sizedIcons?: InputMaybe<Array<TokenMetadataSizedIconRef>>;
  /** when present, field and overrides default ticker which is the asset name */
  ticker?: InputMaybe<Scalars['String']>;
  /** https only url that refers to metadata stored offchain. */
  url?: InputMaybe<Scalars['String']>;
  version?: InputMaybe<Scalars['String']>;
};

export type TokenMetadataSizedIcon = {
  __typename?: 'TokenMetadataSizedIcon';
  /** https only url that refers to metadata stored offchain. */
  icon: Scalars['String'];
  /** Most likely one of 16, 32, 64, 96, 128 */
  size: Scalars['Int'];
};

export type TokenMetadataSizedIconAggregateResult = {
  __typename?: 'TokenMetadataSizedIconAggregateResult';
  count?: Maybe<Scalars['Int']>;
  iconMax?: Maybe<Scalars['String']>;
  iconMin?: Maybe<Scalars['String']>;
  sizeAvg?: Maybe<Scalars['Float']>;
  sizeMax?: Maybe<Scalars['Int']>;
  sizeMin?: Maybe<Scalars['Int']>;
  sizeSum?: Maybe<Scalars['Int']>;
};

export type TokenMetadataSizedIconFilter = {
  and?: InputMaybe<Array<InputMaybe<TokenMetadataSizedIconFilter>>>;
  has?: InputMaybe<Array<InputMaybe<TokenMetadataSizedIconHasFilter>>>;
  not?: InputMaybe<TokenMetadataSizedIconFilter>;
  or?: InputMaybe<Array<InputMaybe<TokenMetadataSizedIconFilter>>>;
};

export enum TokenMetadataSizedIconHasFilter {
  Icon = 'icon',
  Size = 'size'
}

export type TokenMetadataSizedIconOrder = {
  asc?: InputMaybe<TokenMetadataSizedIconOrderable>;
  desc?: InputMaybe<TokenMetadataSizedIconOrderable>;
  then?: InputMaybe<TokenMetadataSizedIconOrder>;
};

export enum TokenMetadataSizedIconOrderable {
  Icon = 'icon',
  Size = 'size'
}

export type TokenMetadataSizedIconPatch = {
  /** https only url that refers to metadata stored offchain. */
  icon?: InputMaybe<Scalars['String']>;
  /** Most likely one of 16, 32, 64, 96, 128 */
  size?: InputMaybe<Scalars['Int']>;
};

export type TokenMetadataSizedIconRef = {
  /** https only url that refers to metadata stored offchain. */
  icon?: InputMaybe<Scalars['String']>;
  /** Most likely one of 16, 32, 64, 96, 128 */
  size?: InputMaybe<Scalars['Int']>;
};

export type TokenOrder = {
  asc?: InputMaybe<TokenOrderable>;
  desc?: InputMaybe<TokenOrderable>;
  then?: InputMaybe<TokenOrder>;
};

export enum TokenOrderable {
  Quantity = 'quantity'
}

export type TokenPatch = {
  asset?: InputMaybe<AssetRef>;
  quantity?: InputMaybe<Scalars['String']>;
  transactionOutput?: InputMaybe<TransactionOutputRef>;
};

export type TokenRef = {
  asset?: InputMaybe<AssetRef>;
  quantity?: InputMaybe<Scalars['String']>;
  transactionOutput?: InputMaybe<TransactionOutputRef>;
};

export type Transaction = {
  __typename?: 'Transaction';
  auxiliaryData?: Maybe<AuxiliaryData>;
  block: Block;
  certificates?: Maybe<Array<Certificate>>;
  collateral?: Maybe<Array<TransactionInput>>;
  collateralAggregate?: Maybe<TransactionInputAggregateResult>;
  deposit: Scalars['Int64'];
  fee: Scalars['Int64'];
  hash: Scalars['String'];
  index: Scalars['Int'];
  inputs: Array<TransactionInput>;
  inputsAggregate?: Maybe<TransactionInputAggregateResult>;
  invalidBefore?: Maybe<Slot>;
  invalidHereafter?: Maybe<Slot>;
  mint?: Maybe<Array<Token>>;
  mintAggregate?: Maybe<TokenAggregateResult>;
  outputs: Array<TransactionOutput>;
  outputsAggregate?: Maybe<TransactionOutputAggregateResult>;
  requiredExtraSignatures?: Maybe<Array<PublicKey>>;
  requiredExtraSignaturesAggregate?: Maybe<PublicKeyAggregateResult>;
  scriptIntegrityHash?: Maybe<Scalars['String']>;
  size: Scalars['Int64'];
  totalOutputCoin: Scalars['Int64'];
  validContract: Scalars['Boolean'];
  withdrawals?: Maybe<Array<Withdrawal>>;
  withdrawalsAggregate?: Maybe<WithdrawalAggregateResult>;
  witness: Witness;
};


export type TransactionAuxiliaryDataArgs = {
  filter?: InputMaybe<AuxiliaryDataFilter>;
};


export type TransactionBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
};


export type TransactionCertificatesArgs = {
  filter?: InputMaybe<CertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};


export type TransactionCollateralArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionInputOrder>;
};


export type TransactionCollateralAggregateArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
};


export type TransactionInputsArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionInputOrder>;
};


export type TransactionInputsAggregateArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
};


export type TransactionInvalidBeforeArgs = {
  filter?: InputMaybe<SlotFilter>;
};


export type TransactionInvalidHereafterArgs = {
  filter?: InputMaybe<SlotFilter>;
};


export type TransactionMintArgs = {
  filter?: InputMaybe<TokenFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenOrder>;
};


export type TransactionMintAggregateArgs = {
  filter?: InputMaybe<TokenFilter>;
};


export type TransactionOutputsArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOutputOrder>;
};


export type TransactionOutputsAggregateArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
};


export type TransactionRequiredExtraSignaturesArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PublicKeyOrder>;
};


export type TransactionRequiredExtraSignaturesAggregateArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
};


export type TransactionWithdrawalsArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WithdrawalOrder>;
};


export type TransactionWithdrawalsAggregateArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
};


export type TransactionWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
};

export type TransactionAggregateResult = {
  __typename?: 'TransactionAggregateResult';
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
  indexAvg?: Maybe<Scalars['Float']>;
  indexMax?: Maybe<Scalars['Int']>;
  indexMin?: Maybe<Scalars['Int']>;
  indexSum?: Maybe<Scalars['Int']>;
  scriptIntegrityHashMax?: Maybe<Scalars['String']>;
  scriptIntegrityHashMin?: Maybe<Scalars['String']>;
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
  and?: InputMaybe<Array<InputMaybe<TransactionFilter>>>;
  has?: InputMaybe<Array<InputMaybe<TransactionHasFilter>>>;
  hash?: InputMaybe<StringHashFilter>;
  not?: InputMaybe<TransactionFilter>;
  or?: InputMaybe<Array<InputMaybe<TransactionFilter>>>;
};

export enum TransactionHasFilter {
  AuxiliaryData = 'auxiliaryData',
  Block = 'block',
  Certificates = 'certificates',
  Collateral = 'collateral',
  Deposit = 'deposit',
  Fee = 'fee',
  Hash = 'hash',
  Index = 'index',
  Inputs = 'inputs',
  InvalidBefore = 'invalidBefore',
  InvalidHereafter = 'invalidHereafter',
  Mint = 'mint',
  Outputs = 'outputs',
  RequiredExtraSignatures = 'requiredExtraSignatures',
  ScriptIntegrityHash = 'scriptIntegrityHash',
  Size = 'size',
  TotalOutputCoin = 'totalOutputCoin',
  ValidContract = 'validContract',
  Withdrawals = 'withdrawals',
  Witness = 'witness'
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
  filter?: InputMaybe<AddressFilter>;
};


export type TransactionInputRedeemerArgs = {
  filter?: InputMaybe<RedeemerFilter>;
};


export type TransactionInputSourceTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};


export type TransactionInputTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};


export type TransactionInputValueArgs = {
  filter?: InputMaybe<ValueFilter>;
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
  and?: InputMaybe<Array<InputMaybe<TransactionInputFilter>>>;
  has?: InputMaybe<Array<InputMaybe<TransactionInputHasFilter>>>;
  not?: InputMaybe<TransactionInputFilter>;
  or?: InputMaybe<Array<InputMaybe<TransactionInputFilter>>>;
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
  asc?: InputMaybe<TransactionInputOrderable>;
  desc?: InputMaybe<TransactionInputOrderable>;
  then?: InputMaybe<TransactionInputOrder>;
};

export enum TransactionInputOrderable {
  Index = 'index'
}

export type TransactionInputPatch = {
  address?: InputMaybe<AddressRef>;
  index?: InputMaybe<Scalars['Int']>;
  redeemer?: InputMaybe<RedeemerRef>;
  sourceTransaction?: InputMaybe<TransactionRef>;
  transaction?: InputMaybe<TransactionRef>;
  value?: InputMaybe<ValueRef>;
};

export type TransactionInputRef = {
  address?: InputMaybe<AddressRef>;
  index?: InputMaybe<Scalars['Int']>;
  redeemer?: InputMaybe<RedeemerRef>;
  sourceTransaction?: InputMaybe<TransactionRef>;
  transaction?: InputMaybe<TransactionRef>;
  value?: InputMaybe<ValueRef>;
};

export type TransactionOrder = {
  asc?: InputMaybe<TransactionOrderable>;
  desc?: InputMaybe<TransactionOrderable>;
  then?: InputMaybe<TransactionOrder>;
};

export enum TransactionOrderable {
  Deposit = 'deposit',
  Fee = 'fee',
  Hash = 'hash',
  Index = 'index',
  ScriptIntegrityHash = 'scriptIntegrityHash',
  Size = 'size',
  TotalOutputCoin = 'totalOutputCoin'
}

export type TransactionOutput = {
  __typename?: 'TransactionOutput';
  address: Address;
  /** hex-encoded 32 byte hash */
  datumHash?: Maybe<Scalars['String']>;
  index: Scalars['Int'];
  transaction: Transaction;
  value: Value;
};


export type TransactionOutputAddressArgs = {
  filter?: InputMaybe<AddressFilter>;
};


export type TransactionOutputTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};


export type TransactionOutputValueArgs = {
  filter?: InputMaybe<ValueFilter>;
};

export type TransactionOutputAggregateResult = {
  __typename?: 'TransactionOutputAggregateResult';
  count?: Maybe<Scalars['Int']>;
  datumHashMax?: Maybe<Scalars['String']>;
  datumHashMin?: Maybe<Scalars['String']>;
  indexAvg?: Maybe<Scalars['Float']>;
  indexMax?: Maybe<Scalars['Int']>;
  indexMin?: Maybe<Scalars['Int']>;
  indexSum?: Maybe<Scalars['Int']>;
};

export type TransactionOutputFilter = {
  and?: InputMaybe<Array<InputMaybe<TransactionOutputFilter>>>;
  has?: InputMaybe<Array<InputMaybe<TransactionOutputHasFilter>>>;
  not?: InputMaybe<TransactionOutputFilter>;
  or?: InputMaybe<Array<InputMaybe<TransactionOutputFilter>>>;
};

export enum TransactionOutputHasFilter {
  Address = 'address',
  DatumHash = 'datumHash',
  Index = 'index',
  Transaction = 'transaction',
  Value = 'value'
}

export type TransactionOutputOrder = {
  asc?: InputMaybe<TransactionOutputOrderable>;
  desc?: InputMaybe<TransactionOutputOrderable>;
  then?: InputMaybe<TransactionOutputOrder>;
};

export enum TransactionOutputOrderable {
  DatumHash = 'datumHash',
  Index = 'index'
}

export type TransactionOutputPatch = {
  address?: InputMaybe<AddressRef>;
  /** hex-encoded 32 byte hash */
  datumHash?: InputMaybe<Scalars['String']>;
  index?: InputMaybe<Scalars['Int']>;
  transaction?: InputMaybe<TransactionRef>;
  value?: InputMaybe<ValueRef>;
};

export type TransactionOutputRef = {
  address?: InputMaybe<AddressRef>;
  /** hex-encoded 32 byte hash */
  datumHash?: InputMaybe<Scalars['String']>;
  index?: InputMaybe<Scalars['Int']>;
  transaction?: InputMaybe<TransactionRef>;
  value?: InputMaybe<ValueRef>;
};

export type TransactionPatch = {
  auxiliaryData?: InputMaybe<AuxiliaryDataRef>;
  block?: InputMaybe<BlockRef>;
  certificates?: InputMaybe<Array<CertificateRef>>;
  collateral?: InputMaybe<Array<TransactionInputRef>>;
  deposit?: InputMaybe<Scalars['Int64']>;
  fee?: InputMaybe<Scalars['Int64']>;
  index?: InputMaybe<Scalars['Int']>;
  inputs?: InputMaybe<Array<TransactionInputRef>>;
  invalidBefore?: InputMaybe<SlotRef>;
  invalidHereafter?: InputMaybe<SlotRef>;
  mint?: InputMaybe<Array<TokenRef>>;
  outputs?: InputMaybe<Array<TransactionOutputRef>>;
  requiredExtraSignatures?: InputMaybe<Array<PublicKeyRef>>;
  scriptIntegrityHash?: InputMaybe<Scalars['String']>;
  size?: InputMaybe<Scalars['Int64']>;
  totalOutputCoin?: InputMaybe<Scalars['Int64']>;
  validContract?: InputMaybe<Scalars['Boolean']>;
  withdrawals?: InputMaybe<Array<WithdrawalRef>>;
  witness?: InputMaybe<WitnessRef>;
};

export type TransactionRef = {
  auxiliaryData?: InputMaybe<AuxiliaryDataRef>;
  block?: InputMaybe<BlockRef>;
  certificates?: InputMaybe<Array<CertificateRef>>;
  collateral?: InputMaybe<Array<TransactionInputRef>>;
  deposit?: InputMaybe<Scalars['Int64']>;
  fee?: InputMaybe<Scalars['Int64']>;
  hash?: InputMaybe<Scalars['String']>;
  index?: InputMaybe<Scalars['Int']>;
  inputs?: InputMaybe<Array<TransactionInputRef>>;
  invalidBefore?: InputMaybe<SlotRef>;
  invalidHereafter?: InputMaybe<SlotRef>;
  mint?: InputMaybe<Array<TokenRef>>;
  outputs?: InputMaybe<Array<TransactionOutputRef>>;
  requiredExtraSignatures?: InputMaybe<Array<PublicKeyRef>>;
  scriptIntegrityHash?: InputMaybe<Scalars['String']>;
  size?: InputMaybe<Scalars['Int64']>;
  totalOutputCoin?: InputMaybe<Scalars['Int64']>;
  validContract?: InputMaybe<Scalars['Boolean']>;
  withdrawals?: InputMaybe<Array<WithdrawalRef>>;
  witness?: InputMaybe<WitnessRef>;
};

export type UpdateActiveStakeInput = {
  filter: ActiveStakeFilter;
  remove?: InputMaybe<ActiveStakePatch>;
  set?: InputMaybe<ActiveStakePatch>;
};

export type UpdateActiveStakePayload = {
  __typename?: 'UpdateActiveStakePayload';
  activeStake?: Maybe<Array<Maybe<ActiveStake>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateActiveStakePayloadActiveStakeArgs = {
  filter?: InputMaybe<ActiveStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ActiveStakeOrder>;
};

export type UpdateAdaInput = {
  filter: AdaFilter;
  remove?: InputMaybe<AdaPatch>;
  set?: InputMaybe<AdaPatch>;
};

export type UpdateAdaPayload = {
  __typename?: 'UpdateAdaPayload';
  ada?: Maybe<Array<Maybe<Ada>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAdaPayloadAdaArgs = {
  filter?: InputMaybe<AdaFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaOrder>;
};

export type UpdateAdaPotsInput = {
  filter: AdaPotsFilter;
  remove?: InputMaybe<AdaPotsPatch>;
  set?: InputMaybe<AdaPotsPatch>;
};

export type UpdateAdaPotsPayload = {
  __typename?: 'UpdateAdaPotsPayload';
  adaPots?: Maybe<Array<Maybe<AdaPots>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAdaPotsPayloadAdaPotsArgs = {
  filter?: InputMaybe<AdaPotsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AdaPotsOrder>;
};

export type UpdateAddressInput = {
  filter: AddressFilter;
  remove?: InputMaybe<AddressPatch>;
  set?: InputMaybe<AddressPatch>;
};

export type UpdateAddressPayload = {
  __typename?: 'UpdateAddressPayload';
  address?: Maybe<Array<Maybe<Address>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAddressPayloadAddressArgs = {
  filter?: InputMaybe<AddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AddressOrder>;
};

export type UpdateAssetInput = {
  filter: AssetFilter;
  remove?: InputMaybe<AssetPatch>;
  set?: InputMaybe<AssetPatch>;
};

export type UpdateAssetMintOrBurnInput = {
  filter: AssetMintOrBurnFilter;
  remove?: InputMaybe<AssetMintOrBurnPatch>;
  set?: InputMaybe<AssetMintOrBurnPatch>;
};

export type UpdateAssetMintOrBurnPayload = {
  __typename?: 'UpdateAssetMintOrBurnPayload';
  assetMintOrBurn?: Maybe<Array<Maybe<AssetMintOrBurn>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAssetMintOrBurnPayloadAssetMintOrBurnArgs = {
  filter?: InputMaybe<AssetMintOrBurnFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetMintOrBurnOrder>;
};

export type UpdateAssetPayload = {
  __typename?: 'UpdateAssetPayload';
  asset?: Maybe<Array<Maybe<Asset>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAssetPayloadAssetArgs = {
  filter?: InputMaybe<AssetFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AssetOrder>;
};

export type UpdateAuxiliaryDataBodyInput = {
  filter: AuxiliaryDataBodyFilter;
  remove?: InputMaybe<AuxiliaryDataBodyPatch>;
  set?: InputMaybe<AuxiliaryDataBodyPatch>;
};

export type UpdateAuxiliaryDataBodyPayload = {
  __typename?: 'UpdateAuxiliaryDataBodyPayload';
  auxiliaryDataBody?: Maybe<Array<Maybe<AuxiliaryDataBody>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAuxiliaryDataBodyPayloadAuxiliaryDataBodyArgs = {
  filter?: InputMaybe<AuxiliaryDataBodyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateAuxiliaryDataInput = {
  filter: AuxiliaryDataFilter;
  remove?: InputMaybe<AuxiliaryDataPatch>;
  set?: InputMaybe<AuxiliaryDataPatch>;
};

export type UpdateAuxiliaryDataPayload = {
  __typename?: 'UpdateAuxiliaryDataPayload';
  auxiliaryData?: Maybe<Array<Maybe<AuxiliaryData>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAuxiliaryDataPayloadAuxiliaryDataArgs = {
  filter?: InputMaybe<AuxiliaryDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<AuxiliaryDataOrder>;
};

export type UpdateAuxiliaryScriptInput = {
  filter: AuxiliaryScriptFilter;
  remove?: InputMaybe<AuxiliaryScriptPatch>;
  set?: InputMaybe<AuxiliaryScriptPatch>;
};

export type UpdateAuxiliaryScriptPayload = {
  __typename?: 'UpdateAuxiliaryScriptPayload';
  auxiliaryScript?: Maybe<Array<Maybe<AuxiliaryScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAuxiliaryScriptPayloadAuxiliaryScriptArgs = {
  filter?: InputMaybe<AuxiliaryScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateBlockInput = {
  filter: BlockFilter;
  remove?: InputMaybe<BlockPatch>;
  set?: InputMaybe<BlockPatch>;
};

export type UpdateBlockPayload = {
  __typename?: 'UpdateBlockPayload';
  block?: Maybe<Array<Maybe<Block>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateBlockPayloadBlockArgs = {
  filter?: InputMaybe<BlockFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BlockOrder>;
};

export type UpdateBootstrapWitnessInput = {
  filter: BootstrapWitnessFilter;
  remove?: InputMaybe<BootstrapWitnessPatch>;
  set?: InputMaybe<BootstrapWitnessPatch>;
};

export type UpdateBootstrapWitnessPayload = {
  __typename?: 'UpdateBootstrapWitnessPayload';
  bootstrapWitness?: Maybe<Array<Maybe<BootstrapWitness>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateBootstrapWitnessPayloadBootstrapWitnessArgs = {
  filter?: InputMaybe<BootstrapWitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BootstrapWitnessOrder>;
};

export type UpdateBytesMetadatumInput = {
  filter: BytesMetadatumFilter;
  remove?: InputMaybe<BytesMetadatumPatch>;
  set?: InputMaybe<BytesMetadatumPatch>;
};

export type UpdateBytesMetadatumPayload = {
  __typename?: 'UpdateBytesMetadatumPayload';
  bytesMetadatum?: Maybe<Array<Maybe<BytesMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateBytesMetadatumPayloadBytesMetadatumArgs = {
  filter?: InputMaybe<BytesMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BytesMetadatumOrder>;
};

export type UpdateCoinSupplyInput = {
  filter: CoinSupplyFilter;
  remove?: InputMaybe<CoinSupplyPatch>;
  set?: InputMaybe<CoinSupplyPatch>;
};

export type UpdateCoinSupplyPayload = {
  __typename?: 'UpdateCoinSupplyPayload';
  coinSupply?: Maybe<Array<Maybe<CoinSupply>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateCoinSupplyPayloadCoinSupplyArgs = {
  filter?: InputMaybe<CoinSupplyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CoinSupplyOrder>;
};

export type UpdateCostModelCoefficientInput = {
  filter: CostModelCoefficientFilter;
  remove?: InputMaybe<CostModelCoefficientPatch>;
  set?: InputMaybe<CostModelCoefficientPatch>;
};

export type UpdateCostModelCoefficientPayload = {
  __typename?: 'UpdateCostModelCoefficientPayload';
  costModelCoefficient?: Maybe<Array<Maybe<CostModelCoefficient>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateCostModelCoefficientPayloadCostModelCoefficientArgs = {
  filter?: InputMaybe<CostModelCoefficientFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelCoefficientOrder>;
};

export type UpdateCostModelInput = {
  filter: CostModelFilter;
  remove?: InputMaybe<CostModelPatch>;
  set?: InputMaybe<CostModelPatch>;
};

export type UpdateCostModelPayload = {
  __typename?: 'UpdateCostModelPayload';
  costModel?: Maybe<Array<Maybe<CostModel>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateCostModelPayloadCostModelArgs = {
  filter?: InputMaybe<CostModelFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<CostModelOrder>;
};

export type UpdateDatumInput = {
  filter: DatumFilter;
  remove?: InputMaybe<DatumPatch>;
  set?: InputMaybe<DatumPatch>;
};

export type UpdateDatumPayload = {
  __typename?: 'UpdateDatumPayload';
  datum?: Maybe<Array<Maybe<Datum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateDatumPayloadDatumArgs = {
  filter?: InputMaybe<DatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<DatumOrder>;
};

export type UpdateEpochInput = {
  filter: EpochFilter;
  remove?: InputMaybe<EpochPatch>;
  set?: InputMaybe<EpochPatch>;
};

export type UpdateEpochPayload = {
  __typename?: 'UpdateEpochPayload';
  epoch?: Maybe<Array<Maybe<Epoch>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateEpochPayloadEpochArgs = {
  filter?: InputMaybe<EpochFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<EpochOrder>;
};

export type UpdateExecutionPricesInput = {
  filter: ExecutionPricesFilter;
  remove?: InputMaybe<ExecutionPricesPatch>;
  set?: InputMaybe<ExecutionPricesPatch>;
};

export type UpdateExecutionPricesPayload = {
  __typename?: 'UpdateExecutionPricesPayload';
  executionPrices?: Maybe<Array<Maybe<ExecutionPrices>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExecutionPricesPayloadExecutionPricesArgs = {
  filter?: InputMaybe<ExecutionPricesFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateExecutionUnitsInput = {
  filter: ExecutionUnitsFilter;
  remove?: InputMaybe<ExecutionUnitsPatch>;
  set?: InputMaybe<ExecutionUnitsPatch>;
};

export type UpdateExecutionUnitsPayload = {
  __typename?: 'UpdateExecutionUnitsPayload';
  executionUnits?: Maybe<Array<Maybe<ExecutionUnits>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExecutionUnitsPayloadExecutionUnitsArgs = {
  filter?: InputMaybe<ExecutionUnitsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExecutionUnitsOrder>;
};

export type UpdateExtendedStakePoolMetadataFieldsInput = {
  filter: ExtendedStakePoolMetadataFieldsFilter;
  remove?: InputMaybe<ExtendedStakePoolMetadataFieldsPatch>;
  set?: InputMaybe<ExtendedStakePoolMetadataFieldsPatch>;
};

export type UpdateExtendedStakePoolMetadataFieldsPayload = {
  __typename?: 'UpdateExtendedStakePoolMetadataFieldsPayload';
  extendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExtendedStakePoolMetadataFieldsPayloadExtendedStakePoolMetadataFieldsArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFieldsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataFieldsOrder>;
};

export type UpdateExtendedStakePoolMetadataInput = {
  filter: ExtendedStakePoolMetadataFilter;
  remove?: InputMaybe<ExtendedStakePoolMetadataPatch>;
  set?: InputMaybe<ExtendedStakePoolMetadataPatch>;
};

export type UpdateExtendedStakePoolMetadataPayload = {
  __typename?: 'UpdateExtendedStakePoolMetadataPayload';
  extendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateExtendedStakePoolMetadataPayloadExtendedStakePoolMetadataArgs = {
  filter?: InputMaybe<ExtendedStakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ExtendedStakePoolMetadataOrder>;
};

export type UpdateGenesisKeyDelegationCertificateInput = {
  filter: GenesisKeyDelegationCertificateFilter;
  remove?: InputMaybe<GenesisKeyDelegationCertificatePatch>;
  set?: InputMaybe<GenesisKeyDelegationCertificatePatch>;
};

export type UpdateGenesisKeyDelegationCertificatePayload = {
  __typename?: 'UpdateGenesisKeyDelegationCertificatePayload';
  genesisKeyDelegationCertificate?: Maybe<Array<Maybe<GenesisKeyDelegationCertificate>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateGenesisKeyDelegationCertificatePayloadGenesisKeyDelegationCertificateArgs = {
  filter?: InputMaybe<GenesisKeyDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<GenesisKeyDelegationCertificateOrder>;
};

export type UpdateItnVerificationInput = {
  filter: ItnVerificationFilter;
  remove?: InputMaybe<ItnVerificationPatch>;
  set?: InputMaybe<ItnVerificationPatch>;
};

export type UpdateItnVerificationPayload = {
  __typename?: 'UpdateITNVerificationPayload';
  iTNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateItnVerificationPayloadITnVerificationArgs = {
  filter?: InputMaybe<ItnVerificationFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ItnVerificationOrder>;
};

export type UpdateIntegerMetadatumInput = {
  filter: IntegerMetadatumFilter;
  remove?: InputMaybe<IntegerMetadatumPatch>;
  set?: InputMaybe<IntegerMetadatumPatch>;
};

export type UpdateIntegerMetadatumPayload = {
  __typename?: 'UpdateIntegerMetadatumPayload';
  integerMetadatum?: Maybe<Array<Maybe<IntegerMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateIntegerMetadatumPayloadIntegerMetadatumArgs = {
  filter?: InputMaybe<IntegerMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<IntegerMetadatumOrder>;
};

export type UpdateKeyValueMetadatumInput = {
  filter: KeyValueMetadatumFilter;
  remove?: InputMaybe<KeyValueMetadatumPatch>;
  set?: InputMaybe<KeyValueMetadatumPatch>;
};

export type UpdateKeyValueMetadatumPayload = {
  __typename?: 'UpdateKeyValueMetadatumPayload';
  keyValueMetadatum?: Maybe<Array<Maybe<KeyValueMetadatum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateKeyValueMetadatumPayloadKeyValueMetadatumArgs = {
  filter?: InputMaybe<KeyValueMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<KeyValueMetadatumOrder>;
};

export type UpdateMetadatumArrayInput = {
  filter: MetadatumArrayFilter;
  remove?: InputMaybe<MetadatumArrayPatch>;
  set?: InputMaybe<MetadatumArrayPatch>;
};

export type UpdateMetadatumArrayPayload = {
  __typename?: 'UpdateMetadatumArrayPayload';
  metadatumArray?: Maybe<Array<Maybe<MetadatumArray>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateMetadatumArrayPayloadMetadatumArrayArgs = {
  filter?: InputMaybe<MetadatumArrayFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateMetadatumMapInput = {
  filter: MetadatumMapFilter;
  remove?: InputMaybe<MetadatumMapPatch>;
  set?: InputMaybe<MetadatumMapPatch>;
};

export type UpdateMetadatumMapPayload = {
  __typename?: 'UpdateMetadatumMapPayload';
  metadatumMap?: Maybe<Array<Maybe<MetadatumMap>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateMetadatumMapPayloadMetadatumMapArgs = {
  filter?: InputMaybe<MetadatumMapFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateMirCertificateInput = {
  filter: MirCertificateFilter;
  remove?: InputMaybe<MirCertificatePatch>;
  set?: InputMaybe<MirCertificatePatch>;
};

export type UpdateMirCertificatePayload = {
  __typename?: 'UpdateMirCertificatePayload';
  mirCertificate?: Maybe<Array<Maybe<MirCertificate>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateMirCertificatePayloadMirCertificateArgs = {
  filter?: InputMaybe<MirCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<MirCertificateOrder>;
};

export type UpdateNOfInput = {
  filter: NOfFilter;
  remove?: InputMaybe<NOfPatch>;
  set?: InputMaybe<NOfPatch>;
};

export type UpdateNOfPayload = {
  __typename?: 'UpdateNOfPayload';
  nOf?: Maybe<Array<Maybe<NOf>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNOfPayloadNOfArgs = {
  filter?: InputMaybe<NOfFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NOfOrder>;
};

export type UpdateNativeScriptInput = {
  filter: NativeScriptFilter;
  remove?: InputMaybe<NativeScriptPatch>;
  set?: InputMaybe<NativeScriptPatch>;
};

export type UpdateNativeScriptPayload = {
  __typename?: 'UpdateNativeScriptPayload';
  nativeScript?: Maybe<Array<Maybe<NativeScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNativeScriptPayloadNativeScriptArgs = {
  filter?: InputMaybe<NativeScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateNetworkConstantsInput = {
  filter: NetworkConstantsFilter;
  remove?: InputMaybe<NetworkConstantsPatch>;
  set?: InputMaybe<NetworkConstantsPatch>;
};

export type UpdateNetworkConstantsPayload = {
  __typename?: 'UpdateNetworkConstantsPayload';
  networkConstants?: Maybe<Array<Maybe<NetworkConstants>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNetworkConstantsPayloadNetworkConstantsArgs = {
  filter?: InputMaybe<NetworkConstantsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NetworkConstantsOrder>;
};

export type UpdateNftMetadataFileInput = {
  filter: NftMetadataFileFilter;
  remove?: InputMaybe<NftMetadataFilePatch>;
  set?: InputMaybe<NftMetadataFilePatch>;
};

export type UpdateNftMetadataFilePayload = {
  __typename?: 'UpdateNftMetadataFilePayload';
  nftMetadataFile?: Maybe<Array<Maybe<NftMetadataFile>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNftMetadataFilePayloadNftMetadataFileArgs = {
  filter?: InputMaybe<NftMetadataFileFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataFileOrder>;
};

export type UpdateNftMetadataInput = {
  filter: NftMetadataFilter;
  remove?: InputMaybe<NftMetadataPatch>;
  set?: InputMaybe<NftMetadataPatch>;
};

export type UpdateNftMetadataPayload = {
  __typename?: 'UpdateNftMetadataPayload';
  nftMetadata?: Maybe<Array<Maybe<NftMetadata>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNftMetadataPayloadNftMetadataArgs = {
  filter?: InputMaybe<NftMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<NftMetadataOrder>;
};

export type UpdatePlutusScriptInput = {
  filter: PlutusScriptFilter;
  remove?: InputMaybe<PlutusScriptPatch>;
  set?: InputMaybe<PlutusScriptPatch>;
};

export type UpdatePlutusScriptPayload = {
  __typename?: 'UpdatePlutusScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  plutusScript?: Maybe<Array<Maybe<PlutusScript>>>;
};


export type UpdatePlutusScriptPayloadPlutusScriptArgs = {
  filter?: InputMaybe<PlutusScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PlutusScriptOrder>;
};

export type UpdatePolicyInput = {
  filter: PolicyFilter;
  remove?: InputMaybe<PolicyPatch>;
  set?: InputMaybe<PolicyPatch>;
};

export type UpdatePolicyPayload = {
  __typename?: 'UpdatePolicyPayload';
  numUids?: Maybe<Scalars['Int']>;
  policy?: Maybe<Array<Maybe<Policy>>>;
};


export type UpdatePolicyPayloadPolicyArgs = {
  filter?: InputMaybe<PolicyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PolicyOrder>;
};

export type UpdatePoolContactDataInput = {
  filter: PoolContactDataFilter;
  remove?: InputMaybe<PoolContactDataPatch>;
  set?: InputMaybe<PoolContactDataPatch>;
};

export type UpdatePoolContactDataPayload = {
  __typename?: 'UpdatePoolContactDataPayload';
  numUids?: Maybe<Scalars['Int']>;
  poolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
};


export type UpdatePoolContactDataPayloadPoolContactDataArgs = {
  filter?: InputMaybe<PoolContactDataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolContactDataOrder>;
};

export type UpdatePoolParametersInput = {
  filter: PoolParametersFilter;
  remove?: InputMaybe<PoolParametersPatch>;
  set?: InputMaybe<PoolParametersPatch>;
};

export type UpdatePoolParametersPayload = {
  __typename?: 'UpdatePoolParametersPayload';
  numUids?: Maybe<Scalars['Int']>;
  poolParameters?: Maybe<Array<Maybe<PoolParameters>>>;
};


export type UpdatePoolParametersPayloadPoolParametersArgs = {
  filter?: InputMaybe<PoolParametersFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PoolParametersOrder>;
};

export type UpdatePoolRegistrationCertificateInput = {
  filter: PoolRegistrationCertificateFilter;
  remove?: InputMaybe<PoolRegistrationCertificatePatch>;
  set?: InputMaybe<PoolRegistrationCertificatePatch>;
};

export type UpdatePoolRegistrationCertificatePayload = {
  __typename?: 'UpdatePoolRegistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  poolRegistrationCertificate?: Maybe<Array<Maybe<PoolRegistrationCertificate>>>;
};


export type UpdatePoolRegistrationCertificatePayloadPoolRegistrationCertificateArgs = {
  filter?: InputMaybe<PoolRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdatePoolRetirementCertificateInput = {
  filter: PoolRetirementCertificateFilter;
  remove?: InputMaybe<PoolRetirementCertificatePatch>;
  set?: InputMaybe<PoolRetirementCertificatePatch>;
};

export type UpdatePoolRetirementCertificatePayload = {
  __typename?: 'UpdatePoolRetirementCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  poolRetirementCertificate?: Maybe<Array<Maybe<PoolRetirementCertificate>>>;
};


export type UpdatePoolRetirementCertificatePayloadPoolRetirementCertificateArgs = {
  filter?: InputMaybe<PoolRetirementCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateProtocolParametersAlonzoInput = {
  filter: ProtocolParametersAlonzoFilter;
  remove?: InputMaybe<ProtocolParametersAlonzoPatch>;
  set?: InputMaybe<ProtocolParametersAlonzoPatch>;
};

export type UpdateProtocolParametersAlonzoPayload = {
  __typename?: 'UpdateProtocolParametersAlonzoPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersAlonzo?: Maybe<Array<Maybe<ProtocolParametersAlonzo>>>;
};


export type UpdateProtocolParametersAlonzoPayloadProtocolParametersAlonzoArgs = {
  filter?: InputMaybe<ProtocolParametersAlonzoFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersAlonzoOrder>;
};

export type UpdateProtocolParametersShelleyInput = {
  filter: ProtocolParametersShelleyFilter;
  remove?: InputMaybe<ProtocolParametersShelleyPatch>;
  set?: InputMaybe<ProtocolParametersShelleyPatch>;
};

export type UpdateProtocolParametersShelleyPayload = {
  __typename?: 'UpdateProtocolParametersShelleyPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersShelley?: Maybe<Array<Maybe<ProtocolParametersShelley>>>;
};


export type UpdateProtocolParametersShelleyPayloadProtocolParametersShelleyArgs = {
  filter?: InputMaybe<ProtocolParametersShelleyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolParametersShelleyOrder>;
};

export type UpdateProtocolVersionInput = {
  filter: ProtocolVersionFilter;
  remove?: InputMaybe<ProtocolVersionPatch>;
  set?: InputMaybe<ProtocolVersionPatch>;
};

export type UpdateProtocolVersionPayload = {
  __typename?: 'UpdateProtocolVersionPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolVersion?: Maybe<Array<Maybe<ProtocolVersion>>>;
};


export type UpdateProtocolVersionPayloadProtocolVersionArgs = {
  filter?: InputMaybe<ProtocolVersionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ProtocolVersionOrder>;
};

export type UpdatePublicKeyInput = {
  filter: PublicKeyFilter;
  remove?: InputMaybe<PublicKeyPatch>;
  set?: InputMaybe<PublicKeyPatch>;
};

export type UpdatePublicKeyPayload = {
  __typename?: 'UpdatePublicKeyPayload';
  numUids?: Maybe<Scalars['Int']>;
  publicKey?: Maybe<Array<Maybe<PublicKey>>>;
};


export type UpdatePublicKeyPayloadPublicKeyArgs = {
  filter?: InputMaybe<PublicKeyFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<PublicKeyOrder>;
};

export type UpdateRatioInput = {
  filter: RatioFilter;
  remove?: InputMaybe<RatioPatch>;
  set?: InputMaybe<RatioPatch>;
};

export type UpdateRatioPayload = {
  __typename?: 'UpdateRatioPayload';
  numUids?: Maybe<Scalars['Int']>;
  ratio?: Maybe<Array<Maybe<Ratio>>>;
};


export type UpdateRatioPayloadRatioArgs = {
  filter?: InputMaybe<RatioFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RatioOrder>;
};

export type UpdateRedeemerInput = {
  filter: RedeemerFilter;
  remove?: InputMaybe<RedeemerPatch>;
  set?: InputMaybe<RedeemerPatch>;
};

export type UpdateRedeemerPayload = {
  __typename?: 'UpdateRedeemerPayload';
  numUids?: Maybe<Scalars['Int']>;
  redeemer?: Maybe<Array<Maybe<Redeemer>>>;
};


export type UpdateRedeemerPayloadRedeemerArgs = {
  filter?: InputMaybe<RedeemerFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RedeemerOrder>;
};

export type UpdateRelayByAddressInput = {
  filter: RelayByAddressFilter;
  remove?: InputMaybe<RelayByAddressPatch>;
  set?: InputMaybe<RelayByAddressPatch>;
};

export type UpdateRelayByAddressPayload = {
  __typename?: 'UpdateRelayByAddressPayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
};


export type UpdateRelayByAddressPayloadRelayByAddressArgs = {
  filter?: InputMaybe<RelayByAddressFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByAddressOrder>;
};

export type UpdateRelayByNameInput = {
  filter: RelayByNameFilter;
  remove?: InputMaybe<RelayByNamePatch>;
  set?: InputMaybe<RelayByNamePatch>;
};

export type UpdateRelayByNameMultihostInput = {
  filter: RelayByNameMultihostFilter;
  remove?: InputMaybe<RelayByNameMultihostPatch>;
  set?: InputMaybe<RelayByNameMultihostPatch>;
};

export type UpdateRelayByNameMultihostPayload = {
  __typename?: 'UpdateRelayByNameMultihostPayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByNameMultihost?: Maybe<Array<Maybe<RelayByNameMultihost>>>;
};


export type UpdateRelayByNameMultihostPayloadRelayByNameMultihostArgs = {
  filter?: InputMaybe<RelayByNameMultihostFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameMultihostOrder>;
};

export type UpdateRelayByNamePayload = {
  __typename?: 'UpdateRelayByNamePayload';
  numUids?: Maybe<Scalars['Int']>;
  relayByName?: Maybe<Array<Maybe<RelayByName>>>;
};


export type UpdateRelayByNamePayloadRelayByNameArgs = {
  filter?: InputMaybe<RelayByNameFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RelayByNameOrder>;
};

export type UpdateRewardAccountInput = {
  filter: RewardAccountFilter;
  remove?: InputMaybe<RewardAccountPatch>;
  set?: InputMaybe<RewardAccountPatch>;
};

export type UpdateRewardAccountPayload = {
  __typename?: 'UpdateRewardAccountPayload';
  numUids?: Maybe<Scalars['Int']>;
  rewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
};


export type UpdateRewardAccountPayloadRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardAccountOrder>;
};

export type UpdateRewardInput = {
  filter: RewardFilter;
  remove?: InputMaybe<RewardPatch>;
  set?: InputMaybe<RewardPatch>;
};

export type UpdateRewardPayload = {
  __typename?: 'UpdateRewardPayload';
  numUids?: Maybe<Scalars['Int']>;
  reward?: Maybe<Array<Maybe<Reward>>>;
};


export type UpdateRewardPayloadRewardArgs = {
  filter?: InputMaybe<RewardFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RewardOrder>;
};

export type UpdateSignatureInput = {
  filter: SignatureFilter;
  remove?: InputMaybe<SignaturePatch>;
  set?: InputMaybe<SignaturePatch>;
};

export type UpdateSignaturePayload = {
  __typename?: 'UpdateSignaturePayload';
  numUids?: Maybe<Scalars['Int']>;
  signature?: Maybe<Array<Maybe<Signature>>>;
};


export type UpdateSignaturePayloadSignatureArgs = {
  filter?: InputMaybe<SignatureFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SignatureOrder>;
};

export type UpdateSlotInput = {
  filter: SlotFilter;
  remove?: InputMaybe<SlotPatch>;
  set?: InputMaybe<SlotPatch>;
};

export type UpdateSlotPayload = {
  __typename?: 'UpdateSlotPayload';
  numUids?: Maybe<Scalars['Int']>;
  slot?: Maybe<Array<Maybe<Slot>>>;
};


export type UpdateSlotPayloadSlotArgs = {
  filter?: InputMaybe<SlotFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SlotOrder>;
};

export type UpdateStakeDelegationCertificateInput = {
  filter: StakeDelegationCertificateFilter;
  remove?: InputMaybe<StakeDelegationCertificatePatch>;
  set?: InputMaybe<StakeDelegationCertificatePatch>;
};

export type UpdateStakeDelegationCertificatePayload = {
  __typename?: 'UpdateStakeDelegationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeDelegationCertificate?: Maybe<Array<Maybe<StakeDelegationCertificate>>>;
};


export type UpdateStakeDelegationCertificatePayloadStakeDelegationCertificateArgs = {
  filter?: InputMaybe<StakeDelegationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateStakeKeyDeregistrationCertificateInput = {
  filter: StakeKeyDeregistrationCertificateFilter;
  remove?: InputMaybe<StakeKeyDeregistrationCertificatePatch>;
  set?: InputMaybe<StakeKeyDeregistrationCertificatePatch>;
};

export type UpdateStakeKeyDeregistrationCertificatePayload = {
  __typename?: 'UpdateStakeKeyDeregistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyDeregistrationCertificate?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificate>>>;
};


export type UpdateStakeKeyDeregistrationCertificatePayloadStakeKeyDeregistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyDeregistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateStakeKeyRegistrationCertificateInput = {
  filter: StakeKeyRegistrationCertificateFilter;
  remove?: InputMaybe<StakeKeyRegistrationCertificatePatch>;
  set?: InputMaybe<StakeKeyRegistrationCertificatePatch>;
};

export type UpdateStakeKeyRegistrationCertificatePayload = {
  __typename?: 'UpdateStakeKeyRegistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyRegistrationCertificate?: Maybe<Array<Maybe<StakeKeyRegistrationCertificate>>>;
};


export type UpdateStakeKeyRegistrationCertificatePayloadStakeKeyRegistrationCertificateArgs = {
  filter?: InputMaybe<StakeKeyRegistrationCertificateFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateStakePoolEpochRewardsInput = {
  filter: StakePoolEpochRewardsFilter;
  remove?: InputMaybe<StakePoolEpochRewardsPatch>;
  set?: InputMaybe<StakePoolEpochRewardsPatch>;
};

export type UpdateStakePoolEpochRewardsPayload = {
  __typename?: 'UpdateStakePoolEpochRewardsPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolEpochRewards?: Maybe<Array<Maybe<StakePoolEpochRewards>>>;
};


export type UpdateStakePoolEpochRewardsPayloadStakePoolEpochRewardsArgs = {
  filter?: InputMaybe<StakePoolEpochRewardsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolEpochRewardsOrder>;
};

export type UpdateStakePoolInput = {
  filter: StakePoolFilter;
  remove?: InputMaybe<StakePoolPatch>;
  set?: InputMaybe<StakePoolPatch>;
};

export type UpdateStakePoolMetadataInput = {
  filter: StakePoolMetadataFilter;
  remove?: InputMaybe<StakePoolMetadataPatch>;
  set?: InputMaybe<StakePoolMetadataPatch>;
};

export type UpdateStakePoolMetadataJsonInput = {
  filter: StakePoolMetadataJsonFilter;
  remove?: InputMaybe<StakePoolMetadataJsonPatch>;
  set?: InputMaybe<StakePoolMetadataJsonPatch>;
};

export type UpdateStakePoolMetadataJsonPayload = {
  __typename?: 'UpdateStakePoolMetadataJsonPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
};


export type UpdateStakePoolMetadataJsonPayloadStakePoolMetadataJsonArgs = {
  filter?: InputMaybe<StakePoolMetadataJsonFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataJsonOrder>;
};

export type UpdateStakePoolMetadataPayload = {
  __typename?: 'UpdateStakePoolMetadataPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
};


export type UpdateStakePoolMetadataPayloadStakePoolMetadataArgs = {
  filter?: InputMaybe<StakePoolMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetadataOrder>;
};

export type UpdateStakePoolMetricsInput = {
  filter: StakePoolMetricsFilter;
  remove?: InputMaybe<StakePoolMetricsPatch>;
  set?: InputMaybe<StakePoolMetricsPatch>;
};

export type UpdateStakePoolMetricsPayload = {
  __typename?: 'UpdateStakePoolMetricsPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
};


export type UpdateStakePoolMetricsPayloadStakePoolMetricsArgs = {
  filter?: InputMaybe<StakePoolMetricsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsOrder>;
};

export type UpdateStakePoolMetricsSizeInput = {
  filter: StakePoolMetricsSizeFilter;
  remove?: InputMaybe<StakePoolMetricsSizePatch>;
  set?: InputMaybe<StakePoolMetricsSizePatch>;
};

export type UpdateStakePoolMetricsSizePayload = {
  __typename?: 'UpdateStakePoolMetricsSizePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
};


export type UpdateStakePoolMetricsSizePayloadStakePoolMetricsSizeArgs = {
  filter?: InputMaybe<StakePoolMetricsSizeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsSizeOrder>;
};

export type UpdateStakePoolMetricsStakeInput = {
  filter: StakePoolMetricsStakeFilter;
  remove?: InputMaybe<StakePoolMetricsStakePatch>;
  set?: InputMaybe<StakePoolMetricsStakePatch>;
};

export type UpdateStakePoolMetricsStakePayload = {
  __typename?: 'UpdateStakePoolMetricsStakePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
};


export type UpdateStakePoolMetricsStakePayloadStakePoolMetricsStakeArgs = {
  filter?: InputMaybe<StakePoolMetricsStakeFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolMetricsStakeOrder>;
};

export type UpdateStakePoolPayload = {
  __typename?: 'UpdateStakePoolPayload';
  numUids?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<Array<Maybe<StakePool>>>;
};


export type UpdateStakePoolPayloadStakePoolArgs = {
  filter?: InputMaybe<StakePoolFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StakePoolOrder>;
};

export type UpdateStringMetadatumInput = {
  filter: StringMetadatumFilter;
  remove?: InputMaybe<StringMetadatumPatch>;
  set?: InputMaybe<StringMetadatumPatch>;
};

export type UpdateStringMetadatumPayload = {
  __typename?: 'UpdateStringMetadatumPayload';
  numUids?: Maybe<Scalars['Int']>;
  stringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
};


export type UpdateStringMetadatumPayloadStringMetadatumArgs = {
  filter?: InputMaybe<StringMetadatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<StringMetadatumOrder>;
};

export type UpdateThePoolsMediaAssetsInput = {
  filter: ThePoolsMediaAssetsFilter;
  remove?: InputMaybe<ThePoolsMediaAssetsPatch>;
  set?: InputMaybe<ThePoolsMediaAssetsPatch>;
};

export type UpdateThePoolsMediaAssetsPayload = {
  __typename?: 'UpdateThePoolsMediaAssetsPayload';
  numUids?: Maybe<Scalars['Int']>;
  thePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
};


export type UpdateThePoolsMediaAssetsPayloadThePoolsMediaAssetsArgs = {
  filter?: InputMaybe<ThePoolsMediaAssetsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ThePoolsMediaAssetsOrder>;
};

export type UpdateTimeSettingsInput = {
  filter: TimeSettingsFilter;
  remove?: InputMaybe<TimeSettingsPatch>;
  set?: InputMaybe<TimeSettingsPatch>;
};

export type UpdateTimeSettingsPayload = {
  __typename?: 'UpdateTimeSettingsPayload';
  numUids?: Maybe<Scalars['Int']>;
  timeSettings?: Maybe<Array<Maybe<TimeSettings>>>;
};


export type UpdateTimeSettingsPayloadTimeSettingsArgs = {
  filter?: InputMaybe<TimeSettingsFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TimeSettingsOrder>;
};

export type UpdateTokenInput = {
  filter: TokenFilter;
  remove?: InputMaybe<TokenPatch>;
  set?: InputMaybe<TokenPatch>;
};

export type UpdateTokenMetadataInput = {
  filter: TokenMetadataFilter;
  remove?: InputMaybe<TokenMetadataPatch>;
  set?: InputMaybe<TokenMetadataPatch>;
};

export type UpdateTokenMetadataPayload = {
  __typename?: 'UpdateTokenMetadataPayload';
  numUids?: Maybe<Scalars['Int']>;
  tokenMetadata?: Maybe<Array<Maybe<TokenMetadata>>>;
};


export type UpdateTokenMetadataPayloadTokenMetadataArgs = {
  filter?: InputMaybe<TokenMetadataFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataOrder>;
};

export type UpdateTokenMetadataSizedIconInput = {
  filter: TokenMetadataSizedIconFilter;
  remove?: InputMaybe<TokenMetadataSizedIconPatch>;
  set?: InputMaybe<TokenMetadataSizedIconPatch>;
};

export type UpdateTokenMetadataSizedIconPayload = {
  __typename?: 'UpdateTokenMetadataSizedIconPayload';
  numUids?: Maybe<Scalars['Int']>;
  tokenMetadataSizedIcon?: Maybe<Array<Maybe<TokenMetadataSizedIcon>>>;
};


export type UpdateTokenMetadataSizedIconPayloadTokenMetadataSizedIconArgs = {
  filter?: InputMaybe<TokenMetadataSizedIconFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenMetadataSizedIconOrder>;
};

export type UpdateTokenPayload = {
  __typename?: 'UpdateTokenPayload';
  numUids?: Maybe<Scalars['Int']>;
  token?: Maybe<Array<Maybe<Token>>>;
};


export type UpdateTokenPayloadTokenArgs = {
  filter?: InputMaybe<TokenFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenOrder>;
};

export type UpdateTransactionInput = {
  filter: TransactionFilter;
  remove?: InputMaybe<TransactionPatch>;
  set?: InputMaybe<TransactionPatch>;
};

export type UpdateTransactionInputInput = {
  filter: TransactionInputFilter;
  remove?: InputMaybe<TransactionInputPatch>;
  set?: InputMaybe<TransactionInputPatch>;
};

export type UpdateTransactionInputPayload = {
  __typename?: 'UpdateTransactionInputPayload';
  numUids?: Maybe<Scalars['Int']>;
  transactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
};


export type UpdateTransactionInputPayloadTransactionInputArgs = {
  filter?: InputMaybe<TransactionInputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionInputOrder>;
};

export type UpdateTransactionOutputInput = {
  filter: TransactionOutputFilter;
  remove?: InputMaybe<TransactionOutputPatch>;
  set?: InputMaybe<TransactionOutputPatch>;
};

export type UpdateTransactionOutputPayload = {
  __typename?: 'UpdateTransactionOutputPayload';
  numUids?: Maybe<Scalars['Int']>;
  transactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
};


export type UpdateTransactionOutputPayloadTransactionOutputArgs = {
  filter?: InputMaybe<TransactionOutputFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOutputOrder>;
};

export type UpdateTransactionPayload = {
  __typename?: 'UpdateTransactionPayload';
  numUids?: Maybe<Scalars['Int']>;
  transaction?: Maybe<Array<Maybe<Transaction>>>;
};


export type UpdateTransactionPayloadTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TransactionOrder>;
};

export type UpdateValueInput = {
  filter: ValueFilter;
  remove?: InputMaybe<ValuePatch>;
  set?: InputMaybe<ValuePatch>;
};

export type UpdateValuePayload = {
  __typename?: 'UpdateValuePayload';
  numUids?: Maybe<Scalars['Int']>;
  value?: Maybe<Array<Maybe<Value>>>;
};


export type UpdateValuePayloadValueArgs = {
  filter?: InputMaybe<ValueFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<ValueOrder>;
};

export type UpdateWithdrawalInput = {
  filter: WithdrawalFilter;
  remove?: InputMaybe<WithdrawalPatch>;
  set?: InputMaybe<WithdrawalPatch>;
};

export type UpdateWithdrawalPayload = {
  __typename?: 'UpdateWithdrawalPayload';
  numUids?: Maybe<Scalars['Int']>;
  withdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
};


export type UpdateWithdrawalPayloadWithdrawalArgs = {
  filter?: InputMaybe<WithdrawalFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WithdrawalOrder>;
};

export type UpdateWitnessInput = {
  filter: WitnessFilter;
  remove?: InputMaybe<WitnessPatch>;
  set?: InputMaybe<WitnessPatch>;
};

export type UpdateWitnessPayload = {
  __typename?: 'UpdateWitnessPayload';
  numUids?: Maybe<Scalars['Int']>;
  witness?: Maybe<Array<Maybe<Witness>>>;
};


export type UpdateWitnessPayloadWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
};

export type UpdateWitnessScriptInput = {
  filter: WitnessScriptFilter;
  remove?: InputMaybe<WitnessScriptPatch>;
  set?: InputMaybe<WitnessScriptPatch>;
};

export type UpdateWitnessScriptPayload = {
  __typename?: 'UpdateWitnessScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  witnessScript?: Maybe<Array<Maybe<WitnessScript>>>;
};


export type UpdateWitnessScriptPayloadWitnessScriptArgs = {
  filter?: InputMaybe<WitnessScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WitnessScriptOrder>;
};

export type Value = {
  __typename?: 'Value';
  assets?: Maybe<Array<Token>>;
  assetsAggregate?: Maybe<TokenAggregateResult>;
  coin: Scalars['Int64'];
};


export type ValueAssetsArgs = {
  filter?: InputMaybe<TokenFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<TokenOrder>;
};


export type ValueAssetsAggregateArgs = {
  filter?: InputMaybe<TokenFilter>;
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
  and?: InputMaybe<Array<InputMaybe<ValueFilter>>>;
  has?: InputMaybe<Array<InputMaybe<ValueHasFilter>>>;
  not?: InputMaybe<ValueFilter>;
  or?: InputMaybe<Array<InputMaybe<ValueFilter>>>;
};

export enum ValueHasFilter {
  Assets = 'assets',
  Coin = 'coin'
}

export type ValueOrder = {
  asc?: InputMaybe<ValueOrderable>;
  desc?: InputMaybe<ValueOrderable>;
  then?: InputMaybe<ValueOrder>;
};

export enum ValueOrderable {
  Coin = 'coin'
}

export type ValuePatch = {
  assets?: InputMaybe<Array<TokenRef>>;
  coin?: InputMaybe<Scalars['Int64']>;
};

export type ValueRef = {
  assets?: InputMaybe<Array<TokenRef>>;
  coin?: InputMaybe<Scalars['Int64']>;
};

export type Withdrawal = {
  __typename?: 'Withdrawal';
  quantity: Scalars['Int64'];
  redeemer?: Maybe<Scalars['String']>;
  rewardAccount: RewardAccount;
  transaction: Transaction;
};


export type WithdrawalRewardAccountArgs = {
  filter?: InputMaybe<RewardAccountFilter>;
};


export type WithdrawalTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
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
  and?: InputMaybe<Array<InputMaybe<WithdrawalFilter>>>;
  has?: InputMaybe<Array<InputMaybe<WithdrawalHasFilter>>>;
  not?: InputMaybe<WithdrawalFilter>;
  or?: InputMaybe<Array<InputMaybe<WithdrawalFilter>>>;
};

export enum WithdrawalHasFilter {
  Quantity = 'quantity',
  Redeemer = 'redeemer',
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type WithdrawalOrder = {
  asc?: InputMaybe<WithdrawalOrderable>;
  desc?: InputMaybe<WithdrawalOrderable>;
  then?: InputMaybe<WithdrawalOrder>;
};

export enum WithdrawalOrderable {
  Quantity = 'quantity',
  Redeemer = 'redeemer'
}

export type WithdrawalPatch = {
  quantity?: InputMaybe<Scalars['Int64']>;
  redeemer?: InputMaybe<Scalars['String']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type WithdrawalRef = {
  quantity?: InputMaybe<Scalars['Int64']>;
  redeemer?: InputMaybe<Scalars['String']>;
  rewardAccount?: InputMaybe<RewardAccountRef>;
  transaction?: InputMaybe<TransactionRef>;
};

export type WithinFilter = {
  polygon: PolygonRef;
};

export type Witness = {
  __typename?: 'Witness';
  bootstrap?: Maybe<Array<BootstrapWitness>>;
  bootstrapAggregate?: Maybe<BootstrapWitnessAggregateResult>;
  datums?: Maybe<Array<Datum>>;
  datumsAggregate?: Maybe<DatumAggregateResult>;
  redeemers?: Maybe<Array<Redeemer>>;
  redeemersAggregate?: Maybe<RedeemerAggregateResult>;
  scripts?: Maybe<Array<WitnessScript>>;
  scriptsAggregate?: Maybe<WitnessScriptAggregateResult>;
  signatures: Array<Signature>;
  signaturesAggregate?: Maybe<SignatureAggregateResult>;
  transaction: Transaction;
};


export type WitnessBootstrapArgs = {
  filter?: InputMaybe<BootstrapWitnessFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<BootstrapWitnessOrder>;
};


export type WitnessBootstrapAggregateArgs = {
  filter?: InputMaybe<BootstrapWitnessFilter>;
};


export type WitnessDatumsArgs = {
  filter?: InputMaybe<DatumFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<DatumOrder>;
};


export type WitnessDatumsAggregateArgs = {
  filter?: InputMaybe<DatumFilter>;
};


export type WitnessRedeemersArgs = {
  filter?: InputMaybe<RedeemerFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<RedeemerOrder>;
};


export type WitnessRedeemersAggregateArgs = {
  filter?: InputMaybe<RedeemerFilter>;
};


export type WitnessScriptsArgs = {
  filter?: InputMaybe<WitnessScriptFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<WitnessScriptOrder>;
};


export type WitnessScriptsAggregateArgs = {
  filter?: InputMaybe<WitnessScriptFilter>;
};


export type WitnessSignaturesArgs = {
  filter?: InputMaybe<SignatureFilter>;
  first?: InputMaybe<Scalars['Int']>;
  offset?: InputMaybe<Scalars['Int']>;
  order?: InputMaybe<SignatureOrder>;
};


export type WitnessSignaturesAggregateArgs = {
  filter?: InputMaybe<SignatureFilter>;
};


export type WitnessTransactionArgs = {
  filter?: InputMaybe<TransactionFilter>;
};

export type WitnessAggregateResult = {
  __typename?: 'WitnessAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type WitnessFilter = {
  and?: InputMaybe<Array<InputMaybe<WitnessFilter>>>;
  has?: InputMaybe<Array<InputMaybe<WitnessHasFilter>>>;
  not?: InputMaybe<WitnessFilter>;
  or?: InputMaybe<Array<InputMaybe<WitnessFilter>>>;
};

export enum WitnessHasFilter {
  Bootstrap = 'bootstrap',
  Datums = 'datums',
  Redeemers = 'redeemers',
  Scripts = 'scripts',
  Signatures = 'signatures',
  Transaction = 'transaction'
}

export type WitnessPatch = {
  bootstrap?: InputMaybe<Array<BootstrapWitnessRef>>;
  datums?: InputMaybe<Array<DatumRef>>;
  redeemers?: InputMaybe<Array<RedeemerRef>>;
  scripts?: InputMaybe<Array<WitnessScriptRef>>;
  signatures?: InputMaybe<Array<SignatureRef>>;
  transaction?: InputMaybe<TransactionRef>;
};

export type WitnessRef = {
  bootstrap?: InputMaybe<Array<BootstrapWitnessRef>>;
  datums?: InputMaybe<Array<DatumRef>>;
  redeemers?: InputMaybe<Array<RedeemerRef>>;
  scripts?: InputMaybe<Array<WitnessScriptRef>>;
  signatures?: InputMaybe<Array<SignatureRef>>;
  transaction?: InputMaybe<TransactionRef>;
};

export type WitnessScript = {
  __typename?: 'WitnessScript';
  key: Scalars['String'];
  script: Script;
  witness: Witness;
};


export type WitnessScriptScriptArgs = {
  filter?: InputMaybe<ScriptFilter>;
};


export type WitnessScriptWitnessArgs = {
  filter?: InputMaybe<WitnessFilter>;
};

export type WitnessScriptAggregateResult = {
  __typename?: 'WitnessScriptAggregateResult';
  count?: Maybe<Scalars['Int']>;
  keyMax?: Maybe<Scalars['String']>;
  keyMin?: Maybe<Scalars['String']>;
};

export type WitnessScriptFilter = {
  and?: InputMaybe<Array<InputMaybe<WitnessScriptFilter>>>;
  has?: InputMaybe<Array<InputMaybe<WitnessScriptHasFilter>>>;
  not?: InputMaybe<WitnessScriptFilter>;
  or?: InputMaybe<Array<InputMaybe<WitnessScriptFilter>>>;
};

export enum WitnessScriptHasFilter {
  Key = 'key',
  Script = 'script',
  Witness = 'witness'
}

export type WitnessScriptOrder = {
  asc?: InputMaybe<WitnessScriptOrderable>;
  desc?: InputMaybe<WitnessScriptOrderable>;
  then?: InputMaybe<WitnessScriptOrder>;
};

export enum WitnessScriptOrderable {
  Key = 'key'
}

export type WitnessScriptPatch = {
  key?: InputMaybe<Scalars['String']>;
  script?: InputMaybe<ScriptRef>;
  witness?: InputMaybe<WitnessRef>;
};

export type WitnessScriptRef = {
  key?: InputMaybe<Scalars['String']>;
  script?: InputMaybe<ScriptRef>;
  witness?: InputMaybe<WitnessRef>;
};

export type AssetQueryVariables = Exact<{
  assetId: Scalars['String'];
}>;


export type AssetQuery = { __typename?: 'Query', queryAsset?: Array<{ __typename?: 'Asset', assetName: string, totalQuantity: number | bigint, fingerprint: string, policy: { __typename?: 'Policy', id: string }, history: Array<{ __typename?: 'AssetMintOrBurn', quantity: number | bigint, transaction: { __typename?: 'Transaction', hash: string } }>, tokenMetadata?: { __typename?: 'TokenMetadata', name: string, ticker?: string | null, icon?: string | null, url?: string | null, desc?: string | null, decimals?: number | null, ref?: string | null, version?: string | null, sizedIcons: Array<{ __typename?: 'TokenMetadataSizedIcon', size: number, icon: string }> } | null, nftMetadata?: { __typename?: 'NftMetadata', name: string, images: Array<string>, version: string, mediaType?: string | null, descriptions: Array<string>, files: Array<{ __typename?: 'NftMetadataFile', name: string, mediaType: string, src: Array<string> }> } | null } | null> | null };

export type BlocksByHashesQueryVariables = Exact<{
  hashes: Array<Scalars['String']> | Scalars['String'];
}>;


export type BlocksByHashesQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', size: number | bigint, totalOutput: number | bigint, totalFees: number | bigint, hash: string, blockNo: number, confirmations: number, slot: { __typename?: 'Slot', number: number, date: string, slotInEpoch: number }, issuer: { __typename?: 'StakePool', id: string, poolParameters: Array<{ __typename?: 'PoolParameters', vrf: string }> }, transactionsAggregate?: { __typename?: 'TransactionAggregateResult', count?: number | null } | null, epoch: { __typename?: 'Epoch', number: number }, previousBlock: { __typename?: 'Block', hash: string }, nextBlock: { __typename?: 'Block', hash: string } } | null> | null };

export type CurrentProtocolParametersQueryVariables = Exact<{ [key: string]: never; }>;


export type CurrentProtocolParametersQuery = { __typename?: 'Query', queryProtocolVersion?: Array<{ __typename?: 'ProtocolVersion', protocolParameters: { __typename?: 'ProtocolParametersAlonzo', coinsPerUtxoWord: number, maxTxSize: number, maxValueSize: number, stakeKeyDeposit: number, poolDeposit: number, maxCollateralInputs: number, minFeeCoefficient: number, minFeeConstant: number, minPoolCost: number, protocolVersion: { __typename?: 'ProtocolVersion', major: number, minor: number, patch?: number | null } } | { __typename?: 'ProtocolParametersShelley' } } | null> | null };

export type GenesisParametersQueryVariables = Exact<{ [key: string]: never; }>;


export type GenesisParametersQuery = { __typename?: 'Query', queryNetworkConstants?: Array<{ __typename?: 'NetworkConstants', systemStart: string, networkMagic: number, activeSlotsCoefficient: number, securityParameter: number, slotsPerKESPeriod: number, maxKESEvolutions: number, updateQuorum: number } | null> | null, queryTimeSettings?: Array<{ __typename?: 'TimeSettings', slotLength: number, epochLength: number } | null> | null, queryAda?: Array<{ __typename?: 'Ada', supply: { __typename?: 'CoinSupply', max: number | bigint } } | null> | null };

export type NetworkInfoQueryVariables = Exact<{ [key: string]: never; }>;


export type NetworkInfoQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', totalLiveStake: number | bigint, epoch: { __typename?: 'Epoch', number: number, startedAt: { __typename?: 'Slot', date: string }, activeStakeAggregate?: { __typename?: 'ActiveStakeAggregateResult', quantitySum?: number | bigint | null } | null } } | null> | null, queryTimeSettings?: Array<{ __typename?: 'TimeSettings', slotLength: number, epochLength: number } | null> | null, queryAda?: Array<{ __typename?: 'Ada', supply: { __typename?: 'CoinSupply', circulating: number | bigint, max: number | bigint, total: number | bigint } } | null> | null };

export type MemberRewardsHistoryQueryVariables = Exact<{
  rewardAccounts: Array<Scalars['String']> | Scalars['String'];
  fromEpochNo?: InputMaybe<Scalars['Int']>;
  toEpochNo?: InputMaybe<Scalars['Int']>;
}>;


export type MemberRewardsHistoryQuery = { __typename?: 'Query', queryRewardAccount?: Array<{ __typename?: 'RewardAccount', rewards: Array<{ __typename?: 'Reward', epochNo: number, quantity: number | bigint }> } | null> | null };

export type CertificateTransactionFieldsFragment = { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } };

export type AllPoolParameterFieldsFragment = { __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null };

export type AllStakePoolFieldsFragment = { __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, poolParameters: Array<{ __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null }>, metrics: Array<{ __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: number | bigint, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: number | bigint, active: number | bigint }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }>, poolRetirementCertificates: Array<{ __typename?: 'PoolRetirementCertificate', transaction: { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } } }>, epochRewards: Array<{ __typename?: 'StakePoolEpochRewards', epochNo: number, epochLength: number, activeStake: number | bigint, operatorFees: number | bigint, totalRewards: number | bigint, memberROI: number }> };

export type StakePoolsByMetadataQueryVariables = Exact<{
  query: Scalars['String'];
  omit?: InputMaybe<Array<Scalars['String']> | Scalars['String']>;
  epochRewardsLimit?: InputMaybe<Scalars['Int']>;
}>;


export type StakePoolsByMetadataQuery = { __typename?: 'Query', queryStakePoolMetadata?: Array<{ __typename?: 'StakePoolMetadata', poolParameters: { __typename?: 'PoolParameters', stakePool: { __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, poolParameters: Array<{ __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null }>, metrics: Array<{ __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: number | bigint, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: number | bigint, active: number | bigint }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }>, poolRetirementCertificates: Array<{ __typename?: 'PoolRetirementCertificate', transaction: { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } } }>, epochRewards: Array<{ __typename?: 'StakePoolEpochRewards', epochNo: number, epochLength: number, activeStake: number | bigint, operatorFees: number | bigint, totalRewards: number | bigint, memberROI: number }> } } } | null> | null };

export type StakePoolsQueryVariables = Exact<{
  query: Scalars['String'];
  epochRewardsLimit?: InputMaybe<Scalars['Int']>;
}>;


export type StakePoolsQuery = { __typename?: 'Query', queryStakePool?: Array<{ __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, poolParameters: Array<{ __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null }>, metrics: Array<{ __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: number | bigint, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: number | bigint, active: number | bigint }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }>, poolRetirementCertificates: Array<{ __typename?: 'PoolRetirementCertificate', transaction: { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } } }>, epochRewards: Array<{ __typename?: 'StakePoolEpochRewards', epochNo: number, epochLength: number, activeStake: number | bigint, operatorFees: number | bigint, totalRewards: number | bigint, memberROI: number }> } | null> | null };

export type TipQueryVariables = Exact<{ [key: string]: never; }>;


export type TipQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', hash: string, blockNo: number, slot: { __typename?: 'Slot', number: number } } | null> | null };

type MetadatumValue_BytesMetadatum_Fragment = { __typename: 'BytesMetadatum', bytes: string };

type MetadatumValue_IntegerMetadatum_Fragment = { __typename: 'IntegerMetadatum', int: number };

type MetadatumValue_MetadatumArray_Fragment = { __typename: 'MetadatumArray' };

type MetadatumValue_MetadatumMap_Fragment = { __typename: 'MetadatumMap' };

type MetadatumValue_StringMetadatum_Fragment = { __typename: 'StringMetadatum', string: string };

export type MetadatumValueFragment = MetadatumValue_BytesMetadatum_Fragment | MetadatumValue_IntegerMetadatum_Fragment | MetadatumValue_MetadatumArray_Fragment | MetadatumValue_MetadatumMap_Fragment | MetadatumValue_StringMetadatum_Fragment;

export type MetadatumMapFragment = { __typename?: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> };

export type MetadatumArrayFragment = { __typename?: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> };

export type ProtocolParametersFragment = { __typename?: 'ProtocolParametersAlonzo', stakeKeyDeposit: number, poolDeposit: number };

export type TxInFragment = { __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } };

export type NonRecursiveNativeScriptFieldsFragment = { __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null };

type AnyScript_NativeScript_Fragment = { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null };

type AnyScript_PlutusScript_Fragment = { __typename: 'PlutusScript', cborHex: string, type: string };

export type AnyScriptFragment = AnyScript_NativeScript_Fragment | AnyScript_PlutusScript_Fragment;

export type CoreTransactionFieldsFragment = { __typename?: 'Transaction', fee: number | bigint, hash: string, index: number, size: number | bigint, scriptIntegrityHash?: string | null, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: number | bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: number | bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: number | bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null, addressAttributes?: string | null, key?: { __typename?: 'PublicKey', key: string } | null }> | null, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, blob?: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null } } | null };

export type TransactionsByHashesQueryVariables = Exact<{
  hashes: Array<Scalars['String']> | Scalars['String'];
}>;


export type TransactionsByHashesQuery = { __typename?: 'Query', queryProtocolParametersAlonzo?: Array<{ __typename?: 'ProtocolParametersAlonzo', stakeKeyDeposit: number, poolDeposit: number } | null> | null, queryTransaction?: Array<{ __typename?: 'Transaction', fee: number | bigint, hash: string, index: number, size: number | bigint, scriptIntegrityHash?: string | null, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: number | bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: number | bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: number | bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null, addressAttributes?: string | null, key?: { __typename?: 'PublicKey', key: string } | null }> | null, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, blob?: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null } } | null } | null> | null };

export type TransactionsByAddressesQueryVariables = Exact<{
  addresses: Array<Scalars['String']> | Scalars['String'];
}>;


export type TransactionsByAddressesQuery = { __typename?: 'Query', queryProtocolParametersAlonzo?: Array<{ __typename?: 'ProtocolParametersAlonzo', stakeKeyDeposit: number, poolDeposit: number } | null> | null, queryAddress?: Array<{ __typename?: 'Address', inputs: Array<{ __typename?: 'TransactionInput', transaction: { __typename?: 'Transaction', fee: number | bigint, hash: string, index: number, size: number | bigint, scriptIntegrityHash?: string | null, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: number | bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: number | bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: number | bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null, addressAttributes?: string | null, key?: { __typename?: 'PublicKey', key: string } | null }> | null, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, blob?: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null } } | null } }>, utxo: Array<{ __typename?: 'TransactionOutput', transaction: { __typename?: 'Transaction', fee: number | bigint, hash: string, index: number, size: number | bigint, scriptIntegrityHash?: string | null, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: number | bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: number | bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: number | bigint, vrf: string, pledge: number | bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null, extSigUrl?: string | null, extVkey?: string | null, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null, status?: ExtendedPoolStatus | null, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null, facebook?: string | null, github?: string | null, feed?: string | null, telegram?: string | null, twitter?: string | null } | null, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null, logo_svg?: string | null, color_fg?: string | null, color_bg?: string | null } | null, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null } } | null } | null, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null, ipv6?: string | null, port?: number | null } | { __typename: 'RelayByName', hostname: string, port?: number | null } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: number | bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null, addressAttributes?: string | null, key?: { __typename?: 'PublicKey', key: string } | null }> | null, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> | null, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null }> }> | null, startsAt?: { __typename?: 'Slot', number: number } | null, expiresAt?: { __typename?: 'Slot', number: number } | null, vkey?: { __typename?: 'PublicKey', key: string } | null } | { __typename: 'PlutusScript', cborHex: string, type: string } }> | null, blob?: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', label: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null } } | null } }> } | null> | null };

export const AllPoolParameterFieldsFragmentDoc = gql`
    fragment allPoolParameterFields on PoolParameters {
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
  owners {
    address
  }
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
  poolRegistrationCertificate {
    transaction {
      hash
    }
  }
  rewardAccount {
    address
  }
  pledge
  metadataJson {
    hash
    url
  }
}
    `;
export const CertificateTransactionFieldsFragmentDoc = gql`
    fragment certificateTransactionFields on Transaction {
  block {
    blockNo
  }
  hash
}
    `;
export const AllStakePoolFieldsFragmentDoc = gql`
    fragment allStakePoolFields on StakePool {
  id
  hexId
  status
  poolParameters(
    order: {desc: sinceEpochNo, then: {desc: transactionBlockNo}}
    first: 1
  ) {
    ...allPoolParameterFields
  }
  metrics(order: {desc: blockNo}, first: 1) {
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
  poolRetirementCertificates {
    transaction {
      ...certificateTransactionFields
    }
  }
  epochRewards(order: {desc: epochNo}, first: $epochRewardsLimit) {
    epochNo
    epochLength
    activeStake
    operatorFees
    totalRewards
    memberROI
  }
}
    ${AllPoolParameterFieldsFragmentDoc}
${CertificateTransactionFieldsFragmentDoc}`;
export const ProtocolParametersFragmentDoc = gql`
    fragment protocolParameters on ProtocolParametersAlonzo {
  stakeKeyDeposit
  poolDeposit
}
    `;
export const TxInFragmentDoc = gql`
    fragment txIn on TransactionInput {
  index
  address {
    address
  }
}
    `;
export const NonRecursiveNativeScriptFieldsFragmentDoc = gql`
    fragment nonRecursiveNativeScriptFields on NativeScript {
  __typename
  startsAt {
    number
  }
  expiresAt {
    number
  }
  vkey {
    key
  }
}
    `;
export const AnyScriptFragmentDoc = gql`
    fragment anyScript on Script {
  ... on NativeScript {
    ...nonRecursiveNativeScriptFields
    any {
      ...nonRecursiveNativeScriptFields
    }
    all {
      ...nonRecursiveNativeScriptFields
    }
    nof {
      key
      scripts {
        ...nonRecursiveNativeScriptFields
      }
    }
  }
  ... on PlutusScript {
    __typename
    cborHex
    type
  }
}
    ${NonRecursiveNativeScriptFieldsFragmentDoc}`;
export const MetadatumValueFragmentDoc = gql`
    fragment metadatumValue on Metadatum {
  __typename
  ... on BytesMetadatum {
    bytes
  }
  ... on IntegerMetadatum {
    int
  }
  ... on StringMetadatum {
    string
  }
}
    `;
export const MetadatumArrayFragmentDoc = gql`
    fragment metadatumArray on MetadatumArray {
  array {
    ...metadatumValue
    ... on MetadatumArray {
      array {
        ...metadatumValue
      }
    }
    ... on MetadatumMap {
      map {
        label
        metadatum {
          ...metadatumValue
        }
      }
    }
  }
}
    ${MetadatumValueFragmentDoc}`;
export const MetadatumMapFragmentDoc = gql`
    fragment metadatumMap on MetadatumMap {
  map {
    label
    metadatum {
      ...metadatumValue
      ... on MetadatumArray {
        ...metadatumArray
      }
      ... on MetadatumMap {
        __typename
        map {
          label
          metadatum {
            ...metadatumValue
            ... on MetadatumArray {
              ...metadatumArray
            }
          }
        }
      }
    }
  }
}
    ${MetadatumValueFragmentDoc}
${MetadatumArrayFragmentDoc}`;
export const CoreTransactionFieldsFragmentDoc = gql`
    fragment coreTransactionFields on Transaction {
  inputs {
    ...txIn
  }
  outputs {
    address {
      address
    }
    value {
      coin
      assets {
        asset {
          assetId
        }
        quantity
      }
    }
    datumHash
  }
  certificates {
    __typename
    ... on GenesisKeyDelegationCertificate {
      genesisHash
      genesisDelegateHash
      vrfKeyHash
    }
    ... on MirCertificate {
      rewardAccount {
        address
      }
      quantity
      pot
    }
    ... on PoolRegistrationCertificate {
      epoch {
        number
      }
      poolParameters {
        ...allPoolParameterFields
        stakePool {
          id
        }
      }
    }
    ... on PoolRetirementCertificate {
      epoch {
        number
      }
      stakePool {
        id
      }
    }
    ... on StakeDelegationCertificate {
      rewardAccount {
        address
      }
      stakePool {
        id
      }
      epoch {
        number
      }
    }
    ... on StakeKeyRegistrationCertificate {
      rewardAccount {
        address
      }
    }
    ... on StakeKeyDeregistrationCertificate {
      rewardAccount {
        address
      }
    }
  }
  collateral {
    ...txIn
  }
  fee
  invalidBefore {
    slotNo: number
  }
  invalidHereafter {
    slotNo: number
  }
  withdrawals {
    rewardAccount {
      address
    }
    quantity
  }
  mint {
    asset {
      assetId
    }
    quantity
  }
  hash
  index
  size
  block {
    blockNo
    slot {
      number
    }
    hash
  }
  requiredExtraSignatures {
    hash
  }
  scriptIntegrityHash
  witness {
    signatures {
      publicKey {
        key
      }
      signature
    }
    scripts {
      key
      script {
        ...anyScript
      }
    }
    bootstrap {
      signature
      chainCode
      addressAttributes
      key {
        key
      }
    }
    redeemers {
      index
      purpose
      scriptHash
      executionUnits {
        memory
        steps
      }
    }
    datums {
      hash
      datum
    }
  }
  auxiliaryData {
    hash
    body {
      scripts {
        script {
          ...anyScript
        }
      }
      blob {
        label
        metadatum {
          ...metadatumValue
          ... on MetadatumArray {
            ...metadatumArray
          }
          ... on MetadatumMap {
            ...metadatumMap
          }
        }
      }
    }
  }
}
    ${TxInFragmentDoc}
${AllPoolParameterFieldsFragmentDoc}
${AnyScriptFragmentDoc}
${MetadatumValueFragmentDoc}
${MetadatumArrayFragmentDoc}
${MetadatumMapFragmentDoc}`;
export const AssetDocument = gql`
    query Asset($assetId: String!) {
  queryAsset(filter: {assetId: {eq: $assetId}}, first: 1) {
    assetName
    policy {
      id
    }
    history {
      quantity
      transaction {
        hash
      }
    }
    totalQuantity
    fingerprint
    tokenMetadata {
      name
      ticker
      icon
      url
      desc
      decimals
      ref
      version
      sizedIcons {
        size
        icon
      }
    }
    nftMetadata {
      name
      images
      version
      mediaType
      files {
        name
        mediaType
        src
      }
      descriptions
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
      poolParameters(
        order: {desc: sinceEpochNo, then: {desc: transactionBlockNo}}
        first: 1
      ) {
        vrf
      }
    }
    size
    transactionsAggregate {
      count
    }
    totalOutput
    totalFees
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
export const CurrentProtocolParametersDocument = gql`
    query CurrentProtocolParameters {
  queryProtocolVersion(
    order: {desc: major, then: {desc: minor, then: {desc: patch}}}
  ) {
    protocolParameters {
      ... on ProtocolParametersAlonzo {
        coinsPerUtxoWord
        maxTxSize
        maxValueSize
        stakeKeyDeposit
        poolDeposit
        maxCollateralInputs
        minFeeCoefficient
        minFeeConstant
        minPoolCost
        protocolVersion {
          major
          minor
          patch
        }
      }
    }
  }
}
    `;
export const GenesisParametersDocument = gql`
    query GenesisParameters {
  queryNetworkConstants(order: {desc: timestamp}, first: 1) {
    systemStart
    networkMagic
    activeSlotsCoefficient
    securityParameter
    slotsPerKESPeriod
    maxKESEvolutions
    updateQuorum
  }
  queryTimeSettings(order: {desc: fromEpochNo}, first: 1) {
    slotLength
    epochLength
  }
  queryAda(order: {desc: sinceBlockNo}, first: 1) {
    supply {
      max
    }
  }
}
    `;
export const NetworkInfoDocument = gql`
    query NetworkInfo {
  queryBlock(order: {desc: blockNo}, first: 1) {
    totalLiveStake
    epoch {
      number
      startedAt {
        date
      }
      activeStakeAggregate {
        quantitySum
      }
    }
  }
  queryTimeSettings(order: {desc: fromEpochNo}, first: 1) {
    slotLength
    epochLength
  }
  queryAda(order: {desc: sinceBlockNo}, first: 1) {
    supply {
      circulating
      max
      total
    }
  }
}
    `;
export const MemberRewardsHistoryDocument = gql`
    query MemberRewardsHistory($rewardAccounts: [String!]!, $fromEpochNo: Int = 0, $toEpochNo: Int = 2147483647) {
  queryRewardAccount(filter: {address: {in: $rewardAccounts}}) {
    rewards(
      filter: {source: {eq: "member"}, and: {epochNo: {gt: $fromEpochNo}, and: {epochNo: {lt: $toEpochNo}}}}
    ) {
      epochNo
      quantity
    }
  }
}
    `;
export const StakePoolsByMetadataDocument = gql`
    query StakePoolsByMetadata($query: String!, $omit: [String!] = ["NEED_THIS_BECAUSE_IN_OPERATOR_WONT_WORK_WITH_EMPTY_ARR"], $epochRewardsLimit: Int = 2147483647) {
  queryStakePoolMetadata(
    filter: {and: [{or: [{name: {anyoftext: $query}}, {ticker: {anyoftext: $query}}]}, {not: {stakePoolId: {in: $omit}}}]}
  ) {
    poolParameters {
      stakePool {
        ...allStakePoolFields
      }
    }
  }
}
    ${AllStakePoolFieldsFragmentDoc}`;
export const StakePoolsDocument = gql`
    query StakePools($query: String!, $epochRewardsLimit: Int = 2147483647) {
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
export const TransactionsByHashesDocument = gql`
    query TransactionsByHashes($hashes: [String!]!) {
  queryProtocolParametersAlonzo {
    ...protocolParameters
  }
  queryTransaction(filter: {hash: {in: $hashes}}) {
    ...coreTransactionFields
  }
}
    ${ProtocolParametersFragmentDoc}
${CoreTransactionFieldsFragmentDoc}`;
export const TransactionsByAddressesDocument = gql`
    query TransactionsByAddresses($addresses: [String!]!) {
  queryProtocolParametersAlonzo {
    ...protocolParameters
  }
  queryAddress(filter: {address: {in: $addresses}}) {
    inputs {
      transaction {
        ...coreTransactionFields
      }
    }
    utxo {
      transaction {
        ...coreTransactionFields
      }
    }
  }
}
    ${ProtocolParametersFragmentDoc}
${CoreTransactionFieldsFragmentDoc}`;

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName) => action();

export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    Asset(variables: AssetQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<AssetQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<AssetQuery>(AssetDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'Asset');
    },
    BlocksByHashes(variables: BlocksByHashesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<BlocksByHashesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<BlocksByHashesQuery>(BlocksByHashesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'BlocksByHashes');
    },
    CurrentProtocolParameters(variables?: CurrentProtocolParametersQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<CurrentProtocolParametersQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<CurrentProtocolParametersQuery>(CurrentProtocolParametersDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'CurrentProtocolParameters');
    },
    GenesisParameters(variables?: GenesisParametersQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<GenesisParametersQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<GenesisParametersQuery>(GenesisParametersDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'GenesisParameters');
    },
    NetworkInfo(variables?: NetworkInfoQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<NetworkInfoQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<NetworkInfoQuery>(NetworkInfoDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'NetworkInfo');
    },
    MemberRewardsHistory(variables: MemberRewardsHistoryQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<MemberRewardsHistoryQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<MemberRewardsHistoryQuery>(MemberRewardsHistoryDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'MemberRewardsHistory');
    },
    StakePoolsByMetadata(variables: StakePoolsByMetadataQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<StakePoolsByMetadataQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<StakePoolsByMetadataQuery>(StakePoolsByMetadataDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'StakePoolsByMetadata');
    },
    StakePools(variables: StakePoolsQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<StakePoolsQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<StakePoolsQuery>(StakePoolsDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'StakePools');
    },
    Tip(variables?: TipQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<TipQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<TipQuery>(TipDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'Tip');
    },
    TransactionsByHashes(variables: TransactionsByHashesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<TransactionsByHashesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<TransactionsByHashesQuery>(TransactionsByHashesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'TransactionsByHashes');
    },
    TransactionsByAddresses(variables: TransactionsByAddressesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<TransactionsByAddressesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<TransactionsByAddressesQuery>(TransactionsByAddressesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'TransactionsByAddresses');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;