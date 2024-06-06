import * as Cardano from '../../../src/Cardano/index.js';

describe('portfolioMetadataFromCip17', () => {
  const poolIds: Cardano.PoolId[] = [
    Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
    Cardano.PoolId('pool1t9xlrjyk76c96jltaspgwcnulq6pdkmhnge8xgza8ku7qvpsy9r'),
    Cardano.PoolId('pool1la4ghj4w4f8p4yk4qmx0qvqmzv6592ee9rs0vgla5w6lc2nc8w5')
  ];

  const portfolio = {
    // eslint-disable-next-line sonarjs/no-duplicate-string
    name: 'Tests Portfolio',
    pools: [
      {
        id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
        name: 'A',
        ticker: 'At',
        weight: 1
      },
      {
        id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
        name: 'B',
        ticker: 'Bt',
        weight: 1
      },
      {
        id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
        name: 'C',
        ticker: 'Ct',
        weight: 1
      }
    ]
  };

  it('can get portfolio metadata from CIP-17', () => {
    const portfolioMetadata = Cardano.portfolioMetadataFromCip17(portfolio);

    expect(portfolioMetadata).toEqual({
      name: 'Tests Portfolio',
      pools: [
        {
          id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
          weight: 1
        },
        {
          id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
          weight: 1
        },
        {
          id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
          weight: 1
        }
      ]
    });
  });

  it('can get portfolio metadata from CIP-17', () => {
    const metadatum: Cardano.Metadatum = new Map<Cardano.Metadatum, Cardano.Metadatum>([
      ['name', 'Tests Portfolio'],
      [
        'pools',
        [
          new Map<Cardano.Metadatum, Cardano.Metadatum>([
            ['id', Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0]))],
            ['weight', 1n]
          ]),
          new Map<Cardano.Metadatum, Cardano.Metadatum>([
            ['id', Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1]))],
            ['weight', 1n]
          ]),
          new Map<Cardano.Metadatum, Cardano.Metadatum>([
            ['id', Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2]))],
            ['weight', 1n]
          ])
        ]
      ]
    ]);

    const cip17 = Cardano.cip17FromMetadatum(metadatum);
    expect(cip17).toEqual({
      name: 'Tests Portfolio',
      pools: [
        {
          id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
          weight: 1
        },
        {
          id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
          weight: 1
        },
        {
          id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
          weight: 1
        }
      ]
    });
  });
});
