import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, OneToMany, OneToOne, PrimaryColumn, RelationOptions } from 'typeorm';
import { PoolRegistrationEntity } from './PoolRegistration.entity';
import { PoolRetirementEntity } from './PoolRetirement.entity';

const OnDeleteSetNull: RelationOptions = {
  nullable: true,
  onDelete: 'SET NULL'
};

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
  @OneToOne(() => PoolRegistrationEntity, OnDeleteSetNull)
  lastRegistration?: PoolRegistrationEntity | null;
  @JoinColumn()
  @OneToOne(() => PoolRetirementEntity, OnDeleteSetNull)
  lastRetirement?: PoolRetirementEntity | null;
}
