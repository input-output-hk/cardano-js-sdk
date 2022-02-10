import { Address, RewardAccount } from './Address';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { Policy } from './Asset/Policy';
import { Signature } from './Transaction/Signature';
import { Transaction } from './Transaction';

@ObjectType()
export class PublicKey {
  @Directive('@id')
  @Field(() => String, { description: 'hex-encoded Ed25519 public key hash' })
  hash: Cardano.Ed25519KeyHash;
  // eslint-disable-next-line sonarjs/no-duplicate-string
  @Directive('@hasInverse(field: publicKey)')
  @Field(() => [Signature])
  signatures: Signature[];
  @Field(() => String, { description: 'hex-encoded Ed25519 public key' })
  key: Cardano.Ed25519PublicKey;
  @Field(() => [Transaction], { nullable: true })
  requiredExtraSignatureInTransactions?: Transaction[];
  @Directive('@hasInverse(field: paymentPublicKey)')
  @Field(() => [Address], { nullable: true })
  addresses?: Address[];
  @Directive('@hasInverse(field: publicKey)')
  @Field(() => RewardAccount, { nullable: true })
  rewardAccount?: RewardAccount;
  @Directive('@hasInverse(field: publicKey)')
  @Field(() => [Policy], { nullable: true })
  policies?: Policy;
}
