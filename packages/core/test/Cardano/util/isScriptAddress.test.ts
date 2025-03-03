import { PaymentAddress } from '../../../src/Cardano';
import { isScriptAddress } from '../../../src/Cardano/util';

describe('isScriptAddress', () => {
  it('returns false when it receives a non-script address', () => {
    const nonScriptAddress = PaymentAddress(
      'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
    );
    expect(isScriptAddress(nonScriptAddress)).toBe(false);
  });

  it('returns true when it receives a script address', () => {
    const scriptAddress = PaymentAddress(
      'addr_test1xr806j8xcq6cw6jjkzfxyewyue33zwnu4ajnu28hakp5fmc6gddlgeqee97vwdeafwrdgrtzp2rw8rlchjf25ld7r2ssptq3m9'
    );
    expect(isScriptAddress(scriptAddress)).toBe(true);
  });
});
