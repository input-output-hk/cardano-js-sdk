import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, AsyncKeyAgent, InMemoryKeyAgent, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { Logger, dummyLogger } from 'ts-log';
import { firstValueFrom } from 'rxjs';

describe('ensureStakeKeys', () => {
  let keyAgent: AsyncKeyAgent;
  let logger: Logger;

  beforeEach(async () => {
    logger = dummyLogger;
    const mnemonicWords = util.generateMnemonicWords();
    const getPassphrase = jest.fn().mockResolvedValue(Buffer.from('password'));
    const inputResolver = { resolveInput: jest.fn() };
    keyAgent = util.createAsyncKeyAgent(
      await InMemoryKeyAgent.fromBip39MnemonicWords(
        {
          chainId: Cardano.ChainIds.Preview,
          getPassphrase,
          mnemonicWords
        },
        { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), inputResolver, logger: dummyLogger }
      )
    );
  });

  it('can derive one stake key', async () => {
    const newRewardAccounts = await util.ensureStakeKeys({ count: 1, keyAgent, logger });
    const knownAddresses = await firstValueFrom(keyAgent.knownAddresses$);
    expect(knownAddresses.length).toBe(1);
    expect(knownAddresses.map(({ rewardAccount }) => rewardAccount)).toEqual(newRewardAccounts);
  });

  it('does not create more stake keys when sufficient exist', async () => {
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 1);

    await util.ensureStakeKeys({ count: 2, keyAgent, logger });

    const knownAddresses = await firstValueFrom(keyAgent.knownAddresses$);
    expect(knownAddresses.length).toBe(2);
  });

  it('derives new stake keys filling any existing gaps', async () => {
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 2);

    await util.ensureStakeKeys({ count: 4, keyAgent, logger });

    const knownAddresses = await firstValueFrom(keyAgent.knownAddresses$);
    const stakeKeyIndices = knownAddresses.map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index).sort();
    expect(stakeKeyIndices).toEqual([0, 1, 2, 3]);
  });

  it('generates new known addresses using the requested payment key index', async () => {
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 2);

    await util.ensureStakeKeys({ count: 4, keyAgent, logger, paymentKeyIndex: 1 });

    const stakeKeyIndicesPaymentKey1 = (await firstValueFrom(keyAgent.knownAddresses$))
      .filter(({ index }) => index === 1)
      .map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index);
    expect(stakeKeyIndicesPaymentKey1).toEqual(expect.arrayContaining([1, 3]));
  });

  it('can handle request of 0 stake keys', async () => {
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
    await util.ensureStakeKeys({ count: 0, keyAgent, logger });

    const knownAddresses = await firstValueFrom(keyAgent.knownAddresses$);
    expect(knownAddresses.length).toBe(1);
  });

  it('returns all reward accounts', async () => {
    await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
    await expect(util.ensureStakeKeys({ count: 2, keyAgent, logger })).resolves.toHaveLength(2);
  });

  it('takes into account addresses with multiple stake keys and payment keys', async () => {
    await Promise.all([
      keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0),
      keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 3),
      keyAgent.deriveAddress({ index: 1, type: AddressType.External }, 0),
      keyAgent.deriveAddress({ index: 1, type: AddressType.External }, 2)
    ]);

    await util.ensureStakeKeys({ count: 5, keyAgent, logger });
    const knownAddresses = await firstValueFrom(keyAgent.knownAddresses$);
    expect(knownAddresses.length).toBe(6);

    const stakeKeyIndicesPaymentKey0 = knownAddresses
      .filter(({ index }) => index === 0)
      .map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index);
    expect(stakeKeyIndicesPaymentKey0).toEqual(expect.arrayContaining([0, 1, 3, 4]));

    const stakeKeyIndicesPaymentKey1 = knownAddresses
      .filter(({ index }) => index === 1)
      .map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath?.index);
    expect(stakeKeyIndicesPaymentKey1).toEqual(expect.arrayContaining([0, 2]));
  });
});
