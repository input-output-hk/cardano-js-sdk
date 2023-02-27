// Source: https://github.com/Microsoft/Typescript/issues/202#issuecomment-811246768
export type OpaqueString<T extends string> = string & {
  /** This helps typescript distinguish different opaque string types. */
  __opaqueString: T;
};

export type OpaqueNumber<T extends string> = number & {
  __opaqueNumber: T;
};
