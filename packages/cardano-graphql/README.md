# Cardano JS SDK | Cardano GraphQL

This package implements StakePoolSearchProvider using GraphQL

## Server-side usage

This package generates GraphQL schema from TypeScript types.

```typescript
// Import this before using DI, or import 'reflect-metadata' before registering services for DI
import { Schema, StakePoolSearchService } from '@cardano-sdk/cardano-graphql';
import { Service } from 'typedi';

// Register services for DI
@Service(ServiceType.StakePoolSearch)
class StakePoolSearch implements StakePoolSearchService {
  // Implement the service
}

const schemaBuilt: Promise<GraphQLSchema> = Schema.build();
// Use the schema
```

## Tests

See [code coverage report]

[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cardano-graphql
