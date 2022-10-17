import { Freeable, ManagedFreeableScope, usingAutoFree } from '../src';

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
  });
});
