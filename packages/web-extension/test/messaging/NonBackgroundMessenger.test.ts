import { MessengerPort, MinimalRuntime, createNonBackgroundMessenger } from '../../src/messaging';
import { dummyLogger } from 'ts-log';

const createMockPort = (): MessengerPort => ({
  disconnect: jest.fn(),
  name: 'test',
  onDisconnect: { addListener: jest.fn(), removeListener: jest.fn() },
  onMessage: { addListener: jest.fn(), removeListener: jest.fn() },
  postMessage: jest.fn()
});

const createMockRuntime = (): MinimalRuntime => ({
  connect: jest.fn(() => createMockPort()),
  onConnect: { addListener: jest.fn(), removeListener: jest.fn() }
});

describe('NonBackgroundMessenger', () => {
  describe('lazy option', () => {
    it('does not call runtime.connect on creation when lazy is true', () => {
      const runtime = createMockRuntime();
      createNonBackgroundMessenger({ baseChannel: 'test', lazy: true }, { logger: dummyLogger, runtime });
      expect(runtime.connect).not.toHaveBeenCalled();
    });

    it('calls runtime.connect on creation when lazy is false', () => {
      const runtime = createMockRuntime();
      createNonBackgroundMessenger({ baseChannel: 'test', lazy: false }, { logger: dummyLogger, runtime });
      expect(runtime.connect).toHaveBeenCalledTimes(1);
    });

    it('calls runtime.connect on creation when lazy is not specified', () => {
      const runtime = createMockRuntime();
      createNonBackgroundMessenger({ baseChannel: 'test' }, { logger: dummyLogger, runtime });
      expect(runtime.connect).toHaveBeenCalledTimes(1);
    });

    it('calls runtime.connect when connect$ is subscribed to with lazy: true', () => {
      const runtime = createMockRuntime();
      const messenger = createNonBackgroundMessenger(
        { baseChannel: 'test', lazy: true },
        { logger: dummyLogger, runtime }
      );
      expect(runtime.connect).not.toHaveBeenCalled();
      messenger.connect$.subscribe();
      expect(runtime.connect).toHaveBeenCalledTimes(1);
    });
  });

  describe('reconnect on disconnect', () => {
    it('reconnects when disconnected with a runtime.lastError', () => {
      jest.useFakeTimers();
      const port = createMockPort();
      const runtime: MinimalRuntime = {
        connect: jest.fn(() => port),
        lastError: undefined,
        onConnect: { addListener: jest.fn(), removeListener: jest.fn() }
      };
      createNonBackgroundMessenger({ baseChannel: 'test' }, { logger: dummyLogger, runtime });
      expect(runtime.connect).toHaveBeenCalledTimes(1);

      // Simulate disconnect with a runtime error (background not listening)
      runtime.lastError = new Error('Could not establish connection');
      const onDisconnectCb = (port.onDisconnect.addListener as jest.Mock).mock.calls[0][0];
      onDisconnectCb(port);

      jest.runAllTimers();
      expect(runtime.connect).toHaveBeenCalledTimes(2);
      jest.useRealTimers();
    });

    it('does not emit disconnect$ when disconnected with a runtime.lastError (reconnectable)', () => {
      jest.useFakeTimers();
      const port = createMockPort();
      const runtime: MinimalRuntime = {
        connect: jest.fn(() => port),
        lastError: undefined,
        onConnect: { addListener: jest.fn(), removeListener: jest.fn() }
      };
      const messenger = createNonBackgroundMessenger({ baseChannel: 'test' }, { logger: dummyLogger, runtime });
      const disconnectSpy = jest.fn();
      messenger.disconnect$.subscribe(disconnectSpy);

      // Simulate disconnect with a runtime error (will reconnect)
      runtime.lastError = new Error('Could not establish connection');
      const onDisconnectCb = (port.onDisconnect.addListener as jest.Mock).mock.calls[0][0];
      onDisconnectCb(port);

      jest.runAllTimers();
      expect(disconnectSpy).not.toHaveBeenCalled();
      jest.useRealTimers();
    });

    it('emits disconnect$ when disconnected without a runtime.lastError (final disconnect)', () => {
      const port = createMockPort();
      const runtime: MinimalRuntime = {
        connect: jest.fn(() => port),
        lastError: undefined,
        onConnect: { addListener: jest.fn(), removeListener: jest.fn() }
      };
      const messenger = createNonBackgroundMessenger({ baseChannel: 'test' }, { logger: dummyLogger, runtime });
      const disconnectSpy = jest.fn();
      messenger.disconnect$.subscribe(disconnectSpy);

      // Simulate clean disconnect (no runtime error)
      const onDisconnectCb = (port.onDisconnect.addListener as jest.Mock).mock.calls[0][0];
      onDisconnectCb(port);

      expect(disconnectSpy).toHaveBeenCalledWith({ disconnected: port, remaining: [] });
    });

    it('does not reconnect when disconnected without a runtime.lastError', () => {
      jest.useFakeTimers();
      const port = createMockPort();
      const runtime: MinimalRuntime = {
        connect: jest.fn(() => port),
        lastError: undefined,
        onConnect: { addListener: jest.fn(), removeListener: jest.fn() }
      };
      createNonBackgroundMessenger({ baseChannel: 'test' }, { logger: dummyLogger, runtime });
      expect(runtime.connect).toHaveBeenCalledTimes(1);

      // Simulate clean disconnect (no runtime error)
      const onDisconnectCb = (port.onDisconnect.addListener as jest.Mock).mock.calls[0][0];
      onDisconnectCb(port);

      jest.runAllTimers();
      expect(runtime.connect).toHaveBeenCalledTimes(1);
      jest.useRealTimers();
    });
  });
});
