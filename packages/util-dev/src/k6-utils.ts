/* eslint-disable sonarjs/cognitive-complexity */
export enum Environment {
  dev = 'dev',
  ops = 'ops',
  staging = 'staging',
  live = 'live'
}

export enum Network {
  mainnet = 'mainnet',
  preprod = 'preprod',
  preview = 'preview',
  sanchonet = 'sanchonet'
}

/**
 * Gets the target URL domain under test (dut) based on `TARGET_ENV`, `TARGET_NET` or `DUT` environment variables.
 *
 * @param options default `undefined`: use default value for each option.<br />
 * - `environments`: the array of allowed environments - default: `['dev', 'ops', 'staging', 'prod']`.
 * - `networks`: the array of allowed networks - default: `['mainnet', 'preprod', 'preview', 'sanchonet']`.
 * @returns the domain under test (dut) based on the environment variables, (e.g. `live-preprod.lw.iog.io`)
 * @throws if none of `TARGET_ENV` and `TARGET_NET`, or `DUT` are configured, or if the options are invalid.
 */
// eslint-disable-next-line complexity, sonarjs/cognitive-complexity
export const getDut = (
  k6Env: { TARGET_ENV?: string; TARGET_NET?: string; DUT?: string },
  options?: { environments?: Environment[]; networks?: Network[] }
) => {
  const allowedEnvironments = new Set<Environment>([
    Environment.dev,
    Environment.ops,
    Environment.staging,
    Environment.live
  ]);
  const allowedNetworks = new Set<Network>([Network.mainnet, Network.preprod, Network.preview, Network.sanchonet]);
  const allowedOptions = new Set(['environments', 'networks']);

  const { TARGET_ENV, TARGET_NET, DUT } = k6Env;

  if (!(TARGET_ENV && TARGET_NET) && !DUT)
    throw new Error('Please specify both TARGET_ENV and TARGET_NET or DUT (Domain Under Test');

  let urlEnvironments = [...allowedEnvironments];
  let urlNetworks = [...allowedNetworks];

  if (options) {
    if (typeof options !== 'object') throw new Error(`${typeof options}: not allowed type for options`);

    for (const option of Object.keys(options))
      if (!allowedOptions.has(option)) throw new Error(`${options}: not allowed option`);

    const { environments, networks } = options;

    switch (typeof environments) {
      case 'undefined':
        break;

      case 'object':
        if (!Array.isArray(environments)) throw new Error('options.environments must be an array');

        for (const environment of environments)
          if (!allowedEnvironments.has(environment)) throw new Error(`${environment}: not allowed environment`);

        urlEnvironments = environments;

        break;

      default:
        throw new Error(`${typeof environments}: not allowed type for options.environments`);
    }

    switch (typeof networks) {
      case 'undefined':
        break;

      case 'object':
        if (!Array.isArray(networks)) throw new Error('options.networks must be an array');

        for (const network of networks)
          if (!allowedNetworks.has(network)) throw new Error(`${network}: not allowed network`);

        urlNetworks = networks;

        break;

      default:
        throw new Error(`${typeof networks}: not allowed type for options.networks`);
    }
  }

  if (TARGET_ENV && !urlEnvironments.includes(TARGET_ENV as Environment))
    throw new Error(`${TARGET_ENV}: not allowed environment`);
  if (TARGET_NET && !urlNetworks.includes(TARGET_NET as Network)) throw new Error(`${TARGET_NET}: not allowed network`);

  return DUT || `${TARGET_ENV}-${TARGET_NET}${TARGET_ENV === 'ops' ? '-1' : ''}.lw.iog.io`;
};
