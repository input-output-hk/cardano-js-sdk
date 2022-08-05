/* eslint-disable max-len */
/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { CommonOptionDescriptions, CommonProgramOptions } from '../../ProgramsCommon';
import { DnsResolver } from '../utils';
import { Logger } from 'ts-log';
import { MissingProgramOption } from '../errors';
import { OgmiosCardanoNode, ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import { ServiceNames } from '../ServiceNames';
import { TxSubmitProvider } from '@cardano-sdk/core';
import { isConnectionError } from '@cardano-sdk/util';

const isCardanoNodeOperation = (prop: string | symbol): prop is 'eraSummaries' | 'systemStart' =>
  ['eraSummaries', 'systemStart'].includes(prop as string);

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

/**
 * Creates an extended TxSubmitProvider instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with fail-overs (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'submitTx' operation and handle connection errors runtime
 * - all other operations are bind to pool object without modifications
 *
 * @returns TxSubmitProvider instance
 */
export const ogmiosTxSubmitProviderWithDiscovery = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): Promise<TxSubmitProvider> => {
  const { name, port } = await dnsResolver(serviceName!);
  let ogmiosProvider = ogmiosTxSubmitProvider({ host: name, port });

  return new Proxy<TxSubmitProvider>({} as TxSubmitProvider, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'submitTx') {
        return (args: Uint8Array) =>
          ogmiosProvider.submitTx(args).catch(async (error) => {
            if (error.innerError && isConnectionError(error.innerError)) {
              const record = await dnsResolver(serviceName!);
              logger.info(`DNS resolution for Ogmios service, resolved with record: ${JSON.stringify(record)}`);
              await ogmiosProvider
                .close?.()
                .catch((error_) =>
                  logger.warn(`Ogmios tx submit provider failed to close after DNS resolution: ${error_}`)
                );
              ogmiosProvider = ogmiosTxSubmitProvider({ host: record.name, port: record.port });
              return await ogmiosProvider.submitTx(args);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof ogmiosProvider[prop as keyof TxSubmitProvider] === 'function') {
        const method = ogmiosProvider[prop as keyof TxSubmitProvider] as any;
        return method.bind(ogmiosProvider);
      }
    }
  });
};

export const getOgmiosTxSubmitProvider = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: CommonProgramOptions
): Promise<TxSubmitProvider> => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosTxSubmitProviderWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl) return ogmiosTxSubmitProvider(urlToConnectionConfig(options?.ogmiosUrl));
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    CommonOptionDescriptions.OgmiosUrl,
    CommonOptionDescriptions.OgmiosSrvServiceName
  ]);
};

/**
 * Creates an extended OgmiosCardanoNode instance :
 * - use passed srv service name in order to resolve the port
 * - make dealing with fail-overs (re-resolving the port) opaque
 * - use exponential backoff retry internally with default timeout and factor
 * - intercept 'initialize' operation and handle connection errors on initialization
 * - intercept 'eraSummaries' operation and handle connection errors runtime
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

  return new Proxy<OgmiosCardanoNode>({} as OgmiosCardanoNode, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'initialize') {
        return () =>
          ogmiosCardanoNode.initialize().catch(async (error) => {
            if (isConnectionError(error)) {
              ogmiosCardanoNode = await recreateOgmiosCardanoNode(serviceName, ogmiosCardanoNode, dnsResolver, logger);
              return await ogmiosCardanoNode.initialize();
            }
            throw error;
          });
      }
      if (isCardanoNodeOperation(prop)) {
        return () =>
          ogmiosCardanoNode[prop]().catch(async (error) => {
            if (isConnectionError(error)) {
              ogmiosCardanoNode = await recreateOgmiosCardanoNode(serviceName, ogmiosCardanoNode, dnsResolver, logger);
              await ogmiosCardanoNode.initialize();
              return await ogmiosCardanoNode[prop]();
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof ogmiosCardanoNode[prop as keyof OgmiosCardanoNode] === 'function') {
        const method = ogmiosCardanoNode[prop as keyof OgmiosCardanoNode] as any;
        return method.bind(ogmiosCardanoNode);
      }
    }
  });
};

export const getOgmiosCardanoNode = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: CommonProgramOptions
): Promise<OgmiosCardanoNode> => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosCardanoNodeWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl) return new OgmiosCardanoNode(urlToConnectionConfig(options.ogmiosUrl), logger);
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    CommonOptionDescriptions.OgmiosUrl,
    CommonOptionDescriptions.OgmiosSrvServiceName
  ]);
};
