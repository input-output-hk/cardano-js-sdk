import { Cardano } from '@cardano-sdk/core';

/**
 * Maps of payment credentials and reward accounts (stake addresses) grouped by their addresses.
 *
 * Note: We use RewardAccount for stake keys because it's a stake address (credential + network ID),
 * which is what we need for API queries. It's a superset of what a pure credential would be.
 */
export interface CredentialMaps {
  /** Payment credentials (bech32: addr_vkh for KeyHash, script for ScriptHash) - network-agnostic */
  paymentCredentials: Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>;
  /** Reward accounts / stake addresses (bech32: stake/stake_test) - includes network ID */
  rewardAccounts: Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>;
}

export interface AddressGroups extends CredentialMaps {
  skippedAddresses: {
    byron: Cardano.PaymentAddress[];
    pointer: Cardano.PaymentAddress[];
  };
}

/** Parses an address, handling both bech32 and base58 formats */
const parseAddress = (address: Cardano.PaymentAddress): Cardano.Address | null => {
  try {
    return Cardano.Address.fromBech32(address);
  } catch {
    try {
      return Cardano.Address.fromBase58(address);
    } catch {
      return null;
    }
  }
};

/** Adds a credential to the map, creating the array if needed */
const addToCredentialMap = <T extends string>(
  map: Map<T, Cardano.PaymentAddress[]>,
  credential: T,
  address: Cardano.PaymentAddress
) => {
  if (!map.has(credential)) {
    map.set(credential, []);
  }
  map.get(credential)!.push(address);
};

/** Processes a BaseAddress, extracting payment credential and reward account (stake address) */
const processBaseAddress = (
  baseAddress: Cardano.BaseAddress,
  parsedAddress: Cardano.Address,
  address: Cardano.PaymentAddress,
  paymentCredentials: Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>,
  rewardAccounts: Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>
) => {
  const paymentCredential = baseAddress.getPaymentCredential();
  const paymentBech32 = Cardano.PaymentCredential.fromCredential(paymentCredential);
  addToCredentialMap(paymentCredentials, paymentBech32, address);

  const stakeCredential = baseAddress.getStakeCredential();
  const networkId = parsedAddress.getNetworkId();
  const rewardAccount = Cardano.RewardAccount.fromCredential(stakeCredential, networkId);
  addToCredentialMap(rewardAccounts, rewardAccount, address);
};

/** Processes an EnterpriseAddress, extracting payment credential only */
const processEnterpriseAddress = (
  enterpriseAddress: Cardano.EnterpriseAddress,
  address: Cardano.PaymentAddress,
  paymentCredentials: Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>
) => {
  const paymentCredential = enterpriseAddress.getPaymentCredential();
  const paymentBech32 = Cardano.PaymentCredential.fromCredential(paymentCredential);
  addToCredentialMap(paymentCredentials, paymentBech32, address);
};

/**
 * Extracts and groups payment credentials and reward accounts (stake addresses) from addresses.
 * Pure function - no logging or side effects.
 *
 * @param addresses Array of payment addresses to extract credentials/addresses from
 * @returns Grouped payment credentials, reward accounts (stake addresses), and skipped addresses
 */
export const extractCredentials = (addresses: Cardano.PaymentAddress[]): AddressGroups => {
  const paymentCredentials = new Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>();
  const rewardAccounts = new Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>();
  const byron: Cardano.PaymentAddress[] = [];
  const pointer: Cardano.PaymentAddress[] = [];
  const seenAddresses = new Set<Cardano.PaymentAddress>();

  for (const address of addresses) {
    if (seenAddresses.has(address)) continue;
    seenAddresses.add(address);

    const parsedAddress = parseAddress(address);
    if (!parsedAddress) continue;

    if (parsedAddress.asByron()) {
      byron.push(address);
      continue;
    }

    if (parsedAddress.asPointer()) {
      pointer.push(address);
      continue;
    }

    const baseAddress = parsedAddress.asBase();
    if (baseAddress) {
      processBaseAddress(baseAddress, parsedAddress, address, paymentCredentials, rewardAccounts);
      continue;
    }

    const enterpriseAddress = parsedAddress.asEnterprise();
    if (enterpriseAddress) {
      processEnterpriseAddress(enterpriseAddress, address, paymentCredentials);
    }
  }

  return {
    paymentCredentials,
    rewardAccounts,
    skippedAddresses: {
      byron,
      pointer
    }
  };
};

