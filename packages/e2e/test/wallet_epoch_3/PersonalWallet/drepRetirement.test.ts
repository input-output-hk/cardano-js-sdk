/* eslint-disable unicorn/consistent-destructuring */

import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, setInConwayEra } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';

import { filter, firstValueFrom, map } from 'rxjs';
import {
  firstValueFromTimed,
  getEnv,
  getWallet,
  submitAndConfirm,
  unDelegateWallet,
  waitForWalletStateSettle,
  walletReady,
  walletVariables
} from '../../../src';

/*
Test that rewardAccounts$ drepDelegatees are updated when dreps retire, provided one of the following conditions are met:
  - a transaction build is attempted
  - drepDelegatees change, new ones are added, old ones removed
Both of these actions trigger a refetch for all dreps found in drepDelegatees.

Setup:
  - create three accounts (wallet, drepWallet, drepWallet2)
  - drep* wallets register as dreps
  - wallet delegates to 2 stake pools, resulting in 2 registered stake keys
  - wallet delegates voting power: stakeKey1 & stakeKey2 to drepWallet & drepWallet2 respectively
    - Expect to see DRep1 & DRep2 in drepDelegatees
  - DRep1 retires - no change in drepDelegatees because a refresh was not triggered
  - Build a transaction with wallet, but do not submit
    - Expect to see DRep1 removed from drepDelegatees
  - DRep2 retires - no change in drepDelegatees because a refresh was not triggered
  - Using another instance of the wallet, delegate stakeKey1 to AlwaysAbstain
    - Original wallet detects the change of delegatees according to tx history, which triggers a refetch for all dreps
    - Expect DRep2 to be removed from drepDelegatees
*/

const { CertificateType, CredentialType, RewardAccount, StakePoolStatus } = Cardano;

const env = getEnv(walletVariables);

const anchor = {
  dataHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d' as Crypto.Hash32ByteBase16,
  url: 'https://testing.this'
};

const getTestWallet = async (idx: number, name: string, minCoinBalance?: bigint) => {
  const { wallet } = await getWallet({ env, idx, logger, name, polling: { interval: 50 } });

  await walletReady(wallet, minCoinBalance);

  return wallet;
};

