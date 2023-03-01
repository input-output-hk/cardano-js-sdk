import * as dotenv from 'dotenv';
import * as envalid from 'envalid';
import { Pool } from 'pg';

dotenv.config();

const setup = async () => {
  const env = envalid.cleanEnv(process.env, { DB_SYNC_CONNECTION_STRING: envalid.str() });
  const db = new Pool({ connectionString: env.DB_SYNC_CONNECTION_STRING });
  const result = await db.query('SELECT view FROM pool_hash');
  process.env.POOLS = JSON.stringify(result.rows.map(({ view }) => view));
  await db.end();
};

export default setup;
