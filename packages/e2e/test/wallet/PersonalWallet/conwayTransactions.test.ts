import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';

import { firstValueFrom, map } from 'rxjs';
import { getEnv, getWallet, submitAndConfirm, unDelegateWallet, walletReady, walletVariables } from '../../../src';

/*
Use cases not covered by specific tests because covered by (before|after)(All|Each) hooks
- send RegisterDelegateRepresentative certificate
  sent in beforeAll as a registered DRep is required to some other test cases
- send UnregisterDelegateRepresentative certificate
  sent in afterAll as test suite tear down
- send Conway Registration certificate
  sent in beforeEach in nested describe with tests requiring it
- send ProposalProcedure
  sent in beforeAll in nested describe to check VotingProcedure
- send AuthorizeCommitteeHot
  sent in beforeAll in nested describe to check UpdateDelegateRepresentative
*/

const {
  CertificateType,
  CredentialType,
  GovernanceActionType,
  RewardAccount,
  StakeCredentialStatus,
  StakePoolStatus,
  Vote,
  VoterType
} = Cardano;

const env = getEnv(walletVariables);

const anchor = {
  dataHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d' as Crypto.Hash32ByteBase16,
  url: 'https://testing.this'
};

const assertTxHasCertificate = (tx: Cardano.HydratedTx, certificate: Cardano.Certificate) =>
  expect(tx.body.certificates![0]).toEqual(certificate);

const getTestWallet = async (idx: number, name: string, minCoinBalance?: bigint) => {
  const { wallet } = await getWallet({ env, idx, logger, name, polling: { interval: 50 } });

  await walletReady(wallet, minCoinBalance);

  return wallet;
};

