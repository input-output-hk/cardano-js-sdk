import { BlockAlonzo, BlockSize } from '@cardano-ogmios/schema';
import { Cardano } from '../..';
import { Epoch, Lovelace, PoolId } from '.';
import { OpaqueString, assertIsHexString } from '../util';

/**
 * block hash as hex string
 */
export type BlockId = OpaqueString<'BlockId'>;

/**
 * @param {string} value block hash as hex string
 * @throws InvalidStringError
 */
export const BlockId = (value: string): BlockId => {
  assertIsHexString(value, 64);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return value as any as BlockId;
};

export { BlockSize };
export type VrfVkBech32 = string;

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
