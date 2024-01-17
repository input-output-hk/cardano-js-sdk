import { MessengerDependencies, consumeRemoteApi } from '../../messaging';
import { signingCoordinatorApiChannel, signingCoordinatorApiProperties } from './util';

export const consumeSigningCoordinatorApi = (dependencies: MessengerDependencies) =>
  consumeRemoteApi(
    {
      baseChannel: signingCoordinatorApiChannel,
      properties: signingCoordinatorApiProperties
    },
    dependencies
  );
