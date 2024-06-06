import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, OneToMany, OneToOne, PrimaryColumn } from 'typeorm';
import { CurrentPoolMetricsEntity } from './CurrentPoolMetrics.entity.js';
import { OnDeleteSetNullRelationOptions } from './util.js';
import { PoolRegistrationEntity } from './PoolRegistration.entity.js';
import { PoolRetirementEntity } from './PoolRetirement.entity.js';

@Entity()
export class StakePoolEntity {
  @PrimaryColumn({ length: 56, type: 'char' })
  id?: Cardano.PoolId;
  @Index()
  @Column({
    enum: Cardano.StakePoolStatus,
    type: 'enum'
  })
  status?: Cardano.StakePoolStatus;
  @OneToMany(() => PoolRegistrationEntity, (registration) => registration.stakePool)
  registrations?: PoolRegistrationEntity[];
  @OneToMany(() => PoolRetirementEntity, (retirement) => retirement.stakePool)
  retirements?: PoolRetirementEntity[];
  @JoinColumn()
  @OneToOne(() => PoolRegistrationEntity, OnDeleteSetNullRelationOptions)
  lastRegistration?: PoolRegistrationEntity | null;
  @JoinColumn()
  @OneToOne(() => PoolRetirementEntity, OnDeleteSetNullRelationOptions)
  lastRetirement?: PoolRetirementEntity | null;
  @OneToOne(() => CurrentPoolMetricsEntity, (metric) => metric.stakePool, OnDeleteSetNullRelationOptions)
  metrics?: CurrentPoolMetricsEntity | null;
}
