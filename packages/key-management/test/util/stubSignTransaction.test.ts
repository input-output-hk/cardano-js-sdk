import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, util } from '../../src';

jest.mock('../../src/util/ownSignatureKeyPaths');
const { ownSignatureKeyPaths } = jest.requireMock('../../src/util/ownSignatureKeyPaths');

describe('KeyManagement.util.stubSignTransaction', () => {
  it('returns as many signatures as number of keys returned by ownSignaturePaths', async () => {
    const inputResolver = {} as Cardano.util.InputResolver; // not called
    const txBody = {} as Cardano.TxBodyAlonzo;
    const knownAddresses = [{} as GroupedAddress];
    ownSignatureKeyPaths.mockReturnValueOnce(['a']).mockReturnValueOnce(['a', 'b']);
    expect((await util.stubSignTransaction(txBody, knownAddresses, inputResolver)).size).toBe(1);
    expect((await util.stubSignTransaction(txBody, knownAddresses, inputResolver)).size).toBe(2);
    expect(ownSignatureKeyPaths).toBeCalledWith(txBody, knownAddresses, inputResolver);
  });
});
