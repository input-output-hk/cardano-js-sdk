/* eslint-disable @typescript-eslint/no-explicit-any */
import { readScheduleConfig } from '../../src/util/schedule.js';
import path from 'path';

describe('util/schedule', () => {
  describe('readScheduleConfig', () => {
    it('reads config successfully from file', () => {
      const queueName = 'test-schedule1';
      const expected = {
        cron: '0 * * * *',
        data: { exampleData: 'exampleData' },
        queue: queueName,
        scheduleOptions: {
          pgBossOption1: 'pgBossOption1',
          pgBossOption2: 'pgBossOption2',
          sharedOption1: 'sharedOption1'
        }
      };
      const configPath = path.join(__dirname, '.schedule.unittest.json');

      const schedules = readScheduleConfig(configPath);

      expect(schedules.length).toBe(2);
      expect(expected).toEqual(schedules.find((schedule) => schedule.queue === queueName));
    });

    it('throws error if read json format is invalid', () => {
      const configPath = path.join(__dirname, '.schedule-invalid.unittest.json');

      expect(() => readScheduleConfig(configPath)).toThrow('Failed to parse the schedule config from file');
    });
  });
});
