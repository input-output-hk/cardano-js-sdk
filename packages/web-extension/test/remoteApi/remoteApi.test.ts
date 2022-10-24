import { EMPTY, Observable, Subject, map } from 'rxjs';
import { Messenger, PortMessage, RemoteApiPropertyType, RequestMessage, exposeMessengerApi } from '../../src/messaging';
import { dummyLogger } from 'ts-log';

const logger = dummyLogger;

enum ApiObjectType {
  simple = 'simple',
  nested = 'nested'
}

type SimpleApi = { someNumbers$: Observable<number>; somePromiseMethod: () => Promise<number> };

const setUp = (mode: ApiObjectType) => {
  const incomingMsg$ = new Subject<PortMessage<unknown>>();

  const observablePropMessenger: Messenger = {
    channel: 'mockMessenger-someNumbers$',
    connect$: new Subject(),
    deriveChannel: jest.fn(),
    message$: new Subject(),
    postMessage: jest.fn().mockImplementation(() => EMPTY),
    shutdown: jest.fn()
  };
  const mockMessenger: Messenger = {
    channel: 'mockMessenger',
    connect$: new Subject(),
    deriveChannel: jest.fn().mockImplementation(() => observablePropMessenger),
    message$: incomingMsg$.asObservable(),
    postMessage: jest.fn().mockImplementation(() => EMPTY),
    shutdown: jest.fn()
  };
  const mockMessengerOuter: Messenger = {
    channel: 'mockMessengerOuter',
    connect$: new Subject(),
    deriveChannel: jest.fn().mockImplementation(() => mockMessenger),
    message$: new Subject(),
    postMessage: jest.fn().mockImplementation(() => EMPTY),
    shutdown: jest.fn()
  };

  const properties = {
    someNumbers$: RemoteApiPropertyType.HotObservable,
    somePromiseMethod: RemoteApiPropertyType.MethodReturningPromise
  };
  const apiSource$ = new Subject<SimpleApi | null>();

  const someNumbers$ = new Subject<number>();
  const someNumbers2$ = new Subject<number>();

  const api = [
    { obj: { someNumbers$, somePromiseMethod: jest.fn().mockResolvedValue(5) }, sourceNumbers$: someNumbers$ },
    {
      obj: { someNumbers$: someNumbers2$, somePromiseMethod: jest.fn().mockResolvedValue(55) },
      sourceNumbers$: someNumbers2$
    }
  ];

  const hostSubscription =
    mode === ApiObjectType.simple
      ? exposeMessengerApi<SimpleApi>(
          {
            api$: apiSource$,
            properties
          },
          {
            logger,
            messenger: mockMessenger
          }
        )
      : exposeMessengerApi<{ innerProps: SimpleApi }>(
          {
            api$: apiSource$.pipe(map((v) => (v ? { innerProps: v } : v))),
            properties: { innerProps: properties }
          },
          {
            logger,
            messenger: mockMessengerOuter
          }
        );

  return {
    api,
    apiSource$,
    hostSubscription,
    incomingMsg$,
    mockMessenger,
    observablePropMessenger,
    shutdown: () => {
      hostSubscription.shutdown();
      apiSource$.complete();
      incomingMsg$.complete();
      someNumbers$.complete();
      someNumbers2$.complete();
    }
  };
};

