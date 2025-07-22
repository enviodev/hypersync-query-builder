// Interface for the BlockFilter component
type blockFilterState = QueryStructure.blockSelection

@react.component
let make: (
  ~filterState: blockFilterState,
  ~onFilterChange: blockFilterState => unit,
  ~isExpanded: bool,
  ~onToggleExpanded: unit => unit
) => React.element 
