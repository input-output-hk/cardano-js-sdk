export const hexStringToBuffer = (hex: string) => Buffer.from(hex, 'hex');

export const bufferToHexString = (bytes: Buffer) => bytes.toString('hex');
