import { AddressType, GroupedAddress, KeyRole } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import {
  accountKeyDerivationPathToBip32Path,
  paymentKeyPathFromGroupedAddress,
  stakeKeyPathFromGroupedAddress
} from '../../src/util';

export const paymentAddress = Cardano.PaymentAddress(
  'addr1qxdtr6wjx3kr7jlrvrfzhrh8w44qx9krcxhvu3e79zr7497tpmpxjfyhk3vwg6qjezjmlg5nr5dzm9j6nxyns28vsy8stu5lh6'
);

const rewardKey = 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr';

export const rewardAccount = Cardano.RewardAccount(rewardKey);

const stakeKeyDerivationPath = {
  index: 0,
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
  describe('accountKeyDerivationPathToBip32Path', () => {
    it('returns correct path with default purpose', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { role: KeyRole.External, index: 0 });
      expect(path).toEqual([2_147_485_500, 2_147_485_463, 2_147_483_648, 0, 0]);
    });

    it('returns correct path for internal key role', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { role: KeyRole.Internal, index: 0 });
      expect(path).toEqual([2_147_485_500, 2_147_485_463, 2_147_483_648, 1, 0]);
    });

    it('returns correct path for stake key role', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { role: KeyRole.Stake, index: 0 });
      expect(path).toEqual([2_147_485_500, 2_147_485_463, 2_147_483_648, 2, 0]);
    });

    it('returns correct path for DRep key role', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { role: KeyRole.DRep, index: 0 });
      expect(path).toEqual([2_147_485_500, 2_147_485_463, 2_147_483_648, 3, 0]);
    });

    it('returns correct path with custom account index', () => {
      const path = accountKeyDerivationPathToBip32Path(5, { role: KeyRole.External, index: 3 });
      expect(path).toEqual([2_147_485_500, 2_147_485_463, 2_147_483_653, 0, 3]);
    });

    it('returns correct path with custom purpose', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { role: KeyRole.External, index: 0 }, 1854);
      expect(path).toEqual([2_147_485_502, 2_147_485_463, 2_147_483_648, 0, 0]);
    });
  });
});
