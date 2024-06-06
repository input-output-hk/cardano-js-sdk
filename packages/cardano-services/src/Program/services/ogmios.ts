/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { MissingCardanoNodeOption } from '../errors/index.js';
import {
  OgmiosCardanoNode,
  OgmiosObservableCardanoNode,
  OgmiosTxSubmitProvider,
  urlToConnectionConfig
} from '@cardano-sdk/ogmios';
import { OgmiosOptionDescriptions } from '../options/ogmios.js';
import { RunnableModule, isConnectionError } from '@cardano-sdk/util';
import { defer, from, of } from 'rxjs';
import type { DnsResolver } from '../utils.js';
import type { HandleProvider, SubmitTxArgs } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { OgmiosProgramOptions } from '../options/ogmios.js';

const isCardanoNodeOperation = (prop: string | symbol): prop is 'eraSummaries' | 'systemStart' | 'stakeDistribution' =>
  ['eraSummaries', 'systemStart', 'stakeDistribution'].includes(prop as string);

const recreateOgmiosCardanoNode = async (
  serviceName: string,
  ogmiosCardanoNode: OgmiosCardanoNode,
  dnsResolver: DnsResolver,
  logger: Logger
) => {
  const record = await dnsResolver(serviceName!);
  logger.info(`DNS resolution for Ogmios service, resolved with record: ${JSON.stringify(record)}`);
  await ogmiosCardanoNode
    .shutdown?.()
    .catch((error_) => logger.warn(`Ogmios cardano node failed to shutdown after connection error: ${error_}`));
  return new OgmiosCardanoNode({ host: record.name, port: record.port }, logger);
};

const recreateOgmiosTxSubmitProvider = async (
  serviceName: string,
  ogmiosTxSubmitProvider: OgmiosTxSubmitProvider,
  dnsResolver: DnsResolver,
  logger: Logger,
  handleProvider?: HandleProvider
) => {
  const record = await dnsResolver(serviceName!);
  logger.info(`DNS resolution for OgmiosTxSubmitProvider, resolved with record: ${JSON.stringify(record)}`);
  await ogmiosTxSubmitProvider
    .shutdown()
    .catch((error_) => logger.warn(`OgmiosTxSubmitProvider failed to shutdown after connection error: ${error_}`));
  return new OgmiosTxSubmitProvider({ host: record.name, port: record.port }, { logger }, handleProvider);
};
/**
 * Creates an extended TxSubmitProvider instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with fail-overs (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'initialize' operation and handle connection errors on initialization
 * - intercept 'submitTx' operation and handle connection errors runtime
 * - all other operations are bind to pool object without modifications
 *
 * @returns TxSubmitProvider instance
 */
export const ogmiosTxSubmitProviderWithDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string,
  handleProvider?: HandleProvider
): Promise<OgmiosTxSubmitProvider> => {
  const { name, port } = await dnsResolver(serviceName!);
  let ogmiosProvider = new OgmiosTxSubmitProvider({ host: name, port }, { logger }, handleProvider);

  const txSubmitProviderProxy = new Proxy<OgmiosTxSubmitProvider>({} as OgmiosTxSubmitProvider, {
    get(_, prop, receiver) {
      if (prop === 'then') return;
      if (prop === 'initialize') {
        return () =>
          ogmiosProvider.initialize().catch(async (error) => {
            if (isConnectionError(error)) {
              ogmiosProvider = await recreateOgmiosTxSubmitProvider(
                serviceName,
                ogmiosProvider,
                dnsResolver,
                logger,
                handleProvider
              );
              return receiver.initialize();
            }
            throw error;
          });
      }
      if (prop === 'submitTx') {
        return (submitTxArgs: SubmitTxArgs) =>
          ogmiosProvider.submitTx(submitTxArgs).catch(async (error) => {
            if (isConnectionError(error)) {
              ogmiosProvider = await recreateOgmiosTxSubmitProvider(
                serviceName,
                ogmiosProvider,
                dnsResolver,
                logger,
                handleProvider
              );
              await receiver.initialize();
              await receiver.start();
              return await receiver.submitTx(submitTxArgs);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof ogmiosProvider[prop as keyof OgmiosTxSubmitProvider] === 'function') {
        const method = ogmiosProvider[prop as keyof OgmiosTxSubmitProvider] as any;
        return method.bind(ogmiosProvider);
      }

      return ogmiosProvider[prop as keyof OgmiosTxSubmitProvider];
    }
  });

  return Object.setPrototypeOf(txSubmitProviderProxy, RunnableModule.prototype);
};

export const getOgmiosTxSubmitProvider = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: OgmiosProgramOptions,
  handleProvider?: HandleProvider
): Promise<OgmiosTxSubmitProvider> => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosTxSubmitProviderWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName, handleProvider);
  if (options?.ogmiosUrl)
    return new OgmiosTxSubmitProvider(urlToConnectionConfig(options?.ogmiosUrl), { logger }, handleProvider);
  throw new MissingCardanoNodeOption([OgmiosOptionDescriptions.Url, OgmiosOptionDescriptions.SrvServiceName]);
};

