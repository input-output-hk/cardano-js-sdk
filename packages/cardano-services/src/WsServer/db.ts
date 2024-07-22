// cSpell:ignore plpgsql proname prosrc tgfoid tgname

import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Pool } from 'pg';

const notifyTipBody = `\
BEGIN
  PERFORM PG_NOTIFY('sdk_tip', JSON_BUILD_OBJECT(
    'blockId', NEW.id,
    'blockNo', NEW.block_no,
    'hash',    ENCODE(NEW.hash, 'hex'),
    'slot',    NEW.slot_no
  )::TEXT);
  RETURN NEW;
END;`;

const notifyTipProcedure = `\
CREATE OR REPLACE FUNCTION sdk_notify_tip()
RETURNS TRIGGER AS
$BODY$${notifyTipBody}$BODY$
LANGUAGE plpgsql`;

const notifyTipTrigger = `\
CREATE TRIGGER sdk_notify_tip
AFTER INSERT ON block
FOR EACH ROW EXECUTE PROCEDURE sdk_notify_tip();`;

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export const initDB = async (db: Pool, logger: Logger) => {
  logger.info('Initializing the DB...');

  // Wait for the schema is ready
  let epochs: number;
  do {
    // Workaround to make this wait for epoch 1.
    // Once db-sync will solve this problem we can check only for one block.
    logger.debug('Checking for an epoch...');
    const { rows } = await db.query<{ epochs: number }>('SELECT COUNT(*) AS epochs FROM epoch');
    epochs = rows[0].epochs;
    if (epochs < 2) await sleep(2000);
  } while (epochs < 2);

  logger.debug('Checking for sdk_notify_tip stored procedure...');
  const procedure = await db.query<{ prosrc: string }>("SELECT prosrc FROM pg_proc WHERE proname = 'sdk_notify_tip'");

  if (procedure.rows.length !== 1 || procedure.rows[0].prosrc !== notifyTipBody) {
    logger.debug('Creating or replacing sdk_notify_tip stored procedure...');
    await db.query(notifyTipProcedure);
  }

  logger.debug('Checking for sdk_notify_tip trigger...');
  const trigger = await db.query<{ proname: string }>(
    "SELECT proname FROM pg_trigger LEFT JOIN pg_proc ON tgfoid = pg_proc.oid WHERE tgname = 'sdk_notify_tip'"
  );

  if (trigger.rows.length !== 1 || trigger.rows[0].proname !== 'sdk_notify_tip') {
    if (trigger.rows.length === 1) {
      logger.debug('Dropping wrong sdk_notify_tip trigger...');
      await db.query('DROP TRIGGER sdk_notify_tip ON block');
    }

    logger.debug('Creating sdk_notify_tip trigger...');
    await db.query(notifyTipTrigger);
  }

  logger.debug('Checking for latest block...');
  const { rows } = await db.query<Cardano.Tip>(
    'SELECT block_no AS "blockNo", encode(hash, \'hex\') AS hash, slot_no::INTEGER AS slot FROM block WHERE block_no = (SELECT MAX(block_no) FROM block)'
  );

  return rows[0];
};
