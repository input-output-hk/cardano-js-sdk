import { ChainSyncEventType } from '@cardano-sdk/core';
import { firstValueFrom, of } from 'rxjs';
import { requestNext } from '../../src/index.js';
import type { ChainSyncRollForward, RequestNext } from '@cardano-sdk/core';

describe('requestNext', () => {
  it('calls event.requestNext() and emits event object without this method', async () => {
    const evt = {
      eventType: ChainSyncEventType.RollForward,
      requestNext: jest.fn() as RequestNext
    } as ChainSyncRollForward;
    const emittedEvent = await firstValueFrom(of(evt).pipe(requestNext()));
    expect(evt.requestNext).toBeCalledTimes(1);
    expect(emittedEvent).toEqual({
      eventType: ChainSyncEventType.RollForward
    });
  });
});
