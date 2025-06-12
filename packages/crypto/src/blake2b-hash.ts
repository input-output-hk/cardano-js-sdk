import { HexBlob, hexStringToBuffer } from '@cardano-sdk/util';
import hash from 'blake2b';
import type { Hash28ByteBase16, Hash32ByteBase16 } from './hexTypes';

export interface Blake2b {
  /**
   * blake2b-256
   *
   * @param message payload to hash
   * @param outputLengthBytes digest size, e.g. 28 for blake2b-224 or 32 for blake2b-256
   */
  hash<T extends Hash32ByteBase16>(message: HexBlob, outputLengthBytes: 32): T;
  /**
   * blake2b-224
   *
   * @param message payload to hash
   * @param outputLengthBytes digest size, e.g. 28 for blake2b-224 or 32 for blake2b-256
   */
  hash<T extends Hash28ByteBase16>(message: HexBlob, outputLengthBytes: 28): T;
  /**
   * @param message payload to hash
   * @param outputLengthBytes digest size, e.g. 28 for blake2b-224 or 32 for blake2b-256
   */
  hash<T extends HexBlob>(message: HexBlob, outputLengthBytes: number): T;

  /**
   * @param message payload to hash
   * @param outputLengthBytes digest size, e.g. 28 for blake2b-224 or 32 for blake2b-256
   */
  hashAsync<T extends HexBlob>(message: HexBlob, outputLengthBytes: number): Promise<T>;
}

export const blake2b: Blake2b = {
  hash<T extends HexBlob>(message: HexBlob, outputLengthBytes: number) {
    return hash(outputLengthBytes).update(hexStringToBuffer(message)).digest('hex') as T;
  },
  async hashAsync<T extends HexBlob>(message: HexBlob, outputLengthBytes: number): Promise<T> {
    return new Promise((resolve) => {
      setImmediate(() => {
        resolve(blake2b.hash<T>(message, outputLengthBytes));
      });
    });
  }
};
