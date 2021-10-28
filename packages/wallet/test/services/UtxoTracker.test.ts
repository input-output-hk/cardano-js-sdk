import { Cardano } from '@cardano-sdk/core';
import { NewTx } from '../../src/prototype';
import { ProviderTrackerSubject, createUtxoProvider$, createUtxoTracker } from '../../src/services';
import { createTestScheduler } from '../testScheduler';
import { providerStub, utxo } from '../mocks';

// eslint-disable-next-line sonarjs/no-duplicate-string
jest.mock('@cardano-sdk/core', () => ({
  ...jest.requireActual('@cardano-sdk/core'),
  cslToCore: {
    ...jest.requireActual('@cardano-sdk/core').cslToCore,
    txInputs: () => [utxo[0][0]]
  }
}));

describe('createUtxoTracker', () => {
  it('fetches utxo from WalletProvider and locks when spent in a transaction in flight', () => {
    const address = utxo[0][0].address;
    const provider = providerStub();
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a-b|', {
        a: [],
        b: [
          {
            body: () => ({
              inputs: () => ({
                get: () => null, // converted to [utxo[0][0]] in jest.mock above
                len: () => 1
              })
            })
          } as unknown as NewTx
        ]
      });
      const utxoTracker = createUtxoTracker(
        {
          config: { maxInterval: 100, pollInterval: 100 }, // not relevant for this test, overwriting utxoSource$
          transactionsInFlight$,
          utxoProvider: createUtxoProvider$(provider, [address])
        },
        { utxoSource$: cold('a---|', { a: utxo }) as unknown as ProviderTrackerSubject<Cardano.Utxo[]> }
      );
      expectObservable(utxoTracker.total$).toBe('a---|', { a: utxo });
      expectObservable(utxoTracker.available$).toBe('-a-b|', {
        a: utxo,
        b: utxo.slice(1)
      });
    });
  });
});
