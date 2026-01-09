type chain = {
  name: string,
  tier: string,
  chain_id: int,
  ecosystem: string,
  additional_features: option<array<string>>,
}

let defaultChains: array<chain>
let chainSupportsTraces: chain => bool

@react.component
let make: (
  ~selectedChainName: option<string>,
  ~onChainSelect: string => unit,
  ~customUrl: option<string>,
  ~onCustomUrlChange: option<string => unit>,
) => React.element
