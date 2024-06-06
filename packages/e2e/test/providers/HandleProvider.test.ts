import { createLogger } from '@cardano-sdk/util-dev';
import { getEnv, walletVariables } from '../../src/index.js';
import { handleHttpProvider } from '@cardano-sdk/cardano-services-client';
import fs from 'fs';
import path from 'path';

const logger = createLogger();
const env = getEnv(walletVariables);

describe('HandleProvider', () => {
  it('resolves handle', async () => {
    const policyPath = path.join(__dirname, '../../local-network/sdk-ipc/handle_policy_ids');
    const policyId = fs.readFileSync(policyPath, 'utf8').toString().trim();
    const handleName = 'hellohandle'; // handle minted in mint-handles.sh
    const handleName2 = 'testhandle';
    const config = { baseUrl: env.HANDLE_PROVIDER_PARAMS.baseUrl, logger };
    const handleProvider = handleHttpProvider(config);
    const handle = await handleProvider.resolveHandles({ handles: [handleName, handleName2] });
    expect(handle.length).toEqual(2);
    expect(handle[0]?.handle).toEqual('hellohandle');
    expect(handle[0]?.hasDatum).toEqual(false);
    expect(handle[0]?.policyId).toEqual(policyId);
    expect(handle[0]?.resolvedAt).toBeDefined();
  });

  it('resolves non existent handle with null', async () => {
    const config = { baseUrl: env.HANDLE_PROVIDER_PARAMS.baseUrl, logger };
    const handleProvider = handleHttpProvider(config);
    const handle = await handleProvider.resolveHandles({ handles: ['nonexistent'] });
    expect(handle).toEqual([null]);
  });

  it('allows request an empty list of handles', async () => {
    const config = { baseUrl: env.HANDLE_PROVIDER_PARAMS.baseUrl, logger };
    const handleProvider = handleHttpProvider(config);
    const handle = await handleProvider.resolveHandles({ handles: [] });
    expect(handle.length).toEqual(0);
  });
});
