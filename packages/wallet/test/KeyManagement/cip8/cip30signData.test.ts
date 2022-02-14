import { Address, Ed25519Signature, PublicKey } from '@emurgo/cardano-serialization-lib-nodejs';
import { AddressType, KeyAgent, KeyType } from '../../../src/KeyManagement';
import { COSEKey, COSESign1, SigStructure } from '@emurgo/cardano-message-signing-nodejs';
import { Cardano, util } from '@cardano-sdk/core';
import { CoseLabel } from '../../../src/KeyManagement/cip8/util';
import { cip30signData } from '../../../src/KeyManagement/cip8';
import { testKeyAgent } from '../../mocks';

describe('cip30signData', () => {
  const addressDerivationPath = { index: 0, type: AddressType.External };
  let keyAgent: KeyAgent;

  beforeAll(async () => {
    keyAgent = await testKeyAgent();
    await keyAgent.deriveAddress(addressDerivationPath);
  });

  const signAndDecode = async (signWith: Cardano.Address | Cardano.RewardAccount) => {
    const dataSignature = await cip30signData({
      keyAgent,
      payload: Cardano.util.HexBlob('abc123'),
      signWith
    });

    const coseKey = COSEKey.from_bytes(Buffer.from(dataSignature.key, 'hex'));
    const coseSign1 = COSESign1.from_bytes(Buffer.from(dataSignature.signature, 'hex'));

    const publicKeyHeader = coseKey.header(CoseLabel.x)!;
    const publicKeyBytes = publicKeyHeader.as_bytes()!;
    const publicKey = PublicKey.from_bytes(publicKeyBytes);
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

    expect(addressHeaderBytes).toEqual(Address.from_bech32(signWith.toString()).to_bytes());
  };

  it('supports sign with payment address', async () => {
    const signWith = keyAgent.knownAddresses[0].address;
    const { signedData, publicKeyHex } = await signAndDecode(signWith);

    testAddressHeader(signedData, signWith);

    expect(publicKeyHex).toEqual(
      await keyAgent.derivePublicKey({
        index: addressDerivationPath.index,
        type: addressDerivationPath.type as number
      })
    );
  });

  it('supports signing with reward account', async () => {
    const signWith = keyAgent.knownAddresses[0].rewardAccount;
    const { signedData, publicKeyHex } = await signAndDecode(signWith);

    testAddressHeader(signedData, signWith);

    expect(publicKeyHex).toEqual(
      await keyAgent.derivePublicKey({
        index: 0,
        type: KeyType.Stake
      })
    );
  });

  it('signature can be verified', async () => {
    const signWith = keyAgent.knownAddresses[0].address;
    const { coseSign1, publicKey, signedData } = await signAndDecode(signWith);
    const signedDataBytes = signedData.to_bytes();
    const signatureBytes = coseSign1.signature();
    expect(publicKey.verify(signedDataBytes, Ed25519Signature.from_bytes(signatureBytes))).toBe(true);
  });
});
