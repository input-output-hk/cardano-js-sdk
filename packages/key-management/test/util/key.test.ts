import { AddressType, GroupedAddress, KeyPurpose, KeyRole } from '../../src';
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

// CIP-1852: m / 1852' / 1815' / account' / role / index  (hardened = n + 0x8000_0000)
const HARDENED_PURPOSE_1852 = 2_147_485_500;
const HARDENED_PURPOSE_1854 = 2_147_485_502;
const HARDENED_COINTYPE_1815 = 2_147_485_463;
const HARDENED_ACCOUNT_0 = 2_147_483_648;
const HARDENED_ACCOUNT_5 = 2_147_483_653;

const knownAddressKeyPath = [HARDENED_PURPOSE_1852, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_0, KeyRole.Internal, 0];
const knownAddressStakeKeyPath = [HARDENED_PURPOSE_1852, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_0, KeyRole.Stake, 0];

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
      const path = accountKeyDerivationPathToBip32Path(0, { index: 0, role: KeyRole.External });
      expect(path).toEqual([HARDENED_PURPOSE_1852, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_0, KeyRole.External, 0]);
    });

    it('returns correct path for internal key role', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { index: 0, role: KeyRole.Internal });
      expect(path).toEqual([HARDENED_PURPOSE_1852, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_0, KeyRole.Internal, 0]);
    });

    it('returns correct path for stake key role', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { index: 0, role: KeyRole.Stake });
      expect(path).toEqual([HARDENED_PURPOSE_1852, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_0, KeyRole.Stake, 0]);
    });

    it('returns correct path for DRep key role', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { index: 0, role: KeyRole.DRep });
      expect(path).toEqual([HARDENED_PURPOSE_1852, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_0, KeyRole.DRep, 0]);
    });

    it('returns correct path with custom account index', () => {
      const path = accountKeyDerivationPathToBip32Path(5, { index: 3, role: KeyRole.External });
      expect(path).toEqual([HARDENED_PURPOSE_1852, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_5, KeyRole.External, 3]);
    });

    it('returns correct path with custom purpose', () => {
      const path = accountKeyDerivationPathToBip32Path(0, { index: 0, role: KeyRole.External }, KeyPurpose.MULTI_SIG);
      expect(path).toEqual([HARDENED_PURPOSE_1854, HARDENED_COINTYPE_1815, HARDENED_ACCOUNT_0, KeyRole.External, 0]);
    });
  });
});
