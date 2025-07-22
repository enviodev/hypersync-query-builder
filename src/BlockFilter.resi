// Interface for the BlockFilter component
type blockFilterState = QueryStructure.blockSelection

@react.component
let make: (
  ~filterState: blockFilterState,
  ~onFilterChange: blockFilterState => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int
) => React.element 
