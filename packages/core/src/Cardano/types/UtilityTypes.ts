import FractionJs from 'fraction.js';

export interface Fraction {
  numerator: number;
  denominator: number;
}

const toFractionJs = (value: number | Fraction): FractionJs => {
  if (typeof value === 'number') {
    return new FractionJs(value);
  }
  const { numerator, denominator } = value;
  return new FractionJs(numerator, denominator);
};

export const FractionUtils = {
  toFraction(value: number | Fraction): Fraction {
    const fractionJs = toFractionJs(value);
    const { n: numerator, d: denominator } = fractionJs;
    return { denominator, numerator };
  },
  toNumber(value: number | Fraction): number {
    const fractionJs = toFractionJs(value);
    return fractionJs.valueOf();
  }
};
