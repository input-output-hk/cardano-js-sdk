import { Command } from 'commander';
import { addOptions, newOption } from './util';

const RABBITMQ_URL_DEFAULT = 'amqp://localhost:5672';

export enum RabbitMqOptionDescriptions {
  SrvServiceName = 'RabbitMQ SRV service name',
  Url = 'RabbitMQ URL'
}

export interface RabbitMqProgramOptions {
  rabbitmqUrl?: URL;
  rabbitmqSrvServiceName?: string;
}

export const withRabbitMqOptions = (command: Command) =>
  addOptions(command, [
    newOption(
      '--rabbitmq-srv-service-name <rabbitmqSrvServiceName>',
      RabbitMqOptionDescriptions.SrvServiceName,
      'RABBITMQ_SRV_SERVICE_NAME'
    ),
    newOption(
      '--rabbitmq-url <rabbitmqUrl>',
      RabbitMqOptionDescriptions.Url,
      'RABBITMQ_URL',
      (url) => new URL(url),
      new URL(RABBITMQ_URL_DEFAULT)
    ).conflicts('rabbitmqSrvServiceName')
  ]);
