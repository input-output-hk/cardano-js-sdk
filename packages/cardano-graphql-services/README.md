# Cardano JS SDK | Cardano GraphQL Services

## Server-side usage

This package:

1. Generates GraphQL SDL schema from TypeScript types (`yarn build:schema`, also part of `yarn build`) `=> dist/schema.graphql`
2. Generates Dgraph schema (`yarn build:schema:dgraph`; requires local dgraph server running at port 8080, see [docker-compose.yml](./docker-compose.yml)) `=> dist/dgraph.graphql`

## Tests

See [code coverage report]

[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cardano-graphql-services
