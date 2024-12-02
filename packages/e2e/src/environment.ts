import { Cardano } from '@cardano-sdk/core';
import { Schema, Validator as SchemaValidator } from 'jsonschema';
import { ValidatorSpec, bool, cleanEnv, makeValidator, num, str } from 'envalid';

export interface KeyManagementParams {
  accountIndex: number;
  mnemonic: string;
  chainId: Cardano.ChainId;
  passphrase: string;
  bip32Ed25519: string;
}

export interface ProviderParams {
  baseUrl: string;
}

export interface HandleProviderParams {
  serverUrl: string;
}

const baseValidator = <T>(value: string, schema: Schema, ...dependencySchemas: Schema[]) => {
  const parsed = JSON.parse(value) as T;
  const v = new SchemaValidator();
  for (const dependencySchema of dependencySchemas) {
    v.addSchema(dependencySchema);
  }
  const res = v.validate(parsed, schema, { required: true });

  if (!res.valid) throw new Error(res.errors[0].stack.replace(/^instance\./, ''));

  return parsed;
};

const keyManagementParams = makeValidator((value) =>
  baseValidator<KeyManagementParams>(
    value,
    {
      properties: {
        accountIndex: { minimum: 0, type: 'integer' },
        bip32Ed25519: { type: 'string' },
        chainId: { $ref: '/ChainId' },
        mnemonic: { type: 'string' },
        passphrase: { type: 'string' }
      },
      required: ['accountIndex', 'mnemonic', 'chainId', 'passphrase', 'bip32Ed25519'],
      type: 'object'
    },
    {
      id: '/ChainId',
      properties: {
        networkId: { minimum: 0, type: 'integer' },
        networkMagic: { minimum: 0, type: 'integer' }
      },
      required: ['networkId', 'networkMagic'],
      type: 'object'
    }
  )
);

const providerParams = makeValidator((value) => {
  const validated = baseValidator<ProviderParams>(value, {
    properties: { baseUrl: { type: 'string' } },
    required: ['baseUrl'],
    type: 'object'
  });

  try {
    // eslint-disable-next-line no-new
    new URL(validated.baseUrl);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    throw new Error(`baseUrl: ${error.message}`);
  }

  return validated;
});

/** Shared across all tests */
const validators = {
  ADDRESS_DISCOVERY: str({ default: 'HDSequentialDiscovery' }),
  ARRIVAL_PHASE_DURATION_IN_SECS: num(),
  DB_SYNC_CONNECTION_STRING: str({ default: undefined }),
  KEY_MANAGEMENT_PARAMS: keyManagementParams(),
  KEY_MANAGEMENT_PROVIDER: str(),
  LOGGER_MIN_SEVERITY: str({ default: 'info' }),
  NETWORK_SPEED: str({ choices: ['fast', 'slow'], default: 'fast' }),
  OGMIOS_URL: str(),
  STAKE_POOL_CONNECTION_STRING: str(),
  STAKE_POOL_TEST_CONNECTION_STRING: str(),
  START_LOCAL_HTTP_SERVER: bool(),
  TEST_CLIENT_ASSET_PROVIDER: str(),
  TEST_CLIENT_ASSET_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_CHAIN_HISTORY_PROVIDER: str(),
  TEST_CLIENT_CHAIN_HISTORY_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_DREP_PROVIDER: str({ choices: ['blockfrost'] }),
  TEST_CLIENT_DREP_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_HANDLE_PROVIDER: str(),
  TEST_CLIENT_HANDLE_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_NETWORK_INFO_PROVIDER: str(),
  TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_REWARDS_PROVIDER: str(),
  TEST_CLIENT_REWARDS_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_STAKE_POOL_PROVIDER: str(),
  TEST_CLIENT_STAKE_POOL_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_TX_SUBMIT_PROVIDER: str(),
  TEST_CLIENT_TX_SUBMIT_PROVIDER_PARAMS: providerParams(),
  TEST_CLIENT_UTXO_PROVIDER: str(),
  TEST_CLIENT_UTXO_PROVIDER_PARAMS: providerParams(),
  TRANSACTIONS_NUMBER: num(),
  TX_SUBMIT_HTTP_URL: str(),
  VIRTUAL_USERS_COUNT: num(),
  VIRTUAL_USERS_GENERATE_DURATION: num(),
  WALLET_SYNC_TIMEOUT_IN_MS: num({ default: undefined }),
  WORKER_PARALLEL_TRANSACTION: num(),
  WS_PROVIDER_URL: str()
} as const;

type Entries<T> = { [K in keyof T]: [K, T[K]] }[keyof T][];
type Validators = typeof validators;
type Validator = keyof Validators;

/**
 * Reads the environment variables from `process.env` and performs the checks against
 * the shared constraints to ensure the required configuration is provided through
 * the environment variables.
 *
 * @param variables Array of the names of the required variables
 * @param options Options to customize the behavior
 * @param options.default Object of default values
 * @param options.override Object of override values
 * @returns A `NodeJS.ProcessEnv` like object which respects the shared constraints
 */
export const getEnv = <V extends readonly Validator[]>(
  variables: V,
  options: { default?: NodeJS.ProcessEnv; override?: NodeJS.ProcessEnv } = {}
) =>
  cleanEnv(
    { ...options.default, ...process.env, ...options.override },
    Object.fromEntries((Object.entries(validators) as Entries<Validators>).filter(([name]) => variables.includes(name)))
  ) as unknown as {
    [v in V[number]]: Validators[v] extends ValidatorSpec<infer T> ? T : never;
  };

/** Collection of all the configuration variables required by `getWallet` */
export const walletVariables = [
  'TEST_CLIENT_ASSET_PROVIDER',
  'TEST_CLIENT_ASSET_PROVIDER_PARAMS',
  'TEST_CLIENT_CHAIN_HISTORY_PROVIDER',
  'TEST_CLIENT_CHAIN_HISTORY_PROVIDER_PARAMS',
  'TEST_CLIENT_DREP_PROVIDER',
  'TEST_CLIENT_DREP_PROVIDER_PARAMS',
  'TEST_CLIENT_HANDLE_PROVIDER',
  'TEST_CLIENT_HANDLE_PROVIDER_PARAMS',
  'KEY_MANAGEMENT_PARAMS',
  'KEY_MANAGEMENT_PROVIDER',
  'LOGGER_MIN_SEVERITY',
  'TEST_CLIENT_NETWORK_INFO_PROVIDER',
  'TEST_CLIENT_NETWORK_INFO_PROVIDER_PARAMS',
  'TEST_CLIENT_REWARDS_PROVIDER',
  'TEST_CLIENT_REWARDS_PROVIDER_PARAMS',
  'TEST_CLIENT_STAKE_POOL_PROVIDER',
  'TEST_CLIENT_STAKE_POOL_PROVIDER_PARAMS',
  'TEST_CLIENT_TX_SUBMIT_PROVIDER',
  'TEST_CLIENT_TX_SUBMIT_PROVIDER_PARAMS',
  'TEST_CLIENT_UTXO_PROVIDER',
  'TEST_CLIENT_UTXO_PROVIDER_PARAMS',
  'WS_PROVIDER_URL',
  'ADDRESS_DISCOVERY',
  'NETWORK_SPEED'
] as const;
