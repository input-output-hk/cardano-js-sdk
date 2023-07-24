import * as fs from 'fs';
import path from 'path';

export enum Paths {
  StakeDistribution = 'stake-distribution.csv',
  WalletUtxos = 'utxos'
}

/**
 * Functions to create/delete and read/write files and folders.
 */
export const Files = {
  /**
   * This method is intended to concatenate individual strings into a single string that represents a file path.
   *
   * @param paths An array of parts of the path.
   */
  combine(paths: Array<string>): string {
    return path.join(...paths);
  },
  /**
   * Creates a new folder if it doesn't exist.
   *
   * @param dir The directory to be created.
   * @param recursive set to true if more than one nested directory is present in the path.
   */
  createFolder(dir: string, recursive?: boolean) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive });
    }
  },
  /**
   * Deletes a file or directory.
   *
   * @param filePath the path of a file or folder.
   * @param recursive set to true if you want to perform a recursive delete.
   */
  delete(filePath: string, recursive?: boolean) {
    if (!fs.existsSync(filePath)) {
      return;
    }

    fs.rmSync(filePath, { recursive });
  },
  /**
   * Writes content to a file.
   *
   * @param filePath The path of the file.
   */
  readFile(filePath: string): Uint8Array {
    if (!fs.existsSync(filePath)) {
      throw new Error('File not found.');
    }

    return fs.readFileSync(filePath);
  },

  /**
   * Writes content to a file.
   *
   * @param filePath The path of the file.
   * @param content The content to be written.
   * @param append true if the content must be appended; otherwise; the original contents will be erased.
   */
  writeFile(filePath: string, content: string | Uint8Array, append?: boolean) {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      this.createFolder(dir, true);
    }

    return append ? fs.appendFileSync(filePath, content) : fs.writeFileSync(filePath, content);
  }
};
