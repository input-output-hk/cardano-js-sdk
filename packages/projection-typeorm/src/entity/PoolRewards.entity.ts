import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, Unique } from 'typeorm';
import { StakePoolEntity } from './StakePool.entity';
import { UInt64ColumnOptions } from './util';

@Entity()
@Unique(['epochNo', 'stakePoolId'])
export class PoolRewardsEntity {
  @PrimaryGeneratedColumn()
  id?: number;

  @Column({ length: 56, type: 'char' })
  stakePoolId?: Cardano.PoolId;

  @ManyToOne(() => StakePoolEntity)
  @JoinColumn()
  stakePool?: StakePoolEntity;

  @Column({ type: 'integer' })
  epochLength?: number;

  @Column('integer')
  epochNo?: Cardano.EpochNo;

  @Column({ type: 'integer' })
  delegators?: number;

  @Column(UInt64ColumnOptions)
  pledge?: Cardano.Lovelace;

  @Column(UInt64ColumnOptions)
  activeStake?: Cardano.Lovelace;

  @Column(UInt64ColumnOptions)
  memberActiveStake?: Cardano.Lovelace;

  @Column(UInt64ColumnOptions)
  leaderRewards?: Cardano.Lovelace;

  @Column(UInt64ColumnOptions)
  memberRewards?: Cardano.Lovelace;

  @Column(UInt64ColumnOptions)
  rewards?: Cardano.Lovelace;

  @Column({ type: 'integer' })
  version?: number;
}
