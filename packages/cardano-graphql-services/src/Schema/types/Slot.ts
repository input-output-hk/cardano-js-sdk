import { Block } from './Block';
import { Directive, Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class Slot {
  @Directive('@id')
  @Field(() => Int)
  number: number;
  /// #if Slot.slotInEpoch
  @Field(() => Int)
  slotInEpoch: number;
  /// #endif
  @Field()
  date: Date;
  @Field(() => Block, { nullable: true })
  block?: Block;
}
