import { Cardano } from '@cardano-sdk/core';
import { ExecutionPrices, ExecutionUnits } from './ExUnits';
import { Field, Float, Int, ObjectType } from 'type-graphql';
import { Json } from './util';
import { ProtocolParameters } from './ProtocolParameters';

@ObjectType()
export class AlonzoGenesis {
  @Field(() => Int)
  lovelacePerUTxOWord: number;
  @Field(() => ExecutionPrices)
  executionPrices: ExecutionPrices;
  @Field(() => ExecutionUnits)
  maxTxExUnits: ExecutionUnits;
  @Field(() => ExecutionUnits)
  maxBlockExUnits: ExecutionUnits;
  @Field(() => Int)
  maxValueSize: number;
  @Field(() => Int)
  collateralPercentage: number;
  @Field(() => Int)
  maxCollateralInputs: number;
}

@ObjectType()
export class ByronSoftForkRule {
  @Field(() => String)
  initThd: string;
  @Field(() => String)
  minThd: string;
  @Field(() => String)
  thdDecrement: string;
}

@ObjectType()
export class ByronTxFeePolicy {
  @Field(() => String)
  summand: string;
  @Field(() => String)
  minThd: string;
}

@ObjectType()
export class ByronBlockVersionData {
  @Field(() => Int)
  scriptVerson: number;
  @Field(() => Int)
  slotDuration: number;
  @Field(() => Int)
  maxBlockSize: number;
  @Field(() => Int)
  maxHeaderSize: number;
  @Field(() => Int)
  maxTxSize: number;
  @Field(() => Int)
  maxProposalSize: number;
  @Field(() => String)
  mpcThd: string;
  @Field(() => String)
  heavyDelThd: string;
  @Field(() => String)
  updateVoteThd: string;
  @Field(() => String)
  updateProposalThd: string;
  @Field(() => String)
  updateImplicit: string;
  @Field(() => ByronSoftForkRule)
  softforkRule: ByronSoftForkRule;
  @Field(() => ByronTxFeePolicy)
  txFeePolicy: ByronTxFeePolicy;
  @Field(() => String)
  unlockStakeEpoch: string;
}

@ObjectType()
export class ByronProtocolConsts {
  @Field(() => Int)
  k: number;
  @Field(() => Int, { nullable: true })
  protocolMagic?: number;
}

@ObjectType()
export class ByronGenesis {
  @Field(() => String)
  bootStakeholders: Json;
  @Field(() => String)
  heavyDelegation: Json;
  @Field()
  startTime: Date;
  @Field(() => String)
  nonAvvmBalances: Json;
  @Field(() => String)
  avvmDistr: Json;
  @Field(() => ByronBlockVersionData)
  blockVersionData: ByronBlockVersionData;
  @Field(() => ByronProtocolConsts)
  protocolConsts: ByronProtocolConsts;
}

@ObjectType()
export class ShelleyGenesisStaking {
  @Field(() => String)
  pools: Json;
  @Field(() => String)
  stake: Json;
}

@ObjectType()
export class ShelleyGenesis {
  @Field(() => Float)
  activeSlotsCoeff: number;
  @Field(() => Int)
  epochLength: number;
  @Field(() => String, { nullable: true })
  genDelegs?: Json;
  @Field(() => String)
  initialFunds: Json;
  @Field(() => Int)
  maxKESEvolutions: number;
  @Field(() => String)
  maxLovelaceSupply: Cardano.Lovelace;
  @Field(() => String)
  networkId: string;
  @Field(() => Int)
  networkMagic: number;
  @Field(() => ProtocolParameters)
  protocolParams: ProtocolParameters;
  @Field(() => Int)
  securityParam: number;
  @Field(() => Int)
  slotLength: number;
  @Field(() => Int)
  slotsPerKESPeriod: number;
  @Field(() => ShelleyGenesisStaking)
  staking: ShelleyGenesisStaking;
  @Field(() => Date)
  systemStart: Date;
  @Field(() => Int)
  updateQuorum: number;
}

@ObjectType()
export class Genesis {
  @Field(() => AlonzoGenesis)
  alonzo: AlonzoGenesis;
  @Field(() => ByronGenesis)
  byron: ByronGenesis;
  @Field(() => ShelleyGenesis)
  shelley: ShelleyGenesis;
}
