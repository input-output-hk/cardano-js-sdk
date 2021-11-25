import { BlockAlonzo, BlockSize } from '@cardano-ogmios/schema';
import { Cardano } from '../..';
import { Epoch, Lovelace, PoolId } from '.';
import { Hash32ByteBase16 } from '../util';

/**
 * block hash as hex string
 */
export type BlockId = Hash32ByteBase16<'BlockId'>;

/**
 * @param {string} value block hash as hex string
 * @throws InvalidStringError
 */
export const BlockId = (value: string): BlockId => Hash32ByteBase16<'BlockId'>(value);

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
