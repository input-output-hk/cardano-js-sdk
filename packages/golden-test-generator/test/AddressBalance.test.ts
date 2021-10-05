import { AddressBalances, applyValue } from '../src/AddressBalance';

describe('AddressBalance', () => {
  describe('applyValueToBalance', () => {
    let balances: AddressBalances;
    beforeEach(() => {
      balances = {
        ab: {
          coins: 100
        },
        cd: {
          assets: {
            12: 10n
          },
          coins: 400
        },
        ef: {
          assets: {
            12: 10n,
            34: 20n
          },
          coins: 500
        }
      };
    });
    describe('values containing only coins', () => {
      const address = 'ab';
      it('adds the coins balance', () => {
        expect(applyValue(balances[address], { coins: 50 })).toEqual({ coins: 150 });
      });
      it('subtracts the coins balance when spending', () => {
        expect(applyValue(balances[address], { coins: 50 }, true)).toEqual({ coins: 50 });
      });
      it('returns the same balance if coins is 0', () => {
        expect(applyValue(balances[address], { coins: 0 })).toEqual({ coins: 100 });
      });
      it('returns the same balance if coins is 0 when spending', () => {
        expect(applyValue(balances[address], { coins: 0 }, true)).toEqual({ coins: 100 });
      });
    });
    describe('values containing an asset', () => {
      const address = 'cd';
      it('adds the coins and asset balance', () => {
        expect(
          applyValue(balances[address], {
            assets: {
              12: 10n
            },
            coins: 50
          })
        ).toEqual({ assets: { 12: 20n }, coins: 450 });
      });
      it('subtracts the coins and asset balance when spending', () => {
        expect(applyValue(balances[address], { assets: { 12: 9n }, coins: 50 }, true)).toEqual({
          assets: { 12: 1n },
          coins: 350
        });
      });
      it('returns the same balance if coins and asset is 0', () => {
        expect(applyValue(balances[address], { assets: { 12: 0n }, coins: 0 })).toEqual({
          assets: { 12: 10n },
          coins: 400
        });
      });
      it('returns the same balance if coins and asset is 0 when spending', () => {
        expect(applyValue(balances[address], { assets: { 12: 0n }, coins: 0 }, true)).toEqual({
          assets: { 12: 10n },
          coins: 400
        });
      });
    });
    describe('values containing multiple assets', () => {
      const address = 'ef';
      it('adds the coins and assets balance', () => {
        expect(
          applyValue(balances[address], {
            assets: {
              12: 10n,
              34: 55n
            },
            coins: 50
          })
        ).toEqual({
          assets: {
            12: 20n,
            34: 75n
          },
          coins: 550
        });
      });
      it('subtracts the coins and asset balances when spending', () => {
        expect(
          applyValue(
            balances[address],
            {
              assets: {
                12: 9n,
                34: 15n
              },
              coins: 50
            },
            true
          )
        ).toEqual({
          assets: {
            12: 1n,
            34: 5n
          },
          coins: 450
        });
      });
      it('adds new assets to the address balance', () => {
        expect(
          applyValue(balances[address], {
            assets: {
              new: 100n
            },
            coins: 1
          })
        ).toEqual({
          assets: {
            12: 10n,
            34: 20n,
            new: 100n
          },
          coins: 501
        });
      });
    });
    describe('balance containing multiple assets, value containing only coins', () => {
      const address = 'ef';
      it('adds the coins', () => {
        expect(
          applyValue(balances[address], {
            coins: 50
          })
        ).toEqual({
          assets: {
            12: 10n,
            34: 20n
          },
          coins: 550
        });
      });
      it('subtracts the coins', () => {
        expect(applyValue(balances[address], { coins: 50 }, true)).toEqual({
          assets: {
            12: 10n,
            34: 20n
          },
          coins: 450
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
              coins: 500
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
              assets: {
                12: 20n
              },
              coins: 1
            },
            true
          )
        ).toThrow();
      });
    });
  });
});
