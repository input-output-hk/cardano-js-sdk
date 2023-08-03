import { AssetEntity } from './Asset.entity';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions, UInt64ColumnOptions } from './util';
import { OutputEntity } from './Output.entity';

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