describe('PersonalWallet/conwayTransactions', () => {
  let dRepWallet: BaseWallet;
  let wallet: BaseWallet;

  let dRepCredential: Cardano.Credential & { type: Cardano.CredentialType.KeyHash };
  let poolId: Cardano.PoolId;
  let rewardAccount: Cardano.RewardAccount;
  let stakeCredential: Cardano.Credential;

  let dRepDeposit: bigint;
  let governanceActionDeposit: bigint;
  let stakeKeyDeposit: bigint;

  const assertWalletIsDelegating = async () =>
    expect((await firstValueFrom(wallet.delegation.rewardAccounts$))[0].delegatee?.nextNextEpoch?.id).toEqual(poolId);

  const getDRepCredential = async () => {
    const drepPubKey = await dRepWallet.getPubDRepKey();
    const dRepKeyHash = Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(
      (await Crypto.Ed25519PublicKey.fromHex(drepPubKey!).hash()).hex()
    );

    return { hash: dRepKeyHash, type: CredentialType.KeyHash } as typeof dRepCredential;
  };

  const getDeposits = async () => {
    const protocolParameters = await wallet.networkInfoProvider.protocolParameters();

    return [
      BigInt(protocolParameters.dRepDeposit),
      BigInt(protocolParameters.governanceActionDeposit),
      BigInt(protocolParameters.stakeKeyDeposit)
    ];
  };

  const getPoolId = async () => {
    const activePools = await wallet.stakePoolProvider.queryStakePools({
      filters: { status: [StakePoolStatus.Active] },
      pagination: { limit: 1, startAt: 0 }
    });

    return activePools.pageResults[0].id;
  };

  const getStakeCredential = async () => {
    rewardAccount = await firstValueFrom(wallet.addresses$.pipe(map((addresses) => addresses[0].rewardAccount)));

    return {
      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccount)),
      type: CredentialType.KeyHash
    };
  };

  const feedDRepWallet = async () => {
    const balance = await firstValueFrom(dRepWallet.balance.utxo.total$);

    if (balance.coins > 10_000_000n) return;

    const address = await firstValueFrom(dRepWallet.addresses$.pipe(map((addresses) => addresses[0].address)));

    const signedTx = await wallet
      .createTxBuilder()
      .addOutput({ address, value: { coins: 20_000_000n } })
      .build()
      .sign();

    await submitAndConfirm(wallet, signedTx.tx, 1);
  };

  const sendDRepRegCert = async (register: boolean) => {
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
    const [, confirmedTx] = await submitAndConfirm(dRepWallet, signedTx.tx, 1);

    assertTxHasCertificate(confirmedTx, certificate);
  };

  const isRegisteredDRep = async () => {
    const txs = [...(await firstValueFrom(dRepWallet.transactions.history$))].reverse();

    for (const {
      body: { certificates }
    } of txs) {
      if (certificates) {
        for (const certificate of certificates) {
          if (certificate.__typename === CertificateType.UnregisterDelegateRepresentative) return false;
          if (certificate.__typename === CertificateType.RegisterDelegateRepresentative) return true;
        }
      }
    }

    return false;
  };

  beforeAll(async () => {
    // TODO: remove once mainnet hardforks to conway-era, and this becomes "the norm"
    Serialization.CborSet.useConwaySerialization = true;
    Serialization.Redeemers.useConwaySerialization = true;

    [wallet, dRepWallet] = await Promise.all([
      getTestWallet(0, 'Conway Wallet', 100_000_000n),
      getTestWallet(1, 'Conway DRep Wallet', 0n)
    ]);

    [, dRepCredential, [dRepDeposit, governanceActionDeposit, stakeKeyDeposit], poolId, stakeCredential] =
      await Promise.all([feedDRepWallet(), getDRepCredential(), getDeposits(), getPoolId(), getStakeCredential()]);

    if (!(await isRegisteredDRep())) await sendDRepRegCert(true);
  });

  beforeEach(() => unDelegateWallet(wallet));

  afterAll(async () => {
    await sendDRepRegCert(false);
    await unDelegateWallet(wallet);

    wallet.shutdown();
    dRepWallet.shutdown();

    // TODO: remove once mainnet hardforks to conway-era, and this becomes "the norm"
    Serialization.CborSet.useConwaySerialization = false;
    Serialization.Redeemers.useConwaySerialization = false;
  });

  it('can register a stake key and delegate stake using a combo certificate', async () => {
    const regAndDelegCert: Cardano.StakeRegistrationDelegationCertificate = {
      __typename: CertificateType.StakeRegistrationDelegation,
      deposit: stakeKeyDeposit,
      poolId,
      stakeCredential
    };
    const signedTx = await wallet
      .createTxBuilder()
      .customize(({ txBody }) => ({ ...txBody, certificates: [regAndDelegCert] }))
      .build()
      .sign();
    const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

    assertTxHasCertificate(confirmedTx, regAndDelegCert);
    await assertWalletIsDelegating();
  });

  it('can register a stake key and delegate vote using a combo certificate', async () => {
    const regAndVoteDelegCert: Cardano.VoteRegistrationDelegationCertificate = {
      __typename: CertificateType.VoteRegistrationDelegation,
      dRep: dRepCredential,
      deposit: stakeKeyDeposit,
      stakeCredential
    };
    const signedTx = await wallet
      .createTxBuilder()
      .customize(({ txBody }) => ({ ...txBody, certificates: [regAndVoteDelegCert] }))
      .build()
      .sign();
    const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

    assertTxHasCertificate(confirmedTx, regAndVoteDelegCert);
  });

  it('can register a stake key and delegate stake and vote using a combo certificate', async () => {
    const regStakeVoteDelegCert: Cardano.StakeVoteRegistrationDelegationCertificate = {
      __typename: CertificateType.StakeVoteRegistrationDelegation,
      dRep: dRepCredential,
      deposit: stakeKeyDeposit,
      poolId,
      stakeCredential
    };
    const signedTx = await wallet
      .createTxBuilder()
      .customize(({ txBody }) => ({ ...txBody, certificates: [regStakeVoteDelegCert] }))
      .build()
      .sign();
    const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

    assertTxHasCertificate(confirmedTx, regStakeVoteDelegCert);
    await assertWalletIsDelegating();
  });

  it('can update delegation representatives', async () => {
    const updateDRepCert: Cardano.UpdateDelegateRepresentativeCertificate = {
      __typename: CertificateType.UpdateDelegateRepresentative,
      anchor: null,
      dRepCredential
    };
    const signedTx = await dRepWallet
      .createTxBuilder()
      .customize(({ txBody }) => ({ ...txBody, certificates: [updateDRepCert] }))
      .build()
      .sign();
    const [, confirmedTx] = await submitAndConfirm(dRepWallet, signedTx.tx, 1);

    assertTxHasCertificate(confirmedTx, updateDRepCert);
  });

  // TODO LW-9962
  describe.skip('with constitutional committee', () => {
    beforeAll(async () => {
      const regCCCert: Cardano.AuthorizeCommitteeHotCertificate = {
        __typename: CertificateType.AuthorizeCommitteeHot,
        coldCredential: stakeCredential,
        hotCredential: stakeCredential
      };
      const signedTx = await dRepWallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, certificates: [regCCCert] }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(dRepWallet, signedTx.tx, 1);

      assertTxHasCertificate(confirmedTx, regCCCert);
    });

    it('can update delegation representatives', async () => {
      const updateDRepCert: Cardano.UpdateDelegateRepresentativeCertificate = {
        __typename: CertificateType.UpdateDelegateRepresentative,
        anchor,
        dRepCredential
      };
      const signedTx = await dRepWallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, certificates: [updateDRepCert] }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(dRepWallet, signedTx.tx, 1);

      assertTxHasCertificate(confirmedTx, updateDRepCert);
    });
  });

  describe('with Conway Registration certificate', () => {
    beforeEach(async () => {
      const newRegCert: Cardano.NewStakeAddressCertificate = {
        __typename: CertificateType.Registration,
        deposit: stakeKeyDeposit,
        stakeCredential
      };
      const signedTx = await wallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, certificates: [newRegCert] }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

      assertTxHasCertificate(confirmedTx, newRegCert);
      expect((await firstValueFrom(wallet.delegation.rewardAccounts$))[0].credentialStatus).toBe(
        StakeCredentialStatus.Registered
      );
    });

    it('can un-register stake key through the new Conway certificates', async () => {
      const newUnRegCert: Cardano.NewStakeAddressCertificate = {
        __typename: CertificateType.Unregistration,
        deposit: stakeKeyDeposit,
        stakeCredential
      };
      const signedTx = await wallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, certificates: [newUnRegCert] }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

      assertTxHasCertificate(confirmedTx, newUnRegCert);
      expect((await firstValueFrom(wallet.delegation.rewardAccounts$))[0].credentialStatus).toBe(
        StakeCredentialStatus.Unregistered
      );
    });

    it('can delegate vote', async () => {
      const voteDelegCert: Cardano.VoteDelegationCertificate = {
        __typename: CertificateType.VoteDelegation,
        dRep: dRepCredential,
        stakeCredential
      };
      const signedTx = await wallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, certificates: [voteDelegCert] }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

      assertTxHasCertificate(confirmedTx, voteDelegCert);
      await assertWalletIsDelegating();
    });

    it('can delegate stake and vote using combo certificate', async () => {
      const stakeVoteDelegCert: Cardano.StakeVoteDelegationCertificate = {
        __typename: CertificateType.StakeVoteDelegation,
        dRep: dRepCredential,
        poolId,
        stakeCredential
      };
      const signedTx = await wallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, certificates: [stakeVoteDelegCert] }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

      assertTxHasCertificate(confirmedTx, stakeVoteDelegCert);
      await assertWalletIsDelegating();
    });
  });

  describe('with proposal procedure', () => {
    let actionId: Cardano.GovernanceActionId;

    beforeAll(async () => {
      const proposalProcedures: Cardano.ProposalProcedure[] = [
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: {
            __typename: GovernanceActionType.parameter_change_action,
            governanceActionId: null,
            policyHash: null,
            protocolParamUpdate: { maxTxSize: 2000 }
          },
          rewardAccount
        },
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: {
            __typename: GovernanceActionType.hard_fork_initiation_action,
            governanceActionId: null,
            protocolVersion: { major: 10, minor: 0 }
          },
          rewardAccount
        },
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: {
            __typename: GovernanceActionType.treasury_withdrawals_action,
            policyHash: null,
            withdrawals: new Set([{ coin: 10_000_000n, rewardAccount }])
          },
          rewardAccount
        },
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: {
            __typename: GovernanceActionType.no_confidence,
            governanceActionId: null
          },
          rewardAccount
        },
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: {
            __typename: GovernanceActionType.new_constitution,
            constitution: { anchor, scriptHash: null },
            governanceActionId: null
          },
          rewardAccount
        },
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: { __typename: GovernanceActionType.info_action },
          rewardAccount
        }
      ];
      const signedTx = await wallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, proposalProcedures }))
        .build()
        .sign();
      const [id, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

      expect(confirmedTx.body.proposalProcedures).toEqual(proposalProcedures);

      actionId = { actionIndex: 0, id };
    });

    it('delegation representatives can vote proposal procedure', async () => {
      const votingProcedures: Cardano.VotingProcedures = [
        {
          voter: { __typename: VoterType.dRepKeyHash, credential: dRepCredential },
          votes: [{ actionId, votingProcedure: { anchor, vote: Vote.abstain } }]
        }
      ];
      const signedTx = await dRepWallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, votingProcedures }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(dRepWallet, signedTx.tx, 1);

      expect(confirmedTx.body.votingProcedures).toEqual(votingProcedures);
    });
  });
});
