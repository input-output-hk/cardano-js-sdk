import { contextLogger } from '@cardano-sdk/util';

import { InvalidModuleState } from './errors';
import { Logger } from 'ts-log';
import { ModuleState } from './types';

export type RunnableModuleState = ModuleState | 'starting' | 'running' | 'stopping';

export abstract class RunnableModule {
  public state: RunnableModuleState;
  protected abstract initializeImpl(): Promise<void>;
  protected abstract startImpl(): Promise<void>;
  protected abstract shutdownImpl(): Promise<void>;
  logger: Logger;
  name: string;

  protected constructor(name: string, logger: Logger) {
    this.state = null;
    this.logger = contextLogger(logger, name);
    this.name = name;
  }

  async initialize() {
    this.initializeBefore();
    await this.initializeImpl();
    this.initializeAfter();
  }

  async start() {
    this.startBefore();
    await this.startImpl();
    this.startAfter();
  }

  async shutdown() {
    this.shutdownBefore();
    await this.shutdownImpl();
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
