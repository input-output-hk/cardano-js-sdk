import { Schema } from '@cardano-ogmios/client';

// BFT = byron blocks
// Praos = the rest
// EBB = epoch boundary blocks. We're ignoring these ones (returning null if we find one)
export type OgmiosBlockType = Schema.BlockBFT | Schema.BlockPraos;
type KeysOfUnion<T> = T extends OgmiosBlockType ? T['type'] : never;
/**
 * Ogmios has actual block under a property named like the era (e.g. `block.alonzo`).
 * This type creates a union with all the properties. It is later used in
 * [exhaustive switches](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
 * to make sure all block types are handled and future blocks types will generate compile time errors.
 */
export type BlockKind = KeysOfUnion<Schema.Block>;

export type CommonBlock = Schema.BlockPraos;

interface Block<B extends OgmiosBlockType, T extends BlockKind> {
  block: B;
  kind: T;
}

export type BlockAndKind = Block<Schema.BlockBFT, 'bft'> | Block<Schema.BlockPraos, 'praos'>;
