# Cardano JS SDK | Cardano GraphQL

This package implements StakePoolSearchProvider using GraphQL

## Generate TypeDefs from SDL
These types are used to implement `*Provider` interfaces. Run these commands from the repository 
root if the schema has been modified, and commit the changes.
1. `cd packages/cardano-graphql-services && docker-compose up`
2. `cd packages/cardano-graphql-services && yarn build && yarn build:schema:dgraph`
3. `cd packages/cardano-graphql && yarn build && yarn generate`
4. `cd packages/cardano-graphql-services && docker-compose down`

## Tests

See [code coverage report]

[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cardano-graphql
