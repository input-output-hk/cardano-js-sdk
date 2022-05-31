/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { ChainHistoryHttpService, DbSyncChainHistoryProvider } from '../ChainHistory';
import { CommonProgramOptions } from '../ProgramsCommon';
import { DbSyncStakePoolProvider, StakePoolHttpService } from '../StakePool';
import { DbSyncUtxoProvider, UtxoHttpService } from '../Utxo';
import { HttpServer, HttpServerConfig, HttpService } from '../Http';
import { MissingProgramOption, UnknownServiceName } from './errors';
import { Pool } from 'pg';
import { ProgramOptionDescriptions } from './ProgramOptionDescriptions';
import { RabbitMqTxSubmitProvider } from '@cardano-sdk/rabbitmq';
import { ServiceNames } from './ServiceNames';
import { TxSubmitHttpService } from '../TxSubmit';
import { createLogger } from 'bunyan';
import { ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';

export interface HttpServerOptions extends CommonProgramOptions {
  dbConnectionString?: string;
  metricsEnabled?: boolean;
  useQueue?: boolean;
}

export interface ProgramArgs {
  apiUrl: URL;
  serviceNames: (ServiceNames.StakePool | ServiceNames.TxSubmit | ServiceNames.ChainHistory | ServiceNames.Utxo)[];
  options?: HttpServerOptions;
}

export const loadHttpServer = async (args: ProgramArgs): Promise<HttpServer> => {
  const services: HttpService[] = [];
  const logger = createLogger({
    level: args.options?.loggerMinSeverity,
    name: 'http-server'
  });

  const db = args.options?.dbConnectionString
    ? new Pool({ connectionString: args.options.dbConnectionString })
    : undefined;

  for (const serviceName of args.serviceNames) {
    switch (serviceName) {
      case ServiceNames.StakePool:
        if (!db) throw new MissingProgramOption(ServiceNames.StakePool, ProgramOptionDescriptions.DbConnection);
        services.push(
          StakePoolHttpService.create({
            logger,
            stakePoolProvider: new DbSyncStakePoolProvider(db, logger)
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
                : ogmiosTxSubmitProvider(urlToConnectionConfig(args.options?.ogmiosUrl))
          })
        );
        break;
      case ServiceNames.ChainHistory:
        if (!db) throw new MissingProgramOption(ServiceNames.ChainHistory, ProgramOptionDescriptions.DbConnection);
        services.push(
          await ChainHistoryHttpService.create({
            chainHistoryProvider: new DbSyncChainHistoryProvider(db, logger),
            logger
          })
        );
        break;
      case ServiceNames.Utxo:
        if (!db) throw new MissingProgramOption(ServiceNames.Utxo, ProgramOptionDescriptions.DbConnection);
        services.push(
          await UtxoHttpService.create({
            logger,
            utxoProvider: new DbSyncUtxoProvider(db, logger)
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
