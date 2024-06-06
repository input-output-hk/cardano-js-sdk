import { CustomError } from 'ts-custom-error';
import { contextLogger } from './logging.js';
import type { Logger } from 'ts-log';

export class InvalidModuleState<ModuleState> extends CustomError {
  public constructor(moduleName: string, methodName: string, requiredState: ModuleState) {
    super();
    this.message = `${methodName} cannot be called unless ${moduleName} is ${requiredState}`;
  }
}

export type RunnableModuleState = null | 'initializing' | 'initialized' | 'starting' | 'running' | 'stopping';

export abstract class RunnableModule {
  public state: RunnableModuleState;
  protected abstract initializeImpl(): Promise<void>;
  protected abstract startImpl(): Promise<void>;
  protected abstract shutdownImpl(): Promise<void>;
  logger: Logger;
  name: string;

  constructor(name: string, logger: Logger) {
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
    this.logger.info('Starting...');
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
    this.logger.info('Stopping...');
  }

  shutdownAfter() {
    if (this.state !== 'stopping') {
      throw new InvalidModuleState<RunnableModuleState>(this.name, 'shutdown', 'stopping');
    }
    this.state = 'initialized';
    this.logger.info('Shutdown complete');
  }
}
