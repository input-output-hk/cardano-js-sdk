import { ManagedFreeableScope, usingAutoFree } from '../src/index.js';
import type { Freeable } from '../src/index.js';

class FreeableEntity implements Freeable {
  constructor(public id: number) {}
  public getId(): number {
    return this.id;
  }
  public free() {
    void 0;
  }
}

describe('freeable', () => {
  describe('ManagedFreeableScope', () => {
    it('manage returns undefined if argument passed is undefined', () => {
      const scope = new ManagedFreeableScope();
      const freeable = undefined;
      const one = scope.manage(freeable);
      expect(one).toBeUndefined();
    });
  });
  describe('usingAutoFree', () => {
    it('calls the object free method after executing callback', () => {
      const entity = new FreeableEntity(1);
      const spy = jest.spyOn(entity, 'free');
      usingAutoFree((scope) => {
        const one = scope.manage(entity);
        expect(one.getId()).toBe(1);
      });
      expect(spy).toHaveBeenCalledTimes(1);
    });

    it('can return a value', () => {
      const entity = new FreeableEntity(1);
      const spy = jest.spyOn(entity, 'free');
      const id = usingAutoFree((scope) => {
        const one = scope.manage(entity);
        return one.getId();
      });
      expect(id).toBe(1);
      expect(spy).toHaveBeenCalledTimes(1);
    });

    it('can handle multiple objects', () => {
      const firstEntity = new FreeableEntity(1);
      const secondEntity = new FreeableEntity(2);
      const firstSpy = jest.spyOn(firstEntity, 'free');
      const secondSpy = jest.spyOn(secondEntity, 'free');
      usingAutoFree((scope) => {
        const one = scope.manage(firstEntity);
        const two = scope.manage(secondEntity);
        expect(one.getId()).toBe(1);
        expect(two.getId()).toBe(2);
      });
      expect(firstSpy).toHaveBeenCalledTimes(1);
      expect(secondSpy).toHaveBeenCalledTimes(1);
    });

    describe('with callback that returns a Promise', () => {
      let resolve: Function;
      let reject: Function;
      let freeable: FreeableEntity;
      let freeableSpy: jest.SpyInstance;
      let result: Promise<unknown>;

      beforeEach(() => {
        freeable = new FreeableEntity(1);
        freeableSpy = jest.spyOn(freeable, 'free');
        result = usingAutoFree((scope) => {
          scope.manage(freeable);
          return new Promise((_resolve, _reject) => {
            resolve = _resolve;
            reject = _reject;
          });
        });
      });

      it('returns promise and frees scope after it resolves', async () => {
        expect(freeableSpy).not.toBeCalled();
        const returnValue = 'result';
        resolve(returnValue);
        await expect(result).resolves.toBe(returnValue);
        expect(freeableSpy).toBeCalledTimes(1);
      });

      it('returns promise and frees scope after promise rejects', async () => {
        expect.assertions(3);
        expect(freeableSpy).not.toBeCalled();
        const rejectedWith = 'error';
        reject(rejectedWith);
        try {
          await result;
        } catch (error) {
          expect(freeableSpy).toBeCalledTimes(1);
          expect(error).toBe(rejectedWith);
        }
      });
    });
  });
});
