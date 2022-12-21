export enum NetworkId {
  Mainnet = 1,
  Testnet = 0
}

export enum CardanoNetworkMagic {
  Mainnet = 764_824_073,
  Testnet = 1_097_911_063
}

export type CardanoNetworkId = keyof typeof CardanoNetworkMagic;
export type NetworkMagic = number;
