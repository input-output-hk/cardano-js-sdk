import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';

@ObjectType()
export class PlutusScript {
  @Directive('@id')
  @Field(() => String)
  hash: Cardano.Hash28ByteBase16;
  @Field(() => String, { description: "'PlutusScriptV1' | 'PlutusScriptV2'" })
  type: string;
  @Field(() => String)
  description: string;
  @Field(() => String, { description: 'Serialized plutus-core program' })
  cborHex: string;
}
