import { Epoch } from './Epoch';
import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class TimeSettings {
  @Field(() => Epoch)
  fromEpoch: Epoch;
  @Field(() => Int)
  fromEpochNo: number;
  @Field(() => Int)
  slotLength: number;
  @Field(() => Int)
  epochLength: number;
}