describe('remoteApi', () => {
  describe.each([ApiObjectType.simple, ApiObjectType.nested])('[%s] exposeMessengerApi', (mode) => {
    let sut: ReturnType<typeof setUp>;
    let postMessage: jest.Mock;

    beforeEach(() => {
      postMessage = jest.fn();
      sut = setUp(mode);
    });

    afterEach(() => {
      sut.shutdown();
    });

    describe('no api emitted yet', () => {
      it('creates messenger object for HotObservable property', () => {
        expect(sut.mockMessenger.deriveChannel).toHaveBeenCalledWith('someNumbers$');
      });

      it('subscribes SimpleApi observable source', () => {
        expect(sut.apiSource$.observed).toBe(true);
      });

      it('unsubscribes SimpleApi observable source and sends unsubscribe message on shutdown', () => {
        sut.hostSubscription.shutdown();
        expect(sut.observablePropMessenger.postMessage).toHaveBeenCalledWith(
          expect.objectContaining({ subscribe: false })
        );
        expect(sut.apiSource$.observed).toBe(false);
      });

      it('does NOT send unsubscribe messages when SimpleApi observable completes', () => {
        sut.apiSource$.complete();
        expect(sut.observablePropMessenger.postMessage).not.toHaveBeenCalled();
        expect(sut.incomingMsg$.observed).toBe(true);
      });
    });

    describe('api objects emitted', () => {
      beforeEach(() => sut.apiSource$.next(sut.api[0].obj));

      it('does NOT send unsubscribe messages when api property completes', () => {
        sut.api[0].sourceNumbers$.complete();
        expect(sut.observablePropMessenger.postMessage).not.toHaveBeenCalled();
      });

      it('unsubscribes api object properties on shutdown', () => {
        sut.hostSubscription.shutdown();
        expect(sut.api[0].sourceNumbers$.observed).toBe(false);
      });

      it('subscribes to api object properties emitted by apiSource$', () => {
        expect(sut.api[0].sourceNumbers$.observed).toBe(true);
      });

      it('mirrors api observable properties on property messenger channel ', () => {
        sut.api[0].sourceNumbers$.next(1);
        expect(sut.observablePropMessenger.postMessage).toHaveBeenCalledWith(expect.objectContaining({ emit: 1 }));
      });

      it('mirrors values from new api objects and unsubscribes prev api', () => {
        sut.apiSource$.next(sut.api[1].obj);
        sut.api[1].sourceNumbers$.next(2);
        expect(sut.api[0].sourceNumbers$.observed).toBe(false);
        expect(sut.observablePropMessenger.postMessage).toHaveBeenCalledWith(expect.objectContaining({ emit: 2 }));
      });

      it('null api unsubscribes observable channels', () => {
        sut.apiSource$.next(null);
        expect(sut.api[0].sourceNumbers$.observed).toBe(false);
      });
    });

    describe('MethodReturningPromise', () => {
      it('monitors requests', () => {
        expect(sut.incomingMsg$.observed).toBe(true);
      });

      it('stops mirroring requests on shutdown', () => {
        sut.hostSubscription.shutdown();
        expect(sut.incomingMsg$.observed).toBe(false);
      });

      it('ignores requests that are not valid', () => {
        sut.incomingMsg$.next({ data: {}, port: { postMessage } });
        expect(postMessage).not.toHaveBeenCalled();
      });

      it('mirrors requests to method returning promise only after an api object is emitted', (done) => {
        const request: RequestMessage = { messageId: 'abc', request: { args: [], method: 'somePromiseMethod' } };
        sut.incomingMsg$.next({ data: request, port: { postMessage } });
        expect(sut.api[0].obj.somePromiseMethod).not.toHaveBeenCalled();
        sut.apiSource$.next(sut.api[0].obj);
        setTimeout(() => {
          expect(sut.api[0].obj.somePromiseMethod).toHaveBeenCalled();
          expect(postMessage).toHaveBeenCalledWith(expect.objectContaining({ response: 5 }));
          done();
        });
      });

      it('mirrors requests to method from new api', (done) => {
        sut.apiSource$.next(sut.api[1].obj);
        const request: RequestMessage = { messageId: 'abc', request: { args: [], method: 'somePromiseMethod' } };
        sut.incomingMsg$.next({ data: request, port: { postMessage } });
        setTimeout(() => {
          expect(postMessage).toHaveBeenCalledWith(expect.objectContaining({ response: 55 }));
          done();
        });
      });

      it('null api makes new promise wait until a new valid api is emitted', (done) => {
        sut.apiSource$.next(null);
        const request: RequestMessage = { messageId: 'abc', request: { args: [], method: 'somePromiseMethod' } };
        sut.incomingMsg$.next({ data: request, port: { postMessage } });
        setTimeout(() => {
          expect(postMessage).not.toHaveBeenCalled();
          // After emitting a valid api, promise calls will resolve to methods from the new api
          sut.apiSource$.next(sut.api[0].obj);
          setTimeout(() => {
            expect(postMessage).toHaveBeenCalledWith(expect.objectContaining({ response: 5 }));
            done();
          });
        });
      });
    });
  });

  describe('consumer', () => {
    it.todo('it handles messages correctly');
  });
});
