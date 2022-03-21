import { Field, ObjectType } from 'type-graphql';
import { Script } from '../Script';
import { Witness } from './Witness';

@ObjectType()
export class WitnessScript {
  // TODO: document the type of this.
  // Not sure if it's a script hash, or a public key as with signatures
  @Field(() => String)
  key: string;
  @Field(() => Script)
  script: typeof Script;
  @Field(() => Witness)
  witness: Witness;
}
