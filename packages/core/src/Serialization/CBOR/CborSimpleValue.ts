/**
 * Represents a CBOR simple value (major type 7).
 */
export enum CborSimpleValue {
  /**
   * Represents the value 'false'.
   */
  False = 20,

  /**
   * Represents the value 'true'.
   */
  True = 21,

  /**
   * Represents the value 'null'.
   */
  Null = 22,

  /**
   * Represents an undefined value, to be used by an encoder as a substitute for a data item with an encoding problem.
   */
  Undefined = 23
}
