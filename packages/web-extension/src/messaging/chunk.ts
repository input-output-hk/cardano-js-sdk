import { PortMessage } from './types';
import { Subject } from 'rxjs';
import { looksLikeMessage } from './util';
import { v4 } from 'uuid';
import fastChunk from 'fast-chunk-string';
import sortBy from 'lodash/sortBy.js';

export interface Chunk {
  messageId: string;
  data: string;
  numChunks: number;
  index: number;
}

export const isChunk = (msg: unknown): msg is Chunk =>
  typeof msg === 'object' &&
  msg !== null &&
  'numChunks' in msg &&
  'messageId' in msg &&
  'data' in msg &&
  'index' in msg;

export const chunkMessage = (message: unknown, size = 10_000): unknown[] => {
  const serializedMessage = JSON.stringify(message);
  if (serializedMessage.length <= size) {
    // no chunking for small messages
    return [message];
  }
  const chunks = fastChunk(serializedMessage, { size });
  const numChunks = chunks.length;
  const messageId = looksLikeMessage(message) ? message.messageId : v4();
  return chunks.map(
    (data, index): Chunk => ({
      data,
      index,
      messageId,
      numChunks
    })
  );
};

export const combineChunks = (chunks: Chunk[]): unknown => {
  if (chunks.length === 0 || chunks.length !== chunks[0].numChunks) {
    throw new Error('Unexpected number of chunks');
  }
  const serializedMessage = sortBy(chunks, ({ index }) => index)
    .map(({ data }) => data)
    .join('');
  return JSON.parse(serializedMessage);
};

export const createChunkedMessageHandler = () => {
  const messages = new Map<string, Chunk[]>();
  return {
    /**
     * @returns if this is the last chunk, returns full message. Otherwise returns `null`
     */
    collectChunk(chunk: Chunk): unknown | null {
      const chunks = messages.get(chunk.messageId);
      if (chunks) {
        chunks.push(chunk);
        if (chunks.length === chunk.numChunks) {
          messages.delete(chunk.messageId);
          return combineChunks(chunks);
        }
      } else if (chunk.numChunks === 1) {
        return JSON.parse(chunk.data);
      } else {
        messages.set(chunk.messageId, [chunk]);
      }
      return null;
    },

    emitIfLastChunk(portMessage: PortMessage, subject$: Subject<PortMessage<unknown>>) {
      if (isChunk(portMessage.data)) {
        const message = this.collectChunk(portMessage.data);
        if (message) {
          subject$.next({ data: message, port: portMessage.port });
        }
      } else {
        subject$.next(portMessage);
      }
    }
  };
};