interface CredentialInfo {
  addresses: Cardano.PaymentAddress[];
  credential: Cardano.PaymentCredential | Cardano.RewardAccount;
  type: 'payment' | 'stake';
  uncoveredCount: number;
}

/** Builds a list of all payment credentials and reward accounts with their coverage info */
const buildCredentialList = (
  paymentCredentials: Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>,
  rewardAccounts: Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>
): CredentialInfo[] => {
  const allCredentials: CredentialInfo[] = [];

  for (const [credential, addresses] of paymentCredentials.entries()) {
    if (addresses.length > 0) {
      allCredentials.push({
        addresses,
        credential,
        type: 'payment',
        uncoveredCount: addresses.length
      });
    }
  }

  for (const [rewardAccount, addresses] of rewardAccounts.entries()) {
    if (addresses.length > 0) {
      allCredentials.push({
        addresses,
        credential: rewardAccount,
        type: 'stake',
        uncoveredCount: addresses.length
      });
    }
  }

  return allCredentials;
};

/** Updates uncovered counts for all credentials */
const updateUncoveredCounts = (credentialInfos: CredentialInfo[], coveredAddresses: Set<Cardano.PaymentAddress>) => {
  for (const info of credentialInfos) {
    info.uncoveredCount = info.addresses.filter((addr) => !coveredAddresses.has(addr)).length;
  }
};

/** Finds the best credential to use (most coverage, prefer payment over stake on tie) */
const findBestCredential = (credentialInfos: CredentialInfo[]): CredentialInfo | null => {
  let maxInfo: CredentialInfo | null = null;

  for (const info of credentialInfos) {
    if (info.uncoveredCount === 0) continue;

    if (maxInfo === null) {
      maxInfo = info;
      continue;
    }

    const hasMoreCoverage = info.uncoveredCount > maxInfo.uncoveredCount;
    const hasSameCoverageButPreferPayment =
      info.uncoveredCount === maxInfo.uncoveredCount && info.type === 'payment' && maxInfo.type === 'stake';

    if (hasMoreCoverage || hasSameCoverageButPreferPayment) {
      maxInfo = info;
    }
  }

  return maxInfo;
};

/** Adds selected credential/address to result maps */
const addToResultMaps = (
  selectedCredential: CredentialInfo,
  minimizedPayment: Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>,
  minimizedRewardAccounts: Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>
) => {
  if (selectedCredential.type === 'payment') {
    minimizedPayment.set(selectedCredential.credential as Cardano.PaymentCredential, selectedCredential.addresses);
  } else {
    minimizedRewardAccounts.set(selectedCredential.credential as Cardano.RewardAccount, selectedCredential.addresses);
  }
};

/**
 * Finds the minimum set of payment credentials and reward accounts that cover all addresses using a greedy algorithm.
 * Prefers payment credentials over reward accounts (stake addresses) when coverage is equal.
 * Pure function - no logging or side effects.
 *
 * @param credentials Payment credentials and reward accounts maps
 * @returns Minimized credential maps
 */
export const minimizeCredentialSet = (credentials: CredentialMaps): CredentialMaps => {
  const { paymentCredentials, rewardAccounts } = credentials;
  const coveredAddresses = new Set<Cardano.PaymentAddress>();
  const minimizedPayment = new Map<Cardano.PaymentCredential, Cardano.PaymentAddress[]>();
  const minimizedRewardAccounts = new Map<Cardano.RewardAccount, Cardano.PaymentAddress[]>();

  const allCredentials = buildCredentialList(paymentCredentials, rewardAccounts);

  // Greedy algorithm: repeatedly pick the credential/address that covers the most uncovered addresses
  while (allCredentials.some((info) => info.uncoveredCount > 0)) {
    updateUncoveredCounts(allCredentials, coveredAddresses);

    const selectedCredential = findBestCredential(allCredentials);
    if (!selectedCredential || selectedCredential.uncoveredCount === 0) break;

    addToResultMaps(selectedCredential, minimizedPayment, minimizedRewardAccounts);

    // Mark all addresses covered by this credential
    for (const addr of selectedCredential.addresses) {
      coveredAddresses.add(addr);
    }
  }

  return {
    paymentCredentials: minimizedPayment,
    rewardAccounts: minimizedRewardAccounts
  };
};
