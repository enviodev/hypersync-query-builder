// Interface for the TransactionFilter component
type transactionFilterState = QueryStructure.transactionSelection

@react.component
let make: (
  ~filterState: transactionFilterState,
  ~onFilterChange: transactionFilterState => unit,
  ~isExpanded: bool,
  ~onToggleExpanded: unit => unit
) => React.element 
