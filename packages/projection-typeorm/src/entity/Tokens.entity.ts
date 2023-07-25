import { AssetEntity } from './Asset.entity';
import { BigIntColumnOptions, OnDeleteCascadeRelationOptions } from './util';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
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
  @Column(BigIntColumnOptions)
  quantity?: bigint;
}
