import Emittery from 'emittery';
import { TransactionTrackerEvents } from '../../src';

export class MockTransactionTracker extends Emittery<TransactionTrackerEvents> {
  track = jest.fn();
}

export const txTracker = new MockTransactionTracker();