describe('PersonalWallet/drepRetirement', () => {
  let dRepWallet1: BaseWallet;
  let dRepWallet2: BaseWallet;
  let delegatingWallet: BaseWallet;

  let dRepCredential1: Cardano.Credential & { type: Cardano.CredentialType.KeyHash };
  let drepId1: Cardano.DRepID;
  let dRepCredential2: Cardano.Credential & { type: Cardano.CredentialType.KeyHash };
  let drepId2: Cardano.DRepID;
  let poolId1: Cardano.PoolId;
  let poolId2: Cardano.PoolId;
  let stakeCredential1: Cardano.Credential;
  let stakeCredential2: Cardano.Credential;

  let dRepDeposit: bigint;

  const getDRepCredential = async (wallet: BaseWallet) => {
    const drepPubKey = await wallet.governance.getPubDRepKey();
    const dRepKeyHash = Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(
      (await Crypto.Ed25519PublicKey.fromHex(drepPubKey!).hash()).hex()
    );

    return { hash: dRepKeyHash, type: CredentialType.KeyHash } as typeof dRepCredential1;
  };

  const getDeposits = async () => {
    const protocolParameters = await delegatingWallet.networkInfoProvider.protocolParameters();

    return [
      BigInt(protocolParameters.dRepDeposit!),
      BigInt(protocolParameters.governanceActionDeposit!),
      BigInt(protocolParameters.stakeKeyDeposit)
    ];
  };

  const getPoolIds = async () => {
    const activePools = await delegatingWallet.stakePoolProvider.queryStakePools({
      filters: { status: [StakePoolStatus.Active] },
      pagination: { limit: 2, startAt: 0 }
    });

    return activePools.pageResults.map(({ id }) => id);
  };

  const getStakeCredential = async () => {
    const rewardAccounts = await firstValueFrom(
      delegatingWallet.addresses$.pipe(map((addresses) => addresses.map(({ rewardAccount }) => rewardAccount)))
    );

    return rewardAccounts.map((rewardAccount) => ({
      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccount)),
      type: CredentialType.KeyHash
    }));
  };

  const feedDRepWallet = async (dRepWallet: BaseWallet, amount: bigint) => {
    const balance = await firstValueFrom(dRepWallet.balance.utxo.total$);

    if (balance.coins > amount) return;

    const address = await firstValueFrom(dRepWallet.addresses$.pipe(map((addresses) => addresses[0].address)));

    const signedTx = await delegatingWallet
      .createTxBuilder()
      .addOutput({ address, value: { coins: amount } })
      .build()
      .sign();

    await submitAndConfirm(delegatingWallet, signedTx.tx, 1);
  };

  const sendDRepRegCert = async (dRepWallet: BaseWallet, register: boolean) => {
    const dRepCredential = await getDRepCredential(dRepWallet);
    const common = { dRepCredential, deposit: dRepDeposit };
    const dRepUnRegCert: Cardano.UnRegisterDelegateRepresentativeCertificate = {
      __typename: CertificateType.UnregisterDelegateRepresentative,
      ...common
    };
    const dRepRegCert: Cardano.RegisterDelegateRepresentativeCertificate = {
      __typename: CertificateType.RegisterDelegateRepresentative,
      anchor,
      ...common
    };
    const certificate = register ? dRepRegCert : dRepUnRegCert;
    const signedTx = await dRepWallet
      .createTxBuilder()
      .customize(({ txBody }) => ({ ...txBody, certificates: [certificate] }))
      .build()
      .sign();
    await submitAndConfirm(dRepWallet, signedTx.tx, 1);
  };

  const isRegisteredDRep = async (wallet: BaseWallet) => {
    await waitForWalletStateSettle(wallet);
    return await firstValueFrom(wallet.governance.isRegisteredAsDRep$);
  };

  beforeAll(async () => {
    // TODO: remove once mainnet hardforks to conway-era, and this becomes "the norm"
    setInConwayEra(true);

    [delegatingWallet, dRepWallet1, dRepWallet2] = await Promise.all([
      getTestWallet(0, 'wallet-delegating', 100_000_000n),
      getTestWallet(1, 'wallet-DRep1', 0n),
      getTestWallet(2, 'wallet-DRep2', 0n)
    ]);

    [dRepCredential1, dRepCredential2, [dRepDeposit], [poolId1, poolId2]] = await Promise.all([
      getDRepCredential(dRepWallet1),
      getDRepCredential(dRepWallet2),
      getDeposits(),
      getPoolIds()
    ]);

    drepId1 = Cardano.DRepID.cip129FromCredential(dRepCredential1);
    drepId2 = Cardano.DRepID.cip129FromCredential(dRepCredential2);

    await feedDRepWallet(dRepWallet1, dRepDeposit * 2n);
    await feedDRepWallet(dRepWallet2, dRepDeposit * 2n);

    if (!(await isRegisteredDRep(dRepWallet1))) await sendDRepRegCert(dRepWallet1, true);
    if (!(await isRegisteredDRep(dRepWallet2))) await sendDRepRegCert(dRepWallet2, true);

    const txBuilder = delegatingWallet.createTxBuilder().delegatePortfolio({
      name: 'Test Portfolio',
      pools: [
        { id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId1)), weight: 1 },
        { id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId2)), weight: 1 }
      ]
    });
    const poolDelegationTx = await txBuilder.build().sign();
    await submitAndConfirm(delegatingWallet, poolDelegationTx.tx, 1);

    [stakeCredential1, stakeCredential2] = await getStakeCredential();
  });

  afterAll(async () => {
    if (await isRegisteredDRep(dRepWallet1)) await sendDRepRegCert(dRepWallet1, false);
    if (await isRegisteredDRep(dRepWallet2)) await sendDRepRegCert(dRepWallet2, false);
    await unDelegateWallet(delegatingWallet);

    delegatingWallet.shutdown();
    dRepWallet1.shutdown();
    dRepWallet2.shutdown();

    // TODO: remove once mainnet hardforks to conway-era, and this becomes "the norm"
    setInConwayEra(false);
  });

  it('emits drepDelegatees after delegating voting power', async () => {
    const voteDelegCert1: Cardano.VoteDelegationCertificate = {
      __typename: CertificateType.VoteDelegation,
      dRep: dRepCredential1,
      stakeCredential: stakeCredential1
    };
    const voteDelegCert2: Cardano.VoteDelegationCertificate = {
      __typename: CertificateType.VoteDelegation,
      dRep: dRepCredential2,
      stakeCredential: stakeCredential2
    };

    const signedTx = await delegatingWallet
      .createTxBuilder()
      .customize(({ txBody }) => ({ ...txBody, certificates: [voteDelegCert1, voteDelegCert2] }))
      .build()
      .sign();
    await submitAndConfirm(delegatingWallet, signedTx.tx, 1);

    const drepDelegatees = await firstValueFrom(
      delegatingWallet.delegation.rewardAccounts$.pipe(
        map((accounts) => accounts.map(({ dRepDelegatee }) => dRepDelegatee))
      )
    );

    expect(drepDelegatees).toEqual([
      { delegateRepresentative: expect.objectContaining({ active: true, id: drepId1 }) },
      { delegateRepresentative: expect.objectContaining({ active: true, id: drepId2 }) }
    ]);
  });

  it('transaction build triggers detection of retired DRep', async () => {
    // Retire DRep1
    await sendDRepRegCert(dRepWallet1, false);

    // Only build and inspect to trigger the refetch of drep infos
    await delegatingWallet.createTxBuilder().delegatePortfolio(null).build().inspect();

    const drepDelegatees = await firstValueFrom(
      delegatingWallet.delegation.rewardAccounts$.pipe(
        map((accounts) => accounts.map(({ dRepDelegatee }) => dRepDelegatee))
      )
    );

    expect(drepDelegatees).toEqual([
      { delegateRepresentative: expect.objectContaining({ active: false, id: drepId1 }) },
      { delegateRepresentative: expect.objectContaining({ active: true, amount: 0n, hasScript: false, id: drepId2 }) }
    ]);
  });

  it('tx history vote delegation change triggers refresh of all delegations', async () => {
    // Retire DRep2
    await sendDRepRegCert(dRepWallet2, false);

    // Create a clone of the delegatingWallet and change drep delegation.
    // The delegatingWallet tx history will update, which will trigger a refetch of all dreps, including DRep2 which was retired.
    const delegatingWalletClone = await getTestWallet(0, 'wallet-delegating-clone', 0n);
    const signedTx = await delegatingWalletClone
      .createTxBuilder()
      .customize(({ txBody }) => ({
        ...txBody,
        certificates: [
          {
            __typename: CertificateType.VoteDelegation,
            dRep: { __typename: 'AlwaysAbstain' },
            stakeCredential: stakeCredential1
          } as Cardano.VoteDelegationCertificate
        ]
      }))
      .build()
      .sign();
    await submitAndConfirm(delegatingWalletClone, signedTx.tx, 1);

    const drepDelegatees = await firstValueFromTimed(
      delegatingWallet.delegation.rewardAccounts$.pipe(
        map((accounts) => accounts.map(({ dRepDelegatee }) => dRepDelegatee)),
        filter(
          ([firstDelegatee]) =>
            !!firstDelegatee?.delegateRepresentative &&
            Cardano.isDRepAlwaysAbstain(firstDelegatee.delegateRepresentative)
        )
      )
    );

    expect(drepDelegatees).toEqual([
      { delegateRepresentative: { __typename: 'AlwaysAbstain' } },
      { delegateRepresentative: expect.objectContaining({ active: false, amount: 0n, hasScript: false, id: drepId2 }) }
    ]);
  });
});
