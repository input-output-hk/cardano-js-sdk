import * as Crypto from '@cardano-sdk/crypto';
import { AccountKeyDerivationPath, AddressType, Bip32Account, InMemoryKeyAgent, KeyRole, util } from '../src';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { dummyLogger } from 'ts-log';

describe('Bip32Account', () => {
  const accountIndex = 1;
  const testnetChainId = Cardano.ChainIds.Preview;
  let testnetAccount: Bip32Account;
  let mainnetAccount: Bip32Account;

  beforeEach(async () => {
    const mnemonicWords = util.generateMnemonicWords();
    const getPassphrase = jest.fn().mockResolvedValue(Buffer.from('password'));
    const keyAgentDependencies = { bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(), logger: dummyLogger };
    const testnetKeyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        accountIndex,
        chainId: testnetChainId,
        getPassphrase,
        mnemonicWords
      },
      keyAgentDependencies
    );
    const mainnetKeyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        accountIndex,
        chainId: Cardano.ChainIds.Mainnet,
        getPassphrase,
        mnemonicWords
      },
      keyAgentDependencies
    );

    const dependencies = await Bip32Account.createDefaultDependencies();
    testnetAccount = new Bip32Account(testnetKeyAgent.serializableData, dependencies);
    mainnetAccount = new Bip32Account(mainnetKeyAgent.serializableData, dependencies);
  });

  it('derivePublicKey resolves with ed25519 public key', async () => {
    const derivedKeys = [
      await testnetAccount.derivePublicKey({ index: 0, role: KeyRole.DRep }),
      await testnetAccount.derivePublicKey({ index: 1, role: KeyRole.External }),
      await mainnetAccount.derivePublicKey({ index: 2, role: KeyRole.Internal }),
      await mainnetAccount.derivePublicKey({ index: 3, role: KeyRole.Stake })
    ];
    for (const hexKey of derivedKeys) {
      expect(typeof hexKey).toBe('string');
      expect(hexKey).toHaveLength(64);
      expect(() => HexBlob(hexKey)).not.toThrow();
    }
  });

  describe('deriveAddress', () => {
    it('derives valid mainnet address', async () => {
      const externalAddress = await mainnetAccount.deriveAddress({ index: 1, type: AddressType.External }, 1);
      expect(externalAddress.address.startsWith('addr')).toBe(true);
      expect(externalAddress.address.startsWith('addr_test')).toBe(false);
      expect(externalAddress.rewardAccount.startsWith('stake')).toBe(true);
      expect(externalAddress.rewardAccount.startsWith('stake_test')).toBe(false);
    });

    it('resolves with GroupedAddress object', async () => {
      const stakeKeyDerivationIndex = 1;
      const paymentKeyDerivationPath = { index: 0, type: AddressType.Internal };
      const internalAddress = await testnetAccount.deriveAddress(paymentKeyDerivationPath, stakeKeyDerivationIndex);
      expect(internalAddress.address.startsWith('addr_test')).toBe(true);
      expect(internalAddress.accountIndex).toBe(accountIndex);
      expect(internalAddress.index).toBe(paymentKeyDerivationPath.index);
      expect(internalAddress.type).toBe(paymentKeyDerivationPath.type);
      expect(internalAddress.networkId).toBe(testnetChainId.networkId);
      expect(internalAddress.rewardAccount.startsWith('stake_test')).toBe(true);
      expect(internalAddress.stakeKeyDerivationPath).toEqual({ index: stakeKeyDerivationIndex, role: 2 });
    });

    it('derives the address with stake key of the given index', async () => {
      const keyMap = new Map<number, string>([
        [0, '0000000000000000000000000000000000000000000000000000000000000000'],
        [1, '1111111111111111111111111111111111111111111111111111111111111111'],
        [2, '2222222222222222222222222222222222222222222222222222222222222222'],
        [3, '3333333333333333333333333333333333333333333333333333333333333333'],
        [4, '4444444444444444444444444444444444444444444444444444444444444444']
      ]);

      testnetAccount.derivePublicKey = jest.fn(async (x: AccountKeyDerivationPath) =>
        Crypto.Ed25519PublicKeyHex(keyMap.get(x.index)!)
      );

      const index = 0;
      const type = AddressType.External;
      const addresses = [
        await testnetAccount.deriveAddress({ index, type }, 0),
        await testnetAccount.deriveAddress({ index, type }, 1),
        await testnetAccount.deriveAddress({ index, type }, 2),
        await testnetAccount.deriveAddress({ index, type }, 3)
      ];

      expect(addresses[0].stakeKeyDerivationPath).toEqual({ index: 0, role: KeyRole.Stake });
      expect(addresses[0].rewardAccount).toEqual('stake_test1uruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhc8cxn3h');
      expect(addresses[0].address).toEqual(
        'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhlemj3p5myzdmy2edx089wtcfp4rymmlejkpvng82utg90s4cadlm'
      );

      expect(addresses[1].stakeKeyDerivationPath).toEqual({ index: 1, role: KeyRole.Stake });
      expect(addresses[1].rewardAccount).toEqual('stake_test1uzx0qqs06evy77cnpk6u5q3fc50exjpp5t4s0swl2ykc4jsmh8tej');
      expect(addresses[1].address).toEqual(
        'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhuv7qpql4jcfaa3xrd4egpzn3gljdyzrghtqlqa75fd3t9qqnvgeq'
      );

      expect(addresses[2].stakeKeyDerivationPath).toEqual({ index: 2, role: KeyRole.Stake });
      expect(addresses[2].rewardAccount).toEqual('stake_test1uqcnxxxatdgmqdmz0rhg72kn3n0egek5s0nqcvfy9ztyltc9cpuz4');
      expect(addresses[2].address).toEqual(
        'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhe3xvvd6k63kqmky78w3u4d8rxlj3ndfqlxpscjg2ykf7hs8qc48l'
      );

      expect(addresses[3].stakeKeyDerivationPath).toEqual({ index: 3, role: KeyRole.Stake });
      expect(addresses[3].rewardAccount).toEqual('stake_test1urj8hvwxxz0t6pnfttj9ne5leu74shjlg83a8kxww9ft2fqtdhssu');
      expect(addresses[3].address).toEqual(
        'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhly0wcuvvy7h5rxjkhyt8nflneatp097s0r60vvuu2jk5jq73efq0'
      );
    });
  });
});
