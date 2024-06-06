import { AssetEntity } from './Asset.entity.js';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions, UInt64ColumnOptions } from './util.js';
import { OutputEntity } from './Output.entity.js';

@Entity()
export class TokensEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @JoinColumn()
  @ManyToOne(() => AssetEntity, OnDeleteCascadeRelationOptions)
  asset?: AssetEntity;
  @JoinColumn()
  @ManyToOne(() => OutputEntity, (output) => output.tokens, OnDeleteCascadeRelationOptions)
  output?: OutputEntity;
  @Column(UInt64ColumnOptions)
  quantity?: bigint;
}
