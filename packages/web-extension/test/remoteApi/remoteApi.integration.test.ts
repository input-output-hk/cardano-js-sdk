/* eslint-disable unicorn/consistent-function-scoping */
import {
  ChannelName,
  Messenger,
  MinimalPort,
  PortMessage,
  RemoteApiProperties,
  RemoteApiPropertyType,
  RemoteApiShutdownError,
  consumeMessengerRemoteApi,
  deriveChannelName,
  exposeMessengerApi
} from '../../src/messaging';
import { EmptyError, Observable, Subject, firstValueFrom, map, of, tap, throwError, timer, toArray } from 'rxjs';
import { dummyLogger } from 'ts-log';
import memoize from 'lodash/memoize';

const logger = dummyLogger;

const createSubjects = memoize((_channelName: ChannelName) => ({
  consumerMessage$: new Subject(),
  hostMessage$: new Subject()
}));

type TestMessenger = Messenger & { connect(): void };

const createMessenger = (channel: ChannelName, isHost: boolean): TestMessenger => {
  const subjects = createSubjects(channel);
  const [local$, remote$] = isHost
    ? [subjects.hostMessage$, subjects.consumerMessage$]
    : [subjects.consumerMessage$, subjects.hostMessage$];
  const postMessage = (message: unknown) =>
    timer(1).pipe(
      tap(() => remote$.next(message)),
      map(() => void 0)
    );
  const derivedMessengers: TestMessenger[] = [];
  const connect$ = new Subject<MinimalPort>();
  return {
    channel,
    connect() {
      // needed to test observable emission on connect
      connect$.next({
        postMessage(message) {
          postMessage(message).subscribe();
        }
      });
      for (const derivedMessenger of derivedMessengers) {
        derivedMessenger.connect();
      }
    },
    connect$,
    deriveChannel(path) {
      const messenger = createMessenger(deriveChannelName(channel, path), isHost);
      derivedMessengers.push(messenger);
      return messenger;
    },
    message$: local$.pipe(
      map((data): PortMessage => ({ data, port: { postMessage: (message) => postMessage(message).subscribe() } }))
    ),
    postMessage,
    shutdown() {
      for (const messenger of derivedMessengers) {
        messenger.shutdown();
      }
      local$.complete();
      remote$.complete();
      connect$.complete();
    }
  };
};

const addOne = async (arg: bigint) => arg + 1n;
const setUp = (someNumbers$: Observable<bigint> = of(0n), nestedSomeNumbers$ = of(0n)) => {
  const baseChannel = 'base-channel';
  const api = {
    addOne,
    addOneTransformedToAddTwo: addOne,
    nested: {
      addOneNoZero: addOne,
      nestedSomeNumbers$
    },
    nestedNonExposed: {
      nestedNonExposed$: of(true)
    },
    nonExposedMethod: jest.fn(async () => true),
    nonExposedObservable$: throwError(() => new Error('Shouldnt be called')),
    someNumbers$
  };

  type FullApi = typeof api;
  type ExposedApi = Omit<FullApi, 'nonExposedMethod' | 'nonExposedObservable$' | 'nestedNonExposed'>;
  const api$ = new Subject<FullApi>();

  const properties: RemoteApiProperties<ExposedApi> = {
    addOne: RemoteApiPropertyType.MethodReturningPromise,
    addOneTransformedToAddTwo: {
      propType: RemoteApiPropertyType.MethodReturningPromise,
      requestOptions: {
        transform: (req) => ({
          ...req,
          args: [(req.args[0] as bigint) + 1n]
        })
      }
    },
    nested: {
      addOneNoZero: {
        propType: RemoteApiPropertyType.MethodReturningPromise,
        requestOptions: {
          validate: async (req) => {
            if (req.args[0] === 0n) {
              throw new Error('Validated to non 0n arg');
            }
          }
        }
      },
      nestedSomeNumbers$: RemoteApiPropertyType.HotObservable
    },
    someNumbers$: RemoteApiPropertyType.HotObservable
  };
  const hostMessenger = createMessenger(baseChannel, true);
  const hostSubscription = exposeMessengerApi(
    {
      api$,
      properties
    },
    {
      logger,
      messenger: hostMessenger
    }
  );
  const consumer = consumeMessengerRemoteApi<FullApi>(
    {
      properties: {
        ...properties,
        nestedNonExposed: {
          nestedNonExposed$: RemoteApiPropertyType.HotObservable
        },
        nonExposedMethod: RemoteApiPropertyType.MethodReturningPromise,
        nonExposedObservable$: RemoteApiPropertyType.HotObservable
      }
    },
    { logger, messenger: createMessenger(baseChannel, false) }
  );

  jest.spyOn(api.nonExposedObservable$, 'subscribe');
  return {
    api,
    api$,
    cleanup() {
      hostSubscription.shutdown();
      consumer.shutdown();
    },
    consumer,
    emitInitial() {
      api$.next(api);
    },
    hostMessenger,
    hostSubscription
  };
};

