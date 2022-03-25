import { TimeSettings } from '../..';

export interface TimeSettingsProvider {
  getTimeSettings(): Promise<TimeSettings[]>;
}
