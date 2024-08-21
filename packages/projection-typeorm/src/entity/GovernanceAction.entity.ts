import { BigIntColumnOptions, OnDeleteCascadeRelationOptions } from './util';
import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { Hash28ByteBase16, Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { json, serializableObj } from './transformers';

@Entity()
export class GovernanceActionEntity {
  @PrimaryGeneratedColumn()
  id?: number;

  // LW-11270
  // This is required to handle rollbacks, once we have transactions projection
  // the OnDeleteCascadeRelationOptions can be moved on txId and this column could be removed
  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;

  @Column('varchar')
  txId?: Cardano.TransactionId;

  @Column('smallint')
  index?: number;

  @Column('varchar')
  stakeCredentialHash?: Hash28ByteBase16;

  @Column('varchar')
  anchorUrl?: string;

  @Column('char', { length: 64, nullable: true })
  anchorHash?: Hash32ByteBase16;

  @Column(BigIntColumnOptions)
  deposit?: bigint;

  @Column({ transformer: [serializableObj, json], type: 'varchar' })
  action?: Cardano.GovernanceAction;
}
