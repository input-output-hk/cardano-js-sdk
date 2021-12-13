/* eslint-disable no-use-before-define */
/* eslint-disable sonarjs/no-duplicate-string */
import { AuxiliaryData } from './AuxiliaryData';
import { Block } from '../Block';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Int, ObjectType } from 'type-graphql';
import { Redeemer } from './Redeemer';
import { Slot } from '../Slot';
import { Token } from './Token';
import { TransactionInput } from './TransactionInput';
import { TransactionOutput } from './TransactionOutput';
import { Withdrawal } from './Withdrawal';

@ObjectType()
export class Transaction {
  @Directive('@id')
  @Field(() => String)
  hash: Cardano.TransactionId;
  @Field(() => Block)
  block: Block;
  @Field(() => Int)
  blockIndex: number;
  @Field(() => [TransactionInput], { nullable: true })
  collateral?: TransactionInput[];
  @Field(() => String)
  deposit: Cardano.Lovelace;
  @Field(() => String)
  fee: Cardano.Lovelace;
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [TransactionInput])
  inputs: TransactionInput[];
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [TransactionOutput])
  outputs: TransactionOutput[];
  @Field(() => Int, { nullable: true })
  invalidBefore?: Slot;
  @Field(() => Int, { nullable: true })
  invalidHereafter?: Slot;
  @Directive('@hasInverse(field: transaction)')
  @Field(() => AuxiliaryData, { nullable: true })
  auxiliaryData?: AuxiliaryData;
  // TODO: simplify core type to use negative qty for burn
  @Field(() => [Token], { nullable: true })
  mint?: Token[];
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [Redeemer], { nullable: true })
  redeemers?: Redeemer[];
  // TODO: not sure how we want to handle overflow on aggregates.
  // Got to dig deeper to implementing custom dgraph stuff,
  // maybe it's possible to have custom aggregate query implementations
  // that would return strings (bigints)
  @Field(() => Int)
  size: number;
  @Field(() => String)
  totalOutputCoin: Cardano.Lovelace;
  @Field()
  validContract: boolean;
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [Withdrawal], { nullable: true })
  withdrawals?: Withdrawal[];
}
