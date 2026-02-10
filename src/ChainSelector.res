type chain = {
  name: string,
  tier: string,
  chain_id: int,
  ecosystem: string,
  additional_features: option<array<string>>,
}

// Raw JSON shape imported from the generated file (run `pnpm update-chains`)
type rawChainJson = {
  name: string,
  tier: string,
  chain_id: int,
  ecosystem: string,
  additional_features: Nullable.t<array<string>>,
}

@module("./generated_chains.json") external rawChainsJson: array<rawChainJson> = "default"

let defaultChains: array<chain> =
  rawChainsJson->Array.map((raw): chain => {
    name: raw.name,
    tier: raw.tier,
    chain_id: raw.chain_id,
    ecosystem: raw.ecosystem,
    additional_features: raw.additional_features->Nullable.toOption,
  })

// Tier visuals removed from UI; no color mapping needed

let getEcosystemIcon = (ecosystem: string) => {
  switch ecosystem {
  | "fuel" => "🔥"
  | _ => "⚡"
  }
}

// Helper function to check if a chain supports traces
let chainSupportsTraces = (chain: chain) => {
  switch chain.additional_features {
  | Some(features) => Array.includes(features, "TRACES")
  | None => false
  }
}

// Detect additional_features from chain name convention
// The API doesn't return additional_features, so we infer from the name
let detectAdditionalFeatures = (name: string): option<array<string>> => {
  if String.endsWith(name, "-traces") {
    Some(["TRACES"])
  } else {
    None
  }
}

