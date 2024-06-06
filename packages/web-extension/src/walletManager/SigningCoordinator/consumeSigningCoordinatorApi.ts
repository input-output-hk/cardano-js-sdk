import { consumeRemoteApi } from '../../messaging/index.js';
import { signingCoordinatorApiChannel, signingCoordinatorApiProperties } from './util.js';
import type { MessengerDependencies } from '../../messaging/index.js';

export const consumeSigningCoordinatorApi = (dependencies: MessengerDependencies) =>
  consumeRemoteApi(
    {
      baseChannel: signingCoordinatorApiChannel,
      properties: signingCoordinatorApiProperties
    },
    dependencies
  );
