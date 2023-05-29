import { BigIntColumnOptions, DeleteCascadeRelationOptions } from './util';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryColumn } from 'typeorm';
import { StakePoolEntity } from './StakePool.entity';
import { float } from './transformers';

@Entity()
export class CurrentPoolMetricsEntity {
  // Using the same column for both primary and foreign key
  @PrimaryColumn({ length: 56, type: 'char' })
  stakePoolId?: Cardano.PoolId;

  @Column()
  slot: Cardano.Slot;

  @OneToOne(() => StakePoolEntity, DeleteCascadeRelationOptions)
  @JoinColumn()
  stakePool?: StakePoolEntity;

  @Column({ type: 'integer' })
  mintedBlocks?: number;

  @Column({ type: 'integer' })
  liveDelegators?: number;

  @Column(BigIntColumnOptions)
  activeStake?: Cardano.Lovelace;

  @Column(BigIntColumnOptions)
  liveStake?: Cardano.Lovelace;

  @Column(BigIntColumnOptions)
  livePledge?: Cardano.Lovelace;

  @Column({ transformer: float, type: 'numeric' })
  liveSaturation?: Cardano.Percent;

  @Column({ transformer: float, type: 'numeric' })
  activeSize?: Cardano.Percent;

  @Column({ transformer: float, type: 'numeric' })
  liveSize?: Cardano.Percent;

  @Column({ transformer: float, type: 'numeric' })
  apy?: Cardano.Percent;
}
