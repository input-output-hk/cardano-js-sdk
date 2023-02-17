import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity()
export class StabilityWindowBlockEntity {
  @PrimaryColumn('number')
  slot: Cardano.Slot;

  @Column('string')
  blockHash: Cardano.BlockId;

  @Column('blob')
  blockHexBlob: string;
}
