// Review: do we want to keep protocol parameter types per era?

import { Cardano } from '@cardano-sdk/core';
import { ExecutionPrices, ExecutionUnits } from './ExUnits';
import { Field, Float, Int, ObjectType } from 'type-graphql';
import { Json } from './util';

// Dropped 'Shelley' from name.
@ObjectType()
export class ProtocolParameters {
  @Field(() => Float)
  a0: number;
  @Field(() => Int, { nullable: true })
  coinsPerUtxoWord?: number;
  @Field(() => Int, { nullable: true })
  collateralPercent?: number;
  @Field(() => String, { nullable: true })
  costModels: string; // Review: could this type be improved?
  @Field(() => Float)
  decentralizationParam: number;
  @Field(() => Int)
  eMax: number;
  @Field(() => String, { nullable: true })
  extraEntropy?: Json;
  @Field(() => Int)
  keyDeposit: number;
  @Field(() => Int)
  maxBlockBodySize: number;
  @Field(() => Int)
  maxBlockHeaderSize: number;
  @Field(() => Int)
  maxTxSize: number;
  @Field(() => Int)
  maxValSize: number;
  @Field(() => ExecutionUnits, { nullable: true })
  maxBlockExUnits?: Cardano.ExUnits;
  @Field(() => ExecutionUnits, { nullable: true })
  maxTxExUnits?: Cardano.ExUnits;
  @Field(() => Int, { nullable: true })
  maxCollateralInputs?: number;
  @Field(() => Int)
  minFeeA: number;
  @Field(() => Int)
  minFeeB: number;
  @Field(() => Int)
  minPoolCost: number;
  @Field(() => Int)
  minUTxOValue: number;
  @Field(() => Int)
  nOpt: number;
  @Field(() => Int)
  poolDeposit: number;
  @Field(() => ExecutionPrices, { nullable: true })
  executionPrices: ExecutionPrices;
  @Field(() => String)
  protocolVersion: Json;
  @Field(() => Float)
  rho: number;
  @Field(() => Float)
  tau: number;
}
