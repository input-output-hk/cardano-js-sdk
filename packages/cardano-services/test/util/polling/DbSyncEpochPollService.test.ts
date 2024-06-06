import { DbSyncEpochPollService } from '../../../src/util/index.js';
import { NetworkInfoFixtureBuilder } from '../../NetworkInfo/fixtures/FixtureBuilder.js';
import { Pool } from 'pg';
import { ingestDbData, sleep, wrapWithTransaction } from '../../util.js';
import { logger } from '@cardano-sdk/util-dev';

describe('DbSyncEpochPollService', () => {
  const epochPollInterval = 2 * 1000;
  const db = new Pool({
    connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC,
    max: 1,
    min: 1
  });
  const fixtureBuilder = new NetworkInfoFixtureBuilder(db, logger);
  const epochMonitor = new DbSyncEpochPollService(db, epochPollInterval!);

  describe('healthy state', () => {
    afterAll(async () => {
      await db.end();
    });

    it(
      'should execute all registered callbacks once the epoch rollover is detected by db polling',
      wrapWithTransaction(async (dbConnection) => {
        const currentEpoch = await fixtureBuilder.getLasKnownEpoch();
        const greaterEpoch = 255;

        const firstRegisteredCallback = jest.fn();
        const secondRegisteredCallback = jest.fn();

        expect(await epochMonitor.getLastKnownEpoch()).toEqual(null);

        const firstDisposer = epochMonitor.onEpochRollover(firstRegisteredCallback);
        const secondDisposer = epochMonitor.onEpochRollover(secondRegisteredCallback);

        await sleep(epochPollInterval * 2);

        expect(await epochMonitor.getLastKnownEpoch()).toEqual(currentEpoch);
        expect(firstRegisteredCallback).not.toHaveBeenCalled();
        expect(secondRegisteredCallback).not.toHaveBeenCalled();

        await ingestDbData(
          dbConnection,
          'epoch',
          ['id', 'out_sum', 'fees', 'tx_count', 'blk_count', 'no', 'start_time', 'end_time'],
          [greaterEpoch, 58_389_393_484_858, 43_424_552, 55_666, 10_000, greaterEpoch, '2022-05-28', '2022-06-02']
        );

        await sleep(epochPollInterval * 2);

        expect(firstRegisteredCallback).toHaveBeenCalled();
        expect(secondRegisteredCallback).toHaveBeenCalled();
        expect(await epochMonitor.getLastKnownEpoch()).toEqual(greaterEpoch);

        // Dispose the registered callbacks in epoch monitor
        firstDisposer();
        secondDisposer();
      }, db)
    );
  });
});
