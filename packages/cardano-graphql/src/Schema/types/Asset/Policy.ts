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
  @Field(() => [Asset])
  assets: Asset[];
  @Field(() => Script)
  script: Cardano.Script;
  @Field(() => PublicKey)
  publicKey: PublicKey;
}
