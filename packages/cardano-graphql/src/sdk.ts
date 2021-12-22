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
  sinceBlock: Block;
  sinceBlockNo: Scalars['Int'];
  supply: CoinSupply;
};


export type AdaSinceBlockArgs = {
  filter?: Maybe<BlockFilter>;
};


export type AdaSupplyArgs = {
  filter?: Maybe<CoinSupplyFilter>;
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
  and?: Maybe<Array<Maybe<AdaFilter>>>;
  has?: Maybe<Array<Maybe<AdaHasFilter>>>;
  not?: Maybe<AdaFilter>;
  or?: Maybe<Array<Maybe<AdaFilter>>>;
};

export enum AdaHasFilter {
  SinceBlock = 'sinceBlock',
  SinceBlockNo = 'sinceBlockNo',
  Supply = 'supply'
}

export type AdaOrder = {
  asc?: Maybe<AdaOrderable>;
  desc?: Maybe<AdaOrderable>;
  then?: Maybe<AdaOrder>;
};

export enum AdaOrderable {
  SinceBlockNo = 'sinceBlockNo'
}

export type AdaPatch = {
  sinceBlock?: Maybe<BlockRef>;
  sinceBlockNo?: Maybe<Scalars['Int']>;
  supply?: Maybe<CoinSupplyRef>;
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
  sinceBlock?: Maybe<BlockRef>;
  sinceBlockNo?: Maybe<Scalars['Int']>;
  supply?: Maybe<CoinSupplyRef>;
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
  filter?: Maybe<AdaFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AdaOrder>;
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
  paymentPublicKey: PublicKeyRef;
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

export type AddAuxiliaryDataBodyInput = {
  auxiliaryData: AuxiliaryDataRef;
  blob?: Maybe<Array<KeyValueMetadatumRef>>;
  scripts?: Maybe<Array<AuxiliaryScriptRef>>;
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
  filter?: Maybe<AuxiliaryScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<BlockFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BlockOrder>;
};

export type AddBootstrapWitnessInput = {
  /** Extra attributes carried by Byron addresses (network magic and/or HD payload) */
  addressAttributes?: Maybe<Scalars['String']>;
  /** An Ed25519-BIP32 chain-code for key deriviation */
  chainCode?: Maybe<Scalars['String']>;
  key?: Maybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature: Scalars['String'];
};

export type AddBootstrapWitnessPayload = {
  __typename?: 'AddBootstrapWitnessPayload';
  bootstrapWitness?: Maybe<Array<Maybe<BootstrapWitness>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddBootstrapWitnessPayloadBootstrapWitnessArgs = {
  filter?: Maybe<BootstrapWitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BootstrapWitnessOrder>;
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
  filter?: Maybe<BytesMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BytesMetadatumOrder>;
};

export type AddCoinSupplyInput = {
  circulating: Scalars['String'];
  max: Scalars['String'];
  total: Scalars['String'];
};

export type AddCoinSupplyPayload = {
  __typename?: 'AddCoinSupplyPayload';
  coinSupply?: Maybe<Array<Maybe<CoinSupply>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddCoinSupplyPayloadCoinSupplyArgs = {
  filter?: Maybe<CoinSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CoinSupplyOrder>;
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
  filter?: Maybe<CostModelCoefficientFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelCoefficientOrder>;
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
  filter?: Maybe<CostModelFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelOrder>;
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
  filter?: Maybe<DatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<DatumOrder>;
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
  filter?: Maybe<GenesisKeyDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<GenesisKeyDelegationCertificateOrder>;
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
  int: Scalars['Int'];
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
  array: Array<MetadatumRef>;
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
  map: Array<KeyValueMetadatumRef>;
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
  filter?: Maybe<MirCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<MirCertificateOrder>;
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
  filter?: Maybe<NOfFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NOfOrder>;
};

export type AddNativeScriptInput = {
  all?: Maybe<Array<NativeScriptRef>>;
  any?: Maybe<Array<NativeScriptRef>>;
  expiresAt?: Maybe<SlotRef>;
  nof?: Maybe<Array<NOfRef>>;
  startsAt?: Maybe<SlotRef>;
  vkey?: Maybe<PublicKeyRef>;
};

export type AddNativeScriptPayload = {
  __typename?: 'AddNativeScriptPayload';
  nativeScript?: Maybe<Array<Maybe<NativeScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type AddNativeScriptPayloadNativeScriptArgs = {
  filter?: Maybe<NativeScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<NetworkConstantsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NetworkConstantsOrder>;
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
  filter?: Maybe<PlutusScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PlutusScriptOrder>;
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

export type AddPoolParametersInput = {
  cost: Scalars['Int64'];
  margin: RatioRef;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
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
  filter?: Maybe<PoolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolParametersOrder>;
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
  filter?: Maybe<PoolRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<PoolRetirementCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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
  extraEntropy?: Maybe<Scalars['String']>;
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
  filter?: Maybe<ProtocolParametersAlonzoFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersAlonzoOrder>;
};

export type AddProtocolParametersShelleyInput = {
  decentralizationParameter: RatioRef;
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
  filter?: Maybe<ProtocolParametersShelleyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersShelleyOrder>;
};

export type AddProtocolVersionInput = {
  major: Scalars['Int'];
  minor: Scalars['Int'];
  patch?: Maybe<Scalars['Int']>;
  protocolParameters: ProtocolParametersRef;
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

export type AddPublicKeyInput = {
  addresses?: Maybe<Array<AddressRef>>;
  /** hex-encoded Ed25519 public key hash */
  hash: Scalars['String'];
  /** hex-encoded Ed25519 public key */
  key: Scalars['String'];
  requiredExtraSignatureInTransactions: Array<TransactionRef>;
  rewardAccount?: Maybe<RewardAccountRef>;
  signatures: Array<SignatureRef>;
};

export type AddPublicKeyPayload = {
  __typename?: 'AddPublicKeyPayload';
  numUids?: Maybe<Scalars['Int']>;
  publicKey?: Maybe<Array<Maybe<PublicKey>>>;
};


export type AddPublicKeyPayloadPublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PublicKeyOrder>;
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
  filter?: Maybe<RatioFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RatioOrder>;
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
  delegationCertificates?: Maybe<Array<StakeDelegationCertificateRef>>;
  deregistrationCertificates?: Maybe<Array<StakeKeyDeregistrationCertificateRef>>;
  mirCertificates?: Maybe<Array<MirCertificateRef>>;
  publicKey: PublicKeyRef;
  registrationCertificates: Array<StakeKeyRegistrationCertificateRef>;
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
  filter?: Maybe<SignatureFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SignatureOrder>;
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
  filter?: Maybe<StakeDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<StakeKeyRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type AddStakePoolInput = {
  hexId: Scalars['String'];
  id: Scalars['String'];
  metrics: StakePoolMetricsRef;
  poolParameters: Array<PoolParametersRef>;
  poolRetirementCertificates: Array<PoolRetirementCertificateRef>;
  /** active | retired | retiring */
  status: StakePoolStatus;
};

export type AddStakePoolMetadataInput = {
  description: Scalars['String'];
  ext?: Maybe<ExtendedStakePoolMetadataRef>;
  extDataUrl?: Maybe<Scalars['String']>;
  extSigUrl?: Maybe<Scalars['String']>;
  extVkey?: Maybe<Scalars['String']>;
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
  active: Scalars['Int64'];
  live: Scalars['Int64'];
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

export type AddStringMetadatumInput = {
  string: Scalars['String'];
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
  filter?: Maybe<TimeSettingsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TimeSettingsOrder>;
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
  certificates?: Maybe<Array<CertificateRef>>;
  collateral?: Maybe<Array<TransactionInputRef>>;
  deposit: Scalars['Int64'];
  fee: Scalars['Int64'];
  hash: Scalars['String'];
  index: Scalars['Int'];
  inputs: Array<TransactionInputRef>;
  invalidBefore?: Maybe<SlotRef>;
  invalidHereafter?: Maybe<SlotRef>;
  mint?: Maybe<Array<TokenRef>>;
  outputs: Array<TransactionOutputRef>;
  requiredExtraSignatures?: Maybe<Array<PublicKeyRef>>;
  scriptIntegrityHash?: Maybe<Scalars['String']>;
  size: Scalars['Int64'];
  totalOutputCoin: Scalars['Int64'];
  validContract: Scalars['Boolean'];
  withdrawals?: Maybe<Array<WithdrawalRef>>;
  witness: WitnessRef;
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
  /** hex-encoded 32 byte hash */
  datumHash?: Maybe<Scalars['String']>;
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

export type AddWitnessInput = {
  bootstrap?: Maybe<Array<BootstrapWitnessRef>>;
  datums?: Maybe<Array<DatumRef>>;
  redeemers?: Maybe<Array<RedeemerRef>>;
  scripts?: Maybe<Array<WitnessScriptRef>>;
  signatures: Array<SignatureRef>;
  transaction: TransactionRef;
};

export type AddWitnessPayload = {
  __typename?: 'AddWitnessPayload';
  numUids?: Maybe<Scalars['Int']>;
  witness?: Maybe<Array<Maybe<Witness>>>;
};


export type AddWitnessPayloadWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<WitnessScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WitnessScriptOrder>;
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
  filter?: Maybe<TransactionInputFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionInputOrder>;
};


export type AddressInputsAggregateArgs = {
  filter?: Maybe<TransactionInputFilter>;
};


export type AddressPaymentPublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
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
  address?: Maybe<StringHashFilter>;
  and?: Maybe<Array<Maybe<AddressFilter>>>;
  has?: Maybe<Array<Maybe<AddressHasFilter>>>;
  not?: Maybe<AddressFilter>;
  or?: Maybe<Array<Maybe<AddressFilter>>>;
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
  asc?: Maybe<AddressOrderable>;
  desc?: Maybe<AddressOrderable>;
  then?: Maybe<AddressOrder>;
};

export enum AddressOrderable {
  Address = 'address'
}

export type AddressPatch = {
  addressType?: Maybe<AddressType>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  paymentPublicKey?: Maybe<PublicKeyRef>;
  rewardAccount?: Maybe<RewardAccountRef>;
  utxo?: Maybe<Array<TransactionOutputRef>>;
};

export type AddressRef = {
  address?: Maybe<Scalars['String']>;
  addressType?: Maybe<AddressType>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  paymentPublicKey?: Maybe<PublicKeyRef>;
  rewardAccount?: Maybe<RewardAccountRef>;
  utxo?: Maybe<Array<TransactionOutputRef>>;
};

export enum AddressType {
  Byron = 'byron',
  Shelley = 'shelley'
}

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
  blob?: Maybe<Array<KeyValueMetadatum>>;
  blobAggregate?: Maybe<KeyValueMetadatumAggregateResult>;
  scripts?: Maybe<Array<AuxiliaryScript>>;
  scriptsAggregate?: Maybe<AuxiliaryScriptAggregateResult>;
};


export type AuxiliaryDataBodyAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
};


export type AuxiliaryDataBodyBlobArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<KeyValueMetadatumOrder>;
};


export type AuxiliaryDataBodyBlobAggregateArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
};


export type AuxiliaryDataBodyScriptsArgs = {
  filter?: Maybe<AuxiliaryScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type AuxiliaryDataBodyScriptsAggregateArgs = {
  filter?: Maybe<AuxiliaryScriptFilter>;
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
  blob?: Maybe<Array<KeyValueMetadatumRef>>;
  scripts?: Maybe<Array<AuxiliaryScriptRef>>;
};

export type AuxiliaryDataBodyRef = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  blob?: Maybe<Array<KeyValueMetadatumRef>>;
  scripts?: Maybe<Array<AuxiliaryScriptRef>>;
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

export type AuxiliaryScript = {
  __typename?: 'AuxiliaryScript';
  auxiliaryDataBody: AuxiliaryDataBody;
  script: Script;
};


export type AuxiliaryScriptAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
};


export type AuxiliaryScriptScriptArgs = {
  filter?: Maybe<ScriptFilter>;
};

export type AuxiliaryScriptAggregateResult = {
  __typename?: 'AuxiliaryScriptAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type AuxiliaryScriptFilter = {
  and?: Maybe<Array<Maybe<AuxiliaryScriptFilter>>>;
  has?: Maybe<Array<Maybe<AuxiliaryScriptHasFilter>>>;
  not?: Maybe<AuxiliaryScriptFilter>;
  or?: Maybe<Array<Maybe<AuxiliaryScriptFilter>>>;
};

export enum AuxiliaryScriptHasFilter {
  AuxiliaryDataBody = 'auxiliaryDataBody',
  Script = 'script'
}

export type AuxiliaryScriptPatch = {
  auxiliaryDataBody?: Maybe<AuxiliaryDataBodyRef>;
  script?: Maybe<ScriptRef>;
};

export type AuxiliaryScriptRef = {
  auxiliaryDataBody?: Maybe<AuxiliaryDataBodyRef>;
  script?: Maybe<ScriptRef>;
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
  asc?: Maybe<BlockOrderable>;
  desc?: Maybe<BlockOrderable>;
  then?: Maybe<BlockOrder>;
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
  blockNo?: Maybe<Scalars['Int']>;
  confirmations?: Maybe<Scalars['Int']>;
  epoch?: Maybe<EpochRef>;
  issuer?: Maybe<StakePoolRef>;
  nextBlock?: Maybe<BlockRef>;
  nextBlockProtocolVersion?: Maybe<ProtocolVersionRef>;
  opCert?: Maybe<Scalars['String']>;
  previousBlock?: Maybe<BlockRef>;
  size?: Maybe<Scalars['Int64']>;
  slot?: Maybe<SlotRef>;
  totalFees?: Maybe<Scalars['Int64']>;
  totalLiveStake?: Maybe<Scalars['Int64']>;
  totalOutput?: Maybe<Scalars['Int64']>;
  transactions?: Maybe<Array<TransactionRef>>;
};

export type BlockRef = {
  blockNo?: Maybe<Scalars['Int']>;
  confirmations?: Maybe<Scalars['Int']>;
  epoch?: Maybe<EpochRef>;
  hash?: Maybe<Scalars['String']>;
  issuer?: Maybe<StakePoolRef>;
  nextBlock?: Maybe<BlockRef>;
  nextBlockProtocolVersion?: Maybe<ProtocolVersionRef>;
  opCert?: Maybe<Scalars['String']>;
  previousBlock?: Maybe<BlockRef>;
  size?: Maybe<Scalars['Int64']>;
  slot?: Maybe<SlotRef>;
  totalFees?: Maybe<Scalars['Int64']>;
  totalLiveStake?: Maybe<Scalars['Int64']>;
  totalOutput?: Maybe<Scalars['Int64']>;
  transactions?: Maybe<Array<TransactionRef>>;
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
  filter?: Maybe<PublicKeyFilter>;
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
  and?: Maybe<Array<Maybe<BootstrapWitnessFilter>>>;
  has?: Maybe<Array<Maybe<BootstrapWitnessHasFilter>>>;
  not?: Maybe<BootstrapWitnessFilter>;
  or?: Maybe<Array<Maybe<BootstrapWitnessFilter>>>;
};

export enum BootstrapWitnessHasFilter {
  AddressAttributes = 'addressAttributes',
  ChainCode = 'chainCode',
  Key = 'key',
  Signature = 'signature'
}

export type BootstrapWitnessOrder = {
  asc?: Maybe<BootstrapWitnessOrderable>;
  desc?: Maybe<BootstrapWitnessOrderable>;
  then?: Maybe<BootstrapWitnessOrder>;
};

export enum BootstrapWitnessOrderable {
  AddressAttributes = 'addressAttributes',
  ChainCode = 'chainCode',
  Signature = 'signature'
}

export type BootstrapWitnessPatch = {
  /** Extra attributes carried by Byron addresses (network magic and/or HD payload) */
  addressAttributes?: Maybe<Scalars['String']>;
  /** An Ed25519-BIP32 chain-code for key deriviation */
  chainCode?: Maybe<Scalars['String']>;
  key?: Maybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: Maybe<Scalars['String']>;
};

export type BootstrapWitnessRef = {
  /** Extra attributes carried by Byron addresses (network magic and/or HD payload) */
  addressAttributes?: Maybe<Scalars['String']>;
  /** An Ed25519-BIP32 chain-code for key deriviation */
  chainCode?: Maybe<Scalars['String']>;
  key?: Maybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: Maybe<Scalars['String']>;
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
  and?: Maybe<Array<Maybe<BytesMetadatumFilter>>>;
  has?: Maybe<Array<Maybe<BytesMetadatumHasFilter>>>;
  not?: Maybe<BytesMetadatumFilter>;
  or?: Maybe<Array<Maybe<BytesMetadatumFilter>>>;
};

export enum BytesMetadatumHasFilter {
  Bytes = 'bytes'
}

export type BytesMetadatumOrder = {
  asc?: Maybe<BytesMetadatumOrderable>;
  desc?: Maybe<BytesMetadatumOrderable>;
  then?: Maybe<BytesMetadatumOrder>;
};

export enum BytesMetadatumOrderable {
  Bytes = 'bytes'
}

export type BytesMetadatumPatch = {
  bytes?: Maybe<Scalars['String']>;
};

export type BytesMetadatumRef = {
  bytes?: Maybe<Scalars['String']>;
};

export type Certificate = GenesisKeyDelegationCertificate | MirCertificate | PoolRegistrationCertificate | PoolRetirementCertificate | StakeDelegationCertificate | StakeKeyDeregistrationCertificate | StakeKeyRegistrationCertificate;

export type CertificateFilter = {
  genesisKeyDelegationCertificateFilter?: Maybe<GenesisKeyDelegationCertificateFilter>;
  memberTypes?: Maybe<Array<CertificateType>>;
  mirCertificateFilter?: Maybe<MirCertificateFilter>;
  poolRegistrationCertificateFilter?: Maybe<PoolRegistrationCertificateFilter>;
  poolRetirementCertificateFilter?: Maybe<PoolRetirementCertificateFilter>;
  stakeDelegationCertificateFilter?: Maybe<StakeDelegationCertificateFilter>;
  stakeKeyDeregistrationCertificateFilter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
  stakeKeyRegistrationCertificateFilter?: Maybe<StakeKeyRegistrationCertificateFilter>;
};

export type CertificateRef = {
  genesisKeyDelegationCertificateRef?: Maybe<GenesisKeyDelegationCertificateRef>;
  mirCertificateRef?: Maybe<MirCertificateRef>;
  poolRegistrationCertificateRef?: Maybe<PoolRegistrationCertificateRef>;
  poolRetirementCertificateRef?: Maybe<PoolRetirementCertificateRef>;
  stakeDelegationCertificateRef?: Maybe<StakeDelegationCertificateRef>;
  stakeKeyDeregistrationCertificateRef?: Maybe<StakeKeyDeregistrationCertificateRef>;
  stakeKeyRegistrationCertificateRef?: Maybe<StakeKeyRegistrationCertificateRef>;
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
  circulating: Scalars['String'];
  max: Scalars['String'];
  total: Scalars['String'];
};

export type CoinSupplyAggregateResult = {
  __typename?: 'CoinSupplyAggregateResult';
  circulatingMax?: Maybe<Scalars['String']>;
  circulatingMin?: Maybe<Scalars['String']>;
  count?: Maybe<Scalars['Int']>;
  maxMax?: Maybe<Scalars['String']>;
  maxMin?: Maybe<Scalars['String']>;
  totalMax?: Maybe<Scalars['String']>;
  totalMin?: Maybe<Scalars['String']>;
};

export type CoinSupplyFilter = {
  and?: Maybe<Array<Maybe<CoinSupplyFilter>>>;
  has?: Maybe<Array<Maybe<CoinSupplyHasFilter>>>;
  not?: Maybe<CoinSupplyFilter>;
  or?: Maybe<Array<Maybe<CoinSupplyFilter>>>;
};

export enum CoinSupplyHasFilter {
  Circulating = 'circulating',
  Max = 'max',
  Total = 'total'
}

export type CoinSupplyOrder = {
  asc?: Maybe<CoinSupplyOrderable>;
  desc?: Maybe<CoinSupplyOrderable>;
  then?: Maybe<CoinSupplyOrder>;
};

export enum CoinSupplyOrderable {
  Circulating = 'circulating',
  Max = 'max',
  Total = 'total'
}

export type CoinSupplyPatch = {
  circulating?: Maybe<Scalars['String']>;
  max?: Maybe<Scalars['String']>;
  total?: Maybe<Scalars['String']>;
};

export type CoinSupplyRef = {
  circulating?: Maybe<Scalars['String']>;
  max?: Maybe<Scalars['String']>;
  total?: Maybe<Scalars['String']>;
};

export type ContainsFilter = {
  point?: Maybe<PointRef>;
  polygon?: Maybe<PolygonRef>;
};

export type CostModel = {
  __typename?: 'CostModel';
  coefficients: Array<CostModelCoefficient>;
  coefficientsAggregate?: Maybe<CostModelCoefficientAggregateResult>;
  language: Scalars['String'];
};


export type CostModelCoefficientsArgs = {
  filter?: Maybe<CostModelCoefficientFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelCoefficientOrder>;
};


export type CostModelCoefficientsAggregateArgs = {
  filter?: Maybe<CostModelCoefficientFilter>;
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
  and?: Maybe<Array<Maybe<CostModelCoefficientFilter>>>;
  has?: Maybe<Array<Maybe<CostModelCoefficientHasFilter>>>;
  not?: Maybe<CostModelCoefficientFilter>;
  or?: Maybe<Array<Maybe<CostModelCoefficientFilter>>>;
};

export enum CostModelCoefficientHasFilter {
  Coefficient = 'coefficient',
  Key = 'key'
}

export type CostModelCoefficientOrder = {
  asc?: Maybe<CostModelCoefficientOrderable>;
  desc?: Maybe<CostModelCoefficientOrderable>;
  then?: Maybe<CostModelCoefficientOrder>;
};

export enum CostModelCoefficientOrderable {
  Coefficient = 'coefficient',
  Key = 'key'
}

export type CostModelCoefficientPatch = {
  coefficient?: Maybe<Scalars['Int']>;
  key?: Maybe<Scalars['String']>;
};

export type CostModelCoefficientRef = {
  coefficient?: Maybe<Scalars['Int']>;
  key?: Maybe<Scalars['String']>;
};

export type CostModelFilter = {
  and?: Maybe<Array<Maybe<CostModelFilter>>>;
  has?: Maybe<Array<Maybe<CostModelHasFilter>>>;
  not?: Maybe<CostModelFilter>;
  or?: Maybe<Array<Maybe<CostModelFilter>>>;
};

export enum CostModelHasFilter {
  Coefficients = 'coefficients',
  Language = 'language'
}

export type CostModelOrder = {
  asc?: Maybe<CostModelOrderable>;
  desc?: Maybe<CostModelOrderable>;
  then?: Maybe<CostModelOrder>;
};

export enum CostModelOrderable {
  Language = 'language'
}

export type CostModelPatch = {
  coefficients?: Maybe<Array<CostModelCoefficientRef>>;
  language?: Maybe<Scalars['String']>;
};

export type CostModelRef = {
  coefficients?: Maybe<Array<CostModelCoefficientRef>>;
  language?: Maybe<Scalars['String']>;
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
  and?: Maybe<Array<Maybe<DatumFilter>>>;
  has?: Maybe<Array<Maybe<DatumHasFilter>>>;
  hash?: Maybe<StringHashFilter>;
  not?: Maybe<DatumFilter>;
  or?: Maybe<Array<Maybe<DatumFilter>>>;
};

export enum DatumHasFilter {
  Datum = 'datum',
  Hash = 'hash'
}

export type DatumOrder = {
  asc?: Maybe<DatumOrderable>;
  desc?: Maybe<DatumOrderable>;
  then?: Maybe<DatumOrder>;
};

export enum DatumOrderable {
  Datum = 'datum',
  Hash = 'hash'
}

export type DatumPatch = {
  datum?: Maybe<Scalars['String']>;
};

export type DatumRef = {
  datum?: Maybe<Scalars['String']>;
  hash?: Maybe<Scalars['String']>;
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
  order?: Maybe<AdaOrder>;
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

export type DeleteAuxiliaryScriptPayload = {
  __typename?: 'DeleteAuxiliaryScriptPayload';
  auxiliaryScript?: Maybe<Array<Maybe<AuxiliaryScript>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteAuxiliaryScriptPayloadAuxiliaryScriptArgs = {
  filter?: Maybe<AuxiliaryScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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

export type DeleteBootstrapWitnessPayload = {
  __typename?: 'DeleteBootstrapWitnessPayload';
  bootstrapWitness?: Maybe<Array<Maybe<BootstrapWitness>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteBootstrapWitnessPayloadBootstrapWitnessArgs = {
  filter?: Maybe<BootstrapWitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BootstrapWitnessOrder>;
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

export type DeleteCoinSupplyPayload = {
  __typename?: 'DeleteCoinSupplyPayload';
  coinSupply?: Maybe<Array<Maybe<CoinSupply>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteCoinSupplyPayloadCoinSupplyArgs = {
  filter?: Maybe<CoinSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CoinSupplyOrder>;
};

export type DeleteCostModelCoefficientPayload = {
  __typename?: 'DeleteCostModelCoefficientPayload';
  costModelCoefficient?: Maybe<Array<Maybe<CostModelCoefficient>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteCostModelCoefficientPayloadCostModelCoefficientArgs = {
  filter?: Maybe<CostModelCoefficientFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelCoefficientOrder>;
};

export type DeleteCostModelPayload = {
  __typename?: 'DeleteCostModelPayload';
  costModel?: Maybe<Array<Maybe<CostModel>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteCostModelPayloadCostModelArgs = {
  filter?: Maybe<CostModelFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelOrder>;
};

export type DeleteDatumPayload = {
  __typename?: 'DeleteDatumPayload';
  datum?: Maybe<Array<Maybe<Datum>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteDatumPayloadDatumArgs = {
  filter?: Maybe<DatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<DatumOrder>;
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

export type DeleteGenesisKeyDelegationCertificatePayload = {
  __typename?: 'DeleteGenesisKeyDelegationCertificatePayload';
  genesisKeyDelegationCertificate?: Maybe<Array<Maybe<GenesisKeyDelegationCertificate>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteGenesisKeyDelegationCertificatePayloadGenesisKeyDelegationCertificateArgs = {
  filter?: Maybe<GenesisKeyDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<GenesisKeyDelegationCertificateOrder>;
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

export type DeleteMirCertificatePayload = {
  __typename?: 'DeleteMirCertificatePayload';
  mirCertificate?: Maybe<Array<Maybe<MirCertificate>>>;
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteMirCertificatePayloadMirCertificateArgs = {
  filter?: Maybe<MirCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<MirCertificateOrder>;
};

export type DeleteNOfPayload = {
  __typename?: 'DeleteNOfPayload';
  msg?: Maybe<Scalars['String']>;
  nOf?: Maybe<Array<Maybe<NOf>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNOfPayloadNOfArgs = {
  filter?: Maybe<NOfFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NOfOrder>;
};

export type DeleteNativeScriptPayload = {
  __typename?: 'DeleteNativeScriptPayload';
  msg?: Maybe<Scalars['String']>;
  nativeScript?: Maybe<Array<Maybe<NativeScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNativeScriptPayloadNativeScriptArgs = {
  filter?: Maybe<NativeScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteNetworkConstantsPayload = {
  __typename?: 'DeleteNetworkConstantsPayload';
  msg?: Maybe<Scalars['String']>;
  networkConstants?: Maybe<Array<Maybe<NetworkConstants>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type DeleteNetworkConstantsPayloadNetworkConstantsArgs = {
  filter?: Maybe<NetworkConstantsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NetworkConstantsOrder>;
};

export type DeletePlutusScriptPayload = {
  __typename?: 'DeletePlutusScriptPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  plutusScript?: Maybe<Array<Maybe<PlutusScript>>>;
};


export type DeletePlutusScriptPayloadPlutusScriptArgs = {
  filter?: Maybe<PlutusScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PlutusScriptOrder>;
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

export type DeletePoolParametersPayload = {
  __typename?: 'DeletePoolParametersPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolParameters?: Maybe<Array<Maybe<PoolParameters>>>;
};


export type DeletePoolParametersPayloadPoolParametersArgs = {
  filter?: Maybe<PoolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolParametersOrder>;
};

export type DeletePoolRegistrationCertificatePayload = {
  __typename?: 'DeletePoolRegistrationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolRegistrationCertificate?: Maybe<Array<Maybe<PoolRegistrationCertificate>>>;
};


export type DeletePoolRegistrationCertificatePayloadPoolRegistrationCertificateArgs = {
  filter?: Maybe<PoolRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeletePoolRetirementCertificatePayload = {
  __typename?: 'DeletePoolRetirementCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  poolRetirementCertificate?: Maybe<Array<Maybe<PoolRetirementCertificate>>>;
};


export type DeletePoolRetirementCertificatePayloadPoolRetirementCertificateArgs = {
  filter?: Maybe<PoolRetirementCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteProtocolParametersAlonzoPayload = {
  __typename?: 'DeleteProtocolParametersAlonzoPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersAlonzo?: Maybe<Array<Maybe<ProtocolParametersAlonzo>>>;
};


export type DeleteProtocolParametersAlonzoPayloadProtocolParametersAlonzoArgs = {
  filter?: Maybe<ProtocolParametersAlonzoFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersAlonzoOrder>;
};

export type DeleteProtocolParametersShelleyPayload = {
  __typename?: 'DeleteProtocolParametersShelleyPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersShelley?: Maybe<Array<Maybe<ProtocolParametersShelley>>>;
};


export type DeleteProtocolParametersShelleyPayloadProtocolParametersShelleyArgs = {
  filter?: Maybe<ProtocolParametersShelleyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersShelleyOrder>;
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

export type DeletePublicKeyPayload = {
  __typename?: 'DeletePublicKeyPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  publicKey?: Maybe<Array<Maybe<PublicKey>>>;
};


export type DeletePublicKeyPayloadPublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PublicKeyOrder>;
};

export type DeleteRatioPayload = {
  __typename?: 'DeleteRatioPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  ratio?: Maybe<Array<Maybe<Ratio>>>;
};


export type DeleteRatioPayloadRatioArgs = {
  filter?: Maybe<RatioFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RatioOrder>;
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

export type DeleteSignaturePayload = {
  __typename?: 'DeleteSignaturePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  signature?: Maybe<Array<Maybe<Signature>>>;
};


export type DeleteSignaturePayloadSignatureArgs = {
  filter?: Maybe<SignatureFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SignatureOrder>;
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

export type DeleteStakeDelegationCertificatePayload = {
  __typename?: 'DeleteStakeDelegationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakeDelegationCertificate?: Maybe<Array<Maybe<StakeDelegationCertificate>>>;
};


export type DeleteStakeDelegationCertificatePayloadStakeDelegationCertificateArgs = {
  filter?: Maybe<StakeDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteStakeKeyDeregistrationCertificatePayload = {
  __typename?: 'DeleteStakeKeyDeregistrationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyDeregistrationCertificate?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificate>>>;
};


export type DeleteStakeKeyDeregistrationCertificatePayloadStakeKeyDeregistrationCertificateArgs = {
  filter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteStakeKeyRegistrationCertificatePayload = {
  __typename?: 'DeleteStakeKeyRegistrationCertificatePayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyRegistrationCertificate?: Maybe<Array<Maybe<StakeKeyRegistrationCertificate>>>;
};


export type DeleteStakeKeyRegistrationCertificatePayloadStakeKeyRegistrationCertificateArgs = {
  filter?: Maybe<StakeKeyRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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

export type DeleteTimeSettingsPayload = {
  __typename?: 'DeleteTimeSettingsPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  timeSettings?: Maybe<Array<Maybe<TimeSettings>>>;
};


export type DeleteTimeSettingsPayloadTimeSettingsArgs = {
  filter?: Maybe<TimeSettingsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TimeSettingsOrder>;
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

export type DeleteWitnessPayload = {
  __typename?: 'DeleteWitnessPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  witness?: Maybe<Array<Maybe<Witness>>>;
};


export type DeleteWitnessPayloadWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type DeleteWitnessScriptPayload = {
  __typename?: 'DeleteWitnessScriptPayload';
  msg?: Maybe<Scalars['String']>;
  numUids?: Maybe<Scalars['Int']>;
  witnessScript?: Maybe<Array<Maybe<WitnessScript>>>;
};


export type DeleteWitnessScriptPayloadWitnessScriptArgs = {
  filter?: Maybe<WitnessScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WitnessScriptOrder>;
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

export type ExecutionPrices = {
  __typename?: 'ExecutionPrices';
  prMem: Ratio;
  prSteps: Ratio;
};


export type ExecutionPricesPrMemArgs = {
  filter?: Maybe<RatioFilter>;
};


export type ExecutionPricesPrStepsArgs = {
  filter?: Maybe<RatioFilter>;
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
  prMem?: Maybe<RatioRef>;
  prSteps?: Maybe<RatioRef>;
};

export type ExecutionPricesRef = {
  prMem?: Maybe<RatioRef>;
  prSteps?: Maybe<RatioRef>;
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

export type GenesisKeyDelegationCertificate = {
  __typename?: 'GenesisKeyDelegationCertificate';
  genesisDelegateHash: Scalars['String'];
  genesisHash: Scalars['String'];
  transaction: Transaction;
  vrfKeyHash: Scalars['String'];
};


export type GenesisKeyDelegationCertificateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
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
  and?: Maybe<Array<Maybe<GenesisKeyDelegationCertificateFilter>>>;
  has?: Maybe<Array<Maybe<GenesisKeyDelegationCertificateHasFilter>>>;
  not?: Maybe<GenesisKeyDelegationCertificateFilter>;
  or?: Maybe<Array<Maybe<GenesisKeyDelegationCertificateFilter>>>;
};

export enum GenesisKeyDelegationCertificateHasFilter {
  GenesisDelegateHash = 'genesisDelegateHash',
  GenesisHash = 'genesisHash',
  Transaction = 'transaction',
  VrfKeyHash = 'vrfKeyHash'
}

export type GenesisKeyDelegationCertificateOrder = {
  asc?: Maybe<GenesisKeyDelegationCertificateOrderable>;
  desc?: Maybe<GenesisKeyDelegationCertificateOrderable>;
  then?: Maybe<GenesisKeyDelegationCertificateOrder>;
};

export enum GenesisKeyDelegationCertificateOrderable {
  GenesisDelegateHash = 'genesisDelegateHash',
  GenesisHash = 'genesisHash',
  VrfKeyHash = 'vrfKeyHash'
}

export type GenesisKeyDelegationCertificatePatch = {
  genesisDelegateHash?: Maybe<Scalars['String']>;
  genesisHash?: Maybe<Scalars['String']>;
  transaction?: Maybe<TransactionRef>;
  vrfKeyHash?: Maybe<Scalars['String']>;
};

export type GenesisKeyDelegationCertificateRef = {
  genesisDelegateHash?: Maybe<Scalars['String']>;
  genesisHash?: Maybe<Scalars['String']>;
  transaction?: Maybe<TransactionRef>;
  vrfKeyHash?: Maybe<Scalars['String']>;
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
  and?: Maybe<Array<Maybe<IntegerMetadatumFilter>>>;
  has?: Maybe<Array<Maybe<IntegerMetadatumHasFilter>>>;
  not?: Maybe<IntegerMetadatumFilter>;
  or?: Maybe<Array<Maybe<IntegerMetadatumFilter>>>;
};

export enum IntegerMetadatumHasFilter {
  Int = 'int'
}

export type IntegerMetadatumOrder = {
  asc?: Maybe<IntegerMetadatumOrderable>;
  desc?: Maybe<IntegerMetadatumOrderable>;
  then?: Maybe<IntegerMetadatumOrder>;
};

export enum IntegerMetadatumOrderable {
  Int = 'int'
}

export type IntegerMetadatumPatch = {
  int?: Maybe<Scalars['Int']>;
};

export type IntegerMetadatumRef = {
  int?: Maybe<Scalars['Int']>;
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
  array: Array<Metadatum>;
};


export type MetadatumArrayArrayArgs = {
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
  Array = 'array'
}

export type MetadatumArrayPatch = {
  array?: Maybe<Array<MetadatumRef>>;
};

export type MetadatumArrayRef = {
  array?: Maybe<Array<MetadatumRef>>;
};

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
  map: Array<KeyValueMetadatum>;
  mapAggregate?: Maybe<KeyValueMetadatumAggregateResult>;
};


export type MetadatumMapMapArgs = {
  filter?: Maybe<KeyValueMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<KeyValueMetadatumOrder>;
};


export type MetadatumMapMapAggregateArgs = {
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
  Map = 'map'
}

export type MetadatumMapPatch = {
  map?: Maybe<Array<KeyValueMetadatumRef>>;
};

export type MetadatumMapRef = {
  map?: Maybe<Array<KeyValueMetadatumRef>>;
};

export type MetadatumRef = {
  bytesMetadatumRef?: Maybe<BytesMetadatumRef>;
  integerMetadatumRef?: Maybe<IntegerMetadatumRef>;
  metadatumArrayRef?: Maybe<MetadatumArrayRef>;
  metadatumMapRef?: Maybe<MetadatumMapRef>;
  stringMetadatumRef?: Maybe<StringMetadatumRef>;
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
  filter?: Maybe<RewardAccountFilter>;
};


export type MirCertificateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
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
  and?: Maybe<Array<Maybe<MirCertificateFilter>>>;
  has?: Maybe<Array<Maybe<MirCertificateHasFilter>>>;
  not?: Maybe<MirCertificateFilter>;
  or?: Maybe<Array<Maybe<MirCertificateFilter>>>;
};

export enum MirCertificateHasFilter {
  Pot = 'pot',
  Quantity = 'quantity',
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type MirCertificateOrder = {
  asc?: Maybe<MirCertificateOrderable>;
  desc?: Maybe<MirCertificateOrderable>;
  then?: Maybe<MirCertificateOrder>;
};

export enum MirCertificateOrderable {
  Pot = 'pot',
  Quantity = 'quantity'
}

export type MirCertificatePatch = {
  pot?: Maybe<Scalars['String']>;
  quantity?: Maybe<Scalars['Int64']>;
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
};

export type MirCertificateRef = {
  pot?: Maybe<Scalars['String']>;
  quantity?: Maybe<Scalars['Int64']>;
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
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
  addPlutusScript?: Maybe<AddPlutusScriptPayload>;
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
  addRewardAccount?: Maybe<AddRewardAccountPayload>;
  addSignature?: Maybe<AddSignaturePayload>;
  addSlot?: Maybe<AddSlotPayload>;
  addStakeDelegationCertificate?: Maybe<AddStakeDelegationCertificatePayload>;
  addStakeKeyDeregistrationCertificate?: Maybe<AddStakeKeyDeregistrationCertificatePayload>;
  addStakeKeyRegistrationCertificate?: Maybe<AddStakeKeyRegistrationCertificatePayload>;
  addStakePool?: Maybe<AddStakePoolPayload>;
  addStakePoolMetadata?: Maybe<AddStakePoolMetadataPayload>;
  addStakePoolMetadataJson?: Maybe<AddStakePoolMetadataJsonPayload>;
  addStakePoolMetrics?: Maybe<AddStakePoolMetricsPayload>;
  addStakePoolMetricsSize?: Maybe<AddStakePoolMetricsSizePayload>;
  addStakePoolMetricsStake?: Maybe<AddStakePoolMetricsStakePayload>;
  addStringMetadatum?: Maybe<AddStringMetadatumPayload>;
  addThePoolsMediaAssets?: Maybe<AddThePoolsMediaAssetsPayload>;
  addTimeSettings?: Maybe<AddTimeSettingsPayload>;
  addToken?: Maybe<AddTokenPayload>;
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
  deletePlutusScript?: Maybe<DeletePlutusScriptPayload>;
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
  deleteRewardAccount?: Maybe<DeleteRewardAccountPayload>;
  deleteSignature?: Maybe<DeleteSignaturePayload>;
  deleteSlot?: Maybe<DeleteSlotPayload>;
  deleteStakeDelegationCertificate?: Maybe<DeleteStakeDelegationCertificatePayload>;
  deleteStakeKeyDeregistrationCertificate?: Maybe<DeleteStakeKeyDeregistrationCertificatePayload>;
  deleteStakeKeyRegistrationCertificate?: Maybe<DeleteStakeKeyRegistrationCertificatePayload>;
  deleteStakePool?: Maybe<DeleteStakePoolPayload>;
  deleteStakePoolMetadata?: Maybe<DeleteStakePoolMetadataPayload>;
  deleteStakePoolMetadataJson?: Maybe<DeleteStakePoolMetadataJsonPayload>;
  deleteStakePoolMetrics?: Maybe<DeleteStakePoolMetricsPayload>;
  deleteStakePoolMetricsSize?: Maybe<DeleteStakePoolMetricsSizePayload>;
  deleteStakePoolMetricsStake?: Maybe<DeleteStakePoolMetricsStakePayload>;
  deleteStringMetadatum?: Maybe<DeleteStringMetadatumPayload>;
  deleteThePoolsMediaAssets?: Maybe<DeleteThePoolsMediaAssetsPayload>;
  deleteTimeSettings?: Maybe<DeleteTimeSettingsPayload>;
  deleteToken?: Maybe<DeleteTokenPayload>;
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
  updatePlutusScript?: Maybe<UpdatePlutusScriptPayload>;
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
  updateRewardAccount?: Maybe<UpdateRewardAccountPayload>;
  updateSignature?: Maybe<UpdateSignaturePayload>;
  updateSlot?: Maybe<UpdateSlotPayload>;
  updateStakeDelegationCertificate?: Maybe<UpdateStakeDelegationCertificatePayload>;
  updateStakeKeyDeregistrationCertificate?: Maybe<UpdateStakeKeyDeregistrationCertificatePayload>;
  updateStakeKeyRegistrationCertificate?: Maybe<UpdateStakeKeyRegistrationCertificatePayload>;
  updateStakePool?: Maybe<UpdateStakePoolPayload>;
  updateStakePoolMetadata?: Maybe<UpdateStakePoolMetadataPayload>;
  updateStakePoolMetadataJson?: Maybe<UpdateStakePoolMetadataJsonPayload>;
  updateStakePoolMetrics?: Maybe<UpdateStakePoolMetricsPayload>;
  updateStakePoolMetricsSize?: Maybe<UpdateStakePoolMetricsSizePayload>;
  updateStakePoolMetricsStake?: Maybe<UpdateStakePoolMetricsStakePayload>;
  updateStringMetadatum?: Maybe<UpdateStringMetadatumPayload>;
  updateThePoolsMediaAssets?: Maybe<UpdateThePoolsMediaAssetsPayload>;
  updateTimeSettings?: Maybe<UpdateTimeSettingsPayload>;
  updateToken?: Maybe<UpdateTokenPayload>;
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
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddAssetArgs = {
  input: Array<AddAssetInput>;
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
  upsert?: Maybe<Scalars['Boolean']>;
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
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddEpochArgs = {
  input: Array<AddEpochInput>;
  upsert?: Maybe<Scalars['Boolean']>;
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


export type MutationAddPlutusScriptArgs = {
  input: Array<AddPlutusScriptInput>;
  upsert?: Maybe<Scalars['Boolean']>;
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
  upsert?: Maybe<Scalars['Boolean']>;
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


export type MutationAddRewardAccountArgs = {
  input: Array<AddRewardAccountInput>;
};


export type MutationAddSignatureArgs = {
  input: Array<AddSignatureInput>;
};


export type MutationAddSlotArgs = {
  input: Array<AddSlotInput>;
  upsert?: Maybe<Scalars['Boolean']>;
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
  upsert?: Maybe<Scalars['Boolean']>;
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


export type MutationDeletePlutusScriptArgs = {
  filter: PlutusScriptFilter;
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


export type MutationUpdatePlutusScriptArgs = {
  input: UpdatePlutusScriptInput;
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
  filter?: Maybe<NativeScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type NOfScriptsAggregateArgs = {
  filter?: Maybe<NativeScriptFilter>;
};

export type NOfAggregateResult = {
  __typename?: 'NOfAggregateResult';
  count?: Maybe<Scalars['Int']>;
  keyMax?: Maybe<Scalars['String']>;
  keyMin?: Maybe<Scalars['String']>;
};

export type NOfFilter = {
  and?: Maybe<Array<Maybe<NOfFilter>>>;
  has?: Maybe<Array<Maybe<NOfHasFilter>>>;
  not?: Maybe<NOfFilter>;
  or?: Maybe<Array<Maybe<NOfFilter>>>;
};

export enum NOfHasFilter {
  Key = 'key',
  Scripts = 'scripts'
}

export type NOfOrder = {
  asc?: Maybe<NOfOrderable>;
  desc?: Maybe<NOfOrderable>;
  then?: Maybe<NOfOrder>;
};

export enum NOfOrderable {
  Key = 'key'
}

export type NOfPatch = {
  key?: Maybe<Scalars['String']>;
  scripts?: Maybe<Array<NativeScriptRef>>;
};

export type NOfRef = {
  key?: Maybe<Scalars['String']>;
  scripts?: Maybe<Array<NativeScriptRef>>;
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
  filter?: Maybe<NativeScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


/** Exactly one field is not null */
export type NativeScriptAllAggregateArgs = {
  filter?: Maybe<NativeScriptFilter>;
};


/** Exactly one field is not null */
export type NativeScriptAnyArgs = {
  filter?: Maybe<NativeScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


/** Exactly one field is not null */
export type NativeScriptAnyAggregateArgs = {
  filter?: Maybe<NativeScriptFilter>;
};


/** Exactly one field is not null */
export type NativeScriptExpiresAtArgs = {
  filter?: Maybe<SlotFilter>;
};


/** Exactly one field is not null */
export type NativeScriptNofArgs = {
  filter?: Maybe<NOfFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NOfOrder>;
};


/** Exactly one field is not null */
export type NativeScriptNofAggregateArgs = {
  filter?: Maybe<NOfFilter>;
};


/** Exactly one field is not null */
export type NativeScriptStartsAtArgs = {
  filter?: Maybe<SlotFilter>;
};


/** Exactly one field is not null */
export type NativeScriptVkeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
};

export type NativeScriptAggregateResult = {
  __typename?: 'NativeScriptAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type NativeScriptFilter = {
  and?: Maybe<Array<Maybe<NativeScriptFilter>>>;
  has?: Maybe<Array<Maybe<NativeScriptHasFilter>>>;
  not?: Maybe<NativeScriptFilter>;
  or?: Maybe<Array<Maybe<NativeScriptFilter>>>;
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
  all?: Maybe<Array<NativeScriptRef>>;
  any?: Maybe<Array<NativeScriptRef>>;
  expiresAt?: Maybe<SlotRef>;
  nof?: Maybe<Array<NOfRef>>;
  startsAt?: Maybe<SlotRef>;
  vkey?: Maybe<PublicKeyRef>;
};

export type NativeScriptRef = {
  all?: Maybe<Array<NativeScriptRef>>;
  any?: Maybe<Array<NativeScriptRef>>;
  expiresAt?: Maybe<SlotRef>;
  nof?: Maybe<Array<NOfRef>>;
  startsAt?: Maybe<SlotRef>;
  vkey?: Maybe<PublicKeyRef>;
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
  and?: Maybe<Array<Maybe<NetworkConstantsFilter>>>;
  has?: Maybe<Array<Maybe<NetworkConstantsHasFilter>>>;
  not?: Maybe<NetworkConstantsFilter>;
  or?: Maybe<Array<Maybe<NetworkConstantsFilter>>>;
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
  asc?: Maybe<NetworkConstantsOrderable>;
  desc?: Maybe<NetworkConstantsOrderable>;
  then?: Maybe<NetworkConstantsOrder>;
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
  activeSlotsCoefficient?: Maybe<Scalars['Float']>;
  maxKESEvolutions?: Maybe<Scalars['Int']>;
  networkMagic?: Maybe<Scalars['Int']>;
  securityParameter?: Maybe<Scalars['Int']>;
  slotsPerKESPeriod?: Maybe<Scalars['Int']>;
  systemStart?: Maybe<Scalars['DateTime']>;
  /** same as 'systemStart' */
  timestamp?: Maybe<Scalars['Int']>;
  updateQuorum?: Maybe<Scalars['Int']>;
};

export type NetworkConstantsRef = {
  activeSlotsCoefficient?: Maybe<Scalars['Float']>;
  maxKESEvolutions?: Maybe<Scalars['Int']>;
  networkMagic?: Maybe<Scalars['Int']>;
  securityParameter?: Maybe<Scalars['Int']>;
  slotsPerKESPeriod?: Maybe<Scalars['Int']>;
  systemStart?: Maybe<Scalars['DateTime']>;
  /** same as 'systemStart' */
  timestamp?: Maybe<Scalars['Int']>;
  updateQuorum?: Maybe<Scalars['Int']>;
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
  and?: Maybe<Array<Maybe<PlutusScriptFilter>>>;
  has?: Maybe<Array<Maybe<PlutusScriptHasFilter>>>;
  hash?: Maybe<StringHashFilter>;
  not?: Maybe<PlutusScriptFilter>;
  or?: Maybe<Array<Maybe<PlutusScriptFilter>>>;
};

export enum PlutusScriptHasFilter {
  CborHex = 'cborHex',
  Description = 'description',
  Hash = 'hash',
  Type = 'type'
}

export type PlutusScriptOrder = {
  asc?: Maybe<PlutusScriptOrderable>;
  desc?: Maybe<PlutusScriptOrderable>;
  then?: Maybe<PlutusScriptOrder>;
};

export enum PlutusScriptOrderable {
  CborHex = 'cborHex',
  Description = 'description',
  Hash = 'hash',
  Type = 'type'
}

export type PlutusScriptPatch = {
  /** Serialized plutus-core program */
  cborHex?: Maybe<Scalars['String']>;
  description?: Maybe<Scalars['String']>;
  /** 'PlutusScriptV1' | 'PlutusScriptV2' */
  type?: Maybe<Scalars['String']>;
};

export type PlutusScriptRef = {
  /** Serialized plutus-core program */
  cborHex?: Maybe<Scalars['String']>;
  description?: Maybe<Scalars['String']>;
  hash?: Maybe<Scalars['String']>;
  /** 'PlutusScriptV1' | 'PlutusScriptV2' */
  type?: Maybe<Scalars['String']>;
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
  filter?: Maybe<RatioFilter>;
};


export type PoolParametersMetadataArgs = {
  filter?: Maybe<StakePoolMetadataFilter>;
};


export type PoolParametersMetadataJsonArgs = {
  filter?: Maybe<StakePoolMetadataJsonFilter>;
};


export type PoolParametersOwnersArgs = {
  filter?: Maybe<RewardAccountFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RewardAccountOrder>;
};


export type PoolParametersOwnersAggregateArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type PoolParametersPoolRegistrationCertificateArgs = {
  filter?: Maybe<PoolRegistrationCertificateFilter>;
};


export type PoolParametersRelaysArgs = {
  filter?: Maybe<SearchResultFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type PoolParametersRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type PoolParametersStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
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
  and?: Maybe<Array<Maybe<PoolParametersFilter>>>;
  has?: Maybe<Array<Maybe<PoolParametersHasFilter>>>;
  not?: Maybe<PoolParametersFilter>;
  or?: Maybe<Array<Maybe<PoolParametersFilter>>>;
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
  asc?: Maybe<PoolParametersOrderable>;
  desc?: Maybe<PoolParametersOrderable>;
  then?: Maybe<PoolParametersOrder>;
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
  cost?: Maybe<Scalars['Int64']>;
  margin?: Maybe<RatioRef>;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  owners?: Maybe<Array<RewardAccountRef>>;
  pledge?: Maybe<Scalars['Int64']>;
  poolId?: Maybe<Scalars['String']>;
  poolRegistrationCertificate?: Maybe<PoolRegistrationCertificateRef>;
  relays?: Maybe<Array<SearchResultRef>>;
  rewardAccount?: Maybe<RewardAccountRef>;
  sinceEpochNo?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<StakePoolRef>;
  transactionBlockNo?: Maybe<Scalars['Int']>;
  /** hex-encoded 32 byte vrf vkey */
  vrf?: Maybe<Scalars['String']>;
};

export type PoolParametersRef = {
  cost?: Maybe<Scalars['Int64']>;
  margin?: Maybe<RatioRef>;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  owners?: Maybe<Array<RewardAccountRef>>;
  pledge?: Maybe<Scalars['Int64']>;
  poolId?: Maybe<Scalars['String']>;
  poolRegistrationCertificate?: Maybe<PoolRegistrationCertificateRef>;
  relays?: Maybe<Array<SearchResultRef>>;
  rewardAccount?: Maybe<RewardAccountRef>;
  sinceEpochNo?: Maybe<Scalars['Int']>;
  stakePool?: Maybe<StakePoolRef>;
  transactionBlockNo?: Maybe<Scalars['Int']>;
  /** hex-encoded 32 byte vrf vkey */
  vrf?: Maybe<Scalars['String']>;
};

export type PoolRegistrationCertificate = {
  __typename?: 'PoolRegistrationCertificate';
  epoch: Epoch;
  poolParameters: PoolParameters;
  transaction: Transaction;
};


export type PoolRegistrationCertificateEpochArgs = {
  filter?: Maybe<EpochFilter>;
};


export type PoolRegistrationCertificatePoolParametersArgs = {
  filter?: Maybe<PoolParametersFilter>;
};


export type PoolRegistrationCertificateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type PoolRegistrationCertificateAggregateResult = {
  __typename?: 'PoolRegistrationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type PoolRegistrationCertificateFilter = {
  and?: Maybe<Array<Maybe<PoolRegistrationCertificateFilter>>>;
  has?: Maybe<Array<Maybe<PoolRegistrationCertificateHasFilter>>>;
  not?: Maybe<PoolRegistrationCertificateFilter>;
  or?: Maybe<Array<Maybe<PoolRegistrationCertificateFilter>>>;
};

export enum PoolRegistrationCertificateHasFilter {
  Epoch = 'epoch',
  PoolParameters = 'poolParameters',
  Transaction = 'transaction'
}

export type PoolRegistrationCertificatePatch = {
  epoch?: Maybe<EpochRef>;
  poolParameters?: Maybe<PoolParametersRef>;
  transaction?: Maybe<TransactionRef>;
};

export type PoolRegistrationCertificateRef = {
  epoch?: Maybe<EpochRef>;
  poolParameters?: Maybe<PoolParametersRef>;
  transaction?: Maybe<TransactionRef>;
};

export type PoolRetirementCertificate = {
  __typename?: 'PoolRetirementCertificate';
  epoch: Epoch;
  stakePool: StakePool;
  transaction: Transaction;
};


export type PoolRetirementCertificateEpochArgs = {
  filter?: Maybe<EpochFilter>;
};


export type PoolRetirementCertificateStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
};


export type PoolRetirementCertificateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type PoolRetirementCertificateAggregateResult = {
  __typename?: 'PoolRetirementCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type PoolRetirementCertificateFilter = {
  and?: Maybe<Array<Maybe<PoolRetirementCertificateFilter>>>;
  has?: Maybe<Array<Maybe<PoolRetirementCertificateHasFilter>>>;
  not?: Maybe<PoolRetirementCertificateFilter>;
  or?: Maybe<Array<Maybe<PoolRetirementCertificateFilter>>>;
};

export enum PoolRetirementCertificateHasFilter {
  Epoch = 'epoch',
  StakePool = 'stakePool',
  Transaction = 'transaction'
}

export type PoolRetirementCertificatePatch = {
  epoch?: Maybe<EpochRef>;
  stakePool?: Maybe<StakePoolRef>;
  transaction?: Maybe<TransactionRef>;
};

export type PoolRetirementCertificateRef = {
  epoch?: Maybe<EpochRef>;
  stakePool?: Maybe<StakePoolRef>;
  transaction?: Maybe<TransactionRef>;
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
  filter?: Maybe<CostModelFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelOrder>;
};


export type ProtocolParametersAlonzoCostModelsAggregateArgs = {
  filter?: Maybe<CostModelFilter>;
};


export type ProtocolParametersAlonzoDecentralizationParameterArgs = {
  filter?: Maybe<RatioFilter>;
};


export type ProtocolParametersAlonzoExecutionPricesArgs = {
  filter?: Maybe<ExecutionPricesFilter>;
};


export type ProtocolParametersAlonzoMaxExecutionUnitsPerBlockArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type ProtocolParametersAlonzoMaxExecutionUnitsPerTransactionArgs = {
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type ProtocolParametersAlonzoMonetaryExpansionArgs = {
  filter?: Maybe<RatioFilter>;
};


export type ProtocolParametersAlonzoPoolInfluenceArgs = {
  filter?: Maybe<RatioFilter>;
};


export type ProtocolParametersAlonzoPoolRetirementEpochBoundArgs = {
  filter?: Maybe<EpochFilter>;
};


export type ProtocolParametersAlonzoProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
};


export type ProtocolParametersAlonzoTreasuryExpansionArgs = {
  filter?: Maybe<RatioFilter>;
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
  and?: Maybe<Array<Maybe<ProtocolParametersAlonzoFilter>>>;
  has?: Maybe<Array<Maybe<ProtocolParametersAlonzoHasFilter>>>;
  not?: Maybe<ProtocolParametersAlonzoFilter>;
  or?: Maybe<Array<Maybe<ProtocolParametersAlonzoFilter>>>;
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
  asc?: Maybe<ProtocolParametersAlonzoOrderable>;
  desc?: Maybe<ProtocolParametersAlonzoOrderable>;
  then?: Maybe<ProtocolParametersAlonzoOrder>;
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
  coinsPerUtxoWord?: Maybe<Scalars['Int']>;
  collateralPercentage?: Maybe<Scalars['Int']>;
  costModels?: Maybe<Array<CostModelRef>>;
  decentralizationParameter?: Maybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: Maybe<Scalars['Int']>;
  executionPrices?: Maybe<ExecutionPricesRef>;
  /** hex-encoded, null if neutral */
  extraEntropy?: Maybe<Scalars['String']>;
  maxBlockBodySize?: Maybe<Scalars['Int']>;
  maxBlockHeaderSize?: Maybe<Scalars['Int']>;
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxExecutionUnitsPerBlock?: Maybe<ExecutionUnitsRef>;
  maxExecutionUnitsPerTransaction?: Maybe<ExecutionUnitsRef>;
  maxTxSize?: Maybe<Scalars['Int']>;
  maxValueSize?: Maybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: Maybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: Maybe<Scalars['Int']>;
  minPoolCost?: Maybe<Scalars['Int']>;
  minUtxoValue?: Maybe<Scalars['Int']>;
  monetaryExpansion?: Maybe<RatioRef>;
  poolDeposit?: Maybe<Scalars['Int']>;
  poolInfluence?: Maybe<RatioRef>;
  poolRetirementEpochBound?: Maybe<EpochRef>;
  protocolVersion?: Maybe<ProtocolVersionRef>;
  stakeKeyDeposit?: Maybe<Scalars['Int']>;
  treasuryExpansion?: Maybe<RatioRef>;
};

export type ProtocolParametersAlonzoRef = {
  coinsPerUtxoWord?: Maybe<Scalars['Int']>;
  collateralPercentage?: Maybe<Scalars['Int']>;
  costModels?: Maybe<Array<CostModelRef>>;
  decentralizationParameter?: Maybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: Maybe<Scalars['Int']>;
  executionPrices?: Maybe<ExecutionPricesRef>;
  /** hex-encoded, null if neutral */
  extraEntropy?: Maybe<Scalars['String']>;
  maxBlockBodySize?: Maybe<Scalars['Int']>;
  maxBlockHeaderSize?: Maybe<Scalars['Int']>;
  maxCollateralInputs?: Maybe<Scalars['Int']>;
  maxExecutionUnitsPerBlock?: Maybe<ExecutionUnitsRef>;
  maxExecutionUnitsPerTransaction?: Maybe<ExecutionUnitsRef>;
  maxTxSize?: Maybe<Scalars['Int']>;
  maxValueSize?: Maybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: Maybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: Maybe<Scalars['Int']>;
  minPoolCost?: Maybe<Scalars['Int']>;
  minUtxoValue?: Maybe<Scalars['Int']>;
  monetaryExpansion?: Maybe<RatioRef>;
  poolDeposit?: Maybe<Scalars['Int']>;
  poolInfluence?: Maybe<RatioRef>;
  poolRetirementEpochBound?: Maybe<EpochRef>;
  protocolVersion?: Maybe<ProtocolVersionRef>;
  stakeKeyDeposit?: Maybe<Scalars['Int']>;
  treasuryExpansion?: Maybe<RatioRef>;
};

export type ProtocolParametersFilter = {
  memberTypes?: Maybe<Array<ProtocolParametersType>>;
  protocolParametersAlonzoFilter?: Maybe<ProtocolParametersAlonzoFilter>;
  protocolParametersShelleyFilter?: Maybe<ProtocolParametersShelleyFilter>;
};

export type ProtocolParametersRef = {
  protocolParametersAlonzoRef?: Maybe<ProtocolParametersAlonzoRef>;
  protocolParametersShelleyRef?: Maybe<ProtocolParametersShelleyRef>;
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
  filter?: Maybe<RatioFilter>;
};


export type ProtocolParametersShelleyMonetaryExpansionArgs = {
  filter?: Maybe<RatioFilter>;
};


export type ProtocolParametersShelleyPoolInfluenceArgs = {
  filter?: Maybe<RatioFilter>;
};


export type ProtocolParametersShelleyPoolRetirementEpochBoundArgs = {
  filter?: Maybe<EpochFilter>;
};


export type ProtocolParametersShelleyProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
};


export type ProtocolParametersShelleyTreasuryExpansionArgs = {
  filter?: Maybe<RatioFilter>;
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
  and?: Maybe<Array<Maybe<ProtocolParametersShelleyFilter>>>;
  has?: Maybe<Array<Maybe<ProtocolParametersShelleyHasFilter>>>;
  not?: Maybe<ProtocolParametersShelleyFilter>;
  or?: Maybe<Array<Maybe<ProtocolParametersShelleyFilter>>>;
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
  asc?: Maybe<ProtocolParametersShelleyOrderable>;
  desc?: Maybe<ProtocolParametersShelleyOrderable>;
  then?: Maybe<ProtocolParametersShelleyOrder>;
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
  decentralizationParameter?: Maybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: Maybe<Scalars['Int']>;
  /** hex-encoded, null if neutral */
  extraEntropy?: Maybe<Scalars['String']>;
  maxBlockBodySize?: Maybe<Scalars['Int']>;
  maxBlockHeaderSize?: Maybe<Scalars['Int']>;
  maxTxSize?: Maybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: Maybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: Maybe<Scalars['Int']>;
  minUtxoValue?: Maybe<Scalars['Int']>;
  monetaryExpansion?: Maybe<RatioRef>;
  poolDeposit?: Maybe<Scalars['Int']>;
  poolInfluence?: Maybe<RatioRef>;
  poolRetirementEpochBound?: Maybe<EpochRef>;
  protocolVersion?: Maybe<ProtocolVersionRef>;
  stakeKeyDeposit?: Maybe<Scalars['Int']>;
  treasuryExpansion?: Maybe<RatioRef>;
};

export type ProtocolParametersShelleyRef = {
  decentralizationParameter?: Maybe<RatioRef>;
  /** n_opt */
  desiredNumberOfPools?: Maybe<Scalars['Int']>;
  /** hex-encoded, null if neutral */
  extraEntropy?: Maybe<Scalars['String']>;
  maxBlockBodySize?: Maybe<Scalars['Int']>;
  maxBlockHeaderSize?: Maybe<Scalars['Int']>;
  maxTxSize?: Maybe<Scalars['Int']>;
  /** minfee A */
  minFeeCoefficient?: Maybe<Scalars['Int']>;
  /** minfee B */
  minFeeConstant?: Maybe<Scalars['Int']>;
  minUtxoValue?: Maybe<Scalars['Int']>;
  monetaryExpansion?: Maybe<RatioRef>;
  poolDeposit?: Maybe<Scalars['Int']>;
  poolInfluence?: Maybe<RatioRef>;
  poolRetirementEpochBound?: Maybe<EpochRef>;
  protocolVersion?: Maybe<ProtocolVersionRef>;
  stakeKeyDeposit?: Maybe<Scalars['Int']>;
  treasuryExpansion?: Maybe<RatioRef>;
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
  filter?: Maybe<ProtocolParametersFilter>;
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
  Patch = 'patch',
  ProtocolParameters = 'protocolParameters'
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
  protocolParameters?: Maybe<ProtocolParametersRef>;
};

export type ProtocolVersionRef = {
  major?: Maybe<Scalars['Int']>;
  minor?: Maybe<Scalars['Int']>;
  patch?: Maybe<Scalars['Int']>;
  protocolParameters?: Maybe<ProtocolParametersRef>;
};

export type PublicKey = {
  __typename?: 'PublicKey';
  addresses?: Maybe<Array<Address>>;
  addressesAggregate?: Maybe<AddressAggregateResult>;
  /** hex-encoded Ed25519 public key hash */
  hash: Scalars['String'];
  /** hex-encoded Ed25519 public key */
  key: Scalars['String'];
  requiredExtraSignatureInTransactions: Array<Transaction>;
  requiredExtraSignatureInTransactionsAggregate?: Maybe<TransactionAggregateResult>;
  rewardAccount?: Maybe<RewardAccount>;
  signatures: Array<Signature>;
  signaturesAggregate?: Maybe<SignatureAggregateResult>;
};


export type PublicKeyAddressesArgs = {
  filter?: Maybe<AddressFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AddressOrder>;
};


export type PublicKeyAddressesAggregateArgs = {
  filter?: Maybe<AddressFilter>;
};


export type PublicKeyRequiredExtraSignatureInTransactionsArgs = {
  filter?: Maybe<TransactionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TransactionOrder>;
};


export type PublicKeyRequiredExtraSignatureInTransactionsAggregateArgs = {
  filter?: Maybe<TransactionFilter>;
};


export type PublicKeyRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type PublicKeySignaturesArgs = {
  filter?: Maybe<SignatureFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SignatureOrder>;
};


export type PublicKeySignaturesAggregateArgs = {
  filter?: Maybe<SignatureFilter>;
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
  and?: Maybe<Array<Maybe<PublicKeyFilter>>>;
  has?: Maybe<Array<Maybe<PublicKeyHasFilter>>>;
  hash?: Maybe<StringHashFilter>;
  not?: Maybe<PublicKeyFilter>;
  or?: Maybe<Array<Maybe<PublicKeyFilter>>>;
};

export enum PublicKeyHasFilter {
  Addresses = 'addresses',
  Hash = 'hash',
  Key = 'key',
  RequiredExtraSignatureInTransactions = 'requiredExtraSignatureInTransactions',
  RewardAccount = 'rewardAccount',
  Signatures = 'signatures'
}

export type PublicKeyOrder = {
  asc?: Maybe<PublicKeyOrderable>;
  desc?: Maybe<PublicKeyOrderable>;
  then?: Maybe<PublicKeyOrder>;
};

export enum PublicKeyOrderable {
  Hash = 'hash',
  Key = 'key'
}

export type PublicKeyPatch = {
  addresses?: Maybe<Array<AddressRef>>;
  /** hex-encoded Ed25519 public key */
  key?: Maybe<Scalars['String']>;
  requiredExtraSignatureInTransactions?: Maybe<Array<TransactionRef>>;
  rewardAccount?: Maybe<RewardAccountRef>;
  signatures?: Maybe<Array<SignatureRef>>;
};

export type PublicKeyRef = {
  addresses?: Maybe<Array<AddressRef>>;
  /** hex-encoded Ed25519 public key hash */
  hash?: Maybe<Scalars['String']>;
  /** hex-encoded Ed25519 public key */
  key?: Maybe<Scalars['String']>;
  requiredExtraSignatureInTransactions?: Maybe<Array<TransactionRef>>;
  rewardAccount?: Maybe<RewardAccountRef>;
  signatures?: Maybe<Array<SignatureRef>>;
};

export type Query = {
  __typename?: 'Query';
  aggregateActiveStake?: Maybe<ActiveStakeAggregateResult>;
  aggregateAda?: Maybe<AdaAggregateResult>;
  aggregateAdaPots?: Maybe<AdaPotsAggregateResult>;
  aggregateAddress?: Maybe<AddressAggregateResult>;
  aggregateAsset?: Maybe<AssetAggregateResult>;
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
  aggregatePlutusScript?: Maybe<PlutusScriptAggregateResult>;
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
  aggregateRewardAccount?: Maybe<RewardAccountAggregateResult>;
  aggregateSignature?: Maybe<SignatureAggregateResult>;
  aggregateSlot?: Maybe<SlotAggregateResult>;
  aggregateStakeDelegationCertificate?: Maybe<StakeDelegationCertificateAggregateResult>;
  aggregateStakeKeyDeregistrationCertificate?: Maybe<StakeKeyDeregistrationCertificateAggregateResult>;
  aggregateStakeKeyRegistrationCertificate?: Maybe<StakeKeyRegistrationCertificateAggregateResult>;
  aggregateStakePool?: Maybe<StakePoolAggregateResult>;
  aggregateStakePoolMetadata?: Maybe<StakePoolMetadataAggregateResult>;
  aggregateStakePoolMetadataJson?: Maybe<StakePoolMetadataJsonAggregateResult>;
  aggregateStakePoolMetrics?: Maybe<StakePoolMetricsAggregateResult>;
  aggregateStakePoolMetricsSize?: Maybe<StakePoolMetricsSizeAggregateResult>;
  aggregateStakePoolMetricsStake?: Maybe<StakePoolMetricsStakeAggregateResult>;
  aggregateStringMetadatum?: Maybe<StringMetadatumAggregateResult>;
  aggregateThePoolsMediaAssets?: Maybe<ThePoolsMediaAssetsAggregateResult>;
  aggregateTimeSettings?: Maybe<TimeSettingsAggregateResult>;
  aggregateToken?: Maybe<TokenAggregateResult>;
  aggregateTransaction?: Maybe<TransactionAggregateResult>;
  aggregateTransactionInput?: Maybe<TransactionInputAggregateResult>;
  aggregateTransactionOutput?: Maybe<TransactionOutputAggregateResult>;
  aggregateValue?: Maybe<ValueAggregateResult>;
  aggregateWithdrawal?: Maybe<WithdrawalAggregateResult>;
  aggregateWitness?: Maybe<WitnessAggregateResult>;
  aggregateWitnessScript?: Maybe<WitnessScriptAggregateResult>;
  getAddress?: Maybe<Address>;
  getBlock?: Maybe<Block>;
  getDatum?: Maybe<Datum>;
  getEpoch?: Maybe<Epoch>;
  getExtendedStakePoolMetadataFields?: Maybe<ExtendedStakePoolMetadataFields>;
  getPlutusScript?: Maybe<PlutusScript>;
  getPublicKey?: Maybe<PublicKey>;
  getSlot?: Maybe<Slot>;
  getStakePool?: Maybe<StakePool>;
  getTransaction?: Maybe<Transaction>;
  queryActiveStake?: Maybe<Array<Maybe<ActiveStake>>>;
  queryAda?: Maybe<Array<Maybe<Ada>>>;
  queryAdaPots?: Maybe<Array<Maybe<AdaPots>>>;
  queryAddress?: Maybe<Array<Maybe<Address>>>;
  queryAsset?: Maybe<Array<Maybe<Asset>>>;
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
  queryPlutusScript?: Maybe<Array<Maybe<PlutusScript>>>;
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
  queryRewardAccount?: Maybe<Array<Maybe<RewardAccount>>>;
  querySignature?: Maybe<Array<Maybe<Signature>>>;
  querySlot?: Maybe<Array<Maybe<Slot>>>;
  queryStakeDelegationCertificate?: Maybe<Array<Maybe<StakeDelegationCertificate>>>;
  queryStakeKeyDeregistrationCertificate?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificate>>>;
  queryStakeKeyRegistrationCertificate?: Maybe<Array<Maybe<StakeKeyRegistrationCertificate>>>;
  queryStakePool?: Maybe<Array<Maybe<StakePool>>>;
  queryStakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
  queryStakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
  queryStakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
  queryStakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
  queryStakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
  queryStringMetadatum?: Maybe<Array<Maybe<StringMetadatum>>>;
  queryThePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
  queryTimeSettings?: Maybe<Array<Maybe<TimeSettings>>>;
  queryToken?: Maybe<Array<Maybe<Token>>>;
  queryTransaction?: Maybe<Array<Maybe<Transaction>>>;
  queryTransactionInput?: Maybe<Array<Maybe<TransactionInput>>>;
  queryTransactionOutput?: Maybe<Array<Maybe<TransactionOutput>>>;
  queryValue?: Maybe<Array<Maybe<Value>>>;
  queryWithdrawal?: Maybe<Array<Maybe<Withdrawal>>>;
  queryWitness?: Maybe<Array<Maybe<Witness>>>;
  queryWitnessScript?: Maybe<Array<Maybe<WitnessScript>>>;
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


export type QueryAggregateAssetArgs = {
  filter?: Maybe<AssetFilter>;
};


export type QueryAggregateAuxiliaryDataArgs = {
  filter?: Maybe<AuxiliaryDataFilter>;
};


export type QueryAggregateAuxiliaryDataBodyArgs = {
  filter?: Maybe<AuxiliaryDataBodyFilter>;
};


export type QueryAggregateAuxiliaryScriptArgs = {
  filter?: Maybe<AuxiliaryScriptFilter>;
};


export type QueryAggregateBlockArgs = {
  filter?: Maybe<BlockFilter>;
};


export type QueryAggregateBootstrapWitnessArgs = {
  filter?: Maybe<BootstrapWitnessFilter>;
};


export type QueryAggregateBytesMetadatumArgs = {
  filter?: Maybe<BytesMetadatumFilter>;
};


export type QueryAggregateCoinSupplyArgs = {
  filter?: Maybe<CoinSupplyFilter>;
};


export type QueryAggregateCostModelArgs = {
  filter?: Maybe<CostModelFilter>;
};


export type QueryAggregateCostModelCoefficientArgs = {
  filter?: Maybe<CostModelCoefficientFilter>;
};


export type QueryAggregateDatumArgs = {
  filter?: Maybe<DatumFilter>;
};


export type QueryAggregateEpochArgs = {
  filter?: Maybe<EpochFilter>;
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


export type QueryAggregateGenesisKeyDelegationCertificateArgs = {
  filter?: Maybe<GenesisKeyDelegationCertificateFilter>;
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


export type QueryAggregateMirCertificateArgs = {
  filter?: Maybe<MirCertificateFilter>;
};


export type QueryAggregateNOfArgs = {
  filter?: Maybe<NOfFilter>;
};


export type QueryAggregateNativeScriptArgs = {
  filter?: Maybe<NativeScriptFilter>;
};


export type QueryAggregateNetworkConstantsArgs = {
  filter?: Maybe<NetworkConstantsFilter>;
};


export type QueryAggregatePlutusScriptArgs = {
  filter?: Maybe<PlutusScriptFilter>;
};


export type QueryAggregatePoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
};


export type QueryAggregatePoolParametersArgs = {
  filter?: Maybe<PoolParametersFilter>;
};


export type QueryAggregatePoolRegistrationCertificateArgs = {
  filter?: Maybe<PoolRegistrationCertificateFilter>;
};


export type QueryAggregatePoolRetirementCertificateArgs = {
  filter?: Maybe<PoolRetirementCertificateFilter>;
};


export type QueryAggregateProtocolParametersAlonzoArgs = {
  filter?: Maybe<ProtocolParametersAlonzoFilter>;
};


export type QueryAggregateProtocolParametersShelleyArgs = {
  filter?: Maybe<ProtocolParametersShelleyFilter>;
};


export type QueryAggregateProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
};


export type QueryAggregatePublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
};


export type QueryAggregateRatioArgs = {
  filter?: Maybe<RatioFilter>;
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


export type QueryAggregateSignatureArgs = {
  filter?: Maybe<SignatureFilter>;
};


export type QueryAggregateSlotArgs = {
  filter?: Maybe<SlotFilter>;
};


export type QueryAggregateStakeDelegationCertificateArgs = {
  filter?: Maybe<StakeDelegationCertificateFilter>;
};


export type QueryAggregateStakeKeyDeregistrationCertificateArgs = {
  filter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
};


export type QueryAggregateStakeKeyRegistrationCertificateArgs = {
  filter?: Maybe<StakeKeyRegistrationCertificateFilter>;
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


export type QueryAggregateStringMetadatumArgs = {
  filter?: Maybe<StringMetadatumFilter>;
};


export type QueryAggregateThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
};


export type QueryAggregateTimeSettingsArgs = {
  filter?: Maybe<TimeSettingsFilter>;
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


export type QueryAggregateWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
};


export type QueryAggregateWitnessScriptArgs = {
  filter?: Maybe<WitnessScriptFilter>;
};


export type QueryGetAddressArgs = {
  address: Scalars['String'];
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


export type QueryGetPublicKeyArgs = {
  hash: Scalars['String'];
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
  filter?: Maybe<ActiveStakeFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ActiveStakeOrder>;
};


export type QueryQueryAdaArgs = {
  filter?: Maybe<AdaFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AdaOrder>;
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


export type QueryQueryAssetArgs = {
  filter?: Maybe<AssetFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<AssetOrder>;
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


export type QueryQueryAuxiliaryScriptArgs = {
  filter?: Maybe<AuxiliaryScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryBlockArgs = {
  filter?: Maybe<BlockFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BlockOrder>;
};


export type QueryQueryBootstrapWitnessArgs = {
  filter?: Maybe<BootstrapWitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BootstrapWitnessOrder>;
};


export type QueryQueryBytesMetadatumArgs = {
  filter?: Maybe<BytesMetadatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BytesMetadatumOrder>;
};


export type QueryQueryCoinSupplyArgs = {
  filter?: Maybe<CoinSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CoinSupplyOrder>;
};


export type QueryQueryCostModelArgs = {
  filter?: Maybe<CostModelFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelOrder>;
};


export type QueryQueryCostModelCoefficientArgs = {
  filter?: Maybe<CostModelCoefficientFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelCoefficientOrder>;
};


export type QueryQueryDatumArgs = {
  filter?: Maybe<DatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<DatumOrder>;
};


export type QueryQueryEpochArgs = {
  filter?: Maybe<EpochFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<EpochOrder>;
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


export type QueryQueryGenesisKeyDelegationCertificateArgs = {
  filter?: Maybe<GenesisKeyDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<GenesisKeyDelegationCertificateOrder>;
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


export type QueryQueryMirCertificateArgs = {
  filter?: Maybe<MirCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<MirCertificateOrder>;
};


export type QueryQueryNOfArgs = {
  filter?: Maybe<NOfFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NOfOrder>;
};


export type QueryQueryNativeScriptArgs = {
  filter?: Maybe<NativeScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryNetworkConstantsArgs = {
  filter?: Maybe<NetworkConstantsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NetworkConstantsOrder>;
};


export type QueryQueryPlutusScriptArgs = {
  filter?: Maybe<PlutusScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PlutusScriptOrder>;
};


export type QueryQueryPoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolContactDataOrder>;
};


export type QueryQueryPoolParametersArgs = {
  filter?: Maybe<PoolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolParametersOrder>;
};


export type QueryQueryPoolRegistrationCertificateArgs = {
  filter?: Maybe<PoolRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryPoolRetirementCertificateArgs = {
  filter?: Maybe<PoolRetirementCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryProtocolParametersAlonzoArgs = {
  filter?: Maybe<ProtocolParametersAlonzoFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersAlonzoOrder>;
};


export type QueryQueryProtocolParametersShelleyArgs = {
  filter?: Maybe<ProtocolParametersShelleyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersShelleyOrder>;
};


export type QueryQueryProtocolVersionArgs = {
  filter?: Maybe<ProtocolVersionFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolVersionOrder>;
};


export type QueryQueryPublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PublicKeyOrder>;
};


export type QueryQueryRatioArgs = {
  filter?: Maybe<RatioFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RatioOrder>;
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


export type QueryQuerySignatureArgs = {
  filter?: Maybe<SignatureFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SignatureOrder>;
};


export type QueryQuerySlotArgs = {
  filter?: Maybe<SlotFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SlotOrder>;
};


export type QueryQueryStakeDelegationCertificateArgs = {
  filter?: Maybe<StakeDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryStakeKeyDeregistrationCertificateArgs = {
  filter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryStakeKeyRegistrationCertificateArgs = {
  filter?: Maybe<StakeKeyRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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


export type QueryQueryTimeSettingsArgs = {
  filter?: Maybe<TimeSettingsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TimeSettingsOrder>;
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


export type QueryQueryWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type QueryQueryWitnessScriptArgs = {
  filter?: Maybe<WitnessScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WitnessScriptOrder>;
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
  and?: Maybe<Array<Maybe<RatioFilter>>>;
  has?: Maybe<Array<Maybe<RatioHasFilter>>>;
  not?: Maybe<RatioFilter>;
  or?: Maybe<Array<Maybe<RatioFilter>>>;
};

export enum RatioHasFilter {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type RatioOrder = {
  asc?: Maybe<RatioOrderable>;
  desc?: Maybe<RatioOrderable>;
  then?: Maybe<RatioOrder>;
};

export enum RatioOrderable {
  Denominator = 'denominator',
  Numerator = 'numerator'
}

export type RatioPatch = {
  denominator?: Maybe<Scalars['Int']>;
  numerator?: Maybe<Scalars['Int']>;
};

export type RatioRef = {
  denominator?: Maybe<Scalars['Int']>;
  numerator?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<ExecutionUnitsFilter>;
};


export type RedeemerWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
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
  Witness = 'witness'
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
  witness?: Maybe<WitnessRef>;
};

export type RedeemerRef = {
  executionUnits?: Maybe<ExecutionUnitsRef>;
  fee?: Maybe<Scalars['Int64']>;
  index?: Maybe<Scalars['Int']>;
  purpose?: Maybe<Scalars['String']>;
  scriptHash?: Maybe<Scalars['String']>;
  witness?: Maybe<WitnessRef>;
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
  delegationCertificates?: Maybe<Array<StakeDelegationCertificate>>;
  delegationCertificatesAggregate?: Maybe<StakeDelegationCertificateAggregateResult>;
  deregistrationCertificates?: Maybe<Array<StakeKeyDeregistrationCertificate>>;
  deregistrationCertificatesAggregate?: Maybe<StakeKeyDeregistrationCertificateAggregateResult>;
  mirCertificates?: Maybe<Array<MirCertificate>>;
  mirCertificatesAggregate?: Maybe<MirCertificateAggregateResult>;
  publicKey: PublicKey;
  registrationCertificates: Array<StakeKeyRegistrationCertificate>;
  registrationCertificatesAggregate?: Maybe<StakeKeyRegistrationCertificateAggregateResult>;
};


export type RewardAccountActiveStakeArgs = {
  filter?: Maybe<ActiveStakeFilter>;
};


export type RewardAccountAddressesArgs = {
  filter?: Maybe<AddressFilter>;
};


export type RewardAccountDelegationCertificatesArgs = {
  filter?: Maybe<StakeDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type RewardAccountDelegationCertificatesAggregateArgs = {
  filter?: Maybe<StakeDelegationCertificateFilter>;
};


export type RewardAccountDeregistrationCertificatesArgs = {
  filter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type RewardAccountDeregistrationCertificatesAggregateArgs = {
  filter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
};


export type RewardAccountMirCertificatesArgs = {
  filter?: Maybe<MirCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<MirCertificateOrder>;
};


export type RewardAccountMirCertificatesAggregateArgs = {
  filter?: Maybe<MirCertificateFilter>;
};


export type RewardAccountPublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
};


export type RewardAccountRegistrationCertificatesArgs = {
  filter?: Maybe<StakeKeyRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type RewardAccountRegistrationCertificatesAggregateArgs = {
  filter?: Maybe<StakeKeyRegistrationCertificateFilter>;
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
  Addresses = 'addresses',
  DelegationCertificates = 'delegationCertificates',
  DeregistrationCertificates = 'deregistrationCertificates',
  MirCertificates = 'mirCertificates',
  PublicKey = 'publicKey',
  RegistrationCertificates = 'registrationCertificates'
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
  delegationCertificates?: Maybe<Array<StakeDelegationCertificateRef>>;
  deregistrationCertificates?: Maybe<Array<StakeKeyDeregistrationCertificateRef>>;
  mirCertificates?: Maybe<Array<MirCertificateRef>>;
  publicKey?: Maybe<PublicKeyRef>;
  registrationCertificates?: Maybe<Array<StakeKeyRegistrationCertificateRef>>;
};

export type RewardAccountRef = {
  activeStake?: Maybe<ActiveStakeRef>;
  address?: Maybe<Scalars['String']>;
  addresses?: Maybe<AddressRef>;
  delegationCertificates?: Maybe<Array<StakeDelegationCertificateRef>>;
  deregistrationCertificates?: Maybe<Array<StakeKeyDeregistrationCertificateRef>>;
  mirCertificates?: Maybe<Array<MirCertificateRef>>;
  publicKey?: Maybe<PublicKeyRef>;
  registrationCertificates?: Maybe<Array<StakeKeyRegistrationCertificateRef>>;
};

export type Script = NativeScript | PlutusScript;

export type ScriptFilter = {
  memberTypes?: Maybe<Array<ScriptType>>;
  nativeScriptFilter?: Maybe<NativeScriptFilter>;
  plutusScriptFilter?: Maybe<PlutusScriptFilter>;
};

export type ScriptRef = {
  nativeScriptRef?: Maybe<NativeScriptRef>;
  plutusScriptRef?: Maybe<PlutusScriptRef>;
};

export enum ScriptType {
  NativeScript = 'NativeScript',
  PlutusScript = 'PlutusScript'
}

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

export type Signature = {
  __typename?: 'Signature';
  publicKey: PublicKey;
  /** hex-encoded Ed25519 signature */
  signature: Scalars['String'];
  witness: Witness;
};


export type SignaturePublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
};


export type SignatureWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
};

export type SignatureAggregateResult = {
  __typename?: 'SignatureAggregateResult';
  count?: Maybe<Scalars['Int']>;
  signatureMax?: Maybe<Scalars['String']>;
  signatureMin?: Maybe<Scalars['String']>;
};

export type SignatureFilter = {
  and?: Maybe<Array<Maybe<SignatureFilter>>>;
  has?: Maybe<Array<Maybe<SignatureHasFilter>>>;
  not?: Maybe<SignatureFilter>;
  or?: Maybe<Array<Maybe<SignatureFilter>>>;
};

export enum SignatureHasFilter {
  PublicKey = 'publicKey',
  Signature = 'signature',
  Witness = 'witness'
}

export type SignatureOrder = {
  asc?: Maybe<SignatureOrderable>;
  desc?: Maybe<SignatureOrderable>;
  then?: Maybe<SignatureOrder>;
};

export enum SignatureOrderable {
  Signature = 'signature'
}

export type SignaturePatch = {
  publicKey?: Maybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: Maybe<Scalars['String']>;
  witness?: Maybe<WitnessRef>;
};

export type SignatureRef = {
  publicKey?: Maybe<PublicKeyRef>;
  /** hex-encoded Ed25519 signature */
  signature?: Maybe<Scalars['String']>;
  witness?: Maybe<WitnessRef>;
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

export type StakeDelegationCertificate = {
  __typename?: 'StakeDelegationCertificate';
  epoch: Epoch;
  rewardAccount: RewardAccount;
  stakePool: StakePool;
  transaction: Transaction;
};


export type StakeDelegationCertificateEpochArgs = {
  filter?: Maybe<EpochFilter>;
};


export type StakeDelegationCertificateRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type StakeDelegationCertificateStakePoolArgs = {
  filter?: Maybe<StakePoolFilter>;
};


export type StakeDelegationCertificateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type StakeDelegationCertificateAggregateResult = {
  __typename?: 'StakeDelegationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type StakeDelegationCertificateFilter = {
  and?: Maybe<Array<Maybe<StakeDelegationCertificateFilter>>>;
  has?: Maybe<Array<Maybe<StakeDelegationCertificateHasFilter>>>;
  not?: Maybe<StakeDelegationCertificateFilter>;
  or?: Maybe<Array<Maybe<StakeDelegationCertificateFilter>>>;
};

export enum StakeDelegationCertificateHasFilter {
  Epoch = 'epoch',
  RewardAccount = 'rewardAccount',
  StakePool = 'stakePool',
  Transaction = 'transaction'
}

export type StakeDelegationCertificatePatch = {
  epoch?: Maybe<EpochRef>;
  rewardAccount?: Maybe<RewardAccountRef>;
  stakePool?: Maybe<StakePoolRef>;
  transaction?: Maybe<TransactionRef>;
};

export type StakeDelegationCertificateRef = {
  epoch?: Maybe<EpochRef>;
  rewardAccount?: Maybe<RewardAccountRef>;
  stakePool?: Maybe<StakePoolRef>;
  transaction?: Maybe<TransactionRef>;
};

export type StakeKeyDeregistrationCertificate = {
  __typename?: 'StakeKeyDeregistrationCertificate';
  rewardAccount: RewardAccount;
  transaction: Transaction;
};


export type StakeKeyDeregistrationCertificateRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type StakeKeyDeregistrationCertificateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type StakeKeyDeregistrationCertificateAggregateResult = {
  __typename?: 'StakeKeyDeregistrationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type StakeKeyDeregistrationCertificateFilter = {
  and?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificateFilter>>>;
  has?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificateHasFilter>>>;
  not?: Maybe<StakeKeyDeregistrationCertificateFilter>;
  or?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificateFilter>>>;
};

export enum StakeKeyDeregistrationCertificateHasFilter {
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type StakeKeyDeregistrationCertificatePatch = {
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
};

export type StakeKeyDeregistrationCertificateRef = {
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
};

export type StakeKeyRegistrationCertificate = {
  __typename?: 'StakeKeyRegistrationCertificate';
  rewardAccount: RewardAccount;
  transaction: Transaction;
};


export type StakeKeyRegistrationCertificateRewardAccountArgs = {
  filter?: Maybe<RewardAccountFilter>;
};


export type StakeKeyRegistrationCertificateTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type StakeKeyRegistrationCertificateAggregateResult = {
  __typename?: 'StakeKeyRegistrationCertificateAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type StakeKeyRegistrationCertificateFilter = {
  and?: Maybe<Array<Maybe<StakeKeyRegistrationCertificateFilter>>>;
  has?: Maybe<Array<Maybe<StakeKeyRegistrationCertificateHasFilter>>>;
  not?: Maybe<StakeKeyRegistrationCertificateFilter>;
  or?: Maybe<Array<Maybe<StakeKeyRegistrationCertificateFilter>>>;
};

export enum StakeKeyRegistrationCertificateHasFilter {
  RewardAccount = 'rewardAccount',
  Transaction = 'transaction'
}

export type StakeKeyRegistrationCertificatePatch = {
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
};

export type StakeKeyRegistrationCertificateRef = {
  rewardAccount?: Maybe<RewardAccountRef>;
  transaction?: Maybe<TransactionRef>;
};

export type StakePool = {
  __typename?: 'StakePool';
  hexId: Scalars['String'];
  id: Scalars['String'];
  metrics: StakePoolMetrics;
  poolParameters: Array<PoolParameters>;
  poolParametersAggregate?: Maybe<PoolParametersAggregateResult>;
  poolRetirementCertificates: Array<PoolRetirementCertificate>;
  poolRetirementCertificatesAggregate?: Maybe<PoolRetirementCertificateAggregateResult>;
  /** active | retired | retiring */
  status: StakePoolStatus;
};


export type StakePoolMetricsArgs = {
  filter?: Maybe<StakePoolMetricsFilter>;
};


export type StakePoolPoolParametersArgs = {
  filter?: Maybe<PoolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolParametersOrder>;
};


export type StakePoolPoolParametersAggregateArgs = {
  filter?: Maybe<PoolParametersFilter>;
};


export type StakePoolPoolRetirementCertificatesArgs = {
  filter?: Maybe<PoolRetirementCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};


export type StakePoolPoolRetirementCertificatesAggregateArgs = {
  filter?: Maybe<PoolRetirementCertificateFilter>;
};

export type StakePoolAggregateResult = {
  __typename?: 'StakePoolAggregateResult';
  count?: Maybe<Scalars['Int']>;
  hexIdMax?: Maybe<Scalars['String']>;
  hexIdMin?: Maybe<Scalars['String']>;
  idMax?: Maybe<Scalars['String']>;
  idMin?: Maybe<Scalars['String']>;
};

export type StakePoolFilter = {
  and?: Maybe<Array<Maybe<StakePoolFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolHasFilter>>>;
  id?: Maybe<StringFullTextFilter_StringHashFilter>;
  not?: Maybe<StakePoolFilter>;
  or?: Maybe<Array<Maybe<StakePoolFilter>>>;
};

export enum StakePoolHasFilter {
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
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
};


export type StakePoolMetadataPoolParametersArgs = {
  filter?: Maybe<PoolParametersFilter>;
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
  poolParameters?: Maybe<PoolParametersRef>;
  stakePoolId?: Maybe<Scalars['String']>;
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
  poolParameters?: Maybe<PoolParametersRef>;
  stakePoolId?: Maybe<Scalars['String']>;
  ticker?: Maybe<Scalars['String']>;
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
  filter?: Maybe<BlockFilter>;
};


export type StakePoolMetricsSizeArgs = {
  filter?: Maybe<StakePoolMetricsSizeFilter>;
};


export type StakePoolMetricsStakeArgs = {
  filter?: Maybe<StakePoolMetricsStakeFilter>;
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
  and?: Maybe<Array<Maybe<StakePoolMetricsFilter>>>;
  has?: Maybe<Array<Maybe<StakePoolMetricsHasFilter>>>;
  not?: Maybe<StakePoolMetricsFilter>;
  or?: Maybe<Array<Maybe<StakePoolMetricsFilter>>>;
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
  asc?: Maybe<StakePoolMetricsOrderable>;
  desc?: Maybe<StakePoolMetricsOrderable>;
  then?: Maybe<StakePoolMetricsOrder>;
};

export enum StakePoolMetricsOrderable {
  BlockNo = 'blockNo',
  BlocksCreated = 'blocksCreated',
  Delegators = 'delegators',
  LivePledge = 'livePledge',
  Saturation = 'saturation'
}

export type StakePoolMetricsPatch = {
  block?: Maybe<BlockRef>;
  blockNo?: Maybe<Scalars['Int']>;
  blocksCreated?: Maybe<Scalars['Int']>;
  delegators?: Maybe<Scalars['Int']>;
  livePledge?: Maybe<Scalars['Int64']>;
  saturation?: Maybe<Scalars['Float']>;
  size?: Maybe<StakePoolMetricsSizeRef>;
  stake?: Maybe<StakePoolMetricsStakeRef>;
};

export type StakePoolMetricsRef = {
  block?: Maybe<BlockRef>;
  blockNo?: Maybe<Scalars['Int']>;
  blocksCreated?: Maybe<Scalars['Int']>;
  delegators?: Maybe<Scalars['Int']>;
  livePledge?: Maybe<Scalars['Int64']>;
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
  active?: Maybe<Scalars['Int64']>;
  live?: Maybe<Scalars['Int64']>;
};

export type StakePoolMetricsStakeRef = {
  active?: Maybe<Scalars['Int64']>;
  live?: Maybe<Scalars['Int64']>;
};

export type StakePoolOrder = {
  asc?: Maybe<StakePoolOrderable>;
  desc?: Maybe<StakePoolOrderable>;
  then?: Maybe<StakePoolOrder>;
};

export enum StakePoolOrderable {
  HexId = 'hexId',
  Id = 'id'
}

export type StakePoolPatch = {
  hexId?: Maybe<Scalars['String']>;
  metrics?: Maybe<StakePoolMetricsRef>;
  poolParameters?: Maybe<Array<PoolParametersRef>>;
  poolRetirementCertificates?: Maybe<Array<PoolRetirementCertificateRef>>;
  /** active | retired | retiring */
  status?: Maybe<StakePoolStatus>;
};

export type StakePoolRef = {
  hexId?: Maybe<Scalars['String']>;
  id?: Maybe<Scalars['String']>;
  metrics?: Maybe<StakePoolMetricsRef>;
  poolParameters?: Maybe<Array<PoolParametersRef>>;
  poolRetirementCertificates?: Maybe<Array<PoolRetirementCertificateRef>>;
  /** active | retired | retiring */
  status?: Maybe<StakePoolStatus>;
};

export enum StakePoolStatus {
  Activating = 'activating',
  Active = 'active',
  Retired = 'retired',
  Retiring = 'retiring'
}

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
  string: Scalars['String'];
};

export type StringMetadatumAggregateResult = {
  __typename?: 'StringMetadatumAggregateResult';
  count?: Maybe<Scalars['Int']>;
  stringMax?: Maybe<Scalars['String']>;
  stringMin?: Maybe<Scalars['String']>;
};

export type StringMetadatumFilter = {
  and?: Maybe<Array<Maybe<StringMetadatumFilter>>>;
  has?: Maybe<Array<Maybe<StringMetadatumHasFilter>>>;
  not?: Maybe<StringMetadatumFilter>;
  or?: Maybe<Array<Maybe<StringMetadatumFilter>>>;
};

export enum StringMetadatumHasFilter {
  String = 'string'
}

export type StringMetadatumOrder = {
  asc?: Maybe<StringMetadatumOrderable>;
  desc?: Maybe<StringMetadatumOrderable>;
  then?: Maybe<StringMetadatumOrder>;
};

export enum StringMetadatumOrderable {
  String = 'string'
}

export type StringMetadatumPatch = {
  string?: Maybe<Scalars['String']>;
};

export type StringMetadatumRef = {
  string?: Maybe<Scalars['String']>;
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

export type TimeSettings = {
  __typename?: 'TimeSettings';
  epochLength: Scalars['Int'];
  fromEpoch: Epoch;
  fromEpochNo: Scalars['Int'];
  slotLength: Scalars['Int'];
};


export type TimeSettingsFromEpochArgs = {
  filter?: Maybe<EpochFilter>;
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
  and?: Maybe<Array<Maybe<TimeSettingsFilter>>>;
  has?: Maybe<Array<Maybe<TimeSettingsHasFilter>>>;
  not?: Maybe<TimeSettingsFilter>;
  or?: Maybe<Array<Maybe<TimeSettingsFilter>>>;
};

export enum TimeSettingsHasFilter {
  EpochLength = 'epochLength',
  FromEpoch = 'fromEpoch',
  FromEpochNo = 'fromEpochNo',
  SlotLength = 'slotLength'
}

export type TimeSettingsOrder = {
  asc?: Maybe<TimeSettingsOrderable>;
  desc?: Maybe<TimeSettingsOrderable>;
  then?: Maybe<TimeSettingsOrder>;
};

export enum TimeSettingsOrderable {
  EpochLength = 'epochLength',
  FromEpochNo = 'fromEpochNo',
  SlotLength = 'slotLength'
}

export type TimeSettingsPatch = {
  epochLength?: Maybe<Scalars['Int']>;
  fromEpoch?: Maybe<EpochRef>;
  fromEpochNo?: Maybe<Scalars['Int']>;
  slotLength?: Maybe<Scalars['Int']>;
};

export type TimeSettingsRef = {
  epochLength?: Maybe<Scalars['Int']>;
  fromEpoch?: Maybe<EpochRef>;
  fromEpochNo?: Maybe<Scalars['Int']>;
  slotLength?: Maybe<Scalars['Int']>;
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
  filter?: Maybe<AuxiliaryDataFilter>;
};


export type TransactionBlockArgs = {
  filter?: Maybe<BlockFilter>;
};


export type TransactionCertificatesArgs = {
  filter?: Maybe<CertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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


export type TransactionInvalidBeforeArgs = {
  filter?: Maybe<SlotFilter>;
};


export type TransactionInvalidHereafterArgs = {
  filter?: Maybe<SlotFilter>;
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


export type TransactionRequiredExtraSignaturesArgs = {
  filter?: Maybe<PublicKeyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PublicKeyOrder>;
};


export type TransactionRequiredExtraSignaturesAggregateArgs = {
  filter?: Maybe<PublicKeyFilter>;
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


export type TransactionWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
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
  and?: Maybe<Array<Maybe<TransactionFilter>>>;
  has?: Maybe<Array<Maybe<TransactionHasFilter>>>;
  hash?: Maybe<StringHashFilter>;
  not?: Maybe<TransactionFilter>;
  or?: Maybe<Array<Maybe<TransactionFilter>>>;
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
  datumHashMax?: Maybe<Scalars['String']>;
  datumHashMin?: Maybe<Scalars['String']>;
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
  DatumHash = 'datumHash',
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
  DatumHash = 'datumHash',
  Index = 'index'
}

export type TransactionOutputPatch = {
  address?: Maybe<AddressRef>;
  /** hex-encoded 32 byte hash */
  datumHash?: Maybe<Scalars['String']>;
  index?: Maybe<Scalars['Int']>;
  transaction?: Maybe<TransactionRef>;
  value?: Maybe<ValueRef>;
};

export type TransactionOutputRef = {
  address?: Maybe<AddressRef>;
  /** hex-encoded 32 byte hash */
  datumHash?: Maybe<Scalars['String']>;
  index?: Maybe<Scalars['Int']>;
  transaction?: Maybe<TransactionRef>;
  value?: Maybe<ValueRef>;
};

export type TransactionPatch = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  block?: Maybe<BlockRef>;
  certificates?: Maybe<Array<CertificateRef>>;
  collateral?: Maybe<Array<TransactionInputRef>>;
  deposit?: Maybe<Scalars['Int64']>;
  fee?: Maybe<Scalars['Int64']>;
  index?: Maybe<Scalars['Int']>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  invalidBefore?: Maybe<SlotRef>;
  invalidHereafter?: Maybe<SlotRef>;
  mint?: Maybe<Array<TokenRef>>;
  outputs?: Maybe<Array<TransactionOutputRef>>;
  requiredExtraSignatures?: Maybe<Array<PublicKeyRef>>;
  scriptIntegrityHash?: Maybe<Scalars['String']>;
  size?: Maybe<Scalars['Int64']>;
  totalOutputCoin?: Maybe<Scalars['Int64']>;
  validContract?: Maybe<Scalars['Boolean']>;
  withdrawals?: Maybe<Array<WithdrawalRef>>;
  witness?: Maybe<WitnessRef>;
};

export type TransactionRef = {
  auxiliaryData?: Maybe<AuxiliaryDataRef>;
  block?: Maybe<BlockRef>;
  certificates?: Maybe<Array<CertificateRef>>;
  collateral?: Maybe<Array<TransactionInputRef>>;
  deposit?: Maybe<Scalars['Int64']>;
  fee?: Maybe<Scalars['Int64']>;
  hash?: Maybe<Scalars['String']>;
  index?: Maybe<Scalars['Int']>;
  inputs?: Maybe<Array<TransactionInputRef>>;
  invalidBefore?: Maybe<SlotRef>;
  invalidHereafter?: Maybe<SlotRef>;
  mint?: Maybe<Array<TokenRef>>;
  outputs?: Maybe<Array<TransactionOutputRef>>;
  requiredExtraSignatures?: Maybe<Array<PublicKeyRef>>;
  scriptIntegrityHash?: Maybe<Scalars['String']>;
  size?: Maybe<Scalars['Int64']>;
  totalOutputCoin?: Maybe<Scalars['Int64']>;
  validContract?: Maybe<Scalars['Boolean']>;
  withdrawals?: Maybe<Array<WithdrawalRef>>;
  witness?: Maybe<WitnessRef>;
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
  order?: Maybe<AdaOrder>;
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

export type UpdateAuxiliaryScriptInput = {
  filter: AuxiliaryScriptFilter;
  remove?: Maybe<AuxiliaryScriptPatch>;
  set?: Maybe<AuxiliaryScriptPatch>;
};

export type UpdateAuxiliaryScriptPayload = {
  __typename?: 'UpdateAuxiliaryScriptPayload';
  auxiliaryScript?: Maybe<Array<Maybe<AuxiliaryScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateAuxiliaryScriptPayloadAuxiliaryScriptArgs = {
  filter?: Maybe<AuxiliaryScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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

export type UpdateBootstrapWitnessInput = {
  filter: BootstrapWitnessFilter;
  remove?: Maybe<BootstrapWitnessPatch>;
  set?: Maybe<BootstrapWitnessPatch>;
};

export type UpdateBootstrapWitnessPayload = {
  __typename?: 'UpdateBootstrapWitnessPayload';
  bootstrapWitness?: Maybe<Array<Maybe<BootstrapWitness>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateBootstrapWitnessPayloadBootstrapWitnessArgs = {
  filter?: Maybe<BootstrapWitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BootstrapWitnessOrder>;
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

export type UpdateCoinSupplyInput = {
  filter: CoinSupplyFilter;
  remove?: Maybe<CoinSupplyPatch>;
  set?: Maybe<CoinSupplyPatch>;
};

export type UpdateCoinSupplyPayload = {
  __typename?: 'UpdateCoinSupplyPayload';
  coinSupply?: Maybe<Array<Maybe<CoinSupply>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateCoinSupplyPayloadCoinSupplyArgs = {
  filter?: Maybe<CoinSupplyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CoinSupplyOrder>;
};

export type UpdateCostModelCoefficientInput = {
  filter: CostModelCoefficientFilter;
  remove?: Maybe<CostModelCoefficientPatch>;
  set?: Maybe<CostModelCoefficientPatch>;
};

export type UpdateCostModelCoefficientPayload = {
  __typename?: 'UpdateCostModelCoefficientPayload';
  costModelCoefficient?: Maybe<Array<Maybe<CostModelCoefficient>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateCostModelCoefficientPayloadCostModelCoefficientArgs = {
  filter?: Maybe<CostModelCoefficientFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelCoefficientOrder>;
};

export type UpdateCostModelInput = {
  filter: CostModelFilter;
  remove?: Maybe<CostModelPatch>;
  set?: Maybe<CostModelPatch>;
};

export type UpdateCostModelPayload = {
  __typename?: 'UpdateCostModelPayload';
  costModel?: Maybe<Array<Maybe<CostModel>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateCostModelPayloadCostModelArgs = {
  filter?: Maybe<CostModelFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<CostModelOrder>;
};

export type UpdateDatumInput = {
  filter: DatumFilter;
  remove?: Maybe<DatumPatch>;
  set?: Maybe<DatumPatch>;
};

export type UpdateDatumPayload = {
  __typename?: 'UpdateDatumPayload';
  datum?: Maybe<Array<Maybe<Datum>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateDatumPayloadDatumArgs = {
  filter?: Maybe<DatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<DatumOrder>;
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

export type UpdateGenesisKeyDelegationCertificateInput = {
  filter: GenesisKeyDelegationCertificateFilter;
  remove?: Maybe<GenesisKeyDelegationCertificatePatch>;
  set?: Maybe<GenesisKeyDelegationCertificatePatch>;
};

export type UpdateGenesisKeyDelegationCertificatePayload = {
  __typename?: 'UpdateGenesisKeyDelegationCertificatePayload';
  genesisKeyDelegationCertificate?: Maybe<Array<Maybe<GenesisKeyDelegationCertificate>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateGenesisKeyDelegationCertificatePayloadGenesisKeyDelegationCertificateArgs = {
  filter?: Maybe<GenesisKeyDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<GenesisKeyDelegationCertificateOrder>;
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

export type UpdateMirCertificateInput = {
  filter: MirCertificateFilter;
  remove?: Maybe<MirCertificatePatch>;
  set?: Maybe<MirCertificatePatch>;
};

export type UpdateMirCertificatePayload = {
  __typename?: 'UpdateMirCertificatePayload';
  mirCertificate?: Maybe<Array<Maybe<MirCertificate>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateMirCertificatePayloadMirCertificateArgs = {
  filter?: Maybe<MirCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<MirCertificateOrder>;
};

export type UpdateNOfInput = {
  filter: NOfFilter;
  remove?: Maybe<NOfPatch>;
  set?: Maybe<NOfPatch>;
};

export type UpdateNOfPayload = {
  __typename?: 'UpdateNOfPayload';
  nOf?: Maybe<Array<Maybe<NOf>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNOfPayloadNOfArgs = {
  filter?: Maybe<NOfFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NOfOrder>;
};

export type UpdateNativeScriptInput = {
  filter: NativeScriptFilter;
  remove?: Maybe<NativeScriptPatch>;
  set?: Maybe<NativeScriptPatch>;
};

export type UpdateNativeScriptPayload = {
  __typename?: 'UpdateNativeScriptPayload';
  nativeScript?: Maybe<Array<Maybe<NativeScript>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNativeScriptPayloadNativeScriptArgs = {
  filter?: Maybe<NativeScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateNetworkConstantsInput = {
  filter: NetworkConstantsFilter;
  remove?: Maybe<NetworkConstantsPatch>;
  set?: Maybe<NetworkConstantsPatch>;
};

export type UpdateNetworkConstantsPayload = {
  __typename?: 'UpdateNetworkConstantsPayload';
  networkConstants?: Maybe<Array<Maybe<NetworkConstants>>>;
  numUids?: Maybe<Scalars['Int']>;
};


export type UpdateNetworkConstantsPayloadNetworkConstantsArgs = {
  filter?: Maybe<NetworkConstantsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<NetworkConstantsOrder>;
};

export type UpdatePlutusScriptInput = {
  filter: PlutusScriptFilter;
  remove?: Maybe<PlutusScriptPatch>;
  set?: Maybe<PlutusScriptPatch>;
};

export type UpdatePlutusScriptPayload = {
  __typename?: 'UpdatePlutusScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  plutusScript?: Maybe<Array<Maybe<PlutusScript>>>;
};


export type UpdatePlutusScriptPayloadPlutusScriptArgs = {
  filter?: Maybe<PlutusScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PlutusScriptOrder>;
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

export type UpdatePoolParametersInput = {
  filter: PoolParametersFilter;
  remove?: Maybe<PoolParametersPatch>;
  set?: Maybe<PoolParametersPatch>;
};

export type UpdatePoolParametersPayload = {
  __typename?: 'UpdatePoolParametersPayload';
  numUids?: Maybe<Scalars['Int']>;
  poolParameters?: Maybe<Array<Maybe<PoolParameters>>>;
};


export type UpdatePoolParametersPayloadPoolParametersArgs = {
  filter?: Maybe<PoolParametersFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolParametersOrder>;
};

export type UpdatePoolRegistrationCertificateInput = {
  filter: PoolRegistrationCertificateFilter;
  remove?: Maybe<PoolRegistrationCertificatePatch>;
  set?: Maybe<PoolRegistrationCertificatePatch>;
};

export type UpdatePoolRegistrationCertificatePayload = {
  __typename?: 'UpdatePoolRegistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  poolRegistrationCertificate?: Maybe<Array<Maybe<PoolRegistrationCertificate>>>;
};


export type UpdatePoolRegistrationCertificatePayloadPoolRegistrationCertificateArgs = {
  filter?: Maybe<PoolRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdatePoolRetirementCertificateInput = {
  filter: PoolRetirementCertificateFilter;
  remove?: Maybe<PoolRetirementCertificatePatch>;
  set?: Maybe<PoolRetirementCertificatePatch>;
};

export type UpdatePoolRetirementCertificatePayload = {
  __typename?: 'UpdatePoolRetirementCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  poolRetirementCertificate?: Maybe<Array<Maybe<PoolRetirementCertificate>>>;
};


export type UpdatePoolRetirementCertificatePayloadPoolRetirementCertificateArgs = {
  filter?: Maybe<PoolRetirementCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateProtocolParametersAlonzoInput = {
  filter: ProtocolParametersAlonzoFilter;
  remove?: Maybe<ProtocolParametersAlonzoPatch>;
  set?: Maybe<ProtocolParametersAlonzoPatch>;
};

export type UpdateProtocolParametersAlonzoPayload = {
  __typename?: 'UpdateProtocolParametersAlonzoPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersAlonzo?: Maybe<Array<Maybe<ProtocolParametersAlonzo>>>;
};


export type UpdateProtocolParametersAlonzoPayloadProtocolParametersAlonzoArgs = {
  filter?: Maybe<ProtocolParametersAlonzoFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersAlonzoOrder>;
};

export type UpdateProtocolParametersShelleyInput = {
  filter: ProtocolParametersShelleyFilter;
  remove?: Maybe<ProtocolParametersShelleyPatch>;
  set?: Maybe<ProtocolParametersShelleyPatch>;
};

export type UpdateProtocolParametersShelleyPayload = {
  __typename?: 'UpdateProtocolParametersShelleyPayload';
  numUids?: Maybe<Scalars['Int']>;
  protocolParametersShelley?: Maybe<Array<Maybe<ProtocolParametersShelley>>>;
};


export type UpdateProtocolParametersShelleyPayloadProtocolParametersShelleyArgs = {
  filter?: Maybe<ProtocolParametersShelleyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ProtocolParametersShelleyOrder>;
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

export type UpdatePublicKeyInput = {
  filter: PublicKeyFilter;
  remove?: Maybe<PublicKeyPatch>;
  set?: Maybe<PublicKeyPatch>;
};

export type UpdatePublicKeyPayload = {
  __typename?: 'UpdatePublicKeyPayload';
  numUids?: Maybe<Scalars['Int']>;
  publicKey?: Maybe<Array<Maybe<PublicKey>>>;
};


export type UpdatePublicKeyPayloadPublicKeyArgs = {
  filter?: Maybe<PublicKeyFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PublicKeyOrder>;
};

export type UpdateRatioInput = {
  filter: RatioFilter;
  remove?: Maybe<RatioPatch>;
  set?: Maybe<RatioPatch>;
};

export type UpdateRatioPayload = {
  __typename?: 'UpdateRatioPayload';
  numUids?: Maybe<Scalars['Int']>;
  ratio?: Maybe<Array<Maybe<Ratio>>>;
};


export type UpdateRatioPayloadRatioArgs = {
  filter?: Maybe<RatioFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RatioOrder>;
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

export type UpdateSignatureInput = {
  filter: SignatureFilter;
  remove?: Maybe<SignaturePatch>;
  set?: Maybe<SignaturePatch>;
};

export type UpdateSignaturePayload = {
  __typename?: 'UpdateSignaturePayload';
  numUids?: Maybe<Scalars['Int']>;
  signature?: Maybe<Array<Maybe<Signature>>>;
};


export type UpdateSignaturePayloadSignatureArgs = {
  filter?: Maybe<SignatureFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SignatureOrder>;
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

export type UpdateStakeDelegationCertificateInput = {
  filter: StakeDelegationCertificateFilter;
  remove?: Maybe<StakeDelegationCertificatePatch>;
  set?: Maybe<StakeDelegationCertificatePatch>;
};

export type UpdateStakeDelegationCertificatePayload = {
  __typename?: 'UpdateStakeDelegationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeDelegationCertificate?: Maybe<Array<Maybe<StakeDelegationCertificate>>>;
};


export type UpdateStakeDelegationCertificatePayloadStakeDelegationCertificateArgs = {
  filter?: Maybe<StakeDelegationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateStakeKeyDeregistrationCertificateInput = {
  filter: StakeKeyDeregistrationCertificateFilter;
  remove?: Maybe<StakeKeyDeregistrationCertificatePatch>;
  set?: Maybe<StakeKeyDeregistrationCertificatePatch>;
};

export type UpdateStakeKeyDeregistrationCertificatePayload = {
  __typename?: 'UpdateStakeKeyDeregistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyDeregistrationCertificate?: Maybe<Array<Maybe<StakeKeyDeregistrationCertificate>>>;
};


export type UpdateStakeKeyDeregistrationCertificatePayloadStakeKeyDeregistrationCertificateArgs = {
  filter?: Maybe<StakeKeyDeregistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateStakeKeyRegistrationCertificateInput = {
  filter: StakeKeyRegistrationCertificateFilter;
  remove?: Maybe<StakeKeyRegistrationCertificatePatch>;
  set?: Maybe<StakeKeyRegistrationCertificatePatch>;
};

export type UpdateStakeKeyRegistrationCertificatePayload = {
  __typename?: 'UpdateStakeKeyRegistrationCertificatePayload';
  numUids?: Maybe<Scalars['Int']>;
  stakeKeyRegistrationCertificate?: Maybe<Array<Maybe<StakeKeyRegistrationCertificate>>>;
};


export type UpdateStakeKeyRegistrationCertificatePayloadStakeKeyRegistrationCertificateArgs = {
  filter?: Maybe<StakeKeyRegistrationCertificateFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
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

export type UpdateTimeSettingsInput = {
  filter: TimeSettingsFilter;
  remove?: Maybe<TimeSettingsPatch>;
  set?: Maybe<TimeSettingsPatch>;
};

export type UpdateTimeSettingsPayload = {
  __typename?: 'UpdateTimeSettingsPayload';
  numUids?: Maybe<Scalars['Int']>;
  timeSettings?: Maybe<Array<Maybe<TimeSettings>>>;
};


export type UpdateTimeSettingsPayloadTimeSettingsArgs = {
  filter?: Maybe<TimeSettingsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<TimeSettingsOrder>;
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

export type UpdateWitnessInput = {
  filter: WitnessFilter;
  remove?: Maybe<WitnessPatch>;
  set?: Maybe<WitnessPatch>;
};

export type UpdateWitnessPayload = {
  __typename?: 'UpdateWitnessPayload';
  numUids?: Maybe<Scalars['Int']>;
  witness?: Maybe<Array<Maybe<Witness>>>;
};


export type UpdateWitnessPayloadWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
};

export type UpdateWitnessScriptInput = {
  filter: WitnessScriptFilter;
  remove?: Maybe<WitnessScriptPatch>;
  set?: Maybe<WitnessScriptPatch>;
};

export type UpdateWitnessScriptPayload = {
  __typename?: 'UpdateWitnessScriptPayload';
  numUids?: Maybe<Scalars['Int']>;
  witnessScript?: Maybe<Array<Maybe<WitnessScript>>>;
};


export type UpdateWitnessScriptPayloadWitnessScriptArgs = {
  filter?: Maybe<WitnessScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WitnessScriptOrder>;
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
  filter?: Maybe<BootstrapWitnessFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<BootstrapWitnessOrder>;
};


export type WitnessBootstrapAggregateArgs = {
  filter?: Maybe<BootstrapWitnessFilter>;
};


export type WitnessDatumsArgs = {
  filter?: Maybe<DatumFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<DatumOrder>;
};


export type WitnessDatumsAggregateArgs = {
  filter?: Maybe<DatumFilter>;
};


export type WitnessRedeemersArgs = {
  filter?: Maybe<RedeemerFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<RedeemerOrder>;
};


export type WitnessRedeemersAggregateArgs = {
  filter?: Maybe<RedeemerFilter>;
};


export type WitnessScriptsArgs = {
  filter?: Maybe<WitnessScriptFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<WitnessScriptOrder>;
};


export type WitnessScriptsAggregateArgs = {
  filter?: Maybe<WitnessScriptFilter>;
};


export type WitnessSignaturesArgs = {
  filter?: Maybe<SignatureFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<SignatureOrder>;
};


export type WitnessSignaturesAggregateArgs = {
  filter?: Maybe<SignatureFilter>;
};


export type WitnessTransactionArgs = {
  filter?: Maybe<TransactionFilter>;
};

export type WitnessAggregateResult = {
  __typename?: 'WitnessAggregateResult';
  count?: Maybe<Scalars['Int']>;
};

export type WitnessFilter = {
  and?: Maybe<Array<Maybe<WitnessFilter>>>;
  has?: Maybe<Array<Maybe<WitnessHasFilter>>>;
  not?: Maybe<WitnessFilter>;
  or?: Maybe<Array<Maybe<WitnessFilter>>>;
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
  bootstrap?: Maybe<Array<BootstrapWitnessRef>>;
  datums?: Maybe<Array<DatumRef>>;
  redeemers?: Maybe<Array<RedeemerRef>>;
  scripts?: Maybe<Array<WitnessScriptRef>>;
  signatures?: Maybe<Array<SignatureRef>>;
  transaction?: Maybe<TransactionRef>;
};

export type WitnessRef = {
  bootstrap?: Maybe<Array<BootstrapWitnessRef>>;
  datums?: Maybe<Array<DatumRef>>;
  redeemers?: Maybe<Array<RedeemerRef>>;
  scripts?: Maybe<Array<WitnessScriptRef>>;
  signatures?: Maybe<Array<SignatureRef>>;
  transaction?: Maybe<TransactionRef>;
};

export type WitnessScript = {
  __typename?: 'WitnessScript';
  key: Scalars['String'];
  script: Script;
  witness: Witness;
};


export type WitnessScriptScriptArgs = {
  filter?: Maybe<ScriptFilter>;
};


export type WitnessScriptWitnessArgs = {
  filter?: Maybe<WitnessFilter>;
};

export type WitnessScriptAggregateResult = {
  __typename?: 'WitnessScriptAggregateResult';
  count?: Maybe<Scalars['Int']>;
  keyMax?: Maybe<Scalars['String']>;
  keyMin?: Maybe<Scalars['String']>;
};

export type WitnessScriptFilter = {
  and?: Maybe<Array<Maybe<WitnessScriptFilter>>>;
  has?: Maybe<Array<Maybe<WitnessScriptHasFilter>>>;
  not?: Maybe<WitnessScriptFilter>;
  or?: Maybe<Array<Maybe<WitnessScriptFilter>>>;
};

export enum WitnessScriptHasFilter {
  Key = 'key',
  Script = 'script',
  Witness = 'witness'
}

export type WitnessScriptOrder = {
  asc?: Maybe<WitnessScriptOrderable>;
  desc?: Maybe<WitnessScriptOrderable>;
  then?: Maybe<WitnessScriptOrder>;
};

export enum WitnessScriptOrderable {
  Key = 'key'
}

export type WitnessScriptPatch = {
  key?: Maybe<Scalars['String']>;
  script?: Maybe<ScriptRef>;
  witness?: Maybe<WitnessRef>;
};

export type WitnessScriptRef = {
  key?: Maybe<Scalars['String']>;
  script?: Maybe<ScriptRef>;
  witness?: Maybe<WitnessRef>;
};

export type BlocksByHashesQueryVariables = Exact<{
  hashes: Array<Scalars['String']> | Scalars['String'];
}>;


export type BlocksByHashesQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', size: bigint, totalOutput: bigint, totalFees: bigint, hash: string, blockNo: number, confirmations: number, slot: { __typename?: 'Slot', number: number, date: string, slotInEpoch: number }, issuer: { __typename?: 'StakePool', id: string, poolParameters: Array<{ __typename?: 'PoolParameters', vrf: string }> }, transactionsAggregate?: { __typename?: 'TransactionAggregateResult', count?: number | null | undefined } | null | undefined, epoch: { __typename?: 'Epoch', number: number }, previousBlock: { __typename?: 'Block', hash: string }, nextBlock: { __typename?: 'Block', hash: string } } | null | undefined> | null | undefined };

export type CurrentProtocolParametersQueryVariables = Exact<{ [key: string]: never; }>;


export type CurrentProtocolParametersQuery = { __typename?: 'Query', queryProtocolVersion?: Array<{ __typename?: 'ProtocolVersion', protocolParameters: { __typename?: 'ProtocolParametersAlonzo', coinsPerUtxoWord: number, maxTxSize: number, maxValueSize: number, stakeKeyDeposit: number, poolDeposit: number, maxCollateralInputs: number, minFeeCoefficient: number, minFeeConstant: number, minPoolCost: number, protocolVersion: { __typename?: 'ProtocolVersion', major: number, minor: number, patch?: number | null | undefined } } | { __typename?: 'ProtocolParametersShelley' } } | null | undefined> | null | undefined };

export type GenesisParametersQueryVariables = Exact<{ [key: string]: never; }>;


export type GenesisParametersQuery = { __typename?: 'Query', queryNetworkConstants?: Array<{ __typename?: 'NetworkConstants', systemStart: string, networkMagic: number, activeSlotsCoefficient: number, securityParameter: number, slotsPerKESPeriod: number, maxKESEvolutions: number, updateQuorum: number } | null | undefined> | null | undefined, queryTimeSettings?: Array<{ __typename?: 'TimeSettings', slotLength: number, epochLength: number } | null | undefined> | null | undefined, queryAda?: Array<{ __typename?: 'Ada', supply: { __typename?: 'CoinSupply', max: string } } | null | undefined> | null | undefined };

export type NetworkInfoQueryVariables = Exact<{ [key: string]: never; }>;


export type NetworkInfoQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', totalLiveStake: bigint, epoch: { __typename?: 'Epoch', number: number, startedAt: { __typename?: 'Slot', date: string }, activeStakeAggregate?: { __typename?: 'ActiveStakeAggregateResult', quantitySum?: bigint | null | undefined } | null | undefined } } | null | undefined> | null | undefined, queryTimeSettings?: Array<{ __typename?: 'TimeSettings', slotLength: number, epochLength: number } | null | undefined> | null | undefined, queryAda?: Array<{ __typename?: 'Ada', supply: { __typename?: 'CoinSupply', circulating: string, max: string, total: string } } | null | undefined> | null | undefined };

export type CertificateTransactionFieldsFragment = { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } };

export type AllPoolParameterFieldsFragment = { __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined };

export type AllStakePoolFieldsFragment = { __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, poolParameters: Array<{ __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: bigint, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: bigint, active: bigint }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, poolRetirementCertificates: Array<{ __typename?: 'PoolRetirementCertificate', transaction: { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } } }> };

export type StakePoolsByMetadataQueryVariables = Exact<{
  query: Scalars['String'];
  omit?: Maybe<Array<Scalars['String']> | Scalars['String']>;
}>;


export type StakePoolsByMetadataQuery = { __typename?: 'Query', queryStakePoolMetadata?: Array<{ __typename?: 'StakePoolMetadata', poolParameters: { __typename?: 'PoolParameters', stakePool: { __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, poolParameters: Array<{ __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: bigint, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: bigint, active: bigint }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, poolRetirementCertificates: Array<{ __typename?: 'PoolRetirementCertificate', transaction: { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } } }> } } } | null | undefined> | null | undefined };

export type StakePoolsQueryVariables = Exact<{
  query: Scalars['String'];
}>;


export type StakePoolsQuery = { __typename?: 'Query', queryStakePool?: Array<{ __typename?: 'StakePool', id: string, hexId: string, status: StakePoolStatus, poolParameters: Array<{ __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: bigint, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: bigint, active: bigint }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, poolRetirementCertificates: Array<{ __typename?: 'PoolRetirementCertificate', transaction: { __typename?: 'Transaction', hash: string, block: { __typename?: 'Block', blockNo: number } } }> } | null | undefined> | null | undefined };

export type TipQueryVariables = Exact<{ [key: string]: never; }>;


export type TipQuery = { __typename?: 'Query', queryBlock?: Array<{ __typename?: 'Block', hash: string, blockNo: number, slot: { __typename?: 'Slot', number: number } } | null | undefined> | null | undefined };

type MetadatumValue_BytesMetadatum_Fragment = { __typename: 'BytesMetadatum', bytes: string };

type MetadatumValue_IntegerMetadatum_Fragment = { __typename: 'IntegerMetadatum', int: number };

type MetadatumValue_MetadatumArray_Fragment = { __typename: 'MetadatumArray' };

type MetadatumValue_MetadatumMap_Fragment = { __typename: 'MetadatumMap' };

type MetadatumValue_StringMetadatum_Fragment = { __typename: 'StringMetadatum', string: string };

export type MetadatumValueFragment = MetadatumValue_BytesMetadatum_Fragment | MetadatumValue_IntegerMetadatum_Fragment | MetadatumValue_MetadatumArray_Fragment | MetadatumValue_MetadatumMap_Fragment | MetadatumValue_StringMetadatum_Fragment;

export type MetadatumMapFragment = { __typename?: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> };

export type MetadatumArrayFragment = { __typename?: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> };

export type ProtocolParametersFragment = { __typename?: 'ProtocolParametersAlonzo', stakeKeyDeposit: number, poolDeposit: number };

export type TxInFragment = { __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } };

export type NonRecursiveNativeScriptFieldsFragment = { __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined };

type AnyScript_NativeScript_Fragment = { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined };

type AnyScript_PlutusScript_Fragment = { __typename: 'PlutusScript', cborHex: string };

export type AnyScriptFragment = AnyScript_NativeScript_Fragment | AnyScript_PlutusScript_Fragment;

export type CoreTransactionFieldsFragment = { __typename?: 'Transaction', fee: bigint, hash: string, index: number, size: bigint, scriptIntegrityHash?: string | null | undefined, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null | undefined, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null | undefined, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null | undefined, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null | undefined, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null | undefined, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null | undefined, addressAttributes?: string | null | undefined, key?: { __typename?: 'PublicKey', hash: string, key: string } | null | undefined }> | null | undefined, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null | undefined, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null | undefined }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, blob?: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null | undefined } } | null | undefined };

export type TransactionsByHashesQueryVariables = Exact<{
  hashes: Array<Scalars['String']> | Scalars['String'];
}>;


export type TransactionsByHashesQuery = { __typename?: 'Query', queryProtocolParametersAlonzo?: Array<{ __typename?: 'ProtocolParametersAlonzo', stakeKeyDeposit: number, poolDeposit: number } | null | undefined> | null | undefined, queryTransaction?: Array<{ __typename?: 'Transaction', fee: bigint, hash: string, index: number, size: bigint, scriptIntegrityHash?: string | null | undefined, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null | undefined, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null | undefined, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null | undefined, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null | undefined, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null | undefined, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null | undefined, addressAttributes?: string | null | undefined, key?: { __typename?: 'PublicKey', hash: string, key: string } | null | undefined }> | null | undefined, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null | undefined, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null | undefined }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, blob?: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null | undefined } } | null | undefined } | null | undefined> | null | undefined };

export type TransactionIdsByAddressesQueryVariables = Exact<{
  addresses: Array<Scalars['String']> | Scalars['String'];
}>;


export type TransactionIdsByAddressesQuery = { __typename?: 'Query', queryProtocolParametersAlonzo?: Array<{ __typename?: 'ProtocolParametersAlonzo', stakeKeyDeposit: number, poolDeposit: number } | null | undefined> | null | undefined, queryAddress?: Array<{ __typename?: 'Address', inputs: Array<{ __typename?: 'TransactionInput', transaction: { __typename?: 'Transaction', fee: bigint, hash: string, index: number, size: bigint, scriptIntegrityHash?: string | null | undefined, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null | undefined, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null | undefined, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null | undefined, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null | undefined, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null | undefined, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null | undefined, addressAttributes?: string | null | undefined, key?: { __typename?: 'PublicKey', hash: string, key: string } | null | undefined }> | null | undefined, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null | undefined, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null | undefined }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, blob?: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null | undefined } } | null | undefined } }>, utxo: Array<{ __typename?: 'TransactionOutput', transaction: { __typename?: 'Transaction', fee: bigint, hash: string, index: number, size: bigint, scriptIntegrityHash?: string | null | undefined, inputs: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }>, outputs: Array<{ __typename?: 'TransactionOutput', datumHash?: string | null | undefined, address: { __typename?: 'Address', address: string }, value: { __typename?: 'Value', coin: bigint, assets?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined } }>, certificates?: Array<{ __typename: 'GenesisKeyDelegationCertificate', genesisHash: string, genesisDelegateHash: string, vrfKeyHash: string } | { __typename: 'MirCertificate', quantity: bigint, pot: string, rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'PoolRegistrationCertificate', epoch: { __typename?: 'Epoch', number: number }, poolParameters: { __typename?: 'PoolParameters', cost: bigint, vrf: string, pledge: bigint, stakePool: { __typename?: 'StakePool', id: string }, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: ExtendedPoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined, owners: Array<{ __typename?: 'RewardAccount', address: string }>, margin: { __typename?: 'Ratio', numerator: number, denominator: number }, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined } | { __typename: 'RelayByNameMultihost', dnsName: string }>, poolRegistrationCertificate: { __typename?: 'PoolRegistrationCertificate', transaction: { __typename?: 'Transaction', hash: string } }, rewardAccount: { __typename?: 'RewardAccount', address: string }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined } } | { __typename: 'PoolRetirementCertificate', epoch: { __typename?: 'Epoch', number: number }, stakePool: { __typename?: 'StakePool', id: string } } | { __typename: 'StakeDelegationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string }, stakePool: { __typename?: 'StakePool', id: string }, epoch: { __typename?: 'Epoch', number: number } } | { __typename: 'StakeKeyDeregistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } } | { __typename: 'StakeKeyRegistrationCertificate', rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, collateral?: Array<{ __typename?: 'TransactionInput', index: number, address: { __typename?: 'Address', address: string } }> | null | undefined, invalidBefore?: { __typename?: 'Slot', slotNo: number } | null | undefined, invalidHereafter?: { __typename?: 'Slot', slotNo: number } | null | undefined, withdrawals?: Array<{ __typename?: 'Withdrawal', quantity: bigint, rewardAccount: { __typename?: 'RewardAccount', address: string } }> | null | undefined, mint?: Array<{ __typename?: 'Token', quantity: string, asset: { __typename?: 'Asset', assetId: string } }> | null | undefined, block: { __typename?: 'Block', blockNo: number, hash: string, slot: { __typename?: 'Slot', number: number } }, requiredExtraSignatures?: Array<{ __typename?: 'PublicKey', hash: string }> | null | undefined, witness: { __typename?: 'Witness', signatures: Array<{ __typename?: 'Signature', signature: string, publicKey: { __typename?: 'PublicKey', key: string } }>, scripts?: Array<{ __typename?: 'WitnessScript', key: string, script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, bootstrap?: Array<{ __typename?: 'BootstrapWitness', signature: string, chainCode?: string | null | undefined, addressAttributes?: string | null | undefined, key?: { __typename?: 'PublicKey', hash: string, key: string } | null | undefined }> | null | undefined, redeemers?: Array<{ __typename?: 'Redeemer', index: number, purpose: string, scriptHash: string, executionUnits: { __typename?: 'ExecutionUnits', memory: number, steps: number } }> | null | undefined, datums?: Array<{ __typename?: 'Datum', hash: string, datum: string }> | null | undefined }, auxiliaryData?: { __typename?: 'AuxiliaryData', hash: string, body: { __typename?: 'AuxiliaryDataBody', scripts?: Array<{ __typename?: 'AuxiliaryScript', script: { __typename: 'NativeScript', any?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, all?: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> | null | undefined, nof?: Array<{ __typename?: 'NOf', key: string, scripts: Array<{ __typename: 'NativeScript', startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined }> }> | null | undefined, startsAt?: { __typename?: 'Slot', number: number } | null | undefined, expiresAt?: { __typename?: 'Slot', number: number } | null | undefined, vkey?: { __typename?: 'PublicKey', key: string } | null | undefined } | { __typename: 'PlutusScript', cborHex: string } }> | null | undefined, blob?: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray', array: Array<{ __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap', map: Array<{ __typename?: 'KeyValueMetadatum', key: string, metadatum: { __typename: 'BytesMetadatum', bytes: string } | { __typename: 'IntegerMetadatum', int: number } | { __typename: 'MetadatumArray' } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string }> } | { __typename: 'MetadatumMap' } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> } | { __typename: 'StringMetadatum', string: string } }> | null | undefined } } | null | undefined } }> } | null | undefined> | null | undefined };

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
  poolRetirementCertificates {
    transaction {
      ...certificateTransactionFields
    }
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
        key
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
    key
    metadatum {
      ...metadatumValue
      ... on MetadatumArray {
        ...metadatumArray
      }
      ... on MetadatumMap {
        __typename
        map {
          key
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
        hash
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
        key
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
export const StakePoolsByMetadataDocument = gql`
    query StakePoolsByMetadata($query: String!, $omit: [String!] = ["NEED_THIS_BECAUSE_IN_OPERATOR_WONT_WORK_WITH_EMPTY_ARR"]) {
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
export const TransactionIdsByAddressesDocument = gql`
    query TransactionIdsByAddresses($addresses: [String!]!) {
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
    TransactionIdsByAddresses(variables: TransactionIdsByAddressesQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<TransactionIdsByAddressesQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<TransactionIdsByAddressesQuery>(TransactionIdsByAddressesDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'TransactionIdsByAddresses');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;