import { InvalidStateError } from '@cardano-sdk/util';
import type { Cardano } from '@cardano-sdk/core';
import type { ChangeAddressResolver, Selection } from '../index.js';
import type { GroupedAddress } from '@cardano-sdk/key-management';

export type GetAddresses = () => Promise<GroupedAddress[]>;

/** Default change address resolver. */
export class StaticChangeAddressResolver implements ChangeAddressResolver {
  readonly #getAddresses: GetAddresses;

  /**
   * Initializes a new instance of the StaticChangeAddressResolver.
   *
   * @param getAddresses A promise that will be resolved with the list of known addresses.
   */
  constructor(getAddresses: GetAddresses) {
    this.#getAddresses = getAddresses;
  }

  /** Always resolves to the same address. */
  async resolve(selection: Selection): Promise<Array<Cardano.TxOut>> {
    const groupedAddresses = await this.#getAddresses();

    if (groupedAddresses.length === 0) throw new InvalidStateError('The wallet has no known addresses.');

    const address = groupedAddresses[0].address;

    return selection.change.map((txOut) => ({ ...txOut, address }));
  }
}
