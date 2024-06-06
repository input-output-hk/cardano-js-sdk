import { BigIntColumnOptions, OnDeleteCascadeRelationOptions } from './util.js';
import { BlockEntity } from './Block.entity.js';
import { Column, Entity, Index, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';

@Entity()
export class StakeKeyRegistrationEntity {
  /** Computed from certificate pointer. Can be used to query by pointer using `Cardano.PointerToId` util. */
  @PrimaryColumn(BigIntColumnOptions)
  id?: bigint;
  @Column('char', { length: 56 })
  @Index()
  stakeKeyHash?: Ed25519KeyHashHex;
  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;
}
