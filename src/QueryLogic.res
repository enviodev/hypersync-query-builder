open QueryStructure
open BooleanLogicGenerator

type subTab = Logs | Transactions | Blocks

@react.component
let make = (~query: query) => {
  let (activeSubTab, setActiveSubTab) = React.useState(() => Logs)

  // Check if any filters exist for each type
  let hasLogFilters = switch query.logs {
  | Some(logs) => Array.length(logs) > 0
  | None => false
  }

  let hasTransactionFilters = switch query.transactions {
  | Some(transactions) => Array.length(transactions) > 0
  | None => false
  }

  let hasBlockFilters = switch query.blocks {
  | Some(blocks) => Array.length(blocks) > 0
  | None => false
  }

  <div>
    // Sub-tab Navigation
    <div className="border-b border-gray-200 mb-6">
      <nav className="flex space-x-6">
        <button
          onClick={_ => setActiveSubTab(_ => Logs)}
          className={`py-2 px-1 border-b-2 font-medium text-sm ${activeSubTab === Logs
              ? "border-blue-500 text-blue-600"
              : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}`}>
          <div className="flex items-center space-x-2">
            <span> {"Logs"->React.string} </span>
            {hasLogFilters
              ? <span
                  className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {Int.toString(query.logs->Option.getOr([])->Array.length)->React.string}
                </span>
              : React.null}
          </div>
        </button>
        <button
          onClick={_ => setActiveSubTab(_ => Transactions)}
          className={`py-2 px-1 border-b-2 font-medium text-sm ${activeSubTab === Transactions
              ? "border-blue-500 text-blue-600"
              : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}`}>
          <div className="flex items-center space-x-2">
            <span> {"Transactions"->React.string} </span>
            {hasTransactionFilters
              ? <span
                  className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  {Int.toString(query.transactions->Option.getOr([])->Array.length)->React.string}
                </span>
              : React.null}
          </div>
        </button>
        <button
          onClick={_ => setActiveSubTab(_ => Blocks)}
          className={`py-2 px-1 border-b-2 font-medium text-sm ${activeSubTab === Blocks
              ? "border-blue-500 text-blue-600"
              : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}`}>
          <div className="flex items-center space-x-2">
            <span> {"Blocks"->React.string} </span>
            {hasBlockFilters
              ? <span
                  className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                  {Int.toString(query.blocks->Option.getOr([])->Array.length)->React.string}
                </span>
              : React.null}
          </div>
        </button>
      </nav>
    </div>

    // Sub-tab Content
    <div className="min-h-80">
      {switch activeSubTab {
      | Logs =>
        <div>
          <div className="mb-4">
            <h4 className="text-lg font-medium text-gray-900 mb-2">
              {"Log Filters Boolean Logic"->React.string}
            </h4>
            <p className="text-sm text-gray-600">
              {"Boolean hierarchy for log filtering. Multiple filters are combined with OR logic."->React.string}
            </p>
          </div>

          {hasLogFilters
            ? <div className="space-y-6">
                // English Description
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {"English Description"->React.string}
                  </label>
                  <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
                    <p className="text-sm text-blue-800">
                      {generateMultiFilterDescription(query.logs)->React.string}
                    </p>
                  </div>
                </div>

                // Boolean Hierarchy
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {"Boolean Logic Hierarchy"->React.string}
                  </label>
                  <pre
                    className="bg-gray-50 border border-gray-200 rounded-md p-4 text-sm font-mono whitespace-pre overflow-x-auto">
                    {generateMultiBooleanHierarchy(query.logs)->React.string}
                  </pre>
                </div>
              </div>
            : <div className="text-center py-12">
                <div className="text-gray-400 mb-4">
                  <svg
                    className="w-12 h-12 mx-auto"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="1"
                      d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                    />
                  </svg>
                </div>
                <h4 className="text-lg font-medium text-gray-500 mb-2">
                  {"No Log Filters"->React.string}
                </h4>
                <p className="text-gray-400">
                  {"Add log filters to see the boolean logic visualization"->React.string}
                </p>
              </div>}
        </div>

      | Transactions =>
        <div>
          <div className="mb-4">
            <h4 className="text-lg font-medium text-gray-900 mb-2">
              {"Transaction Filters Boolean Logic"->React.string}
            </h4>
            <p className="text-sm text-gray-600">
              {"Boolean hierarchy for transaction filtering. Multiple filters are combined with OR logic."->React.string}
            </p>
          </div>

          {hasTransactionFilters
            ? <div className="space-y-6">
                // English Description
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {"English Description"->React.string}
                  </label>
                  <div className="bg-green-50 border border-green-200 rounded-md p-4">
                    <p className="text-sm text-green-800">
                      {generateMultiTransactionFilterDescription(query.transactions)->React.string}
                    </p>
                  </div>
                </div>

                // Boolean Hierarchy
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {"Boolean Logic Hierarchy"->React.string}
                  </label>
                  <pre
                    className="bg-gray-50 border border-gray-200 rounded-md p-4 text-sm font-mono whitespace-pre overflow-x-auto">
                    {generateMultiTransactionBooleanHierarchy(query.transactions)->React.string}
                  </pre>
                </div>
              </div>
            : <div className="text-center py-12">
                <div className="text-gray-400 mb-4">
                  <svg
                    className="w-12 h-12 mx-auto"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="1"
                      d="M7 4V2a1 1 0 011-1h4a1 1 0 011 1v2h4a1 1 0 011 1v2a1 1 0 01-1 1h-1v9a2 2 0 01-2 2H8a2 2 0 01-2-2V8H5a1 1 0 01-1-1V5a1 1 0 011-1h4z"
                    />
                  </svg>
                </div>
                <h4 className="text-lg font-medium text-gray-500 mb-2">
                  {"No Transaction Filters"->React.string}
                </h4>
                <p className="text-gray-400">
                  {"Add transaction filters to see the boolean logic visualization"->React.string}
                </p>
              </div>}
        </div>

      | Blocks =>
        <div>
          <div className="mb-4">
            <h4 className="text-lg font-medium text-gray-900 mb-2">
              {"Block Filters Boolean Logic"->React.string}
            </h4>
            <p className="text-sm text-gray-600">
              {"Boolean hierarchy for block filtering. Multiple filters are combined with OR logic."->React.string}
            </p>
          </div>

          {hasBlockFilters
            ? <div className="space-y-6">
                // English Description
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {"English Description"->React.string}
                  </label>
                  <div className="bg-purple-50 border border-purple-200 rounded-md p-4">
                    <p className="text-sm text-purple-800">
                      {generateMultiBlockFilterDescription(query.blocks)->React.string}
                    </p>
                  </div>
                </div>

                // Boolean Hierarchy
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    {"Boolean Logic Hierarchy"->React.string}
                  </label>
                  <pre
                    className="bg-gray-50 border border-gray-200 rounded-md p-4 text-sm font-mono whitespace-pre overflow-x-auto">
                    {generateMultiBlockBooleanHierarchy(query.blocks)->React.string}
                  </pre>
                </div>
              </div>
            : <div className="text-center py-12">
                <div className="text-gray-400 mb-4">
                  <svg
                    className="w-12 h-12 mx-auto"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="1"
                      d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
                    />
                  </svg>
                </div>
                <h4 className="text-lg font-medium text-gray-500 mb-2">
                  {"No Block Filters"->React.string}
                </h4>
                <p className="text-gray-400">
                  {"Add block filters to see the boolean logic visualization"->React.string}
                </p>
              </div>}
        </div>
      }}
    </div>
  </div>
}
