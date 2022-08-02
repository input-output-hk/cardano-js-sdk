/* eslint-disable max-len */
/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { CommonOptionDescriptions, CommonProgramOptions } from '../../ProgramsCommon';
import { DnsResolver, srvRecordToRabbitmqURL } from '../utils';
import { Logger } from 'ts-log';
import { MissingProgramOption } from '../errors';
import { ProviderFailure } from '@cardano-sdk/core';
import { RabbitMqTxSubmitProvider } from '@cardano-sdk/rabbitmq';
import { ServiceNames } from '../ServiceNames';
import { isConnectionError } from '@cardano-sdk/util';

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
  let rabbitmqProvider = new RabbitMqTxSubmitProvider({
    rabbitmqUrl: srvRecordToRabbitmqURL(record)
  });

  return new Proxy<RabbitMqTxSubmitProvider>({} as RabbitMqTxSubmitProvider, {
    get(_, prop) {
      if (prop === 'then') return;
      if (prop === 'submitTx') {
        return (args: Uint8Array) =>
          rabbitmqProvider.submitTx(args).catch(async (error) => {
            if (
              error.innerError?.reason === ProviderFailure.ConnectionFailure ||
              isConnectionError(error.innerError.innerError)
            ) {
              const resolvedRecord = await dnsResolver(serviceName!);
              logger.info(`DNS resolution for RabbitMQ service, resolved with record: ${JSON.stringify(record)}`);
              await rabbitmqProvider
                .close?.()
                .catch((error_) => logger.warn(`RabbitMQ provider failed to close after DNS resolution: ${error_}`));
              rabbitmqProvider = new RabbitMqTxSubmitProvider({
                rabbitmqUrl: srvRecordToRabbitmqURL(resolvedRecord)
              });
              return await rabbitmqProvider.submitTx(args);
            }
            throw error;
          });
      }
      // Bind if it is a function, no intercept operations
      if (typeof rabbitmqProvider[prop as keyof RabbitMqTxSubmitProvider] === 'function') {
        const method = rabbitmqProvider[prop as keyof RabbitMqTxSubmitProvider] as any;
        return method.bind(rabbitmqProvider);
      }
    }
  });
};

export const getRabbitMqTxSubmitProvider = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: CommonProgramOptions
): Promise<RabbitMqTxSubmitProvider> => {
  if (options?.rabbitmqSrvServiceName)
    return rabbitMqTxSubmitProviderWithDiscovery(dnsResolver, logger, options.rabbitmqSrvServiceName);
  if (options?.rabbitmqUrl) return new RabbitMqTxSubmitProvider({ rabbitmqUrl: options.rabbitmqUrl });
  throw new MissingProgramOption(ServiceNames.TxSubmit, [
    CommonOptionDescriptions.RabbitMQUrl,
    CommonOptionDescriptions.RabbitMQSrvServiceName
  ]);
};
