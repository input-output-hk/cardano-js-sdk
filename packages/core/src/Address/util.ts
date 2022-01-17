import { parseCslAddress } from '../CSL';

/**
 * Validate input as a Cardano Address from all Cardano eras and networks
 */
export const isAddress = (input: string): boolean => !!parseCslAddress(input);
