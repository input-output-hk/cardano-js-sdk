/* eslint-disable unicorn/better-regex */
// From ADA Handle Discord: slightly modified to not allow uppercase characters
const REGEX_HANDLE = new RegExp(/^[a-z0-9_.-]{1,15}$/);
// From ADA Handle Discord
const REGEX_SUB_HANDLE = new RegExp(/(?:^[a-z0-9_.-]{1,15}$)|(?:^(?!.{29})[a-z0-9_.-]+@[a-z0-9_.-]{1,15}$)/g);

/**
 * From ADA Handle FAQ:
 * Alphanumeric: [a-z][0-9]
 * Dash: -
 * Underscore: _
 * Period: .
 *
 * Since handles are case-insensitive, this function only allows lowercase.
 * Max 1-15 characters (or 3-31 characters for a subhandle)
 */
export const isValidHandle = (handle: string) => {
  // 'g' modifier makes it stateful
  REGEX_SUB_HANDLE.lastIndex = 0;
  return (
    REGEX_HANDLE.test(handle) ||
    REGEX_SUB_HANDLE.test(handle) ||
    // Pipe | in general is not valid, but an exception exists in mainnet
    handle === '0|0'
  );
};
