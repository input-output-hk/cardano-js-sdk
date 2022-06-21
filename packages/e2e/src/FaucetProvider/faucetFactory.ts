import { CardanoWalletFaucetProvider } from "./providers/cardanoWalletFaucetProvider"
import { FaucetProvider } from "./types"

// Constants
const PARAM_NAME_URL:       string = 'url';
const PARAM_NAME_MNEMONICS: string = 'mnomonics';

/**
 * Faucet provider factories.
 */
export class FaucetFactory {

    /**
     * Creates a new faucet factory.
     * 
     * @param name The name of the concrete facet provider implementation.
     * @param params The parameters to be passed to the concrete implementation constructor.
     * 
     * @returns The new Faucet provider.
     * 
     * @throws if The give provider name is not registered, or the constructor parameters of the providers are either missing or invalid.
     */
    static create(name: string, params: any): FaucetProvider {

        if (name === CardanoWalletFaucetProvider.name) {

            if (!params.hasOwnProperty(PARAM_NAME_URL))
                throw new Error(`${CardanoWalletFaucetProvider.name} missing argument: ${PARAM_NAME_URL}`);

            if (!params.hasOwnProperty(PARAM_NAME_MNEMONICS))
                throw new Error(`${CardanoWalletFaucetProvider.name} missing argument: ${PARAM_NAME_MNEMONICS}`);

            return new CardanoWalletFaucetProvider(params[PARAM_NAME_URL], params[PARAM_NAME_MNEMONICS]);

        } else {
            throw new Error(`Faucet provider unsupported: ${name}`);
        }
    }
}