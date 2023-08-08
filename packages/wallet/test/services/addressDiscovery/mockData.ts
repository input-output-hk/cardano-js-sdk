import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, AsyncKeyAgent, GroupedAddress, KeyRole } from '@cardano-sdk/key-management';
import { BehaviorSubject } from 'rxjs';
import { CML, Cardano, ChainHistoryProvider, Paginated, TransactionsByAddressesArgs } from '@cardano-sdk/core';

const NOT_IMPLEMENTED = 'Not implemented';

const createMockAsyncKeyAgent = (knownAddresses: Array<Array<GroupedAddress>>): AsyncKeyAgent => {
  let currentKnownAddresses = new Array<GroupedAddress>();
  const knownAddresses$ = new BehaviorSubject(currentKnownAddresses);
  return {
    async deriveAddress(derivationPath, stakeKeyDerivationIndex: number, pure?: boolean) {
      const address = { ...knownAddresses[derivationPath.index][stakeKeyDerivationIndex] };
      address.type = derivationPath.type;
      address.address = `${address.address}_${derivationPath.type}` as Cardano.PaymentAddress;

      if (!pure) currentKnownAddresses.push(address);

      return address;
    },
    derivePublicKey: () => Promise.resolve('00' as unknown as Crypto.Ed25519PublicKeyHex),
    getBip32Ed25519: () => Promise.resolve(new Crypto.CmlBip32Ed25519(CML)),
    getChainId: () =>
      Promise.resolve({
        networkId: 0,
        networkMagic: 0
      }),
    getExtendedAccountPublicKey: () => Promise.resolve('00' as unknown as Crypto.Bip32PublicKeyHex),
    knownAddresses$,
    setKnownAddresses: async (addresses: GroupedAddress[]): Promise<void> => {
      currentKnownAddresses = addresses;
      knownAddresses$.next(currentKnownAddresses);
    },
    // eslint-disable-next-line @typescript-eslint/no-empty-function
    shutdown: () => {},
    signBlob: () =>
      Promise.resolve({
        publicKey: '00' as unknown as Crypto.Ed25519PublicKeyHex,
        signature: '00' as unknown as Crypto.Ed25519SignatureHex
      }),
    signTransaction: () => Promise.resolve(new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>())
  };
};

export const prepareMockKeyAgentWithData = () => {
  const data = new Array<Array<GroupedAddress>>();
  const stakeKeys = new Array<GroupedAddress>();

  // Add 20 stake addresses credentials.
  for (let i = 0; i < 20; ++i) {
    stakeKeys.push({
      accountIndex: 0,
      address: `testAddress_0_${i}` as unknown as Cardano.PaymentAddress,
      index: i,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: `testStakeAddress_${i}` as unknown as Cardano.RewardAccount,
      stakeKeyDerivationPath: {
        index: i,
        role: KeyRole.Stake
      },
      type: AddressType.External
    });
  }

  data.push(stakeKeys);

  for (let i = 1; i < 200; ++i) {
    data.push([
      {
        accountIndex: 0,
        address: `testAddress_${i}_0` as unknown as Cardano.PaymentAddress,
        index: i,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount: 'testStakeAddress_0' as unknown as Cardano.RewardAccount,
        stakeKeyDerivationPath: {
          index: 0,
          role: KeyRole.Stake
        },
        type: AddressType.External
      }
    ]);
  }

  return createMockAsyncKeyAgent(data);
};

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
