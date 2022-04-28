/* eslint-disable sonarjs/cognitive-complexity */
import { DbSyncStakePoolSearchProvider, StakePoolSearchHttpService } from '../StakePoolSearch';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import { HttpServer, HttpServerConfig, HttpService } from '../Http';
import { LogLevel, createLogger } from 'bunyan';
import { MissingProgramOption, UnknownServiceName } from './errors';
import { Pool } from 'pg';
import { ProgramOptionDescriptions } from './ProgramOptionDescriptions';
import { RabbitMqTxSubmitProvider } from '@cardano-sdk/rabbitmq';
import { ServiceNames } from './ServiceNames';
import { TxSubmitHttpService } from '../TxSubmit';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';

export interface ProgramArgs {
  apiUrl: URL;
  serviceNames: (ServiceNames.StakePoolSearch | ServiceNames.TxSubmit | ServiceNames.Utxo)[];
  options?: {
    dbConnectionString?: string;
    loggerMinSeverity?: LogLevel;
    metricsEnabled?: boolean;
    ogmiosUrl?: URL;
    rabbitmqUrl?: URL;
    useQueue?: boolean;
  };
}

export const loadHttpServer = async (args: ProgramArgs): Promise<HttpServer> => {
  const services: HttpService[] = [];
  const logger = createLogger({
    level: args.options?.loggerMinSeverity,
    name: 'http-server'
  });

  for (const serviceName of args.serviceNames) {
    switch (serviceName) {
      case ServiceNames.StakePoolSearch:
        if (args.options?.dbConnectionString === undefined)
          throw new MissingProgramOption(ServiceNames.StakePoolSearch, ProgramOptionDescriptions.DbConnection);
        services.push(
          StakePoolSearchHttpService.create({
            logger,
            stakePoolSearchProvider: new DbSyncStakePoolSearchProvider(
              new Pool({ connectionString: args.options.dbConnectionString }),
              logger
            )
          })
        );
        break;
      case ServiceNames.TxSubmit:
        services.push(
          await TxSubmitHttpService.create({
            logger,
            txSubmitProvider:
              args.options?.useQueue && args.options?.rabbitmqUrl
                ? new RabbitMqTxSubmitProvider(args.options.rabbitmqUrl)
                : ogmiosTxSubmitProvider({
                    host: args.options?.ogmiosUrl?.hostname,
                    port: args.options?.ogmiosUrl ? Number.parseInt(args.options.ogmiosUrl.port) : undefined,
                    tls: args.options?.ogmiosUrl?.protocol === 'wss'
                  })
          })
        );
        break;
      case ServiceNames.Utxo:
        if (args.options?.dbConnectionString === undefined)
          throw new MissingProgramOption(ServiceNames.Utxo, ProgramOptionDescriptions.DbConnection);
        services.push(
          await UtxoHttpService.create({
            logger,
            utxoProvider: new DbSyncUtxoProvider(
              new Pool({ connectionString: args.options.dbConnectionString }),
              logger
            )
          })
        );
        break;
      default:
        throw new UnknownServiceName(serviceName);
    }
  }
  const config: HttpServerConfig = {
    listen: {
      host: args.apiUrl.hostname,
      port: Number.parseInt(args.apiUrl.port)
    }
  };
  if (args.options?.metricsEnabled) {
    config.metrics = { enabled: args.options?.metricsEnabled };
  }
  return new HttpServer(config, { logger, services });
};
