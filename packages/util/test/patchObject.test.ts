import { patchObject } from '../src/index.js';

describe('patchObject', () => {
  const object = {
    fnKey() {
      return this.key;
    },
    key: {}
  };

  it('preserves unpatched base object properties', () => {
    const patchedObject = patchObject(object, {});
    expect(patchedObject.key).toBe(object.key);
    expect(patchedObject.fnKey()).toBe(object.fnKey());
  });

  it('overrides patched properties', () => {
    const patchedKey = {};
    const patchedObject = patchObject(object, {
      key: patchedKey
    });
    expect(patchedObject.key).toBe(patchedKey);
    expect(patchedObject.key).not.toBe(object.key);
    expect(patchedObject.fnKey()).toBe(patchedKey);
  });
});
