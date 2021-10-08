import Emittery from 'emittery';
import { TransactionTrackerEvents } from '../src';

export class MockTransactionTracker extends Emittery<TransactionTrackerEvents> {
  trackTransaction = jest.fn();
}

export const txTracker = new MockTransactionTracker();
