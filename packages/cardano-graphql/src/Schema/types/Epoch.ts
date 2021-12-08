/* eslint-disable no-use-before-define */
import { ActiveStake } from './ActiveStake';
import { Block } from './Block';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Int, ObjectType } from 'type-graphql';
import { ProtocolParameters } from './ProtocolParameters';
import { Slot } from './Slot';

@ObjectType()
export class AdaPots {
  @Field(() => Slot)
  slot: Slot;
  @Field(() => String)
  deposits: Cardano.Lovelace;
  @Field(() => String)
  fees: Cardano.Lovelace;
  @Field(() => String)
  reserves: Cardano.Lovelace;
  @Field(() => String)
  rewards: Cardano.Lovelace;
  @Field(() => String)
  treasury: Cardano.Lovelace;
  @Field(() => String)
  utxo: Cardano.Lovelace;
}

@ObjectType()
export class Epoch {
  @Directive('@id')
  @Field(() => Int)
  number: number;
  @Directive('@hasInverse(field: epoch)')
  @Field(() => [ActiveStake])
  activeStake: ActiveStake[];
  @Field(() => AdaPots)
  adaPots: AdaPots;
  @Directive('@hasInverse(field: epoch)')
  @Field(() => [Block])
  blocks: Block[];
  @Field(() => String)
  fees: Cardano.Lovelace;
  @Field(() => String)
  output: string;
  @Field(() => String)
  nonce: Cardano.Hash32ByteBase16;
  @Field(() => ProtocolParameters)
  protocolParams: ProtocolParameters;
  // Review: in original cardano-graphql schema it's of Date type
  @Field(() => Slot)
  startedAt: Slot;
  @Field(() => Slot)
  endedAt: Slot;
}
