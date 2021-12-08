import { BlockNo, BlockSize, Slot } from '@cardano-ogmios/schema';
import { Cardano } from '../..';
import { Epoch, Lovelace, PoolId } from '.';
import { Hash32ByteBase16, OpaqueString, typedBech32 } from '../util';

export { BlockNo } from '@cardano-ogmios/schema';

/**
 * block hash as hex string
 */
export type BlockId = Hash32ByteBase16<'BlockId'>;

export interface PartialBlockHeader {
  blockNo: BlockNo;
  slot: Slot;
  hash: BlockId;
}

export type Tip = PartialBlockHeader;

/**
 * @param {string} value block hash as hex string
 * @throws InvalidStringError
 */
export const BlockId = (value: string): BlockId => Hash32ByteBase16<'BlockId'>(value);

export { BlockSize };

/**
 * 32 byte ed25519 verification key as bech32 string.
 */
export type VrfVkBech32 = OpaqueString<'VrfVkBech32'>;
export const VrfVkBech32 = (value: string) => typedBech32<VrfVkBech32>(value, 'vrf_vk', 52);

export interface Block {
  header: PartialBlockHeader;
  date: Date;
  epoch: Epoch;
  epochSlot: number;
  slotLeader: PoolId;
  size: BlockSize;
  txCount: number;
  totalOutput: Cardano.Lovelace;
  fees: Lovelace;
  vrf: VrfVkBech32;
  previousBlock?: BlockId;
  nextBlock?: BlockId;
  confirmations: number;
}
