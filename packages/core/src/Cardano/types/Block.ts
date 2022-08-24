import { Hash28ByteBase16, Hash32ByteBase16, OpaqueString, typedBech32 } from '../util';
import { InvalidStringError } from '../..';
import { Lovelace, PoolId } from '.';

/**
 * The block size in bytes
 */
export type BlockSize = number;

/**
 * The block number.
 */
export type BlockNo = number;

/**
 * The epoch number.
 */
export type EpochNo = number;

/**
 * Smallest time period in the blockchain
 */
export type Slot = number;

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

/**
 * 32 byte ed25519 verification key as bech32 string.
 */
export type VrfVkBech32 = OpaqueString<'VrfVkBech32'>;
export const VrfVkBech32 = (value: string) => typedBech32<VrfVkBech32>(value, 'vrf_vk', 52);

/**
 * Shelley genesis delegate
 * Either a 28 byte hex string, or 'ShelleyGenesis-[8byte-hex-string]'
 */
export type GenesisDelegate = OpaqueString<'GenesisDelegate'>;
export const GenesisDelegate = (value: string): GenesisDelegate => {
  // eslint-disable-next-line wrap-regex
  if (/ShelleyGenesis-[\da-f]{16}/.test(value)) {
    return value as unknown as GenesisDelegate;
  }
  return Hash28ByteBase16(value);
};

export type SlotLeader = PoolId | GenesisDelegate;
export const SlotLeader = (value: string): SlotLeader => {
  try {
    return PoolId(value);
  } catch {
    try {
      return GenesisDelegate(value);
    } catch (error) {
      throw new InvalidStringError('Expected either PoolId or GenesisDelegate', error);
    }
  }
};

export interface Block {
  header: PartialBlockHeader;
  date: Date;
  epoch: EpochNo;
  epochSlot: number;
  slotLeader: SlotLeader;
  size: BlockSize;
  txCount: number;
  totalOutput: Lovelace;
  fees: Lovelace;
  vrf: VrfVkBech32;
  previousBlock?: BlockId;
  nextBlock?: BlockId;
  confirmations: number;
}
