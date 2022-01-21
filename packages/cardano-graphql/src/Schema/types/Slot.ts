import { Block } from './Block';
import { Directive, Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class Slot {
  @Directive('@id')
  @Field(() => Int)
  number: number;
  @Field(() => Int)
  slotInEpoch: number;
  @Field()
  date: Date;
  @Field(() => Block, { nullable: true })
  block?: Block;
}
