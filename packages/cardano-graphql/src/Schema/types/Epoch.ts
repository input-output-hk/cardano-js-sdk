/* eslint-disable no-use-before-define */
import { ActiveStake } from './ActiveStake';
import { Block } from './Block';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Int, ObjectType } from 'type-graphql';
import { Int64 } from './util';
import { ProtocolParameters } from './ProtocolParameters';
import { Slot } from './Slot';

@ObjectType()
export class AdaPots {
  @Field(() => Slot)
  slot: Slot;
  @Field(() => Int64)
  deposits: Cardano.Lovelace;
  @Field(() => Int64)
  fees: Cardano.Lovelace;
  @Field(() => Int64)
  reserves: Cardano.Lovelace;
  @Field(() => Int64)
  rewards: Cardano.Lovelace;
  @Field(() => Int64)
  treasury: Cardano.Lovelace;
  @Field(() => Int64)
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
  @Field(() => Int64)
  fees: Cardano.Lovelace;
  @Field(() => Int64)
  output: Cardano.Lovelace;
  @Field(() => String)
  nonce: Cardano.Hash32ByteBase16;
  @Field(() => ProtocolParameters)
  protocolParams: ProtocolParameters;
  @Field(() => Slot)
  startedAt: Slot;
  @Field(() => Slot)
  endedAt: Slot;
}
