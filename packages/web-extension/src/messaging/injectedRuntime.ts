// only tested in ../e2e tests
import { isResponseMessage } from './util.js';
import type { MessengerPort } from './types.js';
import type { Runtime } from 'webextension-polyfill';

const noOp = () => void 0;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const listeners = new WeakMap<any, any>();
const connectWindow = ({ name }: Runtime.ConnectConnectInfoType): MessengerPort => {
  const port: MessengerPort = {
    disconnect: noOp,
    name: name || '',
    onDisconnect: {
      addListener: noOp,
      removeListener: noOp
    },
    onMessage: {
      addListener(listener) {
        const wrappedListener = ({ data, source }: MessageEvent) => {
          // TODO: consider validating the source, or else something else might pretend to be this wallet
          if (source !== window || !isResponseMessage(data)) return;
          listener(data, port);
        };
        listeners.set(listener, wrappedListener);
        window.addEventListener('message', wrappedListener);
      },
      removeListener(listener) {
        const wrappedListener = listeners.get(listener);
        window.removeEventListener('message', wrappedListener);
        listeners.delete(listener);
      }
    },
    postMessage(message) {
      window.postMessage(message, '*');
    }
  };
  return port;
};

export const injectedRuntime = { connect: connectWindow, onConnect: { addListener: noOp, removeListener: noOp } };
