import { pbkdf2 } from 'pbkdf2';
import chacha from 'chacha';
import getRandomValues from 'get-random-values';

const KEY_LENGTH = 32;
const NONCE_LENGTH = 12;
const PBKDF2_ITERATIONS = 19_162;
const SALT_LENGTH = 32;
const TAG_LENGTH = 16;
const AAD = Buffer.from('', 'hex');

export const createPbkdf2Key = async (password: Uint8Array, salt: Uint8Array | Uint16Array) =>
  await new Promise<Buffer>((resolve, reject) =>
    pbkdf2(password, salt, PBKDF2_ITERATIONS, KEY_LENGTH, 'sha512', (err, derivedKey) => {
      if (err) return reject(err);
      resolve(derivedKey);
    })
  );

/**
 * https://github.com/Emurgo/EmIPs/blob/master/specs/emip-003.md
 */
export const emip3encrypt = async (data: Uint8Array, password: Uint8Array): Promise<Uint8Array> => {
  const salt = new Uint8Array(SALT_LENGTH);
  getRandomValues(salt);
  const key = await createPbkdf2Key(password, salt);
  const nonce = new Uint8Array(NONCE_LENGTH);
  getRandomValues(nonce);
  const cipher = chacha.createCipher(key, Buffer.from(nonce));
  cipher.setAAD(AAD, { plaintextLength: data.length });
  const head = cipher.update(data);
  const final = cipher.final();
  const tag = cipher.getAuthTag();
  return Buffer.concat([salt, nonce, tag, head, final]);
};

/**
 * https://github.com/Emurgo/EmIPs/blob/master/specs/emip-003.md
 */
export const emip3decrypt = async (encrypted: Uint8Array, password: Uint8Array): Promise<Uint8Array> => {
  const salt = encrypted.slice(0, SALT_LENGTH);
  const nonce = encrypted.slice(SALT_LENGTH, SALT_LENGTH + NONCE_LENGTH);
  const tag = encrypted.slice(SALT_LENGTH + NONCE_LENGTH, SALT_LENGTH + NONCE_LENGTH + TAG_LENGTH);
  const data = encrypted.slice(SALT_LENGTH + NONCE_LENGTH + TAG_LENGTH);
  const key = await createPbkdf2Key(password, salt);
  const decipher = chacha.createDecipher(key, Buffer.from(nonce));
  decipher.setAuthTag(Buffer.from(tag));
  decipher.setAAD(AAD);
  return Buffer.concat([decipher.update(Buffer.from(data)), decipher.final()]);
};
