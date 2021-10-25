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
  Int64: number;
};

export type AddExtendedStakePoolMetadataFieldsInput = {
  contact?: Maybe<PoolContactDataRef>;
  country?: Maybe<Scalars['String']>;
  id: Scalars['String'];
  itn?: Maybe<ItnVerificationRef>;
  media_assets?: Maybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: Maybe<PoolStatus>;
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

export type AddStakePoolInput = {
  /** Coin quantity */
  cost: Scalars['String'];
  hexId: Scalars['String'];
  id: Scalars['String'];
  margin: Scalars['Float'];
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  metrics: StakePoolMetricsRef;
  owners: Array<Scalars['String']>;
  /** Coin quantity */
  pledge: Scalars['String'];
  relays: Array<SearchResultRef>;
  rewardAccount: Scalars['String'];
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

export type AuthRule = {
  and?: Maybe<Array<Maybe<AuthRule>>>;
  not?: Maybe<AuthRule>;
  or?: Maybe<Array<Maybe<AuthRule>>>;
  rule?: Maybe<Scalars['String']>;
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
  status?: Maybe<PoolStatus>;
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
  status?: Maybe<PoolStatus>;
};

export type ExtendedStakePoolMetadataFieldsRef = {
  contact?: Maybe<PoolContactDataRef>;
  country?: Maybe<Scalars['String']>;
  id?: Maybe<Scalars['String']>;
  itn?: Maybe<ItnVerificationRef>;
  media_assets?: Maybe<ThePoolsMediaAssetsRef>;
  /** active | retired | offline | experimental | private */
  status?: Maybe<PoolStatus>;
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

export type IntersectsFilter = {
  multiPolygon?: Maybe<MultiPolygonRef>;
  polygon?: Maybe<PolygonRef>;
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
  addExtendedStakePoolMetadata?: Maybe<AddExtendedStakePoolMetadataPayload>;
  addExtendedStakePoolMetadataFields?: Maybe<AddExtendedStakePoolMetadataFieldsPayload>;
  addITNVerification?: Maybe<AddItnVerificationPayload>;
  addPoolContactData?: Maybe<AddPoolContactDataPayload>;
  addRelayByAddress?: Maybe<AddRelayByAddressPayload>;
  addRelayByName?: Maybe<AddRelayByNamePayload>;
  addStakePool?: Maybe<AddStakePoolPayload>;
  addStakePoolMetadata?: Maybe<AddStakePoolMetadataPayload>;
  addStakePoolMetadataJson?: Maybe<AddStakePoolMetadataJsonPayload>;
  addStakePoolMetrics?: Maybe<AddStakePoolMetricsPayload>;
  addStakePoolMetricsSize?: Maybe<AddStakePoolMetricsSizePayload>;
  addStakePoolMetricsStake?: Maybe<AddStakePoolMetricsStakePayload>;
  addStakePoolTransactions?: Maybe<AddStakePoolTransactionsPayload>;
  addThePoolsMediaAssets?: Maybe<AddThePoolsMediaAssetsPayload>;
  deleteExtendedStakePoolMetadata?: Maybe<DeleteExtendedStakePoolMetadataPayload>;
  deleteExtendedStakePoolMetadataFields?: Maybe<DeleteExtendedStakePoolMetadataFieldsPayload>;
  deleteITNVerification?: Maybe<DeleteItnVerificationPayload>;
  deletePoolContactData?: Maybe<DeletePoolContactDataPayload>;
  deleteRelayByAddress?: Maybe<DeleteRelayByAddressPayload>;
  deleteRelayByName?: Maybe<DeleteRelayByNamePayload>;
  deleteStakePool?: Maybe<DeleteStakePoolPayload>;
  deleteStakePoolMetadata?: Maybe<DeleteStakePoolMetadataPayload>;
  deleteStakePoolMetadataJson?: Maybe<DeleteStakePoolMetadataJsonPayload>;
  deleteStakePoolMetrics?: Maybe<DeleteStakePoolMetricsPayload>;
  deleteStakePoolMetricsSize?: Maybe<DeleteStakePoolMetricsSizePayload>;
  deleteStakePoolMetricsStake?: Maybe<DeleteStakePoolMetricsStakePayload>;
  deleteStakePoolTransactions?: Maybe<DeleteStakePoolTransactionsPayload>;
  deleteThePoolsMediaAssets?: Maybe<DeleteThePoolsMediaAssetsPayload>;
  updateExtendedStakePoolMetadata?: Maybe<UpdateExtendedStakePoolMetadataPayload>;
  updateExtendedStakePoolMetadataFields?: Maybe<UpdateExtendedStakePoolMetadataFieldsPayload>;
  updateITNVerification?: Maybe<UpdateItnVerificationPayload>;
  updatePoolContactData?: Maybe<UpdatePoolContactDataPayload>;
  updateRelayByAddress?: Maybe<UpdateRelayByAddressPayload>;
  updateRelayByName?: Maybe<UpdateRelayByNamePayload>;
  updateStakePool?: Maybe<UpdateStakePoolPayload>;
  updateStakePoolMetadata?: Maybe<UpdateStakePoolMetadataPayload>;
  updateStakePoolMetadataJson?: Maybe<UpdateStakePoolMetadataJsonPayload>;
  updateStakePoolMetrics?: Maybe<UpdateStakePoolMetricsPayload>;
  updateStakePoolMetricsSize?: Maybe<UpdateStakePoolMetricsSizePayload>;
  updateStakePoolMetricsStake?: Maybe<UpdateStakePoolMetricsStakePayload>;
  updateStakePoolTransactions?: Maybe<UpdateStakePoolTransactionsPayload>;
  updateThePoolsMediaAssets?: Maybe<UpdateThePoolsMediaAssetsPayload>;
};


export type MutationAddExtendedStakePoolMetadataArgs = {
  input: Array<AddExtendedStakePoolMetadataInput>;
};


export type MutationAddExtendedStakePoolMetadataFieldsArgs = {
  input: Array<AddExtendedStakePoolMetadataFieldsInput>;
  upsert?: Maybe<Scalars['Boolean']>;
};


export type MutationAddItnVerificationArgs = {
  input: Array<AddItnVerificationInput>;
};


export type MutationAddPoolContactDataArgs = {
  input: Array<AddPoolContactDataInput>;
};


export type MutationAddRelayByAddressArgs = {
  input: Array<AddRelayByAddressInput>;
};


export type MutationAddRelayByNameArgs = {
  input: Array<AddRelayByNameInput>;
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


export type MutationAddThePoolsMediaAssetsArgs = {
  input: Array<AddThePoolsMediaAssetsInput>;
};


export type MutationDeleteExtendedStakePoolMetadataArgs = {
  filter: ExtendedStakePoolMetadataFilter;
};


export type MutationDeleteExtendedStakePoolMetadataFieldsArgs = {
  filter: ExtendedStakePoolMetadataFieldsFilter;
};


export type MutationDeleteItnVerificationArgs = {
  filter: ItnVerificationFilter;
};


export type MutationDeletePoolContactDataArgs = {
  filter: PoolContactDataFilter;
};


export type MutationDeleteRelayByAddressArgs = {
  filter: RelayByAddressFilter;
};


export type MutationDeleteRelayByNameArgs = {
  filter: RelayByNameFilter;
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


export type MutationDeleteThePoolsMediaAssetsArgs = {
  filter: ThePoolsMediaAssetsFilter;
};


export type MutationUpdateExtendedStakePoolMetadataArgs = {
  input: UpdateExtendedStakePoolMetadataInput;
};


export type MutationUpdateExtendedStakePoolMetadataFieldsArgs = {
  input: UpdateExtendedStakePoolMetadataFieldsInput;
};


export type MutationUpdateItnVerificationArgs = {
  input: UpdateItnVerificationInput;
};


export type MutationUpdatePoolContactDataArgs = {
  input: UpdatePoolContactDataInput;
};


export type MutationUpdateRelayByAddressArgs = {
  input: UpdateRelayByAddressInput;
};


export type MutationUpdateRelayByNameArgs = {
  input: UpdateRelayByNameInput;
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


export type MutationUpdateThePoolsMediaAssetsArgs = {
  input: UpdateThePoolsMediaAssetsInput;
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

export enum PoolStatus {
  Active = 'active',
  Experimental = 'experimental',
  Offline = 'offline',
  Private = 'private',
  Retired = 'retired'
}

export type Query = {
  __typename?: 'Query';
  aggregateExtendedStakePoolMetadata?: Maybe<ExtendedStakePoolMetadataAggregateResult>;
  aggregateExtendedStakePoolMetadataFields?: Maybe<ExtendedStakePoolMetadataFieldsAggregateResult>;
  aggregateITNVerification?: Maybe<ItnVerificationAggregateResult>;
  aggregatePoolContactData?: Maybe<PoolContactDataAggregateResult>;
  aggregateRelayByAddress?: Maybe<RelayByAddressAggregateResult>;
  aggregateRelayByName?: Maybe<RelayByNameAggregateResult>;
  aggregateStakePool?: Maybe<StakePoolAggregateResult>;
  aggregateStakePoolMetadata?: Maybe<StakePoolMetadataAggregateResult>;
  aggregateStakePoolMetadataJson?: Maybe<StakePoolMetadataJsonAggregateResult>;
  aggregateStakePoolMetrics?: Maybe<StakePoolMetricsAggregateResult>;
  aggregateStakePoolMetricsSize?: Maybe<StakePoolMetricsSizeAggregateResult>;
  aggregateStakePoolMetricsStake?: Maybe<StakePoolMetricsStakeAggregateResult>;
  aggregateStakePoolTransactions?: Maybe<StakePoolTransactionsAggregateResult>;
  aggregateThePoolsMediaAssets?: Maybe<ThePoolsMediaAssetsAggregateResult>;
  getExtendedStakePoolMetadataFields?: Maybe<ExtendedStakePoolMetadataFields>;
  getStakePool?: Maybe<StakePool>;
  getStakePoolMetadata?: Maybe<StakePoolMetadata>;
  queryExtendedStakePoolMetadata?: Maybe<Array<Maybe<ExtendedStakePoolMetadata>>>;
  queryExtendedStakePoolMetadataFields?: Maybe<Array<Maybe<ExtendedStakePoolMetadataFields>>>;
  queryITNVerification?: Maybe<Array<Maybe<ItnVerification>>>;
  queryPoolContactData?: Maybe<Array<Maybe<PoolContactData>>>;
  queryRelayByAddress?: Maybe<Array<Maybe<RelayByAddress>>>;
  queryRelayByName?: Maybe<Array<Maybe<RelayByName>>>;
  queryStakePool?: Maybe<Array<Maybe<StakePool>>>;
  queryStakePoolMetadata?: Maybe<Array<Maybe<StakePoolMetadata>>>;
  queryStakePoolMetadataJson?: Maybe<Array<Maybe<StakePoolMetadataJson>>>;
  queryStakePoolMetrics?: Maybe<Array<Maybe<StakePoolMetrics>>>;
  queryStakePoolMetricsSize?: Maybe<Array<Maybe<StakePoolMetricsSize>>>;
  queryStakePoolMetricsStake?: Maybe<Array<Maybe<StakePoolMetricsStake>>>;
  queryStakePoolTransactions?: Maybe<Array<Maybe<StakePoolTransactions>>>;
  queryThePoolsMediaAssets?: Maybe<Array<Maybe<ThePoolsMediaAssets>>>;
};


export type QueryAggregateExtendedStakePoolMetadataArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFilter>;
};


export type QueryAggregateExtendedStakePoolMetadataFieldsArgs = {
  filter?: Maybe<ExtendedStakePoolMetadataFieldsFilter>;
};


export type QueryAggregateItnVerificationArgs = {
  filter?: Maybe<ItnVerificationFilter>;
};


export type QueryAggregatePoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
};


export type QueryAggregateRelayByAddressArgs = {
  filter?: Maybe<RelayByAddressFilter>;
};


export type QueryAggregateRelayByNameArgs = {
  filter?: Maybe<RelayByNameFilter>;
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


export type QueryAggregateThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
};


export type QueryGetExtendedStakePoolMetadataFieldsArgs = {
  id: Scalars['String'];
};


export type QueryGetStakePoolArgs = {
  id: Scalars['String'];
};


export type QueryGetStakePoolMetadataArgs = {
  stakePoolId: Scalars['String'];
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


export type QueryQueryItnVerificationArgs = {
  filter?: Maybe<ItnVerificationFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ItnVerificationOrder>;
};


export type QueryQueryPoolContactDataArgs = {
  filter?: Maybe<PoolContactDataFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<PoolContactDataOrder>;
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


export type QueryQueryThePoolsMediaAssetsArgs = {
  filter?: Maybe<ThePoolsMediaAssetsFilter>;
  first?: Maybe<Scalars['Int']>;
  offset?: Maybe<Scalars['Int']>;
  order?: Maybe<ThePoolsMediaAssetsOrder>;
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

export type SearchResult = RelayByAddress | RelayByName;

export type SearchResultFilter = {
  memberTypes?: Maybe<Array<SearchResultType>>;
  relayByAddressFilter?: Maybe<RelayByAddressFilter>;
  relayByNameFilter?: Maybe<RelayByNameFilter>;
};

export type SearchResultRef = {
  relayByAddressRef?: Maybe<RelayByAddressRef>;
  relayByNameRef?: Maybe<RelayByNameRef>;
};

export enum SearchResultType {
  RelayByAddress = 'RelayByAddress',
  RelayByName = 'RelayByName'
}

export type StakePool = {
  __typename?: 'StakePool';
  /** Coin quantity */
  cost: Scalars['String'];
  hexId: Scalars['String'];
  id: Scalars['String'];
  margin: Scalars['Float'];
  metadata?: Maybe<StakePoolMetadata>;
  metadataJson?: Maybe<StakePoolMetadataJson>;
  metrics: StakePoolMetrics;
  owners: Array<Scalars['String']>;
  /** Coin quantity */
  pledge: Scalars['String'];
  relays: Array<SearchResult>;
  rewardAccount: Scalars['String'];
  transactions: StakePoolTransactions;
  vrf: Scalars['String'];
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
  marginAvg?: Maybe<Scalars['Float']>;
  marginMax?: Maybe<Scalars['Float']>;
  marginMin?: Maybe<Scalars['Float']>;
  marginSum?: Maybe<Scalars['Float']>;
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
  Margin = 'margin',
  Pledge = 'pledge',
  RewardAccount = 'rewardAccount',
  Vrf = 'vrf'
}

export type StakePoolPatch = {
  /** Coin quantity */
  cost?: Maybe<Scalars['String']>;
  hexId?: Maybe<Scalars['String']>;
  margin?: Maybe<Scalars['Float']>;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  metrics?: Maybe<StakePoolMetricsRef>;
  owners?: Maybe<Array<Scalars['String']>>;
  /** Coin quantity */
  pledge?: Maybe<Scalars['String']>;
  relays?: Maybe<Array<SearchResultRef>>;
  rewardAccount?: Maybe<Scalars['String']>;
  transactions?: Maybe<StakePoolTransactionsRef>;
  vrf?: Maybe<Scalars['String']>;
};

export type StakePoolRef = {
  /** Coin quantity */
  cost?: Maybe<Scalars['String']>;
  hexId?: Maybe<Scalars['String']>;
  id?: Maybe<Scalars['String']>;
  margin?: Maybe<Scalars['Float']>;
  metadata?: Maybe<StakePoolMetadataRef>;
  metadataJson?: Maybe<StakePoolMetadataJsonRef>;
  metrics?: Maybe<StakePoolMetricsRef>;
  owners?: Maybe<Array<Scalars['String']>>;
  /** Coin quantity */
  pledge?: Maybe<Scalars['String']>;
  relays?: Maybe<Array<SearchResultRef>>;
  rewardAccount?: Maybe<Scalars['String']>;
  transactions?: Maybe<StakePoolTransactionsRef>;
  vrf?: Maybe<Scalars['String']>;
};

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

export type WithinFilter = {
  polygon: PolygonRef;
};

export type AllStakePoolFieldsFragment = { __typename?: 'StakePool', id: string, hexId: string, owners: Array<string>, cost: string, margin: number, vrf: string, rewardAccount: string, pledge: string, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: string, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: string, active: string }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, transactions: { __typename?: 'StakePoolTransactions', registration: Array<string>, retirement: Array<string> }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: PoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined };

export type StakePoolsByMetadataQueryVariables = Exact<{
  query: Scalars['String'];
  omit?: Maybe<Array<Scalars['String']> | Scalars['String']>;
}>;


export type StakePoolsByMetadataQuery = { __typename?: 'Query', queryStakePoolMetadata?: Array<{ __typename?: 'StakePoolMetadata', stakePool: { __typename?: 'StakePool', id: string, hexId: string, owners: Array<string>, cost: string, margin: number, vrf: string, rewardAccount: string, pledge: string, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: string, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: string, active: string }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, transactions: { __typename?: 'StakePoolTransactions', registration: Array<string>, retirement: Array<string> }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: PoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined } } | null | undefined> | null | undefined };

export type StakePoolsQueryVariables = Exact<{
  query: Scalars['String'];
}>;


export type StakePoolsQuery = { __typename?: 'Query', queryStakePool?: Array<{ __typename?: 'StakePool', id: string, hexId: string, owners: Array<string>, cost: string, margin: number, vrf: string, rewardAccount: string, pledge: string, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: string, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: string, active: string }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, transactions: { __typename?: 'StakePoolTransactions', registration: Array<string>, retirement: Array<string> }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: PoolStatus | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined } | null | undefined> | null | undefined };

export const AllStakePoolFieldsFragmentDoc = gql`
    fragment allStakePoolFields on StakePool {
  id
  hexId
  owners
  cost
  margin
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

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName) => action();

export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    StakePoolsByMetadata(variables: StakePoolsByMetadataQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<StakePoolsByMetadataQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<StakePoolsByMetadataQuery>(StakePoolsByMetadataDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'StakePoolsByMetadata');
    },
    StakePools(variables: StakePoolsQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<StakePoolsQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<StakePoolsQuery>(StakePoolsDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'StakePools');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;