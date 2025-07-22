open QueryStructure

type activeTab = QueryJson | QueryLogic | Results

@react.component
let make = (~query: query, ~selectedChainId: option<int>) => {
  let (activeTab, setActiveTab) = React.useState(() => QueryJson)

  let serializeQuery = (query: query) => {
    // For now, return a simple JSON representation
    // We can enhance this later with proper JSON encoding
    let logsJson = switch query.logs {
    | Some(logs) when Array.length(logs) > 0 => `"logs": [...${Int.toString(Array.length(logs))} filters...]`
    | _ => ""
    }
    
    let transactionsJson = switch query.transactions {
    | Some(transactions) when Array.length(transactions) > 0 => `"transactions": [...${Int.toString(Array.length(transactions))} filters...]`
    | _ => ""
    }
    
    let blocksJson = switch query.blocks {
    | Some(blocks) when Array.length(blocks) > 0 => `"blocks": [...${Int.toString(Array.length(blocks))} filters...]`
    | _ => ""
    }
    
    let fieldSelectionJson = {
      let blockFields = Array.length(query.fieldSelection.block)
      let transactionFields = Array.length(query.fieldSelection.transaction)
      let logFields = Array.length(query.fieldSelection.log)
      
      `"fieldSelection": {
  "block": [${Int.toString(blockFields)} fields selected],
  "transaction": [${Int.toString(transactionFields)} fields selected], 
  "log": [${Int.toString(logFields)} fields selected]
}`
    }
    
    let parts = [logsJson, transactionsJson, blocksJson, fieldSelectionJson]
      ->Array.filter(part => part !== "")
    
    let content = if Array.length(parts) > 0 {
      Array.join(parts, ",\n  ")
    } else {
      ""
    }
    
    `{
  "fromBlock": ${Int.toString(query.fromBlock)},
  ${content}
}`
  }

  <div className="bg-white rounded-lg shadow p-6">
    <div className="mb-6">
      <h3 className="text-lg font-medium text-gray-900 mb-2">
        {"Results"->React.string}
      </h3>
      <p className="text-sm text-gray-500">
        {"View your query structure and results"->React.string}
      </p>
      {switch selectedChainId {
      | Some(chainId) => 
        <div className="mt-2">
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
            {`Query URL: https://${Int.toString(chainId)}.hypersync.xyz/query`->React.string}
          </span>
        </div>
      | None => React.null
      }}
    </div>

    // Tab Navigation
    <div className="border-b border-gray-200 mb-6">
      <nav className="flex space-x-8">
        <button
          onClick={_ => setActiveTab(_ => QueryJson)}
          className={`py-2 px-1 border-b-2 font-medium text-sm ${
            activeTab === QueryJson 
              ? "border-blue-500 text-blue-600" 
              : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
          }`}>
          {"Query JSON"->React.string}
        </button>
        <button
          onClick={_ => setActiveTab(_ => QueryLogic)}
          className={`py-2 px-1 border-b-2 font-medium text-sm ${
            activeTab === QueryLogic 
              ? "border-blue-500 text-blue-600" 
              : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
          }`}>
          {"Query Logic"->React.string}
        </button>
        <button
          onClick={_ => setActiveTab(_ => Results)}
          className={`py-2 px-1 border-b-2 font-medium text-sm ${
            activeTab === Results 
              ? "border-blue-500 text-blue-600" 
              : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
          }`}>
          {"Results"->React.string}
        </button>
      </nav>
    </div>

    // Tab Content
    <div className="min-h-96">
      {switch activeTab {
      | QueryJson => 
        <div>
          <h4 className="text-sm font-medium text-gray-900 mb-3">{"Query Structure"->React.string}</h4>
          <pre className="bg-gray-50 border border-gray-200 rounded-md p-4 text-sm font-mono overflow-x-auto whitespace-pre">
            {serializeQuery(query)->React.string}
          </pre>
          <div className="mt-4 text-xs text-gray-500">
            {"This is a simplified representation. The actual query will include all filter details."->React.string}
          </div>
        </div>
      
      | QueryLogic => 
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">
            <svg className="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
            </svg>
          </div>
          <h4 className="text-lg font-medium text-gray-500 mb-2">{"Query Logic"->React.string}</h4>
          <p className="text-gray-400">{"Logic visualization coming soon..."->React.string}</p>
        </div>

      | Results => 
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">
            <svg className="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
          <h4 className="text-lg font-medium text-gray-500 mb-2">{"Query Results"->React.string}</h4>
          <p className="text-gray-400">{"Execute query to see results here..."->React.string}</p>
          {switch selectedChainId {
          | Some(_) => 
            <button className="mt-4 px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
              {"Execute Query"->React.string}
            </button>
          | None => 
            <div className="mt-4 text-sm text-orange-600">
              {"Please select a chain to execute queries"->React.string}
            </div>
          }}
        </div>
      }}
    </div>
  </div>
} 
