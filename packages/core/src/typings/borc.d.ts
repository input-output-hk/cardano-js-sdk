declare module 'borc' {
  /**
   * A CBOR tagged item, where the tag does not have semantics specified at the
   * moment, or those semantics threw an error during parsing. Typically this will
   * be an extension point you're not yet expecting.
   */
  export class Tagged {
    /**
     * Creates an instance of Tagged.
     *
     * @param {number} tag - the number of the tag
     * @param {any} value - the value inside the tag
     */
    constructor(tag: number, value: any);

    /**
     * If we have a converter for this type, do the conversion.  Some converters
     * are built-in.  Additional ones can be passed in.  If you want to remove
     * a built-in converter, pass a converter in whose value is 'null' instead
     * of a function.
     *
     * @param {Object} converters - keys in the object are a tag number, the value
     * is a function that takes the decoded CBOR and returns a JavaScript value
     * of the appropriate type.  Throw an exception in the function on errors.
     * @returns {any} - the converted item
     */
    convert(converters: any): any;

    /**
     * Push the simple value onto the CBOR stream
     *
     * @param gen - The generator to push onto
     * @returns {number}
     */
    encodeCBOR(gen: any): number;

    /**
     * Convert to a String
     *
     * @returns {string} string of the form '1(2)'
     */
    toString(): string;
  }

  /**
   * Decode the first cbor object.
   *
   * @param {Uint8Array|Buffer|string} input
   * @param {string} [enc='hex'] - Encoding used if a string is passed.
   * @returns {*}
   */
  export function decode(input: Uint8Array | Buffer | string, enc: string = 'hex'): any;

  /**
   * Encode the given value
   *
   * @param {*} o
   * @returns {Buffer}
   */
  export function encode(...o: any[]): Buffer;
}
