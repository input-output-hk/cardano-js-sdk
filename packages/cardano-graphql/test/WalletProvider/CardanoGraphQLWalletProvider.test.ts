import { GraphQLClient } from 'graphql-request';
import { createGraphQLWalletProviderFromSdk } from '../../src/WalletProvider/CardanoGraphQLWalletProvider';
import { getSdk } from '../../src/sdk';

describe('CardanoGraphQLWalletProvider', () => {
  it('returns an object with all provider functions', () => {
    const sdk = getSdk(new GraphQLClient(''));
    const provider = createGraphQLWalletProviderFromSdk(sdk);
    expect(typeof provider.currentWalletProtocolParameters).toBe('function');
    expect(typeof provider.genesisParameters).toBe('function');
    expect(typeof provider.ledgerTip).toBe('function');
    expect(typeof provider.networkInfo).toBe('function');
    expect(typeof provider.queryBlocksByHashes).toBe('function');
    // TODO
    // expect(typeof provider.queryTransactionsByAddresses).toBe('function');
    // expect(typeof provider.queryTransactionsByHashes).toBe('function');
  });
});
