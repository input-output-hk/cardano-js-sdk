import { BlockEntity } from './Block.entity.js';
import { Column, Entity, Index, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions } from './util.js';
import { OutputEntity } from './Output.entity.js';
import type { Asset, Handle } from '@cardano-sdk/core';

@Entity()
export class HandleMetadataEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @Index()
  @Column('varchar')
  handle?: Handle;
  @Column('boolean', { nullable: true })
  og?: boolean | null;
  @Column('varchar', { nullable: true })
  profilePicImage?: Asset.Uri | null;
  @Column('varchar', { nullable: true })
  backgroundImage?: Asset.Uri | null;
  @ManyToOne(() => OutputEntity, { nullable: true })
  @JoinColumn()
  /** Only present for metadata associated with cip68 datum */
  output?: OutputEntity | null;
  @Column('integer', { nullable: true })
  outputId?: number | null;
  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;
}
