import { Cardano } from '@cardano-sdk/core';

export * from './properties';
export * from './tests';
export * as SelectionConstraints from './selectionConstraints';

export const asAssetId = (x: string): Cardano.AssetId => x as unknown as Cardano.AssetId;
export const asPaymentAddress = (x: string): Cardano.PaymentAddress => x as unknown as Cardano.PaymentAddress;
export const asTokenMap = (elements: Iterable<[Cardano.AssetId, bigint]>) => new Map<Cardano.AssetId, bigint>(elements);
