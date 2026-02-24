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
});
