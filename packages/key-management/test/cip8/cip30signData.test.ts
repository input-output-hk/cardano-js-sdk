import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, AsyncKeyAgent, GroupedAddress, KeyAgent, KeyRole, cip8 } from '../../src';
import { Bip32Ed25519 } from '@cardano-sdk/crypto';
import { COSEKey, COSESign1, SigStructure } from '@emurgo/cardano-message-signing-nodejs';
import { Cardano, util } from '@cardano-sdk/core';
import { CoseLabel } from '../../src/cip8/util';
import { DREP_KEY_DERIVATION_PATH } from '../../src/util';
import { HexBlob } from '@cardano-sdk/util';
import { createCoseKey, getAddressBytes } from '../../src/cip8';
import { testAsyncKeyAgent, testKeyAgent } from '../mocks';

describe('cip30signData', () => {
  const payload = HexBlob('abc123');
  const addressDerivationPath = { index: 0, type: AddressType.External };
  let keyAgent: KeyAgent;
  let asyncKeyAgent: AsyncKeyAgent;
  let address: GroupedAddress;
  let drepKeyHex: Crypto.Ed25519PublicKeyHex;
  let drepKeyHash: Crypto.Ed25519KeyHashHex;
  let cryptoProvider: Bip32Ed25519;

  beforeAll(async () => {
    cryptoProvider = await Crypto.SodiumBip32Ed25519.create();
    const keyAgentReady = testKeyAgent();
    keyAgent = await keyAgentReady;
    asyncKeyAgent = await testAsyncKeyAgent(undefined, keyAgentReady);
    address = await asyncKeyAgent.deriveAddress(addressDerivationPath, 0);
    drepKeyHex = await asyncKeyAgent.derivePublicKey(DREP_KEY_DERIVATION_PATH);
    drepKeyHash = Crypto.Ed25519PublicKey.fromHex(drepKeyHex).hash().hex();
  });

  const signAndDecode = async (
    signWith: Cardano.PaymentAddress | Cardano.RewardAccount,
    knownAddresses: GroupedAddress[]
  ) => {
    const dataSignature = await cip8.cip30signData(keyAgent, {
      knownAddresses,
      payload,
      signWith
    });

    const coseKey = COSEKey.from_bytes(Buffer.from(dataSignature.key, 'hex'));
    const coseSign1 = COSESign1.from_bytes(Buffer.from(dataSignature.signature, 'hex'));

    const publicKeyHeader = coseKey.header(CoseLabel.x)!;
    const publicKeyBytes = publicKeyHeader.as_bytes()!;
    const publicKeyHex = util.bytesToHex(publicKeyBytes);
    const signedData = coseSign1.signed_data();
    return { coseKey, coseSign1, publicKeyHex, signedData };
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const testAddressHeader = (signedData: SigStructure, signWith: Cardano.RewardAccount | Cardano.PaymentAddress) => {
    const addressHeader = signedData.body_protected().deserialized_headers().header(CoseLabel.address)!;

    // Subject to change (cbor vs raw bytes argument), PR open: https://github.com/cardano-foundation/CIPs/pull/148
    // An alternative would be addressHeader.to_bytes(), although
    // @emurgo/cardano-message-signing-nodejs only allows CBORValue for headers
    const addressHeaderBytes = addressHeader.as_bytes();

    expect(Buffer.from(addressHeaderBytes!).toString('hex')).toEqual(Cardano.Address.fromBech32(signWith).toBytes());
  };

  it('supports sign with payment address', async () => {
    const signWith = address.address;
    const { signedData, publicKeyHex } = await signAndDecode(signWith, [address]);

    testAddressHeader(signedData, signWith);

    expect(publicKeyHex).toEqual(
      await keyAgent.derivePublicKey({
        index: addressDerivationPath.index,
        role: addressDerivationPath.type as number
      })
    );
  });

  it('supports signing with reward account', async () => {
    const signWith = address.rewardAccount;
    const { signedData, publicKeyHex } = await signAndDecode(signWith, [address]);

    testAddressHeader(signedData, signWith);

    expect(publicKeyHex).toEqual(
      await keyAgent.derivePublicKey({
        index: 0,
        role: KeyRole.Stake
      })
    );
  });

  it('supports signing with drep key hash as bech32 enterprise payment address', async () => {
    const drepAddr = new Cardano.Address({
      paymentPart: {
        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(drepKeyHash),
        type: Cardano.CredentialType.KeyHash
      },
      type: Cardano.AddressType.EnterpriseKey
    });

    const signWith = drepAddr.toBech32();
    if (!signWith) {
      expect(signWith).toBeDefined();
      return;
    }

    const { signedData, publicKeyHex } = await signAndDecode(signWith, [address]);
    testAddressHeader(signedData, signWith);
    expect(publicKeyHex).toEqual(drepKeyHex);
  });

  it('signature can be verified', async () => {
    const signWith = address.address;
    const { coseSign1, publicKeyHex, signedData } = await signAndDecode(signWith, [address]);
    const signedDataBytes = HexBlob.fromBytes(signedData.to_bytes());
    const signatureBytes = HexBlob.fromBytes(coseSign1.signature()) as unknown as Crypto.Ed25519SignatureHex;
    expect(
      cryptoProvider.verify(signatureBytes, signedDataBytes, publicKeyHex as unknown as Crypto.Ed25519PublicKeyHex)
    ).toBe(true);
  });

  describe('createCoseKey', () => {
    it('can create a coseKey structure', async () => {
      const signWith = Cardano.PaymentAddress(
        'addr_test1qrtnkn24fr6dqzsegl5jsnxdehzkth2tskekazzn832wmxl69cvjxcm8f3647hh7s8rzpuvtmhuv7cl3s8gnvmllau6qpg2etl'
      );
      const pubKeyBytes = Crypto.Ed25519PublicKeyHex(
        '3fe822fca223192577130a288b766fcac5b2b8972d89fc229bbc00af60aeaf67'
      );

      // Vector created with Ledger HW version 7.1.1
      const expectedCoseStructureHex =
        'a5010102583900d73b4d5548f4d00a1947e9284ccdcdc565dd4b85b36e88533c54ed9bfa2e192363674c755f5efe81c620f18bddf8cf63f181d1366fffef34032720062158203fe822fca223192577130a288b766fcac5b2b8972d89fc229bbc00af60aeaf67';

      const keyStructure = createCoseKey(getAddressBytes(signWith), pubKeyBytes);

      expect(HexBlob.fromBytes(keyStructure.to_bytes())).toBe(expectedCoseStructureHex);
    });
  });

  describe('getAddressBytes', () => {
    it('can serializes an address to its raw format', async () => {
      const signWith = Cardano.PaymentAddress(
        'addr_test1qrtnkn24fr6dqzsegl5jsnxdehzkth2tskekazzn832wmxl69cvjxcm8f3647hh7s8rzpuvtmhuv7cl3s8gnvmllau6qpg2etl'
      );

      // Vector created with Cardano.Address.toBytes
      const expectedAddressBytes =
        '00d73b4d5548f4d00a1947e9284ccdcdc565dd4b85b36e88533c54ed9bfa2e192363674c755f5efe81c620f18bddf8cf63f181d1366fffef34';

      expect(HexBlob.fromBytes(getAddressBytes(signWith))).toBe(expectedAddressBytes);
    });
  });
});
