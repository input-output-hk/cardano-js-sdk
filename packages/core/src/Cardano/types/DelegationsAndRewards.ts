import { Lovelace } from './Value';
import { Metadatum } from './AuxiliaryData';
import { PoolId, PoolIdHex, StakePool } from './StakePool';
import { RewardAccount } from '../Address';
import { metadatumToJson } from '../../util/metadatum';

export interface DelegationsAndRewards {
  delegate?: PoolId;
  rewards: Lovelace;
}

export interface Delegatee {
  /** Rewards at the end of current epoch will be from this stake pool */
  currentEpoch?: StakePool;
  nextEpoch?: StakePool;
  nextNextEpoch?: StakePool;
}

export enum StakeCredentialStatus {
  Registering = 'REGISTERING',
  Registered = 'REGISTERED',
  Unregistering = 'UNREGISTERING',
  Unregistered = 'UNREGISTERED'
}

export interface RewardAccountInfo {
  address: RewardAccount;
  credentialStatus: StakeCredentialStatus;
  delegatee?: Delegatee;
  rewardBalance: Lovelace;
  // Maybe add rewardsHistory for each reward account too
  deposit?: Lovelace; // defined only when keyStatus is Registered
}

export interface Cip17Pool {
  id: PoolIdHex;
  weight: number;
  name?: string;
  ticker?: string;
}
export interface Cip17DelegationPortfolio {
  name: string;
  pools: Cip17Pool[];
  description?: string;
  author?: string;
}

// On chain portfolio metadata
export const DelegationMetadataLabel = 6862n; // 0x1ace
export type DelegationPortfolioMetadata = Exclude<Cip17DelegationPortfolio, 'pools'> & {
  pools: Pick<Cip17Pool, 'id' | 'weight'>[];
};

export const portfolioMetadataFromCip17 = (cip17: Cip17DelegationPortfolio): DelegationPortfolioMetadata => {
  const portfolio = { ...cip17 };

  portfolio.pools = cip17.pools.map((pool) => ({
    id: pool.id,
    weight: pool.weight
  }));

  return portfolio as DelegationPortfolioMetadata;
};

export const cip17FromMetadatum = (portfolio: Metadatum): Cip17DelegationPortfolio => {
  const cip17 = metadatumToJson(portfolio);

  for (const pool of cip17.pools) {
    // Metadatum serializes/deserializes numbers as bigints
    pool.weight = Number(pool.weight);
  }

  return cip17 as Cip17DelegationPortfolio;
};
