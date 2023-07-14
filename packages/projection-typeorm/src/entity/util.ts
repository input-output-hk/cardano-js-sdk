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

/**
 * To be used for user-specified coin quantities that are not validated by the node
 * to not exceed max lovelace supply (up to unsigned 64 bit integer):
 * - pool registration cost
 * - pool registration pledge
 */
export const ImaginaryCoinsColumnOptions: Pick<ColumnOptions, 'transformer' | 'type' | 'precision' | 'scale'> = {
  precision: 20,
  scale: 0,
  transformer: parseBigInt,
  type: 'numeric'
};
