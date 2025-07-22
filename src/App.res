%%raw(`import './App.css'`)
%%raw(`import './tailwind.css'`)

open QueryStructure

@react.component
let make = () => {
  let (query, setQuery) = React.useState(() => {
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
    maxNumBlocks: None,
    maxNumTransactions: None,
    maxNumLogs: None,
    maxNumTraces: None,
    joinMode: None,
  })

  let (selectedChainId, setSelectedChainId) = React.useState(() => None)

  let updateFieldSelection = (newFieldSelection: fieldSelection) => {
    setQuery(prev => {...prev, fieldSelection: newFieldSelection})
  }

  let addLogFilter = () => {
    let newLogFilter: logSelection = {
      address: None,
      topics: None,
    }
    setQuery(prev => {
      ...prev,
      logs: Some(Array.concat(prev.logs->Option.getOr([]), [newLogFilter])),
    })
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
  }

  let addTransactionFilter = () => {
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
      {...prev, transactions: Array.length(updatedTransactions) > 0 ? Some(updatedTransactions) : None}
    })
  }

  let addBlockFilter = () => {
    let newBlockFilter: blockSelection = {
      hash: None,
      miner: None,
    }
    setQuery(prev => {
      ...prev,
      blocks: Some(Array.concat(prev.blocks->Option.getOr([]), [newBlockFilter])),
    })
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
  }

  <div className="min-h-screen bg-gray-50">
    <header className="bg-white shadow-sm border-b">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <h1 className="text-xl font-semibold text-gray-900">
              {"HyperSync Query Builder"->React.string}
            </h1>
          </div>
          <div className="text-sm text-gray-500">
            {"Build blockchain queries with ease"->React.string}
          </div>
        </div>
      </div>
    </header>
    <main className="flex-1 overflow-y-auto py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            {"Create Your Query"->React.string}
          </h2>
          <p className="text-gray-600">
            {"Select a chain, configure your filters, and choose fields for your blockchain query."->React.string}
          </p>
        </div>

        // Chain Selection
        <ChainSelector 
          selectedChainId={selectedChainId}
          onChainSelect={chainId => setSelectedChainId(_ => Some(chainId))}
        />

        // Add Filter Buttons
        <div className="mb-8">
          <h3 className="text-lg font-medium text-gray-900 mb-4">{"Add Filters"->React.string}</h3>
          <div className="flex flex-wrap gap-3">
            <button
              onClick={_ => addLogFilter()}
              className="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              {"Add Log Filter"->React.string}
            </button>
            <button
              onClick={_ => addTransactionFilter()}
              className="inline-flex items-center px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500">
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              {"Add Transaction Filter"->React.string}
            </button>
            <button
              onClick={_ => addBlockFilter()}
              className="inline-flex items-center px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500">
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              {"Add Block Filter"->React.string}
            </button>
          </div>
        </div>

        // Filters
        <div className="space-y-4 mb-8">
          // Log Filters
          {Array.mapWithIndex(query.logs->Option.getOr([]), (logFilter, index) =>
            <LogFilter
              key={`log-${Int.toString(index)}`}
              filterState={logFilter}
              onFilterChange={newFilter => updateLogFilter(index, newFilter)}
              onRemove={() => removeLogFilter(index)}
              filterIndex={index}
            />
          )->React.array}

          // Transaction Filters
          {Array.mapWithIndex(query.transactions->Option.getOr([]), (transactionFilter, index) =>
            <TransactionFilter
              key={`transaction-${Int.toString(index)}`}
              filterState={transactionFilter}
              onFilterChange={newFilter => updateTransactionFilter(index, newFilter)}
              onRemove={() => removeTransactionFilter(index)}
              filterIndex={index}
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
            />
          )->React.array}

          // Empty state message
          {Array.length(query.logs->Option.getOr([])) === 0 && 
           Array.length(query.transactions->Option.getOr([])) === 0 && 
           Array.length(query.blocks->Option.getOr([])) === 0
            ? <div className="text-center py-12">
                <div className="text-gray-400 mb-4">
                  <svg className="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
                  </svg>
                </div>
                <h3 className="text-lg font-medium text-gray-500 mb-2">{"No filters added yet"->React.string}</h3>
                <p className="text-gray-400">{"Click one of the buttons above to add your first filter"->React.string}</p>
              </div>
            : React.null}
        </div>

        // Field Selection
        <FieldSelector 
          fieldSelection={query.fieldSelection}
          onFieldSelectionChange={updateFieldSelection}
        />

        // Results
        <QueryResults 
          query={query}
          selectedChainId={selectedChainId}
        />
      </div>
    </main>
    <footer className="bg-white border-t mt-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex items-center justify-center space-x-4 text-sm text-gray-500">
          <span>
            {"Proudly made by Envio - the team behind the best blockchain indexing tool"->React.string}
          </span>
        </div>
      </div>
    </footer>
  </div>
}
