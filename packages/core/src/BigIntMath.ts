export const BigIntMath = {
  abs(x: bigint): bigint {
    return x < 0n ? -x : x;
  },
  sum(arr: bigint[]): bigint {
    return arr.reduce((result, num) => result + num, 0n);
  }
};
