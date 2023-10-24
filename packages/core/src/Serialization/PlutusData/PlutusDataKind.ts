/** The plutus data type kind. */
export enum PlutusDataKind {
  /** Represents a specific constructor of a 'Sum Type' along with its arguments. */
  ConstrPlutusData,

  /** A map of PlutusData as both key and values. */
  Map,

  /** A list of PlutusData. */
  List,

  /** An integer. */
  Integer,

  /** Bounded bytes. */
  Bytes
}
