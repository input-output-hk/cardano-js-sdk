import type { Cardano, ChainHistoryProvider, Paginated, TransactionsByAddressesArgs } from '@cardano-sdk/core';

const NOT_IMPLEMENTED = 'Not implemented';

export const mockChainHistoryProvider: ChainHistoryProvider = {
  blocksByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  healthCheck: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  transactionsByAddresses: (args: TransactionsByAddressesArgs): Promise<Paginated<Cardano.HydratedTx>> => {
    const address = args.addresses.length > 0 ? args.addresses[0] : undefined;

    // Only even payment indices and indices less than 100 will ''return' results.
    if (address) {
      const segments = address.split('_');
      const paymentIndex = Number(segments[1]);
      const stakeIndex = Number(segments[2]);
      const isPaymentEven = paymentIndex % 2 === 0;
      const isExternalAddress = Number(segments[3]) === 0;
      const isStakeAddress = paymentIndex === 0 && stakeIndex > 0;

      return Promise.resolve({
        pageResults: new Array<Cardano.HydratedTx>(),
        totalResultCount: !isStakeAddress && isExternalAddress && isPaymentEven && paymentIndex < 100 ? 1 : 0
      });
    }

    return Promise.resolve({
      pageResults: new Array<Cardano.HydratedTx>(),
      totalResultCount: 0
    });
  },
  transactionsByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  }
};

export const createMockChainHistoryProvider = (addressesWithTx: Map<Cardano.PaymentAddress, number>) => ({
  blocksByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  healthCheck: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  transactionsByAddresses: (args: TransactionsByAddressesArgs): Promise<Paginated<Cardano.HydratedTx>> => {
    const address = args.addresses.length > 0 ? args.addresses[0] : undefined;

    if (address && addressesWithTx.has(address)) {
      return Promise.resolve({
        pageResults: new Array<Cardano.HydratedTx>(),
        totalResultCount: addressesWithTx.get(address)!
      });
    }

    return Promise.resolve({
      pageResults: new Array<Cardano.HydratedTx>(),
      totalResultCount: 0
    });
  },
  transactionsByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  }
});

export const mockAlwaysFailChainHistoryProvider: ChainHistoryProvider = {
  blocksByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  healthCheck: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  transactionsByAddresses: (): Promise<Paginated<Cardano.HydratedTx>> => {
    throw new Error(NOT_IMPLEMENTED);
  },
  transactionsByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  }
};

export const mockAlwaysEmptyChainHistoryProvider: ChainHistoryProvider = {
  blocksByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  healthCheck: () => {
    throw new Error(NOT_IMPLEMENTED);
  },
  transactionsByAddresses: async (): Promise<Paginated<Cardano.HydratedTx>> => ({
    pageResults: [],
    totalResultCount: 0
  }),
  transactionsByHashes: () => {
    throw new Error(NOT_IMPLEMENTED);
  }
};
