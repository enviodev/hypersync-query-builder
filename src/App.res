%%raw(`import './App.css'`)
%%raw(`import './tailwind.css'`)

open QueryStructure
open UrlEncoder

@react.component
let make = () => {
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
    // Try to load selectedChainName from URL first, fallback to None
    switch UrlEncoder.getUrlStateFromUrl() {
    | Some(urlState) => urlState.selectedChainName
    | None => None
    }
  })
  let (expandedFilterKey, setExpandedFilterKey) = React.useState(() => None)

  // Helper function to check if selected chain supports traces
  let selectedChainSupportsTraces = () => {
    switch selectedChainName {
    | Some(chainName) =>
      // Find the selected chain in the default chains list
      let selectedChain = ChainSelector.defaultChains->Array.find(chain => chain.name === chainName)
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

  // Update URL when query or selectedChainName changes
  React.useEffect1(() => {
    UrlEncoder.updateUrlWithState({query, selectedChainName})
    None
  }, [(query, selectedChainName)])

  // Clear trace-related data when a non-traces network is selected
  React.useEffect1(() => {
    switch selectedChainName {
    | Some(chainName) =>
      let selectedChain = ChainSelector.defaultChains->Array.find(chain => chain.name === chainName)
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

  <main className="flex-1 overflow-hidden bg-slate-50">
    <div className="h-full flex flex-col lg:flex-row bg-white">
      // Left Column - Query Builder
      <div
        className="w-full lg:w-1/2 border-r-0 lg:border-r border-b lg:border-b-0 border-slate-200 overflow-y-auto bg-white">
        <div className="p-6 lg:p-8">
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-slate-900 mb-2">
              {"Create Your Query"->React.string}
            </h2>
          </div>

          <div className="space-y-6">
            // Section 1: Configuration
            <div className="bg-slate-50 rounded-xl p-6 border-l-4 border-slate-600">
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
                  onChainSelect={chainName => setSelectedChainName(_ => Some(chainName))}
                />
              </div>

              // Advanced Options
              <AdvancedOptions query={query} onQueryChange={newQuery => setQuery(_ => newQuery)} />
            </div>

            // Section 2: Filters
            <div className="bg-slate-50 rounded-xl p-6 border-l-4 border-slate-600">
              <div className="flex items-center mb-4">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-slate-900">
                    {"Add Filters"->React.string}
                  </h3>
                  <p className="text-sm text-slate-600">
                    {"Define what data you want to retrieve (logs, transactions, blocks)"->React.string}
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

              <div className="mb-6">
                <div className="flex flex-wrap gap-3">
                  <button
                    onClick={_ => addLogFilter()}
                    className="inline-flex items-center px-4 py-2 bg-slate-700 text-white text-sm font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
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
                    className="inline-flex items-center px-4 py-2 bg-emerald-600 text-white text-sm font-medium rounded-lg hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-colors">
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
                    className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 transition-colors">
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
                        className="inline-flex items-center px-4 py-2 bg-amber-600 text-white text-sm font-medium rounded-lg hover:bg-amber-700 focus:outline-none focus:ring-2 focus:ring-amber-500 transition-colors">
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
                ? <div className="mt-6">
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
            <div className="bg-slate-50 rounded-xl p-6 border-l-4 border-slate-600">
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
      <div className="w-full lg:w-1/2 overflow-y-auto bg-slate-50">
        <div className="p-6 lg:p-8">
          <div className="mb-6">
            <h2 className="text-2xl font-bold text-slate-900 mb-2">
              {"Query Results"->React.string}
            </h2>
            <p className="text-slate-600">
              {"View your generated query, execute it, and see the results."->React.string}
            </p>
          </div>
          <QueryResults query={query} selectedChainName={selectedChainName} />
        </div>
      </div>
    </div>
  </main>
}
