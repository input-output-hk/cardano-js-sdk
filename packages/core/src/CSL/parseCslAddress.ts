import { CSL } from './CSL';

/**
 * Parse Cardano address from all Cardano eras and networks
 */
export const parseCslAddress = (input: string): CSL.Address | null => {
  try {
    return CSL.Address.from_bech32(input);
  } catch (error: unknown) {
    // eslint-disable-next-line no-console
    console.error('CSL failed to parse address', `"${input}"`, error);
    try {
      return CSL.ByronAddress.from_base58(input).to_address();
    } catch {
      return null;
    }
  }
};
