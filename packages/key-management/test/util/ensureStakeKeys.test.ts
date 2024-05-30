import { AddressType, Bip32Account, KeyPurpose, util } from '../../src';
import { Bip32PublicKeyHex } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { Logger, dummyLogger } from 'ts-log';

describe('ensureStakeKeys', () => {
  let bip32Account: Bip32Account;
  let logger: Logger;

  beforeEach(async () => {
    logger = dummyLogger;
    bip32Account = new Bip32Account({
      accountIndex: 0,
      chainId: Cardano.ChainIds.Preview,
      extendedAccountPublicKey: Bip32PublicKeyHex(
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      ),
      purpose: KeyPurpose.STANDARD
    });
  });

  it('can derive one stake key', async () => {
    const { rewardAccounts, newAddresses } = await util.ensureStakeKeys({
      bip32Account,
      count: 1,
      knownAddresses: [],
      logger
    });
    expect(newAddresses).toHaveLength(1);
    expect(rewardAccounts).toHaveLength(1);
  });

  it('does not create more stake keys when sufficient exist', async () => {
    const knownAddresses = [
      await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 0),
      await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 1)
    ];

    const { newAddresses, rewardAccounts } = await util.ensureStakeKeys({
      bip32Account,
      count: 2,
      knownAddresses,
      logger
    });

    expect(newAddresses).toHaveLength(0);
    expect(rewardAccounts).toHaveLength(2);
  });

  it('derives new stake keys filling any existing gaps', async () => {
    const knownAddresses = [
      await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 0),
      await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 2)
    ];

    const { newAddresses, rewardAccounts } = await util.ensureStakeKeys({
      bip32Account,
      count: 4,
      knownAddresses,
      logger
    });

    const stakeKeyIndices = newAddresses.map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index).sort();
    expect(stakeKeyIndices).toEqual([1, 3]);
    expect(rewardAccounts).toHaveLength(4);
  });

  it('generates new known addresses using the requested payment key index', async () => {
    const knownAddresses = [
      await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 0),
      await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 2)
    ];

    const { newAddresses, rewardAccounts } = await util.ensureStakeKeys({
      bip32Account,
      count: 4,
      knownAddresses,
      logger,
      paymentKeyIndex: 1
    });

    expect(newAddresses).toHaveLength(2);
    expect(newAddresses.every((acc) => acc.index === 1)).toBe(true);
    const newStakeKeyIndices = newAddresses.map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index);
    expect(newStakeKeyIndices).toEqual([1, 3]);
    expect(rewardAccounts).toHaveLength(4);
  });

  it('can handle request of 0 stake keys', async () => {
    const knownAddresses = [await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 0)];
    const { newAddresses, rewardAccounts } = await util.ensureStakeKeys({
      bip32Account,
      count: 0,
      knownAddresses,
      logger
    });

    expect(newAddresses).toHaveLength(0);
    expect(rewardAccounts).toHaveLength(1);
  });

  it('returns all reward accounts', async () => {
    const knownAddresses = [await bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 0)];
    const { rewardAccounts } = await util.ensureStakeKeys({ bip32Account, count: 2, knownAddresses, logger });
    expect(rewardAccounts).toHaveLength(2);
  });

  it('takes into account addresses with multiple stake keys and payment keys', async () => {
    const knownAddresses = await Promise.all([
      bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 0),
      bip32Account.deriveAddress({ index: 0, type: AddressType.External }, 3),
      bip32Account.deriveAddress({ index: 1, type: AddressType.External }, 0),
      bip32Account.deriveAddress({ index: 1, type: AddressType.External }, 2)
    ]);

    const { newAddresses, rewardAccounts } = await util.ensureStakeKeys({
      bip32Account,
      count: 5,
      knownAddresses,
      logger
    });
    expect(newAddresses).toHaveLength(2);
    expect(
      newAddresses.every(({ address: newAddress }) => !knownAddresses.some(({ address }) => address === newAddress))
    ).toBe(true);
    expect(rewardAccounts).toHaveLength(5);

    const stakeKeyIndicesPaymentKey0 = [...knownAddresses, ...newAddresses]
      .filter(({ index }) => index === 0)
      .map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index);
    expect(stakeKeyIndicesPaymentKey0).toEqual(expect.arrayContaining([0, 1, 3, 4]));

    const stakeKeyIndicesPaymentKey1 = [...knownAddresses, ...newAddresses]
      .filter(({ index }) => index === 1)
      .map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index);
    expect(stakeKeyIndicesPaymentKey1).toEqual(expect.arrayContaining([0, 2]));
  });
});
