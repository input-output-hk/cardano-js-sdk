import { ProviderFailure } from '@cardano-sdk/core';
import { getExactlyOneObject } from '../../src/util';
import { ledgerTipProvider } from '../../src/WalletProvider/ledgerTip';

describe('CardanoGraphQLWalletProvider.ledgerTip', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let sdk: any;
  const tip = {
    blockNo: 1,
    hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
    slot: { number: 2 }
  };

  beforeEach(() => {
    sdk = { Tip: jest.fn() };
  });

  it('makes a graphql query and coerces result to core types', async () => {
    sdk.Tip.mockResolvedValueOnce({
      queryBlock: [tip]
    });
    const getLedgerTip = ledgerTipProvider({
      getExactlyOneObject,
      sdk
    });
    expect(await getLedgerTip()).toEqual({
      blockNo: tip.blockNo,
      hash: tip.hash,
      slot: tip.slot.number
    });
  });

  it('uses util.getExactlyOneObject to validate response', async () => {
    sdk.Tip.mockResolvedValueOnce({});
    const getExactlyOneObjectMock = jest.fn().mockImplementation(getExactlyOneObject);
    const getLedgerTip = ledgerTipProvider({
      getExactlyOneObject: getExactlyOneObjectMock,
      sdk
    });
    await expect(getLedgerTip()).rejects.toThrow(ProviderFailure.NotFound);
    expect(getExactlyOneObjectMock).toBeCalledTimes(1);
  });
});
