import { Field, ObjectType } from 'type-graphql';
import { NativeScript } from './NativeScript';

@ObjectType()
export class NOf {
  @Field(() => String)
  key: string; // TODO: figure out what this is and document it
  @Field(() => [NativeScript])
  scripts: NativeScript[];
}
