export const isValidHandle = (handle: string) => {
  const pattern = /^[\w,.\-]*@{0,1}[\w,.\-]+$/;
  return pattern.test(handle);
};
