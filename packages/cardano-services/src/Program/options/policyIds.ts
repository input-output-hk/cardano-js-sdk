import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import { addOptions, newOption } from './util.js';
import { readFile } from 'fs/promises';
import type { Command } from 'commander';

const handlePolicyIdsParser = (policyIds: string) => policyIds.split(',').map(Cardano.PolicyId);

export enum HandlePolicyIdsOptionDescriptions {
  HandlePolicyIds = 'Handle policy Ids',
  HandlePolicyIdsFile = 'Handle policy Ids file'
}

export interface HandlePolicyIdsProgramOptions {
  handlePolicyIds: Cardano.PolicyId[];
  handlePolicyIdsFile?: string;
}

export const handlePolicyIdsFromFile = async (args: HandlePolicyIdsProgramOptions) => {
  const { handlePolicyIdsFile } = args;

  if (!handlePolicyIdsFile) return;

  args.handlePolicyIds = handlePolicyIdsParser(
    (await readFile(handlePolicyIdsFile, { encoding: 'utf8' })).replace(/\s/g, '')
  );
};

export const withHandlePolicyIdsOptions = (command: Command, maxPolicyIdsSupported?: number) =>
  addOptions(command, [
    newOption(
      '--handle-policy-ids <handlePolicyIds>',
      HandlePolicyIdsOptionDescriptions.HandlePolicyIds,
      'HANDLE_POLICY_IDS',
      (policyIds: string) => {
        const policyIdsArray = handlePolicyIdsParser(policyIds);

        if (maxPolicyIdsSupported && policyIdsArray.length > maxPolicyIdsSupported)
          throw new NotImplementedError(`${policyIdsArray.length} policyIds are not supported`);

        return policyIdsArray;
      }
    ),
    newOption(
      '--handle-policy-ids-file <handlePolicyIdsFile>',
      HandlePolicyIdsOptionDescriptions.HandlePolicyIdsFile,
      'HANDLE_POLICY_IDS_FILE'
    ).conflicts('handlePolicyIds')
  ]);
