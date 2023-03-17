import { RelationOptions } from 'typeorm';

/**
 * Use these RelationOptions if it's appropriate for an entity row
 * to be deleted when the block is rolled back.
 */
export const DeleteCascadeRelationOptions: RelationOptions = {
  nullable: false,
  onDelete: 'CASCADE'
};
