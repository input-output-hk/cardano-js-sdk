import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, JoinTable, ManyToMany, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { BlockEntity } from './Block.entity';
import { CredentialEntity } from './Credential.entity';
import { OnDeleteCascadeRelationOptions } from './util';

@Entity()
export class TransactionEntity {
  @PrimaryGeneratedColumn()
  id?: number;

  @Column('varchar')
  txId?: Cardano.TransactionId;

  @Index()
  @Column('bytea')
  cbor?: Buffer;

  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn({ name: 'block_id' })
  block?: BlockEntity;

  @ManyToMany(() => CredentialEntity, credential => credential.transactions, { onDelete: 'CASCADE' })
  @JoinTable({
    name: "transaction_credentials",
    joinColumn: { name: "transaction_id", referencedColumnName: "id" },
    inverseJoinColumn: { name: "credential_id", referencedColumnName: "id" },
  })
  credentials?: CredentialEntity[];
}
