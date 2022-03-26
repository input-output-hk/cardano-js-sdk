/* eslint-disable no-use-before-define */
import { ActiveStake } from './ActiveStake';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType, registerEnumType } from 'type-graphql';
import {
  MirCertificate,
  StakeDelegationCertificate,
  StakeKeyDeregistrationCertificate,
  StakeKeyRegistrationCertificate
} from './Transaction/Certificate';
import { PublicKey } from './PublicKey';
import { Reward } from './Reward';
import { TransactionInput, TransactionOutput, Withdrawal } from './Transaction';

enum AddressType {
  byron = 'byron',
  shelley = 'shelley'
}

registerEnumType(AddressType, { name: 'AddressType' });

@ObjectType()
export class RewardAccount {
  @Directive('@search(by: [hash])')
  @Directive('@id')
  @Field(() => String)
  address: Cardano.RewardAccount;
  // eslint-disable-next-line sonarjs/no-duplicate-string
  @Directive('@hasInverse(field: rewardAccount)')
  @Field(() => [ActiveStake])
  activeStake: ActiveStake[];
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
  @Directive('@hasInverse(field: rewardAccount)')
  @Field(() => [Reward])
  rewards: Reward[];
  @Directive('@hasInverse(field: rewardAccount)')
  @Field(() => [Withdrawal])
  withdrawals: Withdrawal[];
}

@ObjectType()
export class Address {
  @Field(() => AddressType)
  addressType: AddressType;
  @Directive('@search(by: [hash])')
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
