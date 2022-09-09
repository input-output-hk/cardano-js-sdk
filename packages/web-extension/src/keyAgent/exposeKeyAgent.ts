import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { MessengerDependencies, exposeApi } from '../messaging';
import { keyAgentChannel, keyAgentProperties } from './util';

export interface ExposeKeyAgentProps {
  keyAgent: AsyncKeyAgent;
  walletName: string;
}

export const exposeKeyAgent = ({ keyAgent, walletName }: ExposeKeyAgentProps, dependencies: MessengerDependencies) =>
  exposeApi(
    {
      api: keyAgent,
      baseChannel: keyAgentChannel(walletName),
      properties: keyAgentProperties
    },
    dependencies
  );
