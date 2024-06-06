import { exposeApi } from '../messaging/index.js';
import { keyAgentChannel, keyAgentProperties } from './util.js';
import { of } from 'rxjs';
import type { AsyncKeyAgent } from '@cardano-sdk/key-management';
import type { MessengerDependencies } from '../messaging/index.js';

export interface ExposeKeyAgentProps {
  keyAgent: AsyncKeyAgent;
  walletName: string;
}

export const exposeKeyAgent = ({ keyAgent, walletName }: ExposeKeyAgentProps, dependencies: MessengerDependencies) =>
  exposeApi(
    {
      api$: of(keyAgent),
      baseChannel: keyAgentChannel(walletName),
      properties: keyAgentProperties
    },
    dependencies
  );
