import { MessengerDependencies, consumeRemoteApi } from '../messaging';
import { keyAgentChannel, keyAgentProperties } from './util';

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
