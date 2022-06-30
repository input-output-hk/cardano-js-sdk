import * as core from '@cardano-sdk/core';

export type Tip = Pick<core.Cardano.Tip, 'slot' | 'blockNo'>;

// Review: this is a little awkward - it would be cleaner to instead do:
// `core.NetworkInfoProvider extends WC.NetworkInfoProvider`
// However, then we would have to move both typesets to `core` package and I'm not sure it's a good idea.
export interface NetworkInfoProvider extends Omit<core.NetworkInfoProvider, 'ledgerTip'> {
  ledgerTip(): Promise<Tip>;
}
