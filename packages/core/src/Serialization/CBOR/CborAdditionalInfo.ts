/**
 * Represents the 5-bit additional information included in a CBOR initial byte.
 */
export enum CborAdditionalInfo {
  AdditionalFalse = 20,
  AdditionalTrue = 21,
  AdditionalNull = 22,
  Additional8BitData = 24,
  Additional16BitData = 25,
  Additional32BitData = 26,
  Additional64BitData = 27,
  IndefiniteLength = 31
}
