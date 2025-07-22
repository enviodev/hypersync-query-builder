// Interface for the TransactionFilter component
type transactionFilterState = QueryStructure.transactionSelection

@react.component
let make: (
  ~filterState: transactionFilterState,
  ~onFilterChange: transactionFilterState => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int
) => React.element 
