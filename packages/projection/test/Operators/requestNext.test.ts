import { ChainSyncEventType, ChainSyncRollForward, RequestNext } from '@cardano-sdk/core';
import { Operators } from '../../src';
import { firstValueFrom, of } from 'rxjs';

describe('requestNext', () => {
  it('calls event.requestNext() and emits event object without this method', async () => {
    const evt = {
      eventType: ChainSyncEventType.RollForward,
      requestNext: jest.fn() as RequestNext
    } as ChainSyncRollForward;
    const emittedEvent = await firstValueFrom(of(evt).pipe(Operators.requestNext()));
    expect(evt.requestNext).toBeCalledTimes(1);
    expect(emittedEvent).toEqual({
      eventType: ChainSyncEventType.RollForward
    });
  });
});
