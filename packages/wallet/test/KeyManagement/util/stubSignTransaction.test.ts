import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '../../../src/KeyManagement';
import { stubSignTransaction } from '../../../src/KeyManagement/util';

jest.mock('../../../src/KeyManagement/util/ownSignatureKeyPaths');
const { ownSignatureKeyPaths } = jest.requireMock('../../../src/KeyManagement/util/ownSignatureKeyPaths');

describe('KeyManagement.util.stubSignTransaction', () => {
  it('returns as many signatures as number of keys returned by ownSignaturePaths', () => {
    const txBody = {} as Cardano.TxBodyAlonzo;
    const knownAddresses = [{} as GroupedAddress];
    ownSignatureKeyPaths.mockReturnValueOnce([{}]).mockReturnValueOnce([{}, {}]);
    expect(stubSignTransaction(txBody, knownAddresses).size).toBe(1);
    expect(stubSignTransaction(txBody, knownAddresses).size).toBe(2);
    expect(ownSignatureKeyPaths).toBeCalledWith(txBody, knownAddresses);
  });
});
