/* eslint-disable promise/no-nesting */
/* eslint-disable no-use-before-define */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { CONNECTION_ERROR_EVENT, RabbitMqTxSubmitProvider, TxSubmitWorker } from '../../TxSubmit';
import { DnsResolver } from '../utils';
import { Logger } from 'ts-log';
import { MissingProgramOption } from '../errors';
import { OgmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import { ProviderError, ProviderFailure, SubmitTxArgs } from '@cardano-sdk/core';
import { RabbitMqOptionDescriptions, RabbitMqProgramOptions } from '../options';
import { ServiceNames } from '../programs/types';
import { SrvRecord } from 'dns';
import { TxWorkerArgs } from '../programs/txWorker';
import { isConnectionError } from '@cardano-sdk/util';

export const srvRecordToRabbitmqURL = ({ name, port }: SrvRecord) => new URL(`amqp://${name}:${port}`);

/**
 * Creates a extended RabbitMqTxSubmitProvider instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with failovers (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'submitTx' operation and handle connection errors runtime
 * - all other operations are bind to pool object withoud modifications
 *
 * @returns RabbitMqTxSubmitProvider instance
 */
export const rabbitMqTxSubmitProviderWithDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): Promise<RabbitMqTxSubmitProvider> => {
  const record = await dnsResolver(serviceName!);
  let rabbitmqProvider = new RabbitMqTxSubmitProvider({ rabbitmqUrl: srvRecordToRabbitmqURL(record) }, { logger });

  return new Proxy<RabbitMqTxSubmitProvider>({} as RabbitMqTxSubmitProvider, {
    get(_, prop, receiver) {
      if (prop === 'then') return;
      if (prop === 'submitTx') {
        return (submitTxArgs: SubmitTxArgs) =>
          rabbitmqProvider.submitTx(submitTxArgs).catch(async (error) => {
            if (isConnectionError(error)) {
              const resolvedRecord = await dnsResolver(serviceName!);
              logger.info(`DNS resolution for RabbitMQ service, resolved with record: ${JSON.stringify(record)}`);
              await rabbitmqProvider
                .close?.()
                .catch((error_) => logger.warn(`RabbitMQ provider failed to close after DNS resolution: ${error_}`));
              rabbitmqProvider = new RabbitMqTxSubmitProvider(
                { rabbitmqUrl: srvRecordToRabbitmqURL(resolvedRecord) },
                { logger }
              );
              return await receiver.submitTx(submitTxArgs);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof rabbitmqProvider[prop as keyof RabbitMqTxSubmitProvider] === 'function') {
        const method = rabbitmqProvider[prop as keyof RabbitMqTxSubmitProvider] as any;
        return method.bind(rabbitmqProvider);
      }

      return rabbitmqProvider[prop as keyof RabbitMqTxSubmitProvider];
    }
  });
};

export const getRabbitMqTxSubmitProvider = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: RabbitMqProgramOptions
): Promise<RabbitMqTxSubmitProvider> => {
  if (options?.rabbitmqSrvServiceName)
    return rabbitMqTxSubmitProviderWithDiscovery(dnsResolver, logger, options.rabbitmqSrvServiceName);
  if (options?.rabbitmqUrl) return new RabbitMqTxSubmitProvider({ rabbitmqUrl: options.rabbitmqUrl }, { logger });
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    RabbitMqOptionDescriptions.Url,
    RabbitMqOptionDescriptions.SrvServiceName
  ]);
};

type WorkerFactory = () => Promise<TxSubmitWorker>;

/**
 * Create a worker factory with service discovery
 *
 * @param {DnsResolver} dnsResolver used for DNS resolution
 * @param {OgmiosTxSubmitProvider} txSubmitProvider tx submit provider
 * @param {Logger} logger common logger
 * @param {TxWorkerArgs} args needed for tx worker initialization
 * @returns {WorkerFactory} WorkerFactory with service discovery, returning a 'TxSubmitWorker' instance
 */
export const createWorkerFactoryWithDiscovery =
  (
    dnsResolver: DnsResolver,
    txSubmitProvider: OgmiosTxSubmitProvider,
    logger: Logger,
    args: TxWorkerArgs
  ): WorkerFactory =>
  async () => {
    const record = await dnsResolver(args.rabbitmqSrvServiceName!);
    return new TxSubmitWorker({ ...args, rabbitmqUrl: srvRecordToRabbitmqURL(record) }, { logger, txSubmitProvider });
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

export type RunningTxSubmitWorker = Pick<TxSubmitWorker, 'shutdown' | 'getStatus'>;

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
    shutdown: () => worker.shutdown()
  };
};

/**
 * Create and return a running worker instance with static service config or service discovery
 *
 * @param {DnsResolver} dnsResolver used for DNS resolution
 * @param {OgmiosTxSubmitProvider} txSubmitProvider tx submit provider
 * @param {Logger} logger common logger
 * @param {TxWorkerArgs} args needed for tx worker initialization * @returns {RunningTxSubmitWorker} RunningTxSubmitWorker instance
 * @throws {MissingProgramOption} error if neither URL nor service name is provided
 */
export const getRunningTxSubmitWorker = async (
  dnsResolver: DnsResolver,
  txSubmitProvider: OgmiosTxSubmitProvider,
  logger: Logger,
  args?: TxWorkerArgs
): Promise<RunningTxSubmitWorker> => {
  if (args?.rabbitmqSrvServiceName)
    return startTxSubmitWorkerWithDiscovery(
      createWorkerFactoryWithDiscovery(dnsResolver, txSubmitProvider, logger, args)
    );
  if (args?.rabbitmqUrl) {
    const worker = new TxSubmitWorker({ ...args, rabbitmqUrl: args.rabbitmqUrl }, { logger, txSubmitProvider });
    worker.on(CONNECTION_ERROR_EVENT, (error) => {
      logger.error(`Worker received a connection error event, terminating the process caused by: ${error}`);
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    });
    await worker.start();
    return worker;
  }
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    RabbitMqOptionDescriptions.Url,
    RabbitMqOptionDescriptions.SrvServiceName
  ]);
};
