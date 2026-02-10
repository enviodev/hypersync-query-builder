%%raw(`import './App.css'`)
%%raw(`import './tailwind.css'`)

open QueryStructure
open UrlEncoder

@react.component
let make = () => {
  // Token state management
  let (bearerToken, setBearerToken) = React.useState(() => AuthToken.getToken())

  let handleTokenSubmit = (token: string) => {
    if AuthToken.saveToken(token) {
      setBearerToken(_ => Some(token))
    }
  }

  let (query, setQuery) = React.useState(() => {
    // Try to load query from URL first, fallback to default
    switch UrlEncoder.getUrlStateFromUrl() {
    | Some(urlState) => urlState.query
    | None => {
        fromBlock: 0,
        toBlock: None,
        logs: None,
        transactions: None,
        traces: None,
        blocks: None,
        includeAllBlocks: None,
        fieldSelection: {
          block: [],
          transaction: [],
          log: [],
          trace: [],
        },
        maxNumBlocks: Some(10),
        maxNumTransactions: Some(10),
        maxNumLogs: Some(10),
        maxNumTraces: None,
        joinMode: None,
      }
    }
  })

  let (selectedChainName, setSelectedChainName) = React.useState(() => {
    // Try to load selectedChainName from URL first, fallback to eth by default
    switch UrlEncoder.getUrlStateFromUrl() {
    | Some(urlState) =>
      switch urlState.selectedChainName {
      | Some(name) => Some(name)
      | None => Some("eth")
      }
    | None => Some("eth")
    }
  })
  let (customUrl, setCustomUrl) = React.useState(() => None)
  let (availableChains, setAvailableChains) = React.useState(() => ChainSelector.defaultChains)
  let (expandedFilterKey, setExpandedFilterKey) = React.useState(() => None)
  let (executeSignal, setExecuteSignal) = React.useState(() => 0)

  // Quick Start shared address (used by address-based presets)
  let (quickStartAddress, setQuickStartAddress) = React.useState(() => "")

  let padLeftZeros = (hex: string, totalLen: int): string => {
    let len = String.length(hex)
    if len >= totalLen {
      hex
    } else {
      let zeros = Belt.Array.makeBy(totalLen - len, _ => "0")->Array.join("")
      zeros ++ hex
    }
  }

  let encodeAddressToTopic = (addr: string): option<string> => {
    if !(addr->String.startsWith("0x")) || String.length(addr) !== 42 {
      None
    } else {
      let hex = String.substring(addr, ~start=2)->String.toLowerCase
      let padded = padLeftZeros(hex, 64)
      Some("0x" ++ padded)
    }
  }

  // Helper function to check if selected chain supports traces
  let selectedChainSupportsTraces = () => {
    switch selectedChainName {
    | Some(chainName) =>
      // Find the selected chain in the available chains list (fetched from API or default)
      let selectedChain = availableChains->Array.find(chain => chain.name === chainName)
      switch selectedChain {
      | Some(chain) => ChainSelector.chainSupportsTraces(chain)
      | None => false
      }
    | None => false
    }
  }

  let toggleFilter = key =>
    setExpandedFilterKey(prev =>
      switch prev {
      | Some(prevKey) =>
        if prevKey === key {
          None
        } else {
          Some(key)
        }
      | None => Some(key)
      }
    )

  let resetBuilder = () => {
    setSelectedChainName(_ => Some("eth"))
    setQuickStartAddress(_ => "")
    setExpandedFilterKey(_ => None)
    setQuery(_ => {
      fromBlock: 0,
      toBlock: None,
      logs: None,
      transactions: None,
      traces: None,
      blocks: None,
      includeAllBlocks: None,
      fieldSelection: {
        block: [],
        transaction: [],
        log: [],
        trace: [],
      },
      maxNumBlocks: Some(10),
      maxNumTransactions: Some(10),
      maxNumLogs: Some(10),
      maxNumTraces: None,
      joinMode: None,
    })
  }

  // Quick-start templates
  let applyPresetErc20Transfers = () => {
    // ERC20 Transfer event signature
    let transferTopic0 = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
    let preset: query = {
      ...query,
      logs: Some([{address: None, topics: Some([[transferTopic0]])}]),
      transactions: None,
      blocks: None,
      traces: None,
      fieldSelection: {
        block: [],
        transaction: [
          // transactionField
          BlockHash,
          From,
          To,
          Value,
          Status,
        ],
        log: [
          // logField
          Address,
          Topic0,
          Topic1,
          Topic2,
          Topic3,
          TransactionHash,
          BlockNumber,
        ],
        trace: [],
      },
      maxNumBlocks: Some(10),
      maxNumTransactions: Some(10),
      maxNumLogs: Some(10),
      maxNumTraces: None,
      joinMode: query.joinMode,
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("log-0"))
    // Select a sensible default network if none selected
    setSelectedChainName(prev =>
      switch prev {
      | Some(_) => prev
      | None => Some("eth")
      }
    )
  }

  let applyPresetFailedTransactions = () => {
    let preset: query = {
      ...query,
      logs: None,
      transactions: Some([
        {
          from_: None,
          to_: None,
          sighash: None,
          status: Some(0),
          kind: None,
          contractAddress: None,
          authorizationList: None,
        },
      ]),
      traces: None,
      blocks: None,
      fieldSelection: {
        block: [],
        transaction: [Hash, From, To, Value, GasUsed, Status],
        log: [],
        trace: [],
      },
      maxNumBlocks: Some(10),
      maxNumTransactions: Some(10),
      maxNumLogs: Some(10),
      maxNumTraces: None,
      joinMode: query.joinMode,
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("transaction-0"))
    // Select a sensible default network if none selected
    setSelectedChainName(prev =>
      switch prev {
      | Some(_) => prev
      | None => Some("eth")
      }
    )
  }

  // Additional Quick-start templates inspired by docs
  // https://docs.envio.dev/docs/HyperSync/hypersync-curl-examples#get-all-erc-20-transfers-for-an-address
  let applyPresetErc20TransfersForAddress = () => {
    // Example address from docs; users can override via Quick Start Address
    let defaultAddr = "0x1e037f97d730Cc881e77F01E409D828b0bb14de0"
    let addr = if (
      quickStartAddress->String.startsWith("0x") && String.length(quickStartAddress) === 42
    ) {
      quickStartAddress
    } else {
      defaultAddr
    }
    // 32-byte topic-encoded address
    let addrTopic = encodeAddressToTopic(addr)->Option.getOr("")
    let transferTopic0 = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
    let preset: query = {
      ...query,
      fromBlock: 0,
      logs: Some([
        {address: None, topics: Some([[transferTopic0], [], [addrTopic]])},
        {address: None, topics: Some([[transferTopic0], [addrTopic], []])},
      ]),
      transactions: Some([
        {
          from_: Some([addr]),
          to_: None,
          sighash: None,
          status: None,
          kind: None,
          contractAddress: None,
          authorizationList: None,
        },
        {
          from_: None,
          to_: Some([addr]),
          sighash: None,
          status: None,
          kind: None,
          contractAddress: None,
          authorizationList: None,
        },
      ]),
      blocks: None,
      traces: None,
      fieldSelection: {
        block: [Number, Timestamp, Hash],
        log: [
          BlockNumber,
          LogIndex,
          TransactionIndex,
          Data,
          Address,
          Topic0,
          Topic1,
          Topic2,
          Topic3,
        ],
        transaction: [BlockNumber, TransactionIndex, Hash, From, To, Value, Input],
        trace: [],
      },
      maxNumBlocks: Some(10),
      maxNumTransactions: Some(10),
      maxNumLogs: Some(10),
      maxNumTraces: None,
      joinMode: query.joinMode,
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("log-0"))
    setSelectedChainName(prev =>
      switch prev {
      | Some(_) => prev
      | None => Some("eth")
      }
    )
  }

  // https://docs.envio.dev/docs/HyperSync/hypersync-curl-examples#get-all-transactions-for-an-address
  let applyPresetAddressTransactions = () => {
    let defaultAddr = "0x1e037f97d730Cc881e77F01E409D828b0bb14de0"
    let addr = if (
      quickStartAddress->String.startsWith("0x") && String.length(quickStartAddress) === 42
    ) {
      quickStartAddress
    } else {
      defaultAddr
    }
    let preset: query = {
      ...query,
      fromBlock: 15362000,
      logs: None,
      transactions: Some([
        {
          from_: Some([addr]),
          to_: None,
          sighash: None,
          status: None,
          kind: None,
          contractAddress: None,
          authorizationList: None,
        },
        {
          from_: None,
          to_: Some([addr]),
          sighash: None,
          status: None,
          kind: None,
          contractAddress: None,
          authorizationList: None,
        },
      ]),
      blocks: None,
      traces: None,
      fieldSelection: {
        block: [Number, Timestamp, Hash],
        transaction: [BlockNumber, TransactionIndex, Hash, From, To],
        log: [],
        trace: [],
      },
      maxNumBlocks: Some(10),
      maxNumTransactions: Some(10),
      maxNumLogs: Some(10),
      maxNumTraces: None,
      joinMode: query.joinMode,
    }
    setQuery(_ => preset)
    setExpandedFilterKey(_ => Some("transaction-0"))
    setSelectedChainName(prev =>
      switch prev {
      | Some(_) => prev
      | None => Some("eth")
      }
    )
  }

  // Update URL when query or selectedChainName changes
  React.useEffect1(() => {
    UrlEncoder.updateUrlWithState({query, selectedChainName})
    None
  }, [(query, selectedChainName)])

  // Clear trace-related data when a non-traces network is selected
  React.useEffect1(() => {
    switch selectedChainName {
    | Some(chainName) =>
      let selectedChain = availableChains->Array.find(chain => chain.name === chainName)
      switch selectedChain {
      | Some(chain) =>
        if !ChainSelector.chainSupportsTraces(chain) {
          // Clear trace filters and field selections when traces are not supported
          setQuery(prev => {
            ...prev,
            traces: None,
            fieldSelection: {
              ...prev.fieldSelection,
              trace: [],
            },
          })
        }
      | None => ()
      }
    | None => ()
    }
    None
  }, [selectedChainName])

  let updateFieldSelection = (newFieldSelection: fieldSelection) => {
    setQuery(prev => {...prev, fieldSelection: newFieldSelection})
  }

  let addLogFilter = () => {
    let newIndex = query.logs->Option.getOr([])->Array.length
    let newLogFilter: logSelection = {
      address: None,
      topics: None,
    }
    setQuery(prev => {
      ...prev,
      logs: Some(Array.concat(prev.logs->Option.getOr([]), [newLogFilter])),
    })
    setExpandedFilterKey(_ => Some(`log-${Int.toString(newIndex)}`))
  }

  let updateLogFilter = (index: int, newFilter: logSelection) => {
    setQuery(prev => {
      let currentLogs = prev.logs->Option.getOr([])
      let updatedLogs = Array.mapWithIndex(currentLogs, (filter, i) =>
        i === index ? newFilter : filter
      )
      {...prev, logs: Some(updatedLogs)}
    })
  }

  let removeLogFilter = (index: int) => {
    setQuery(prev => {
      let currentLogs = prev.logs->Option.getOr([])
      let updatedLogs = Belt.Array.keepWithIndex(currentLogs, (_, i) => i !== index)
      {...prev, logs: Array.length(updatedLogs) > 0 ? Some(updatedLogs) : None}
    })
    let key = `log-${Int.toString(index)}`
    setExpandedFilterKey(prev =>
      if prev === Some(key) {
        None
      } else {
        prev
      }
    )
  }

  let addTransactionFilter = () => {
    let newIndex = query.transactions->Option.getOr([])->Array.length
    let newTransactionFilter: transactionSelection = {
      from_: None,
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    }
    setQuery(prev => {
      ...prev,
      transactions: Some(Array.concat(prev.transactions->Option.getOr([]), [newTransactionFilter])),
    })
    setExpandedFilterKey(_ => Some(`transaction-${Int.toString(newIndex)}`))
  }

  let updateTransactionFilter = (index: int, newFilter: transactionSelection) => {
    setQuery(prev => {
      let currentTransactions = prev.transactions->Option.getOr([])
      let updatedTransactions = Array.mapWithIndex(currentTransactions, (filter, i) =>
        i === index ? newFilter : filter
      )
      {...prev, transactions: Some(updatedTransactions)}
    })
  }

  let removeTransactionFilter = (index: int) => {
    setQuery(prev => {
      let currentTransactions = prev.transactions->Option.getOr([])
      let updatedTransactions = Belt.Array.keepWithIndex(currentTransactions, (_, i) => i !== index)
      {
        ...prev,
        transactions: Array.length(updatedTransactions) > 0 ? Some(updatedTransactions) : None,
      }
    })
    let key = `transaction-${Int.toString(index)}`
    setExpandedFilterKey(prev =>
      if prev === Some(key) {
        None
      } else {
        prev
      }
    )
  }

  let addBlockFilter = () => {
    let newIndex = query.blocks->Option.getOr([])->Array.length
    let newBlockFilter: blockSelection = {
      hash: None,
      miner: None,
    }
    setQuery(prev => {
      ...prev,
      blocks: Some(Array.concat(prev.blocks->Option.getOr([]), [newBlockFilter])),
    })
    setExpandedFilterKey(_ => Some(`block-${Int.toString(newIndex)}`))
  }

  let updateBlockFilter = (index: int, newFilter: blockSelection) => {
    setQuery(prev => {
      let currentBlocks = prev.blocks->Option.getOr([])
      let updatedBlocks = Array.mapWithIndex(currentBlocks, (filter, i) =>
        i === index ? newFilter : filter
      )
      {...prev, blocks: Some(updatedBlocks)}
    })
  }

  let removeBlockFilter = (index: int) => {
    setQuery(prev => {
      let currentBlocks = prev.blocks->Option.getOr([])
      let updatedBlocks = Belt.Array.keepWithIndex(currentBlocks, (_, i) => i !== index)
      {...prev, blocks: Array.length(updatedBlocks) > 0 ? Some(updatedBlocks) : None}
    })
    let key = `block-${Int.toString(index)}`
    setExpandedFilterKey(prev =>
      if prev === Some(key) {
        None
      } else {
        prev
      }
    )
  }

  let addTraceFilter = () => {
    let newIndex = query.traces->Option.getOr([])->Array.length
    let newTraceFilter: traceSelection = {
      from_: None,
      to_: None,
      address: None,
      callType: None,
      rewardType: None,
      kind: None,
      sighash: None,
    }
    setQuery(prev => {
      ...prev,
      traces: Some(Array.concat(prev.traces->Option.getOr([]), [newTraceFilter])),
    })
    setExpandedFilterKey(_ => Some(`trace-${Int.toString(newIndex)}`))
  }

  let updateTraceFilter = (index: int, newFilter: traceSelection) => {
    setQuery(prev => {
      let currentTraces = prev.traces->Option.getOr([])
      let updatedTraces = Array.mapWithIndex(currentTraces, (filter, i) =>
        i === index ? newFilter : filter
      )
      {...prev, traces: Some(updatedTraces)}
    })
  }

  let removeTraceFilter = (index: int) => {
    setQuery(prev => {
      let currentTraces = prev.traces->Option.getOr([])
      let updatedTraces = Belt.Array.keepWithIndex(currentTraces, (_, i) => i !== index)
      {
        ...prev,
        traces: Array.length(updatedTraces) > 0 ? Some(updatedTraces) : None,
      }
    })
    let key = `trace-${Int.toString(index)}`
    setExpandedFilterKey(prev =>
      if prev === Some(key) {
        None
      } else {
        prev
      }
    )
  }

  <>
    // Show token prompt if no valid token
    {!AuthToken.isValidToken(bearerToken)
      ? <TokenPrompt onTokenSubmit={handleTokenSubmit} />
      : React.null}

    <main className="flex-1 overflow-hidden bg-slate-50">
      <div className="h-full flex flex-col lg:flex-row">
        // Left Column - Query Builder
        <div className="w-full lg:w-1/2 overflow-y-auto">
          <div className="p-6 lg:p-4 lg:pr-2">
            <div className="mb-8 flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold text-slate-900 mb-1">
                  {"Create Your Query"->React.string}
                </h2>
                <p className="text-sm text-slate-600">
                  {"Build and test HyperSync queries with a visual interface"->React.string}
                </p>
              </div>
              <button
                onClick={_ => resetBuilder()}
                className="inline-flex items-center px-3 py-1.5 text-xs font-medium text-slate-600 hover:text-slate-900 bg-slate-100 hover:bg-slate-200 rounded-lg border border-slate-200 transition-colors"
              >
                {"Reset"->React.string}
              </button>
            </div>

          <div className="space-y-6">
            // Section 1: Configuration
            <div className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm">
              <div className="flex items-center mb-4">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-slate-900">
                    {"Choose Your Config"->React.string}
                  </h3>
                  <p className="text-sm text-slate-600">
                    {"Select your blockchain network and configure query settings"->React.string}
                  </p>
                </div>
                {switch selectedChainName {
                | Some(chainName) =>
                  <div className="ml-auto">
                    <span
                      className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                      {chainName->React.string}
                    </span>
                  </div>
                | None => React.null
                }}
              </div>

              // Chain Selection
              <div className="mb-6">
                <ChainSelector
                  selectedChainName={selectedChainName}
                  onChainSelect={chainName => {
                    setSelectedChainName(_ => Some(chainName))
                    setCustomUrl(_ => None)
                  }}
                  customUrl={customUrl}
                  onCustomUrlChange={Some(url => {
                    setCustomUrl(_ => Some(url))
                    setSelectedChainName(_ => None)
                  })}
                  onChainsLoaded={Some(chains => setAvailableChains(_ => chains))}
                />
              </div>

              // Advanced Options
              <AdvancedOptions query={query} onQueryChange={newQuery => setQuery(_ => newQuery)} />

              // Quick Start Templates
              <div className="mt-6">
                <div className="flex items-center justify-between mb-3">
                  <div>
                    <h4 className="text-sm font-medium text-slate-900">
                      {"Quick start"->React.string}
                    </h4>
                    <p className="text-xs text-slate-600">
                      {"Start from a popular template"->React.string}
                    </p>
                  </div>
                </div>
                <div className="mb-2 flex items-center gap-2">
                  <input
                    type_="text"
                    value={quickStartAddress}
                    onChange={e => {
                      let target = ReactEvent.Form.target(e)
                      setQuickStartAddress(_ => target["value"])
                    }}
                    placeholder="Address for address-based presets (0x...)"
                    className="flex-1 border border-slate-300 rounded-lg px-3 py-1.5 text-xs focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition-colors"
                  />
                  <span className="text-[11px] text-slate-500">
                    {if String.length(quickStartAddress) == 0 {
                      "Using a random example address: 0x1e03…4de0"
                    } else {
                      "Using your address for address-based presets"
                    }->React.string}
                  </span>
                </div>
                <div className="flex flex-wrap gap-2">
                  <button
                    onClick={_ => applyPresetErc20Transfers()}
                    className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    {"ERC20 Transfers (logs)"->React.string}
                  </button>
                  <button
                    onClick={_ => applyPresetFailedTransactions()}
                    className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    {"Failed Transactions"->React.string}
                  </button>
                  <button
                    onClick={_ => applyPresetErc20TransfersForAddress()}
                    className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    {"ERC20 Transfers for Address"->React.string}
                  </button>
                  <button
                    onClick={_ => applyPresetAddressTransactions()}
                    className="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-lg border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    {"All Txns for Address"->React.string}
                  </button>
                </div>
              </div>
            </div>

            // Section 2: Filters
            <div className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm">
              <div className="flex items-center mb-4">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-slate-900">
                    {"Add Filters"->React.string}
                  </h3>
                  <p className="text-sm text-slate-600">
                    {"Define what data you want to retrieve: "->React.string}
                    <span className="font-medium"> {"logs"->React.string} </span>
                    {", "->React.string}
                    <span className="font-medium"> {"transactions"->React.string} </span>
                    {", "->React.string}
                    <span className="font-medium"> {"blocks"->React.string} </span>
                    <span className="text-xs text-slate-500">
                      {" (traces available on select networks - reach out to team if interested)"->React.string}
                    </span>
                  </p>
                </div>
                {Array.length(query.logs->Option.getOr([])) > 0 ||
                Array.length(query.transactions->Option.getOr([])) > 0 ||
                Array.length(query.blocks->Option.getOr([])) > 0 || (
                  selectedChainSupportsTraces()
                    ? Array.length(query.traces->Option.getOr([])) > 0
                    : false
                )
                  ? <div className="ml-auto">
                      <span
                        className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                        {`${Int.toString(
                            Array.length(query.logs->Option.getOr([])) +
                            Array.length(query.transactions->Option.getOr([])) +
                            Array.length(query.blocks->Option.getOr([])) + (
                              selectedChainSupportsTraces()
                                ? Array.length(query.traces->Option.getOr([]))
                                : 0
                            ),
                          )} filter${Array.length(query.logs->Option.getOr([])) +
                          Array.length(query.transactions->Option.getOr([])) +
                          Array.length(query.blocks->Option.getOr([])) + (
                            selectedChainSupportsTraces()
                              ? Array.length(query.traces->Option.getOr([]))
                              : 0
                          ) === 1
                            ? ""
                            : "s"}`->React.string}
                      </span>
                    </div>
                  : React.null}
              </div>

              <div className="mb-8">
                <div className="flex flex-wrap gap-3">
                  <button
                    onClick={_ => addLogFilter()}
                    className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    <svg
                      className="w-4 h-4 mr-2"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24">
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                      />
                    </svg>
                    {"Add Log Filter"->React.string}
                  </button>
                  <button
                    onClick={_ => addTransactionFilter()}
                    className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    <svg
                      className="w-4 h-4 mr-2"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24">
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                      />
                    </svg>
                    {"Add Transaction Filter"->React.string}
                  </button>
                  <button
                    onClick={_ => addBlockFilter()}
                    className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                    <svg
                      className="w-4 h-4 mr-2"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24">
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                      />
                    </svg>
                    {"Add Block Filter"->React.string}
                  </button>
                  {selectedChainSupportsTraces()
                    ? <button
                        onClick={_ => addTraceFilter()}
                        className="inline-flex items-center px-4 py-2 bg-slate-900 text-white text-sm font-medium rounded-lg hover:bg-slate-950 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
                        <svg
                          className="w-4 h-4 mr-2"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                          />
                        </svg>
                        {"Add Trace Filter"->React.string}
                      </button>
                    : React.null}
                </div>
              </div>

              // Active Filters Display
              {Array.length(query.logs->Option.getOr([])) > 0 ||
              Array.length(query.transactions->Option.getOr([])) > 0 ||
              Array.length(query.blocks->Option.getOr([])) > 0 || (
                selectedChainSupportsTraces()
                  ? Array.length(query.traces->Option.getOr([])) > 0
                  : false
              )
                ? <div className="mt-6 relative z-0">
                    <div className="grid gap-4">
                      // Log Filters
                      {Array.mapWithIndex(query.logs->Option.getOr([]), (logFilter, index) =>
                        <LogFilter
                          key={`log-${Int.toString(index)}`}
                          filterState={logFilter}
                          onFilterChange={newFilter => updateLogFilter(index, newFilter)}
                          onRemove={() => removeLogFilter(index)}
                          filterIndex={index}
                          isExpanded={expandedFilterKey === Some(`log-${Int.toString(index)}`)}
                          onToggleExpand={() => toggleFilter(`log-${Int.toString(index)}`)}
                        />
                      )->React.array}

                      // Transaction Filters
                      {Array.mapWithIndex(query.transactions->Option.getOr([]), (
                        transactionFilter,
                        index,
                      ) =>
                        <TransactionFilter
                          key={`transaction-${Int.toString(index)}`}
                          filterState={transactionFilter}
                          onFilterChange={newFilter => updateTransactionFilter(index, newFilter)}
                          onRemove={() => removeTransactionFilter(index)}
                          filterIndex={index}
                          isExpanded={expandedFilterKey ===
                            Some(`transaction-${Int.toString(index)}`)}
                          onToggleExpand={() => toggleFilter(`transaction-${Int.toString(index)}`)}
                        />
                      )->React.array}

                      // Block Filters
                      {Array.mapWithIndex(query.blocks->Option.getOr([]), (blockFilter, index) =>
                        <BlockFilter
                          key={`block-${Int.toString(index)}`}
                          filterState={blockFilter}
                          onFilterChange={newFilter => updateBlockFilter(index, newFilter)}
                          onRemove={() => removeBlockFilter(index)}
                          filterIndex={index}
                          isExpanded={expandedFilterKey === Some(`block-${Int.toString(index)}`)}
                          onToggleExpand={() => toggleFilter(`block-${Int.toString(index)}`)}
                        />
                      )->React.array}

                      // Trace Filters
                      {selectedChainSupportsTraces()
                        ? Array.mapWithIndex(query.traces->Option.getOr([]), (traceFilter, index) =>
                            <TraceFilter
                              key={`trace-${Int.toString(index)}`}
                              filterState={traceFilter}
                              onFilterChange={newFilter => updateTraceFilter(index, newFilter)}
                              onRemove={() => removeTraceFilter(index)}
                              filterIndex={index}
                              isExpanded={expandedFilterKey ===
                                Some(`trace-${Int.toString(index)}`)}
                              onToggleExpand={() => toggleFilter(`trace-${Int.toString(index)}`)}
                            />
                          )->React.array
                        : React.null}
                    </div>
                  </div>
                : <div className="mt-6">
                    <div
                      className="text-center py-8 border-2 border-dashed border-slate-300 rounded-lg">
                      <div className="text-slate-400 mb-3">
                        <svg
                          className="w-8 h-8 mx-auto"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="1"
                            d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
                          />
                        </svg>
                      </div>
                      <h4 className="text-sm font-medium text-slate-600 mb-1">
                        {"No filters added yet"->React.string}
                      </h4>
                      <p className="text-xs text-slate-500">
                        {"Click a button above to add your first filter"->React.string}
                      </p>
                    </div>
                  </div>}
            </div>

            // Section 3: Field Selection
            <div className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm">
              <div className="flex items-center mb-4">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-slate-900">
                    {"Select Fields"->React.string}
                  </h3>
                  <p className="text-sm text-slate-600">
                    {"Choose which data fields to include in your query response"->React.string}
                  </p>
                </div>
                {Array.length(query.fieldSelection.block) > 0 ||
                Array.length(query.fieldSelection.transaction) > 0 ||
                Array.length(query.fieldSelection.log) > 0 ||
                Array.length(query.fieldSelection.trace) > 0
                  ? <div className="ml-auto">
                      <span
                        className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                        {`${Int.toString(
                            Array.length(query.fieldSelection.block) +
                            Array.length(query.fieldSelection.transaction) +
                            Array.length(query.fieldSelection.log) +
                            Array.length(query.fieldSelection.trace),
                          )} fields`->React.string}
                      </span>
                    </div>
                  : React.null}
              </div>
              <FieldSelector
                fieldSelection={query.fieldSelection}
                onFieldSelectionChange={updateFieldSelection}
                tracesSupported={selectedChainSupportsTraces()}
              />
            </div>
          </div>
        </div>
      </div>

      // Right Column - Results
      <div className="w-full lg:w-1/2 overflow-y-auto">
        <div className="p-6 lg:p-4 lg:pl-2">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold text-slate-900 mb-2">
                {"Query Results"->React.string}
              </h2>
              <p className="text-slate-600">
                {"View your generated query, execute it, and see the results."->React.string}
              </p>
            </div>
            <div className="flex items-center">
              <button
                onClick={_ => setExecuteSignal(prev => prev + 1)}
                className="inline-flex items-center px-3 py-1.5 text-xs font-medium text-white bg-slate-700 hover:bg-slate-800 rounded-lg border border-slate-700 transition-colors">
                {"Execute Query"->React.string}
              </button>
            </div>
          </div>
          <QueryResults
            query={query}
            selectedChainName={selectedChainName}
            executeSignal={executeSignal}
            bearerToken={bearerToken}
            customUrl={customUrl}
            availableChains={availableChains}
          />
        </div>
      </div>
    </div>
    </main>
  </>
}
