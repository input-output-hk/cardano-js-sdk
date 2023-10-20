/** Edwards 25519 test vector. */
export interface Ed25519TestVector {
  /** The secret key in hexadecimal representation. */
  secretKey: string;
  /** The public key in hexadecimal representation. */
  publicKey: string;

  /** The Blake2b hash of the public key. */
  publicKeyHash: string;

  /** The message to be signed in hexadecimal representation. */
  message: string;
  /** The signature in hexadecimal representation. */
  signature: string;
}

/** BIP-32 Ed25519 test vector. */
export interface Bip32Ed25519TestVector {
  /** The BIP39 entropy generated from a set of mnemonic words. */
  bip39Entropy: string;

  /** Root BIP32 root private key. */
  rootKey: string;

  /** Root BIP32 root public key. */
  publicKey: string;

  /** The BIP32 derived chlid private key. */
  childPrivateKey: string;

  /** The BIP32 derived child public key. */
  childPublicKey: string;

  /** The 2-factor authentication password. */
  password: string;

  /** The BIP32 index chain that derived the extended keys. */
  derivationPath: number[];

  /** The Edwards 25519 extended vector. */
  ed25519eVector: Ed25519TestVector;
}

export const InvalidSignature =
  '00000000c360ac729086e2cc806e828a' +
  '84877f1000000074d873e06522490155' +
  '5fb8821590a33b00000000701cf9b46b' +
  'd25bf5f0595bbe246551410000000000';

// These test vectors for non extended keys were taken from https://www.rfc-editor.org/rfc/rfc8032#page-23 and added the
// public key Blake2b key hashes.
export const testVectorMessageZeroLength: Ed25519TestVector = {
  message: '',
  publicKey: 'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
  publicKeyHash: '35dedd2982a03cf39e7dce03c839994ffdec2ec6b04f1cf2d40e61a3',
  secretKey: '9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60',
  signature:
    'e5564300c360ac729086e2cc806e828a' +
    '84877f1eb8e5d974d873e06522490155' +
    '5fb8821590a33bacc61e39701cf9b46b' +
    'd25bf5f0595bbe24655141438e7a100b'
};

export const testVectorMessageOneLength: Ed25519TestVector = {
  message: '72',
  publicKey: '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c',
  publicKeyHash: '977efb35ab621d39dbeb7274ec7795a34708ff4d25a01a1df04c1f27',
  secretKey: '4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb',
  signature:
    '92a009a9f0d4cab8720e820b5f642540' +
    'a2b27b5416503f8fb3762223ebdb69da' +
    '085ac1e43e15996e458f3613d0f11d8c' +
    '387b2eaeb4302aeeb00d291612bb0c00'
};

export const testVectorMessageTwoLength: Ed25519TestVector = {
  message: 'af82',
  publicKey: 'fc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025',
  publicKeyHash: '7f8a76c0ebaa4ad20dfdcd51a5de070ab771f4bf377f2c41e6b71c0a',
  secretKey: 'c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7',
  signature:
    '6291d657deec24024827e69c3abe01a3' +
    '0ce548a284743a445e3680d7db5ac3ac' +
    '18ff9b538d16f290ae67f760984dc659' +
    '4a7c15e9716ed28dc027beceea1ec40a'
};

