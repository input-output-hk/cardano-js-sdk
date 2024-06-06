import { EMPTY, from, lastValueFrom } from 'rxjs';
import { finalizeWithLatest } from '../src/index.js';

describe('finalizeWithLatest', () => {
  describe('source completes without emitting', () => {
    it('calls the callback function with "null"', async () => {
      const callback = jest.fn();
      EMPTY.pipe(finalizeWithLatest(callback)).subscribe();
      expect(callback).toBeCalledWith(null);
    });
  });

  describe('source emits some value(s)', () => {
    it('calls the callback function with last emitted value', async () => {
      const callback = jest.fn();
      await lastValueFrom(from([1, 2]).pipe(finalizeWithLatest(callback)));
      expect(callback).toBeCalledWith(2);
    });
  });
});
