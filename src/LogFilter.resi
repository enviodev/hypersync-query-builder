// Interface for the LogFilter component
type filterState = QueryStructure.logSelection

@react.component
let make: (
  ~filterState: filterState,
  ~onFilterChange: filterState => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int
) => React.element
