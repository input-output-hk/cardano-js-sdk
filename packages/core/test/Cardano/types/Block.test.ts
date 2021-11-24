import { BlockId } from '../../../src/Cardano';

describe('Cardano/types/Block', () => {
  it('BlockId() accepts a valid transaction hash', () => {
    expect(() => BlockId('0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed')).not.toThrow();
  });
});
