import { Cardano } from '@cardano-sdk/core';
import { Field, ObjectType } from 'type-graphql';
import { PublicKey } from '../PublicKey';
import { Witness } from './Witness';

@ObjectType()
export class Signature {
  @Field(() => PublicKey)
  publicKey: PublicKey;
  @Field(() => String, { description: 'hex-encoded Ed25519 signature' })
  signature: Cardano.Ed25519Signature;
  @Field(() => Witness)
  witness: Witness;
}
