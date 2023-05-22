import { AddressEntity } from './Address.entity';
import { AssetEntity } from './Asset.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, JoinColumn, OneToOne, PrimaryColumn } from 'typeorm';
import { PointEntity } from './PointEntity';

@Entity()
export class HandleEntity {
  @PrimaryColumn()
  handle?: string;
  @Column({ nullable: true })
  address?: Cardano.PaymentAddress;
  @OneToOne(() => AssetEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  asset?: AssetEntity;
  @Column()
  issuer?: string;
  @Column()
  hasDatum?: boolean;
  @OneToOne(() => AddressEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  resolvedAddresses?: AddressEntity;
  @OneToOne(() => PointEntity, { onDelete: 'CASCADE' })
  @JoinColumn()
  resolvedAt?: PointEntity;
  @Column({ nullable: true })
  code?: number;
}
