export const StringUtils = {
  byteSize: (str: string) => new Blob([str]).size,
  /**
   * Creates an array of strings split into groups, limited to the specified size. If array can't be split evenly, the final chunk will be the remaining.
   *
   * @param str The string to chunk
   * @param maxBytes number of bytes to impose as a limit
   * @returns Array of string chunks
   */
  chunkByBytes: (str: string, maxBytes: number): string[] => {
    let chunkSize = 0;
    let chunkStart = 0;
    const result = [];

    for (let char = 0; char < str.length; char++) {
      const isEndOfArray = char === str.length - 1;
      const currentChunkSize = chunkSize + StringUtils.byteSize(str[char]);
      const nextCharSize = !isEndOfArray ? currentChunkSize + StringUtils.byteSize(str[char + 1]) : maxBytes + 1;
      const atLimit = currentChunkSize === maxBytes || nextCharSize > maxBytes || isEndOfArray;

      if (atLimit) {
        const chunk = str.slice(chunkStart, char + 1);
        result.push(chunk);
        chunkStart = char + 1;
        chunkSize = 0;
      } else {
        chunkSize = currentChunkSize;
      }
    }
    return result;
  }
};
