/* eslint-disable no-use-before-define */
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Int, ObjectType } from 'type-graphql';
import { Epoch } from './Epoch';
import { Json } from './util';
import { Slot } from './Slot';
import { StakePool } from './StakePool';
import { Transaction } from './Transaction';

@ObjectType()
export class Block {
  @Directive('@id')
  @Field(() => String)
  hash: Cardano.BlockId;
  @Field(() => Int)
  blockNo: Cardano.BlockNo;
  @Directive('@hasInverse(field: block)')
  @Field(() => Slot)
  slot: Slot;
  // Review: it's more intuitive to have this on 'Slot',
  // but this design with Slot{block?} allows Block{slotLeader} field to be non-nullable
  @Field(() => StakePool)
  slotLeader: StakePool;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => Int)
  size: Cardano.BlockSize;
  @Directive('@hasInverse(field: block)')
  @Field(() => [Transaction])
  transactions: Transaction[];
  @Field(() => String)
  totalOutput: Cardano.Lovelace;
  @Field(() => String)
  fees: Cardano.Lovelace;
  @Field(() => String)
  vrf: Cardano.VrfVkBech32;
  @Field(() => Block)
  previousBlock?: Block;
  @Field(() => Block)
  nextBlock?: Block;
  @Field(() => Int)
  confirmations: number;
  @Field(() => String)
  nextBlockProtocolVersion: Json;
  @Field(() => String)
  opCert: Cardano.Hash32ByteBase16;
}
