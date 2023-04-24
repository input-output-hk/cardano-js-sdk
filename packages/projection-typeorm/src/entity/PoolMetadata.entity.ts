import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, ManyToOne, OneToOne, PrimaryGeneratedColumn } from 'typeorm';
import { DeleteCascadeRelationOptions } from './util';
import { PoolRegistrationEntity } from './PoolRegistration.entity';
import { StakePoolEntity } from './StakePool.entity';

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
  ext?: Cardano.ExtendedStakePoolMetadata | null | undefined;
  @JoinColumn({ referencedColumnName: 'id' })
  @ManyToOne(() => StakePoolEntity)
  stakePool?: StakePoolEntity;
  @JoinColumn()
  @OneToOne(() => PoolRegistrationEntity, DeleteCascadeRelationOptions)
  poolUpdate?: PoolRegistrationEntity;
}
