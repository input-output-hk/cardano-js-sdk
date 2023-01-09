import { of } from 'rxjs';
import { passthrough } from '../src';

describe('passthrough', () => {
  it('returns source observable', () => {
    const source$ = of(null);
    expect(passthrough()(source$)).toBe(source$);
  });
});
