import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, ManyToOne, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
import { OnDeleteCascadeRelationOptions } from './util';
import { PoolRegistrationEntity } from './PoolRegistration.entity';
import { StakePoolEntity } from './StakePool.entity';

@Entity()
export class PoolMetadataEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @Column('varchar')
  @Index()
  ticker?: string;
  @Column('varchar')
  @Index()
  name?: string;
  @Column('varchar')
  description?: string;
  @Column('varchar')
  homepage?: string;
  @Column('varchar')
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