// Function to fetch chains from API
let fetchChains = async () => {
  open Fetch

  try {
    let response = await fetchSimple("https://chains.hyperquery.xyz/active_chains")
    let json = await response->Response.json

    // Parse the JSON response - the API returns an array of chain objects
    let chains =
      json
      ->JSON.Decode.array
      ->Option.getOr([])
      ->Array.filterMap(item => {
        try {
          let obj = item->JSON.Decode.object
          switch obj {
          | Some(chainObj) =>
            let name =
              chainObj->Dict.get("name")->Option.flatMap(JSON.Decode.string)->Option.getOr("")
            let tier =
              chainObj
              ->Dict.get("tier")
              ->Option.flatMap(JSON.Decode.string)
              ->Option.getOr("STONE")
            let chain_id =
              chainObj
              ->Dict.get("chain_id")
              ->Option.flatMap(JSON.Decode.float)
              ->Option.map(Float.toInt)
              ->Option.getOr(0)
            let ecosystem =
              chainObj
              ->Dict.get("ecosystem")
              ->Option.flatMap(JSON.Decode.string)
              ->Option.getOr("evm")

            // Try to get additional_features from API response, fallback to name-based detection
            let additional_features = {
              let fromApi =
                chainObj
                ->Dict.get("additional_features")
                ->Option.flatMap(JSON.Decode.array)
                ->Option.map(arr => arr->Array.filterMap(JSON.Decode.string))
              switch fromApi {
              | Some(_) => fromApi
              | None => detectAdditionalFeatures(name)
              }
            }

            // Only include chains with valid data
            if name !== "" && chain_id !== 0 {
              Some(({
                name,
                tier,
                chain_id,
                ecosystem,
                additional_features,
              }: chain))
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
  | JsExn(obj) =>
    Console.error2("Failed to fetch chains from API:", obj)
    defaultChains
  | _ =>
    Console.warn("Failed to fetch chains from API, using default list")
    defaultChains
  }
}

@react.component
let make = (
  ~selectedChainName: option<string>,
  ~onChainSelect: string => unit,
  ~customUrl: option<string>,
  ~onCustomUrlChange: option<string => unit>,
  ~onChainsLoaded: option<array<chain> => unit>,
) => {
  let (searchTerm, setSearchTerm) = React.useState(() => "")
  let (chains, setChains) = React.useState(() => defaultChains)
  let (isExpanded, setIsExpanded) = React.useState(() => Option.isNone(selectedChainName))
  let (isLoading, setIsLoading) = React.useState(() => true)
  let (focusedIndex, setFocusedIndex) = React.useState(() => 0)
  let (showCustomInput, setShowCustomInput) = React.useState(() => false)
  let (localCustomUrl, setLocalCustomUrl) = React.useState(() => customUrl->Option.getOr(""))

  // Load chains on component mount
  React.useEffect0(() => {
    let fetchData = async () => {
      let fetchedChains = await fetchChains()
      let sorted = fetchedChains->Array.copy
      Array.sort(sorted, (a, b) =>
        // ensure alphabetical order A->Z
        Js.String.localeCompare(b.name, a.name)
      )->ignore
      setChains(_ => sorted)
      setIsLoading(_ => false)
      // Notify parent about loaded chains so they can use them for URL generation etc.
      switch onChainsLoaded {
      | Some(callback) => callback(sorted)
      | None => ()
      }
    }

    fetchData()->ignore
    None
  })

  let isNumeric = str =>
    switch Int.fromString(str) {
    | Some(_) => true
    | None => false
    }

  let filteredChains = chains->Array.filter(chain => {
    if searchTerm === "" {
      true
    } else if isNumeric(searchTerm) {
      String.includes(Int.toString(chain.chain_id), searchTerm)
    } else {
      String.includes(String.toLowerCase(chain.name), String.toLowerCase(searchTerm))
    }
  })

  let selectedChain =
    selectedChainName->Option.flatMap(chainName =>
      chains->Array.find(chain => chain.name === chainName)
    )

  // Handle selection logic
  let handleChainSelect = (chainName: string) => {
    onChainSelect(chainName)
    setIsExpanded(_ => false)
    setSearchTerm(_ => "")
    setShowCustomInput(_ => false)
  }

  // Handle custom URL submission
  let handleCustomUrlSubmit = () => {
    if String.length(localCustomUrl) > 0 {
      switch onCustomUrlChange {
      | Some(callback) => callback(localCustomUrl)
      | None => ()
      }
      setIsExpanded(_ => false)
      setShowCustomInput(_ => false)
    }
  }

  // Handle selected chain click (expand/collapse toggle)
  let handleSelectedChainClick = () => {
    setIsExpanded(prev => {
      let next = !prev
      if next {
        setFocusedIndex(_ => 0)
      }
      next
    })
  }

  <div className="relative mb-6">
    <button
      onClick={_ => handleSelectedChainClick()}
      className="w-full flex items-center justify-between px-3 py-2 bg-blue-50 border border-blue-200 rounded-md hover:bg-blue-100 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"
    >
      {switch (customUrl, selectedChain) {
      | (Some(url), _) if String.length(url) > 0 =>
        <div className="flex items-center space-x-2">
          <span className="font-medium text-blue-900"> {"Custom URL"->React.string} </span>
          <span className="text-sm text-blue-600 truncate max-w-[200px]">
            {url->React.string}
          </span>
        </div>
      | (_, Some(chain)) =>
        <div className="flex items-center space-x-2">
          <span className="font-medium text-blue-900"> {chain.name->React.string} </span>
          <span className="text-sm text-blue-600">
            {Int.toString(chain.chain_id)->React.string}
          </span>
        </div>
      | (_, None) => <span className="text-blue-900"> {"Select a chain"->React.string} </span>
      }}
      <svg
        className={`w-5 h-5 text-blue-500 transform transition-transform duration-200 ${isExpanded
            ? "rotate-180"
            : ""}`}
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    {isExpanded
      ? <div
          className="absolute left-0 right-0 mt-2 z-10 bg-white border border-gray-200 rounded-md shadow-lg"
        >
          <div className="p-2">
            <input
              type_="text"
              placeholder="Search chains..."
              autoFocus=true
              value={searchTerm}
              onChange={e => {
                let target = ReactEvent.Form.target(e)
                setSearchTerm(_ => target["value"])
                setFocusedIndex(_ => 0)
              }}
              onKeyDown={e => {
                switch ReactEvent.Keyboard.key(e) {
                | "ArrowDown" => {
                    ReactEvent.Synthetic.preventDefault(e)
                    setFocusedIndex(prev => min(prev + 1, Array.length(filteredChains) - 1))
                  }
                | "ArrowUp" => {
                    ReactEvent.Synthetic.preventDefault(e)
                    setFocusedIndex(prev => max(prev - 1, 0))
                  }
                | "Enter" => {
                    ReactEvent.Synthetic.preventDefault(e)
                    Belt.Array.get(filteredChains, focusedIndex)->Option.forEach(chain =>
                      handleChainSelect(chain.name)
                    )
                  }
                | _ => ()
                }
              }}
              className="w-full border border-gray-300 rounded-md px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          // Custom URL input section
          {Option.isSome(onCustomUrlChange)
            ? <div className="px-2 pb-2 border-b border-gray-200">
                {showCustomInput
                  ? <div className="flex items-center gap-2">
                      <input
                        type_="text"
                        placeholder="Enter custom HyperSync URL..."
                        value={localCustomUrl}
                        onChange={e => {
                          let target = ReactEvent.Form.target(e)
                          setLocalCustomUrl(_ => target["value"])
                        }}
                        onKeyDown={e => {
                          if ReactEvent.Keyboard.key(e) === "Enter" {
                            ReactEvent.Synthetic.preventDefault(e)
                            handleCustomUrlSubmit()
                          }
                        }}
                        className="flex-1 border border-gray-300 rounded-md px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      />
                      <button
                        onClick={_ => handleCustomUrlSubmit()}
                        className="px-3 py-1 bg-blue-500 text-white text-sm font-medium rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
                      >
                        {"Use"->React.string}
                      </button>
                      <button
                        onClick={_ => setShowCustomInput(_ => false)}
                        className="px-2 py-1 text-gray-500 hover:text-gray-700 text-sm"
                      >
                        {"Cancel"->React.string}
                      </button>
                    </div>
                  : <button
                      onClick={_ => setShowCustomInput(_ => true)}
                      className="w-full flex items-center justify-between px-3 py-2 text-left text-sm text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                    >
                      <div className="flex items-center space-x-2">
                        <svg
                          className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                          />
                        </svg>
                        <span> {"Use Custom URL"->React.string} </span>
                      </div>
                    </button>}
              </div>
            : React.null}
          <div className="max-h-60 overflow-y-auto">
            {isLoading
              ? <div className="px-4 py-8 text-center text-gray-500">
                  <div
                    className="inline-block w-6 h-6 border-2 border-gray-300 border-t-blue-500 rounded-full animate-spin mb-2"
                  >
                  </div>
                  <div> {"Loading available chains..."->React.string} </div>
                </div>
              : Array.mapWithIndex(filteredChains, (chain, index) =>
                  <button
                    key={Int.toString(index)}
                    onClick={_ => handleChainSelect(chain.name)}
                    className={`w-full flex items-center justify-between px-3 py-2 text-left hover:bg-gray-50 border-b border-gray-100 last:border-b-0 transition-colors ${selectedChainName ===
                        Some(chain.name)
                        ? "bg-blue-50"
                        : ""} ${focusedIndex === index ? "bg-gray-100" : ""}`}
                  >
                    <div className="flex items-center space-x-2">
                      <span className="text-lg">
                        {getEcosystemIcon(chain.ecosystem)->React.string}
                      </span>
                      <span className="font-medium text-gray-900">
                        {chain.name->React.string}
                      </span>
                      <span className="text-sm text-gray-500">
                        {Int.toString(chain.chain_id)->React.string}
                      </span>
                    </div>
                  </button>
                )->React.array}
          </div>
          {!isLoading && Array.length(filteredChains) === 0
            ? <div className="px-4 py-4 text-center text-gray-500">
                {"No chains match your search"->React.string}
              </div>
            : React.null}
        </div>
      : React.null}
  </div>
}
