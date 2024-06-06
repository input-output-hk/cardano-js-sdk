import { Column, Entity, Index, JoinColumn, ManyToOne, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions } from './util.js';
import { PoolRegistrationEntity } from './PoolRegistration.entity.js';
import { StakePoolEntity } from './StakePool.entity.js';
import type { Cardano } from '@cardano-sdk/core';

@Entity()
export class PoolMetadataEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @Column()
  @Index()
  ticker?: string;
  @Column()
  @Index()
  name?: string;
  @Column()
  description?: string;
  @Column()
  homepage?: string;
  @Column()
  hash?: string;
  @Column('jsonb', { nullable: true })
  ext?: Cardano.ExtendedStakePoolMetadata | null;
  @JoinColumn({ referencedColumnName: 'id' })
  @ManyToOne(() => StakePoolEntity)
  stakePool?: StakePoolEntity;
  @JoinColumn()
  @OneToOne(() => PoolRegistrationEntity, (poolUpdate) => poolUpdate.metadata, OnDeleteCascadeRelationOptions)
  poolUpdate?: PoolRegistrationEntity;
}
