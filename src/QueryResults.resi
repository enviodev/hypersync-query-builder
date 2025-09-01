@react.component
let make: (
  ~query: QueryStructure.query,
  ~selectedChainName: option<string>,
  ~executeSignal: int,
) => React.element
