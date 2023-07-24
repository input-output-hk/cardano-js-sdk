/* eslint-disable brace-style */
import { BigIntColumnOptions, DeleteCascadeRelationOptions, ImaginaryCoinsColumnOptions } from './util';
import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, OneToOne, PrimaryColumn } from 'typeorm';
import { Percent } from '@cardano-sdk/util';
import { PoolMetadataEntity } from './PoolMetadata.entity';
import { StakePoolEntity } from './StakePool.entity';

@Entity()
export class PoolRegistrationEntity {
  /**
   * Computed from certificate pointer.
   * Can be used to sort pool updates.
   */
  @PrimaryColumn(BigIntColumnOptions)
  id?: bigint;
  @Column()
  rewardAccount?: Cardano.RewardAccount;
  @Column(ImaginaryCoinsColumnOptions)
  pledge?: bigint;
  @Column(ImaginaryCoinsColumnOptions)
  cost?: bigint;
  // Review: should we store this as 'double' instead?
  // Maybe both formats? If we'll need to do computations with this
  // then it's best to keep the lossless format
  @Column({ type: 'jsonb' })
  margin?: Cardano.Fraction;
  @Column({ type: 'float4' })
  marginPercent?: Percent;
  @Column('jsonb')
  relays?: Cardano.Relay[];
  @Column('jsonb')
  owners?: Cardano.RewardAccount[];
  @Column({ length: 64, type: 'char' })
  vrf?: Cardano.VrfVkHex;
  @Column('varchar', { nullable: true })
  metadataUrl?: string | null;
  @Column({ length: 64, nullable: true, type: 'char' })
  metadataHash?: string | null;
  @JoinColumn()
  @ManyToOne(() => StakePoolEntity, (stakePool) => stakePool.registrations, DeleteCascadeRelationOptions)
  stakePool?: StakePoolEntity;
  @OneToOne(() => PoolMetadataEntity, (metadata) => metadata.poolUpdate)
  metadata?: PoolMetadataEntity | null;
  @ManyToOne(() => BlockEntity, DeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;
}
