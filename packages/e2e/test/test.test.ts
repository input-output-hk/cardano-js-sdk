import { CardanoWalletFaucetService } from '../src/FaucetProvider/providers/cardanoWalletFaucetProvider'
import { FaucetRequestResult } from '../src/FaucetProvider/types'

describe('CardanoWalletFaucetService', () => {

    const _faucetProvider: CardanoWalletFaucetService = new CardanoWalletFaucetService("http://localhost:8090/v2", "fire method repair aware foot tray accuse brother popular olive find account sick rocket next");
   
    beforeAll(async () => {

        await _faucetProvider.start();
        let healthCheck = await _faucetProvider.healthCheck();

        if (!healthCheck.ok)
            throw "Faucet provider could not be started.";
    });

    afterAll(async() => {

        await _faucetProvider.close();
    });

    it('should do stuff', async () => {

        let result: FaucetRequestResult = await _faucetProvider.request(
            ["addr_test1vrgylrse49du60jdy7h46mg5mwft6kw8r0l4v5pklkj324cm247gf", "addr_test1vrgylrse49du60jdy7h46mg5mwft6kw8r0l4v5pklkj324cm247gf"],
            [45000000, 33000000]);

        console.log(result);
    });
});