export const testVectorMessage1023Length: Ed25519TestVector = {
  message:
    '08b8b2b733424243760fe426a4b54908' +
    '632110a66c2f6591eabd3345e3e4eb98' +
    'fa6e264bf09efe12ee50f8f54e9f77b1' +
    'e355f6c50544e23fb1433ddf73be84d8' +
    '79de7c0046dc4996d9e773f4bc9efe57' +
    '38829adb26c81b37c93a1b270b20329d' +
    '658675fc6ea534e0810a4432826bf58c' +
    '941efb65d57a338bbd2e26640f89ffbc' +
    '1a858efcb8550ee3a5e1998bd177e93a' +
    '7363c344fe6b199ee5d02e82d522c4fe' +
    'ba15452f80288a821a579116ec6dad2b' +
    '3b310da903401aa62100ab5d1a36553e' +
    '06203b33890cc9b832f79ef80560ccb9' +
    'a39ce767967ed628c6ad573cb116dbef' +
    'efd75499da96bd68a8a97b928a8bbc10' +
    '3b6621fcde2beca1231d206be6cd9ec7' +
    'aff6f6c94fcd7204ed3455c68c83f4a4' +
    '1da4af2b74ef5c53f1d8ac70bdcb7ed1' +
    '85ce81bd84359d44254d95629e9855a9' +
    '4a7c1958d1f8ada5d0532ed8a5aa3fb2' +
    'd17ba70eb6248e594e1a2297acbbb39d' +
    '502f1a8c6eb6f1ce22b3de1a1f40cc24' +
    '554119a831a9aad6079cad88425de6bd' +
    'e1a9187ebb6092cf67bf2b13fd65f270' +
    '88d78b7e883c8759d2c4f5c65adb7553' +
    '878ad575f9fad878e80a0c9ba63bcbcc' +
    '2732e69485bbc9c90bfbd62481d9089b' +
    'eccf80cfe2df16a2cf65bd92dd597b07' +
    '07e0917af48bbb75fed413d238f5555a' +
    '7a569d80c3414a8d0859dc65a46128ba' +
    'b27af87a71314f318c782b23ebfe808b' +
    '82b0ce26401d2e22f04d83d1255dc51a' +
    'ddd3b75a2b1ae0784504df543af8969b' +
    'e3ea7082ff7fc9888c144da2af58429e' +
    'c96031dbcad3dad9af0dcbaaaf268cb8' +
    'fcffead94f3c7ca495e056a9b47acdb7' +
    '51fb73e666c6c655ade8297297d07ad1' +
    'ba5e43f1bca32301651339e22904cc8c' +
    '42f58c30c04aafdb038dda0847dd988d' +
    'cda6f3bfd15c4b4c4525004aa06eeff8' +
    'ca61783aacec57fb3d1f92b0fe2fd1a8' +
    '5f6724517b65e614ad6808d6f6ee34df' +
    'f7310fdc82aebfd904b01e1dc54b2927' +
    '094b2db68d6f903b68401adebf5a7e08' +
    'd78ff4ef5d63653a65040cf9bfd4aca7' +
    '984a74d37145986780fc0b16ac451649' +
    'de6188a7dbdf191f64b5fc5e2ab47b57' +
    'f7f7276cd419c17a3ca8e1b939ae49e4' +
    '88acba6b965610b5480109c8b17b80e1' +
    'b7b750dfc7598d5d5011fd2dcc5600a3' +
    '2ef5b52a1ecc820e308aa342721aac09' +
    '43bf6686b64b2579376504ccc493d97e' +
    '6aed3fb0f9cd71a43dd497f01f17c0e2' +
    'cb3797aa2a2f256656168e6c496afc5f' +
    'b93246f6b1116398a346f1a641f3b041' +
    'e989f7914f90cc2c7fff357876e506b5' +
    '0d334ba77c225bc307ba537152f3f161' +
    '0e4eafe595f6d9d90d11faa933a15ef1' +
    '369546868a7f3a45a96768d40fd9d034' +
    '12c091c6315cf4fde7cb68606937380d' +
    'b2eaaa707b4c4185c32eddcdd306705e' +
    '4dc1ffc872eeee475a64dfac86aba41c' +
    '0618983f8741c5ef68d3a101e8a3b8ca' +
    'c60c905c15fc910840b94c00a0b9d0',
  publicKey: '278117fc144c72340f67d0f2316e8386ceffbf2b2428c9c51fef7c597f1d426e',
  publicKeyHash: '3fa478a09cf841058b3e63abe2cfc50aac0ea46d84eaa50a6ae5accc',
  secretKey: 'f5e5767cf153319517630f226876b86c8160cc583bc013744c6bf255f5cc0ee5',
  signature:
    '0aab4c900501b3e24d7cdf4663326a3a' +
    '87df5e4843b2cbdb67cbf6e460fec350' +
    'aa5371b1508f9f4528ecea23c436d94b' +
    '5e8fcd4f681e30a6ac00a9704a188a03'
};

export const testVectorMessageShaOfAbc: Ed25519TestVector = {
  message:
    'ddaf35a193617abacc417349ae204131' +
    '12e6fa4e89a97ea20a9eeee64b55d39a' +
    '2192992a274fc1a836ba3c23a3feebbd' +
    '454d4423643ce80e2a9ac94fa54ca49f',
  publicKey: 'ec172b93ad5e563bf4932c70e1245034c35467ef2efd4d64ebf819683467e2bf',
  publicKeyHash: '04914a5d895b6ecb480359279b0ab415a06363dbe2c8c4b9dcaa2f29',
  secretKey: '833fe62409237b9d62ec77587520911e9a759cec1d19755b7da901b96dca3d42',
  signature:
    'dc2a4459e7369633a52b1bf277839a00' +
    '201009a3efbf3ecb69bea2186c26b589' +
    '09351fc9ac90b3ecfdfbc7c66431e030' +
    '3dca179c138ac17ad9bef1177331a704'
};

