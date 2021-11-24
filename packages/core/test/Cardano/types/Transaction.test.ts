import { TransactionId } from '../../../src/Cardano';

describe('Cardano/types/Transaction', () => {
  it('TransactionId() accepts a valid transaction hash', () => {
    expect(() => TransactionId('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).not.toThrow();
  });
});
