/* eslint-disable unicorn/consistent-function-scoping */
import {
  ChannelName,
  Messenger,
  PortMessage,
  RemoteApiProperty,
  consumeMessengerRemoteApi,
  deriveChannelName,
  exposeMessengerApi
} from '../../src/messaging';
import { Observable, Subject, firstValueFrom, map, of, tap, timer, toArray } from 'rxjs';
import { dummyLogger } from 'ts-log';
import { memoize } from 'lodash-es';

const logger = dummyLogger;

const createSubjects = memoize((_channelName: ChannelName) => ({
  consumerMessage$: new Subject(),
  hostMessage$: new Subject()
}));

const createMessenger = (channel: ChannelName, isHost: boolean): Messenger => {
  const subjects = createSubjects(channel);
  const [local$, remote$] = isHost
    ? [subjects.hostMessage$, subjects.consumerMessage$]
    : [subjects.consumerMessage$, subjects.hostMessage$];
  const postMessage = (message: unknown) =>
    timer(1).pipe(
      tap(() => remote$.next(message)),
      map(() => void 0)
    );
  const derivedMessengers: Messenger[] = [];
  return {
    channel,
    deriveChannel(path) {
      const messenger = createMessenger(deriveChannelName(channel, path), isHost);
      derivedMessengers.push(messenger);
      return messenger;
    },
    destroy() {
      for (const messenger of derivedMessengers) {
        messenger.destroy();
        local$.complete();
        remote$.complete();
      }
    },
    message$: local$.pipe(
      map((data): PortMessage => ({ data, port: { postMessage: (message) => postMessage(message).subscribe() } }))
    ),
    postMessage
  };
};

const setUp = (someNumbers$: Observable<bigint> = of(0n)) => {
  const baseChannel = 'base-channel';
  const api = {
    addOne: async (arg: bigint) => arg + 1n,
    someNumbers$
  };
  const hostSubscription = exposeMessengerApi(
    {
      api,
      methodRequestOptions: {
        transform: (req) => {
          if (req.args[0] === 1n) {
            return {
              ...req,
              args: [2n]
            };
          }
          return req;
        },
        validate: async (req) => {
          if (req.args[0] === 0n) {
            throw new Error('Invalid arg');
          }
        }
      }
    },
    {
      logger,
      messenger: createMessenger(baseChannel, true)
    }
  );
  const consumer = consumeMessengerRemoteApi<typeof api>(
    {
      properties: {
        addOne: RemoteApiProperty.MethodReturningPromise,
        someNumbers$: RemoteApiProperty.Observable
      }
    },
    { logger, messenger: createMessenger(baseChannel, false) }
  );
  return {
    cleanup() {
      hostSubscription.unsubscribe();
      consumer.shutdown();
    },
    consumer
  };
};

type SUT = ReturnType<typeof setUp>;

describe('remoteApi', () => {
  describe('methods returning promise', () => {
    let sut: SUT;

    beforeEach(() => {
      sut = setUp();
    });
    afterEach(() => sut.cleanup());
    it('invalid properties are undefined', () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      expect((sut.consumer as any).addTwo).toBeUndefined();
    });
    it('calls remote method and resolves result', async () => {
      expect(await sut.consumer.addOne(2n)).toBe(3n);
    });
    describe('methodRequestOptions', () => {
      // see beforeAll for setup
      test('transform', async () => {
        expect(await sut.consumer.addOne(1n)).toBe(3n);
      });
      test('validate', async () => {
        await expect(() => sut.consumer.addOne(0n)).rejects.toThrowError();
      });
    });
  });

  describe('observables', () => {
    let source$: Subject<bigint>;
    let sut: SUT;

    beforeEach(() => {
      source$ = new Subject();
      sut = setUp(source$);
    });
    afterEach(() => {
      createSubjects.cache.clear!();
      sut.cleanup();
    });

    describe('mirrors source emissions and completion', () => {
      it('values emitted after subscription', (done) => {
        const emitted = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
        setTimeout(async () => {
          source$.next(0n);
          source$.next(1n);
          source$.complete();
          expect(await emitted).toEqual([0n, 1n]);
          done();
        }, 1);
      });
      it('replays 1 last value emitted before subscription', (done) => {
        source$.next(-1n);
        source$.next(0n);
        setTimeout(() => {
          const emitted = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
          setTimeout(async () => {
            source$.next(1n);
            source$.complete();
            expect(await emitted).toEqual([0n, 1n]);
            done();
          }, 1);
        }, 1);
      });
    });

    describe('mirrors source errors', () => {
      const subscribeAndAssertError = (done: Function) => {
        sut.consumer.someNumbers$.subscribe({
          error: (err) => {
            expect(err instanceof Error).toBe(true);
            expect(err.message).toBe('err');
            done();
          }
        });
      };

      it('when thrown after subscription', (done) => {
        subscribeAndAssertError(done);
        source$.error(new Error('err'));
      });

      it('when thrown before subscription', (done) => {
        source$.error(new Error('err'));
        subscribeAndAssertError(done);
      });
    });
  });
});
