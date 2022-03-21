/* eslint-disable no-use-before-define */
import { AuxiliaryDataBody } from './AuxiliaryDataBody';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { Transaction } from '../Transaction';

@ObjectType()
export class AuxiliaryData {
  @Field(() => String)
  hash: Cardano.Hash32ByteBase16;
  @Directive('@hasInverse(field: auxiliaryData)')
  @Field(() => AuxiliaryDataBody)
  body: AuxiliaryDataBody;
  @Field(() => Transaction)
  transaction: Transaction;
}
