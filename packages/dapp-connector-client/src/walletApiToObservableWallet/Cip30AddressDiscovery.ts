import { AddressDiscovery } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import { Cip30WalletDependencyBase } from './Cip30WalletDependencyBase';
import uniq from 'lodash/uniq';
import type { AddressType, GroupedAddress } from '@cardano-sdk/key-management';

export class Cip30AddressDiscovery extends Cip30WalletDependencyBase implements AddressDiscovery {
  async discover(): Promise<GroupedAddress[]> {
    const usedAddresses = await this.api.getUsedAddresses();
    const changeAddress = await this.api.getChangeAddress();
    const unusedAddresses = await this.api.getUnusedAddresses();
    return uniq([...usedAddresses, ...unusedAddresses, changeAddress])
      .map(Cardano.PaymentAddress)
      .map((bech32Address): GroupedAddress => {
        const address = Cardano.Address.fromBech32(bech32Address);
        const networkId = address.getNetworkId();
        const stakeCredential = address.asBase()?.getStakeCredential();
        const rewardAccount = stakeCredential ? Cardano.RewardAccount.fromCredential(stakeCredential, networkId) : null;
        return {
          address: bech32Address,
          networkId,
          // TODO: refactor ObservableWallet interface to not require Base/Grouped addresses
          rewardAccount: rewardAccount!,
          // TODO: refactor ObservableWallet interface to not include key info about the address
          // eslint-disable-next-line sort-keys-fix/sort-keys-fix
          accountIndex: 0,
          index: 0,
          type: 0 as AddressType
        };
      });
  }
}
