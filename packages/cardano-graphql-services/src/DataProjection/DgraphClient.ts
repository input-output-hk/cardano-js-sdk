import { LastBlockQuery, Upsert } from './types';
import { RunnableModule } from '../RunnableModule';
import { dummyLogger } from 'ts-log';
import { exponentialBackoff } from '../util';
import { gql, request } from 'graphql-request';
import dgraph from 'dgraph-js';
export class DgraphClient extends RunnableModule {
  #clientStub: dgraph.DgraphClientStub;
  #dgraphClient: dgraph.DgraphClient;

  constructor(public address: string, logger = dummyLogger) {
    super('DgraphClient', logger);
    this.#clientStub = new dgraph.DgraphClientStub(address);
    this.#dgraphClient = new dgraph.DgraphClient(this.#clientStub);
  }

  async initializeImpl(schema: string): Promise<void> {
    // Issuing the library operation isn't working as expected, so we're using the HTTP API instead
    const query = gql`
      mutation ($sch: String!) {
        updateGQLSchema(input: { set: { schema: $sch } }) {
          gqlSchema {
            generatedSchema
          }
        }
      }
    `;
    await request(`${this.address}/admin`, query, { sch: schema });
    this.logger.debug('Dgraph schema set');
  }

  async shutdownImpl(): Promise<void> {
    await this.#clientStub.close();
  }
  // eslint-disable-next-line @typescript-eslint/no-empty-function
  async startImpl(): Promise<void> {}

  newTxn(): dgraph.Txn {
    return this.#dgraphClient.newTxn();
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  async query(query: string, vars?: { [k: string]: any }): Promise<any> {
    const txn = this.#dgraphClient.newTxn();
    const response = await txn.queryWithVars(query, vars);
    return response.getJson();
  }

  private async runDgraphTransaction(txn: dgraph.Txn, fn: Function) {
    try {
      return fn();
    } catch (error) {
      if (error === dgraph.ERR_ABORTED) {
        await exponentialBackoff(fn());
      } else {
        throw error;
      }
    } finally {
      await txn.discard();
    }
  }

  private async runUpsertBlockFromMutations(upsert: Upsert, txn: dgraph.Txn, mutations: dgraph.Mutation[]) {
    const req = new dgraph.Request();
    req.setMutationsList(mutations);
    if (upsert.variables?.dql) {
      req.setQuery(upsert.variables?.dql);
    }
    await txn.doRequest(req);
    await txn.commit();
  }

  async writeDataFromBlock(upsert: Upsert, txn: dgraph.Txn) {
    await this.runDgraphTransaction(txn, async () => {
      const mu = new dgraph.Mutation();
      mu.setSetJson(upsert);
      await this.runUpsertBlockFromMutations(upsert, txn, [mu]);
    });
  }

  async deleteDataAfterSlot(upsert: Upsert, txn: dgraph.Txn) {
    await this.runDgraphTransaction(txn, async () => {
      const mu = new dgraph.Mutation();
      mu.setDeleteJson(upsert.mutations);
      await this.runUpsertBlockFromMutations(upsert, txn, [mu]);
    });
  }

  async getLastBlock() {
    const tx = await this.#dgraphClient.newTxn({ readOnly: true });
    return this.runDgraphTransaction(tx, async () => {
      const query = `query {
      queryBlock(order: {desc: blockNo}, first: 1) {
        hash,
        slot {
          number
        }
      }
    }`;
      const response = await tx.query(query);
      return response.getJson();
    }) as Promise<LastBlockQuery>;
  }
}
