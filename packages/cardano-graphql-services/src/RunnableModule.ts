import { InvalidModuleState } from './errors';
import { Logger, dummyLogger } from 'ts-log';
import { ModuleState } from './types';
import { moduleLogger } from './util';

export type RunnableModuleState = ModuleState | 'starting' | 'running' | 'stopping';

export abstract class RunnableModule {
  public state: RunnableModuleState;
  protected abstract initializeImpl(parameters?: any): Promise<void>;
  protected abstract startImpl(parameters?: any): Promise<void>;
  protected abstract shutdownImpl(parameters?: any): Promise<void>;
  logger: Logger;
  name: string;

  protected constructor(name: string, logger: Logger = dummyLogger) {
    this.state = null;
    this.logger = moduleLogger(logger, name) || dummyLogger;
    this.name = name;
  }

  async initialize(parameters?: any) {
    this.initializeBefore();
    await this.initializeImpl(parameters);
    this.initializeAfter();
  }

  async start(parameters?: any) {
    this.startBefore();
    await this.startImpl(parameters);
    this.startAfter();
  }

  async shutdown(parameters?: any) {
    this.shutdownBefore();
    await this.shutdownImpl(parameters);
    this.shutdownAfter();
  }

  initializeBefore() {
    if (this.state !== null) {
      throw new InvalidModuleState<RunnableModuleState>(this.name, 'initializeBefore', null);
    }
    this.state = 'initializing';
    this.logger.info('Initializing...');
  }

  initializeAfter() {
    if (this.state !== 'initializing') {
      throw new InvalidModuleState<RunnableModuleState>(this.name, 'initializeAfter', 'initializing');
    }
    this.state = 'initialized';
    this.logger.info('Initialized');
  }

  startBefore() {
    if (this.state !== 'initialized') {
      throw new InvalidModuleState<RunnableModuleState>(this.name, 'start', 'initialized');
    }
    this.state = 'starting';
    this.logger.info('Starting');
  }

  startAfter() {
    if (this.state !== 'starting') {
      throw new InvalidModuleState<RunnableModuleState>(this.name, 'start', 'starting');
    }
    this.state = 'running';
    this.logger.info('Started');
  }

  shutdownBefore() {
    if (this.state !== 'running') {
      throw new InvalidModuleState<RunnableModuleState>(this.name, 'shutdown', 'running');
    }
    this.state = 'stopping';
    this.logger.info('Stopping');
  }

  shutdownAfter() {
    if (this.state !== 'stopping') {
      throw new InvalidModuleState<RunnableModuleState>(this.name, 'shutdown', 'stopping');
    }
    this.state = 'initialized';
    this.logger.info('Shutdown complete...');
  }
}
