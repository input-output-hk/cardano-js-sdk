// Source: https://github.com/Microsoft/Typescript/issues/202#issuecomment-811246768
export declare class OpaqueString<T extends string> extends String {
  /** This helps typescript distinguish different opaque string types. */
  protected readonly __opaqueString: T;
  /**
   * This object is already a string, but calling this makes method
   * makes typescript recognize it as such.
   */
  toString(): string;
}

export declare class OpaqueNumber<T extends string> extends Number {
  /** This helps typescript distinguish different opaque number types. */
  protected readonly __opaqueNumber: T;
}
