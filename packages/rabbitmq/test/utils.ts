import { RabbitMqTxSubmitProvider } from '../src';
import { connect } from 'amqplib';
import { dummyLogger } from 'ts-log';
import { readFile } from 'fs/promises';
import axios from 'axios';
import path from 'path';

export const BAD_CONNECTION_URL = new URL('amqp://localhost:1234');
export const GOOD_CONNECTION_URL = new URL('amqp://localhost');

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

export const enqueueFakeTx = async (idx = 0, logger = dummyLogger) =>
  new Promise<void>(async (resolve, reject) => {
    const txs = await txsPromise;
    let err: unknown;
    let rabbitMqTxSubmitProvider: RabbitMqTxSubmitProvider | null = null;

    try {
      rabbitMqTxSubmitProvider = new RabbitMqTxSubmitProvider({ rabbitmqUrl: GOOD_CONNECTION_URL }, { logger });
      await rabbitMqTxSubmitProvider.submitTx(txs[idx].txBodyUint8Array);
    } catch (error) {
      err = error;
    } finally {
      if (rabbitMqTxSubmitProvider) await rabbitMqTxSubmitProvider.close();
      if (err) reject(err);
      else resolve();
    }
  });

export const removeAllQueues = async () => {
  const queues = await axios.get('http://guest:guest@localhost:15672/api/queues/');

  if (queues.data.length === 0) return;

  const connection = await connect(GOOD_CONNECTION_URL.toString());
  const channel = await connection.createChannel();

  for (const queue of queues.data) await channel.deleteQueue(queue.name as string);

  await channel.close();
  await connection.close();
};

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
