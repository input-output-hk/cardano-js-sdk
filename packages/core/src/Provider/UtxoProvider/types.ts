// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import Cardano, { Provider } from '../..';

export interface UtxoByAddressesArgs {
  addresses: Cardano.Address[];
}

export interface UtxoProvider extends Provider {
  /**
   * @returns an array of utxo corresponding to the given addresses
   */
  utxoByAddresses: (args: UtxoByAddressesArgs) => Promise<Cardano.Utxo[]>;
}
