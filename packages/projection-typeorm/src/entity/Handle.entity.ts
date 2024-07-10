import { AssetEntity } from './Asset.entity';
import { Cardano, Handle } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, OneToOne, PrimaryColumn } from 'typeorm';

@Entity()
export class HandleEntity {
  @PrimaryColumn('varchar')
  handle?: Handle;
  @Column({ nullable: true, type: 'varchar' })
  cardanoAddress?: Cardano.PaymentAddress | null;
  @OneToOne(() => AssetEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  asset?: AssetEntity;
  @Column('varchar')
  policyId?: Cardano.PolicyId;
  @Column('boolean')
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
