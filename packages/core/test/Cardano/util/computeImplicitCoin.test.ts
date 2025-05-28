import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '../../../src';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';

describe('Cardano.util.computeImplicitCoin', () => {
  let rewardAccount: Cardano.RewardAccount;
  let stakeCredential: Cardano.Credential;
  let dRepPublicKey: Crypto.Ed25519PublicKeyHex;
  let dRepKeyHash: Crypto.Ed25519KeyHashHex;

  beforeAll(() => Crypto.ready());

  beforeEach(async () => {
    rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
    stakeCredential = {
      hash: Cardano.RewardAccount.toHash(rewardAccount),
      type: Cardano.CredentialType.KeyHash
    };
    dRepPublicKey = Crypto.Ed25519PublicKeyHex('deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01');
    dRepKeyHash = Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash().hex();
  });

  describe('calculates deposit', () => {
    it('using protocol parameters for shelley era registration certificate', () => {
      const protocolParameters = { stakeKeyDeposit: 3 } as Cardano.ProtocolParameters;
      const certificates: Cardano.Certificate[] = [
        { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential }
      ];
      const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates });
      expect(coin.deposit).toBe(3n);
    });

    it('using deposit field in conway era stake registration certificate', () => {
      const protocolParameters = { stakeKeyDeposit: 3 } as Cardano.ProtocolParameters;
      const certificates: Cardano.Certificate[] = [
        { __typename: Cardano.CertificateType.Registration, deposit: 10n, stakeCredential }
      ];
      const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates });
      expect(coin.deposit).toBe(10n);
    });
  });

  describe('calculates reclaim', () => {
    it('using protocol parameters for shelley era deregistration certificate', () => {
      const protocolParameters = { stakeKeyDeposit: 3 } as Cardano.ProtocolParameters;
      const certificates: Cardano.Certificate[] = [
        { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential }
      ];
      const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates });
      expect(coin.input).toBe(3n);
    });

    it('using deposit field in conway era stake deregistration certificate', () => {
      const protocolParameters = { stakeKeyDeposit: 3 } as Cardano.ProtocolParameters;
      const certificates: Cardano.Certificate[] = [
        { __typename: Cardano.CertificateType.Unregistration, deposit: 10n, stakeCredential }
      ];
      const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates });
      expect(coin.input).toBe(10n);
    });
  });

  it('sums registrations for deposit, withdrawals and deregistrations for input', () => {
    const protocolParameters = { dRepDeposit: 5, poolDeposit: 3, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const poolId = Cardano.PoolId.fromKeyHash(Ed25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount)));
    const certificates: Cardano.Certificate[] = [
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential },
      { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential },
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential },
      {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(500),
        poolId
      },
      {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId,
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
        anchor: null,
        dRepCredential: {} as Cardano.Credential,
        deposit: 7n
      },
      {
        __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
        dRepCredential: {} as Cardano.Credential,
        deposit: 7n
      }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 5n, stakeAddress: rewardAccount }];
    const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals }, [rewardAccount]);
    expect(coin.deposit).toBe(2n + 2n + 7n);
    expect(coin.input).toBe(2n + 3n + 5n + 7n);
    expect(coin.withdrawals).toBe(5n);
    expect(coin.reclaimDeposit).toBe(5n + 7n);
  });

  it('sums registrations for deposit, withdrawals and deregistrations for input for own reward accounts when given reward accounts array', () => {
    const protocolParameters = { dRepDeposit: 5, poolDeposit: 3, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const foreignRewardAccount = Cardano.RewardAccount(
      'stake_test17rphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcljw6kf'
    );

    const foreignStakeCredential = {
      hash: Cardano.RewardAccount.toHash(foreignRewardAccount) as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    };

    const poolId = Cardano.PoolId.fromKeyHash(
      Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Ed25519KeyHashHex
    );

    const stakeKeyDepositPp = BigInt(protocolParameters.stakeKeyDeposit);
    const stakeKeyDepositCert = 10n;
    const stakeKeyReclaimCert = 20n;
    const poolDeposit = BigInt(protocolParameters.poolDeposit!);
    const drepDeposit = BigInt(protocolParameters.dRepDeposit!);

    const certificates: Cardano.Certificate[] = [
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential },
      { __typename: Cardano.CertificateType.Registration, deposit: stakeKeyDepositCert, stakeCredential },
      { __typename: Cardano.CertificateType.Unregistration, deposit: stakeKeyReclaimCert, stakeCredential },
      { __typename: Cardano.CertificateType.Unregistration, deposit: 100n, stakeCredential: foreignStakeCredential },
      { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential: foreignStakeCredential },
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential: foreignStakeCredential },
      {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(500),
        poolId
      },
      {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
        anchor: null,
        dRepCredential: {
          hash: dRepKeyHash,
          type: Cardano.CredentialType.KeyHash
        } as Cardano.Credential,
        deposit: drepDeposit
      },
      {
        __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
        dRepCredential: {
          hash: dRepKeyHash,
          type: Cardano.CredentialType.KeyHash
        } as Cardano.Credential,
        deposit: drepDeposit
      },
      {
        __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
        anchor: null,
        dRepCredential: {} as Cardano.Credential,
        deposit: drepDeposit
      },
      {
        __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
        dRepCredential: {} as Cardano.Credential,
        deposit: drepDeposit
      },
      {
        __typename: Cardano.CertificateType.StakeRegistrationDelegation,
        deposit: stakeKeyDepositCert,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.VoteRegistrationDelegation,
        dRep: {} as Cardano.DelegateRepresentative,
        deposit: stakeKeyDepositCert,
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
        dRep: {} as Cardano.DelegateRepresentative,
        deposit: stakeKeyDepositCert,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        stakeCredential
      },
      { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 10n, stakeAddress: rewardAccount }];
    const coin = Cardano.util.computeImplicitCoin(
      protocolParameters,
      { certificates, withdrawals },
      [rewardAccount],
      dRepKeyHash
    );
    expect(coin.deposit).toBe(
      stakeKeyDepositPp +
        stakeKeyDepositCert +
        drepDeposit +
        stakeKeyDepositCert +
        stakeKeyDepositCert +
        stakeKeyDepositCert
    );
    const expectedReclaim = stakeKeyReclaimCert + poolDeposit + drepDeposit + stakeKeyDepositPp;
    expect(coin.reclaimDeposit).toBe(expectedReclaim);
    expect(coin.input).toBe(withdrawals[0].quantity + expectedReclaim);
    expect(coin.withdrawals).toBe(withdrawals[0].quantity);
  });

  it('sums withdrawals for input for own reward accounts', () => {
    const protocolParameters = { dRepDeposit: 5, poolDeposit: 3, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const certificates: Cardano.Certificate[] = [];
    const foreignRewardAccount = Cardano.RewardAccount(
      'stake_test17rphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcljw6kf'
    );
    const withdrawals: Cardano.Withdrawal[] = [
      { quantity: 15n, stakeAddress: foreignRewardAccount },
      { quantity: 5n, stakeAddress: rewardAccount }
    ];
    const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals }, [rewardAccount]);
    expect(coin.withdrawals).toBe(5n);
  });

  it('sums all withdrawals for input if there are no reward accounts provided', () => {
    const protocolParameters = { dRepDeposit: 5, poolDeposit: 3, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const certificates: Cardano.Certificate[] = [];
    const foreignRewardAccount = Cardano.RewardAccount(
      'stake_test17rphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcljw6kf'
    );
    const withdrawals: Cardano.Withdrawal[] = [
      { quantity: 15n, stakeAddress: foreignRewardAccount },
      { quantity: 5n, stakeAddress: rewardAccount }
    ];
    const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals });
    expect(coin.withdrawals).toBe(20n);
  });

  it('sums certificates and proposal procedures for deposit', () => {
    const protocolParameters = { governanceActionDeposit: 4, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const governanceActionDeposit = BigInt(protocolParameters.governanceActionDeposit!);
    const stakeKeyDeposit = BigInt(protocolParameters.stakeKeyDeposit);

    const anchor = {
      dataHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d' as Crypto.Hash32ByteBase16,
      url: 'https://testing.this'
    };
    const certificates: Cardano.Certificate[] = [
      { __typename: Cardano.CertificateType.Registration, deposit: stakeKeyDeposit, stakeCredential }
    ];
    const proposalProcedures: Cardano.ProposalProcedure[] = [
      {
        anchor,
        deposit: governanceActionDeposit,
        governanceAction: { __typename: Cardano.GovernanceActionType.info_action },
        rewardAccount
      }
    ];

    const coin = Cardano.util.computeImplicitCoin(
      protocolParameters,
      { certificates, proposalProcedures },
      [rewardAccount],
      dRepKeyHash
    );

    expect(coin.deposit).toBe(stakeKeyDeposit + governanceActionDeposit);
  });
});
