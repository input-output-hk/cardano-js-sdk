import { consumeRemoteApi } from '../messaging/index.js';
import { keyAgentChannel, keyAgentProperties } from './util.js';
import type { MessengerDependencies } from '../messaging/index.js';

export interface ConsumeKeyAgentProps {
  walletName: string;
}

export const consumeKeyAgent = ({ walletName }: ConsumeKeyAgentProps, dependencies: MessengerDependencies) =>
  consumeRemoteApi(
    {
      baseChannel: keyAgentChannel(walletName),
      properties: keyAgentProperties
    },
    dependencies
  );