export const vectors = [
  testVectorMessageZeroLength,
  testVectorMessageOneLength,
  testVectorMessageTwoLength,
  testVectorMessage1023Length,
  testVectorMessageShaOfAbc
];

// This test vectors for extended keys were created using https://github.com/dcSpark/cardano-multiplatform-lib

/**
 * Hardens the given index.
 *
 * @param num The index to be hardened.
 */
const harden = (num: number): number => 0x80_00_00_00 + num;

export const bip32TestVectorMessageShaOfAbc: Bip32Ed25519TestVector = {
  bip39Entropy: 'f07e8b397c93a16c06f83c8f0c1a1866477c6090926445fc0cb1201228ace6e9',
  childPrivateKey:
    '3809937b61bd4f180a1e9bd15237e7bc20e36b9037dd95ef60d84f6004758250' +
    'a22e1bfc0d81e9adb7760bcba7f5214416b3e9f27c8d58794a3a7fead2d5b695' +
    '8d515cb54181fb2f5fc3af329e80949c082fb52f7b07e359bd7835a6762148bf',
  childPublicKey:
    'b857a8cd1dbbfed1824359d9d9e58bc8ffb9f66812b404f4c6ffc315629835bf' +
    '9db12d11a3559131a47f51f854a6234725ab8767d3fcc4c9908be55508f3c712',
  derivationPath: [harden(1852), harden(1815), harden(0)],
  ed25519eVector: {
    message:
      'ddaf35a193617abacc417349ae204131' +
      '12e6fa4e89a97ea20a9eeee64b55d39a' +
      '2192992a274fc1a836ba3c23a3feebbd' +
      '454d4423643ce80e2a9ac94fa54ca49f',
    publicKey: '311f8914b8934efbe7cbb8cc4745853de12e8ea402df6f9f69b18d2792c6bed8',
    publicKeyHash: 'ebf46bc374bda5b937d4d964fc0b73e940a9ea7d8cfdf39162a6f207',
    secretKey:
      'a0ab55b174ba8cd95e2362d035f377b4' +
      'dc779a0fae65767e3b8dd790fa748250' +
      'f3ef2cc372c207d7902607ffef01872a' +
      '4c785cd27e7342de7f4332f2d5fdc3a8',
    signature:
      '843aa4353184193bdf01aab7f636ac53' +
      'f86746dd97a2a2e01fe7923c37bfec40' +
      'b68a73881a26ba57dc974abc1123d086' +
      '6b542a5447e03677134a8f4e1db2bc0c'
  },
  password: '',
  publicKey:
    '311f8914b8934efbe7cbb8cc4745853d' +
    'e12e8ea402df6f9f69b18d2792c6bed8' +
    'd0c110e1d6a061d3558eb6a3138a3982' +
    '253c6616e1bf4d8bd31e92de8328affe',
  rootKey:
    'a0ab55b174ba8cd95e2362d035f377b4' +
    'dc779a0fae65767e3b8dd790fa748250' +
    'f3ef2cc372c207d7902607ffef01872a' +
    '4c785cd27e7342de7f4332f2d5fdc3a8' +
    'd0c110e1d6a061d3558eb6a3138a3982' +
    '253c6616e1bf4d8bd31e92de8328affe'
};