/**
 * Creates an extended OgmiosCardanoNode instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with fail-overs (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'initialize' operation and handle connection errors on initialization
 * - intercept 'eraSummaries', 'systemStart' and 'stakeDistribution' operations and handle connection errors runtime
 * - all other operations are bind to pool object without modifications
 *
 * @returns OgmiosCardanoNode instance
 */
export const ogmiosCardanoNodeWithDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): Promise<OgmiosCardanoNode> => {
  const { name, port } = await dnsResolver(serviceName!);
  let ogmiosCardanoNode = new OgmiosCardanoNode({ host: name, port }, logger);

  const cardanoNodeProxy = new Proxy<OgmiosCardanoNode>({} as OgmiosCardanoNode, {
    get(_, prop, receiver) {
      if (prop === 'then') return;
      if (prop === 'initialize') {
        return () =>
          ogmiosCardanoNode.initialize().catch(async (error) => {
            if (isConnectionError(error)) {
              ogmiosCardanoNode = await recreateOgmiosCardanoNode(serviceName, ogmiosCardanoNode, dnsResolver, logger);
              return await receiver.initialize();
            }
            throw error;
          });
      }
      if (isCardanoNodeOperation(prop)) {
        return () =>
          ogmiosCardanoNode[prop]().catch(async (error) => {
            if (isConnectionError(error)) {
              ogmiosCardanoNode = await recreateOgmiosCardanoNode(serviceName, ogmiosCardanoNode, dnsResolver, logger);
              await receiver.initialize();
              await receiver.start();
              return await receiver[prop]();
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof ogmiosCardanoNode[prop as keyof OgmiosCardanoNode] === 'function') {
        const method = ogmiosCardanoNode[prop as keyof OgmiosCardanoNode] as any;
        return method.bind(ogmiosCardanoNode);
      }

      return ogmiosCardanoNode[prop as keyof OgmiosCardanoNode];
    }
  });

  return Object.setPrototypeOf(cardanoNodeProxy, RunnableModule.prototype);
};

/**
 * Creates an ObservableOgmiosCardanoNode instance :
 * - use passed srv service name in order to resolve the port
 * - all other operations are bind to pool object without modifications
 *
 * @returns ObservableOgmiosCardanoNode instance
 */
export const ogmiosObservableCardanoNodeWithDiscovery = (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): OgmiosObservableCardanoNode =>
  new OgmiosObservableCardanoNode(
    {
      connectionConfig$: defer(() => from(dnsResolver(serviceName).then(({ name, port }) => ({ host: name, port }))))
    },
    { logger }
  );

export const getOgmiosCardanoNode = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: OgmiosProgramOptions
): Promise<OgmiosCardanoNode> => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosCardanoNodeWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl) return new OgmiosCardanoNode(urlToConnectionConfig(options.ogmiosUrl), logger);
  throw new MissingCardanoNodeOption([OgmiosOptionDescriptions.Url, OgmiosOptionDescriptions.SrvServiceName]);
};

export const getOgmiosObservableCardanoNode = (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: OgmiosProgramOptions
): OgmiosObservableCardanoNode => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosObservableCardanoNodeWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl)
    return new OgmiosObservableCardanoNode(
      { connectionConfig$: of(urlToConnectionConfig(options.ogmiosUrl)) },
      { logger }
    );
  throw new MissingCardanoNodeOption([OgmiosOptionDescriptions.Url, OgmiosOptionDescriptions.SrvServiceName]);
};
