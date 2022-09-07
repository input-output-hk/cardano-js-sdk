import { Address, Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '../../../src/KeyManagement';
import { stubSignTransaction } from '../../../src/KeyManagement/util';

jest.mock('../../../src/KeyManagement/util/ownSignatureKeyPaths');
const { ownSignatureKeyPaths } = jest.requireMock('../../../src/KeyManagement/util/ownSignatureKeyPaths');

describe('KeyManagement.util.stubSignTransaction', () => {
  it('returns as many signatures as number of keys returned by ownSignaturePaths', async () => {
    const inputResolver = {} as Address.util.InputResolver; // not called
    const txBody = {} as Cardano.TxBodyAlonzo;
    const knownAddresses = [{} as GroupedAddress];
    ownSignatureKeyPaths.mockReturnValueOnce(['a']).mockReturnValueOnce(['a', 'b']);
    expect((await stubSignTransaction(txBody, knownAddresses, inputResolver)).size).toBe(1);
    expect((await stubSignTransaction(txBody, knownAddresses, inputResolver)).size).toBe(2);
    expect(ownSignatureKeyPaths).toBeCalledWith(txBody, knownAddresses, inputResolver);
  });
});
