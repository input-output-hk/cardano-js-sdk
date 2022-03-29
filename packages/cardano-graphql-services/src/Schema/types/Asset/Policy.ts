import { Asset } from './Asset';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { PublicKey } from '../PublicKey';
import { Script } from '../Transaction/Script';

@ObjectType()
export class Policy {
  @Directive('@id')
  @Field(() => String)
  id: Cardano.PolicyId;
  @Directive('@hasInverse(field: policy)')
  // TODO: revert nullable
  @Field(() => [Asset], { nullable: true })
  assets?: Asset[];
  // TODO: revert nullable
  @Field(() => Script, { nullable: true })
  script?: Cardano.Script;
  // TODO: revert nullable
  @Field(() => PublicKey, { nullable: true })
  publicKey?: PublicKey;
}
