import { Cardano } from '@cardano-sdk/core';
import { Cip30Event, Cip30EventName, Cip30EventRegistry } from '../../src/WalletApi/Cip30EventRegistry';
import { Subject } from 'rxjs';

describe('Cip30EventRegistry', () => {
  let cip30Event$: Subject<Cip30Event>;
  let registry: Cip30EventRegistry;

  beforeEach(() => {
    cip30Event$ = new Subject();
    registry = new Cip30EventRegistry(cip30Event$);
  });

  afterEach(() => {
    registry.shutdown();
  });

  it('should register and trigger networkChange callback', () => {
    const callback = jest.fn();
    registry.register(Cip30EventName.networkChange, callback);

    const networkId: Cardano.NetworkId = 1;
    cip30Event$.next({ data: networkId, eventName: Cip30EventName.networkChange });

    expect(callback).toHaveBeenCalledWith(networkId);
  });

  it('should register and trigger accountChange callback', () => {
    const callback = jest.fn();
    registry.register(Cip30EventName.accountChange, callback);

    const addresses: Cardano.BaseAddress[] = [{} as unknown as Cardano.BaseAddress];
    cip30Event$.next({ data: addresses, eventName: Cip30EventName.accountChange });

    expect(callback).toHaveBeenCalledWith(addresses);
  });

  it('should deregister networkChange callback', () => {
    const callback = jest.fn();
    registry.register(Cip30EventName.networkChange, callback);
    registry.deregister(Cip30EventName.networkChange, callback);

    const networkId: Cardano.NetworkId = 1;
    cip30Event$.next({ data: networkId, eventName: Cip30EventName.networkChange });

    expect(callback).not.toHaveBeenCalled();
  });

  it('should deregister accountChange callback', () => {
    const callback = jest.fn();
    registry.register(Cip30EventName.accountChange, callback);
    registry.deregister(Cip30EventName.accountChange, callback);

    const addresses: Cardano.BaseAddress[] = [{} as unknown as Cardano.BaseAddress];
    cip30Event$.next({ data: addresses, eventName: Cip30EventName.accountChange });

    expect(callback).not.toHaveBeenCalled();
  });

  it('should handle multiple callbacks for the same event', () => {
    const callback1 = jest.fn();
    const callback2 = jest.fn();
    registry.register(Cip30EventName.networkChange, callback1);
    registry.register(Cip30EventName.networkChange, callback2);

    const networkId: Cardano.NetworkId = 1;
    cip30Event$.next({ data: networkId, eventName: Cip30EventName.networkChange });

    expect(callback1).toHaveBeenCalledWith(networkId);
    expect(callback2).toHaveBeenCalledWith(networkId);
  });

  it('should not trigger callbacks after shutdown', () => {
    const callback = jest.fn();
    registry.register(Cip30EventName.networkChange, callback);

    registry.shutdown();

    const networkId: Cardano.NetworkId = 1;
    cip30Event$.next({ data: networkId, eventName: Cip30EventName.networkChange });

    expect(callback).not.toHaveBeenCalled();
    expect(cip30Event$.observed).toBeFalsy();
  });

  it('should not register callbacks after shutdown', () => {
    const callback = jest.fn();
    registry.shutdown();
    registry.register(Cip30EventName.networkChange, callback);

    const networkId: Cardano.NetworkId = 1;
    cip30Event$.next({ data: networkId, eventName: Cip30EventName.networkChange });

    expect(callback).not.toHaveBeenCalled();
  });
});
