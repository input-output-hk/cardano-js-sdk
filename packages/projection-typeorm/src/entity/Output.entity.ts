import { BigIntColumnOptions, OnDeleteCascadeRelationOptions } from './util';
import { BlockEntity } from './Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { HexBlob } from '@cardano-sdk/util';
import { TokensEntity } from './Tokens.entity';

@Entity()
export class OutputEntity {
  @PrimaryGeneratedColumn()
  id?: number;
  // @Index()
  @Column('varchar')
  address?: Cardano.PaymentAddress;
  @Index()
  @Column('varchar')
  txId?: Cardano.TransactionId;
  @Index()
  @Column('smallint')
  outputIndex?: number;
  @Column(BigIntColumnOptions)
  coins?: bigint;
  @Column({ nullable: true, type: 'integer' })
  consumedAtSlot?: Cardano.Slot | null;
  @OneToMany(() => TokensEntity, (tokens) => tokens.output)
  tokens?: TokensEntity[];
  @Column({ length: 64, nullable: true, type: 'char' })
  datumHash?: Cardano.DatumHash | null;
  @Column({ nullable: true, type: 'varchar' })
  datum?: HexBlob | null;
  @Column({ nullable: true, type: 'jsonb' })
  scriptReference?: Cardano.Script | null;
  @ManyToOne(() => BlockEntity, OnDeleteCascadeRelationOptions)
  @JoinColumn()
  block?: BlockEntity;
}
