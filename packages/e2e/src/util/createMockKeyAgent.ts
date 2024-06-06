import { Bip32PublicKeyHex, SodiumBip32Ed25519 } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { KeyAgentType } from '@cardano-sdk/key-management';
import type { GroupedAddress, KeyAgent } from '@cardano-sdk/key-management';

const accountIndex = 0;
const chainId = Cardano.ChainIds.Preview;
const extendedAccountPublicKey = Bip32PublicKeyHex(
  '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
);

export const createMockKeyAgent = (deriveAddressesReturn: GroupedAddress[] = []): jest.Mocked<KeyAgent> => {
  const remainingDeriveAddressesReturn = [...deriveAddressesReturn];
  return {
    accountIndex,
    bip32Ed25519: new SodiumBip32Ed25519(),
    chainId,
    deriveAddress: jest.fn().mockImplementation(async () => remainingDeriveAddressesReturn.shift()),
    derivePublicKey: jest.fn(),
    exportRootPrivateKey: jest.fn(),
    extendedAccountPublicKey,
    serializableData: {
      __typename: KeyAgentType.InMemory,
      accountIndex,
      chainId,
      encryptedRootPrivateKeyBytes: [],
      extendedAccountPublicKey
    },
    signBlob: jest.fn(),
    signTransaction: jest.fn()
  };
};
