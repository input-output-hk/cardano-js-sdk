import { Column, Entity, Index, ManyToMany, PrimaryColumn } from 'typeorm';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { TransactionEntity } from './Transaction.entity';

export enum CredentialType {
  PaymentKey = 'payment_key',
  PaymentScript = 'payment_script',
  StakeKey = 'stake_key',
  StakeScript = 'stake_script'
}

@Entity()
export class CredentialEntity {
  @Index()
  @PrimaryColumn('varchar')
  credentialHash?: Hash28ByteBase16;

  @Column('enum', { enum: CredentialType, nullable: true })
  credentialType?: CredentialType;

  @ManyToMany(() => TransactionEntity, (transaction) => transaction.credentials, { onDelete: 'CASCADE' })
  transactions?: TransactionEntity[];
}

export const credentialEntityComparator = (c1: CredentialEntity, c2: CredentialEntity) =>
  c1.credentialHash === c2.credentialHash && c1.credentialType === c2.credentialType;
