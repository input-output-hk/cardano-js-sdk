/* eslint-disable max-statements */
import { Awaited } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import { KeyAgentFactoryProps, getWallet } from '../../src';
import { env } from '../environment';
import { logger } from '@cardano-sdk/util-dev';
import { submitAndConfirm, waitForWalletStateSettle, walletReady } from '../util';

import { AddressType, KeyRole } from '@cardano-sdk/key-management';
import { firstValueFrom } from 'rxjs';

const vrf1 = Cardano.VrfVkHex('2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759');
const vrf2 = Cardano.VrfVkHex('641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014');

const wallet1Params: KeyAgentFactoryProps = {
  accountIndex: 0,
  mnemonic:
    // eslint-disable-next-line max-len
    'decorate survey empower stairs pledge humble social leisure baby wrap grief exact monster rug dash kiss perfect select science light frame play swallow day',
  networkId: Cardano.NetworkId.testnet,
  password: 'some_password'
};
const wallet2Params: KeyAgentFactoryProps = {
  accountIndex: 0,
  mnemonic:
    // eslint-disable-next-line max-len
    'salon zoo engage submit smile frost later decide wing sight chaos renew lizard rely canal coral scene hobby scare step bus leaf tobacco slice',
  networkId: Cardano.NetworkId.testnet,
  password: 'some_password'
};

/**
 * Submit certificates on behalf of the given wallet.
 *
 * @param certificate The certificate to be send.
 * @param wallet The wallet
 */
const submitCertificate = async (certificate: Cardano.Certificate, wallet: Awaited<ReturnType<typeof getWallet>>) => {
  const walletAddress = (await firstValueFrom(wallet.wallet.addresses$))[0].address;
  const txProps = {
    certificates: [certificate],
    outputs: new Set([
      {
        address: walletAddress,
        value: {
          coins: 3_000_000n
        }
      }
    ])
  };

  const unsignedTx = await wallet.wallet.initializeTx(txProps);

  const signedTx = await wallet.wallet.finalizeTx({
    tx: unsignedTx
  });

  await submitAndConfirm(wallet.wallet, signedTx);
};

describe('local-network/register-pool', () => {
  let wallet1: Awaited<ReturnType<typeof getWallet>>;
  let wallet2: Awaited<ReturnType<typeof getWallet>>;

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
  });

  afterAll(() => {
    wallet1.wallet.shutdown();
    wallet2.wallet.shutdown();
  });

  test('without pledge', async () => {
    const wallet = wallet1.wallet;

    await walletReady(wallet);

    const poolKeyAgent = wallet.keyAgent;

    const poolPubKey = await poolKeyAgent.derivePublicKey({
      index: 0,
      role: KeyRole.External
    });

    const poolKeyHash = Cardano.Ed25519KeyHash.fromKey(poolPubKey);
    const poolId = Cardano.PoolId.fromKeyHash(poolKeyHash);
    const poolRewardAccount = (
      await poolKeyAgent.deriveAddress({
        index: 0,
        type: AddressType.External
      })
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
            ipv4: '127.0.0.1',
            port: 6000
          }
        ],
        rewardAccount: poolRewardAccount,
        vrf: vrf1
      }
    };

    await submitCertificate(registrationCert, wallet1);

    const result = await wallet1.providers.stakePoolProvider.queryStakePools({
      filters: {
        identifier: {
          values: [{ id: poolId }]
        }
      },
      pagination: { limit: 1, startAt: 0 }
    });

    expect(result.pageResults.length).toBeGreaterThan(0);
    expect(result.pageResults[0].hexId).toBe(Cardano.PoolIdHex(poolKeyHash.toString()));
    expect(result.pageResults[0].id).toBe(poolId);
    expect(result.pageResults[0].status).toBe('activating');
  });

  test('with pledge', async () => {
    const wallet = wallet2.wallet;

    await walletReady(wallet);

    const poolKeyAgent = wallet.keyAgent;

    const poolPubKey = await poolKeyAgent.derivePublicKey({
      index: 0,
      role: KeyRole.External
    });

    const poolKeyHash = Cardano.Ed25519KeyHash.fromKey(poolPubKey);
    const poolId = Cardano.PoolId.fromKeyHash(poolKeyHash);
    const poolRewardAccount = (
      await poolKeyAgent.deriveAddress({
        index: 0,
        type: AddressType.External
      })
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
            ipv4: '127.0.0.1',
            port: 6000
          }
        ],
        rewardAccount: poolRewardAccount,
        vrf: vrf2
      }
    };

    const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
    const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccounts[0].address);

    await submitCertificate(registrationCert, wallet2);

    // Register stake key.
    const registerStakeKey: Cardano.StakeAddressCertificate = {
      __typename: Cardano.CertificateType.StakeKeyRegistration,
      stakeKeyHash
    };

    await submitCertificate(registerStakeKey, wallet2);

    // Delegate pool owner funds to meet pledge.
    const delegationCert: Cardano.StakeDelegationCertificate = {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId,
      stakeKeyHash
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
    expect(result.pageResults[0].hexId).toBe(Cardano.PoolIdHex(poolKeyHash.toString()));
    expect(result.pageResults[0].id).toBe(poolId);
    expect(result.pageResults[0].status).toBe('activating');
  });
});
