import * as BaseEncoding from '@scure/base';
import * as Crypto from '@cardano-sdk/crypto';
import { InvalidStringError, OpaqueNumber, OpaqueString, typedBech32 } from '@cardano-sdk/util';
import { Lovelace } from './Value';
import { OnChainTx } from './Transaction';
import { PoolId } from './StakePool/primitives';

/** The block size in bytes */
export type BlockSize = OpaqueNumber<'BlockSize'>;
export const BlockSize = (value: number): BlockSize => value as unknown as BlockSize;

/** The block number. */
export type BlockNo = OpaqueNumber<'BlockNo'>;
export const BlockNo = (value: number): BlockNo => value as unknown as BlockNo;

/** The epoch number. */
export type EpochNo = OpaqueNumber<'EpochNo'>;
export const EpochNo = (value: number): EpochNo => value as unknown as EpochNo;

/** Smallest time period in the blockchain */
export type Slot = OpaqueNumber<'Slot'>;
export const Slot = (value: number): Slot => value as unknown as Slot;

/** block hash as hex string */
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
export const BlockId = (value: string): BlockId => Crypto.Hash32ByteBase16(value) as unknown as BlockId;

/** 32 byte ed25519 verification key as bech32 string. */
export type VrfVkBech32 = OpaqueString<'VrfVkBech32'>;
export const VrfVkBech32 = (value: string) => typedBech32<VrfVkBech32>(value, 'vrf_vk', 52);

/** Shelley genesis delegate Either a 28 byte hex string, or 'ShelleyGenesis-[8byte-hex-string]' */
export type GenesisDelegate = OpaqueString<'GenesisDelegate'>;
export const GenesisDelegate = (value: string): GenesisDelegate => {
  // eslint-disable-next-line wrap-regex
  if (/ShelleyGenesis-[\da-f]{16}/.test(value)) {
    return value as unknown as GenesisDelegate;
  }
  return Crypto.Hash28ByteBase16(value) as unknown as GenesisDelegate;
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
 * Get Bech32 encoded VRF verification key from base16 encoded string
 *
 * @param value is a base16 string
 * @returns Bech32 encoded vrf_vk
 */
VrfVkBech32.fromHex = (value: string) => {
  const words = BaseEncoding.bech32.toWords(Buffer.from(value, 'hex'));
  return VrfVkBech32(BaseEncoding.bech32.encode('vrf_vk', words, 1023));
};

export type BlockType = 'bft' | 'praos';

/** Minimal Block type meant as a base for the more complete version `Block`  */
// TODO: optionals (except previousBlock) are there because they are not calculated for Byron yet.
// Remove them once calculation is done and remove the Required<BlockMinimal> from interface Block
export interface BlockInfo {
  type: BlockType;
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
  issuerVk?: Crypto.Ed25519PublicKeyHex;
}

export interface Block extends BlockInfo {
  body: OnChainTx[];
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
