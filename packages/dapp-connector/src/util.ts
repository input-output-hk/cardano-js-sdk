import { Runtime } from 'webextension-polyfill';

export const senderOrigin = (sender?: Runtime.MessageSender): string | null => {
  try {
    const { origin } = new URL(sender?.url || 'throw');
    return origin;
  } catch {
    return null;
  }
};
