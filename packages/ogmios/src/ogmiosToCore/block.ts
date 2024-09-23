import { BigIntMath, isNotNil } from '@cardano-sdk/util';
import { Schema, isBlockBFT, isBlockPraos } from '@cardano-ogmios/client';

import * as Crypto from '@cardano-sdk/crypto';
import { BlockAndKind, CommonBlock, OgmiosBlockType } from './types';
import { Cardano } from '@cardano-sdk/core';
import { mapBlockBody } from './tx';

/**
 * @returns
 *   - { BlockAndKind }
 *   - `null` if `block` is the ByronEpochBoundaryBlock. This block can be skipped
 */
const getBlockAndKind = (block: Schema.Block): BlockAndKind | null => {
  if (isBlockBFT(block)) return { block: block as Schema.BlockBFT, kind: 'bft' };
  if (isBlockPraos(block)) return { block: block as Schema.BlockPraos, kind: 'praos' };

  return null;
};

// Mappers that apply to all Block types
const mapBlockHeight = (block: OgmiosBlockType): number => block.height;
const mapBlockSlot = (block: OgmiosBlockType): number => block.slot;
const mapPreviousBlock = (block: OgmiosBlockType): Cardano.BlockId | undefined =>
  block.ancestor !== 'genesis' ? Cardano.BlockId(block.ancestor) : undefined;
const mapTxCount = (block: OgmiosBlockType): number => block.transactions?.length || 0;
const mapBlockHash = (block: OgmiosBlockType): Cardano.BlockId => Cardano.BlockId(block.id);
const mapTotalOutputs = (block: OgmiosBlockType): Cardano.Lovelace =>
  BigIntMath.sum(
    (block.transactions || []).map(({ outputs }) =>
      BigIntMath.sum(
        outputs.map(
          ({
            value: {
              ada: { lovelace }
            }
          }) => lovelace
        )
      )
    )
  );
const mapBlockSize = (block: OgmiosBlockType): Cardano.BlockSize => Cardano.BlockSize(block.size.bytes);
const mapFees = (block: OgmiosBlockType): Cardano.Lovelace =>
  (block.transactions || [])
    .map(({ fee }) => fee)
    .filter(isNotNil)
    .reduce((prev, { ada: { lovelace } }) => prev + lovelace, 0n);

const mapBlockHeader = (block: OgmiosBlockType) => ({
  blockNo: Cardano.BlockNo(mapBlockHeight(block)),
  hash: mapBlockHash(block),
  slot: Cardano.Slot(mapBlockSlot(block))
});

// Mappers for the rest of Block types

// This is the VRF verification key, An Ed25519 verification key.
const mapCommonVrf = (block: CommonBlock): Cardano.VrfVkBech32 =>
  Cardano.VrfVkBech32.fromHex(block.issuer.vrfVerificationKey);
// SlotLeader is the producer pool id. It can be calculated from the issuer verification key
// which is actually the cold verification key
const mapCommonSlotLeader = (block: CommonBlock): Crypto.Ed25519PublicKeyHex =>
  Crypto.Ed25519PublicKeyHex(block.issuer.verificationKey);

const mapByronBlock = (block: Schema.BlockBFT): Cardano.Block => ({
  body: mapBlockBody(block),
  // TODO: figure out how to calculate fees
  fees: undefined,
  header: mapBlockHeader(block),
  // TODO: use the genesisKey to provide a value here, but it needs more work. Leaving as undefined for now
  issuerVk: undefined,

  previousBlock: mapPreviousBlock(block),
  size: mapBlockSize(block),
  totalOutput: mapTotalOutputs(block),
  txCount: mapTxCount(block),
  type: block.type,
  vrf: undefined // no vrf key for byron. DbSync doesn't have one either
});

const mapCommonBlock = (block: CommonBlock): Cardano.Block => ({
  body: mapBlockBody(block),
  fees: mapFees(block),
  header: mapBlockHeader(block),
  issuerVk: mapCommonSlotLeader(block),
  previousBlock: mapPreviousBlock(block),
  size: mapBlockSize(block),
  totalOutput: mapTotalOutputs(block),
  txCount: mapTxCount(block),
  type: block.type,
  vrf: mapCommonVrf(block)
});

const mapBlock = <R>(
  ogmiosBlock: Schema.Block,
  mapStandardBlock: (b: Schema.BlockBFT) => R,
  mapOtherBlock: (b: CommonBlock) => R
) => {
  const b = getBlockAndKind(ogmiosBlock);
  if (!b) return null;

  switch (b.kind) {
    case 'bft': {
      return mapStandardBlock(b.block);
    }
    case 'praos': {
      return mapOtherBlock(b.block);
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
  mapBlock<Cardano.PartialBlockHeader>(ogmiosBlock, mapBlockHeader, mapBlockHeader);

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
