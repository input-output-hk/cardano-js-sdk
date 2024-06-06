import { of } from 'rxjs';
import { passthrough } from '../src/index.js';

describe('passthrough', () => {
  it('returns source observable', () => {
    const source$ = of(null);
    expect(passthrough()(source$)).toBe(source$);
  });
});
