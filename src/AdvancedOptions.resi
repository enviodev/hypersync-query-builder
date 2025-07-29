@react.component
let make: (
  ~query: QueryStructure.query,
  ~onQueryChange: QueryStructure.query => unit,
) => React.element
