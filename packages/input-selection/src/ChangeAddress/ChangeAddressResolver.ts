import type { Cardano } from '@cardano-sdk/core';
import type { Selection } from '../../src/index.js';

/**
 * Resolves the addresses to be used for change outputs.
 *
 * The resolver takes the selection results from the input selection algorithm and
 * updates its change outputs to use the resolved addresses.
 */
export interface ChangeAddressResolver {
  /**
   * Resolves the change addresses for the change outputs.
   *
   * @param selection The inputs selection result.
   * @returns The updated change outputs.
   */
  resolve(selection: Selection): Promise<Array<Cardano.TxOut>>;
}
