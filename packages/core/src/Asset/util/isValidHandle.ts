export const isValidHandle = (handle: string) => {
  const pattern = /^[\w.@\-]+$/;
  return pattern.test(handle);
};
