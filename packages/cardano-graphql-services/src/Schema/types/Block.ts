/* eslint-disable no-use-before-define */
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Int, ObjectType } from 'type-graphql';
import { Epoch } from './Epoch';
import { Int64 } from './util';
import { ProtocolVersion } from './ProtocolParameters/ProtocolVersion';
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
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => StakePool, { nullable: true })
  issuer: StakePool;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => Epoch, { nullable: true })
  epoch: Epoch;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => Int64, { nullable: true })
  size: Cardano.BlockSize;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => Int64, { nullable: true })
  totalLiveStake: Cardano.Lovelace;
  @Directive('@hasInverse(field: block)')
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => [Transaction], { nullable: true })
  transactions: Transaction[];
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => Int64, { nullable: true })
  totalOutput: Cardano.Lovelace;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => Int64, { nullable: true })
  totalFees: Cardano.Lovelace;
  @Field(() => Block)
  previousBlock?: Block;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => Block, { nullable: true })
  nextBlock?: Block;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => Int, { nullable: true })
  confirmations: number;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => ProtocolVersion, { nullable: true })
  nextBlockProtocolVersion: ProtocolVersion;
  // TODO: nullable has to be removed once
  // we have this information when inserting blocks
  @Field(() => String, { nullable: true })
  opCert: Cardano.Hash32ByteBase16;
}
