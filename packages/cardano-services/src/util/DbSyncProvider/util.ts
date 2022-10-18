export interface BlockNoModel {
  block_no: number;
}

export const DB_MAX_SAFE_INTEGER = 2_147_483_647;
export const DB_BLOCKS_BEHIND_TOLERANCE = 5;

export const findLastBlockNo = `
    SELECT 
    block_no
    FROM block
    ORDER BY block_no DESC 
    NULLS LAST
    LIMIT 1`;
