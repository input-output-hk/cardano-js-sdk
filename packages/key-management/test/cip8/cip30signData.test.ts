import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, AsyncKeyAgent, GroupedAddress, KeyAgent, KeyRole, cip8 } from '../../src';
import { CML, Cardano, util } from '@cardano-sdk/core';
import { COSEKey, COSESign1, SigStructure } from '@emurgo/cardano-message-signing-nodejs';
import { CoseLabel } from '../../src/cip8/util';
import { HexBlob } from '@cardano-sdk/util';
import { testAsyncKeyAgent, testKeyAgent } from '../mocks';

describe('cip30signData', () => {
  const addressDerivationPath = { index: 0, type: AddressType.External };
  let keyAgent: KeyAgent;
  let asyncKeyAgent: AsyncKeyAgent;
  let address: GroupedAddress;
  const cryptoProvider = new Crypto.CmlBip32Ed25519(CML);

  beforeAll(async () => {
    const keyAgentReady = testKeyAgent();
    keyAgent = await keyAgentReady;
    asyncKeyAgent = await testAsyncKeyAgent(undefined, undefined, keyAgentReady);
    address = await asyncKeyAgent.deriveAddress(addressDerivationPath, 0);
  });

  const signAndDecode = async (signWith: Cardano.PaymentAddress | Cardano.RewardAccount) => {
    const dataSignature = await cip8.cip30signData({
      keyAgent: asyncKeyAgent,
      payload: HexBlob('abc123'),
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
    const { signedData, publicKeyHex } = await signAndDecode(signWith);

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
    const { signedData, publicKeyHex } = await signAndDecode(signWith);

    testAddressHeader(signedData, signWith);

    expect(publicKeyHex).toEqual(
      await keyAgent.derivePublicKey({
        index: 0,
        role: KeyRole.Stake
      })
    );
  });

  it('signature can be verified', async () => {
    const signWith = address.address;
    const { coseSign1, publicKeyHex, signedData } = await signAndDecode(signWith);
    const signedDataBytes = HexBlob.fromBytes(signedData.to_bytes());
    const signatureBytes = HexBlob.fromBytes(coseSign1.signature()) as unknown as Crypto.Ed25519SignatureHex;
    expect(
      await cryptoProvider.verify(
        signatureBytes,
        signedDataBytes,
        publicKeyHex as unknown as Crypto.Ed25519PublicKeyHex
      )
    ).toBe(true);
  });
});
