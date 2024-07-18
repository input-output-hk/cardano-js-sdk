import { BlockEntity } from './Block.entity';
import { Cardano, TxCBOR } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, JoinTable, ManyToMany, ManyToOne, PrimaryColumn } from 'typeorm';
import { CredentialEntity } from './Credential.entity';
import { OnDeleteCascadeRelationOptions } from './util';

@Entity()
export class TransactionEntity {
  @Index()
  @PrimaryColumn('varchar')
  txId?: Cardano.TransactionId;

  @Column('varchar', { nullable: false })
  cbor?: TxCBOR;

  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn({ name: 'block_id' })
  block?: BlockEntity;

  @ManyToMany(() => CredentialEntity, (credential) => credential.transactions, { onDelete: 'CASCADE' })
  @JoinTable({
    inverseJoinColumn: { name: 'credential_id', referencedColumnName: 'credentialHash' },
    joinColumn: { name: 'transaction_id', referencedColumnName: 'txId' },
    name: 'transaction_credentials'
  })
  credentials?: CredentialEntity[];
}
