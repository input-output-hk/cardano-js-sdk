import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { StakeKeyRegistrationEntity } from './StakeKeyRegistration.entity';

@Entity()
export class AddressEntity {
  @PrimaryColumn('varchar')
  address?: Cardano.PaymentAddress;
  @Column({ enum: Cardano.AddressType, type: 'enum' })
  type?: Cardano.AddressType;
  @Column('char', { length: 56, nullable: true })
  @Index()
  /** Applicable only for base/grouped, enterprise and pointer addresses */
  paymentCredentialHash?: Hash28ByteBase16 | null;
  @Column('char', { length: 56, nullable: true })
  @Index()
  /** Applicable only for base/grouped and pointer addresses */
  stakeCredentialHash?: Hash28ByteBase16 | null;
  @ManyToOne(() => StakeKeyRegistrationEntity, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn()
  /** Applicable only for pointer addresses */
  registration?: StakeKeyRegistrationEntity | null;
}
