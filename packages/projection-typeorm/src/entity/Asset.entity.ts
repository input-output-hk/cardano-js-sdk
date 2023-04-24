import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { DeleteCascadeRelationOptions } from './util';
import { parseBigInt } from './transformers';

@Entity()
export class AssetEntity {
  @PrimaryColumn()
  id?: Cardano.AssetId;
  @Column({
    transformer: parseBigInt,
    type: 'decimal'
  })
  supply?: bigint;
  @ManyToOne(() => BlockEntity, DeleteCascadeRelationOptions)
  @JoinColumn()
  firstMintBlock?: BlockEntity;
}
