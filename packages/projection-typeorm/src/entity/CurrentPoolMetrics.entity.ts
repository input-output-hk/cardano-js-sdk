import { BigIntColumnOptions, OnDeleteCascadeRelationOptions } from './util';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryColumn } from 'typeorm';
import { Percent } from '@cardano-sdk/util';
import { StakePoolEntity } from './StakePool.entity';
import { float } from './transformers';

@Entity()
export class CurrentPoolMetricsEntity {
  // Using the same column for both primary and foreign key
  @PrimaryColumn({ length: 56, type: 'char' })
  stakePoolId?: Cardano.PoolId;

  @Column('integer', { nullable: true })
  slot: Cardano.Slot;

  @OneToOne(() => StakePoolEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  stakePool?: StakePoolEntity;

  @Column({ nullable: true, type: 'integer' })
  mintedBlocks?: number;

  @Column({ nullable: true, type: 'integer' })
  liveDelegators?: number;

  @Column({ nullable: true, ...BigIntColumnOptions })
  activeStake?: Cardano.Lovelace;

  @Column({ nullable: true, ...BigIntColumnOptions })
  liveStake?: Cardano.Lovelace;

  @Column({ nullable: true, ...BigIntColumnOptions })
  livePledge?: Cardano.Lovelace;

  @Column({ nullable: true, transformer: float, type: 'numeric' })
  liveSaturation?: Percent;

  @Column({ nullable: true, transformer: float, type: 'numeric' })
  activeSize?: Percent;

  @Column({ nullable: true, transformer: float, type: 'numeric' })
  liveSize?: Percent;

  @Column({ nullable: true, transformer: float, type: 'numeric' })
  lastRos?: Percent;

  @Column({ nullable: true, transformer: float, type: 'numeric' })
  ros?: Percent;
}
