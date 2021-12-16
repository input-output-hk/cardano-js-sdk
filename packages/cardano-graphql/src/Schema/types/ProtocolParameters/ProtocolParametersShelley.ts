// Review: do we want to keep protocol parameter types per era?

import { Epoch } from '../Epoch';
import { Field, Int, ObjectType } from 'type-graphql';
import { ProtocolVersion } from './ProtocolVersion';
import { Ratio } from '../Ratio';

@ObjectType()
export class ProtocolParametersShelley {
  @Field(() => Int, { description: 'minfee A' })
  minFeeCoefficient: number;
  @Field(() => Int, { description: 'minfee B' })
  minFeeConstant: number;
  @Field(() => Int)
  maxBlockBodySize: number;
  @Field(() => Int)
  maxBlockHeaderSize: number;
  @Field(() => Int)
  maxTxSize: number;
  @Field(() => Int)
  stakeKeyDeposit: number;
  @Field(() => Int)
  poolDeposit: number;
  @Field(() => Epoch, { description: 'maximum epoch' })
  poolRetirementEpochBound: Epoch;
  @Field(() => Int, { description: 'n_opt' })
  desiredNumberOfPools: number;
  @Field(() => Ratio, { description: 'pool pledge influence' })
  poolInfluence: Ratio;
  @Field(() => Ratio, { description: 'expansion rate' })
  monetaryExpansion: Ratio;
  @Field(() => Ratio, { description: 'treasury growth rate' })
  treasuryExpansion: Ratio;
  @Field(() => Ratio, { description: 'd. decentralization constant' })
  decentralizationParameter: Ratio;
  @Field(() => String, { description: 'hex-encoded, null if neutral', nullable: true })
  extraEntropy?: string;
  @Field(() => ProtocolVersion)
  protocolVersion: ProtocolVersion;
  @Field(() => Int)
  minUtxoValue: number;
}
