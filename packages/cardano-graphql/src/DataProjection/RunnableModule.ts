import { InvalidModuleState } from './errors';
import { Logger, dummyLogger } from 'ts-log';
import { ModuleState } from './types';
import { moduleLogger } from '../util';

export type RunnableModuleState = ModuleState | 'starting' | 'running' | 'stopping';

export abstract class RunnableModule {
  public state: RunnableModuleState;
  logger: Logger;
  name: string;

  constructor(name: string, logger: Logger = dummyLogger) {
    this.state = null;
    this.logger = moduleLogger(logger, name) || dummyLogger;
    this.name = name;
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

  protected abstract initializeImpl(parameter?: any): Promise<void>;
  async initialize(parameter?: any) {
    this.initializeBefore();
    await this.initializeImpl(parameter);
    this.initializeAfter();
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

  protected abstract startImpl(parameter?: any): Promise<void>;
  async start(parameter?: any) {
    this.startBefore();
    await this.startImpl(parameter);
    this.startAfter();
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

  protected abstract shutdownImpl(): Promise<void>;
  async shutdown() {
    this.shutdownBefore();
    await this.shutdownImpl();
    this.shutdownBefore();
  }
}
