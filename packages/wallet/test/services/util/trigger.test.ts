import { Cardano, NetworkInfo, testnetTimeSettings } from '@cardano-sdk/core';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { distinctBlock, distinctTimeSettings } from '../../../src/services/util';

describe('trigger', () => {
  it('distinctBlock subscribes to tip$ on each subscription and emits when tip$ has new blockNo', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const tip$ = cold('a--b--c', {
        a: { blockNo: 100 } as Cardano.Tip,
        b: { blockNo: 100 } as Cardano.Tip,
        c: { blockNo: 101 } as Cardano.Tip
      });
      const distinctTip$ = distinctBlock(tip$);
      expectObservable(distinctTip$).toBe('a-----b', {
        a: 100,
        b: 101
      });
      expectObservable(distinctTip$, '-^-----').toBe('-a-----b', {
        a: 100,
        b: 101
      });
    });
  });

  it('distinctTimeSettings emits when NetworkInfo.network.timeSettings changes', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const timeSettings1 = testnetTimeSettings;
      const latestTimeSettings = timeSettings1[timeSettings1.length - 1];
      const timeSettings2 = [
        ...testnetTimeSettings,
        { ...latestTimeSettings, fromSlotNo: latestTimeSettings.fromSlotNo + 10_000 }
      ];
      const networkInfo$ = cold('-a--b-c', {
        a: { network: { timeSettings: timeSettings1 } } as NetworkInfo,
        b: { network: { timeSettings: [...timeSettings1] } } as NetworkInfo,
        c: { network: { timeSettings: timeSettings2 } } as NetworkInfo
      });
      expectObservable(distinctTimeSettings(networkInfo$)).toBe('-a----b', {
        a: timeSettings1,
        b: timeSettings2
      });
    });
  });
});
