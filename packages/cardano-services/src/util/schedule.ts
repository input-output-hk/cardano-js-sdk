import * as fs from 'fs';

export type ScheduleConfig = {
  queue: string;
  cron: string;
  data: object;
  scheduleOptions: object;
};
type RawSchedulesConfig = {
  schedules: {
    sharedScheduleOptions: {};
    list: Array<ScheduleConfig>;
  };
};
export const readScheduleConfig = (filePath: string): Array<ScheduleConfig> => {
  try {
    const { schedules } = JSON.parse(fs.readFileSync(filePath, 'utf-8')) as RawSchedulesConfig;
    return schedules.list.map((schedule) => ({
      ...schedule,
      scheduleOptions: { ...schedules.sharedScheduleOptions, ...schedule.scheduleOptions }
    }));
  } catch (error) {
    throw new Error(
      `Failed to parse the schedule config from file: ${filePath}\n error: ${
        error instanceof Error ? error.message : JSON.stringify(error)
      }`
    );
  }
};
