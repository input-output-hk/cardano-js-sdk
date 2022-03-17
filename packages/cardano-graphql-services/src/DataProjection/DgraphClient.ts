import { RunnableModule } from '../RunnableModule';
import { Upsert } from './types';
import { dummyLogger } from 'ts-log';
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
    super.shutdownBefore();
    await this.#clientStub.close();
    super.shutdownAfter();
  }
  // eslint-disable-next-line @typescript-eslint/no-empty-function
  async startImpl(): Promise<void> {}

  newTxn(): dgraph.Txn {
    return this.#dgraphClient.newTxn();
  }

  async query(query: string, vars?: { [k: string]: any }): Promise<any> {
    const txn = this.#dgraphClient.newTxn();
    const response = await txn.queryWithVars(query, vars);
    return response.getJson();
  }

  private async runDgraphTransaction(txn: dgraph.Txn, fn: Function) {
    try {
      await fn();
    } catch (error) {
      if (error === dgraph.ERR_ABORTED) {
        // Retry or handle exception.
      } else {
        throw error;
      }
    } finally {
      await txn.discard();
    }
  }

  private async runUpsertBlockFromMutations(upsert: Upsert, txn: dgraph.Txn, mutations: dgraph.Mutation[]) {
    try {
      const req = new dgraph.Request();
      req.setMutationsList(mutations);
      if (upsert.variables?.dql) {
        req.setQuery(upsert.variables?.dql);
      }
      await txn.doRequest(req);
      await txn.commit();
    } catch (error) {
      if (error === dgraph.ERR_ABORTED) {
        // Retry or handle exception.
      } else {
        throw error;
      }
    } finally {
      await txn.discard();
    }
  }

  async writeDataFromBlock(upsert: Upsert, txn: dgraph.Txn) {
    await this.runDgraphTransaction(txn, async () => {
      const mu = new dgraph.Mutation();
      // Todo: Translate our Upsert type
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
}
