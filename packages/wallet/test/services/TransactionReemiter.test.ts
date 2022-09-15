import { Cardano } from '@cardano-sdk/core';
import { InMemoryVolatileTransactionsStore, WalletStores } from '../../src/persistence';
import { Logger, dummyLogger } from 'ts-log';
import { NewTxAlonzoWithSlot, TransactionReemitErrorCode, createTransactionReemitter } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { genesisParameters } from '../mocks';

describe('TransactionReemiter', () => {
  let store: WalletStores['volatileTransactions'];
  let volatileTransactions: NewTxAlonzoWithSlot[];
  let logger: Logger;

  beforeEach(() => {
    logger = dummyLogger;
    store = new InMemoryVolatileTransactionsStore();
    store.set = jest.fn();
    volatileTransactions = [
      {
        body: { validityInterval: { invalidHereafter: 1000 } },
        id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
        slot: 100
      },
      {
        body: { validityInterval: { invalidHereafter: 1000 } },
        id: Cardano.TransactionId('7804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
        slot: 200
      },
      {
        body: { validityInterval: { invalidHereafter: 1000 } },
        id: Cardano.TransactionId('8804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
        slot: 300
      },
      {
        body: { validityInterval: { invalidHereafter: 1000 } },
        id: Cardano.TransactionId('9904edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
        slot: 400
      }
    ] as NewTxAlonzoWithSlot[];
  });

  it('Stored volatile transactions are fetched on init', () => {
    const storeTransaction = volatileTransactions[0];
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      store.get = jest.fn(() => cold('a|', { a: [storeTransaction] }));
      const tipSlot$ = hot<Cardano.Slot>('-|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('-|');
      const confirmed$ = cold<NewTxAlonzoWithSlot>('-|');
      const rollback$ = cold<Cardano.TxAlonzo>('-|');
      const submitting$ = cold<NewTxAlonzoWithSlot>('-|');
      const transactionReemiter = createTransactionReemitter({
        confirmed$,
        genesisParameters$,
        logger,
        rollback$,
        store,
        submitting$,
        tipSlot$
      });
      expectObservable(transactionReemiter).toBe('-|');
    });
    expect(store.get).toHaveBeenCalledTimes(1);
    expect(store.set).not.toHaveBeenCalledTimes(1); // already in store
  });

  it('Merges stored transacions with confirmed transactions and adds them all to store', () => {
    const storeTransaction = volatileTransactions[0];
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      store.get = jest.fn(() => cold('a|', { a: [storeTransaction] }));
      const tipSlot$ = hot<Cardano.Slot>('----|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a---|', { a: genesisParameters });
      const confirmed$ = cold<NewTxAlonzoWithSlot>('-b-c|', { b: volatileTransactions[1], c: volatileTransactions[2] });
      const rollback$ = cold<Cardano.TxAlonzo>('----|');
      const submitting$ = cold<NewTxAlonzoWithSlot>('----|');
      const transactionReemiter = createTransactionReemitter({
        confirmed$,
        genesisParameters$,
        logger,
        rollback$,
        store,
        submitting$,
        tipSlot$
      });
      expectObservable(transactionReemiter).toBe('----|');
    });
    expect(store.set).toHaveBeenCalledTimes(2);
    expect(store.set).toHaveBeenLastCalledWith(volatileTransactions.slice(0, 3));
  });

  it('Removes transaction from volatiles if it is reported as submitting', () => {
    const storeTransaction = volatileTransactions;
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      store.get = jest.fn(() => cold('a|', { a: storeTransaction }));
      const tipSlot$ = hot<Cardano.Slot>('--|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a-|', { a: genesisParameters });
      const confirmed$ = cold<NewTxAlonzoWithSlot>('--|');
      const rollback$ = cold<Cardano.TxAlonzo>('--|');
      const submitting$ = cold<NewTxAlonzoWithSlot>('-b|', { b: volatileTransactions[0] });
      const transactionReemiter = createTransactionReemitter({
        confirmed$,
        genesisParameters$,
        logger,
        rollback$,
        store,
        submitting$,
        tipSlot$
      });
      expectObservable(transactionReemiter).toBe('--|');
    });
    expect(store.set).toHaveBeenCalledTimes(1);
    expect(store.set).toHaveBeenLastCalledWith(volatileTransactions.slice(1));
  });

  it('Uses stability window to remove transactions no longer volatile', () => {
    const [volatileSlot100, volatileSlot200, volatileSlot300] = volatileTransactions;
    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tipSlot$ = hot<Cardano.Slot>('---|');
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a--|', {
        a: { ...genesisParameters, activeSlotsCoefficient: 33 }
      });
      const confirmed$ = cold<NewTxAlonzoWithSlot>('abc|', {
        a: volatileSlot100,
        b: volatileSlot200,
        c: volatileSlot300
      });
      const rollback$ = cold<Cardano.TxAlonzo>('---|');
      const submitting$ = cold<NewTxAlonzoWithSlot>('---|');
      const transactionReemiter = createTransactionReemitter({
        confirmed$,
        genesisParameters$,
        logger,
        rollback$,
        store,
        submitting$,
        tipSlot$
      });
      expectObservable(transactionReemiter).toBe('---|');
    });
    expect(store.set).toHaveBeenCalledTimes(3);
    expect(store.set).toHaveBeenLastCalledWith(volatileTransactions.slice(1, 3));
  });

  it('Emits transactions that were rolled back and still valid', () => {
    const LAST_TIP_SLOT = 400;
    const [volatileA, volatileB, volatileC, volatileD] = volatileTransactions;
    const rollbackA: Cardano.TxAlonzo = { body: volatileA.body, id: volatileA.id } as Cardano.TxAlonzo;
    const rollbackC: Cardano.TxAlonzo = {
      body: { validityInterval: { invalidHereafter: LAST_TIP_SLOT - 1 } },
      id: volatileC.id
    } as Cardano.TxAlonzo;
    const rollbackD: Cardano.TxAlonzo = { body: volatileD.body, id: volatileD.id } as Cardano.TxAlonzo;

    // eslint-disable-next-line @typescript-eslint/no-shadow
    logger.error = jest.fn();

    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tipSlot$ = hot<Cardano.Slot>('x--------|', { x: LAST_TIP_SLOT });
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a--------|', { a: genesisParameters });
      const confirmed$ = cold<NewTxAlonzoWithSlot>('a-b-c-d--|', {
        a: volatileA,
        b: volatileB,
        c: volatileC,
        d: volatileD
      });
      const rollback$ = cold<Cardano.TxAlonzo>('--a--c--d|', { a: rollbackA, c: rollbackC, d: rollbackD });
      const submitting$ = cold<NewTxAlonzoWithSlot>('---------|');
      const transactionReemiter = createTransactionReemitter({
        confirmed$,
        genesisParameters$,
        logger,
        rollback$,
        store,
        submitting$,
        tipSlot$
      });
      expectObservable(transactionReemiter).toBe('--a-----d|', { a: volatileA, d: volatileD });
    });

    expect(logger.error).toHaveBeenCalledWith(expect.anything(), TransactionReemitErrorCode.invalidHereafter);
  });

  it('Logs error message for rolledback transactions not found in volatiles', () => {
    const [volatileA, volatileB, volatileC] = volatileTransactions;
    const rollbackC: Cardano.TxAlonzo = { body: volatileC.body, id: volatileC.id } as Cardano.TxAlonzo;
    // eslint-disable-next-line @typescript-eslint/no-shadow
    const logger = dummyLogger;
    logger.error = jest.fn();

    createTestScheduler().run(({ hot, cold, expectObservable }) => {
      const tipSlot$ = hot<Cardano.Slot>('x--|', { x: 300 });
      const genesisParameters$ = cold<Cardano.CompactGenesis>('a--|', { a: genesisParameters });
      const confirmed$ = cold<NewTxAlonzoWithSlot>('ab-|', {
        a: volatileA,
        b: volatileB
      });
      const rollback$ = cold<Cardano.TxAlonzo>('--c|', { c: rollbackC });
      const submitting$ = cold<NewTxAlonzoWithSlot>('---|');
      const transactionReemiter = createTransactionReemitter({
        confirmed$,
        genesisParameters$,
        logger,
        rollback$,
        store,
        submitting$,
        tipSlot$
      });
      expectObservable(transactionReemiter).toBe('---|');
    });
    expect(logger.error).toHaveBeenCalledWith(expect.anything(), TransactionReemitErrorCode.notFound);
  });
});
