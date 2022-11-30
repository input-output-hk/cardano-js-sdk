/**
 * Network type (mainnet or **some** testnet)
 */
export enum NetworkId {
  Mainnet = 1,
  Testnet = 0
}

export enum CardanoNetworkMagic {
  Mainnet = 764_824_073,
  Preprod = 1,
  Preview = 2,
  /**
   * Legacy public testnet
   */
  Testnet = 1_097_911_063
}

export type CardanoNetworkId = keyof typeof CardanoNetworkMagic;
export type NetworkMagic = number;
