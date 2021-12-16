/* eslint-disable no-use-before-define */
/* eslint-disable sonarjs/no-duplicate-string */
import { AuxiliaryData } from './AuxiliaryData';
import { Block } from '../Block';
import { Cardano } from '@cardano-sdk/core';
import { Certificate } from './CertificateUnion';
import { Directive, Field, Int, ObjectType } from 'type-graphql';
import { Int64 } from '../util';
import { PublicKey } from '../PublicKey';
import { Redeemer } from './Redeemer';
import { Signature } from './Signature';
import { Slot } from '../Slot';
import { Token } from './Token';
import { TransactionInput } from './TransactionInput';
import { TransactionOutput } from './TransactionOutput';
import { Withdrawal } from './Withdrawal';

@ObjectType()
export class Transaction {
  @Directive('@id')
  @Field(() => String)
  hash: Cardano.TransactionId;
  @Field(() => Block)
  block: Block;
  @Field(() => Int)
  index: number;
  @Field(() => [TransactionInput], { nullable: true })
  collateral?: TransactionInput[];
  @Field(() => Int64)
  deposit: Cardano.Lovelace;
  @Field(() => Int64)
  fee: Cardano.Lovelace;
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [TransactionInput])
  inputs: TransactionInput[];
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [TransactionOutput])
  outputs: TransactionOutput[];
  @Field(() => Int, { nullable: true })
  invalidBefore?: Slot;
  @Field(() => Int, { nullable: true })
  invalidHereafter?: Slot;
  @Directive('@hasInverse(field: transaction)')
  @Field(() => AuxiliaryData, { nullable: true })
  auxiliaryData?: AuxiliaryData;
  // TODO: simplify core type to use negative qty for burn
  @Field(() => [Token], { nullable: true })
  mint?: Token[];
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [Redeemer], { nullable: true })
  redeemers?: Redeemer[];
  @Field(() => Int64)
  size: number;
  @Field(() => Int64)
  totalOutputCoin: Cardano.Lovelace;
  @Field()
  validContract: boolean;
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [Withdrawal], { nullable: true })
  withdrawals?: Withdrawal[];
  @Directive('@hasInverse(field: transaction)')
  @Field(() => [Signature])
  signatures: Signature[];
  @Field(() => [Certificate], { nullable: true })
  certificates?: typeof Certificate[];
  @Field(() => String, { nullable: true })
  scriptIntegrityHash?: Cardano.Hash28ByteBase16;
  @Directive('@hasInverse(field: requiredExtraSignatureInTransactions)')
  @Field(() => [PublicKey])
  requiredExtraSignatures?: PublicKey[];
}
