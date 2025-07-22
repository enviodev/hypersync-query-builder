type chain = {
  name: string,
  tier: string,
  chain_id: int,
  ecosystem: string,
  additional_features: option<array<string>>,
}

let defaultChains = [
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
  | "STONE" => "bg-blue-100 text-blue-800 border-blue-200"
  | _ => "bg-green-100 text-green-800 border-green-200"
  }
}

let getEcosystemIcon = (ecosystem: string) => {
  switch ecosystem {
  | "fuel" => "🔥"
  | _ => "⚡"
  }
}

// Function to fetch chains from API
// Unfortunately this function gets CORS errors so we are not using it properly.
let fetchChains = async () => {
  open Fetch
  
  try {
    let response = await fetch("https://chains.hyperquery.xyz/active_chains", {})
    let json = await response->Response.json
    
    // Parse the JSON response - the API returns an array of chain objects
    let chains = json
      ->Js.Json.decodeArray
      ->Option.getOr([])
      ->Array.filterMap(item => {
        try {
          let obj = item->Js.Json.decodeObject
          switch obj {
          | Some(chainObj) =>
            let name = chainObj->Js.Dict.get("name")->Option.flatMap(Js.Json.decodeString)->Option.getOr("")
            let tier = chainObj->Js.Dict.get("tier")->Option.flatMap(Js.Json.decodeString)->Option.getOr("STONE")
            let chain_id = chainObj->Js.Dict.get("chain_id")->Option.flatMap(Js.Json.decodeNumber)->Option.map(Float.toInt)->Option.getOr(0)
            let ecosystem = chainObj->Js.Dict.get("ecosystem")->Option.flatMap(Js.Json.decodeString)->Option.getOr("evm")
            
            let additional_features = chainObj
              ->Js.Dict.get("additional_features")
              ->Option.flatMap(Js.Json.decodeArray)
              ->Option.map(arr => arr->Array.filterMap(Js.Json.decodeString))
            
            // Only include chains with valid data
            if name !== "" && chain_id !== 0 {
              Some({
                name: name,
                tier: tier,
                chain_id: chain_id,
                ecosystem: ecosystem,
                additional_features: additional_features,
              })
            } else {
              None
            }
          | None => None
          }
        } catch {
        | _ => None
        }
      })
    
    // Return fetched chains or fallback to default
    if Array.length(chains) > 0 {
      Console.log(`Successfully loaded ${Int.toString(Array.length(chains))} chains from API`)
      chains
    } else {
      Console.warn("API returned no valid chains, using default list")
      defaultChains
    }
  } catch {
  | Js.Exn.Error(obj) => 
    Console.error2("Failed to fetch chains from API:", obj)
    defaultChains
  | _ => 
    Console.warn("Failed to fetch chains from API, using default list")
    defaultChains
  }
}

@react.component
let make = (~selectedChainId: option<int>, ~onChainSelect: int => unit) => {
  let (searchTerm, setSearchTerm) = React.useState(() => "")
  let (chains, setChains) = React.useState(() => defaultChains)
  let (isExpanded, setIsExpanded) = React.useState(() => true)
  let (isLoading, setIsLoading) = React.useState(() => true)

  // Load chains on component mount
  React.useEffect0(() => {
    let fetchData = async () => {
      let fetchedChains = await fetchChains()
      setChains(_ => fetchedChains)
      setIsLoading(_ => false)
    }
    
    fetchData()->ignore
    None
  })

  let filteredChains = chains->Array.filter(chain => {
    searchTerm === "" || 
    String.includes(String.toLowerCase(chain.name), String.toLowerCase(searchTerm)) ||
    String.includes(String.toLowerCase(chain.tier), String.toLowerCase(searchTerm))
  })

  let selectedChain = selectedChainId->Option.flatMap(chainId => 
    chains->Array.find(chain => chain.chain_id === chainId)
  )

  // Handle selection logic
  let handleChainSelect = (chainId: int) => {
    onChainSelect(chainId)
    setIsExpanded(_ => false) // Collapse after selection
    setSearchTerm(_ => "") // Clear search
  }

  // Handle selected chain click (expand/collapse toggle)
  let handleSelectedChainClick = () => {
    setIsExpanded(prev => !prev)
  }

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
      {isLoading ? (
        <div className="text-sm text-gray-500">
          {"Loading chains..."->React.string}
        </div>
      ) : (
        <div className="text-sm text-gray-500">
          {`${Int.toString(Array.length(chains))} chains available`->React.string}
        </div>
      )}
    </div>

    // Selected Chain Display
    {switch selectedChain {
    | Some(chain) => 
      <button
        onClick={_ => handleSelectedChainClick()}
        className="w-full mb-4 p-3 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <span className="text-lg">{getEcosystemIcon(chain.ecosystem)->React.string}</span>
            <div className="text-left">
              <div className="font-medium text-blue-900">
                {chain.name->React.string}
              </div>
              <div className="text-sm text-blue-600">
                {`Chain ID: ${Int.toString(chain.chain_id)} • ${String.toUpperCase(chain.ecosystem)}`->React.string}
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-2">
            <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium border ${getTierColor(chain.tier)}`}>
              {chain.tier->React.string}
            </span>
            <svg 
              className={`w-5 h-5 text-blue-500 transform transition-transform duration-200 ${isExpanded ? "rotate-180" : ""}`}
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
      </button>
    | None => React.null
    }}

    // Chain Selection List - Show when expanded or no chain selected
    {(isExpanded || Option.isNone(selectedChainId)) ? (
      <div>
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

        <div className="max-h-60 overflow-y-auto border border-gray-200 rounded-md">
          {isLoading ? (
            <div className="px-4 py-8 text-center text-gray-500">
              <div className="inline-block w-6 h-6 border-2 border-gray-300 border-t-blue-500 rounded-full animate-spin mb-2"></div>
              <div>{"Loading available chains..."->React.string}</div>
            </div>
          ) : (
            Array.mapWithIndex(filteredChains, (chain, index) =>
              <button
                key={Int.toString(index)}
                onClick={_ => handleChainSelect(chain.chain_id)}
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
                  <div className="flex items-center space-x-2">
                    <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium border ${getTierColor(chain.tier)}`}>
                      {chain.tier->React.string}
                    </span>
                    {switch chain.additional_features {
                    | Some(features) when Array.length(features) > 0 => 
                      <span className="text-xs text-gray-400">
                        {`+${Int.toString(Array.length(features))}`->React.string}
                      </span>
                    | _ => React.null
                    }}
                  </div>
                </div>
              </button>
            )->React.array
          )}
        </div>
        
        {!isLoading && Array.length(filteredChains) === 0 ? (
          <div className="px-4 py-8 text-center text-gray-500">
            {"No chains match your search"->React.string}
          </div>
        ) : React.null}
      </div>
    ) : React.null}
  </div>
} 
