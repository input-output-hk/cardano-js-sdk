// cSpell:ignore costmdls vasil

import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, setInConwayEra } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';

import { firstValueFrom, map } from 'rxjs';
import {
  getEnv,
  getWallet,
  submitAndConfirm,
  unDelegateWallet,
  waitForWalletStateSettle,
  walletReady,
  walletVariables
} from '../../../src';

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
  PlutusLanguageVersion,
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

export const vasilPlutusV1Costmdls = [
  205_665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24_177, 4, 1, 1000, 32, 117_366, 10_475, 4, 23_000, 100, 23_000, 100,
  23_000, 100, 23_000, 100, 23_000, 100, 23_000, 100, 100, 100, 23_000, 100, 19_537, 32, 175_354, 32, 46_417, 4,
  221_973, 511, 0, 1, 89_141, 32, 497_525, 14_068, 4, 2, 196_500, 453_240, 220, 0, 1, 1, 1000, 28_662, 4, 2, 245_000,
  216_773, 62, 1, 1_060_367, 12_586, 1, 208_512, 421, 1, 187_000, 1000, 52_998, 1, 80_436, 32, 43_249, 32, 1000, 32,
  80_556, 1, 57_667, 4, 1000, 10, 197_145, 156, 1, 197_145, 156, 1, 204_924, 473, 1, 208_896, 511, 1, 52_467, 32,
  64_832, 32, 65_493, 32, 22_558, 32, 16_563, 32, 76_511, 32, 196_500, 453_240, 220, 0, 1, 1, 69_522, 11_687, 0, 1,
  60_091, 32, 196_500, 453_240, 220, 0, 1, 1, 196_500, 453_240, 220, 0, 1, 1, 806_990, 30_482, 4, 1_927_926, 82_523, 4,
  265_318, 0, 4, 0, 85_931, 32, 205_665, 812, 1, 1, 41_182, 32, 212_342, 32, 31_220, 32, 32_696, 32, 43_357, 32, 32_247,
  32, 38_314, 32, 57_996_947, 18_975, 10
];

export const vasilPlutusV2Costmdls = [
  205_665, 812, 1, 1, 1000, 571, 0, 1, 1000, 24_177, 4, 1, 1000, 32, 117_366, 10_475, 4, 23_000, 100, 23_000, 100,
  23_000, 100, 23_000, 100, 23_000, 100, 23_000, 100, 100, 100, 23_000, 100, 19_537, 32, 175_354, 32, 46_417, 4,
  221_973, 511, 0, 1, 89_141, 32, 497_525, 14_068, 4, 2, 196_500, 453_240, 220, 0, 1, 1, 1000, 28_662, 4, 2, 245_000,
  216_773, 62, 1, 1_060_367, 12_586, 1, 208_512, 421, 1, 187_000, 1000, 52_998, 1, 80_436, 32, 43_249, 32, 1000, 32,
  80_556, 1, 57_667, 4, 1000, 10, 197_145, 156, 1, 197_145, 156, 1, 204_924, 473, 1, 208_896, 511, 1, 52_467, 32,
  64_832, 32, 65_493, 32, 22_558, 32, 16_563, 32, 76_511, 32, 196_500, 453_240, 220, 0, 1, 1, 69_522, 11_687, 0, 1,
  60_091, 32, 196_500, 453_240, 220, 0, 1, 1, 196_500, 453_240, 220, 0, 1, 1, 1_159_724, 392_670, 0, 2, 806_990, 30_482,
  4, 1_927_926, 82_523, 4, 265_318, 0, 4, 0, 85_931, 32, 205_665, 812, 1, 1, 41_182, 32, 212_342, 32, 31_220, 32,
  32_696, 32, 43_357, 32, 32_247, 32, 38_314, 32, 35_892_428, 10, 57_996_947, 18_975, 10, 38_887_044, 32_947, 10
];

