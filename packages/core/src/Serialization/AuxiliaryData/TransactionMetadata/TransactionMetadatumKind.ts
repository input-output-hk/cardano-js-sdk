/** The transaction metadatum type kind. */
export enum TransactionMetadatumKind {
  /** A map of TransactionMetadatum as both key and values. */
  Map,

  /** A list of TransactionMetadatum. */
  List,

  /** An integer. */
  Integer,

  /** Bounded bytes. */
  Bytes,

  /** A text string. */
  Text
}
