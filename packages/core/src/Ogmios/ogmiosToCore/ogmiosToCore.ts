import { BigIntMath } from '@cardano-sdk/util';
import { Schema, isByronStandardBlock } from '@cardano-ogmios/client';

import { Cardano, Ogmios } from '../..';

type KeysOfUnion<T> = T extends T ? keyof T : never;
/**
 * Ogmios has actual block under a property named like the era (e.g. `block.alonzo`).
 * This type creates a union with all the properties. It is later used in
 * [exhaustive switches](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#exhaustiveness-checking)
 * to make sure all block types are handled and future blocks types will generate compile time errors.
 */
type BlockKind = KeysOfUnion<Schema.Block>;
type OgmiosBlockType =
  | Schema.BlockAllegra
  | Schema.BlockAlonzo
  | Schema.BlockBabbage
  | Schema.StandardBlock
  | Schema.BlockMary
  | Schema.BlockShelley;

type CommonBlock = Exclude<OgmiosBlockType, Schema.StandardBlock>;

interface Block<B extends OgmiosBlockType, T extends BlockKind> {
  block: B;
  kind: T;
}

type BlockAndKind =
  | Block<Schema.BlockAllegra, 'allegra'>
  | Block<Schema.BlockAlonzo, 'alonzo'>
  | Block<Schema.BlockBabbage, 'babbage'>
  | Block<Schema.StandardBlock, 'byron'>
  | Block<Schema.BlockMary, 'mary'>
  | Block<Schema.BlockShelley, 'shelley'>;

/**
 * @returns
 *   - {BlockAndKind} that unlocks type narrowing in switch statements based on `kind`.
 *     Another advantage of using switch is using exhaustive check of case branches, making sure that future new
 *     block kinds will cause compilation errors, instead of silently fail or runtime errors.
 *   - `null` if `block` is the ByronEpochBoundaryBlock. This block can be skipped
 */
// eslint-disable-next-line complexity
const getBlockAndKind = (block: Schema.Block): BlockAndKind | null => {
  let propName: BlockKind = 'alonzo';
  if (Ogmios.isAllegraBlock(block)) propName = 'allegra';
  if (Ogmios.isAlonzoBlock(block)) propName = 'alonzo';
  if (Ogmios.isBabbageBlock(block)) propName = 'babbage';
  if (Ogmios.isByronBlock(block)) propName = 'byron';
  if (Ogmios.isMaryBlock(block)) propName = 'mary';
  if (Ogmios.isShelleyBlock(block)) propName = 'shelley';

  // If it complains because a branch is not handled, please add logic for the new block type.
  switch (propName) {
    case 'allegra':
      return { block: (block as Schema.Allegra).allegra, kind: 'allegra' };
    case 'alonzo':
      return { block: (block as Schema.Alonzo).alonzo, kind: 'alonzo' };
    case 'babbage':
      return { block: (block as Schema.Babbage).babbage, kind: 'babbage' };
    case 'byron':
      // Return `null` if it is the EBB block to signal that it can be skipped
      return isByronStandardBlock(block) ? { block: block.byron, kind: 'byron' } : null;
    case 'mary':
      return { block: (block as Schema.Mary).mary, kind: 'mary' };
    case 'shelley':
      return { block: (block as Schema.Shelley).shelley, kind: 'shelley' };
    default: {
      // will fail at compile time if not all branches are handled
      // eslint-disable-next-line sonarjs/prefer-immediate-return
      const _exhaustiveCheck: never = propName;
      return _exhaustiveCheck;
    }
  }
};

// Mappers that apply to all Block types
const mapBlockHeight = (block: OgmiosBlockType): number => block.header.blockHeight;
const mapBlockSlot = (block: OgmiosBlockType): number => block.header.slot;
const mapPreviousBlock = (block: OgmiosBlockType): Cardano.BlockId => Cardano.BlockId(block.header.prevHash);

