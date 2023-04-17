import { AssetEntity } from './Asset.entity';
import { BigIntColumnOptions, DeleteCascadeRelationOptions } from './util';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OutputEntity } from './Output.entity';

@Entity()
export class TokensEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @JoinColumn()
  @ManyToOne(() => AssetEntity, DeleteCascadeRelationOptions)
  asset?: AssetEntity;
  @JoinColumn()
  @ManyToOne(() => OutputEntity, (output) => output.tokens, DeleteCascadeRelationOptions)
  output?: OutputEntity;
  @Column(BigIntColumnOptions)
  quantity?: bigint;
}
