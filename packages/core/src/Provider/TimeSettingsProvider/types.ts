import { TimeSettings } from '../..';

export interface TimeSettingsProvider {
  (): Promise<TimeSettings[]>;
}
