/* eslint-disable sonarjs/no-duplicate-string */
// cSpell:ignore kora subhandles
/* eslint-disable no-magic-numbers */
/* eslint-disable camelcase */
import { Cardano, HandleResolution } from '@cardano-sdk/core';
import { KoraLabsHandleProvider } from '@cardano-sdk/cardano-services-client';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const handlePolicyId = 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a';

const config = {
  policyId: Cardano.PolicyId(handlePolicyId),
  serverUrl: 'https://preprod.api.handle.me/'
};

const test_handle_1 = {
  bg_asset: 'e517b38693b633f1bc0dd3eb69cb1ad0f0c198c67188405901ae63a3001bc28068616e646c65735f6e61747572652d6c616b65',
  bg_image: 'ipfs://zdj7Wjfr1dZz7Kao2ADZSF3xttBm7AJewWH5sARvG6XkmaprT',
  characters: 'letters,numbers,special',
  created_slot_number: 35_479_476,
  default_in_wallet: 'cde',
  handle_type: 'handle',
  has_datum: false,
  hex: '000de140746573745f68616e646c655f31',
  holder: 'stake_test1uract9p2rvczsaxzdmvhlplj4ngduhfztdsru0hvegazldgrtgynh',
  holder_type: 'wallet',
  image: 'ipfs://zb2rheiGzwihXcW7FSnFUmCeGdRMJrVtynMYy3o9xKSr2myD8',
  image_hash: '26321fc1f9aac61c950c08c5fd7299e36173002e6f6b8ab7f748068879796ba3',
  last_update_address:
    '0x00e8fc28480c73486d288074c5ac7660ad0611ae5ce505de194353466961ea70af1de71795df52e62d1c0f2c8817f13b5cd4b40e04cab5ad6a',
  length: 13,
  name: 'test_handle_1',
  numeric_modifiers: '',
  og_number: 0,
  payment_key_hash: 'cf1b5fe70c1ab3b1da0bcbb18267502ec5fdfb0522eb0de359151ce8',
  pfp_image: '',
  policy: 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a',
  pz_enabled: false,
  rarity: 'basic',
  resolved_addresses: {
    ada: 'addr_test1qr83khl8psdt8vw6p09mrqn82qhvtl0mq53wkr0rty23e68msk2z5xes9p6vymke07rl9txsmewjykmq8clwej36976s2ay8ev'
  },
  standard_image: 'ipfs://zb2rheiGzwihXcW7FSnFUmCeGdRMJrVtynMYy3o9xKSr2myD8',
  standard_image_hash:
    '37376533393939366463353066643131353033376536636234373661343933653930666161396362356531633536323939306361383764346236383531613666',
  svg_version: '1.13.0',
  updated_slot_number: 80_137_815,
  utxo: '47a95080175d8dad8480d0cb052b88fbb18382b1186aec3564088866b95ce269#0',
  version: 1
};

const test_handle_2 = {
  bg_image: '',
  characters: 'letters,numbers,special',
  created_slot_number: 36_089_789,
  default_in_wallet: 'cde',
  handle_type: 'handle',
  has_datum: false,
  hex: '000de140746573745f68616e646c655f32',
  holder: 'stake_test1uract9p2rvczsaxzdmvhlplj4ngduhfztdsru0hvegazldgrtgynh',
  holder_type: 'wallet',
  image: 'ipfs://zb2rhaLNcs1bRDyTaKFUZ1BcseBj45JUgo5HzezdBC2BFzYdw',
  image_hash: '740a3916076b375e39f3bf6a7bb482bc652958fb59c59c8244c0b38fa48e5b06',
  last_update_address:
    '0x00a6801d5bbd8405ac0c6d8e4fd56eb573df3e5d567d22a8c5601dd5b6156eea2a4aa7717720f50abaf8baa341124dbf18b43ee2e349d83af4',
  length: 13,
  name: 'test_handle_2',
  numeric_modifiers: '',
  og_number: 0,
  payment_key_hash: 'cf1b5fe70c1ab3b1da0bcbb18267502ec5fdfb0522eb0de359151ce8',
  pfp_image: '',
  policy: 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a',
  pz_enabled: false,
  rarity: 'basic',
  resolved_addresses: {
    ada: 'addr_test1qr83khl8psdt8vw6p09mrqn82qhvtl0mq53wkr0rty23e68msk2z5xes9p6vymke07rl9txsmewjykmq8clwej36976s2ay8ev'
  },
  standard_image: 'ipfs://zb2rhaLNcs1bRDyTaKFUZ1BcseBj45JUgo5HzezdBC2BFzYdw',
  standard_image_hash:
    '33366438366439656366383236656637393366386439393335363330666266303565393033643934653430323139353463376662336438353663663361393832',
  svg_version: '3.0.0',
  updated_slot_number: 80_137_815,
  utxo: '47a95080175d8dad8480d0cb052b88fbb18382b1186aec3564088866b95ce269#0',
  version: 1
};

