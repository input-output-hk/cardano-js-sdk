/* eslint-disable import/no-extraneous-dependencies */
const { env, pathToE2ePackage } = require('./e2e-env');
const {
  coinsRequiredByHandleMint,
  createStandaloneKeyAgent,
  getHandlePolicyId,
  getWallet,
  mintCIP25andCIP68Handles,
  walletReady
} = require('@cardano-sdk/e2e');
const { firstValueFrom } = require('rxjs');
const { logger } = require('@cardano-sdk/util-dev');
const path = require('path');
const { SodiumBip32Ed25519 } = require('@cardano-sdk/crypto');

(async () => {
  const { wallet, asyncKeyAgent } = await getWallet({
    env,
    idx: 0,
    logger,
    name: 'Handle Init Wallet',
    polling: { interval: 50 }
  });
  logger.info('Waiting for walletReady');
  await walletReady(wallet, coinsRequiredByHandleMint + 10_000_000n);

  const keyAgent = await createStandaloneKeyAgent(
    env.KEY_MANAGEMENT_PARAMS.mnemonic.split(' '),
    await firstValueFrom(wallet.genesisParameters$),
    new SodiumBip32Ed25519()
  );

  const policyId = await getHandlePolicyId(path.join(pathToE2ePackage, 'local-network', 'sdk-ipc'));
  await mintCIP25andCIP68Handles(wallet, keyAgent, policyId);

  wallet.shutdown();
  logger.info('Minted CIP25 and CIP68 handles');
})();
