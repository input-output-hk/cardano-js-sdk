/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { WalletProviderFnProps } from '../../../src/WalletProvider/WalletProviderFnProps';
import {
  queryTransactionsByAddressesProvider,
  queryTransactionsByHashesProvider
} from '../../../src/WalletProvider/queryTransactions';

jest.mock('../../../src/WalletProvider/queryTransactions/graphqlTransactionsToCore');
const { graphqlTransactionsToCore } = jest.requireMock(
  '../../../src/WalletProvider/queryTransactions/graphqlTransactionsToCore'
);

describe('WalletProvider/queryTransactions/providers', () => {
  let props: WalletProviderFnProps;
  let sdk: any;

  beforeEach(() => {
    sdk = { TransactionsByAddresses: jest.fn(), TransactionsByHashes: jest.fn() };
    props = { getExactlyOneObject: null as any, sdk };
  });

  afterEach(() => graphqlTransactionsToCore.mockReset());

  describe('queryTransactionsByHashesProvider', () => {
    it('fetches transactions from sdk and maps them to core types', async () => {
      const queryTransaction = 'queryTransaction';
      const queryProtocolParametersAlonzo = 'queryProtocolParametersAlonzo';
      const graphqlTransactionsToCoreResult = 'result';
      sdk.TransactionsByHashes.mockReturnValueOnce({ queryProtocolParametersAlonzo, queryTransaction });
      graphqlTransactionsToCore.mockReturnValueOnce(graphqlTransactionsToCoreResult);
      const hashes = [Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')];
      expect(await queryTransactionsByHashesProvider(props)(hashes)).toBe(graphqlTransactionsToCoreResult);
      expect(sdk.TransactionsByHashes).toHaveBeenCalledWith({ hashes });
      expect(graphqlTransactionsToCore).toHaveBeenCalledWith(
        queryTransaction,
        queryProtocolParametersAlonzo,
        props.getExactlyOneObject
      );
    });
  });

  describe('queryTransactionsByAddressesProvider', () => {
    const addresses = [Cardano.Address('addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24')];

    it('returns an empty array if no transactions are found', async () => {
      sdk.TransactionsByAddresses.mockReturnValueOnce({});
      expect(await queryTransactionsByAddressesProvider(props)(addresses)).toEqual([]);
    });

    it('fetches transactions from sdk and maps them to core types, filtering out duplicates', async () => {
      const tx1 = 'tx1';
      const tx2 = 'tx2';
      const result1 = { id: 'core-tx1' };
      const result2 = { id: 'core-tx2' };
      const queryAddress = [{ inputs: [{ transaction: tx1 }, { transaction: tx1 }], utxo: [{ transaction: tx2 }] }];
      const queryProtocolParametersAlonzo = 'queryProtocolParametersAlonzo';
      sdk.TransactionsByAddresses.mockReturnValueOnce({ queryAddress, queryProtocolParametersAlonzo });
      graphqlTransactionsToCore.mockReturnValueOnce([result1, result1]).mockReturnValueOnce([result2]);
      expect(await queryTransactionsByAddressesProvider(props)(addresses)).toEqual([result1, result2]);
      expect(sdk.TransactionsByAddresses).toHaveBeenCalledWith({ addresses });
      expect(graphqlTransactionsToCore).toHaveBeenCalledTimes(2);
      expect(graphqlTransactionsToCore).toHaveBeenCalledWith(
        [tx1, tx1],
        queryProtocolParametersAlonzo,
        props.getExactlyOneObject
      );
      expect(graphqlTransactionsToCore).toHaveBeenCalledWith(
        [tx2],
        queryProtocolParametersAlonzo,
        props.getExactlyOneObject
      );
    });
  });
});
