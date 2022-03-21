/* eslint-disable no-use-before-define */
/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { PublicKey } from '../../PublicKey';
import { Redeemer } from './Redeemer';
import { Signature } from '../Signature';
import { Transaction } from '../Transaction';
import { WitnessScript } from './WitnessScript';

@ObjectType()
export class BootstrapWitness {
  @Field(() => String, { description: 'hex-encoded Ed25519 signature' })
  signature: Cardano.Ed25519Signature;
  @Field(() => String, { description: 'An Ed25519-BIP32 chain-code for key deriviation', nullable: true })
  chainCode?: string;
  @Field(() => String, {
    description: 'Extra attributes carried by Byron addresses (network magic and/or HD payload)',
    nullable: true
  })
  addressAttributes?: string;
  @Field(() => PublicKey, { nullable: true })
  key?: PublicKey;
}

// TODO: narrow down hash and datum types
@ObjectType()
export class Datum {
  @Directive('@id')
  @Field(() => String)
  hash: string;
  @Field(() => String)
  datum: string;
}

@ObjectType()
export class Witness {
  @Directive('@hasInverse(field: witness)')
  @Field(() => [Signature])
  signatures: Signature[];
  @Directive('@hasInverse(field: witness)')
  @Field(() => [WitnessScript], { nullable: true })
  scripts?: WitnessScript[];
  @Field(() => [BootstrapWitness], { nullable: true })
  bootstrap?: BootstrapWitness[];
  @Field(() => [Datum], { nullable: true })
  datums?: Datum[];
  @Directive('@hasInverse(field: witness)')
  @Field(() => [Redeemer], { nullable: true })
  redeemers?: Redeemer[];
  @Field(() => Transaction)
  transaction: Transaction;
}
