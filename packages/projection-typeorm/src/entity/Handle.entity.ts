import { AssetEntity } from './Asset.entity';
import { Cardano, Handle } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryColumn } from 'typeorm';

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
  /**
   * `null` when cardanoAddress === `null`, or owned by enterprise/byron address
   */
  defaultForStakeCredential?: Handle | null;
  @Column('varchar', { nullable: true })
  /**
   * `null` when cardanoAddress === `null`
   */
  defaultForPaymentCredential?: Handle | null;
}
