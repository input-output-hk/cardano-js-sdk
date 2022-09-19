/**
 * Pagination arguments
 */
export interface PaginationArgs {
  /**
   * Start at
   */
  startAt: number;
  /**
   * Page size
   */
  limit: number;
}

/**
 * Base interface to model a query as paginated
 */
export interface Paginated<TQueryResult> {
  /**
   * Result list per page
   */
  pageResults: TQueryResult[];
  /**
   * Total result count
   */
  totalResultCount: number;
}
