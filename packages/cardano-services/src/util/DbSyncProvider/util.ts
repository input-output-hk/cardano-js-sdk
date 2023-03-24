export interface LedgerTipModel {
  block_no: number;
  slot_no: string;
  hash: Buffer;
}

export const DB_MAX_SAFE_INTEGER = 2_147_483_647;
export const DB_BLOCKS_BEHIND_TOLERANCE = 5;

export const findLedgerTip = `
SELECT
  block_no, slot_no, hash
FROM block
WHERE
  block_no = (SELECT MAX(block_no) FROM block)`;
