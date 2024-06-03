import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import {
  KeyAgentFactoryProps,
  TestWallet,
  bip32Ed25519Factory,
  getEnv,
  getTxConfirmationEpoch,
  getWallet,
  submitCertificate,
  waitForEpoch,
  waitForWalletStateSettle,
  walletReady,
  walletVariables
} from '../../src';
import { containerExec } from 'dockerode-utils';
import { getRandomPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import Docker from 'dockerode';
import path from 'path';

const vrf = Cardano.VrfVkHex('2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759');

describe('cache invalidation', () => {
  let testProviderServer: Docker.Container;
  let wallet1: TestWallet;
  let bip32Ed25519: Crypto.Bip32Ed25519;

  beforeAll(async () => {
    const port = await getRandomPort();

    // Get environment from original provider server container
    const docker = new Docker();
    const originalProviderServer = docker.getContainer('local-network-e2e-provider-server-1');
    const cmdOutput = await containerExec(originalProviderServer, [
      'node',
      '-e',
      'console.log(`sdk_token${JSON.stringify(process.env)}sdk_token`)'
    ]);
    const matchResult = cmdOutput[0].match(/sdk_token(.*)sdk_token/);

    if (!matchResult) throw new Error('Error getting original container environment');

    const [, encodedEnv] = matchResult;

    const Env = Object.entries({
      ...JSON.parse(encodedEnv),
      DISABLE_DB_CACHE: 'false',
      LOGGER_MIN_SEVERITY: 'debug'
    }).map(([key, value]) => `${key}=${value}`);

    const network = docker.getNetwork('local-network-e2e_default');

    // Test container
    testProviderServer = await docker.createContainer({
      Env,
      HostConfig: {
        Binds: [`${path.join(__dirname, '..', '..', '..', '..', 'compose', 'placeholder-secrets')}:/run/secrets`],
        PortBindings: { '3000/tcp': [{ HostPort: port.toString() }] }
      },
      Image: 'local-network-e2e-provider-server',
      name: 'local-network-e2e-provider-server-test'
    });

    await network.connect({ Container: testProviderServer.id });
    await testProviderServer.start();

    const override = Object.fromEntries(
      Object.entries(process.env)
        .filter(([key]) => walletVariables.includes(key as typeof walletVariables[number]))
        .map(([key, value]) => [key, value?.replace('localhost:4000/', `localhost:${port}/`)])
    );
    const env = getEnv(walletVariables, { override });
    const wallet1Params: KeyAgentFactoryProps = {
      accountIndex: 0,
      chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
      mnemonic:
        // eslint-disable-next-line max-len
        'phrase raw learn suspect inmate powder combine apology regular hero gain chronic fruit ritual short screen goddess odor keen creek brand today kit machine',
      passphrase: 'some_passphrase'
    };

    jest.setTimeout(180_000);

    wallet1 = await getWallet({
      customKeyParams: wallet1Params,
      env,
      idx: 0,
      logger,
      name: 'Pool Wallet 1',
      polling: { interval: 500 }
    });

    await waitForWalletStateSettle(wallet1.wallet);
    bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);
  });

  afterAll(async () => {
    wallet1.wallet.shutdown();
    await testProviderServer.stop();
    await testProviderServer.remove();
  });

  test('cache is invalidated on epoch rollover', async () => {
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
        pledge: 50_000_000n,
        relays: [{ __typename: 'RelayByAddress', ipv4: '127.0.0.1', port: 6000 }],
        rewardAccount: poolRewardAccount,
        vrf
      }
    };

    // This loads the data in the cache
    const resultBeforeRegistration = await wallet1.providers.stakePoolProvider.queryStakePools({
      filters: { identifier: { values: [{ id: poolId }] } },
      pagination: { limit: 1, startAt: 0 }
    });

    expect(resultBeforeRegistration.totalResultCount).toBe(0);

    const signedTx = await submitCertificate(registrationCert, wallet1);

    const resultAfterRegistration = await wallet1.providers.stakePoolProvider.queryStakePools({
      filters: { identifier: { values: [{ id: poolId }] } },
      pagination: { limit: 1, startAt: 0 }
    });

    // Here we still expect 0 as the cache is doing its job
    expect(resultAfterRegistration.totalResultCount).toBe(0);

    const registrationTxConfirmedAtEpoch = await getTxConfirmationEpoch(wallet1.wallet, signedTx);

    await waitForEpoch(wallet1.wallet, registrationTxConfirmedAtEpoch + 1);

    const resultAfterOneEpoch = await wallet1.providers.stakePoolProvider.queryStakePools({
      filters: { identifier: { values: [{ id: poolId }] } },
      pagination: { limit: 1, startAt: 0 }
    });

    expect(resultAfterOneEpoch.totalResultCount).toBe(1);
    expect(resultAfterOneEpoch.pageResults[0].status).toBe('activating');

    await waitForEpoch(wallet1.wallet, registrationTxConfirmedAtEpoch + 2);

    const resultAfterTwoEpochs = await wallet1.providers.stakePoolProvider.queryStakePools({
      filters: { identifier: { values: [{ id: poolId }] } },
      pagination: { limit: 1, startAt: 0 }
    });

    expect(resultAfterTwoEpochs.totalResultCount).toBe(1);
    expect(resultAfterTwoEpochs.pageResults[0].status).toBe('active');
  });
});
