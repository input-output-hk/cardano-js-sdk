import { Cardano, DRepProvider, RewardAccountInfoProvider, Serialization, StakePoolProvider } from '@cardano-sdk/core';

import { BlockfrostClient, BlockfrostProvider, fetchSequentially, isBlockfrostNotFoundError } from '../blockfrost';
import { HexBlob, isNotNil } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import uniq from 'lodash/uniq.js';
import type { Responses } from '@blockfrost/blockfrost-js';

export type BlockfrostRewardAccountInfoProviderDependencies = {
  client: BlockfrostClient;
  logger: Logger;
  stakePoolProvider: StakePoolProvider;
  dRepProvider: DRepProvider;
};

const emptyArrayIfNotFound = (error: unknown) => {
  if (isBlockfrostNotFoundError(error)) {
    return [];
  }
  throw error;
};

export class BlockfrostRewardAccountInfoProvider extends BlockfrostProvider implements RewardAccountInfoProvider {
  #dRepProvider: DRepProvider;
  #stakePoolProvider: StakePoolProvider;

  constructor({ client, logger, stakePoolProvider, dRepProvider }: BlockfrostRewardAccountInfoProviderDependencies) {
    super(client, logger);
    this.#dRepProvider = dRepProvider;
    this.#stakePoolProvider = stakePoolProvider;
  }

  async rewardAccountInfo(
    address: Cardano.RewardAccount,
    localEpoch: Cardano.EpochNo
  ): Promise<Cardano.RewardAccountInfo> {
    const [account, [lastRegistrationActivity]] = await Promise.all([
      await this.request<Responses['account_content']>(`accounts/${address}`).catch(
        (error): Responses['account_content'] => {
          if (isBlockfrostNotFoundError(error)) {
            return {
              active: false,
              active_epoch: null,
              controlled_amount: '0',
              drep_id: null,
              pool_id: null,
              reserves_sum: '0',
              rewards_sum: '0',
              stake_address: address,
              treasury_sum: '0',
              withdrawable_amount: '0',
              withdrawals_sum: '0'
            };
          }
          throw error;
        }
      ),
      this.request<Responses['account_registration_content']>(
        `accounts/${address}/registrations?order=desc&count=1`
      ).catch(emptyArrayIfNotFound)
    ]);

    const isUnregisteringAtEpoch = await this.#getUnregisteringAtEpoch(lastRegistrationActivity);

    const credentialStatus = account.active
      ? Cardano.StakeCredentialStatus.Registered
      : lastRegistrationActivity?.action === 'registered'
      ? Cardano.StakeCredentialStatus.Registering
      : typeof isUnregisteringAtEpoch === 'undefined' || isUnregisteringAtEpoch <= localEpoch
      ? Cardano.StakeCredentialStatus.Unregistered
      : Cardano.StakeCredentialStatus.Unregistering;
    const rewardBalance = BigInt(account.withdrawable_amount || '0');

    const [delegatee, dRepDelegatee, deposit] = await Promise.all([
      this.#getDelegatee(address, localEpoch, isUnregisteringAtEpoch),
      this.#getDrepDelegatee(account),
      // This provider currently does not find other deposits (pool/drep/govaction)
      this.#getKeyDeposit(lastRegistrationActivity)
    ]);

    return {
      address,
      credentialStatus,
      dRepDelegatee,
      delegatee,
      deposit,
      rewardBalance
    };
  }

  async delegationPortfolio(rewardAccount: Cardano.RewardAccount): Promise<Cardano.Cip17DelegationPortfolio | null> {
    const portfolios = await fetchSequentially({
      haveEnoughItems: (items: Array<null | Cardano.Cip17DelegationPortfolio>) => items.some(isNotNil),
      paginationOptions: { order: 'desc' },
      request: async (paginationQueryString) => {
        const txs = await this.request<Responses['account_delegation_content']>(
          `accounts/${rewardAccount}/delegations?${paginationQueryString}`
        ).catch(emptyArrayIfNotFound);
        const result: Array<null | Cardano.Cip17DelegationPortfolio> = [];
        for (const { tx_hash } of txs) {
          const metadata = await this.request<Responses['tx_content_metadata_cbor']>(
            `txs/${tx_hash}/metadata/cbor`
          ).catch(emptyArrayIfNotFound);
          const cbor = metadata.find(({ label }) => label === '6862')?.metadata;
          if (!cbor) {
            result.push(null);
            continue;
          }
          const metadatum = Serialization.TransactionMetadatum.fromCbor(HexBlob(cbor));
          try {
            result.push(Cardano.cip17FromMetadatum(metadatum.toCore()));
            break;
          } catch {
            result.push(null);
          }
        }
        return result;
      }
    });
    return portfolios.find(isNotNil) || null;
  }

