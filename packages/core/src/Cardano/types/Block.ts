import { BlockAlonzo, BlockNo, BlockSize, Slot } from '@cardano-ogmios/schema';
import { Cardano } from '../..';
import { Epoch, Lovelace, PoolId } from '.';
import { Hash32ByteBase16, OpaqueString, typedBech32 } from '../util';

/**
 * block hash as hex string
 */
export type BlockId = Hash32ByteBase16<'BlockId'>;

export interface Tip {
  slot: Slot;
  hash: BlockId;
  blockNo: BlockNo;
}

/**
 * @param {string} value block hash as hex string
 * @throws InvalidStringError
 */
export const BlockId = (value: string): BlockId => Hash32ByteBase16<'BlockId'>(value);

export { BlockSize };

/**
 * 32 byte ed25519 verification key as bech32 string.
 * poolmd_vk prefix might be used in extended stake pool metadata (cip6).
 */
export type VrfVkBech32 = OpaqueString<'VrfVkBech32'>;
export const VrfVkBech32 = (value: string) => typedBech32<VrfVkBech32>(value, ['vrf_vk', 'poolmd_vk'], 52);

type OgmiosHeader = NonNullable<BlockAlonzo['header']>;
export type PartialBlockHeader = Pick<OgmiosHeader, 'blockHeight' | 'slot'> & {
  blockHash: BlockId;
};

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
