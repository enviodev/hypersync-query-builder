@react.component
let make: (
  ~query: QueryStructure.query,
  ~selectedChainName: option<string>,
  ~executeSignal: int,
  ~bearerToken: option<string>,
  ~customUrl: option<string>,
) => React.element