// Mappers specific to Byron block properties
const mapByronHash = (block: Schema.StandardBlock): Cardano.BlockId => Cardano.BlockId(block.hash);
const mapByronTotalOutputs = (block: Schema.StandardBlock): bigint =>
  BigIntMath.sum(
    block.body.txPayload.map(({ body: { outputs } }) => BigIntMath.sum(outputs.map(({ value: { coins } }) => coins)))
  );
const mapByronTxCount = (block: Schema.StandardBlock): number => block.body.txPayload.length;

// Mappers for the rest of Block types
const mapCommonTxCount = (block: CommonBlock): number => block.body.length;
const mapCommonHash = (block: CommonBlock): Cardano.BlockId => Cardano.BlockId(block.headerHash);
const mapCommonTotalOutputs = (block: CommonBlock): Cardano.Lovelace =>
  BigIntMath.sum(
    block.body.map(({ body: { outputs } }) => BigIntMath.sum(outputs.map(({ value: { coins } }) => coins)))
  );
const mapCommonBlockSize = (block: CommonBlock): number => block.header.blockSize;
const mapCommonFees = (block: CommonBlock): Cardano.Lovelace =>
  block.body.map(({ body: { fee } }) => fee).reduce((prev, current) => prev + current, 0n);
// This is the VRF verification key, An Ed25519 verification key.
const mapCommonVrf = (block: CommonBlock): Cardano.VrfVkBech32 => Cardano.VrfVkBech32FromBase64(block.header.issuerVrf);
// SlotLeader is the producer pool id. It can be calculated from the issuer verification key
// which is actually the cold verification key
const mapCommonSlotLeader = (block: CommonBlock): Cardano.Ed25519PublicKey =>
  Cardano.Ed25519PublicKey(block.header.issuerVk);

export const mapByronBlock = (block: Schema.StandardBlock): Cardano.BlockMinimal => ({
  fees: undefined, // TODO: figure out how to calculate fees
  header: {
    blockNo: mapBlockHeight(block),
    hash: mapByronHash(block),
    slot: mapBlockSlot(block)
  },
  // TODO: use the genesisKey to provide a value here, but it needs more work. Leaving as undefined for now
  issuerVk: undefined,
  previousBlock: mapPreviousBlock(block),
  // TODO: calculate byron blocksize by transforming into CSL Block object
  size: undefined,
  totalOutput: mapByronTotalOutputs(block),
  txCount: mapByronTxCount(block),
  vrf: undefined // no vrf key for byron. DbSync doesn't have one either
});

export const mapCommonBlock = (block: CommonBlock): Cardano.BlockMinimal => ({
  fees: mapCommonFees(block),
  header: {
    blockNo: mapBlockHeight(block),
    hash: mapCommonHash(block),
    slot: mapBlockSlot(block)
  },
  issuerVk: mapCommonSlotLeader(block),
  previousBlock: mapPreviousBlock(block),
  size: mapCommonBlockSize(block),
  totalOutput: mapCommonTotalOutputs(block),
  txCount: mapCommonTxCount(block),
  vrf: mapCommonVrf(block)
});

/**
 * Translate `Ogmios` block to `Cardano.BlockMinimal`
 *
 * @param ogmiosBlock the block to translate into a `Cardano.BlockMinimal`
 * @returns
 *   - {Cardano.BlockMinimal} a minimal block type encompassing information extracted from Ogmios block type.
 *   - `null` if `block` is the ByronEpochBoundaryBlock. This block can be skipped.
 */
export const getBlock = (ogmiosBlock: Schema.Block): Cardano.BlockMinimal | null => {
  const b = getBlockAndKind(ogmiosBlock);
  if (!b) return null;

  switch (b.kind) {
    case 'byron': {
      return mapByronBlock(b.block);
    }
    case 'babbage':
    case 'allegra':
    case 'alonzo':
    case 'mary':
    case 'shelley': {
      return mapCommonBlock(b.block);
    }
    default: {
      // eslint-disable-next-line sonarjs/prefer-immediate-return
      const _exhaustiveCheck: never = b;
      return _exhaustiveCheck;
    }
  }
};

// byron-shelley-allegra-mary-alonzo-babbage
