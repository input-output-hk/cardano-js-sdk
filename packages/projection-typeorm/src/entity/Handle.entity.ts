import { AssetEntity } from './Asset.entity.js';
import { Column, Entity, JoinColumn, ManyToOne, OneToOne, PrimaryColumn } from 'typeorm';
import type { Cardano, Handle } from '@cardano-sdk/core';

@Entity()
export class HandleEntity {
  @PrimaryColumn()
  handle?: Handle;
  @Column({ nullable: true, type: 'varchar' })
  cardanoAddress?: Cardano.PaymentAddress | null;
  @OneToOne(() => AssetEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  asset?: AssetEntity;
  @Column()
  policyId?: Cardano.PolicyId;
  @Column()
  hasDatum?: boolean;
  @Column('varchar', { nullable: true })
  /** `null` when cardanoAddress === `null`, or owned by enterprise/byron address */
  defaultForStakeCredential?: Handle | null;
  @Column('varchar', { nullable: true })
  /** `null` when cardanoAddress === `null` */
  defaultForPaymentCredential?: Handle | null;
  @ManyToOne(() => HandleEntity, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn()
  parentHandle?: HandleEntity;
}
