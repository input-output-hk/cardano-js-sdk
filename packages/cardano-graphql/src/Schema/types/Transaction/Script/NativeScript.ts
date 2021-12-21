import { Field, ObjectType } from 'type-graphql';
import { NOf } from './nof';
import { PublicKey } from '../../PublicKey';
import { Slot } from '../../Slot';

// Review: alternatively could create a union type
@ObjectType({ description: 'Exactly one field is not null' })
export class NativeScript {
  @Field(() => [NativeScript], { nullable: true })
  any?: NativeScript[];
  @Field(() => [NativeScript], { nullable: true })
  all?: NativeScript[];
  @Field(() => [NOf], { nullable: true })
  nof?: [NOf];
  @Field(() => Slot, { nullable: true })
  startsAt?: Slot;
  @Field(() => Slot, { nullable: true })
  expiresAt?: Slot;
  @Field(() => PublicKey, { nullable: true })
  vkey?: PublicKey;
}
