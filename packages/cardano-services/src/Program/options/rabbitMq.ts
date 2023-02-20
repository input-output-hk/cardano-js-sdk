import { Command, Option } from 'commander';
import { RABBITMQ_URL_DEFAULT } from '../defaults';
import { URL } from 'url';

export enum RabbitMqOptionDescriptions {
  SrvServiceName = 'RabbitMQ SRV service name',
  Url = 'RabbitMQ URL'
}

export interface RabbitMqProgramOptions {
  rabbitmqUrl?: URL;
  rabbitmqSrvServiceName?: string;
}

export const withRabbitMqOptions = (command: Command) =>
  command
    .addOption(
      new Option('--rabbitmq-srv-service-name <rabbitmqSrvServiceName>', RabbitMqOptionDescriptions.SrvServiceName).env(
        'RABBITMQ_SRV_SERVICE_NAME'
      )
    )
    .addOption(
      new Option('--rabbitmq-url <rabbitmqUrl>', RabbitMqOptionDescriptions.Url)
        .env('RABBITMQ_URL')
        .default(new URL(RABBITMQ_URL_DEFAULT))
        .conflicts('rabbitmqSrvServiceName')
        .argParser((url) => new URL(url))
    );
