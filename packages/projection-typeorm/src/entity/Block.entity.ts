import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, PrimaryGeneratedColumn, RelationOptions } from 'typeorm';

@Entity()
export class BlockEntity {
  @PrimaryGeneratedColumn()
  id?: number;

  @Index({ unique: true })
  @Column({ length: 64, type: 'char' })
  hash?: Cardano.BlockId;

  @Index({ unique: true })
  @Column({ type: 'int' })
  slot?: number;

  @Index({ unique: true })
  @Column({ type: 'int' })
  height?: number;
}

/**
 * Use these RelationOptions if it's appropriate for an entity row
 * to be deleted when the block is rolled back.
 */
export const BlockCascadeRelationOptions: RelationOptions = {
  nullable: false,
  onDelete: 'CASCADE'
};
