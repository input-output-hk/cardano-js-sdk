/* eslint-disable no-use-before-define */
// Review: these types didn't exist in original cardano-graphql schema
import { ActiveStake } from './ActiveStake';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType, registerEnumType } from 'type-graphql';
import {
  MirCertificate,
  StakeDelegationCertificate,
  StakeKeyDeregistrationCertificate,
  StakeKeyRegistrationCertificate,
  TransactionInput,
  TransactionOutput
} from './Transaction';
import { PublicKey } from './PublicKey';

enum AddressType {
  byron = 'byron',
  shelley = 'shelley'
}

registerEnumType(AddressType, { name: 'AddressType' });

@ObjectType()
export class RewardAccount {
  @Field(() => String)
  address: Cardano.RewardAccount;
  @Directive('@hasInverse(field: rewardAccount)')
  @Field(() => ActiveStake)
  activeStake: ActiveStake;
  @Directive('@hasInverse(field: rewardAccount)')
  @Field(() => Address)
  addresses: Address[];
  @Field(() => PublicKey)
  publicKey: PublicKey;
  @Field(() => [StakeKeyRegistrationCertificate])
  registrationCertificates: StakeKeyRegistrationCertificate[];
  @Field(() => [StakeKeyDeregistrationCertificate], { nullable: true })
  deregistrationCertificates?: StakeKeyDeregistrationCertificate[];
  @Field(() => [StakeDelegationCertificate], { nullable: true })
  delegationCertificates?: StakeDelegationCertificate[];
  @Field(() => [MirCertificate], { nullable: true })
  mirCertificates?: MirCertificate[];
}

@ObjectType()
export class Address {
  @Field(() => AddressType)
  addressType: AddressType;
  @Directive('@id')
  @Field(() => String)
  address: Cardano.Address;
  @Field(() => PublicKey)
  paymentPublicKey: PublicKey;
  @Field(() => RewardAccount, { nullable: true })
  rewardAccount?: RewardAccount;
  @Field(() => [TransactionInput], { description: 'Spending history' })
  @Directive('@hasInverse(field: address)')
  inputs: TransactionInput[];
  @Directive('@hasInverse(field: address)')
  @Field(() => [TransactionOutput], { description: 'Balance' })
  utxo: TransactionOutput[];
}
