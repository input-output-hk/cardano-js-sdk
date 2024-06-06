import * as cip19TestVectors from '../../../../util-dev/src/Cip19TestVectors.js';
import { ByronAddressType } from '../../../src/Cardano/index.js';
import { Cardano } from '../../../src/index.js';

// eslint-disable-next-line max-statements
describe('Cardano/Address', () => {
  describe('isAddress', () => {
    it('returns false if the address is invalid', () => {
      expect(Cardano.isAddress('invalid')).toBe(false);
    });
    it('returns true if the address is a valid shelley address', () => {
      expect(
        Cardano.isAddress(
          // eslint-disable-next-line max-len
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        )
      ).toBe(true);
    });
    it('returns true if the address is a valid stake address', () => {
      expect(Cardano.isAddress('stake1vpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5egfu2p0u')).toBe(true);
    });
    it('returns true if the address is a valid byron address', () => {
      expect(
        Cardano.isAddress(
          // eslint-disable-next-line max-len
          '37btjrVyb4KDXBNC4haBVPCrro8AQPHwvCMp3RFhhSVWwfFmZ6wwzSK6JK1hY6wHNmtrpTf1kdbva8TCneM2YsiXT7mrzT21EacHnPpz5YyUdj64na'
        )
      ).toBe(true);
    });
  });

  it('Address fromString can correctly decode Byron addresses', () => {
    const address = Cardano.Address.fromString(cip19TestVectors.byronTestnetDaedalus);

    expect(address).toBeDefined();

    const byron = address!.asByron();

    expect(byron).toBeDefined();

    expect(byron!.getByronAddressType()).toEqual(ByronAddressType.PubKey);
    expect(byron!.getAttributes()).toEqual({
      derivationPath: '9c1722f7e446689256e1a30260f3510d558d99d0c391f2ba89cb6977',
      magic: 1_097_911_063
    });
    expect(byron!.getRoot()).toEqual('9c708538a763ff27169987a489e35057ef3cd3778c05e96f7ba9450e');
  });

  it('Address fromString can correctly decode bech32 addresses', () => {
    const address = Cardano.Address.fromString(cip19TestVectors.testnetRewardScript);

    expect(address).toBeDefined();

    const reward = address!.asReward();

    expect(reward).toBeDefined();
    expect(reward!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
  });

  it('Address fromString can correctly decode CBOR addresses', () => {
    const address = Cardano.Address.fromString('f0c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f');

    expect(address).toBeDefined();

    const reward = address!.asReward();

    expect(reward).toBeDefined();
    expect(reward!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
  });

  it('Address fromString return null when a invalid addresses is given', () => {
    const address = Cardano.Address.fromString('invalidAddress');
    expect(address).toEqual(null);
  });

  it('Address isValidBech32 return true when a valid bech32 address is given', () => {
    expect(Cardano.Address.isValidBech32(cip19TestVectors.testnetBasePaymentKeyStakeKey)).toEqual(true);
  });

  it('Address isValidBech32 return false when an invalid bech32 address is given', () => {
    expect(Cardano.Address.isValidBech32('invalidAddress')).toEqual(false);
  });

  it('Address isValidByron return true when a valid byron address is given', () => {
    expect(Cardano.Address.isValidByron(cip19TestVectors.byronTestnetDaedalus)).toEqual(true);
  });

  it('Address isValidByron return false when an invalid byron address is given', () => {
    expect(Cardano.Address.isValidByron('invalidAddress')).toEqual(false);
  });

  it('Address isValid return true when a valid byron address is given', () => {
    expect(Cardano.Address.isValid(cip19TestVectors.byronTestnetDaedalus)).toEqual(true);
  });

  it('Address isValid return true when a valid bech32 address is given', () => {
    expect(Cardano.Address.isValid(cip19TestVectors.testnetBasePaymentKeyStakeKey)).toEqual(true);
  });

  it('Address isValid return false when an invalid address is given', () => {
    expect(Cardano.Address.isValid('invalidAddress')).toEqual(false);
  });

  it('Address isValid return false when a bitcoin address is given', () => {
    const address = Cardano.Address.isValid('bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh');
    expect(address).toEqual(false);
  });

  it('Address can correctly decode/encode mainnet BasePaymentKeyStakeKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.basePaymentKeyStakeKey);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.KEY_STAKE_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentKeyStakeKey);
    expect(address.toBech32()).toBe(cip19TestVectors.basePaymentKeyStakeKey);
    expect(address.toBytes()).toBe(
      '019493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e337b62cfff6403a06a3acbc34f8c46003c69fe79a3628cefa9c47251'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.basePaymentKeyStakeKey);
  });

  it('Address can correctly decode/encode testnet BasePaymentKeyStakeKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetBasePaymentKeyStakeKey);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.KEY_STAKE_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentKeyStakeKey);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetBasePaymentKeyStakeKey);
    expect(address.toBytes()).toBe(
      '009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e337b62cfff6403a06a3acbc34f8c46003c69fe79a3628cefa9c47251'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(
      cip19TestVectors.testnetBasePaymentKeyStakeKey
    );
  });

  it('Address can correctly decode/encode mainnet BasePaymentScriptStakeKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.basePaymentScriptStakeKey);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.KEY_STAKE_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentScriptStakeKey);
    expect(address.toBech32()).toBe(cip19TestVectors.basePaymentScriptStakeKey);
    expect(address.toBytes()).toBe(
      '11c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f337b62cfff6403a06a3acbc34f8c46003c69fe79a3628cefa9c47251'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.basePaymentScriptStakeKey);
  });

  it('Address can correctly decode/encode testnet BasePaymentScriptStakeKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetBasePaymentScriptStakeKey);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.KEY_STAKE_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentScriptStakeKey);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetBasePaymentScriptStakeKey);
    expect(address.toBytes()).toBe(
      '10c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f337b62cfff6403a06a3acbc34f8c46003c69fe79a3628cefa9c47251'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(
      cip19TestVectors.testnetBasePaymentScriptStakeKey
    );
  });

  it('Address can correctly decode/encode mainnet BasePaymentKeyStakeScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.basePaymentKeyStakeScript);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentKeyStakeScript);
    expect(address.toBech32()).toBe(cip19TestVectors.basePaymentKeyStakeScript);
    expect(address.toBytes()).toBe(
      '219493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8ec37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.basePaymentKeyStakeScript);
  });

  it('Address can correctly decode/encode testnet BasePaymentKeyStakeScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetBasePaymentKeyStakeScript);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentKeyStakeScript);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetBasePaymentKeyStakeScript);
    expect(address.toBytes()).toBe(
      '209493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8ec37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(
      cip19TestVectors.testnetBasePaymentKeyStakeScript
    );
  });

  it('Address can correctly decode/encode mainnet BasePaymentScriptStakeScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.basePaymentScriptStakeScript);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentScriptStakeScript);
    expect(address.toBech32()).toBe(cip19TestVectors.basePaymentScriptStakeScript);
    expect(address.toBytes()).toBe(
      '31c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542fc37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.basePaymentScriptStakeScript);
  });

  it('Address can correctly decode/encode testnet BasePaymentScriptStakeScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetBasePaymentScriptStakeScript);

    const baseAddress = address.asBase();

    expect(baseAddress).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(baseAddress!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(baseAddress!.getStakeCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.BasePaymentScriptStakeScript);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetBasePaymentScriptStakeScript);
    expect(address.toBytes()).toBe(
      '30c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542fc37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(
      cip19TestVectors.testnetBasePaymentScriptStakeScript
    );
  });

  it('Address can correctly decode/encode mainnet Byron', () => {
    const address = Cardano.Address.fromBase58(cip19TestVectors.byronMainnetYoroi);

    const byron = address.asByron();

    expect(byron).toBeDefined();
    expect(address.asEnterprise()).toBeUndefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(byron!.getByronAddressType()).toEqual(ByronAddressType.PubKey);
    expect(address.getType()).toBe(Cardano.AddressType.Byron);
    // This address payload has no attributes. It was a Yoroi’s address on MainNet which follows a
    // BIP-44 derivation scheme and therefore, does not require any attributes.
    expect(byron!.getAttributes()).toEqual({ derivationPath: undefined, magic: undefined });
    expect(byron!.getRoot()).toEqual('ba970ad36654d8dd8f74274b733452ddeab9a62a397746be3c42ccdd');
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.toBase58()).toBe(cip19TestVectors.byronMainnetYoroi);
    expect(address.toBytes()).toBe(
      '82d818582183581cba970ad36654d8dd8f74274b733452ddeab9a62a397746be3c42ccdda0001a9026da5b'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBase58()).toBe(cip19TestVectors.byronMainnetYoroi);
  });

  it('Address can correctly decode/encode testnet Byron', () => {
    const address = Cardano.Address.fromBase58(cip19TestVectors.byronTestnetDaedalus);

    const byron = address.asByron();

    expect(byron).toBeDefined();
    expect(address.asEnterprise()).toBeUndefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(byron!.getByronAddressType()).toEqual(ByronAddressType.PubKey);
    expect(address.getType()).toBe(Cardano.AddressType.Byron);
    expect(byron!.getAttributes()).toEqual({
      derivationPath: '9c1722f7e446689256e1a30260f3510d558d99d0c391f2ba89cb6977',
      magic: 1_097_911_063
    });
    expect(byron!.getRoot()).toEqual('9c708538a763ff27169987a489e35057ef3cd3778c05e96f7ba9450e');
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.toBase58()).toBe(cip19TestVectors.byronTestnetDaedalus);
    expect(address.toBytes()).toBe(
      // eslint-disable-next-line max-len
      '82d818584983581c9c708538a763ff27169987a489e35057ef3cd3778c05e96f7ba9450ea201581e581c9c1722f7e446689256e1a30260f3510d558d99d0c391f2ba89cb697702451a4170cb17001a6979126c'
    );
    expect(Cardano.Address.fromBytes(address.toBytes()).toBase58()).toBe(cip19TestVectors.byronTestnetDaedalus);
  });

  it('Address can correctly decode/encode mainnet EnterpriseKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.enterpriseKey);

    const enterprise = address.asEnterprise();

    expect(enterprise).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(enterprise!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.EnterpriseKey);
    expect(address.toBech32()).toBe(cip19TestVectors.enterpriseKey);
    expect(address.toBytes()).toBe('619493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.enterpriseKey);
  });

  it('Address can correctly decode/encode testnet EnterpriseKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetEnterpriseKey);

    const enterprise = address.asEnterprise();

    expect(enterprise).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(enterprise!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.EnterpriseKey);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetEnterpriseKey);
    expect(address.toBytes()).toBe('609493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.testnetEnterpriseKey);
  });

  it('Address can correctly decode/encode mainnet EnterpriseScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.enterpriseScript);

    const enterprise = address.asEnterprise();

    expect(enterprise).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(enterprise!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.EnterpriseScript);
    expect(address.toBech32()).toBe(cip19TestVectors.enterpriseScript);
    expect(address.toBytes()).toBe('71c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.enterpriseScript);
  });

  it('Address can correctly decode/encode testnet EnterpriseScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetEnterpriseScript);

    const enterprise = address.asEnterprise();

    expect(enterprise).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(enterprise!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.EnterpriseScript);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetEnterpriseScript);
    expect(address.toBytes()).toBe('70c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.testnetEnterpriseScript);
  });

  it('Address can correctly decode/encode mainnet PointerKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.pointerKey);

    const pointer = address.asPointer();

    expect(pointer).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(pointer!.getStakePointer()).toEqual(cip19TestVectors.POINTER);
    expect(pointer!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.PointerKey);
    expect(address.toBech32()).toBe(cip19TestVectors.pointerKey);
    expect(address.toBytes()).toBe('419493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e8198bd431b03');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.pointerKey);
  });

  it('Address can correctly decode/encode testnet PointerKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetPointerKey);

    const pointer = address.asPointer();

    expect(pointer).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(pointer!.getStakePointer()).toEqual(cip19TestVectors.POINTER);
    expect(pointer!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.PointerKey);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetPointerKey);
    expect(address.toBytes()).toBe('409493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e8198bd431b03');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.testnetPointerKey);
  });

  it('Address can correctly decode/encode mainnet PointerScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.pointerScript);

    const pointer = address.asPointer();

    expect(pointer).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(pointer!.getStakePointer()).toEqual(cip19TestVectors.POINTER);
    expect(pointer!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.PointerScript);
    expect(address.toBech32()).toBe(cip19TestVectors.pointerScript);
    expect(address.toBytes()).toBe('51c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f8198bd431b03');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.pointerScript);
  });

  it('Address can correctly decode/encode testnet PointerScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetPointerScript);

    const pointer = address.asPointer();

    expect(pointer).toBeDefined();
    expect(address.asReward()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asEnterprise()).toBeUndefined();

    expect(pointer!.getStakePointer()).toEqual(cip19TestVectors.POINTER);
    expect(pointer!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.PointerScript);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetPointerScript);
    expect(address.toBytes()).toBe('50c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f8198bd431b03');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.testnetPointerScript);
  });

  it('Address can correctly decode/encode mainnet RewardKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.rewardKey);

    const reward = address.asReward();

    expect(reward).toBeDefined();
    expect(address.asEnterprise()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(reward!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_STAKE_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.RewardKey);
    expect(address.toBech32()).toBe(cip19TestVectors.rewardKey);
    expect(address.toBytes()).toBe('e1337b62cfff6403a06a3acbc34f8c46003c69fe79a3628cefa9c47251');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.rewardKey);
  });

  it('Address can correctly decode/encode testnet RewardKey', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetRewardKey);

    const reward = address.asReward();

    expect(reward).toBeDefined();
    expect(address.asEnterprise()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(reward!.getPaymentCredential()).toEqual(cip19TestVectors.KEY_STAKE_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.RewardKey);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetRewardKey);
    expect(address.toBytes()).toBe('e0337b62cfff6403a06a3acbc34f8c46003c69fe79a3628cefa9c47251');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.testnetRewardKey);
  });

  it('Address can correctly decode/encode mainnet RewardScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.rewardScript);

    const reward = address.asReward();

    expect(reward).toBeDefined();
    expect(address.asEnterprise()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(reward!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Mainnet);
    expect(address.getType()).toBe(Cardano.AddressType.RewardScript);
    expect(address.toBech32()).toBe(cip19TestVectors.rewardScript);
    expect(address.toBytes()).toBe('f1c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.rewardScript);
  });

  it('Address can correctly decode/encode testnet RewardScript', () => {
    const address = Cardano.Address.fromBech32(cip19TestVectors.testnetRewardScript);

    const reward = address.asReward();

    expect(reward).toBeDefined();
    expect(address.asEnterprise()).toBeUndefined();
    expect(address.asByron()).toBeUndefined();
    expect(address.asBase()).toBeUndefined();
    expect(address.asPointer()).toBeUndefined();

    expect(reward!.getPaymentCredential()).toEqual(cip19TestVectors.SCRIPT_CREDENTIAL);
    expect(address.getNetworkId()).toBe(Cardano.NetworkId.Testnet);
    expect(address.getType()).toBe(Cardano.AddressType.RewardScript);
    expect(address.toBech32()).toBe(cip19TestVectors.testnetRewardScript);
    expect(address.toBytes()).toBe('f0c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f');
    expect(Cardano.Address.fromBytes(address.toBytes()).toBech32()).toBe(cip19TestVectors.testnetRewardScript);
  });
});
