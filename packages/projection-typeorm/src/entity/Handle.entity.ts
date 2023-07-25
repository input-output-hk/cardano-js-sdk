import { AssetEntity } from './Asset.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryColumn } from 'typeorm';

@Entity()
export class HandleEntity {
  @PrimaryColumn()
  handle?: string;
  @Column({ nullable: true, type: 'varchar' })
  cardanoAddress?: Cardano.PaymentAddress | null;
  @OneToOne(() => AssetEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  asset?: AssetEntity;
  @Column()
  policyId?: Cardano.PolicyId;
  @Column()
  hasDatum?: boolean;
}
