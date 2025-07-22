// Interface for the LogFilter component
type filterState = QueryStructure.logSelection

@react.component
let make: (
  ~filterState: filterState,
  ~onFilterChange: filterState => unit,
  ~isExpanded: bool,
  ~onToggleExpanded: unit => unit
) => React.element
