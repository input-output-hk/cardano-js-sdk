import { BlockEntity } from './Block.entity.js';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions } from './util.js';
import { json, serializableObj, stringBytea } from './transformers.js';

@Entity()
export class BlockDataEntity {
  // Using the same column for both primary and foreign key
  @PrimaryColumn()
  blockHeight?: number;

  @OneToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn({ referencedColumnName: 'height' })
  block?: BlockEntity;

  @Column({ transformer: [serializableObj, json, stringBytea], type: 'bytea' })
  data?: Cardano.Block;
}
