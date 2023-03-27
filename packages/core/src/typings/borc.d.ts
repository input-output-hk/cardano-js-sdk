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

  export type ExtendedResults = {
    /**
     * The value that was found.
     */
    value: any;
    /**
     * The number of bytes of the original input that
     * were read.
     */
    length: number;
    /**
     * The bytes of the original input that were used
     * to produce the value.
     */
    bytes: Buffer;
    /**
     * The bytes that were left over from the original
     * input.  This property only exists if {@linkcode Decoder.decodeFirst } or
     * {@linkcode Decoder.decodeFirstSync } was called.
     */
    unused?: Buffer;
  };

  export type DecoderOptions = {
    /**
     * The maximum depth to parse.
     * Use -1 for "until you run out of memory".  Set this to a finite
     * positive number for un-trusted inputs.  Most standard inputs won't nest
     * more than 100 or so levels; I've tested into the millions before
     * running out of memory.
     */
    max_depth?: number;
    /**
     * Mapping from tag number to function(v),
     * where v is the decoded value that comes after the tag, and where the
     * function returns the correctly-created value for that tag.
     */
    tags?: Tagged.TagMap;
    /**
     * If true, prefer Uint8Arrays to
     * be generated instead of node Buffers.  This might turn on some more
     * changes in the future, so forward-compatibility is not guaranteed yet.
     */
    preferWeb?: boolean;
    /**
     * The encoding of the input.
     * Ignored if input is a Buffer.
     */
    encoding?: BufferEncoding;
    /**
     * Should an error be thrown when no
     * data is in the input?
     */
    required?: boolean;
    /**
     * If true, emit extended
     * results, which will be an object with shape {@link ExtendedResults }.
     * The value will already have been null-checked.
     */
    extendedResults?: boolean;
    /**
     * If true, error is
     * thrown if a map has duplicate keys.
     */
    preventDuplicateKeys?: boolean;
  };

  export type decodeCallback = (error?: Error, value?: any) => void;

  /**
   * Decode a stream of CBOR bytes by transforming them into equivalent
   * @extends BinaryParseStream
   */
  export class Decoder extends BinaryParseStream {
    /**
     * Check the given value for a symbol encoding a NULL or UNDEFINED value in
     * the CBOR stream.
     *
     * @static
     * @param {any} val The value to check.
     * @returns {any} The corrected value.
     * @throws {Error} Nothing was found.
     * @example
     * myDecoder.on('data', val => {
     *   val = Decoder.nullcheck(val)
     *   // ...
     * })
     */
    static nullcheck(val: any): any;
    /**
     * Decode the first CBOR item in the input.  This will error if there are
     * more bytes left over at the end (if options.extendedResults is not true),
     * and optionally if there were no valid CBOR bytes in the input.  Emits the
     * {Decoder.NOT_FOUND} Symbol in the callback if no data was found and the
     * `required` option is false.
     *
     * @static
     * @param {BufferLike} input What to parse?
     * @param {DecoderOptions|decodeCallback|string} [options={}] Options, the
     *   callback, or input encoding.
     * @param {decodeCallback} [cb] Callback.
     * @returns {Promise<ExtendedResults|any>} Returned even if callback is
     *   specified.
     * @throws {TypeError} No input provided.
     */
    static decodeFirst(input: BufferLike, options?: DecoderOptions | decodeCallback | string, cb?: decodeCallback): Promise<ExtendedResults | any>;
    /**
     * @callback decodeAllCallback
     * @param {Error} error If one was generated.
     * @param {Array<ExtendedResults>|Array<any>} value All of the decoded
     *   values, wrapped in an Array.
     */
    /**
     * Decode all of the CBOR items in the input.  This will error if there are
     * more bytes left over at the end.
     *
     * @static
     * @param {BufferLike} input What to parse?
     * @param {DecoderOptions|decodeAllCallback|string} [options={}]
     *   Decoding options, the callback, or the input encoding.
     * @param {decodeAllCallback} [cb] Callback.
     * @returns {Promise<Array<ExtendedResults>|Array<any>>} Even if callback
     *   is specified.
     * @throws {TypeError} No input specified.
     */
    static decodeAll(input: BufferLike, options?: string | DecoderOptions | ((error: Error, value: Array<ExtendedResults> | Array<any>) => any), cb?: (error: Error, value: Array<ExtendedResults> | Array<any>) => any): Promise<Array<ExtendedResults> | Array<any>>;
    /**
     * Create a parsing stream.
     *
     * @param {DecoderOptions} [options={}] Options.
     */
    constructor(options?: DecoderOptions);
    running: boolean;
    max_depth: number;
    tags: {
      [x: string]: Tagged.TagFunction;
    };
    preferWeb: boolean;
    extendedResults: boolean;
    required: boolean;
    preventDuplicateKeys: boolean;
    valueBytes: NoFilter;
    /**
     * Stop processing.
     */
    close(): void;
    /**
     * Only called if extendedResults is true.
     *
     * @ignore
     */
    _onRead(data: any): void;
  }

  /**
   * @typedef EncodingOptions
   * @property {any[]|object} [genTypes=[]] Array of pairs of
   *   `type`, `function(Encoder)` for semantic types to be encoded.  Not
   *   needed for Array, Date, Buffer, Map, RegExp, Set, or URL.
   *   If an object, the keys are the constructor names for the types.
   * @property {boolean} [canonical=false] Should the output be
   *   canonicalized.
   * @property {boolean|WeakSet} [detectLoops=false] Should object loops
   *   be detected?  This will currently add memory to track every part of the
   *   object being encoded in a WeakSet.  Do not encode
   *   the same object twice on the same encoder, without calling
   *   `removeLoopDetectors` in between, which will clear the WeakSet.
   *   You may pass in your own WeakSet to be used; this is useful in some
   *   recursive scenarios.
   * @property {("number"|"float"|"int"|"string")} [dateType="number"] -
   *   how should dates be encoded?  "number" means float or int, if no
   *   fractional seconds.
   * @property {any} [encodeUndefined=undefined] How should an
   *   "undefined" in the input be encoded.  By default, just encode a CBOR
   *   undefined.  If this is a buffer, use those bytes without re-encoding
   *   them.  If this is a function, the function will be called (which is a
   *   good time to throw an exception, if that's what you want), and the
   *   return value will be used according to these rules.  Anything else will
   *   be encoded as CBOR.
   * @property {boolean} [disallowUndefinedKeys=false] Should
   *   "undefined" be disallowed as a key in a Map that is serialized?  If
   *   this is true, encode(new Map([[undefined, 1]])) will throw an
   *   exception.  Note that it is impossible to get a key of undefined in a
   *   normal JS object.
   * @property {boolean} [collapseBigIntegers=false] Should integers
   *   that come in as ECMAscript bigint's be encoded
   *   as normal CBOR integers if they fit, discarding type information?
   * @property {number} [chunkSize=4096] Number of characters or bytes
   *   for each chunk, if obj is a string or Buffer, when indefinite encoding.
   * @property {boolean} [omitUndefinedProperties=false] When encoding
   *   objects or Maps, do not include a key if its corresponding value is
   *   `undefined`.
   */
  /**
   * Transform JavaScript values into CBOR bytes.  The `Writable` side of
   * the stream is in object mode.
   *
   * @extends stream.Transform
   */
  export class Encoder extends stream.Transform {
    /**
     * Encode an array and all of its elements.
     *
     * @param {Encoder} gen Encoder to use.
     * @param {any[]} obj Array to encode.
     * @param {object} [opts] Options.
     * @param {boolean} [opts.indefinite=false] Use indefinite encoding?
     * @returns {boolean} True on success.
     */
    static pushArray(gen: Encoder, obj: any[], opts?: {
      indefinite?: boolean;
    }): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {Date} obj Date to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushDate(gen: Encoder, obj: Date): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {Buffer} obj Buffer to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushBuffer(gen: Encoder, obj: Buffer): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {NoFilter} obj Buffer to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushNoFilter(gen: Encoder, obj: NoFilter): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {RegExp} obj RegExp to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushRegexp(gen: Encoder, obj: RegExp): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {Set} obj Set to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushSet(gen: Encoder, obj: Set<any>): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {URL} obj URL to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushURL(gen: Encoder, obj: URL): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {object} obj Boxed String, Number, or Boolean object to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushBoxed(gen: Encoder, obj: object): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {Map} obj Map to encode.
     * @returns {boolean} True on success.
     * @throws {Error} Map key that is undefined.
     * @ignore
     */
    static _pushMap(gen: Encoder, obj: Map<any, any>, opts: any): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param {NodeJS.TypedArray} obj Array to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushTypedArray(gen: Encoder, obj: NodeJS.TypedArray): boolean;

    /**
     * @param {Encoder} gen Encoder.
     * @param { ArrayBuffer } obj Array to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    static _pushArrayBuffer(gen: Encoder, obj: ArrayBuffer): boolean;

    /**
     * Encode the given object with indefinite length.  There are apparently
     * some (IMO) broken implementations of poorly-specified protocols that
     * REQUIRE indefinite-encoding.  See the example for how to add this as an
     * `encodeCBOR` function to an object or class to get indefinite encoding.
     *
     * @param {Encoder} gen The encoder to use.
     * @param {string|Buffer|Array|Map|object} [obj] The object to encode.  If
     *   null, use "this" instead.
     * @param {EncodingOptions} [options={}] Options for encoding.
     * @returns {boolean} True on success.
     * @throws {Error} No object to encode or invalid indefinite encoding.
     * @example <caption>Force indefinite encoding:</caption>
     * const o = {
     *   a: true,
     *   encodeCBOR: cbor.Encoder.encodeIndefinite,
     * }
     * const m = []
     * m.encodeCBOR = cbor.Encoder.encodeIndefinite
     * cbor.encodeOne([o, m])
     */
    static encodeIndefinite(gen: Encoder, obj?: string | Buffer | any[] | Map<any, any> | object, options?: EncodingOptions): boolean;

    /**
     * Encode one or more JavaScript objects, and return a Buffer containing the
     * CBOR bytes.
     *
     * @param {...any} objs The objects to encode.
     * @returns {Buffer} The encoded objects.
     */
    static encode(...objs: any[]): Buffer;

    /**
     * Encode one or more JavaScript objects canonically (slower!), and return
     * a Buffer containing the CBOR bytes.
     *
     * @param {...any} objs The objects to encode.
     * @returns {Buffer} The encoded objects.
     */
    static encodeCanonical(...objs: any[]): Buffer;

    /**
     * Encode one JavaScript object using the given options.
     *
     * @static
     * @param {any} obj The object to encode.
     * @param {EncodingOptions} [options={}] Passed to the Encoder constructor.
     * @returns {Buffer} The encoded objects.
     */
    static encodeOne(obj: any, options?: EncodingOptions): Buffer;

    static set SEMANTIC_TYPES(arg: {
      [x: string]: EncodeFunction;
    });

    /**
     * The currently supported set of semantic types.  May be modified by plugins.
     *
     * @type {SemanticMap}
     */
    static get SEMANTIC_TYPES(): {
      [x: string]: EncodeFunction;
    };

    /**
     * Reset the supported semantic types to the original set, before any
     * plugins modified the list.
     */
    static reset(): void;

    /**
     * Creates an instance of Encoder.
     *
     * @param {EncodingOptions} [options={}] Options for the encoder.
     */
    constructor(options?: EncodingOptions);
    canonical: boolean;
    encodeUndefined: any;
    disallowUndefinedKeys: boolean;
    dateType: "string" | "number" | "float" | "int";
    collapseBigIntegers: boolean;
    /** @type {WeakSet?} */
    detectLoops: WeakSet<any> | null;
    omitUndefinedProperties: boolean;
    semanticTypes: {
      [x: string]: EncodeFunction;
    };

    /**
     * @param {number} val Number(0-255) to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushUInt8(val: number): boolean;
    /**
     * @param {number} val Number(0-65535) to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushUInt16BE(val: number): boolean;
    /**
     * @param {number} val Number(0..2**32-1) to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushUInt32BE(val: number): boolean;
    /**
     * @param {number} val Number to encode as 4-byte float.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushFloatBE(val: number): boolean;
    /**
     * @param {number} val Number to encode as 8-byte double.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushDoubleBE(val: number): boolean;
    /**
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushNaN(): boolean;
    /**
     * @param {number} obj Positive or negative infinity.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushInfinity(obj: number): boolean;
    /**
     * Choose the best float representation for a number and encode it.
     *
     * @param {number} obj A number that is known to be not-integer, but not
     *    how many bytes of precision it needs.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushFloat(obj: number): boolean;
    /**
     * Choose the best integer representation for a postive number and encode
     * it.  If the number is over MAX_SAFE_INTEGER, fall back on float (but I
     * don't remember why).
     *
     * @param {number} obj A positive number that is known to be an integer,
     *    but not how many bytes of precision it needs.
     * @param {number} mt The Major Type number to combine with the integer.
     *    Not yet shifted.
     * @param {number} [orig] The number before it was transformed to positive.
     *    If the mt is NEG_INT, and the positive number is over MAX_SAFE_INT,
     *    then we'll encode this as a float rather than making the number
     *    negative again and losing precision.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushInt(obj: number, mt: number, orig?: number): boolean;
    /**
     * Choose the best integer representation for a number and encode it.
     *
     * @param {number} obj A number that is known to be an integer,
     *    but not how many bytes of precision it needs.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushIntNum(obj: number): boolean;
    /**
     * @param {number} obj Plain JS number to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushNumber(obj: number): boolean;
    /**
     * @param {string} obj String to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushString(obj: string): boolean;
    /**
     * @param {boolean} obj Bool to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushBoolean(obj: boolean): boolean;
    /**
     * @param {undefined} obj Ignored.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushUndefined(obj: undefined): boolean;
    /**
     * @param {null} obj Ignored.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushNull(obj: null): boolean;
    /**
     * @param {number} tag Tag number to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushTag(tag: number): boolean;
    /**
     * @param {bigint} obj BigInt to encode.
     * @returns {boolean} True on success.
     * @ignore
     */
    _pushJSBigint(obj: bigint): boolean;
    /**
     * @param {object} obj Object to encode.
     * @returns {boolean} True on success.
     * @throws {Error} Loop detected.
     * @ignore
     */
    _pushObject(obj: object, opts: any): boolean;
    /**
     * @param {any[]} objs Array of supported things.
     * @returns {Buffer} Concatenation of encodings for the supported things.
     * @ignore
     */
    _encodeAll(objs: any[]): Buffer;
    /**
     * Add an encoding function to the list of supported semantic types.  This
     * is useful for objects for which you can't add an encodeCBOR method.
     *
     * @param {string|Function} type The type to encode.
     * @param {EncodeFunction} fun The encoder to use.
     * @returns {EncodeFunction?} The previous encoder or undefined if there
     *   wasn't one.
     * @throws {TypeError} Invalid function.
     */
    addSemanticType(type: string | Function, fun: EncodeFunction): EncodeFunction | null;
    /**
     * Push any supported type onto the encoded stream.
     *
     * @param {any} obj The thing to encode.
     * @returns {boolean} True on success.
     * @throws {TypeError} Unknown type for obj.
     */
    pushAny(obj: any): boolean;
    /**
     * Remove the loop detector WeakSet for this Encoder.
     *
     * @returns {boolean} True when the Encoder was reset, else false.
     */
    removeLoopDetectors(): boolean;
  }

  /**
   * Generate the CBOR for a value.  If you are using this, you'll either need
   * to call {@link Encoder.write } with a Buffer, or look into the internals of
   * Encoder to reuse existing non-documented behavior.
   */
  export type EncodeFunction = (enc: Encoder, val: any) => boolean;

  type EncodingOptions = {
    /**
     * Array of pairs of
     * `type`, `function(Encoder)` for semantic types to be encoded.  Not
     * needed for Array, Date, Buffer, Map, RegExp, Set, or URL.
     * If an object, the keys are the constructor names for the types.
     */
    genTypes?: any[] | object;
    /**
     * Should the output be
     * canonicalized.
     */
    canonical?: boolean;
    /**
     * Should object loops
     * be detected?  This will currently add memory to track every part of the
     * object being encoded in a WeakSet.  Do not encode
     * the same object twice on the same encoder, without calling
     * `removeLoopDetectors` in between, which will clear the WeakSet.
     * You may pass in your own WeakSet to be used; this is useful in some
     * recursive scenarios.
     */
    detectLoops?: boolean | WeakSet<any>;
    /**
     * -
     * how should dates be encoded?  "number" means float or int, if no
     * fractional seconds.
     */
    dateType?: ("number" | "float" | "int" | "string");
    /**
     * How should an
     * "undefined" in the input be encoded.  By default, just encode a CBOR
     * undefined.  If this is a buffer, use those bytes without re-encoding
     * them.  If this is a function, the function will be called (which is a
     * good time to throw an exception, if that's what you want), and the
     * return value will be used according to these rules.  Anything else will
     * be encoded as CBOR.
     */
    encodeUndefined?: any;
    /**
     * Should
     * "undefined" be disallowed as a key in a Map that is serialized?  If
     * this is true, encode(new Map([[undefined, 1]])) will throw an
     * exception.  Note that it is impossible to get a key of undefined in a
     * normal JS object.
     */
    disallowUndefinedKeys?: boolean;
    /**
     * Should integers
     * that come in as ECMAscript bigint's be encoded
     * as normal CBOR integers if they fit, discarding type information?
     */
    collapseBigIntegers?: boolean;
    /**
     * Number of characters or bytes
     * for each chunk, if obj is a string or Buffer, when indefinite encoding.
     */
    chunkSize?: number;
    /**
     * When encoding
     * objects or Maps, do not include a key if its corresponding value is
     * `undefined`.
     */
    omitUndefinedProperties?: boolean;
  };

  /**
   * A mapping from tag number to a tag decoding function.
   */
  type SemanticMap = {
    [x: string]: EncodeFunction;
  };
}
