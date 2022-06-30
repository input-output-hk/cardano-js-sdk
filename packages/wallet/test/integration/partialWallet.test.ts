import * as mocks from '../mocks';
import { BehaviorObservable } from '@cardano-sdk/util-rxjs';
import { Cardano } from '@cardano-sdk/core';
import {
  KeyManagement,
  ObservableWalletCore,
  SingleAddressWalletCore,
  SingleAddressWalletCoreDependencies,
  SingleAddressWalletProps,
  WC
} from '../../src';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';

// SingleAddressWallet generic parameters compatible with WC.* (WalletCore) types
// because they are either used internally or considered essential
interface CustomTip extends WC.Tip {
  // You can pick any extra fields (that are not available in WC.* types) that you need from SDK `core` package types.
  // Typically you would pick something from Cardano.Tip,
  // but the only property that is not available in WC.Tip is 'hash'
  // and we also want to demonstrate the absence of Cardano.* fields
  date: Cardano.Block['date'];
}

const stubCustomNetworkInfoProvider = {
  ...mocks.mockNetworkInfoProvider(),
  async ledgerTip() {
    return {
      blockNo: 123,
      date: new Date(),
      slot: 12_345
    };
  }
};

interface CustomWalletDependencies extends SingleAddressWalletCoreDependencies {
  readonly networkInfoProvider: typeof stubCustomNetworkInfoProvider;
}

class CustomSingleAdddressWallet extends SingleAddressWalletCore {
  readonly tip$: BehaviorObservable<CustomTip>;

  constructor(props: SingleAddressWalletProps, dependencies: CustomWalletDependencies) {
    super(props, dependencies);
  }
}

describe('integration/partialWallet', () => {
  it(`can create SingleAddressWallet with a custom provider
  that omits some field from Cardano.* type and includes an extra field not present in WC.* type`, async () => {
    const wallet = new CustomSingleAdddressWallet(
      {
        name: 'Custom'
      },
      {
        assetProvider: mocks.mockAssetProvider(),
        chainHistoryProvider: mocks.mockChainHistoryProvider(),
        keyAgent: KeyManagement.util.createAsyncKeyAgent(await mocks.testKeyAgent()),
        networkInfoProvider: stubCustomNetworkInfoProvider,
        rewardsProvider: mocks.mockRewardsProvider(),
        stakePoolProvider: createStubStakePoolProvider(),
        txSubmitProvider: mocks.mockTxSubmitProvider(),
        utxoProvider: mocks.mockUtxoProvider()
      }
    );
    // this compiles
    const asObservableWallet: ObservableWalletCore = wallet;
    asObservableWallet;

    const tip = await firstValueFrom(wallet.tip$);

    // this compiles
    tip.slot;
    tip.date;

    // this doesnt compile
    // tip.hash;

    wallet.shutdown();
  });
});
