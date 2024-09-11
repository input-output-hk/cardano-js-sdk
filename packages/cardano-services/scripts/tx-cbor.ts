import { Pool } from 'pg';
import { readFileSync } from 'fs';
import { spawnSync } from 'child_process';
import WebSocket from 'ws';

interface Tx {
  cbor: string;
  id: string;
}

const txId = process.argv[2];

const normalizeError = (status: number | null, stderr: string) =>
  [status || 1, stderr || 'Unknown error\n', ''] as const;

const inside = async () => {
  const db = new Pool({
    database: readFileSync(process.env.POSTGRES_DB_FILE_DB_SYNC!).toString(),
    host: 'postgres',
    password: readFileSync(process.env.POSTGRES_PASSWORD_FILE_DB_SYNC!).toString(),
    user: readFileSync(process.env.POSTGRES_USER_FILE_DB_SYNC!).toString()
  });

  const query = `\
SELECT ENCODE(b2.hash, 'hex') AS id, b2.slot_no::INTEGER AS slot FROM tx
JOIN block b1 ON block_id = b1.id
JOIN block b2 ON b1.previous_id = b2.id
WHERE tx.hash = $1`;

  const { rows } = await db.query(query, [Buffer.from(txId, 'hex')]);
  const [prevBlock] = rows;

  await db.end();

  if (!prevBlock) return [1, `Unknown transaction id ${txId}\n`, ''] as const;

  const cbor = await new Promise<string>((resolve) => {
    const client = new WebSocket(process.env.OGMIOS_URL!);
    let request = 0;

    const rpc = (method: string, params: unknown) =>
      client.send(JSON.stringify({ id: ++request, jsonrpc: '2.0', method, params }));

    client.on('open', () => rpc('findIntersection', { points: [prevBlock] }));

    client.on('message', (msg) => {
      const { result } = JSON.parse(msg.toString()) as { result: { block: { transactions: Tx[] } } };
      let tx: Tx | undefined;

      if (
        result &&
        result.block &&
        result.block.transactions &&
        (tx = result.block.transactions.find((t) => t.id === txId))
      ) {
        client.on('close', () => resolve(tx!.cbor));
        client.close();
      } else rpc('nextBlock', {});
    });
  });

  return [0, '', `${cbor}\n`] as const;
};

const outside = async () => {
  if (!txId) return [1, 'Missing input transaction id\n', ''] as const;

  let { status, stderr, stdout } = spawnSync('docker', ['ps'], { encoding: 'utf-8' });

  if (status || stderr) return normalizeError(status, stderr);

  const container = [
    'cardano-services-mainnet-provider-server-1',
    'cardano-services-preprod-provider-server-1',
    'cardano-services-preview-provider-server-1',
    'cardano-services-sanchonet-provider-server-1',
    'local-network-e2e-provider-server-1'
  ].find((name) => stdout.includes(name));

  if (!container) return [1, "Can't find any valid container\n", ''] as const;

  ({ status, stderr, stdout } = spawnSync(
    'docker',
    ['container', 'exec', '-i', container, 'bash', '-c', `cd /app ; INSIDE_THE_CONTAINER=true yarn tx-cbor ${txId}`],
    { encoding: 'utf-8' }
  ));

  if (status || stderr) return normalizeError(status, stderr);

  return [0, '', stdout] as const;
};

(process.env.INSIDE_THE_CONTAINER ? inside() : outside())
  .then(([status, stderr, stdout]) => {
    if (status) {
      process.stderr.write(stderr);
      // eslint-disable-next-line unicorn/no-process-exit
      process.exit(status);
    }

    process.stdout.write(stdout);
  })
  .catch((error) => {
    throw error;
  });
