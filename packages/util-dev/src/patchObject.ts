export type ObjectPatches<T> = {
  [k in keyof T]?: T[k];
};

export const patchObject = <T extends object>(baseObject: T, patches: ObjectPatches<T>) =>
  new Proxy(baseObject, {
    get(target, p, receiver) {
      const value = p in patches ? patches[p as keyof T] : target[p as keyof T];
      return typeof value === 'function' ? value.bind(receiver) : value;
    }
  });
