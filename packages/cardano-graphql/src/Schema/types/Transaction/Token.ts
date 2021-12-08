import { Asset } from '../Asset';
import { Field, ObjectType } from 'type-graphql';
import { TransactionOutput } from './TransactionOutput';

@ObjectType()
export class Token {
  @Field(() => Asset)
  asset: Asset;
  @Field(() => String)
  quantity: bigint;
  @Field(() => TransactionOutput)
  transactionOutput: TransactionOutput;
}
