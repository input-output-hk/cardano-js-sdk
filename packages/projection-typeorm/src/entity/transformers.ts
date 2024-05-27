/* eslint-disable @typescript-eslint/no-explicit-any */
import { ValueTransformer } from 'typeorm';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';

export const float: ValueTransformer = {
  from(data: string) {
    return Number.parseFloat(data);
  },
  to(data: number) {
    return data;
  }
};

export const stringBytea: ValueTransformer = {
  from(bytea: Buffer) {
    return bytea.toString('utf8');
  },
  to(str: string) {
    return Buffer.from(str, 'utf8');
  }
};

export const json: ValueTransformer = {
  from(str: string) {
    return JSON.parse(str);
  },
  to(obj: any) {
    return JSON.stringify(obj);
  }
};

export const serializableObj: ValueTransformer = {
  from(obj: any) {
    return fromSerializableObject(obj);
  },
  to(obj: any) {
    return toSerializableObject(obj);
  }
};

export const sanitizeString: ValueTransformer = {
  from(obj: any) {
    return obj;
  },
  to(obj: any) {
    if (typeof obj !== 'string') return obj;
    return obj.replace(/\0/g, '');
  }
};

export const parseBigInt: ValueTransformer = {
  from(obj: unknown) {
    return typeof obj === 'string' ? BigInt(obj) : obj;
  },
  to(obj: any) {
    // It can also be a FindOperator object
    return typeof obj === 'bigint' ? obj.toString() : obj;
  }
};