const handle_ = {
  characters: 'letters',
  created_slot_number: 66_464_780,
  default_in_wallet: '1925',
  handle_type: 'handle',
  has_datum: false,
  hex: '000de14068616e646c65',
  holder: 'stake_test1urcs5pxwju0eex77jftma9hetf8avkdqwftlkc57fr4ataqcvgpaz',
  holder_type: 'wallet',
  image: 'ipfs://zb2rhmoP92QisWdhs76eUYsLbH85cfs4mkJzYm69eA1EPZYWS',
  image_hash: 'e134411636b3a147dde4763cff01d651aacd1a5a397c11736810020cf95cf307',
  last_update_address:
    '0x0022b74d2e789358eddd5ac9441477583eae01af674b2226faa92ec44ef10a04ce971f9c9bde9257be96f95a4fd659a07257fb629e48ebd5f4',
  length: 6,
  name: 'handle',
  numeric_modifiers: '',
  og_number: 0,
  payment_key_hash: '22b74d2e789358eddd5ac9441477583eae01af674b2226faa92ec44e',
  policy: 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a',
  pz_enabled: false,
  rarity: 'common',
  resolved_addresses: {
    ada: 'addr_test1qq3twnfw0zf43mwatty5g9rhtql2uqd0va9jyfh64yhvgnh3pgzva9clnjdaayjhh6t0jkj06ev6qujhld3fuj8t6h6q9a037y'
  },
  standard_image: 'ipfs://zb2rhmoP92QisWdhs76eUYsLbH85cfs4mkJzYm69eA1EPZYWS',
  standard_image_hash: 'e134411636b3a147dde4763cff01d651aacd1a5a397c11736810020cf95cf307',
  svg_version: '3.0.8',
  updated_slot_number: 66_464_780,
  utxo: 'daf2b0025ce52ce5b14aed06d3c8a65a2a5ce04184a2bc1bd5e66413d476f536#2',
  version: 1
};

const ada_handle = {
  bg_image: '',
  characters: 'letters,special',
  created_slot_number: 69_795_802,
  default_in_wallet: 'goodgood',
  handle_type: 'handle',
  has_datum: false,
  hex: '000de1406164612e68616e646c65',
  holder: 'stake_test1uqv7h4p9uegkxp86h4c9lp8egxzul7y9skn6j7uv2kscqrqvs9fuh',
  holder_type: 'wallet',
  image: 'ipfs://zb2rhkzJM1xbi4Wd3fMEXpmzNWd8s9a45yYUzckHFPmUrDjDu',
  image_hash: 'd5248957460ebe56fe1b776dc7c97e2166088bb558f6a449881d2a9bb96c88a4',
  last_update_address:
    '0x0059af3b60893002498bd0fc84bd64f8487eecb0df845ad9e60932aa8674eb22ead1bf6ec66d107e916772585f1bc8390b76498fbe0a05365e',
  length: 10,
  name: 'ada.handle',
  numeric_modifiers: '',
  og_number: 0,
  payment_key_hash: '5246584e62db5939298f453ded5061229381b06e3d9fdf107b4e1e9d',
  pfp_image: '',
  policy: 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a',
  pz_enabled: true,
  rarity: 'basic',
  resolved_addresses: {
    ada: 'addr_test1qpfyvkzwvtd4jwff3aznmm2svy3f8qdsdc7elhcs0d8pa8gea02ztej3vvz040tst7z0jsv9elugtpd849acc4dpsqxqx9746k'
  },
  standard_image: 'ipfs://zb2rhkzJM1xbi4Wd3fMEXpmzNWd8s9a45yYUzckHFPmUrDjDu',
  standard_image_hash: 'd5248957460ebe56fe1b776dc7c97e2166088bb558f6a449881d2a9bb96c88a4',
  svg_version: '3.0.8',
  updated_slot_number: 69_863_096,
  utxo: 'dcc7317400344786509aa8f5f8ac1feaee40aed7eddf4b51df54ba89d80730b3#0',
  version: 1
};

