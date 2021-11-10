import { BlockSize } from '@cardano-ogmios/schema';
import { Cardano } from '../..';
import { Epoch, Hash16, Lovelace, PartialBlockHeader, PoolId } from '.';

export { BlockSize };
export type VrfVkBech32 = string;

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
  previousBlock?: Hash16;
  nextBlock?: Hash16;
  confirmations: number;
}
