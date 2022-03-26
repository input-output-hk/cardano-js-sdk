import { Epoch } from './Epoch';
import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class TimeSettings {
  /// #if Epoch
  @Field(() => Epoch)
  fromEpoch: Epoch;
  /// #endif
  @Field(() => Int)
  fromEpochNo: number;
  @Field(() => Int)
  slotLength: number;
  @Field(() => Int)
  epochLength: number;
}
