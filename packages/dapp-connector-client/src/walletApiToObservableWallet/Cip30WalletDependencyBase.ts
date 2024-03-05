import type { Cip30WalletApi } from '@cardano-sdk/dapp-connector';
import type { Logger } from 'ts-log';
import type { WithLogger } from '@cardano-sdk/util';

export type Cip30WalletDependencyProps = {
  api: Cip30WalletApi;
};

export class Cip30WalletDependencyBase {
  protected readonly api: Cip30WalletApi;
  protected readonly logger: Logger;

  constructor({ api }: Cip30WalletDependencyProps, { logger }: WithLogger) {
    this.api = api;
    this.logger = logger;
  }
}
