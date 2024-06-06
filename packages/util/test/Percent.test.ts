import { calcPercentages } from '../src/Percent.js';

describe('Percent', () => {
  it('single value is always 100%', () => {
    expect(calcPercentages([50])).toEqual([1]);
  });

  it('whole percentages add up to 100%', () => {
    expect(calcPercentages([50, 50])).toEqual([0.5, 0.5]);
  });

  it('floating point percentages', () => {
    expect(calcPercentages([403, 597])).toEqual([0.403, 0.597]);
    expect(calcPercentages([249, 249, 502])).toEqual([0.249, 0.249, 0.502]);
    expect(calcPercentages([255, 245, 265, 235])).toEqual([0.255, 0.245, 0.265, 0.235]);
  });

  it('percentages smaller than 1%', () => {
    expect(calcPercentages([5, 6, 1000 - 5 - 6])).toEqual([0.005, 0.006, 0.989]);
    expect(calcPercentages([0, 6, 1000 - 6])).toEqual([0, 0.006, 0.994]);
  });

  it('one part is zero, total is implicitly zero, so it takes 100% of the total', () => {
    expect(calcPercentages([0])).toEqual([1]);
  });

  it('multiple parts are zero, total is implicitly zero, percent is distributed evenly', () => {
    expect(calcPercentages([0, 0, 0, 0])).toEqual([0.25, 0.25, 0.25, 0.25]);
  });

  it('total is adjusted to equal at least as much as the sum of the parts', () => {
    expect(calcPercentages([80], 0)).toEqual([1]);
  });

  it('returns empty array if no parts are provided', () => {
    expect(calcPercentages([])).toEqual([]);
  });

  describe('parts sum less than 100%', () => {
    it('part are zero but total > zero translates to 0% for each part', () => {
      expect(calcPercentages([0, 0], 100)).toEqual([0, 0]);
    });

    it('single 80% value', () => {
      expect(calcPercentages([80], 100)).toEqual([0.8]);
    });

    it('two whole parts adding up to 80%', () => {
      expect(calcPercentages([40, 40], 100)).toEqual([0.4, 0.4]);
    });

    it('multiple rounded parts adding up to 80%', () => {
      expect(calcPercentages([205, 205, 215, 175], 1000)).toEqual([0.205, 0.205, 0.215, 0.175]);
    });
  });
});
