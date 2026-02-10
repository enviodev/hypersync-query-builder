open QueryStructure

@react.component
let make = (~query: QueryStructure.query, ~onQueryChange: QueryStructure.query => unit) => {
  let (isExpanded, setIsExpanded) = React.useState(() => false)

  <div className="mb-8 bg-white shadow rounded-lg">
    <div className="px-6 py-4 border-b border-gray-200">
      <button
        onClick={_ => setIsExpanded(prev => !prev)}
        className="flex items-center justify-between w-full text-left focus:outline-none focus:ring-2 focus:ring-blue-500 rounded"
      >
        <div>
          <h3 className="text-lg font-medium text-gray-900">
            {"Advanced Options"->React.string}
          </h3>
          <p className="text-sm text-gray-600 mt-1">
            {"Configure advanced query parameters like block ranges, join modes, and limits"->React.string}
          </p>
        </div>
        <svg
          className={`w-5 h-5 text-gray-500 transform transition-transform duration-200 ${isExpanded
              ? "rotate-180"
              : ""}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
    </div>

    {isExpanded
      ? <div className="p-6 space-y-6">
          // Block Range
          <div>
            <h4 className="text-md font-medium text-gray-900 mb-3">
              {"Block Range"->React.string}
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {"From Block"->React.string}
                </label>
                <input
                  type_="number"
                  value={Int.toString(query.fromBlock)}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({...query, fromBlock: Int.fromString(value)->Option.getOr(0)})
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="0"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {"To Block (Optional)"->React.string}
                </label>
                <input
                  type_="number"
                  value={switch query.toBlock {
                  | Some(block) => Int.toString(block)
                  | None => ""
                  }}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({
                      ...query,
                      toBlock: value === "" ? None : Int.fromString(value),
                    })
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Latest block"
                />
              </div>
            </div>
          </div>

          // Join Mode
          <div>
            <h4 className="text-md font-medium text-gray-900 mb-3">
              {"Join Mode"->React.string}
            </h4>
            <p className="text-sm text-gray-600 mb-3">
              {"Controls how data from different sources (logs, transactions, blocks) are related"->React.string}
            </p>
            <div className="space-y-2">
              <label className="flex items-center">
                <input
                  type_="radio"
                  name="joinMode"
                  checked={switch query.joinMode {
                  | Some(Default) => true
                  | Some(_) => false
                  | None => true
                  }}
                  onChange={_ => onQueryChange({...query, joinMode: Some(Default)})}
                  className="text-blue-600 focus:ring-blue-500"
                />
                <span className="ml-2 text-sm text-gray-700">
                  <strong> {"Default"->React.string} </strong>
                  {" - Standard join behavior (recommended)"->React.string}
                </span>
              </label>
              <label className="flex items-center">
                <input
                  type_="radio"
                  name="joinMode"
                  checked={switch query.joinMode {
                  | Some(JoinAll) => true
                  | _ => false
                  }}
                  onChange={_ => onQueryChange({...query, joinMode: Some(JoinAll)})}
                  className="text-blue-600 focus:ring-blue-500"
                />
                <span className="ml-2 text-sm text-gray-700">
                  <strong> {"Join All"->React.string} </strong>
                  {" - Include all relationships between data"->React.string}
                </span>
              </label>
              <label className="flex items-center">
                <input
                  type_="radio"
                  name="joinMode"
                  checked={switch query.joinMode {
                  | Some(JoinNothing) => true
                  | _ => false
                  }}
                  onChange={_ => onQueryChange({...query, joinMode: Some(JoinNothing)})}
                  className="text-blue-600 focus:ring-blue-500"
                />
                <span className="ml-2 text-sm text-gray-700">
                  <strong> {"Join Nothing"->React.string} </strong>
                  {" - Return data without relationships"->React.string}
                </span>
              </label>
            </div>
          </div>

          // Include All Blocks
          <div>
            <label className="flex items-center">
              <input
                type_="checkbox"
                checked={query.includeAllBlocks->Option.getOr(false)}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  let checked = target["checked"]
                  onQueryChange({...query, includeAllBlocks: Some(checked)})
                }}
                className="text-blue-600 focus:ring-blue-500 rounded"
              />
              <span className="ml-2">
                <span className="text-sm font-medium text-gray-700">
                  {"Include All Blocks"->React.string}
                </span>
                <p className="text-xs text-gray-500">
                  {"Include blocks even if they don't match other filters"->React.string}
                </p>
              </span>
            </label>
          </div>

          // Result Limits
          <div>
            <h4 className="text-md font-medium text-gray-900 mb-3">
              {"Result Limits"->React.string}
            </h4>
            <p className="text-sm text-gray-600 mb-3">
              {"Set maximum number of results to return (leave empty for no limit)"->React.string}
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {"Max Blocks"->React.string}
                </label>
                <input
                  type_="number"
                  value={switch query.maxNumBlocks {
                  | Some(num) => Int.toString(num)
                  | None => ""
                  }}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({
                      ...query,
                      maxNumBlocks: value === "" ? None : Int.fromString(value),
                    })
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="No limit"
                  min="1"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {"Max Transactions"->React.string}
                </label>
                <input
                  type_="number"
                  value={switch query.maxNumTransactions {
                  | Some(num) => Int.toString(num)
                  | None => ""
                  }}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({
                      ...query,
                      maxNumTransactions: value === "" ? None : Int.fromString(value),
                    })
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="No limit"
                  min="1"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {"Max Logs"->React.string}
                </label>
                <input
                  type_="number"
                  value={switch query.maxNumLogs {
                  | Some(num) => Int.toString(num)
                  | None => ""
                  }}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({
                      ...query,
                      maxNumLogs: value === "" ? None : Int.fromString(value),
                    })
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="No limit"
                  min="1"
                />
              </div>
            </div>
          </div>
        </div>
      : React.null}
  </div>
}
