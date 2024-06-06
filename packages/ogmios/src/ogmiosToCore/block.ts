import { BigIntMath } from '@cardano-sdk/util';
import {
  isAllegraBlock,
  isAlonzoBlock,
  isBabbageBlock,
  isByronBlock,
  isByronStandardBlock,
  isMaryBlock,
  isShelleyBlock
} from '@cardano-ogmios/client';
import type { Schema } from '@cardano-ogmios/client';

import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { mapByronBlockBody, mapCommonBlockBody } from './tx.js';
import type { BlockAndKind, BlockKind, CommonBlock, OgmiosBlockType } from './types.js';

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
  if (isAllegraBlock(block)) propName = 'allegra';
  if (isAlonzoBlock(block)) propName = 'alonzo';
  if (isBabbageBlock(block)) propName = 'babbage';
  if (isByronBlock(block)) propName = 'byron';
  if (isMaryBlock(block)) propName = 'mary';
  if (isShelleyBlock(block)) propName = 'shelley';

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
const mapPreviousBlock = (block: OgmiosBlockType): Cardano.BlockId | undefined =>
  block.header.prevHash !== 'genesis' ? Cardano.BlockId(block.header.prevHash) : undefined;

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
const mapCommonBlockSize = (block: CommonBlock): Cardano.BlockSize => Cardano.BlockSize(block.header.blockSize);
const mapCommonFees = (block: CommonBlock): Cardano.Lovelace =>
  block.body.map(({ body: { fee } }) => fee).reduce((prev, current) => prev + current, 0n);
// This is the VRF verification key, An Ed25519 verification key.
const mapCommonVrf = (block: CommonBlock): Cardano.VrfVkBech32 => Cardano.VrfVkBech32FromBase64(block.header.issuerVrf);
// SlotLeader is the producer pool id. It can be calculated from the issuer verification key
// which is actually the cold verification key
const mapCommonSlotLeader = (block: CommonBlock): Crypto.Ed25519PublicKeyHex =>
  Crypto.Ed25519PublicKeyHex(block.header.issuerVk);

const mapStandardBlockHeader = (block: Schema.StandardBlock) => ({
  blockNo: Cardano.BlockNo(mapBlockHeight(block)),
  hash: mapByronHash(block),
  slot: Cardano.Slot(mapBlockSlot(block))
});

const mapCommonBlockHeader = (block: CommonBlock) => ({
  blockNo: Cardano.BlockNo(mapBlockHeight(block)),
  hash: mapCommonHash(block),
  slot: Cardano.Slot(mapBlockSlot(block))
});

const mapByronBlock = (block: Schema.StandardBlock): Cardano.Block => ({
  body: mapByronBlockBody(block),
  fees: undefined,

  // TODO: figure out how to calculate fees
  header: mapStandardBlockHeader(block),
  // TODO: use the genesisKey to provide a value here, but it needs more work. Leaving as undefined for now
  issuerVk: undefined,

  previousBlock: mapPreviousBlock(block),
  // TODO: calculate byron blocksize by transforming into CSL Block object
  size: undefined,
  totalOutput: mapByronTotalOutputs(block),
  txCount: mapByronTxCount(block),
  vrf: undefined // no vrf key for byron. DbSync doesn't have one either
});

const mapCommonBlock = (block: CommonBlock, kind: BlockKind): Cardano.Block => ({
  body: mapCommonBlockBody(block, kind),
  fees: mapCommonFees(block),
  header: mapCommonBlockHeader(block),
  issuerVk: mapCommonSlotLeader(block),
  previousBlock: mapPreviousBlock(block),
  size: mapCommonBlockSize(block),
  totalOutput: mapCommonTotalOutputs(block),
  txCount: mapCommonTxCount(block),
  vrf: mapCommonVrf(block)
});

const mapBlock = <R>(
  ogmiosBlock: Schema.Block,
  mapStandardBlock: (b: Schema.StandardBlock) => R,
  mapOtherBlock: (b: CommonBlock, k: BlockKind) => R
) => {
  const b = getBlockAndKind(ogmiosBlock);
  if (!b) return null;

  switch (b.kind) {
    case 'byron': {
      return mapStandardBlock(b.block);
    }
    case 'babbage':
    case 'allegra':
    case 'alonzo':
    case 'mary':
    case 'shelley': {
      return mapOtherBlock(b.block, b.kind);
    }
    default: {
      // eslint-disable-next-line sonarjs/prefer-immediate-return
      const _exhaustiveCheck: never = b;
      return _exhaustiveCheck;
    }
  }
};

/**
 * Extract block header from `Ogmios` block
 *
 * @returns {Cardano.PartialBlockHeader} compact block header.
 *   - `null` if `block` is the ByronEpochBoundaryBlock. This block can be skipped.
 */
export const blockHeader = (ogmiosBlock: Schema.Block): Cardano.PartialBlockHeader | null =>
  mapBlock<Cardano.PartialBlockHeader>(ogmiosBlock, mapStandardBlockHeader, mapCommonBlockHeader);

/**
 * Translate `Ogmios` block to `Cardano.BlockMinimal`
 *
 * @param ogmiosBlock the block to translate into a `Cardano.BlockMinimal`
 * @returns {Cardano.BlockMinimal} a minimal block type encompassing information extracted from Ogmios block type.
 *  - `null` if `block` is the ByronEpochBoundaryBlock. This block can be skipped.
 */
export const block = (ogmiosBlock: Schema.Block): Cardano.Block | null =>
  mapBlock<Cardano.Block>(ogmiosBlock, mapByronBlock, mapCommonBlock);

// byron-shelley-allegra-mary-alonzo-babbage
