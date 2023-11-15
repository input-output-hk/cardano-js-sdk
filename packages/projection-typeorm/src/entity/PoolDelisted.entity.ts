import { Cardano } from '@cardano-sdk/core';
import { Entity, PrimaryColumn } from 'typeorm';

@Entity()
export class PoolDelistedEntity {
  // Using the same column for both primary and foreign key
  @PrimaryColumn({ length: 56, type: 'char' })
  stakePoolId?: Cardano.PoolId;
}
