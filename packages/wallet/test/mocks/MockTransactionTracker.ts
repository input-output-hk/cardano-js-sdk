import { TransactionTrackerEvents } from '../../src';
import Emittery from 'emittery';

export class MockTransactionTracker extends Emittery<TransactionTrackerEvents> {
  track = jest.fn();
}

export const txTracker = new MockTransactionTracker();
