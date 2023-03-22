import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, PrimaryColumn } from 'typeorm';

@Entity()
export class BlockEntity {
  @PrimaryColumn()
  height?: Cardano.BlockNo;

  @Index({ unique: true })
  @Column({ length: 64, type: 'char' })
  hash?: Cardano.BlockId;

  @Index({ unique: true })
  @Column()
  slot?: Cardano.Slot;
}
