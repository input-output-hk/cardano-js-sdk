import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  GroupedAddress,
  InMemoryKeyAgent,
  KeyPurpose,
  KeyRole,
  SerializableInMemoryKeyAgentData,
  util
} from '../src';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { dummyLogger } from 'ts-log';

jest.mock('../src/util/ownSignatureKeyPaths');
const { ownSignatureKeyPaths } = jest.requireMock('../src/util/ownSignatureKeyPaths');

describe('InMemoryKeyAgent', () => {
  let keyAgent: InMemoryKeyAgent;
  let getPassphrase: jest.Mock;
  let mnemonicWords: string[];
  const bip32Ed25519 = new Crypto.SodiumBip32Ed25519();

  beforeEach(async () => {
    mnemonicWords = util.generateMnemonicWords();
    getPassphrase = jest.fn().mockResolvedValue(Buffer.from('password'));
    keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preview,
        getPassphrase,
        mnemonicWords
      },
      { bip32Ed25519, logger: dummyLogger }
    );
  });

  afterEach(() => getPassphrase.mockReset());

  test('chainId', () => {
    expect(keyAgent.chainId).toEqual(Cardano.ChainIds.Preview);
  });

  test('__typename', () => {
    expect(typeof keyAgent.serializableData.__typename).toBe('string');
  });

  test('accountIndex', () => {
    expect(typeof keyAgent.accountIndex).toBe('number');
  });

  test('fromBip39MnemonicWords with "mnemonic2ndFactorPassphrase" results in different key', async () => {
    const saferKeyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preview,
        getPassphrase,
        mnemonic2ndFactorPassphrase: 'passphrase',
        mnemonicWords
      },
      { bip32Ed25519, logger: dummyLogger }
    );
    expect(await saferKeyAgent.exportRootPrivateKey()).not.toEqual(await keyAgent.exportRootPrivateKey());
  });

  describe('serializableData', () => {
    let serializableData: SerializableInMemoryKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as SerializableInMemoryKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.chainId).toBe('object');
      expect(serializableData.encryptedRootPrivateKeyBytes.length > 0).toBe(true);
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });

  it('has extendedAccountPublicKey', () => {
    expect(typeof keyAgent.extendedAccountPublicKey).toBe('string');
  });

  test('signBlob', async () => {
    const { publicKey, signature } = await keyAgent.signBlob({ index: 0, role: KeyRole.Internal }, HexBlob('abc123'));
    expect(typeof publicKey).toBe('string');
    expect(typeof signature).toBe('string');
  });

  test('signTransaction', async () => {
    ownSignatureKeyPaths.mockReturnValueOnce([
      { index: 0, role: 0 },
      { index: 0, role: 2 }
    ]);
    const body = {
      hash: () => Cardano.TransactionId('8561258e210352fba2ac0488afed67b3427a27ccf1d41ec030c98a8199bc22ec'),
      toCore: () => ({} as unknown as Cardano.HydratedTxBody)
    } as unknown as Serialization.TransactionBody;

    const knownAddresses: GroupedAddress[] = [];
    const txInKeyPathMap = {};
    const witnessSet = await keyAgent.signTransaction(body, {
      knownAddresses,
      txInKeyPathMap
    });
    expect(ownSignatureKeyPaths).toBeCalledWith(body.toCore(), knownAddresses, txInKeyPathMap, expect.anything());
    expect(witnessSet.size).toBe(2);
    expect(typeof [...witnessSet.values()][0]).toBe('string');
  });

  test('exportKeyPair', async () => {
    const { skey, vkey } = await keyAgent.exportExtendedKeyPair([1852, 1815, 0, 0, 0]);
    expect(typeof skey).toBe('string');
    expect(typeof vkey).toBe('string');
  });

  test('deriveAddress', async () => {
    const address = await keyAgent.deriveAddress({ index: 1, type: AddressType.Internal }, 0);
    expect(address).toBeDefined();
  });

  test('exportRootPrivateKey ignores passphrase cache', async () => {
    const privateKey = await keyAgent.exportRootPrivateKey();
    expect(typeof privateKey).toBe('string');
    expect(getPassphrase).toBeCalledTimes(2); // once on initialization of key agent
    expect(getPassphrase).toBeCalledWith(true);
  });

  describe('yoroi compatibility', () => {
    const yoroiMnemonic = [
      'glide',
      'pencil',
      'pitch',
      'genius',
      'actor',
      'cause',
      'worry',
      'spot',
      'noble',
      'essay',
      'yellow',
      'robot',
      'cat',
      'glove',
      'shell'
    ];
    const yoroiRootPrivateKeyHex =
      // eslint-disable-next-line max-len
      '306c8eeeeab20533fde6d8a3272e848b9b669b1b9edae2265b6cde195bc2c3540eab2f531bce7f8adf9afd6257620d80be6f11a02829d7cf61294ef12e2ff7d8636ac76f6aaa14049eb3e90e25153ce080151ceecd86b0ad52f5fb499aa21eb9';
    const yoroiEncryptedRootPrivateKeyHex =
      // eslint-disable-next-line max-len
      '7ec495800df33892c274b954145208c7038d22478f98d7c6843697a964ec10f49856e2c7ee7b2dbf9fa939d3b6b80caee60fa097cb1fb8bfb75271662c8d35c93aa0515f61d79d3f2e21d2dc26d144e83d6791122c45c9b6e1c941b8f71b7904efa16e68c3512e14e30f8831b397c7ddeb56242f376177721eb7d6acd7e99848cd8cf64de5f88e14a6a2e9890329c7d80d91250da96bb1343f22529d';

    it('can decrypt yoroi-encrypted root private key', async () => {
      const keyAgentFromEncryptedKey = new InMemoryKeyAgent(
        {
          accountIndex: 0,
          chainId: Cardano.ChainIds.Preview,
          encryptedRootPrivateKeyBytes: [...Buffer.from(yoroiEncryptedRootPrivateKeyHex, 'hex')],
          extendedAccountPublicKey: await bip32Ed25519.getBip32PublicKey(
            await util.deriveAccountPrivateKey({
              accountIndex: 0,
              bip32Ed25519,
              purpose: KeyPurpose.STANDARD,
              rootPrivateKey: Crypto.Bip32PrivateKeyHex(yoroiRootPrivateKeyHex)
            })
          ),
          getPassphrase,
          purpose: KeyPurpose.STANDARD
        },
        { bip32Ed25519, logger: dummyLogger }
      );
      const exportedPrivateKeyHex = await keyAgentFromEncryptedKey.exportRootPrivateKey();
      expect(exportedPrivateKeyHex).toEqual(yoroiRootPrivateKeyHex);
    });

    it('can import yoroi 15-word mnemonic', async () => {
      const keyAgentFromMnemonic = await InMemoryKeyAgent.fromBip39MnemonicWords(
        {
          chainId: Cardano.ChainIds.Preview,
          getPassphrase,
          mnemonicWords: yoroiMnemonic
        },
        { bip32Ed25519, logger: dummyLogger }
      );
      const exportedPrivateKeyHex = await keyAgentFromMnemonic.exportRootPrivateKey();
      expect(exportedPrivateKeyHex).toEqual(yoroiRootPrivateKeyHex);
    });

    it('can sign correctly', async () => {
      const michaelMnemonic =
        // eslint-disable-next-line max-len
        'defy draw planet sketch security bless chaos candy evolve pupil arrest dismiss involve orphan pass cross envelope burger ghost short rescue penalty song slush'.split(
          ' '
        );
      const keyAgentFromMnemonic = await InMemoryKeyAgent.fromBip39MnemonicWords(
        {
          chainId: Cardano.ChainIds.Preview,
          getPassphrase,
          mnemonicWords: michaelMnemonic
        },
        { bip32Ed25519, logger: dummyLogger }
      );

      ownSignatureKeyPaths.mockReturnValue([{ index: 0, type: KeyRole.External }]);
      const txBody = Serialization.TransactionBody.fromCore({
        fee: 10n,
        inputs: [],
        outputs: [],
        validityInterval: {}
      });
      const signature = await keyAgentFromMnemonic.signTransaction(txBody, { knownAddresses: [], txInKeyPathMap: {} });
      expect(
        signature.has(Crypto.Ed25519PublicKeyHex('0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'))
      ).toBe(true);
    });
  });

  describe('daedelus compatibility', () => {
    const daedelusMnemonic24 = [
      'impulse',
      'mom',
      'alarm',
      'say',
      'comfort',
      'ribbon',
      'spy',
      'almost',
      'symptom',
      'this',
      'gorilla',
      'lift',
      'glance',
      'enter',
      'skill',
      'gap',
      'foam',
      'tragic',
      'easily',
      'cause',
      'wave',
      'medal',
      'parrot',
      'copy'
    ];
    const daedelusStakeAddress = 'stake_test1uqxphnjjvuxwxt0jftxrn7m35sy5px0f7cwwrtkcv42ccxqw2d5xk';
    const daedelusEncryptedRootPrivateKeyHex =
      // eslint-disable-next-line max-len
      '5f7644cb357ba0e255e351574aef9f6971295142b95ce04bcd94d8f54f96fb616fc1fec402578c0b1577a112bc8826faee08c3a7534af31bbe7bb5a20cbef3607ab697b1a28bd93464f233ed4df0184a0905bac41e0f594abafde45eca3ed86b7c34c6aefccad3428649e2ca86b3d93a6da602298b2853d4d556eae24edd6cce';
    const daedalusRootPrivateKeyHex = ''; // TODO;

    // fails to decrypt root private key
    it.skip('can decrypt daedelus-encrypted root private key to produce expected stake address', async () => {
      const keyAgentFromEncryptedKey = new InMemoryKeyAgent(
        {
          accountIndex: 0,
          chainId: Cardano.ChainIds.Preview,
          encryptedRootPrivateKeyBytes: [...Buffer.from(daedelusEncryptedRootPrivateKeyHex, 'hex')],
          extendedAccountPublicKey: await bip32Ed25519.getBip32PublicKey(
            await util.deriveAccountPrivateKey({
              accountIndex: 0,
              bip32Ed25519,
              purpose: KeyPurpose.STANDARD,
              rootPrivateKey: Crypto.Bip32PrivateKeyHex(daedalusRootPrivateKeyHex)
            })
          ),
          // daedelus enforces min length of 10
          getPassphrase: jest.fn().mockResolvedValue(Buffer.from('nMmys*X002')),

          purpose: KeyPurpose.STANDARD
        },
        { bip32Ed25519, logger: dummyLogger }
      );
      const derivedAddress = await keyAgentFromEncryptedKey.deriveAddress(
        {
          index: 1,
          type: AddressType.External
        },
        0
      );
      expect(derivedAddress.rewardAccount).toEqual(daedelusStakeAddress);
    });

    it('can import daedelus 24-word mnemonic to produce expected stake address', async () => {
      const keyAgentFromMnemonic = await InMemoryKeyAgent.fromBip39MnemonicWords(
        {
          chainId: Cardano.ChainIds.Preview,
          getPassphrase,
          mnemonicWords: daedelusMnemonic24
        },
        { bip32Ed25519, logger: dummyLogger }
      );
      const derivedAddress = await keyAgentFromMnemonic.deriveAddress(
        {
          index: 1,
          type: AddressType.External
        },
        0
      );
      expect(derivedAddress.rewardAccount).toEqual(daedelusStakeAddress);
    });
  });
});
