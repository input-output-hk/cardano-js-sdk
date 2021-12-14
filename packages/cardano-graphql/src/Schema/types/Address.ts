/* eslint-disable no-use-before-define */
// Review: these types didn't exist in original cardano-graphql schema
import { ActiveStake } from './ActiveStake';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType, registerEnumType } from 'type-graphql';
import { TransactionInput, TransactionOutput } from './Transaction';

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
}

@ObjectType()
export class Address {
  @Field(() => AddressType)
  addressType: AddressType;
  @Field(() => String)
  address: Cardano.Address;
  @Field(() => RewardAccount, { nullable: true })
  rewardAccount?: RewardAccount;
  @Field(() => [TransactionInput], { description: 'Spending history' })
  @Directive('@hasInverse(field: address)')
  inputs: TransactionInput[];
  @Directive('@hasInverse(field: address)')
  @Field(() => [TransactionOutput], { description: 'Balance' })
  utxo: TransactionOutput[];
}
