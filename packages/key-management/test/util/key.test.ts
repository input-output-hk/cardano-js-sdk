import { AddressType, GroupedAddress, KeyPurpose, KeyRole } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { paymentKeyPathFromGroupedAddress, stakeKeyPathFromGroupedAddress } from '../../src/util';

export const paymentAddress = Cardano.PaymentAddress(
  'addr1qxdtr6wjx3kr7jlrvrfzhrh8w44qx9krcxhvu3e79zr7497tpmpxjfyhk3vwg6qjezjmlg5nr5dzm9j6nxyns28vsy8stu5lh6'
);

const rewardKey = 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr';

export const rewardAccount = Cardano.RewardAccount(rewardKey);

const stakeKeyDerivationPath = {
  index: 0,
  purpose: KeyPurpose.STANDARD,
  role: KeyRole.Stake
};

const knownAddress: GroupedAddress = {
  accountIndex: 0,
  address: paymentAddress,
  index: 0,
  networkId: Cardano.NetworkId.Testnet,
  rewardAccount,
  stakeKeyDerivationPath,
  type: AddressType.Internal
};

const knownAddressKeyPath = [2_147_485_500, 2_147_485_463, 2_147_483_648, 1, 0];
const knownAddressStakeKeyPath = [2_147_485_500, 2_147_485_463, 2_147_483_648, 2, 0];

describe('key utils', () => {
  describe('paymentKeyPathFromGroupedAddress', () => {
    it('returns a hardened BIP32 payment key path', () => {
      expect(paymentKeyPathFromGroupedAddress(knownAddress)).toEqual(knownAddressKeyPath);
    });
  });
  describe('stakeKeyPathFromGroupedAddress', () => {
    it('returns null when given an undefined stakeKeyDerivationPath', async () => {
      const knownAddressClone = { ...knownAddress };
      delete knownAddressClone.stakeKeyDerivationPath;
      expect(stakeKeyPathFromGroupedAddress(knownAddressClone)).toEqual(null);
    });
    it('returns a hardened BIP32 stake key path', () => {
      expect(stakeKeyPathFromGroupedAddress(knownAddress)).toEqual(knownAddressStakeKeyPath);
    });
  });
});
