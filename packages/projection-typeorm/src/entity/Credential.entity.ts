import { Column, Entity, Index, ManyToMany, PrimaryGeneratedColumn } from 'typeorm';
import { TransactionEntity } from './Transaction.entity';

@Entity()
export class CredentialEntity {
  @PrimaryGeneratedColumn()
  id?: number;

  @Index()
  @Column('bytea', { nullable: false })
  spendingHash?: Buffer;
  
  @Index()
  @Column('bytea', { nullable: true })
  stakeHash?: Buffer;

  @ManyToMany(() => TransactionEntity, transaction => transaction.credentials, { onDelete: 'CASCADE' })
  transactions?: TransactionEntity[];
}
