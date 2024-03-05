import {
  type AccountKeyDerivationPath,
  type AddressType,
  type GroupedAddress,
  KeyRole
} from '@cardano-sdk/key-management';
import { AddressDiscovery } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import { Cip30WalletDependencyBase } from './Cip30WalletDependencyBase';
import uniq from 'lodash/uniq';

export class Cip30AddressDiscovery extends Cip30WalletDependencyBase implements AddressDiscovery {
  #nextStubRewardAccountIndex = 0;
  readonly #stubStakeKeyDerivationPaths: Partial<Record<Cardano.RewardAccount, AccountKeyDerivationPath>> = {};
  #getStakeKeyDerivationPath(rewardAccount: Cardano.RewardAccount) {
    return (this.#stubStakeKeyDerivationPaths[rewardAccount] ||= {
      index: this.#nextStubRewardAccountIndex++,
      role: KeyRole.Stake
    });
  }

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
          stakeKeyDerivationPath: rewardAccount ? this.#getStakeKeyDerivationPath(rewardAccount) : undefined,
          type: 0 as AddressType
        };
      });
  }
}
