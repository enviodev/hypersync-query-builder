type traceFilterState = QueryStructure.traceSelection

@react.component
let make: (
  ~filterState: traceFilterState,
  ~onFilterChange: traceFilterState => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int,
  ~isExpanded: bool,
  ~onToggleExpand: unit => unit,
) => React.element 