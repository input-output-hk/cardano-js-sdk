import { BlockCascadeRelationOptions, BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
import { json, serializableObj, stringBytea } from './transformers';

@Entity()
export class BlockDataEntity {
  @PrimaryGeneratedColumn()
  id?: number;

  @OneToOne(() => BlockEntity, BlockCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;

  @Column({ transformer: [serializableObj, json, stringBytea], type: 'bytea' })
  data?: Cardano.Block;
}
