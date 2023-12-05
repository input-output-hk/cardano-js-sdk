import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';

export interface AddressesModel {
  tx_count: number;
  address: string;
  stake_address: string;
}

export const mapToGroupedAddress = (addrModel: AddressesModel): GroupedAddress => ({
  accountIndex: 0,
  address: Cardano.PaymentAddress(addrModel.address),
  index: 0,
  networkId: addrModel.address.startsWith('addr_test') ? Cardano.NetworkId.Testnet : Cardano.NetworkId.Mainnet,
  rewardAccount: Cardano.RewardAccount(addrModel.stake_address),
  type: AddressType.External
});