  async #getUnregisteringAtEpoch(
    lastRegistrationActivity: Responses['account_registration_content'][0] | undefined
  ): Promise<Cardano.EpochNo | undefined> {
    if (!lastRegistrationActivity || lastRegistrationActivity.action === 'registered') {
      return;
    }
    const tx = await this.request<Responses['tx_content']>(`txs/${lastRegistrationActivity.tx_hash}`);
    const block = await this.request<Responses['block_content']>(`blocks/${tx.block}`);
    return Cardano.EpochNo(block.epoch!);
  }

  async #getDrepDelegatee(account: Responses['account_content']): Promise<Cardano.DRepDelegatee | undefined> {
    if (!account.drep_id) return;
    if (account.drep_id === 'drep_always_abstain') {
      return { delegateRepresentative: { __typename: 'AlwaysAbstain' } };
    }
    if (account.drep_id === 'drep_always_no_confidence') {
      return { delegateRepresentative: { __typename: 'AlwaysNoConfidence' } };
    }
    const cip129DrepId = Cardano.DRepID.toCip129DRepID(Cardano.DRepID(account.drep_id));
    const dRepInfo = await this.#dRepProvider.getDRepInfo({ id: cip129DrepId });
    return {
      delegateRepresentative: dRepInfo
    };
  }

  async #getKeyDeposit(lastRegistrationActivity: Responses['account_registration_content'][0] | undefined) {
    if (!lastRegistrationActivity || lastRegistrationActivity.action === 'deregistered') {
      return 0n;
    }
    const tx = await this.request<Responses['tx_content']>(`txs/${lastRegistrationActivity.tx_hash}`);
    const block = await this.request<Responses['block_content']>(`blocks/${tx.block}`);
    const epochParameters = await this.request<Responses['epoch_param_content']>(`epochs/${block.epoch}/parameters`);
    return BigInt(epochParameters.key_deposit);
  }

  async #getDelegatee(
    address: Cardano.RewardAccount,
    currentEpoch: Cardano.EpochNo,
    isUnregisteringAtEpoch: Cardano.EpochNo | undefined
  ): Promise<Cardano.Delegatee | undefined> {
    const delegationHistory = await fetchSequentially<Responses['account_delegation_content'][0]>({
      haveEnoughItems: (items) => items[items.length - 1]?.active_epoch <= currentEpoch,
      paginationOptions: { order: 'desc' },
      request: (paginationQueryString) => this.request(`accounts/${address}/delegations?${paginationQueryString}`)
    });

    const isRegisteredAt = (epochFromNow: number): true | undefined => {
      if (!isUnregisteringAtEpoch) {
        return true;
      }
      return isUnregisteringAtEpoch > currentEpoch + epochFromNow || undefined;
    };

    const poolIds = [
      // current epoch
      isRegisteredAt(0) && delegationHistory.find(({ active_epoch }) => active_epoch <= currentEpoch)?.pool_id,
      // next epoch
      isRegisteredAt(1) && delegationHistory.find(({ active_epoch }) => active_epoch <= currentEpoch + 1)?.pool_id,
      // next next epoch
      isRegisteredAt(2) && delegationHistory.find(({ active_epoch }) => active_epoch <= currentEpoch + 2)?.pool_id
    ] as Array<Cardano.PoolId | undefined>;

    const poolIdsToFetch = uniq(poolIds.filter(isNotNil));
    if (poolIdsToFetch.length === 0) {
      return undefined;
    }

    const stakePools = await this.#stakePoolProvider.queryStakePools({
      filters: { identifier: { values: poolIdsToFetch.map((id) => ({ id })) } },
      pagination: { limit: 3, startAt: 0 }
    });

    const stakePoolMathingPoolId = (index: number) => stakePools.pageResults.find((pool) => pool.id === poolIds[index]);
    return {
      currentEpoch: stakePoolMathingPoolId(0),
      nextEpoch: stakePoolMathingPoolId(1),
      nextNextEpoch: stakePoolMathingPoolId(2)
    };
  }
}
