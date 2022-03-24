import { Block } from './Block';
import { Directive, Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class Slot {
  @Directive('@id')
  @Field(() => Int)
  number: number;
  // TODO: nullable to be reverted when this info is obtained in DataProjector
  @Field(() => Int, { nullable: true })
  slotInEpoch: number;
  @Field()
  date: Date;
  @Field(() => Block, { nullable: true })
  block?: Block;
}
