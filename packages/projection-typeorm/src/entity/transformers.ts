/* eslint-disable @typescript-eslint/no-explicit-any */
import { ValueTransformer } from 'typeorm';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';

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
