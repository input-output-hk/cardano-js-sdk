import { Column, Entity, Index, ManyToMany, PrimaryGeneratedColumn } from 'typeorm';
import { TransactionEntity } from './Transaction.entity';

export enum CredentialType {
  PAYMENT = 'payment',
  SCRIPT = 'script',
  STAKE = 'stake'
}

@Entity()
export class CredentialEntity {
  @PrimaryGeneratedColumn()
  id?: number;

  @Index()
  @Column('bytea', { nullable: false })
  credentialHash?: Buffer;

  @Column({
    type: 'enum',
    enum: CredentialType
  })
  credentialType?: CredentialType;

  @ManyToMany(() => TransactionEntity, (transaction) => transaction.credentials, { onDelete: 'CASCADE' })
  transactions?: TransactionEntity[];
}
