import { AddressBalances, applyValue } from '../src/AddressBalance';

describe('AddressBalance', () => {
  describe('applyValueToBalance', () => {
    let balances: AddressBalances;
    beforeEach(() => {
      balances = {
        ab: {
          ada: { lovelace: 100n }
        },
        cd: {
          ada: { lovelace: 400n },
          policyId: {
            assetName: 10n
          }
        },
        ef: {
          ada: { lovelace: 500n },
          policyId: {
            assetName1: 10n,
            assetName2: 20n
          }
        }
      };
    });
    describe('values containing only coins', () => {
      const address = 'ab';
      it('adds the coins balance', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 50n } })).toEqual({ ada: { lovelace: 150n } });
      });
      it('subtracts the coins balance when spending', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 50n } }, true)).toEqual({ ada: { lovelace: 50n } });
      });
      it('returns the same balance if coins is 0', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 0n } })).toEqual({ ada: { lovelace: 100n } });
      });
      it('returns the same balance if coins is 0 when spending', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 0n } }, true)).toEqual({ ada: { lovelace: 100n } });
      });
    });
    describe('values containing an asset', () => {
      const address = 'cd';
      it('adds the coins and asset balance', () => {
        expect(
          applyValue(balances[address], {
            ada: { lovelace: 50n },
            policyId: {
              assetName: 10n
            }
          })
        ).toEqual({ ada: { lovelace: 450n }, policyId: { assetName: 20n } });
      });
      it('subtracts the coins and asset balance when spending', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 50n }, policyId: { assetName: 9n } }, true)).toEqual({
          ada: { lovelace: 350n },
          policyId: { assetName: 1n }
        });
      });
      it('returns the same balance if coins and asset is 0', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 0n }, policyId: { assetName: 0n } })).toEqual({
          ada: { lovelace: 400n },
          policyId: { assetName: 10n }
        });
      });
      it('returns the same balance if coins and asset is 0 when spending', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 0n }, policyId: { assetName: 0n } }, true)).toEqual({
          ada: { lovelace: 400n },
          policyId: { assetName: 10n }
        });
      });
    });
    describe('values containing multiple assets', () => {
      const address = 'ef';
      it('adds the coins and assets balance', () => {
        expect(
          applyValue(balances[address], {
            ada: { lovelace: 50n },
            policyId: {
              assetName1: 10n,
              assetName2: 55n
            }
          })
        ).toEqual({
          ada: { lovelace: 550n },
          policyId: {
            assetName1: 20n,
            assetName2: 75n
          }
        });
      });
      it('subtracts the coins and asset balances when spending', () => {
        expect(
          applyValue(
            balances[address],
            {
              ada: { lovelace: 50n },
              policyId: {
                assetName1: 9n,
                assetName2: 15n
              }
            },
            true
          )
        ).toEqual({
          ada: { lovelace: 450n },
          policyId: {
            assetName1: 1n,
            assetName2: 5n
          }
        });
      });
      it('adds new assets to the address balance', () => {
        expect(
          applyValue(balances[address], {
            ada: { lovelace: 1n },
            policyId: {
              new: 100n
            }
          })
        ).toEqual({
          ada: { lovelace: 501n },
          policyId: {
            assetName1: 10n,
            assetName2: 20n,
            new: 100n
          }
        });
      });
    });
    describe('balance containing multiple assets, value containing only coins', () => {
      const address = 'ef';
      it('adds the coins', () => {
        expect(
          applyValue(balances[address], {
            ada: { lovelace: 50n }
          })
        ).toEqual({
          ada: { lovelace: 550n },
          policyId: {
            assetName1: 10n,
            assetName2: 20n
          }
        });
      });
      it('subtracts the coins', () => {
        expect(applyValue(balances[address], { ada: { lovelace: 50n } }, true)).toEqual({
          ada: { lovelace: 450n },
          policyId: {
            assetName1: 10n,
            assetName2: 20n
          }
        });
      });
    });
    describe('guarding against negative balances', () => {
      const address = 'cd';
      it('throws if the balance calculated for coins is less than 0', () => {
        expect(() =>
          applyValue(
            balances[address],
            {
              ada: { lovelace: 500n }
            },
            true
          )
        ).toThrow();
      });
      it('throws if the balance calculated for assets is less than 0', () => {
        expect(() =>
          applyValue(
            balances[address],
            {
              ada: { lovelace: 1n },
              policyId: {
                assetName1: 20n
              }
            },
            true
          )
        ).toThrow();
      });
    });
  });
});
