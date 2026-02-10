@react.component
let make: (
  ~query: QueryStructure.query,
  ~selectedChainName: option<string>,
  ~executeSignal: int,
  ~bearerToken: option<string>,
  ~customUrl: option<string>,
  ~availableChains: array<ChainSelector.chain>,
) => React.element
