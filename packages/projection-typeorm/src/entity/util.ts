import { ColumnOptions, RelationOptions } from 'typeorm';
import { parseBigInt } from './transformers';

/**
 * Use these RelationOptions if it's appropriate for an entity row
 * to be deleted when the block is rolled back.
 */
export const DeleteCascadeRelationOptions: RelationOptions = {
  nullable: false,
  onDelete: 'CASCADE'
};

// Pick is needed for this to be compatible with both ColumnOptions and PrimaryColumnOptions
export const BigIntColumnOptions: Pick<ColumnOptions, 'transformer' | 'type'> = {
  transformer: parseBigInt,
  type: 'bigint'
};
