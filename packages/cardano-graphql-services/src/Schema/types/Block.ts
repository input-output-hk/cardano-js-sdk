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
  /// #if Slot
  @Directive('@hasInverse(field: block)')
  @Field(() => Slot)
  slot: Slot;
  /// #endif
  @Field(() => Int)
  slotNo: Cardano.Slot;
  /// #if StakePool
  @Field(() => StakePool)
  issuer: StakePool;
  /// #endif
  /// #if Epoch
  @Field(() => Epoch)
  epoch: Epoch;
  /// #endif
  /// #if Block.epochNo
  // Need to implement and query TimeSettings to compute this
  @Field(() => Int)
  epochNo: Cardano.Epoch;
  /// #endif
  /// #if Block.size
  @Field(() => Int64)
  size: Cardano.BlockSize;
  /// #endif
  /// #if Block.totalLiveStake
  @Field(() => Int64)
  totalLiveStake: Cardano.Lovelace;
  /// #endif
  /// #if Transaction
  @Directive('@hasInverse(field: block)')
  @Field(() => [Transaction])
  transactions: Transaction[];
  /// #endif
  /// #if Block.totalOutput
  @Field(() => Int64)
  totalOutput: Cardano.Lovelace;
  /// #endif
  /// #if Block.totalFees
  @Field(() => Int64)
  totalFees: Cardano.Lovelace;
  /// #endif
  @Field(() => Block, { nullable: true })
  previousBlock?: Block;
  /// #if Block.nextBlock
  @Field(() => Block, { nullable: true })
  nextBlock?: Block;
  /// #endif

  // Review: confirmations are really just block on top
  // resolve this, you can just query tip

  /// #if ProtocolVersion
  @Field(() => ProtocolVersion, { nullable: true })
  nextBlockProtocolVersion: ProtocolVersion;
  /// #endif

  /// #if Block.opCert
  @Field(() => String)
  // Review: I'm not sure this is useful to track in db.
  // If it is, then we should probably convert this to object, as ogmios provides it.
  opCert: Cardano.Hash32ByteBase16;
  /// #endif
}
