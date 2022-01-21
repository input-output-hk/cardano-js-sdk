import { Field, Int, ObjectType } from 'type-graphql';
import { ProtocolParameters } from './ProtocolParametersUnion';

@ObjectType()
export class ProtocolVersion {
  @Field(() => Int)
  major: number;
  @Field(() => Int)
  minor: number;
  @Field(() => Int, { nullable: true })
  patch?: number;
  @Field(() => ProtocolParameters)
  protocolParameters: typeof ProtocolParameters;
}
