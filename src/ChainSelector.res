type chain = {
  name: string,
  tier: string,
  chain_id: int,
  ecosystem: string,
  additional_features: option<array<string>>,
}

let chains = [
  {name: "eth", tier: "GOLD", chain_id: 1, ecosystem: "evm", additional_features: None},
  {name: "base", tier: "GOLD", chain_id: 8453, ecosystem: "evm", additional_features: None},
  {name: "arbitrum", tier: "SILVER", chain_id: 42161, ecosystem: "evm", additional_features: None},
  {name: "optimism", tier: "GOLD", chain_id: 10, ecosystem: "evm", additional_features: None},
  {name: "polygon", tier: "SILVER", chain_id: 137, ecosystem: "evm", additional_features: None},
  {name: "bsc", tier: "BRONZE", chain_id: 56, ecosystem: "evm", additional_features: None},
  {name: "avalanche", tier: "BRONZE", chain_id: 43114, ecosystem: "evm", additional_features: None},
  {name: "gnosis", tier: "GOLD", chain_id: 100, ecosystem: "evm", additional_features: None},
  {name: "sepolia", tier: "TESTNET", chain_id: 11155111, ecosystem: "evm", additional_features: None},
  {name: "base-sepolia", tier: "TESTNET", chain_id: 84532, ecosystem: "evm", additional_features: None},
  {name: "arbitrum-sepolia", tier: "TESTNET", chain_id: 421614, ecosystem: "evm", additional_features: None},
  {name: "optimism-sepolia", tier: "TESTNET", chain_id: 11155420, ecosystem: "evm", additional_features: None},
]

let getTierColor = (tier: string) => {
  switch tier {
  | "GOLD" => "bg-yellow-100 text-yellow-800 border-yellow-200"
  | "SILVER" => "bg-gray-100 text-gray-800 border-gray-200"
  | "BRONZE" => "bg-orange-100 text-orange-800 border-orange-200"
  | "TESTNET" => "bg-red-100 text-red-800 border-red-200"
  | _ => "bg-blue-100 text-blue-800 border-blue-200"
  }
}

let getEcosystemIcon = (ecosystem: string) => {
  switch ecosystem {
  | "fuel" => "🔥"
  | _ => "⚡"
  }
}

@react.component
let make = (~selectedChainId: option<int>, ~onChainSelect: int => unit) => {
  let (searchTerm, setSearchTerm) = React.useState(() => "")

  let filteredChains = chains->Array.filter(chain => {
    searchTerm === "" || 
    String.includes(String.toLowerCase(chain.name), String.toLowerCase(searchTerm)) ||
    String.includes(String.toLowerCase(chain.tier), String.toLowerCase(searchTerm))
  })

  let selectedChain = selectedChainId->Option.flatMap(chainId => 
    chains->Array.find(chain => chain.chain_id === chainId)
  )

  <div className="bg-white rounded-lg shadow p-6 mb-8">
    <div className="flex items-center justify-between mb-4">
      <div>
        <h3 className="text-lg font-medium text-gray-900 mb-1">
          {"Chain Selection"->React.string}
        </h3>
        <p className="text-sm text-gray-500">
          {"Select the blockchain network to query"->React.string}
        </p>
      </div>
    </div>

    <div className="mb-4">
      <input
        type_="text"
        placeholder="Search chains..."
        value={searchTerm}
        onChange={e => {
          let target = ReactEvent.Form.target(e)
          setSearchTerm(_ => target["value"])
        }}
        className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
      />
    </div>

    {switch selectedChain {
    | Some(chain) => 
      <div className="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-md">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <span className="text-lg">{getEcosystemIcon(chain.ecosystem)->React.string}</span>
            <div>
              <div className="font-medium text-blue-900">
                {chain.name->React.string}
              </div>
              <div className="text-sm text-blue-600">
                {`Chain ID: ${Int.toString(chain.chain_id)} • ${String.toUpperCase(chain.ecosystem)}`->React.string}
              </div>
            </div>
          </div>
          <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium border ${getTierColor(chain.tier)}`}>
            {chain.tier->React.string}
          </span>
        </div>
      </div>
    | None => React.null
    }}

    <div className="max-h-60 overflow-y-auto border border-gray-200 rounded-md">
      {Array.mapWithIndex(filteredChains, (chain, index) =>
        <button
          key={Int.toString(index)}
          onClick={_ => onChainSelect(chain.chain_id)}
          className={`w-full text-left px-4 py-3 hover:bg-gray-50 border-b border-gray-100 last:border-b-0 transition-colors ${
            selectedChainId === Some(chain.chain_id) ? "bg-blue-50" : ""
          }`}>
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <span className="text-lg">{getEcosystemIcon(chain.ecosystem)->React.string}</span>
              <div>
                <div className="font-medium text-gray-900">
                  {chain.name->React.string}
                </div>
                <div className="text-sm text-gray-500">
                  {`Chain ID: ${Int.toString(chain.chain_id)} • ${String.toUpperCase(chain.ecosystem)}`->React.string}
                </div>
              </div>
            </div>
            <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium border ${getTierColor(chain.tier)}`}>
              {chain.tier->React.string}
            </span>
          </div>
        </button>
      )->React.array}
    </div>
  </div>
} 
