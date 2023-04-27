/**
 * Represents CBOR Major Types, as defined in RFC7049 section 2.1.
 */
export enum CborMajorType {
  /**
   * An unsigned integer in the range 0..264-1 inclusive. The value of the encoded item is the argument itself.
   */
  UnsignedInteger = 0,

  /**
   * A negative integer in the range -264..-1 inclusive. The value of the item is -1 minus the argument.
   */
  NegativeInteger = 1,

  /**
   * A byte string. The number of bytes in the string is equal to the argument.
   */
  ByteString = 2,

  /**
   * A text string (Section 2) encoded as UTF-8 [RFC3629]. The number of bytes in the string is equal to the argument.
   */
  Utf8String = 3,

  /**
   * An array of data items. In other formats, arrays are also called lists, sequences, or tuples (a "CBOR sequence"
   * is something slightly different, though [RFC8742]). The argument is the number of data items in the array.
   */
  Array = 4,

  /**
   * A map of pairs of data items. Maps are also called tables, dictionaries, hashes, or objects (in JSON).
   */
  Map = 5,

  /**
   * A tagged data item ("tag") whose tag number, an integer in the range 0..264-1 inclusive, is the argument and whose
   * enclosed data item (tag content) is the single encoded data item that follows the head.
   */
  Tag = 6,

  /**
   * Simple values, Floating-point numbers and the "break" stop code.
   */
  Simple = 7
}
