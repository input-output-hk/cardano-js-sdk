/* eslint-disable max-statements */
import { AddressType, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { KeyAgentFactoryProps, TestWallet, getEnv, getWallet, walletVariables } from '../../src';
import {
  getTxConfirmationEpoch,
  submitCertificate,
  waitForEpoch,
  waitForWalletStateSettle,
  walletReady
} from '../util';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);
const vrf = Cardano.VrfVkHex('2ee5a4c423224bb9c42107fc18a60556d6a83cec1d9dd37a71f56af7198fc759');

const wallet1Params: KeyAgentFactoryProps = {
  accountIndex: 0,
  chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
  mnemonic:
    // eslint-disable-next-line max-len
    'phrase raw learn suspect inmate powder combine apology regular hero gain chronic fruit ritual short screen goddess odor keen creek brand today kit machine',
  passphrase: 'some_passphrase'
};

describe('cache invalidation', () => {
  let wallet1: TestWallet;

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

    await waitForWalletStateSettle(wallet1.wallet);
  });

  afterAll(() => wallet1.wallet.shutdown());

  test('cache is invalidated on epoch rollover', async () => {
    const wallet = wallet1.wallet;

    await walletReady(wallet);

    const poolKeyAgent = wallet.keyAgent;

    const poolPubKey = await poolKeyAgent.derivePublicKey({
      index: 0,
      role: KeyRole.External
    });

    const bip32Ed25519 = await poolKeyAgent.getBip32Ed25519();
    const poolKeyHash = await bip32Ed25519.getPubKeyHash(poolPubKey);
    const poolId = Cardano.PoolId.fromKeyHash(poolKeyHash);
    const poolRewardAccount = (
      await poolKeyAgent.deriveAddress(
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
