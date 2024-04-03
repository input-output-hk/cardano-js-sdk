/* eslint-disable max-statements */
import { Cardano } from '@cardano-sdk/core';
import {
  KeyAgentFactoryProps,
  TestWallet,
  bip32Ed25519Factory,
  getEnv,
  getWallet,
  submitCertificate,
  unDelegateWallet,
  waitForWalletStateSettle,
  walletReady,
  walletVariables
} from '../../src';
import { logger } from '@cardano-sdk/util-dev';

import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, KeyRole } from '@cardano-sdk/key-management';
import { firstValueFrom } from 'rxjs';

const env = getEnv(walletVariables);

const vrf1 = Cardano.VrfVkHex('2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759');
const vrf2 = Cardano.VrfVkHex('641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014');

const wallet1Params: KeyAgentFactoryProps = {
  accountIndex: 0,
  chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
  mnemonic:
    // eslint-disable-next-line max-len
    'decorate survey empower stairs pledge humble social leisure baby wrap grief exact monster rug dash kiss perfect select science light frame play swallow day',
  passphrase: 'some_passphrase'
};
const wallet2Params: KeyAgentFactoryProps = {
  accountIndex: 0,
  chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
  mnemonic:
    // eslint-disable-next-line max-len
    'salon zoo engage submit smile frost later decide wing sight chaos renew lizard rely canal coral scene hobby scare step bus leaf tobacco slice',
  passphrase: 'some_passphrase'
};

describe('local-network/register-pool', () => {
  let wallet1: TestWallet;
  let wallet2: TestWallet;
  let bip32Ed25519: Crypto.Bip32Ed25519;

  beforeAll(async () => {
    jest.setTimeout(180_000);

    wallet1 = await getWallet({
      customKeyParams: wallet1Params,
      env,
      idx: 0,
      logger,
      name: 'Pool Wallet 1',
      polling: { interval: 500 }
    });
    wallet2 = await getWallet({
      customKeyParams: wallet2Params,
      env,
      idx: 0,
      logger,
      name: 'Pool Wallet 2',
      polling: { interval: 500 }
    });

    await waitForWalletStateSettle(wallet1.wallet);
    await waitForWalletStateSettle(wallet2.wallet);
    bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);
  });

  afterAll(() => {
    wallet1.wallet.shutdown();
    wallet2.wallet.shutdown();
  });

  beforeEach(() => unDelegateWallet(wallet1.wallet));

  test('does not meet pledge', async () => {
    const wallet = wallet1.wallet;

    await walletReady(wallet);

    const poolPubKey = await wallet1.bip32Account.derivePublicKey({
      index: 0,
      role: KeyRole.External
    });

    const poolKeyHash = await bip32Ed25519.getPubKeyHash(poolPubKey.hex());
    const poolId = Cardano.PoolId.fromKeyHash(poolKeyHash);
    const poolRewardAccount = (
      await wallet1.bip32Account.deriveAddress(
        {
          index: 0,
          type: AddressType.External
        },
        0
      )
    ).rewardAccount;

    const registrationCert: Cardano.PoolRegistrationCertificate = {
      __typename: Cardano.CertificateType.PoolRegistration,
      poolParameters: {
        cost: 1000n,
        id: poolId,
        margin: { denominator: 5, numerator: 1 },
        owners: [poolRewardAccount],
        pledge: 500_000_000_000_000n,
        relays: [
          {
            __typename: 'RelayByAddress',
            ipv4: '127.0.0.1',
            port: 6000
          }
        ],
        rewardAccount: poolRewardAccount,
        vrf: vrf1
      }
    };

    const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
    const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccounts[0].address);
    const stakeCredential = {
      hash: stakeKeyHash as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    };

    await submitCertificate(registrationCert, wallet1);

    // Register stake key.
    const registerStakeKey: Cardano.StakeAddressCertificate = {
      __typename: Cardano.CertificateType.StakeRegistration,
      stakeCredential
    };

    await submitCertificate(registerStakeKey, wallet1);

    // Delegate pool owner funds to meet pledge.
    const delegationCert: Cardano.StakeDelegationCertificate = {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId,
      stakeCredential
    };

    await submitCertificate(delegationCert, wallet1);

    const result = await wallet1.providers.stakePoolProvider.queryStakePools({
      filters: {
        _condition: 'and',
        identifier: {
          values: [{ id: poolId }]
        },
        pledgeMet: false
      },
      pagination: { limit: 1, startAt: 0 }
    });

    expect(result.pageResults.length).toBeGreaterThan(0);
    expect(result.pageResults[0].hexId).toBe(Cardano.PoolIdHex(poolKeyHash));
    expect(result.pageResults[0].id).toBe(poolId);
    expect(result.pageResults[0].status).toBe(Cardano.StakePoolStatus.Activating);
    expect(result.pageResults[0].metrics?.livePledge).toBeLessThan(result.pageResults[0].pledge);
  });

  test('meets pledge', async () => {
    const wallet = wallet2.wallet;

    await walletReady(wallet);

    const poolPubKey = await wallet2.bip32Account.derivePublicKey({
      index: 0,
      role: KeyRole.External
    });

    const poolKeyHash = await bip32Ed25519.getPubKeyHash(poolPubKey.hex());
    const poolId = Cardano.PoolId.fromKeyHash(poolKeyHash);
    const poolRewardAccount = (
      await wallet2.bip32Account.deriveAddress(
        {
          index: 0,
          type: AddressType.External
        },
        0
      )
    ).rewardAccount;

    const registrationCert: Cardano.PoolRegistrationCertificate = {
      __typename: Cardano.CertificateType.PoolRegistration,
      poolParameters: {
        cost: 1000n,
        id: poolId,
        margin: { denominator: 5, numerator: 1 },
        owners: [poolRewardAccount],
        pledge: 50_000_000n,
        relays: [
          {
            __typename: 'RelayByAddress',
            ipv4: '127.0.0.2',
            port: 6000
          }
        ],
        rewardAccount: poolRewardAccount,
        vrf: vrf2
      }
    };

    const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
    const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccounts[0].address);
    const stakeCredential = {
      hash: stakeKeyHash as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    };

    await submitCertificate(registrationCert, wallet2);

    // Register stake key.
    const registerStakeKey: Cardano.StakeAddressCertificate = {
      __typename: Cardano.CertificateType.StakeRegistration,
      stakeCredential
    };

    await submitCertificate(registerStakeKey, wallet2);

    // Delegate pool owner funds to meet pledge.
    const delegationCert: Cardano.StakeDelegationCertificate = {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId,
      stakeCredential
    };

    await submitCertificate(delegationCert, wallet2);

    const result = await wallet2.providers.stakePoolProvider.queryStakePools({
      filters: {
        _condition: 'and',
        identifier: {
          values: [{ id: poolId }]
        },
        pledgeMet: true
      },
      pagination: { limit: 1, startAt: 0 }
    });

    expect(result.pageResults.length).toBeGreaterThan(0);
    expect(result.pageResults[0].hexId).toBe(Cardano.PoolIdHex(poolKeyHash));
    expect(result.pageResults[0].id).toBe(poolId);
    expect(result.pageResults[0].status).toBe(Cardano.StakePoolStatus.Activating);
    expect(result.pageResults[0].metrics?.livePledge).toBeGreaterThan(result.pageResults[0].pledge);
  });
});
