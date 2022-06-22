import * as envalid from 'envalid';
import { Factory, FaucetProvider } from '../src/FaucetProvider'
import { LogLevel, createLogger } from 'bunyan';
import { Logger } from 'ts-log';

// Validate environemnt variables

const loggerMethodNames = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'] as (keyof Logger)[];

export const env = envalid.cleanEnv(process.env, {
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  FAUCET_PROVIDER: envalid.str(),
  FAUCET_PROVIDER_PARAMS: envalid.json()
});

// Instantiate providers

// Logger
export const logger = createLogger({
  level: env.LOGGER_MIN_SEVERITY as LogLevel,
  name: 'e2e tests'
});

// Faucet
export const faucetProvider = Factory<FaucetProvider>.get().create(env.FAUCET_PROVIDER, env.FAUCET_PROVIDER_PARAMS) as FaucetProvider;