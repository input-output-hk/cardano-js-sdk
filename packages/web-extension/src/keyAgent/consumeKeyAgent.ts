import '@cardano-sdk/util';
import '@cardano-sdk/wallet/dist/cjs/KeyManagement';
import 'rxjs';
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
