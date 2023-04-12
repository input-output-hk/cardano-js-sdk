/**
 * Specifies the state of a CborReader instance.
 */
export enum CborReaderState {
  /**
   * Indicates the undefined state.
   */
  Undefined = 0,

  /**
   * Indicates that the next CBOR data item is an unsigned integer (major type 0).
   */
  UnsignedInteger,

  /**
   * Indicates that the next CBOR data item is a negative integer (major type 1).
   */
  NegativeInteger,

  /**
   * Indicates that the next CBOR data item is a byte string (major type 2).
   */
  ByteString,

  /**
   * Indicates that the next CBOR data item denotes the start of an indefinite-length byte string (major type 2).
   */
  StartIndefiniteLengthByteString,

  /**
   * Indicates that the reader is at the end of an indefinite-length byte string (major type 2).
   */
  EndIndefiniteLengthByteString,

  /**
   * Indicates that the next CBOR data item is a UTF-8 string (major type 3).
   */
  TextString,

  /**
   * Indicates that the next CBOR data item denotes the start of an indefinite-length UTF-8 text string (major type 3).
   */
  StartIndefiniteLengthTextString,

  /**
   * Indicates that the reader is at the end of an indefinite-length UTF-8 text string (major type 3).
   */
  EndIndefiniteLengthTextString,

  /**
   * Indicates that the next CBOR data item denotes the start of an array (major type 4).
   */
  StartArray,
  /**
   * Indicates that the reader is at the end of an array (major type 4).
   */
  EndArray,

  /**
   * Indicates that the next CBOR data item denotes the start of a map (major type 5).
   */
  StartMap,

  /**
   * Indicates that the reader is at the end of a map (major type 5).
   */
  EndMap,

  /**
   * Indicates that the next CBOR data item is a semantic tag (major type 6).
   */
  Tag,

  /**
   * Indicates that the next CBOR data item is a simple value (major type 7).
   */
  SimpleValue,
  /**
   * Indicates that the next CBOR data item is an IEEE 754 Half-Precision float (major type 7).
   */
  HalfPrecisionFloat,
  /**
   * Indicates that the next CBOR data item is an IEEE 754 Single-Precision float (major type 7).
   */
  SinglePrecisionFloat,

  /**
   * Indicates that the next CBOR data item is an IEEE 754 Double-Precision float (major type 7).
   */
  DoublePrecisionFloat,
  /**
   * Indicates that the next CBOR data item is a null literal (major type 7).
   */
  Null,
  /**
   * Indicates that the next CBOR data item encodes a bool value (major type 7).
   */
  Boolean,

  /**
   * Indicates that the reader has completed reading a full CBOR document.
   */
  Finished
}
