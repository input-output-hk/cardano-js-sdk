import { Asset } from '../Asset';
import { Field, ObjectType } from 'type-graphql';
import { TransactionOutput } from './TransactionOutput';

@ObjectType()
export class Token {
  @Field(() => Asset)
  asset: Asset;
  @Field(() => String) // TODO: check if int64 would be sufficient and use that if it is
  quantity: bigint;
  @Field(() => TransactionOutput)
  transactionOutput: TransactionOutput;
}