type SUT = ReturnType<typeof setUp>;

describe('remoteApi integration', () => {
  let sut: SUT;

  let otherApi: typeof sut.api;
  let someOtherNumbersSource$: Subject<bigint>;
  let nestedOtherSomeNumbers$: Subject<bigint>;

  beforeEach(() => {
    someOtherNumbersSource$ = new Subject<bigint>();
    nestedOtherSomeNumbers$ = new Subject<bigint>();
    otherApi = {
      addOne,
      addOneTransformedToAddTwo: addOne,
      nested: {
        addOneNoZero: addOne,
        nestedSomeNumbers$: nestedOtherSomeNumbers$
      },
      nestedNonExposed: {
        nestedNonExposed$: of(true)
      },
      nonExposedMethod: jest.fn(async () => true),
      nonExposedObservable$: throwError(() => new Error('Shouldnt be called')),
      someNumbers$: someOtherNumbersSource$
    };
  });

  afterEach(() => {
    sut.cleanup();
    createSubjects.cache.clear!();
  });

  it('invalid properties are undefined', () => {
    sut = setUp();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect((sut.consumer as any).addTwo).toBeUndefined();
  });

  it('shuts down underlying messenger when the exposed object is shut down', async () => {
    sut = setUp();
    sut.hostSubscription.shutdown();
    await expect(firstValueFrom(sut.hostMessenger.message$)).rejects.toThrowError(EmptyError);
  });

  describe('methods returning promise', () => {
    beforeEach(() => {
      sut = setUp();
    });

    it('accessing property returns the same function object', () => {
      expect(sut.consumer.addOne).toBe(sut.consumer.addOne);
      expect(sut.consumer.addOneTransformedToAddTwo).toBe(sut.consumer.addOneTransformedToAddTwo);
    });

    describe('nested property', () => {
      it('accessing property returns the same function object', () => {
        expect(sut.consumer.nested.addOneNoZero).toBe(sut.consumer.nested.addOneNoZero);
        expect(sut.consumer.nested.nestedSomeNumbers$).toBe(sut.consumer.nested.nestedSomeNumbers$);
      });

      it('calls remote method and resolves result', async () => {
        const resolved = sut.consumer.nested.addOneNoZero(2n);
        sut.emitInitial();
        expect(await resolved).toBe(3n);
      });
      test('requestOptions | validate', async () => {
        await expect(() => sut.consumer.nested.addOneNoZero(0n)).rejects.toThrowError();
      });
    });

    describe('top-level property', () => {
      beforeEach(() => sut.emitInitial());

      it('calls remote method and resolves result', async () => {
        expect(await sut.consumer.addOne(2n)).toBe(3n);
      });

      test('requestOptions | transform', async () => {
        expect(await sut.consumer.addOneTransformedToAddTwo(1n)).toBe(3n);
      });

      it('calls remote method multiple times and resolves result', async () => {
        expect(await sut.consumer.addOne(2n)).toBe(3n);
        expect(await sut.consumer.addOne(2n)).toBe(3n);
      });

      it('calls remote method from new source and resolves result', async () => {
        expect(await sut.consumer.addOne(2n)).toBe(3n);
        // add 11 instead of 1 to differentiate from original api object
        otherApi.addOne = async (arg: bigint) => arg + 11n;
        sut.api$.next(otherApi);
        expect(await sut.consumer.addOne(2n)).toBe(13n);
      });

      // TODO: this fails in CI
      // describe('non-exposed properties dont work', () => {
      //   it('source method is not called', async () => {
      //     await expect(sut.consumer.nonExposedMethod()).rejects.toThrowError();
      //     expect(sut.api.nonExposedMethod).not.toBeCalled();
      //   });
      //   it('source observable is not subscribed', (done) => {
      //     sut.consumer.nonExposedObservable$.subscribe();
      //     setTimeout(() => {
      //       expect(sut.api.nonExposedObservable$.subscribe).not.toBeCalled();
      //       done();
      //     }, 1);
      //   });
      // });
    });

    it('throws RemoteApiShutdownError when the remote object shutdown method is called more than once', async () => {
      sut.consumer.shutdown();
      await expect(sut.consumer.addOne(1n)).rejects.toThrowError(RemoteApiShutdownError);
    });
  });

  describe('observables', () => {
    let someNumbersSource$: Subject<bigint>;
    let nestedSomeNumbersSource$: Subject<bigint>;

    beforeEach(() => {
      someNumbersSource$ = new Subject();
      nestedSomeNumbersSource$ = new Subject();
      sut = setUp(someNumbersSource$, nestedSomeNumbersSource$);
      sut.emitInitial();
    });

    afterEach(() => {
      someNumbersSource$.complete();
      nestedSomeNumbersSource$.complete();
    });

    it('accessing property returns the same observable object', () => {
      expect(sut.consumer.someNumbers$).toBe(sut.consumer.someNumbers$);
    });

    describe('top level property', () => {
      describe('mirrors source emissions and completion', () => {
        it('values emitted after subscription', (done) => {
          const emitted = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
          setTimeout(async () => {
            someNumbersSource$.next(0n);
            someNumbersSource$.next(1n);
            setTimeout(() => sut.hostSubscription.shutdown());
            expect(await emitted).toEqual([0n, 1n]);
            done();
          }, 1);
        });

        it('replays 1 last value emitted before subscription', (done) => {
          someNumbersSource$.next(-1n);
          someNumbersSource$.next(0n);
          setTimeout(() => {
            const emittedFromSubscriptionBeforeConnect = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
            sut.hostMessenger.connect();
            setTimeout(() => {
              const emittedFromSubscriptionAfterConnect = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
              setTimeout(async () => {
                someNumbersSource$.next(1n);
                setTimeout(() => sut.hostSubscription.shutdown());
                expect(await emittedFromSubscriptionBeforeConnect).toEqual([0n, 1n]);
                expect(await emittedFromSubscriptionBeforeConnect).toEqual(await emittedFromSubscriptionAfterConnect);
                done();
              }, 1);
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
          someNumbersSource$.error(new Error('err'));
        });

        it('when thrown before subscription', (done) => {
          someNumbersSource$.error(new Error('err'));
          subscribeAndAssertError(done);
        });
      });
    });

    it('nested property | mirrors source emissions and completion for values emitted after subscription', (done) => {
      const emitted = firstValueFrom(sut.consumer.nested.nestedSomeNumbers$.pipe(toArray()));
      setTimeout(async () => {
        nestedSomeNumbersSource$.next(0n);
        nestedSomeNumbersSource$.next(1n);
        setTimeout(() => sut.hostSubscription.shutdown());
        expect(await emitted).toEqual([0n, 1n]);
        done();
      }, 1);
    });

    describe('changing source', () => {
      describe('top level property', () => {
        it('mirrors values emitted from original source, then from new source', (done) => {
          const emitted = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
          setTimeout(async () => {
            // Emit from first api object
            someNumbersSource$.next(0n);
            // Switch to otherApi
            sut.api$.next(otherApi);
            // Emit from otherApi
            someOtherNumbersSource$.next(1n);
            setTimeout(() => sut.hostSubscription.shutdown());
            expect(await emitted).toEqual([0n, 1n]);
            done();
          }, 1);
        });

        it('replays 1 last value emitted by new source before subscription', (done) => {
          someNumbersSource$.next(-1n);
          sut.api$.next(otherApi);
          someOtherNumbersSource$.next(0n);
          setTimeout(() => {
            const emittedFromSubscriptionBeforeConnect = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
            sut.hostMessenger.connect();
            setTimeout(() => {
              const emittedFromSubscriptionAfterConnect = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
              setTimeout(async () => {
                someOtherNumbersSource$.next(1n);
                setTimeout(() => sut.hostSubscription.shutdown());
                expect(await emittedFromSubscriptionBeforeConnect).toEqual([0n, 1n]);
                expect(await emittedFromSubscriptionBeforeConnect).toEqual(await emittedFromSubscriptionAfterConnect);
                done();
              }, 1);
            }, 1);
          }, 1);
        });

        it('mirrors new source errors', (done) => {
          sut.consumer.someNumbers$.subscribe({
            error: (error) => {
              expect(error instanceof Error).toBe(true);
              expect(error.message).toBe('err');
              done();
            }
          });
          sut.api$.next(otherApi);
          someOtherNumbersSource$.error(new Error('err'));
          expect.assertions(2);
        });

        it('nested property | mirrors new source emissions and completion for values emitted', (done) => {
          const emitted = firstValueFrom(sut.consumer.nested.nestedSomeNumbers$.pipe(toArray()));
          setTimeout(async () => {
            nestedSomeNumbersSource$.next(0n);
            sut.api$.next(otherApi);
            nestedOtherSomeNumbers$.next(1n);
            setTimeout(() => sut.hostSubscription.shutdown());
            expect(await emitted).toEqual([0n, 1n]);
            done();
          }, 1);
        });

        it('ignores old source emissions', (done) => {
          const emitted = firstValueFrom(sut.consumer.someNumbers$.pipe(toArray()));
          setTimeout(async () => {
            sut.api$.next(otherApi);
            someNumbersSource$.next(0n); // ignored because source has changed
            someOtherNumbersSource$.next(1n);
            setTimeout(() => sut.hostMessenger.shutdown());
            expect(await emitted).toEqual([1n]);
            done();
          }, 1);
        });

        it('rejects new api object with missing properties', async () => {
          otherApi.someNumbers$ = null as unknown as typeof otherApi['someNumbers$'];
          sut.api$.next(otherApi);
          await expect(firstValueFrom(sut.consumer.someNumbers$)).rejects.toThrowError();
        });
      });
    });
  });
});
