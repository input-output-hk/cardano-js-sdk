interface StakePoolMetricsStake {
  live: string;
  active: string;
}

interface StakePoolMetricsSize {
  live: number;
  active: number;
}

interface StakePoolMetrics {
  blocksCreated: number;
  livePledge: string;
  stake: StakePoolMetricsStake;
  size: StakePoolMetricsSize;
  saturation: number;
  delegators: number;
}

interface StakePoolTransactions {
  registration: string[];
  retirement: string[];
}

interface StakePoolMetadataJson {
  hash: string;
  url: string;
}

interface StakePoolMetadata {
  ticker: string;
  name: string;
  description: string;
  homepage: string;
  extDataUrl: string | null;
  extSigUrl: string | null;
  extVkey: string | null;
}

interface StakePoolRelayByAddress {
  __typename: 'StakePoolRelayByAddress';
  ipv4: string | null;
  ipv6: string | null;
  port: number;
}
interface StakePoolRelayByName {
  __typename: 'StakePoolRelayByName';
  hostname: string;
  port: number;
}

type StakePoolRelay = StakePoolRelayByAddress | StakePoolRelayByName;

interface StakePool {
  id: string;
  hexId: string;
  owners: string[];
  cost: string;
  margin: number;
  vrf: string;
  relays: StakePoolRelay[];
  rewardAccount: string;
  pledge: string;
  metrics: StakePoolMetrics;
  transactions: StakePoolTransactions;
  metadataJson: StakePoolMetadataJson;
  metadata: StakePoolMetadata;
}

export interface StakePoolsQueryResponse {
  stakePools: StakePool[];
}
