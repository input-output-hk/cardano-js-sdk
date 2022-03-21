import { AuxiliaryDataBody } from './AuxiliaryDataBody';
import { Field, ObjectType } from 'type-graphql';
import { Script } from '../Script';

@ObjectType()
export class AuxiliaryScript {
  @Field(() => AuxiliaryDataBody)
  auxiliaryDataBody: AuxiliaryDataBody;
  // TODO: figure it if this shouldn't actually be PlutusScript.
  // Using NativeScript here might not make sense.
  @Field(() => Script)
  script: typeof Script;
}
