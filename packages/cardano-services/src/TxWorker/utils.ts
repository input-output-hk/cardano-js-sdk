/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-shadow */
/* eslint-disable no-use-before-define */
import { CONNECTION_ERROR_EVENT, TxSubmitWorker } from '../TxSubmit';
import { CommonOptionDescriptions } from '../ProgramsCommon';
import { DnsResolver, MissingProgramOption, ServiceNames, srvRecordToRabbitmqURL } from '../Program';
import { Logger } from 'ts-log';
import { ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { TxWorkerOptions } from './loadTxWorker';

type WorkerFactory = () => Promise<TxSubmitWorker>;

/**
 * Create a worker factory with service discovery
 *
 * @param {DnsResolver} dnsResolver used for DNS resolution
 * @param {TxSubmitProvider} txSubmitProvider tx submit provider 'ogmiosTxSubmitProvider'
 * @param {Logger} logger common logger
 * @param {TxWorkerOptions} options needed for tx worker initialization
 * @returns {WorkerFactory} WorkerFactory with service discovery, returning a 'TxSubmitWorker' instance
 */
export const createWorkerFactoryWithDiscovery =
  (
    dnsResolver: DnsResolver,
    txSubmitProvider: TxSubmitProvider,
    logger: Logger,
    options: TxWorkerOptions
  ): WorkerFactory =>
  async () => {
    const record = await dnsResolver(options.rabbitmqSrvServiceName!);
    return new TxSubmitWorker(
      { ...options, rabbitmqUrl: srvRecordToRabbitmqURL(record) },
      { logger, txSubmitProvider }
    );
  };

/**
 * Create and start a new worker instance with registered listener for connection error events
 *
 * @param {WorkerFactory} workerFactory creates a worker instance with service discovery
 */
export const createAndStartNewWorker = async (workerFactory: WorkerFactory) => {
  const newWorker = await workerFactory();
  attachOnConnectionErrorHandler(newWorker, workerFactory);
  await newWorker.start();
};

/**
 * With service discovery, register a listener for 'connection-error' event type
 * emitted in the case of a connection-related runtime error
 *
 * @param {TxSubmitWorker} worker TxSubmitWorker instance
 * @param {WorkerFactory} factory creates a worker instance with service discovery
 */
export const attachOnConnectionErrorHandler = (worker: TxSubmitWorker, factory: WorkerFactory) => {
  worker.on(CONNECTION_ERROR_EVENT, () => createAndStartNewWorker(factory));
};

export type RunningTxSubmitWorker = Pick<TxSubmitWorker, 'stop' | 'getStatus'>;

/**
 * An abstraction which starts and manages restarts of the worker instance with service discovery
 *
 * @param {WorkerFactory} workerFactory creates a worker instance with service discovery
 * @returns {RunningTxSubmitWorker} RunningTxSubmitWorker instance
 */
export const startTxSubmitWorkerWithDiscovery = async (
  workerFactory: WorkerFactory
): Promise<RunningTxSubmitWorker> => {
  let worker: TxSubmitWorker;
  await createAndStartNewWorker(async () => (worker = await workerFactory()));

  return {
    getStatus: () => worker.getStatus(),
    stop: () => worker.stop()
  };
};

/**
 * Create and return a running worker instance with static service config or service discovery
 *
 * @param {DnsResolver} dnsResolver used for DNS resolution
 * @param {TxSubmitProvider} txSubmitProvider tx submit provider 'ogmiosTxSubmitProvider'
 * @param {Logger} logger common logger
 * @param {TxWorkerOptions} options needed for tx worker initialization
 * @returns {RunningTxSubmitWorker} RunningTxSubmitWorker instance
 * @throws {MissingProgramOption} error if neither URL nor service name is provided
 */
export const getRunningTxSubmitWorker = async (
  dnsResolver: DnsResolver,
  txSubmitProvider: TxSubmitProvider,
  logger: Logger,
  options?: TxWorkerOptions
): Promise<RunningTxSubmitWorker> => {
  if (options?.rabbitmqSrvServiceName)
    return startTxSubmitWorkerWithDiscovery(
      createWorkerFactoryWithDiscovery(dnsResolver, txSubmitProvider, logger, options)
    );
  if (options?.rabbitmqUrl) {
    const worker = new TxSubmitWorker({ ...options, rabbitmqUrl: options.rabbitmqUrl }, { logger, txSubmitProvider });
    worker.on(CONNECTION_ERROR_EVENT, (error) => {
      logger.error(`Worker received a connection error event, terminating the process caused by: ${error}`);
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    });
    await worker.start();
    return worker;
  }
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    CommonOptionDescriptions.RabbitMQUrl,
    CommonOptionDescriptions.RabbitMQSrvServiceName
  ]);
};
