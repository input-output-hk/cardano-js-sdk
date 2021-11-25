export interface RelayByAddress {
  __typename: 'RelayByAddress';
  ipv4?: string;
  ipv6?: string;
  port?: number;
}
export interface RelayByName {
  __typename: 'RelayByName';
  hostname: string;
  port?: number;
}

export interface RelayByNameMultihost {
  __typename: 'RelayByNameMultihost';
  dnsName: string;
}

export type Relay = RelayByAddress | RelayByName | RelayByNameMultihost;
