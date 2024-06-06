import { InvalidModuleState, RunnableModule } from '../src/index.js';
import { createStubLogger } from './util.js';
import { dummyLogger } from 'ts-log';
import type { Logger } from 'ts-log';

class SomeRunnableModule extends RunnableModule {
  constructor(logger = dummyLogger) {
    super('Some Module', logger);
  }

  protected initializeImpl(): Promise<void> {
    return Promise.resolve();
  }

  protected startImpl(): Promise<void> {
    return Promise.resolve();
  }

  protected shutdownImpl(): Promise<void> {
    return Promise.resolve();
  }
}

describe('RunnableModule', () => {
  let logger: Logger;

  beforeEach(() => {
    logger = createStubLogger();
  });

  describe('construction', () => {
    it('initially has null state', () => {
      const runnableModule = new SomeRunnableModule();
      expect(runnableModule.state).toBeNull();
    });
    it('optionally takes a logger on construction', () => {
      const runnableModule = new SomeRunnableModule(logger);
      expect(runnableModule.state).toBeNull();
      expect(logger.info).not.toHaveBeenCalled();
    });
  });
  describe('initialize', () => {
    let runnableModule: RunnableModule;

    beforeEach(() => {
      runnableModule = new SomeRunnableModule(logger);
    });

    it('changes state if not already in progress, and logs info', async () => {
      expect(runnableModule.state).toBeNull();
      await runnableModule.initialize();
      expect(runnableModule.state).toBe('initialized');
      expect(logger.info).toHaveBeenCalled();
      jest.resetAllMocks();
      await expect(runnableModule.initialize()).rejects.toThrowError(InvalidModuleState);
      expect(runnableModule.state).toBe('initialized');
      expect(logger.info).not.toHaveBeenCalled();
    });
  });

  describe('start', () => {
    let runnableModule: RunnableModule;

    beforeEach(async () => {
      runnableModule = new SomeRunnableModule(logger);
      await runnableModule.initialize();
    });

    it('changes state if initialized and not already in progress, and logs info', async () => {
      expect(runnableModule.state).toBe('initialized');
      await runnableModule.start();
      expect(logger.info).toHaveBeenCalled();
      expect(runnableModule.state).toBe('running');
      jest.resetAllMocks();
      await expect(runnableModule.initialize()).rejects.toThrowError(InvalidModuleState);
      expect(runnableModule.state).toBe('running');
      expect(logger.info).not.toHaveBeenCalled();
    });
  });

  describe('shutdown', () => {
    let runnableModule: RunnableModule;

    beforeEach(async () => {
      runnableModule = new SomeRunnableModule(logger);
      await runnableModule.initialize();
      await runnableModule.start();
    });

    it('changes state if running and not already in progress, and logs info', async () => {
      expect(runnableModule.state).toBe('running');
      await runnableModule.shutdown();
      expect(logger.info).toHaveBeenCalled();
      expect(runnableModule.state).toBe('initialized');
      jest.resetAllMocks();
      await expect(runnableModule.initialize()).rejects.toThrowError(InvalidModuleState);
      await expect(runnableModule.shutdown()).rejects.toThrowError(InvalidModuleState);
      expect(runnableModule.state).toBe('initialized');
      expect(logger.info).not.toHaveBeenCalled();
    });
  });
});
