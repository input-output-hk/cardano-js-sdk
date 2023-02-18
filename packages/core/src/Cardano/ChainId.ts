/**
 * The "network ID" identifies a network in the Cardano blockchain, it is included in every address and also
 * optionally present in the transaction body.
 *
 * This can only store 16 possibilities (4 bits).
 */
export enum NetworkId {
  Mainnet = 1,
  Testnet = 0
}

/**
 * This Network magic a parameter introduced in Cardano during the Byron era. It is used internally by the protocol in
 * cryptographic functions that construct addresses from a seed. Since this value is different for each network,
 * the address obtained from a given path (or seed) is different.
 */
export type NetworkMagic = number;

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

/**
 * Tuple of values designed to uniquely identify a network in the Cardano blockchain.
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
