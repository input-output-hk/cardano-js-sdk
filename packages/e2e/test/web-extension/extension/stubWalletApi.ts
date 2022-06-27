import { Cardano, coreToCsl } from '@cardano-sdk/core';
import { Cip30DataSignature, WalletApi } from '@cardano-sdk/cip30';

const mapUtxos = (utxos: Cardano.Utxo[]) =>
  coreToCsl.utxo(utxos).map((utxo) => Buffer.from(utxo.to_bytes()).toString('hex'));

export const stubWalletApi: WalletApi = {
  getBalance: async () => '100',
  getChangeAddress: async () =>
    'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x',
  getCollateral: async () =>
    mapUtxos([
      [
        {
          address: Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
          index: 1,
          txId: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8')
        },
        {
          address: Cardano.Address(
            // eslint-disable-next-line max-len
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
          ),
          value: { coins: 5n }
        }
      ]
    ]),
  getNetworkId: async () => 0,
  getRewardAddresses: async () => ['stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'],
  getUnusedAddresses: async () => [],
  getUsedAddresses: async () => [
    'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
  ],
  getUtxos: async () =>
    mapUtxos([
      [
        {
          address: Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
          index: 0,
          txId: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8')
        },
        {
          address: Cardano.Address(
            // eslint-disable-next-line max-len
            'addr_test1qra788mu4sg8kwd93ns9nfdh3k4ufxwg4xhz2r3n064tzfgxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flkns6cy45x'
          ),
          value: { coins: 100n }
        }
      ]
    ]),
  signData: async (_addr, _payload) =>
    ({
      key: 'key',
      signature: 'signature'
    } as unknown as Cip30DataSignature),
  signTx: async (_tx) => 'signedTransaction',
  submitTx: async (_tx) => 'transactionId'
};
