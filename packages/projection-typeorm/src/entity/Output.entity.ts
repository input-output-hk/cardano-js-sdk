import { BigIntColumnOptions, DeleteCascadeRelationOptions } from './util';
import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { TokensEntity } from './Tokens.entity';

@Entity()
export class OutputEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  @Index()
  @Column()
  address?: Cardano.PaymentAddress;
  @Index()
  @Column()
  txId?: Cardano.TransactionId;
  @Index()
  @Column('smallint')
  outputIndex?: number;
  @Column(BigIntColumnOptions)
  coins?: bigint;
  @Column({ nullable: true })
  consumedAtSlot?: Cardano.Slot;
  @OneToMany(() => TokensEntity, (tokens) => tokens.output)
  tokens?: TokensEntity[];
  @Column({ length: 64, nullable: true, type: 'char' })
  datumHash?: Cardano.DatumHash;
  @Column({ nullable: true })
  datum?: Cardano.Datum;
  @Column({ nullable: true, type: 'jsonb' })
  scriptReference?: Cardano.Script;
  @ManyToOne(() => BlockEntity, DeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;
}
