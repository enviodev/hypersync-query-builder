%%raw(`import './App.css'`)
%%raw(`import './tailwind.css'`)

open QueryStructure

// Combined filter state using proper QueryStructure types
// TODO: this should use the QueryStructure.query type (not this custom type) - and it should be shared everywhere.
///      Some of the fields in the query are not implemented yet so just default to sensible values or none if it is an option.
type sharedQueryState = {
  logFilter: logSelection,
  transactionFilter: transactionSelection,
  blockFilter: blockSelection,
}

// I believe each component should keep track if it is expanded or not? (since there could be many of them, or an array of them)?
// I may be wrong on this. 
type sectionExpansion = {
  logs: bool,
  transactions: bool,
  blocks: bool,
}

@react.component
let make = () => {
  let (queryState, setQueryState) = React.useState(() => {
    logFilter: {
      address: None,
      topics: None,
    },
    transactionFilter: {
      from_: None,
      to_: None,
      sighash: None,
      status: None,
      kind: None,
      contractAddress: None,
      authorizationList: None,
    },
    blockFilter: {
      hash: None,
      miner: None,
    },
  })

  let (expandedSections, setExpandedSections) = React.useState(() => {
    logs: false,
    transactions: false,
    blocks: false,
  })

  let toggleSection = (section: [#logs | #transactions | #blocks]) => {
    setExpandedSections(prev => 
      switch section {
      | #logs => {...prev, logs: !prev.logs}
      | #transactions => {...prev, transactions: !prev.transactions}
      | #blocks => {...prev, blocks: !prev.blocks}
      }
    )
  }

  let updateLogFilter = (newLogFilter: logSelection) => {
    setQueryState(prev => {...prev, logFilter: newLogFilter})
  }

  let updateTransactionFilter = (newTransactionFilter: transactionSelection) => {
    setQueryState(prev => {...prev, transactionFilter: newTransactionFilter})
  }

  let updateBlockFilter = (newBlockFilter: blockSelection) => {
    setQueryState(prev => {...prev, blockFilter: newBlockFilter})
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
            {"Start by adding filters for logs, transactions, and blocks. Configure your query parameters below."->React.string}
          </p>
        </div>
        <div className="space-y-4">
          <LogFilter
            filterState={queryState.logFilter}
            onFilterChange={updateLogFilter}
            isExpanded={expandedSections.logs}
            onToggleExpanded={() => toggleSection(#logs)}
          />
          <TransactionFilter
            filterState={queryState.transactionFilter}
            onFilterChange={updateTransactionFilter}
            isExpanded={expandedSections.transactions}
            onToggleExpanded={() => toggleSection(#transactions)}
          />
          <BlockFilter
            filterState={queryState.blockFilter}
            onFilterChange={updateBlockFilter}
            isExpanded={expandedSections.blocks}
            onToggleExpanded={() => toggleSection(#blocks)}
          />
        </div>
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
