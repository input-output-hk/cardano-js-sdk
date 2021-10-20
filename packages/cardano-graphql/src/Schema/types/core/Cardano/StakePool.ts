import * as Ogmios from '@cardano-ogmios/schema';
import { Cardano } from '@cardano-sdk/core';
import { createUnionType, Field, Float, ID, Int, ObjectType } from 'type-graphql';
import { BigIntScalar, PercentageScalar } from '../../util';
import { ExtendedStakePoolMetadata } from './ExtendedStakePoolMetadata';

@ObjectType()
export class StakePoolMetricsStake implements Cardano.StakePoolMetricsStake {
  @Field(() => BigIntScalar)
  live: bigint;
  @Field(() => BigIntScalar)
  active: bigint;
}

@ObjectType()
export class StakePoolMetricsSize implements Cardano.StakePoolMetricsSize {
  @Field(() => PercentageScalar)
  live: number;
  @Field(() => PercentageScalar)
  active: number;
}

@ObjectType()
export class StakePoolMetrics implements Cardano.StakePoolMetrics {
  @Field(() => Int)
  blocksCreated: number;
  @Field(() => BigIntScalar)
  livePledge: bigint;
  @Field(() => StakePoolMetricsStake)
  stake: Cardano.StakePoolMetricsStake;
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
export class StakePoolMetadataJson implements Ogmios.PoolMetadata {
  @Field()
  hash: string;
  @Field()
  url: string;
}

@ObjectType()
export class RelayByName implements Ogmios.ByName {
  @Field()
  hostname: string;
  @Field(() => Int)
  port: number | null;
}

@ObjectType()
export class RelayByAddress implements Ogmios.ByAddress {
  @Field(() => String, { nullable: true })
  ipv4: string | null;
  @Field(() => String, { nullable: true })
  ipv6: string | null;
  @Field(() => Int, { nullable: true })
  port: number | null;
}

const Relay = createUnionType({
  name: 'SearchResult', // the name of the GraphQL union
  types: () => [RelayByName, RelayByAddress] as const, // function that returns tuple of object types classes,
  resolveType: (value) => ('hostname' in value ? RelayByName : RelayByAddress)
});

@ObjectType()
export class StakePoolMetadata implements Cardano.StakePoolMetadata {
  @Field()
  ticker: string;
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
  // Review: what would be a good complexity number?
  @Field(() => ExtendedStakePoolMetadata, { nullable: true, complexity: 5 })
  ext?: Cardano.ExtendedStakePoolMetadata;
}

@ObjectType()
export class StakePool implements Cardano.StakePool {
  @Field(() => ID)
  id: string;
  @Field()
  hexId: string;
  @Field(() => BigIntScalar)
  pledge: bigint;
  @Field(() => BigIntScalar)
  cost: bigint;
  @Field(() => Float)
  margin: number;
  @Field(() => StakePoolMetrics)
  metrics: Cardano.StakePoolMetrics;
  @Field(() => StakePoolTransactions)
  transactions: Cardano.StakePoolTransactions;
  @Field(() => StakePoolMetadataJson, { nullable: true })
  metadataJson?: Ogmios.PoolMetadata;
  // Review: what would be a good complexity number?
  @Field(() => StakePoolMetadata, { nullable: true, complexity: 5 })
  metadata?: Cardano.StakePoolMetadata;
  @Field(() => [String])
  owners: string[];
  @Field()
  vrf: string;
  @Field(() => [Relay])
  relays: Ogmios.Relay[];
  @Field()
  rewardAccount: string;
}
