import { Cardano, addressNetworkId, createRewardAccount } from '../../src';

describe('address', () => {
  describe('addressNetworkId', () => {
    it('parses testnet address', () => {
      expect(addressNetworkId(Cardano.Address('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t'))).toBe(
        Cardano.NetworkId.Testnet
      );
    });

    it('parses testnet reward account', () => {
      expect(
        addressNetworkId(Cardano.RewardAccount('stake_test1urpklgzqsh9yqz8pkyuxcw9dlszpe5flnxjtl55epla6ftqktdyfz'))
      ).toBe(Cardano.NetworkId.Testnet);
    });

    it('parses mainnet address', () => {
      expect(
        addressNetworkId(
          Cardano.Address(
            'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
          )
        )
      ).toBe(Cardano.NetworkId.Mainnet);
    });

    it('parses mainnet reward account', () => {
      expect(
        addressNetworkId(Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'))
      ).toBe(Cardano.NetworkId.Mainnet);
    });

    it('parses mainnet byron address', () => {
      expect(
        addressNetworkId(
          Cardano.Address(
            'DdzFFzCqrht4PWfBGtmrQz4x1GkZHYLVGbK7aaBkjWxujxzz3L5GxCgPiTsks5RjUr3yX9KvwKjNJBt7ZzPCmS3fUQrGeRvo9Y1YBQKQ'
          )
        )
      ).toBe(Cardano.NetworkId.Mainnet);
    });
  });

  describe('createRewardAccount', () => {
    const keyHash = Cardano.Ed25519KeyHash('f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80');

    it('creates a mainnet address', () => {
      const rewardAccount = createRewardAccount(keyHash, Cardano.NetworkId.Mainnet);
      expect(rewardAccount.startsWith('stake')).toBe(true);
      expect(rewardAccount.startsWith('stake_test')).toBe(false);
    });

    it('creates a testnet address', () => {
      const rewardAccount = createRewardAccount(keyHash, Cardano.NetworkId.Testnet);
      expect(rewardAccount.startsWith('stake_test')).toBe(true);
    });
  });
});
