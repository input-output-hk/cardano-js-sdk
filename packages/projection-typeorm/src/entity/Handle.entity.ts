import { AssetEntity } from './Asset.entity';
import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryColumn } from 'typeorm';

@Entity()
export class HandleEntity {
  @PrimaryColumn()
  handle?: string;
  @Column({ nullable: true })
  cardanoAddress?: Cardano.PaymentAddress;
  @OneToOne(() => AssetEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  asset?: AssetEntity;
  @Column()
  policyId?: Cardano.PolicyId;
  @Column()
  hasDatum?: boolean;
  @OneToOne(() => BlockEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  resolvedAt?: BlockEntity;
}