export const bip32TestVectorMessageOneLength: Bip32Ed25519TestVector = {
  bip39Entropy: 'caec96d09fc2020ab230199e0188cd6a554e2da2cba32de9ff6c0908c7f04d65',
  childPrivateKey:
    'd0d3ddf972ca055ca7fe5703ebb03201128c2c5a93a0d9350bd7a65f2e1d045f' +
    'fc5fc40c42a98fab3a4afa2d31eef5e1e85d982ca3dccafb364aa2ef369c3e09' +
    'ee2372d821e7b4d95f2cb0cd7fa53d5620c952864ed931f7bc9d390e17fb39f4',
  childPublicKey:
    'b857a8cd1dbbfed1824359d9d9e58bc8ffb9f66812b404f4c6ffc315629835bf' +
    '9db12d11a3559131a47f51f854a6234725ab8767d3fcc4c9908be55508f3c712',
  derivationPath: [harden(1852), harden(1815), harden(1)],
  ed25519eVector: {
    message: '72',
    publicKey: 'ba4f80dea2632a17c99ae9d8b934abf02643db5426b889fef14709c85e294aa1',
    publicKeyHash: '2a6383e079acd8e32b7e56a53f5749d5c8da260170d8306a0a716024',
    secretKey:
      '60292301b8dd20a74b58a0bd4ecdeb24' +
      '4a95e757c7a2d25962ada75e271d045f' +
      'f827c85a5530bfe76975b4189c5fd6d3' +
      '2d4fe43c81373f386fde2fa0e6d0255a',
    signature:
      'c1d21c78e17c62a7536bb791dbac908a' +
      'd8f3c6c6a9f0634d3fcad1286d31ebdc' +
      '5aacdb7ccb7c4d02c192266f0088d570' +
      'e566a3e2203a75803aea72595332ca05'
  },
  password: 'some_password_@#$%^&',
  publicKey:
    'ba4f80dea2632a17c99ae9d8b934abf0' +
    '2643db5426b889fef14709c85e294aa1' +
    '2ac1f1560a893ea7937c5bfbfdeab459' +
    'b1a396f1174b9c5a673a640d01880c35',
  rootKey:
    '60292301b8dd20a74b58a0bd4ecdeb24' +
    '4a95e757c7a2d25962ada75e271d045f' +
    'f827c85a5530bfe76975b4189c5fd6d3' +
    '2d4fe43c81373f386fde2fa0e6d0255a' +
    '2ac1f1560a893ea7937c5bfbfdeab459' +
    'b1a396f1174b9c5a673a640d01880c35'
};

export const bip32TestVectorMessageShaOfAbcUnhardened: Bip32Ed25519TestVector = {
  bip39Entropy: 'be9ffd296c0ccabadf51c6fbb904995b182d6ac84181c08d8b016ab1eefd78ce',
  childPrivateKey:
    '08f9d7de597d31fade994b8a1e9d3e3afe53ac8393297e8f4d96225d72586951' +
    '7ae54c631588abb408fcab0676a4da6b60c82b3a3d7045a26a576c7901e5e957' +
    '9db12d11a3559131a47f51f854a6234725ab8767d3fcc4c9908be55508f3c712',
  childPublicKey:
    'b857a8cd1dbbfed1824359d9d9e58bc8ffb9f66812b404f4c6ffc315629835bf' +
    '9db12d11a3559131a47f51f854a6234725ab8767d3fcc4c9908be55508f3c712',
  derivationPath: [1852, 1815, 0], // Non hardened.
  ed25519eVector: {
    message:
      'ddaf35a193617abacc417349ae204131' +
      '12e6fa4e89a97ea20a9eeee64b55d39a' +
      '2192992a274fc1a836ba3c23a3feebbd' +
      '454d4423643ce80e2a9ac94fa54ca49f',
    publicKey: '6fd8d9c696b01525cc45f15583fc9447c66e1c71fd1a11c8885368404cd0a4ab',
    publicKeyHash: 'b79e58495d0aabbe068cde6cef2c6659eca348950ff9966510c90cee',
    secretKey:
      'd8287e922756977dc0b79659e6eebcae' +
      '3a1fb29a22ce1449c94f125462586951' +
      '390af99a0350130451e9bf4f4691f37c' +
      '352dc7025d52d9132f61a82f61d3803d',
    signature:
      'f363d78e0a315ae1fc0ceb6b8efdd163' +
      '1a3a2ce16f6cf43f596ff92c4a7b2926' +
      '39c6e352cc24efcf80ccea39cbdb7ec9' +
      'a02f4a5b332afc2de7f7a2e65e67780e'
  },
  password: '',
  publicKey:
    '6fd8d9c696b01525cc45f15583fc9447' +
    'c66e1c71fd1a11c8885368404cd0a4ab' +
    '00b5f1652f5cbe257e567c883dc2b16e' +
    '0a9568b19c5b81ea8bd197fc95e8bdcf',
  rootKey:
    'd8287e922756977dc0b79659e6eebcae' +
    '3a1fb29a22ce1449c94f125462586951' +
    '390af99a0350130451e9bf4f4691f37c' +
    '352dc7025d52d9132f61a82f61d3803d' +
    '00b5f1652f5cbe257e567c883dc2b16e' +
    '0a9568b19c5b81ea8bd197fc95e8bdcf'
};

export const extendedVectors = [
  bip32TestVectorMessageShaOfAbc,
  bip32TestVectorMessageOneLength,
  bip32TestVectorMessageShaOfAbcUnhardened
];