const space_ada_handle = {
  characters: 'letters,special',
  created_slot_number: 69_871_820,
  default_in_wallet: 'conraddit',
  handle_type: 'virtual_subhandle',
  has_datum: false,
  hex: '000000007370616365406164612e68616e646c65',
  holder: 'stake_test1up6wkgh26xlka3ndzplfzemjtp03hjpepdmynra7pgznvhsycsez9',
  holder_type: 'wallet',
  image: 'ipfs://zb2rhkzJM1xbi4Wd3fMEXpmzNWd8s9a45yYUzckHFPmUrDjDu',
  image_hash: '26fe10e21dd178888ab41ab8c2c3b5bba08e58a4aec1108aafa7d5d4ce12276a',
  last_update_address:
    '0x005246584e62db5939298f453ded5061229381b06e3d9fdf107b4e1e9d19ebd425e6516304fabd705f84f94185cff88585a7a97b8c55a1800c',
  length: 16,
  name: 'space@ada.handle',
  numeric_modifiers: '',
  og_number: 0,
  payment_key_hash: '59af3b60893002498bd0fc84bd64f8487eecb0df845ad9e60932aa86',
  policy: 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a',
  pz_enabled: true,
  rarity: 'basic',
  resolved_addresses: {
    ada: 'addr_test1qpv67wmq3ycqyjvt6r7gf0tylpy8am9sm7z94k0xpye24pn5av3w45dldmrx6yr7j9nhykzlr0yrjzmkfx8muzs9xe0q9vuv59'
  },
  standard_image: '',
  standard_image_hash: '26fe10e21dd178888ab41ab8c2c3b5bba08e58a4aec1108aafa7d5d4ce12276a',
  sub_characters: 'letters',
  sub_length: 5,
  sub_numeric_modifiers: '',
  sub_rarity: 'common',
  svg_version: '3.0.8',
  updated_slot_number: 69_871_820,
  utxo: '94b18568d8b1b7d02530bf83e8c83f21437a9ef4aebabb6ccdd1e1fec0638039#2',
  version: 0,
  virtual: { expires_time: 1_757_091_000_789, public_mint: false }
};

const checkHandleResolution = (source: string, result: unknown) => {
  expect(typeof result).toBe('object');

  const { backgroundImage, cardanoAddress, handle, hasDatum, image, policyId, profilePic } = result as HandleResolution;

  expect(['string', 'undefined']).toContain(typeof backgroundImage);
  expect(typeof cardanoAddress).toBe('string');
  expect(cardanoAddress.startsWith('addr_')).toBe(true);
  expect(handle).toBe(source);
  expect(typeof hasDatum).toBe('boolean');
  expect(typeof image).toBe('string');
  expect(policyId).toBe(handlePolicyId);
  expect(['string', 'undefined']).toContain(typeof profilePic);
};

describe('KoraLabsHandleProvider', () => {
  let axiosMock: MockAdapter;
  let provider: KoraLabsHandleProvider;

  beforeAll(() => {
    axiosMock = new MockAdapter(axios);
    provider = new KoraLabsHandleProvider(config);
  });

  afterEach(() => {
    axiosMock.reset();
  });

  afterAll(() => {
    axiosMock.restore();
  });

  describe('resolveHandles', () => {
    test('HandleProvider should resolve a single handle', async () => {
      axiosMock.onGet().replyOnce(200, test_handle_1);

      const [result] = await provider.resolveHandles({ handles: ['test_handle_1'] });

      checkHandleResolution('test_handle_1', result);
    });

    test('HandleProvider should resolve multiple handles', async () => {
      axiosMock.onGet().replyOnce(200, test_handle_1).onGet().replyOnce(200, test_handle_2);

      const [result1, result2] = await provider.resolveHandles({ handles: ['test_handle_1', 'test_handle_2'] });

      checkHandleResolution('test_handle_1', result1);
      checkHandleResolution('test_handle_2', result2);
    });

    test('HandleProvider should return null for for not found handle', async () => {
      axiosMock.onGet().replyOnce(404).onGet().replyOnce(200, test_handle_1);

      const [resultN, result1] = await provider.resolveHandles({ handles: ['does_not_exists', 'test_handle_1'] });

      expect(resultN).toBe(null);
      checkHandleResolution('test_handle_1', result1);
    });

    test('HandleProvider should resolve handle, subhandles and virtual subhandles', async () => {
      axiosMock
        .onGet()
        .replyOnce(200, handle_)
        .onGet()
        .replyOnce(200, ada_handle)
        .onGet()
        .replyOnce(200, space_ada_handle);

      const [result1, result2, result3] = await provider.resolveHandles({
        handles: ['handle', 'ada.handle', 'space@ada.handle']
      });

      checkHandleResolution('handle', result1);
      checkHandleResolution('ada.handle', result2);
      checkHandleResolution('space@ada.handle', result3);
    });
  });

  describe('health checks', () => {
    test('HandleProvider should get ok health check', async () => {
      axiosMock.onGet().replyOnce(200);

      const result = await provider.healthCheck();

      expect(result.ok).toEqual(true);
    });
  });

  describe('get policy ids', () => {
    test('HandleProvider should get handle policy ids', async () => {
      const policyIds = await provider.getPolicyIds();

      expect(policyIds.length).toEqual(1);
      expect(policyIds).toEqual([config.policyId]);
    });
  });
});
