import { PortMessage, RemoteApiProperty, consumeMessengerRemoteApi, exposeMessengerApi } from '../../src/messaging';
import { Subject, Subscription, map, of } from 'rxjs';
import { dummyLogger } from 'ts-log';

const logger = dummyLogger;

const baseChannel = 'some-channel';
const createMessenger = (local$: Subject<unknown>, remote$: Subject<unknown>) => {
  const postMessage = (message: unknown) => {
    remote$.next(message);
    return of(void 0);
  };
  return {
    channel: baseChannel,
    message$: local$.pipe(map((data): PortMessage => ({ data, port: { postMessage } }))),
    postMessage
  };
};

const api = {
  addOne: async (arg: bigint) => arg + 1n
};

describe('remoteApi', () => {
  let hostMessage$: Subject<unknown>;
  let consumerMessage$: Subject<unknown>;
  let hostSubscription: Subscription;
  let consumer: typeof api;

  beforeAll(() => {
    hostMessage$ = new Subject();
    consumerMessage$ = new Subject();
    hostSubscription = exposeMessengerApi(
      {
        api,
        baseChannel,
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
        messenger: createMessenger(hostMessage$, consumerMessage$)
      }
    );
    consumer = consumeMessengerRemoteApi<typeof api>(
      {
        baseChannel,
        properties: {
          addOne: RemoteApiProperty.MethodReturningPromise
        }
      },
      { logger, messenger: createMessenger(consumerMessage$, hostMessage$) }
    );
  });

  afterAll(() => {
    hostMessage$.complete();
    consumerMessage$.complete();
    hostSubscription.unsubscribe();
  });

  it('invalid properties are undefined', () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect((consumer as any).addTwo).toBeUndefined();
  });

  describe('methods returning promise', () => {
    it('calls remote method and resolves result', async () => {
      expect(await consumer.addOne(2n)).toBe(3n);
    });
    describe('methodRequestOptions', () => {
      // see beforeAll for setup
      test('transform', async () => {
        expect(await consumer.addOne(1n)).toBe(3n);
      });
      test('validate', async () => {
        await expect(() => consumer.addOne(0n)).rejects.toThrowError();
      });
    });
  });
});
