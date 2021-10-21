# Cardano JS SDK | Cardano GraphQL

This package implements StakePoolSearchProvider using GraphQL

## Server-side usage

This package generates GraphQL schema from TypeScript types.

```typescript
// Import this before using DI, or import 'reflect-metadata' before registering services for DI
import { Schema } from '@cardano-sdk/cardano-graphql';
import { GraphQLSchema } from 'graphql';
import { Service } from 'typedi';

// Register services for DI
@Service(Schema.ServiceType.StakePoolSearch)
class StakePoolSearch implements Schema.StakePoolSearchService {
  // Implement the service
}

const schemaBuilt: Promise<GraphQLSchema> = Schema.build();
// Use the schema
```

## Tests

See [code coverage report]

[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cardano-graphql
