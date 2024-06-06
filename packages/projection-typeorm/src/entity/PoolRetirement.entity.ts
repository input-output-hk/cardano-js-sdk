import { BigIntColumnOptions, OnDeleteCascadeRelationOptions } from './util.js';
import { BlockEntity } from './Block.entity.js';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { StakePoolEntity } from './StakePool.entity.js';

@Entity()
export class PoolRetirementEntity {
  /** Computed from certificate pointer. Can be used to sort pool retirements. */
  @PrimaryColumn(BigIntColumnOptions)
  id?: bigint;

  @Column()
  retireAtEpoch?: Cardano.EpochNo;

  @ManyToOne(() => StakePoolEntity, (stakePool) => stakePool.retirements, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  stakePool?: StakePoolEntity;

  @Column()
  blockSlot?: Cardano.Slot;

  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;
}
