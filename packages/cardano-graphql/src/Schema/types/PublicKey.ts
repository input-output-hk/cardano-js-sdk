import { Address, RewardAccount } from './Address';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { Signature } from './Transaction/Signature';
import { Transaction } from './Transaction';

@ObjectType()
export class PublicKey {
  @Directive('@id')
  @Field(() => String, { description: 'hex-encoded Ed25519 public key hash' })
  hash: Cardano.Ed25519KeyHash;
  @Field(() => String, { description: 'hex-encoded Ed25519 public key' })
  key?: Cardano.Ed25519PublicKey;
  @Field(() => [Transaction])
  requiredExtraSignatureInTransactions: Transaction[];
  @Directive('@hasInverse(field: publicKey)')
  @Field(() => [Signature])
  signatures: Signature[];
  @Directive('@hasInverse(field: paymentPublicKey)')
  @Field(() => [Address], { nullable: true })
  addresses?: Address[];
  @Directive('@hasInverse(field: publicKey)')
  @Field(() => RewardAccount, { nullable: true })
  rewardAccount?: RewardAccount;
}
