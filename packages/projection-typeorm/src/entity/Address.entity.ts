import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity()
export class AddressEntity {
  @PrimaryColumn()
  id?: string;
  @Column()
  cardano?: Cardano.PaymentAddress;
}
