import { CML } from '../..';
import { Ed25519PublicKey } from './Key';
import { Hash28ByteBase16, Hash32ByteBase16, OpaqueString, typedBech32 } from '../util/primitives';
import { InvalidStringError } from '../../errors';
import { Lovelace } from './Value';
import { NewTxAlonzo } from './Transaction';
import { PoolId } from './StakePool/primitives';

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
export type BlockId = OpaqueString<'BlockId'>;

export interface PartialBlockHeader {
  blockNo: BlockNo;
  slot: Slot;
  /** Block header hash */
  hash: BlockId;
}

export type Tip = PartialBlockHeader;

/**
 * @param {string} value block hash as hex string
 * @throws InvalidStringError
 */
export const BlockId = (value: string): BlockId => Hash32ByteBase16(value) as unknown as BlockId;

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
  return Hash28ByteBase16(value) as unknown as GenesisDelegate;
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

/**
 * Get Bech32 encoded VRF verification key from base64 encoded string
 *
 * @param value is a Base64 string
 * @returns Bech32 encoded vrf_vk
 */
export const VrfVkBech32FromBase64 = (value: string) =>
  VrfVkBech32(CML.VRFVKey.from_bytes(Buffer.from(value, 'base64')).to_bech32('vrf_vk'));

/** Minimal Block type meant as a base for the more complete version `Block`  */
// TODO: optionals (except previousBlock) are there because they are not calculated for Byron yet.
// Remove them once calculation is done and remove the Required<BlockMinimal> from interface Block
export interface BlockInfo {
  header: PartialBlockHeader;
  /** Byron blocks fee not calculated yet */
  fees?: Lovelace;
  totalOutput: Lovelace;
  txCount: number;
  /** Byron blocks size not calculated yet */
  size?: BlockSize;
  previousBlock?: BlockId;
  vrf?: VrfVkBech32;
  /**
   * This is the operational cold verification key of the stake pool
   * Leaving as undefined for Byron blocks until we figure out how/if we can use the genesisKey field
   */
  issuerVk?: Ed25519PublicKey;
}

export interface Block extends BlockInfo {
  body: NewTxAlonzo[];
}

export interface ExtendedBlockInfo
  extends Required<Omit<BlockInfo, 'issuerVk' | 'previousBlock'>>,
    Pick<BlockInfo, 'previousBlock'> {
  /**
   * In case of blocks produced by BFT nodes, the SlotLeader the issuerVk hash
   * For blocks produced by stake pools, it is the Bech32 encoded value of issuerVk hash
   */
  slotLeader: SlotLeader; // TODO: move to CompactBlockInfo and make nullable
  date: Date;
  epoch: EpochNo;
  epochSlot: number;
  nextBlock?: BlockId;
  confirmations: number;
}
