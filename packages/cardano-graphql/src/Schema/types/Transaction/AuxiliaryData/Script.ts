// Review: seems like it doesn't include actual script in original cardano-graphql schema.
// Should we add it?

import { AuxiliaryDataBody } from './AuxiliaryDataBody';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { Int64 } from '../../util';

@ObjectType()
export class Script {
  @Directive('@id')
  @Field(() => String)
  hash: Cardano.Hash28ByteBase16;
  @Field(() => Int64)
  serializedSize: number;
  @Field(() => String)
  type: string;
  @Field(() => AuxiliaryDataBody)
  auxiliaryDataBody: AuxiliaryDataBody;
}
