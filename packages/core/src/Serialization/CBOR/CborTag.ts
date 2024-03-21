/** Represents a CBOR semantic tag (major type 6). */
export enum CborTag {
  /** Tag value for RFC3339 date/time strings. */
  DateTimeString = 0,

  /** Tag value for Epoch-based date/time strings. */
  UnixTimeSeconds = 1,

  /** Tag value for unsigned bignum encodings. */
  UnsignedBigNum = 2,

  /** Tag value for negative bignum encodings. */
  NegativeBigNum = 3,

  /** Tag value for decimal fraction encodings. */
  DecimalFraction = 4,

  /** Tag value for big float encodings. */
  BigFloat = 5,

  /** Tag value for byte strings, meant for later encoding to a base64url string representation. */
  Base64UrlLaterEncoding = 21,

  /** Tag value for byte strings, meant for later encoding to a base64 string representation. */
  Base64StringLaterEncoding = 22,

  /** Tag value for byte strings, meant for later encoding to a base16 string representation. */
  Base16StringLaterEncoding = 23,

  /** Tag value for byte strings containing embedded CBOR data item encodings. */
  EncodedCborDataItem = 24,

  /** Tag value for Rational numbers, as defined in http://peteroupc.github.io/CBOR/rational.html. */
  RationalNumber = 30,

  /** Tag value for Uri strings, as defined in RFC3986. */
  Uri = 32,

  /** Tag value for base64url-encoded text strings, as defined in RFC4648. */
  Base64Url = 33,

  /** Tag value for base64-encoded text strings, as defined in RFC4648. */
  Base64 = 34,

  /** Tag value for regular expressions in Perl Compatible Regular Expressions / Javascript syntax. */
  Regex = 35,

  /** Tag value for MIME messages (including all headers), as defined in RFC2045. */
  MimeMessage = 36,

  /** Tag value for `set<a> = #6.258([* a]) / [* a]`, `nonempty_set<a> = #6.258([+ a]) / [+ a]`, `nonempty_oset<a> = #6.258([+ a]) / [+ a]` */
  Set = 258,

  /** Tag value for the Self-Describe CBOR header (0xd9d9f7). */
  SelfDescribeCbor = 55_799
}
