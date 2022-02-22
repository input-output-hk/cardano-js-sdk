import { Logger } from 'ts-log';
import { RunnableModule } from '../../src/DataProjection/RunnableModule';
import { createStubLogger } from '../util/stubLogger';

describe('RunnableModule', () => {
  let loggerInfoSpy: jest.SpyInstance;
  let logger: Logger;

  beforeEach(() => {
    logger = createStubLogger();
  });

  describe('construction', () => {
    it('initially has null state', () => {
      const runnableModule = new RunnableModule('SomeModule');
      expect(runnableModule.state).toBeNull();
    });
    it('optionally takes a logger on construction', () => {
      loggerInfoSpy = jest.spyOn(logger, 'info');
      const runnableModule = new RunnableModule('SomeModule', logger);
      expect(runnableModule.state).toBeNull();
      expect(loggerInfoSpy).not.toHaveBeenCalled();
    });
  });
  describe('initializeBefore', () => {
    let runnableModule: RunnableModule;

    beforeEach(() => {
      runnableModule = new RunnableModule('SomeModule', logger);
      loggerInfoSpy = jest.spyOn(logger, 'info');
    });

    it('changes state if not already in progress, and logs info', () => {
      expect(runnableModule.state).toBeNull();
      expect(() => runnableModule.initializeBefore()).not.toThrow();
      expect(runnableModule.state).toBe('initializing');
      expect(loggerInfoSpy).toHaveBeenCalled();
      loggerInfoSpy.mockReset();
      expect(() => runnableModule.initializeBefore()).toThrow();
      expect(runnableModule.state).toBe('initializing');
      expect(loggerInfoSpy).not.toHaveBeenCalled();
    });
  });

  describe('initializeAfter', () => {
    let runnableModule: RunnableModule;

    beforeEach(() => {
      runnableModule = new RunnableModule('SomeModule', logger);
      runnableModule.initializeBefore();
      loggerInfoSpy = jest.spyOn(logger, 'info');
    });

    it('changes state if initializing and not already in progress, and logs info', () => {
      expect(runnableModule.state).toBe('initializing');
      expect(() => runnableModule.initializeAfter()).not.toThrow();
      expect(loggerInfoSpy).toHaveBeenCalled();
      expect(runnableModule.state).toBe('initialized');
      loggerInfoSpy.mockReset();
      expect(() => runnableModule.initializeBefore()).toThrow();
      expect(() => runnableModule.initializeAfter()).toThrow();
      expect(() => runnableModule.startAfter()).toThrow();
      expect(() => runnableModule.shutdownBefore()).toThrow();
      expect(() => runnableModule.shutdownAfter()).toThrow();
      expect(runnableModule.state).toBe('initialized');
      expect(loggerInfoSpy).not.toHaveBeenCalled();
    });
  });

  describe('startBefore', () => {
    let runnableModule: RunnableModule;

    beforeEach(() => {
      runnableModule = new RunnableModule('SomeModule', logger);
      runnableModule.initializeBefore();
      runnableModule.initializeAfter();
      loggerInfoSpy = jest.spyOn(logger, 'info');
    });

    it('changes state if initialized and not already in progress, and logs info', () => {
      expect(runnableModule.state).toBe('initialized');
      expect(() => runnableModule.startBefore()).not.toThrow();
      expect(loggerInfoSpy).toHaveBeenCalled();
      expect(runnableModule.state).toBe('starting');
      loggerInfoSpy.mockReset();
      expect(() => runnableModule.initializeBefore()).toThrow();
      expect(() => runnableModule.initializeAfter()).toThrow();
      expect(() => runnableModule.startBefore()).toThrow();
      expect(() => runnableModule.shutdownBefore()).toThrow();
      expect(() => runnableModule.shutdownAfter()).toThrow();
      expect(runnableModule.state).toBe('starting');
      expect(loggerInfoSpy).not.toHaveBeenCalled();
    });
  });

  describe('startAfter', () => {
    let runnableModule: RunnableModule;

    beforeEach(() => {
      runnableModule = new RunnableModule('SomeModule', logger);
      runnableModule.initializeBefore();
      runnableModule.initializeAfter();
      runnableModule.startBefore();
      loggerInfoSpy = jest.spyOn(logger, 'info');
    });

    it('changes state if starting and not already in progress, and logs info', () => {
      expect(runnableModule.state).toBe('starting');
      expect(() => runnableModule.startAfter()).not.toThrow();
      expect(loggerInfoSpy).toHaveBeenCalled();
      expect(runnableModule.state).toBe('running');
      loggerInfoSpy.mockReset();
      expect(() => runnableModule.initializeBefore()).toThrow();
      expect(() => runnableModule.initializeAfter()).toThrow();
      expect(() => runnableModule.startBefore()).toThrow();
      expect(() => runnableModule.startAfter()).toThrow();
      expect(() => runnableModule.shutdownAfter()).toThrow();
      expect(runnableModule.state).toBe('running');
      expect(loggerInfoSpy).not.toHaveBeenCalled();
    });
  });

  describe('shutdownBefore', () => {
    let runnableModule: RunnableModule;

    beforeEach(() => {
      runnableModule = new RunnableModule('SomeModule', logger);
      runnableModule.initializeBefore();
      runnableModule.initializeAfter();
      runnableModule.startBefore();
      runnableModule.startAfter();
      loggerInfoSpy = jest.spyOn(logger, 'info');
    });

    it('changes state if running and not already in progress, and logs info', () => {
      expect(runnableModule.state).toBe('running');
      expect(() => runnableModule.shutdownBefore()).not.toThrow();
      expect(loggerInfoSpy).toHaveBeenCalled();
      expect(runnableModule.state).toBe('stopping');
      loggerInfoSpy.mockReset();
      expect(() => runnableModule.initializeBefore()).toThrow();
      expect(() => runnableModule.initializeAfter()).toThrow();
      expect(() => runnableModule.startBefore()).toThrow();
      expect(() => runnableModule.startAfter()).toThrow();
      expect(() => runnableModule.shutdownBefore()).toThrow();
      expect(runnableModule.state).toBe('stopping');
      expect(loggerInfoSpy).not.toHaveBeenCalled();
    });
  });

  describe('shutdownAfter', () => {
    let runnableModule: RunnableModule;

    beforeEach(() => {
      runnableModule = new RunnableModule('SomeModule', logger);
      runnableModule.initializeBefore();
      runnableModule.initializeAfter();
      runnableModule.startBefore();
      runnableModule.startAfter();
      runnableModule.shutdownBefore();
      loggerInfoSpy = jest.spyOn(logger, 'info');
    });

    it('changes state if stopping and not already in progress, and logs info', () => {
      expect(runnableModule.state).toBe('stopping');
      expect(() => runnableModule.shutdownAfter()).not.toThrow();
      expect(loggerInfoSpy).toHaveBeenCalled();
      expect(runnableModule.state).toBe('initialized');
      loggerInfoSpy.mockReset();
      expect(() => runnableModule.initializeBefore()).toThrow();
      expect(() => runnableModule.initializeAfter()).toThrow();
      expect(() => runnableModule.startAfter()).toThrow();
      expect(() => runnableModule.shutdownBefore()).toThrow();
      expect(() => runnableModule.shutdownAfter()).toThrow();
      expect(runnableModule.state).toBe('initialized');
      expect(loggerInfoSpy).not.toHaveBeenCalled();
    });
  });
});
