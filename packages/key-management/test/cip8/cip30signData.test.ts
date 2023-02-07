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

  beforeAll(async () => {
    const keyAgentReady = testKeyAgent();
    keyAgent = await keyAgentReady;
    asyncKeyAgent = await testAsyncKeyAgent(undefined, undefined, keyAgentReady);
    address = await asyncKeyAgent.deriveAddress(addressDerivationPath);
  });

  const signAndDecode = async (signWith: Cardano.Address | Cardano.RewardAccount) => {
    const dataSignature = await cip8.cip30signData({
      keyAgent: asyncKeyAgent,
      payload: HexBlob('abc123'),
      signWith
    });

    const coseKey = COSEKey.from_bytes(Buffer.from(dataSignature.key, 'hex'));
    const coseSign1 = COSESign1.from_bytes(Buffer.from(dataSignature.signature, 'hex'));

    const publicKeyHeader = coseKey.header(CoseLabel.x)!;
    const publicKeyBytes = publicKeyHeader.as_bytes()!;
    const publicKey = CML.PublicKey.from_bytes(publicKeyBytes);
    const publicKeyHex = util.bytesToHex(publicKeyBytes);
    const signedData = coseSign1.signed_data();
    return { coseKey, coseSign1, publicKey, publicKeyHex, signedData };
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const testAddressHeader = (signedData: SigStructure, signWith: Cardano.RewardAccount | Cardano.Address) => {
    const addressHeader = signedData.body_protected().deserialized_headers().header(CoseLabel.address)!;

    // Subject to change (cbor vs raw bytes argument), PR open: https://github.com/cardano-foundation/CIPs/pull/148
    // An alternative would be addressHeader.to_bytes(), although
    // @emurgo/cardano-message-signing-nodejs only allows CBORValue for headers
    const addressHeaderBytes = addressHeader.as_bytes();

    expect(addressHeaderBytes).toEqual(CML.Address.from_bech32(signWith.toString()).to_bytes());
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
    const { coseSign1, publicKey, signedData } = await signAndDecode(signWith);
    const signedDataBytes = signedData.to_bytes();
    const signatureBytes = coseSign1.signature();
    expect(publicKey.verify(signedDataBytes, CML.Ed25519Signature.from_bytes(signatureBytes))).toBe(true);
  });
});
