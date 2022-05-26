import { Message, connect } from 'amqplib';
import { RabbitMqTxSubmitProvider, TX_SUBMISSION_QUEUE } from '../src';

export const BAD_CONNECTION_URL = new URL('amqp://localhost:1234');
export const GOOD_CONNECTION_URL = new URL('amqp://localhost');

export const enqueueFakeTx = async (data = [0, 1, 2, 3, 23]) => {
  const rabbitMqTxSubmitProvider = new RabbitMqTxSubmitProvider(GOOD_CONNECTION_URL);
  await rabbitMqTxSubmitProvider.submitTx(new Uint8Array(data));
  return rabbitMqTxSubmitProvider.close();
};

export const removeAllMessagesFromQueue = async () => {
  const connection = await connect(GOOD_CONNECTION_URL.toString());
  const channel = await connection.createChannel();
  await channel.assertQueue(TX_SUBMISSION_QUEUE);
  let message: Message | false;

  do {
    message = await channel.get(TX_SUBMISSION_QUEUE);
    if (message) channel.ack(message);
  } while (message);

  await channel.close();
  await connection.close();
};
