import { Cardano } from '@cardano-sdk/core';
import { Ed25519PublicKey, Ed25519PublicKeyHex } from '@cardano-sdk/crypto';

import { GroupedAddress, util } from '../../src';

jest.mock('../../src/util/ownSignatureKeyPaths');
const { ownSignatureKeyPaths } = jest.requireMock('../../src/util/ownSignatureKeyPaths');

describe('KeyManagement.util.stubSignTransaction', () => {
  it('returns as many signatures as number of keys returned by ownSignaturePaths', async () => {
    const txBody = {} as Cardano.HydratedTxBody;
    const knownAddresses = [{} as GroupedAddress];
    const dRepPublicKey = Ed25519PublicKeyHex('0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4');
    const dRepKeyHash = (await Ed25519PublicKey.fromHex(dRepPublicKey).hash()).hex();
    const txInKeyPathMap = {};
    ownSignatureKeyPaths.mockReturnValueOnce(['a']).mockReturnValueOnce(['a', 'b']);
    expect(
      (
        await util.stubSignTransaction({
          context: { dRepPublicKey, knownAddresses, txInKeyPathMap },
          txBody
        })
      ).size
    ).toBe(1);
    expect(
      (
        await util.stubSignTransaction({
          context: { dRepPublicKey, knownAddresses, txInKeyPathMap },
          txBody
        })
      ).size
    ).toBe(2);
    expect(ownSignatureKeyPaths).toBeCalledWith(txBody, knownAddresses, txInKeyPathMap, dRepKeyHash);
  });
});
