import { readFile } from 'fs/promises';
import path from 'path';

export const BAD_CONNECTION_URL = new URL('amqp://localhost:1234');

interface TestTx {
  txBodyHex: string;
  txBodyUint8Array: Uint8Array;
  txId: string;
}

export const txsPromise = (async () => {
  const ret: TestTx[] = [];
  const body = await readFile(path.join(__dirname, 'transactions.txt'));

  for (const line of body.toString().split('\n'))
    if (line) {
      const tokens = line.split(',');

      ret.push({
        txBodyHex: tokens[1],
        txBodyUint8Array: Uint8Array.from(Buffer.from(tokens[1], 'hex')),
        txId: tokens[0]
      });
    }

  return ret;
})();

export const testLogger = () => {
  const messages: { message: unknown[]; level: 'debug' | 'error' | 'info' | 'trace' | 'warn' }[] = [];

  return {
    debug: (...message: unknown[]) => messages.push({ level: 'debug', message }),
    error: (...message: unknown[]) => messages.push({ level: 'error', message }),
    info: (...message: unknown[]) => messages.push({ level: 'info', message }),
    messages,
    trace: (...message: unknown[]) => messages.push({ level: 'trace', message }),
    warn: (...message: unknown[]) => messages.push({ level: 'warn', message })
  };
};
