/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
/* eslint-disable prettier/prettier */
import { queryTransactionsResult } from '../mocks';

jest.mock('@emurgo/cardano-serialization-lib-nodejs', () => ({
  ...jest.requireActual('@emurgo/cardano-serialization-lib-nodejs'),
  hash_transaction: () => ({ to_bytes: () => new Uint8Array(Buffer.from(queryTransactionsResult[0].id, 'hex')) })
}));

// const cslTx = async (tx: Cardano.TxAlonzo, changeAddress: Cardano.Address) => {
//   const { body } = await createTransactionInternals({
//     changeAddress,
//     inputSelection: {
//       change: new Set(),
//       fee: CSL.BigNum.from_str('0'),
//       inputs: new Set(
//         tx.body.inputs
//           .map(txIn => [txIn, utxo[0][1]] as const) // use any TxOut, not relevant for these tests
//           .map(([txIn, txOut]) => coreToCsl.utxo([[txIn, txOut]]))[0]),
//       outputs: new Set(tx.body.outputs.map(coreToCsl.txOut))
//     },
//     validityInterval: {}
//   });
//   const witnessSet = CSL.TransactionWitnessSet.new();
//   return CSL.Transaction.new(body, witnessSet);
// };

describe('createTransactionsTracker', () => {
  it.todo('fetches transactions from WalletProvider');
  // it('fetches transactions from WalletProvider', async () => {
  //   const address = queryTransactionsResult[0].body.inputs[0].address;
  //   const provider = providerStub();
  //   const transactionsProvider = createAddressTransactionsProvider$(provider, [address]);
  //   const tx = await cslTx(queryTransactionsResult[0], address);
  //   const incomingTx = { direction: TransactionDirection.Incoming, tx: queryTransactionsResult[0] };
  //   const outgoingTx = { direction: TransactionDirection.Outgoing, tx: queryTransactionsResult[0] };
  //   createTestScheduler().run(({ cold, expectObservable }) => {
  //     const failedToSubmit$ = cold<FailedTx>( '----|');
  //     const tip$ = cold<Cardano.Tip>(         '----|');
  //     const submitting$ = cold(               '-a--|', { a: tx });
  //     const pending$ = cold(                  '--a-|', { a: tx });
  //     const transactionsSource$ = cold(       'a-bc|', {
  //       a: [],
  //       b: [incomingTx],
  //       c: [incomingTx, outgoingTx]
  //     }) as unknown as ProviderTrackerSubject<DirectionalTransaction[]>;
  //     const transactionsTracker = createTransactionsTracker(
  //       {
  //         config: { maxInterval: 100, pollInterval: 100 }, // not relevant, overwriting transactionsSource$
  //         newTransactions: {
  //           failedToSubmit$,
  //           pending$,
  //           submitting$
  //         },
  //         tip$,
  //         transactionsProvider
  //       },
  //       {
  //         transactionsSource$
  //       }
  //     );
  //     expectObservable(transactionsTracker.incoming$).toBe('--a-|', { a: incomingTx.tx });
  //     expectObservable(transactionsTracker.outgoing.submitting$).toBe('-a--|', { a: tx });
  //     expectObservable(transactionsTracker.outgoing.pending$).toBe('--a-|', { a: tx });
  //     expectObservable(transactionsTracker.outgoing.confirmed$).toBe('---a|', { a: tx });
  //     expectObservable(transactionsTracker.outgoing.inFlight$).toBe('a-b-|', { a: [tx], b: [] });
  //     expectObservable(transactionsTracker.outgoing.failed$).toBe('----|');
  //     expectObservable(transactionsTracker.history.incoming$).toBe('--ab|',
  // { a: [incomingTx.tx], b: [incomingTx.tx] });
  //     expectObservable(transactionsTracker.history.outgoing$).toBe('---a|', { a: [outgoingTx.tx] });
  //     expectObservable(transactionsTracker.history.all$).toBe('--ab|', {
  //       a: [incomingTx], b: [incomingTx, outgoingTx]
  //     });
  //   });
  // });
});
