# SQL profiling

The SQL profiling systems is composed by:

1. [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html) collects SQL queries statistics
2. [pg-agent](https://coroot.com/blog/pg-agent) produces Prometheus view from SQL queries statistics
3. Prometheus serves a UI to access the SQL queries statistics

It is installed in our `docker-compose` infrastructures.

## Starting the SQL profiling system

The profiling systems is included by default in all the `cardano-services` infrastructures while it is optional in the
`e2e` infrastructure to not affect _CI e2e tests_ time.

To start the _local-network_ with the **SQL profiling system** following two commands can be used:

- `yarn local-network:profile:up`
- `yarn local-network:profile:dev`

## Accessing the SQL profiling data

By default the **SQL profiling system** is exposed on port `9090`, configurable through the `PROMETHEUS_PORT`
environment variable.

It takes a while to perform its startup jobs; to check if statistics are actually available, check the
[targets](http://localhost:9090/targets?search=), once the **State** is `UP` everything is ready.

## Example views

- [Top CPU time consuming queries](<http://localhost:9090/graph?g0.expr=topk(10%2C%20pg_top_query_time_per_second)&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=15m>)
- [Top IO time consuming queries](<http://localhost:9090/graph?g0.expr=topk(10%2C%20pg_top_query_io_time_per_second)&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=15m>)
