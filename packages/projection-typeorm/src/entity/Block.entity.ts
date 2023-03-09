import { Cardano } from '@cardano-sdk/core';
import { Column, Entity, Index, PrimaryGeneratedColumn, RelationOptions } from 'typeorm';
import { json, serializableObj, stringBytea } from './transformers';

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

  @Column({ nullable: true, transformer: [serializableObj, json, stringBytea], type: 'bytea' })
  bufferData?: Cardano.Block;
}

/**
 * Use these RelationOptions if it's appropriate for an entity row
 * to be deleted when the block is rolled back.
 */
export const BlockCascadeRelationOptions: RelationOptions = {
  nullable: false,
  onDelete: 'CASCADE'
};
