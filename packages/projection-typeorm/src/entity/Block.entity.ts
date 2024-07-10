import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, PrimaryColumn } from 'typeorm';

@Entity()
export class BlockEntity {
  @Index({ unique: true })
  @Column('integer')
  height?: Cardano.BlockNo;

  @Index({ unique: true })
  @Column({ length: 64, type: 'char' })
  hash?: Cardano.BlockId;

  @PrimaryColumn('integer')
  slot?: Cardano.Slot;
}
