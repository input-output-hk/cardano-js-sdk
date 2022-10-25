import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { MessengerDependencies, exposeApi } from '../messaging';
import { keyAgentChannel, keyAgentProperties } from './util';
import { of } from 'rxjs';

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
