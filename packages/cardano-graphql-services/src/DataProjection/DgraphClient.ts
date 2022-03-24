import { RunnableModule } from '../RunnableModule';
import { Upsert, LastBlockQuery } from './types';
import { dummyLogger } from 'ts-log';
import { exponentialBackoff } from '../util';
import { gql, request } from 'graphql-request';
import dgraph from 'dgraph-js';

export interface DgraphClientAddresses {
  grpc: string;
  http: string;
}
export class DgraphClient extends RunnableModule {
  #clientStub: dgraph.DgraphClientStub;
  #dgraphClient: dgraph.DgraphClient;

  constructor(public addresses: DgraphClientAddresses, logger = dummyLogger) {
    super('DgraphClient', logger);
    this.#clientStub = new dgraph.DgraphClientStub(addresses.grpc);
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
    await request(`${this.addresses.http}/admin`, query, { sch: schema });
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
      // eslint-disable-next-line sonarjs/prefer-immediate-return
      const rsp = await fn();
      return rsp;
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

  private async runLastBlockQuery(tx: dgraph.Txn) {
    const query = `{
      latestBlock(func: type(Block), orderdesc: blockNo, first: 1) {
        hash,
        slot {
          number
        }
      }
    }`;
    const response = await tx.query(query);
    await tx.commit();
    return response.getJson() as LastBlockQuery;
  }

  async writeDataFromBlock(upsert: Upsert, txn: dgraph.Txn) {
    await this.runDgraphTransaction(txn, async () => {
      const mu = new dgraph.Mutation();
      mu.setSetJson(upsert.mutations);
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
    const tx = await this.#dgraphClient.newTxn();
    try {
      return await this.runLastBlockQuery(tx);
    } catch (error) {
      if (error === dgraph.ERR_ABORTED) {
        return await exponentialBackoff(this.runLastBlockQuery(tx));
      } else if (
        // FIXME: when running a zero percentage synched instance this error is thrown
        error?.code !== 2
      ) {
        throw error;
      }
    } finally {
      await tx.discard();
    }
  }
}
