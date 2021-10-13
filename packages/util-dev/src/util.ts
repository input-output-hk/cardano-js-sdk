export const flushPromises = (setImmediate = global.setImmediate) =>
  new Promise((resolve) => setImmediate(resolve, void 0));
