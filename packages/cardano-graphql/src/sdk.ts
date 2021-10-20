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
  /** BigInt scalar type. Serializes to String. */
  BigInt: string;
  /** Float in range [0; 1] */
  Percentage: number;
  /** 'active' | 'retired' | 'offline' | 'experimental' | 'private' */
  PoolStatus: 'active' | 'retired' | 'offline' | 'experimental' | 'private';
};

export type ExtendedStakePoolMetadata = {
  __typename?: 'ExtendedStakePoolMetadata';
  pool: ExtendedStakePoolMetadataFields;
  serial: Scalars['Int'];
};

export type ExtendedStakePoolMetadataFields = {
  __typename?: 'ExtendedStakePoolMetadataFields';
  contact?: Maybe<PoolContactData>;
  country?: Maybe<Scalars['String']>;
  id: Scalars['String'];
  itn?: Maybe<ItnVerification>;
  media_assets?: Maybe<ThePoolsMediaAssets>;
  status?: Maybe<Scalars['PoolStatus']>;
};

export type ItnVerification = {
  __typename?: 'ITNVerification';
  owner: Scalars['String'];
  witness: Scalars['String'];
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

export type Query = {
  __typename?: 'Query';
  /** Query stake pools that match any fragment */
  stakePoolsByFragments: Array<StakePool>;
};


export type QueryStakePoolsByFragmentsArgs = {
  fragments: Array<Scalars['String']>;
};

export type RelayByAddress = {
  __typename?: 'RelayByAddress';
  ipv4?: Maybe<Scalars['String']>;
  ipv6?: Maybe<Scalars['String']>;
  port?: Maybe<Scalars['Int']>;
};

export type RelayByName = {
  __typename?: 'RelayByName';
  hostname: Scalars['String'];
  port?: Maybe<Scalars['Int']>;
};

export type SearchResult = RelayByAddress | RelayByName;

export type StakePool = {
  __typename?: 'StakePool';
  cost: Scalars['BigInt'];
  hexId: Scalars['String'];
  id: Scalars['ID'];
  margin: Scalars['Float'];
  metadata?: Maybe<StakePoolMetadata>;
  metadataJson?: Maybe<StakePoolMetadataJson>;
  metrics: StakePoolMetrics;
  owners: Array<Scalars['String']>;
  pledge: Scalars['BigInt'];
  relays: Array<SearchResult>;
  rewardAccount: Scalars['String'];
  transactions: StakePoolTransactions;
  vrf: Scalars['String'];
};

export type StakePoolMetadata = {
  __typename?: 'StakePoolMetadata';
  description: Scalars['String'];
  ext?: Maybe<ExtendedStakePoolMetadata>;
  extDataUrl?: Maybe<Scalars['String']>;
  extSigUrl?: Maybe<Scalars['String']>;
  extVkey?: Maybe<Scalars['String']>;
  homepage: Scalars['String'];
  name: Scalars['String'];
  ticker: Scalars['String'];
};

export type StakePoolMetadataJson = {
  __typename?: 'StakePoolMetadataJson';
  hash: Scalars['String'];
  url: Scalars['String'];
};

export type StakePoolMetrics = {
  __typename?: 'StakePoolMetrics';
  blocksCreated: Scalars['Int'];
  delegators: Scalars['Int'];
  livePledge: Scalars['BigInt'];
  saturation: Scalars['Float'];
  size: StakePoolMetricsSize;
  stake: StakePoolMetricsStake;
};

export type StakePoolMetricsSize = {
  __typename?: 'StakePoolMetricsSize';
  active: Scalars['Percentage'];
  live: Scalars['Percentage'];
};

export type StakePoolMetricsStake = {
  __typename?: 'StakePoolMetricsStake';
  active: Scalars['BigInt'];
  live: Scalars['BigInt'];
};

export type StakePoolTransactions = {
  __typename?: 'StakePoolTransactions';
  registration: Array<Scalars['String']>;
  retirement: Array<Scalars['String']>;
};

export type ThePoolsMediaAssets = {
  __typename?: 'ThePoolsMediaAssets';
  color_bg?: Maybe<Scalars['String']>;
  color_fg?: Maybe<Scalars['String']>;
  icon_png_64x64: Scalars['String'];
  logo_png?: Maybe<Scalars['String']>;
  logo_svg?: Maybe<Scalars['String']>;
};

export type StakePoolsByFragmentsQueryVariables = Exact<{
  fragments: Array<Scalars['String']> | Scalars['String'];
}>;


export type StakePoolsByFragmentsQuery = { __typename?: 'Query', stakePoolsByFragments: Array<{ __typename?: 'StakePool', id: string, hexId: string, owners: Array<string>, cost: string, margin: number, vrf: string, rewardAccount: string, pledge: string, relays: Array<{ __typename: 'RelayByAddress', ipv4?: string | null | undefined, ipv6?: string | null | undefined, port?: number | null | undefined } | { __typename: 'RelayByName', hostname: string, port?: number | null | undefined }>, metrics: { __typename?: 'StakePoolMetrics', blocksCreated: number, livePledge: string, saturation: number, delegators: number, stake: { __typename?: 'StakePoolMetricsStake', live: string, active: string }, size: { __typename?: 'StakePoolMetricsSize', live: number, active: number } }, transactions: { __typename?: 'StakePoolTransactions', registration: Array<string>, retirement: Array<string> }, metadataJson?: { __typename?: 'StakePoolMetadataJson', hash: string, url: string } | null | undefined, metadata?: { __typename?: 'StakePoolMetadata', ticker: string, name: string, description: string, homepage: string, extDataUrl?: string | null | undefined, extSigUrl?: string | null | undefined, extVkey?: string | null | undefined, ext?: { __typename?: 'ExtendedStakePoolMetadata', serial: number, pool: { __typename?: 'ExtendedStakePoolMetadataFields', id: string, country?: string | null | undefined, status?: 'active' | 'retired' | 'offline' | 'experimental' | 'private' | null | undefined, contact?: { __typename?: 'PoolContactData', primary: string, email?: string | null | undefined, facebook?: string | null | undefined, github?: string | null | undefined, feed?: string | null | undefined, telegram?: string | null | undefined, twitter?: string | null | undefined } | null | undefined, media_assets?: { __typename?: 'ThePoolsMediaAssets', icon_png_64x64: string, logo_png?: string | null | undefined, logo_svg?: string | null | undefined, color_fg?: string | null | undefined, color_bg?: string | null | undefined } | null | undefined, itn?: { __typename?: 'ITNVerification', owner: string, witness: string } | null | undefined } } | null | undefined } | null | undefined }> };


export const StakePoolsByFragmentsDocument = gql`
    query StakePoolsByFragments($fragments: [String!]!) {
  stakePoolsByFragments(fragments: $fragments) {
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
}
    `;

export type SdkFunctionWrapper = <T>(action: (requestHeaders?:Record<string, string>) => Promise<T>, operationName: string) => Promise<T>;


const defaultWrapper: SdkFunctionWrapper = (action, _operationName) => action();

export function getSdk(client: GraphQLClient, withWrapper: SdkFunctionWrapper = defaultWrapper) {
  return {
    StakePoolsByFragments(variables: StakePoolsByFragmentsQueryVariables, requestHeaders?: Dom.RequestInit["headers"]): Promise<StakePoolsByFragmentsQuery> {
      return withWrapper((wrappedRequestHeaders) => client.request<StakePoolsByFragmentsQuery>(StakePoolsByFragmentsDocument, variables, {...requestHeaders, ...wrappedRequestHeaders}), 'StakePoolsByFragments');
    }
  };
}
export type Sdk = ReturnType<typeof getSdk>;