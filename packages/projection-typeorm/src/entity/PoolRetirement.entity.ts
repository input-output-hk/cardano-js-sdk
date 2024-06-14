import { BigIntColumnOptions, OnDeleteCascadeRelationOptions } from './util';
import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { StakePoolEntity } from './StakePool.entity';

@Entity()
export class PoolRetirementEntity {
  /** Computed from certificate pointer. Can be used to sort pool retirements. */
  @PrimaryColumn(BigIntColumnOptions)
  id?: bigint;

  @Column('integer')
  retireAtEpoch?: Cardano.EpochNo;

  @ManyToOne(() => StakePoolEntity, (stakePool) => stakePool.retirements, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  stakePool?: StakePoolEntity;

  @Column('integer')
  blockSlot?: Cardano.Slot;

  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;
}
