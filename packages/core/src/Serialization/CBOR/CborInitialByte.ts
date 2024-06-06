/* eslint-disable no-bitwise */
/* eslint-disable unicorn/number-literal-case */
import type { CborAdditionalInfo } from './CborAdditionalInfo.js';
import type { CborMajorType } from './CborMajorType.js';

/** Represents a CBOR initial byte. */
export class CborInitialByte {
  static readonly IndefiniteLengthBreakByte = 0xff;
  static readonly AdditionalInformationMask = 0b0001_1111;

  #initialByte: number;

  /**
   * Initializes a new instance of the CborInitialByte class.
   *
   * @param majorType The initial byte major type.
   * @param additionalInfo The initial byte additional info.
   */
  CborInitialByte(majorType: CborMajorType, additionalInfo: CborAdditionalInfo) {
    this.#initialByte = (majorType << 5) | additionalInfo;
  }

  /**
   * Creates a CborInitialByte class from a packed initialByte.
   *
   * @param initialByte The initial.
   */
  static from(initialByte: number) {
    const init = new CborInitialByte();
    init.#initialByte = initialByte;

    return init;
  }

  /**
   * Gets the packed initial byte.
   *
   * @returns The packed initial byte.
   */
  getInitialByte(): number {
    return this.#initialByte;
  }

  /**
   * Gets the initial type major type.
   *
   * @returns The major type.
   */
  getMajorType(): CborMajorType {
    return this.#initialByte >> 5;
  }

  /**
   * Gets initial type the additional info.
   *
   * @returns The additional info.
   */
  getAdditionalInfo(): CborAdditionalInfo {
    return this.#initialByte & CborInitialByte.AdditionalInformationMask;
  }
}
