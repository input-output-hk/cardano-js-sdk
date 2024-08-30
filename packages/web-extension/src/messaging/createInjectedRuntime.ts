// only tested in ../e2e tests
import { MessengerPort } from './types';
import { Runtime } from 'webextension-polyfill';
import { isResponseMessage } from './util';

const noOp = () => void 0;

export const createInjectedRuntime = (apiName: string) => {
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
        window.postMessage({ ...message, apiName }, '*');
      }
    };
    return port;
  };

  return { connect: connectWindow, onConnect: { addListener: noOp, removeListener: noOp } };
};
