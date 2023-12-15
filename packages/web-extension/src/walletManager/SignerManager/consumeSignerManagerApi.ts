import { MessengerDependencies, consumeRemoteApi } from '../../messaging';
import { signerManagerApiChannel, signerManagerApiProperties } from './util';

export const consumeSignerManagerApi = (dependencies: MessengerDependencies) =>
  consumeRemoteApi(
    {
      baseChannel: signerManagerApiChannel,
      properties: signerManagerApiProperties
    },
    dependencies
  );
