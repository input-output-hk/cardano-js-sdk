import type { Schema } from '@cardano-ogmios/client';

type KeysOfUnion<T> = T extends T ? keyof T : never;
/**
 * Ogmios has actual block under a property named like the era (e.g. `block.alonzo`).
 * This type creates a union with all the properties. It is later used in
 * [exhaustive switches](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
 * to make sure all block types are handled and future blocks types will generate compile time errors.
 */
export type BlockKind = KeysOfUnion<Schema.Block>;
export type OgmiosBlockType =
  | Schema.BlockAllegra
  | Schema.BlockAlonzo
  | Schema.BlockBabbage
  | Schema.StandardBlock
  | Schema.BlockMary
  | Schema.BlockShelley;

export type CommonBlock = Exclude<OgmiosBlockType, Schema.StandardBlock>;

interface Block<B extends OgmiosBlockType, T extends BlockKind> {
  block: B;
  kind: T;
}

export type BlockAndKind =
  | Block<Schema.BlockAllegra, 'allegra'>
  | Block<Schema.BlockAlonzo, 'alonzo'>
  | Block<Schema.BlockBabbage, 'babbage'>
  | Block<Schema.StandardBlock, 'byron'>
  | Block<Schema.BlockMary, 'mary'>
  | Block<Schema.BlockShelley, 'shelley'>;
