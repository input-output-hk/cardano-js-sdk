/* eslint-disable no-use-before-define */
import { BigIntsAsStrings, coinDescription, percentageDescription } from '../../util';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Float, Int, ObjectType, createUnionType } from 'type-graphql';
import { ExtendedStakePoolMetadataFields } from './ExtendedStakePoolMetadataFields';

//  This is not in ./ExtendedStakePoolMetadata to avoid circular import
@ObjectType()
export class ExtendedStakePoolMetadata implements Cardano.ExtendedStakePoolMetadata {
  [k: string]: unknown;
  @Field(() => Int)
  serial: number;
  @Field(() => ExtendedStakePoolMetadataFields)
  pool: Cardano.ExtendedStakePoolMetadataFields;
  @Field(() => StakePoolMetadata)
  metadata: Cardano.StakePoolMetadata;
}

@ObjectType()
export class StakePoolMetricsStake implements BigIntsAsStrings<Cardano.StakePoolMetricsStake> {
  @Field({ description: coinDescription })
  live: string;
  @Field({ description: coinDescription })
  active: string;
}

@ObjectType()
export class StakePoolMetricsSize implements Cardano.StakePoolMetricsSize {
  @Field({ description: percentageDescription })
  live: number;
  @Field({ description: percentageDescription })
  // @Field()
  active: number;
}

@ObjectType()
export class StakePoolMetrics implements BigIntsAsStrings<Cardano.StakePoolMetrics> {
  @Field(() => Int)
  blocksCreated: number;
  @Field({ description: coinDescription })
  livePledge: string;
  @Field(() => StakePoolMetricsStake)
  stake: BigIntsAsStrings<Cardano.StakePoolMetricsStake>;
  @Field(() => StakePoolMetricsSize)
  size: Cardano.StakePoolMetricsSize;
  @Field(() => Float)
  saturation: number;
  @Field(() => Int)
  delegators: number;
}

@ObjectType()
export class StakePoolTransactions implements Cardano.StakePoolTransactions {
  @Field(() => [String])
  registration: string[];
  @Field(() => [String])
  retirement: string[];
}

@ObjectType()
export class StakePoolMetadataJson implements Cardano.PoolMetadata {
  @Field()
  hash: string;
  @Field()
  url: string;
}

@ObjectType()
export class RelayByName implements Cardano.ByName {
  type: 'singlehost-by-name';
  @Field()
  hostname: string;
  @Field(() => Int, { nullable: true })
  port: number;
}

@ObjectType()
export class RelayByAddress implements Cardano.ByAddress {
  type: 'singlehost-by-address';
  @Field(() => String, { nullable: true })
  ipv4?: string;
  @Field(() => String, { nullable: true })
  ipv6?: string;
  @Field(() => Int, { nullable: true })
  port?: number;
}

const Relay = createUnionType({
  name: 'SearchResult',
  // function that returns tuple of object types classes,
  resolveType: (value) => ('hostname' in value ? RelayByName : RelayByAddress),
  // the name of the GraphQL union
  types: () => [RelayByName, RelayByAddress] as const
});

@ObjectType()
export class StakePoolMetadata implements Cardano.StakePoolMetadata {
  @Directive('@id')
  @Field()
  stakePoolId: string;
  // eslint-disable-next-line sonarjs/no-duplicate-string
  @Directive('@search(by: [fulltext])')
  @Field()
  ticker: string;
  @Directive('@search(by: [fulltext])')
  @Field()
  name: string;
  @Field()
  description: string;
  @Field()
  homepage: string;
  @Field({ nullable: true })
  extDataUrl?: string;
  @Field({ nullable: true })
  extSigUrl?: string;
  @Field({ nullable: true })
  extVkey?: string;
  @Field(() => ExtendedStakePoolMetadata, { nullable: true })
  @Directive('@hasInverse(field: metadata)')
  ext?: Cardano.ExtendedStakePoolMetadata;
  @Field(() => StakePool)
  stakePool: Cardano.StakePool;
}

@ObjectType()
export class Fraction implements Cardano.Fraction {
  @Field(() => Int)
  numerator: number;
  @Field(() => Int)
  denominator: number;
}

@ObjectType()
export class StakePool implements BigIntsAsStrings<Cardano.StakePool> {
  @Directive('@search(by: [fulltext])')
  @Directive('@id')
  @Field()
  id: string;
  @Field()
  hexId: string;
  @Field({ description: coinDescription })
  pledge: string;
  @Field({ description: coinDescription })
  cost: string;
  @Field(() => Float)
  margin: Fraction;
  @Field(() => StakePoolMetrics)
  metrics: BigIntsAsStrings<Cardano.StakePoolMetrics>;
  @Field(() => StakePoolTransactions)
  transactions: Cardano.StakePoolTransactions;
  @Field(() => StakePoolMetadataJson, { nullable: true })
  metadataJson?: Cardano.PoolMetadata;
  @Directive('@hasInverse(field: stakePool)')
  @Field(() => StakePoolMetadata, { nullable: true })
  metadata?: BigIntsAsStrings<Cardano.StakePoolMetadata>;
  @Field(() => [String])
  owners: string[];
  @Field()
  vrf: string;
  @Field(() => [Relay])
  relays: Cardano.Relay[];
  @Field()
  rewardAccount: string;
}
