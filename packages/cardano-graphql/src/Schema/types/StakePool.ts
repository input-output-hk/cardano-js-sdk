/* eslint-disable no-use-before-define */
import { BigIntsAsStrings, coinDescription, percentageDescription } from './util';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Float, Int, ObjectType, createUnionType, registerEnumType } from 'type-graphql';
import { ExtendedStakePoolMetadataFields } from './ExtendedStakePoolMetadataFields';

enum StakePoolStatus {
  active = 'active',
  retired = 'retired',
  retiring = 'retiring'
}

registerEnumType(StakePoolStatus, { name: 'StakePoolStatus' });

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
  registration: Cardano.TransactionId[];
  @Field(() => [String])
  retirement: Cardano.TransactionId[];
}

@ObjectType()
export class StakePoolMetadataJson implements Cardano.PoolMetadataJson {
  @Field(() => String)
  hash: Cardano.Hash32ByteBase16;
  @Field()
  url: string;
}

@ObjectType()
export class RelayByName implements Omit<Cardano.RelayByName, '__typename'> {
  @Field()
  hostname: string;
  @Field(() => Int, { nullable: true })
  port: number;
}

@ObjectType()
export class RelayByAddress implements Omit<Cardano.RelayByAddress, '__typename'> {
  @Field(() => String, { nullable: true })
  ipv4?: string;
  @Field(() => String, { nullable: true })
  ipv6?: string;
  @Field(() => Int, { nullable: true })
  port?: number;
}

@ObjectType()
export class RelayByNameMultihost implements Omit<Cardano.RelayByNameMultihost, '__typename'> {
  type: 'multihost-by-name';
  @Field()
  dnsName: string;
}

const Relay = createUnionType({
  name: 'SearchResult',
  // function that returns tuple of object types classes,
  resolveType: (value) => {
    if ('hostname' in value) return RelayByName;
    if ('dnsName' in value) return RelayByNameMultihost;
    return RelayByAddress;
  },
  // the name of the GraphQL union
  types: () => [RelayByName, RelayByAddress, RelayByNameMultihost] as const
});

@ObjectType()
export class StakePoolMetadata implements Cardano.StakePoolMetadata {
  @Directive('@id')
  @Field(() => String)
  stakePoolId: Cardano.PoolId;
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
  @Field(() => String, { nullable: true })
  extVkey?: Cardano.PoolMdVk;
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
  @Field(() => String)
  id: Cardano.PoolId;
  @Field()
  hexId: string;
  @Field(() => StakePoolStatus, {
    description: 'active | retired | retiring'
  })
  status: Cardano.StakePoolStatus;
  @Field({ description: coinDescription })
  pledge: string;
  @Field({ description: coinDescription })
  cost: string;
  @Field(() => Fraction)
  margin: Fraction;
  @Field(() => StakePoolMetrics)
  metrics: BigIntsAsStrings<Cardano.StakePoolMetrics>;
  @Field(() => StakePoolTransactions)
  transactions: Cardano.StakePoolTransactions;
  @Field(() => StakePoolMetadataJson, { nullable: true })
  metadataJson?: Cardano.PoolMetadataJson;
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
