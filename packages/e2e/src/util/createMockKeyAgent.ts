import { Bip32PublicKeyHex, SodiumBip32Ed25519 } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, KeyAgent, KeyAgentType, KeyPurpose } from '@cardano-sdk/key-management';

const accountIndex = 0;
const chainId = Cardano.ChainIds.Preview;
const extendedAccountPublicKey = Bip32PublicKeyHex(
  '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
);

export const createMockKeyAgent = async (
  deriveAddressesReturn: GroupedAddress[] = []
): Promise<jest.Mocked<KeyAgent>> => {
  const remainingDeriveAddressesReturn = [...deriveAddressesReturn];
  return {
    accountIndex,
    bip32Ed25519: await SodiumBip32Ed25519.create(),
    chainId,
    deriveAddress: jest.fn().mockImplementation(async () => remainingDeriveAddressesReturn.shift()),
    derivePublicKey: jest.fn(),
    exportRootPrivateKey: jest.fn(),
    extendedAccountPublicKey,
    purpose: KeyPurpose.STANDARD,
    serializableData: {
      __typename: KeyAgentType.InMemory,
      accountIndex,
      chainId,
      encryptedRootPrivateKeyBytes: [],
      extendedAccountPublicKey,
      purpose: KeyPurpose.STANDARD
    },
    signBlob: jest.fn(),
    signCip8Data: jest.fn(),
    signTransaction: jest.fn()
  };
};
