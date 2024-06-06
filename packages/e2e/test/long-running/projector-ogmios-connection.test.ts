import * as envalid from 'envalid';
import { DockerUtil } from '@cardano-sdk/util-dev';
import { open, rm } from 'fs/promises';
import Dockerode from 'dockerode';
import axios from 'axios';
import delay from 'delay';
import path from 'path';
import type { AxiosResponse } from 'axios';

const preventOgmiosStartFile = path.join(__dirname, '..', '..', 'local-network', 'sdk-ipc', 'prevent_ogmios');

const docker = new Dockerode();

const ogmiosContainer = docker.getContainer('local-network-e2e-ogmios-1');
const stakePoolProjectorContainer = docker.getContainer('local-network-e2e-stake-pool-projector-1');

const createPrevent = async () => {
  const file = await open(preventOgmiosStartFile, 'a');

  await file.close();
};

const removePrevent = () => rm(preventOgmiosStartFile, { force: true });

const killContainer = async (container: DockerUtil.Docker.Container) => {
  // This waits only for the signal to be sent
  await DockerUtil.containerExec(container, ['kill', '1']);
  // Let's wait one more second to ensure the container was shut down
  await delay(1000);
};

describe('projector ogmios connection', () => {
  let stakePoolProjectorUrl: string;

  const fetchProjectorHealth = async () => {
    let result: AxiosResponse;

    try {
      result = await axios.post(stakePoolProjectorUrl, {});
    } catch (error) {
      if (axios.isAxiosError(error)) throw new Error(error.message);

      throw error;
    }

    return result;
  };

  const checkProjector = async () => {
    const health = await fetchProjectorHealth();

    if (!health.data.ok) throw new Error('Projector not healthy');

    const { blockNo } = health.data.services[0].projectedTip;
    const start = Date.now();

    // Wait for another block to be projected to ensure projector is working correctly
    while ((await fetchProjectorHealth()).data.services[0].projectedTip.blockNo === blockNo) {
      if (Date.now() - start > 60_000) throw new Error('The projector is not projecting new blocks');

      await delay(100);
    }
  };

  const waitProjector = async (skipOkCheck = false, tolerateConnectionErrors = false) => {
    const start = Date.now();
    let projectorReady = false;

    do {
      try {
        const health = await fetchProjectorHealth();

        if ('ok' in health.data && (skipOkCheck || health.data.ok)) projectorReady = true;
      } catch (error) {
        if (error && !tolerateConnectionErrors) throw error;
      }

      if (Date.now() - start > 60_000) throw new Error("The projector can't get ready");
      await delay(1000);
    } while (projectorReady === false);
  };

  beforeAll(() => {
    const env = envalid.cleanEnv(process.env, { STAKE_POOL_PROJECTOR_URL: envalid.url() });

    stakePoolProjectorUrl = `${env.STAKE_POOL_PROJECTOR_URL}v1.0.0/health`;
  });

  beforeEach(async () => {
    await removePrevent();
    await checkProjector();
  });

  afterEach(() => removePrevent());

  it('projector reconnects after a short delay', async () => {
    await killContainer(ogmiosContainer);
    await waitProjector();
    await checkProjector();
  });

  it('projector reconnects after a long delay', async () => {
    await createPrevent();
    await killContainer(ogmiosContainer);
    await delay(120_000);
    await removePrevent();
    await waitProjector();
    await checkProjector();
  });

  it('projector connects to a later started ogmios', async () => {
    await createPrevent();
    await killContainer(ogmiosContainer);
    await killContainer(stakePoolProjectorContainer);
    await waitProjector(true, true);
    await removePrevent();
    await waitProjector();
    await checkProjector();
  });
});
