import { parseBigInt } from './transformers.js';
import type { ColumnOptions, RelationOptions } from 'typeorm';

/** Use these RelationOptions if it's appropriate for an entity row to be deleted when the block is rolled back. */
export const OnDeleteCascadeRelationOptions: RelationOptions = {
  nullable: false,
  onDelete: 'CASCADE'
};

export const OnDeleteSetNullRelationOptions: RelationOptions = {
  nullable: true,
  onDelete: 'SET NULL'
};

// Pick is needed for this to be compatible with both ColumnOptions and PrimaryColumnOptions
export const BigIntColumnOptions: Pick<ColumnOptions, 'transformer' | 'type'> = {
  transformer: parseBigInt,
  type: 'bigint'
};

/**
 * To be used for
 * - user-specified coin quantities that are not validated by the node
 *   to not exceed max lovelace supply
 * - native asset quantities
 */
export const UInt64ColumnOptions: Pick<ColumnOptions, 'transformer' | 'type' | 'precision' | 'scale'> = {
  precision: 20,
  scale: 0,
  transformer: parseBigInt,
  type: 'numeric'
};
