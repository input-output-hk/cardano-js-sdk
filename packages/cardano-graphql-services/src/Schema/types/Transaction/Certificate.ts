import { Cardano } from '@cardano-sdk/core';
import { Epoch } from '../Epoch';
import { Field, ObjectType } from 'type-graphql';
import { Int64 } from '../util';
import { PoolParameters } from '../StakePool';
import { RewardAccount } from '../Address';
import { StakePool } from '../StakePool/StakePool';
import { Transaction } from './Transaction';

@ObjectType()
export class StakeKeyRegistrationCertificate {
  __typename: Cardano.CertificateType.StakeKeyRegistration;
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => Transaction)
  transaction: Transaction;
}

@ObjectType()
export class StakeKeyDeregistrationCertificate {
  __typename: Cardano.CertificateType.StakeKeyDeregistration;
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => Transaction)
  transaction: Transaction;
}

@ObjectType()
export class PoolRegistrationCertificate {
  __typename: Cardano.CertificateType.PoolRegistration;
  @Field(() => PoolParameters)
  poolParameters: PoolParameters;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => Transaction)
  transaction: Transaction;
}

@ObjectType()
export class PoolRetirementCertificate {
  __typename: Cardano.CertificateType.PoolRetirement;
  @Field(() => StakePool)
  stakePool: StakePool;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => Transaction)
  transaction: Transaction;
}

@ObjectType()
export class StakeDelegationCertificate {
  __typename: Cardano.CertificateType.StakeDelegation;
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => StakePool)
  stakePool: StakePool;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => Transaction)
  transaction: Transaction;
}

@ObjectType()
export class MirCertificate {
  __typename: Cardano.CertificateType.MIR;
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => Int64)
  quantity: Cardano.Lovelace;
  @Field(() => String)
  pot: 'reserve' | 'treasury';
  @Field(() => Transaction)
  transaction: Transaction;
}

@ObjectType()
export class GenesisKeyDelegationCertificate {
  __typename: Cardano.CertificateType.GenesisKeyDelegation;
  @Field(() => String)
  genesisHash: Cardano.Hash32ByteBase16;
  @Field(() => String)
  genesisDelegateHash: Cardano.Hash32ByteBase16;
  @Field(() => String)
  vrfKeyHash: Cardano.Hash32ByteBase16;
  @Field(() => Transaction)
  transaction: Transaction;
}