export const protocolParamUpdate: Cardano.ProtocolParametersUpdateConway = {
  coinsPerUtxoByte: 35_000,
  collateralPercentage: 852,
  committeeTermLimit: Cardano.EpochNo(200),
  costModels: new Map([
    [PlutusLanguageVersion.V1, vasilPlutusV1Costmdls],
    [PlutusLanguageVersion.V2, vasilPlutusV2Costmdls]
  ]),
  dRepDeposit: 2000,
  dRepInactivityPeriod: Cardano.EpochNo(5000),
  dRepVotingThresholds: {
    committeeNoConfidence: { denominator: 3, numerator: 1 },
    committeeNormal: { denominator: 3, numerator: 1 },
    hardForkInitiation: { denominator: 7, numerator: 4 },
    motionNoConfidence: { denominator: 3, numerator: 1 },
    ppEconomicGroup: { denominator: 7, numerator: 6 },
    ppGovernanceGroup: { denominator: 7, numerator: 6 },
    ppNetworkGroup: { denominator: 7, numerator: 6 },
    ppTechnicalGroup: { denominator: 7, numerator: 6 },
    treasuryWithdrawal: { denominator: 7, numerator: 6 },
    updateConstitution: { denominator: 7, numerator: 6 }
  },
  desiredNumberOfPools: 900,
  governanceActionDeposit: 1000,
  governanceActionValidityPeriod: Cardano.EpochNo(1_000_000),
  maxBlockBodySize: 300,
  maxBlockHeaderSize: 500,
  maxCollateralInputs: 100,
  maxExecutionUnitsPerBlock: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxExecutionUnitsPerTransaction: { memory: 4_294_967_296, steps: 4_294_967_296 },
  maxTxSize: 400,
  maxValueSize: 954,
  minCommitteeSize: 100,
  minFeeCoefficient: 100,
  minFeeConstant: 200,
  minFeeRefScriptCostPerByte: '44.5',
  minPoolCost: 1000,
  monetaryExpansion: '0.3333333333333333',
  poolDeposit: 200_000_000,
  poolInfluence: '0.5',
  poolRetirementEpochBound: 800,
  poolVotingThresholds: {
    committeeNoConfidence: { denominator: 3, numerator: 1 },
    committeeNormal: { denominator: 3, numerator: 1 },
    hardForkInitiation: { denominator: 7, numerator: 6 },
    motionNoConfidence: { denominator: 3, numerator: 1 },
    securityRelevantParamVotingThreshold: { denominator: 3, numerator: 1 }
  },
  prices: { memory: 0.5, steps: 0.5 },
  stakeKeyDeposit: 2_000_000,
  treasuryExpansion: '0.25'
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
    const drepPubKey = await dRepWallet.governance.getPubDRepKey();
    const dRepKeyHash = Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(
      (await Crypto.Ed25519PublicKey.fromHex(drepPubKey!).hash()).hex()
    );

    return { hash: dRepKeyHash, type: CredentialType.KeyHash } as typeof dRepCredential;
  };

  const getDeposits = async () => {
    const protocolParameters = await wallet.networkInfoProvider.protocolParameters();

    return [
      BigInt(protocolParameters.dRepDeposit!),
      BigInt(protocolParameters.governanceActionDeposit!),
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
      hash: RewardAccount.toHash(rewardAccount),
      type: CredentialType.KeyHash
    };
  };

  const feedDRepWallet = async (amount: bigint) => {
    const balance = await firstValueFrom(dRepWallet.balance.utxo.total$);

    if (balance.coins > amount) return;

    const address = await firstValueFrom(dRepWallet.addresses$.pipe(map((addresses) => addresses[0].address)));

    const signedTx = await wallet
      .createTxBuilder()
      .addOutput({ address, value: { coins: amount } })
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
    await waitForWalletStateSettle(dRepWallet);
    return await firstValueFrom(dRepWallet.governance.isRegisteredAsDRep$);
  };

  beforeAll(async () => {
    // TODO: remove once mainnet hardforks to conway-era, and this becomes "the norm"
    setInConwayEra(true);

    [wallet, dRepWallet] = await Promise.all([
      getTestWallet(0, 'Conway Wallet', 100_000_000n),
      getTestWallet(1, 'Conway DRep Wallet', 0n)
    ]);

    [dRepCredential, [dRepDeposit, governanceActionDeposit, stakeKeyDeposit], poolId, stakeCredential] =
      await Promise.all([getDRepCredential(), getDeposits(), getPoolId(), getStakeCredential()]);

    await feedDRepWallet(dRepDeposit * 2n);

    if (!(await isRegisteredDRep())) await sendDRepRegCert(true);
  });

  beforeEach(async () => await unDelegateWallet(wallet));

  afterAll(async () => {
    await sendDRepRegCert(false);
    await unDelegateWallet(wallet);

    wallet.shutdown();
    dRepWallet.shutdown();

    // TODO: remove once mainnet hardforks to conway-era, and this becomes "the norm"
    setInConwayEra(false);
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

    it.each([
      dRepCredential,
      { __typename: 'AlwaysAbstain' },
      { __typename: 'AlwaysNoConfidence' }
    ] as Cardano.DelegateRepresentative[])('can delegate vote %s', async (dRep) => {
      // dRepCredential is initialized in beforeAll, and it.each runs before `beforeAll`,
      // so it is not available in the .each scope.
      // Use this workaround to pass the dRepCredential to the test
      dRep = dRep ?? dRepCredential;
      const voteDelegCert: Cardano.VoteDelegationCertificate = {
        __typename: CertificateType.VoteDelegation,
        dRep,
        stakeCredential
      };
      const signedTx = await wallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, certificates: [voteDelegCert] }))
        .build()
        .sign();
      const [, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);

      assertTxHasCertificate(confirmedTx, voteDelegCert);
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
    let confirmedTx: Cardano.HydratedTx;
    let id: Cardano.TransactionId;
    let proposalProcedures: Cardano.ProposalProcedure[];

    beforeAll(async () => {
      proposalProcedures = [
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: {
            __typename: GovernanceActionType.parameter_change_action,
            governanceActionId: null,
            policyHash: null,
            protocolParamUpdate
          },
          rewardAccount
        },
        {
          anchor,
          deposit: governanceActionDeposit,
          governanceAction: {
            __typename: GovernanceActionType.hard_fork_initiation_action,
            governanceActionId: null,
            protocolVersion: { major: 11, minor: 0 }
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
      [id, confirmedTx] = await submitAndConfirm(wallet, signedTx.tx, 1);
    });

    it('parameter_change_action correctly submits protocol parameters update', () => {
      expect(confirmedTx.body.proposalProcedures).toEqual(proposalProcedures);
    });

    it('delegation representatives can vote proposal procedure', async () => {
      const votingProcedures: Cardano.VotingProcedures = [
        {
          voter: { __typename: VoterType.dRepKeyHash, credential: dRepCredential },
          votes: [
            { actionId: { actionIndex: 0, id }, votingProcedure: { anchor, vote: Vote.abstain } },
            { actionId: { actionIndex: 1, id }, votingProcedure: { anchor: null, vote: Vote.yes } }
          ]
        }
      ];
      const signedTx = await dRepWallet
        .createTxBuilder()
        .customize(({ txBody }) => ({ ...txBody, votingProcedures }))
        .build()
        .sign();
      const [, tx] = await submitAndConfirm(dRepWallet, signedTx.tx, 1);

      expect(tx.body.votingProcedures).toEqual(votingProcedures);
    });
  });
});
