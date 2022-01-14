import { TimeSettings, TimeSettingsProvider } from '@cardano-sdk/core';
import delay from 'delay';

export const createStubTimeSettingsProvider =
  (timeSettings: TimeSettings[], delayMs?: number): TimeSettingsProvider =>
  async () => {
    if (delayMs) await delay(delayMs);
    return timeSettings;
  };
