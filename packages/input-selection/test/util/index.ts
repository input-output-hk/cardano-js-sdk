import { Cardano } from '@cardano-sdk/core';
import { ChangeAddressResolver, Selection } from '../../src';

export * from './properties';
export * from './tests';
export * as SelectionConstraints from './selectionConstraints';

export const asAssetId = (x: string): Cardano.AssetId => x as unknown as Cardano.AssetId;
export const asPaymentAddress = (x: string): Cardano.PaymentAddress => x as unknown as Cardano.PaymentAddress;
export const asTokenMap = (elements: Iterable<[Cardano.AssetId, bigint]>) => new Map<Cardano.AssetId, bigint>(elements);

export const mockChangeAddress =
  'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9' as Cardano.PaymentAddress;

export class MockChangeAddressResolver implements ChangeAddressResolver {
  async resolve(selection: Selection) {
    return selection.change.map((txOut) => ({
      ...txOut,
      address: mockChangeAddress
    }));
  }
}

/**
 * Coalesce all coin values from all outputs in the change set that belongs to the given address.
 *
 * @param address The address to query.
 * @param change The change set.
 */
export const getCoinValueForAddress = (address: string, change: Array<Cardano.TxOut>) =>
  change
    .filter((out) => out.address === address)
    .map((out) => out.value.coins)
    .reduce((cur, prev) => cur + prev, 0n);
