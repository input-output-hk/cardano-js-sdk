import { Cardano } from '@cardano-sdk/core';
import { Column, PrimaryColumn } from 'typeorm';

export class PointEntity {
  @PrimaryColumn()
  hash?: Cardano.BlockId;
  @Column()
  slot?: Cardano.Slot;
}
