import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Int, ObjectType, createUnionType } from 'type-graphql';
import { Int64 } from '../util';
import { PoolRegistrationCertificate } from '../Transaction/Certificate';
import { Ratio } from '../Ratio';
import { RewardAccount } from '../Address';
import { StakePool } from './StakePool';
import { StakePoolMetadata } from './StakePoolMetadata';

@ObjectType()
export class StakePoolMetadataJson implements Cardano.PoolMetadataJson {
  @Field(() => String)
  hash: Cardano.Hash32ByteBase16;
  @Field()
  url: string;
}

@ObjectType()
export class RelayByName implements Cardano.RelayByName {
  __typename: 'RelayByName';
  @Field()
  hostname: string;
  @Field(() => Int, { nullable: true })
  port: number;
}

@ObjectType()
export class RelayByAddress implements Cardano.RelayByAddress {
  __typename: 'RelayByAddress';
  @Field(() => String, { nullable: true })
  ipv4?: string;
  @Field(() => String, { nullable: true })
  ipv6?: string;
  @Field(() => Int, { nullable: true })
  port?: number;
}

@ObjectType()
export class RelayByNameMultihost implements Cardano.RelayByNameMultihost {
  __typename: 'RelayByNameMultihost';
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
export class PoolParameters {
  @Field(() => Int)
  sinceEpochNo: number;
  @Field(() => Int)
  transactionBlockNo: number;
  @Field(() => String)
  poolId: Cardano.PoolId;
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => Int64)
  pledge: Cardano.Lovelace;
  @Field(() => Int64)
  cost: Cardano.Lovelace;
  @Field(() => Ratio)
  margin: Ratio;
  @Field(() => StakePoolMetadataJson, { nullable: true })
  metadataJson?: StakePoolMetadataJson;
  @Field(() => [Relay])
  relays: typeof Relay[];
  @Field(() => [RewardAccount])
  owners: RewardAccount[];
  @Field(() => String, { description: 'hex-encoded 32 byte vrf vkey' })
  vrf: Cardano.VrfVkHex;
  @Field(() => StakePool)
  stakePool: StakePool;
  @Directive('@hasInverse(field: poolParameters)')
  @Field(() => PoolRegistrationCertificate)
  poolRegistrationCertificate: PoolRegistrationCertificate;
  @Directive('@hasInverse(field: poolParameters)')
  @Field(() => StakePoolMetadata, { nullable: true })
  metadata?: StakePoolMetadata;
}
