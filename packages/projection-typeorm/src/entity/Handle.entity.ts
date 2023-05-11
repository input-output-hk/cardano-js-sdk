import { AssetEntity } from './Asset.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';

@Entity()
export class HandleEntity {
  @PrimaryColumn()
  handle?: string;
  @Column({ nullable: true })
  address?: Cardano.PaymentAddress;
  @ManyToOne(() => AssetEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  asset?: AssetEntity;
}
