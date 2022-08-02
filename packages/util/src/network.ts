/* eslint-disable @typescript-eslint/no-explicit-any */

export const connectionErrorCodes = ['ENOTFOUND', 'ECONNREFUSED', 'ECONNRESET'];

export const isConnectionError = (error: any) => {
  if (
    (error?.code && connectionErrorCodes.includes(error.code)) ||
    (error?.message && connectionErrorCodes.some((err) => error.message.includes(err)))
  ) {
    return true;
  }
  return false;
};
