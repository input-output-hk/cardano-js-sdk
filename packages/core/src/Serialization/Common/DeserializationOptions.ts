/** Options controlling CBOR deserialization behavior. */
export interface DeserializationOptions {
  /**
   * When true, deserialization throws on unknown map keys instead of silently skipping them, so that
   * constructs from a newer era than this build understands are detected rather than under-rendered.
   * Defaults to false (unknown keys are skipped).
   */
  strict?: boolean;
}
