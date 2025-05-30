import { AddressEntity } from '../entity/Address.entity';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEventType, Mappers } from '@cardano-sdk/projection';
import { QueryRunner } from 'typeorm';
import { StakeKeyRegistrationEntity } from '../entity';
import { certificatePointerToId, typeormOperator } from './util';

const lookupStakeKeyRegistration = async (pointer: Cardano.Pointer | undefined, queryRunner: QueryRunner) => {
  if (!pointer) return;
  const registrationId = certificatePointerToId(pointer);
  const stakeKeyRegistration = await queryRunner.manager
    .getRepository(StakeKeyRegistrationEntity)
    .findOne({ select: { stakeKeyHash: true }, where: { id: registrationId } });
  if (!stakeKeyRegistration?.stakeKeyHash) return;
  return stakeKeyRegistration.stakeKeyHash;
};

export const willStoreAddresses = ({ addresses }: Mappers.WithAddresses) => addresses.length > 0;

export const storeAddresses = typeormOperator<Mappers.WithAddresses>(async (evt) => {
  const { addresses, eventType, queryRunner } = evt;
  if (addresses.length === 0 || eventType !== ChainSyncEventType.RollForward) return;
  const addressEntities = await Promise.all(
    addresses.map(async ({ paymentCredentialHash, stakeCredential, address, type }): Promise<AddressEntity> => {
      const stakeCredentialHash =
        typeof stakeCredential === 'string'
          ? stakeCredential
          : await lookupStakeKeyRegistration(stakeCredential, queryRunner);
      return {
        address,
        paymentCredentialHash,
        stakeCredentialHash,
        type
      };
    })
  );
  await queryRunner.manager
    .createQueryBuilder()
    .insert()
    .into(AddressEntity)
    .values(addressEntities)
    .orIgnore()
    .execute();
});
