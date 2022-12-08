/**
 * Network type (mainnet or **some** testnet)
 */
export enum NetworkId {
  Mainnet = 1,
  Testnet = 0
}

/**
 * Common Cardano NetworkMagics
 */
export enum NetworkMagics {
  Mainnet = 764_824_073,
  Preprod = 1,
  Preview = 2,
  /**
   * Legacy public testnet
   */
  Testnet = 1_097_911_063
}

export type NetworkMagic = number;

/**
 * Network identifier
 */
export interface ChainId {
  networkId: NetworkId;
  networkMagic: NetworkMagic;
}

/**
 * Common Cardano ChainIds
 */
export const ChainIds = {
  LegacyTestnet: {
    networkId: NetworkId.Testnet,
    networkMagic: NetworkMagics.Testnet
  },
  Mainnet: {
    networkId: NetworkId.Mainnet,
    networkMagic: NetworkMagics.Mainnet
  },
  Preprod: {
    networkId: NetworkId.Testnet,
    networkMagic: NetworkMagics.Preprod
  },
  Preview: {
    networkId: NetworkId.Testnet,
    networkMagic: NetworkMagics.Preview
  }
};
