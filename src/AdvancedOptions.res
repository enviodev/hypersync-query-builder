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
            {"Configure advanced query parameters like slot ranges and limits"->React.string}
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
          // Slot Range
          <div>
            <h4 className="text-md font-medium text-gray-900 mb-3">
              {"Slot Range"->React.string}
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {"From Slot"->React.string}
                </label>
                <input
                  type_="number"
                  value={Int.toString(query.fromSlot)}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({...query, fromSlot: Int.fromString(value)->Option.getOr(0)})
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="0"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {"To Slot (Optional)"->React.string}
                </label>
                <input
                  type_="number"
                  value={switch query.toSlot {
                  | Some(slot) => Int.toString(slot)
                  | None => ""
                  }}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({
                      ...query,
                      toSlot: value === "" ? None : Int.fromString(value),
                    })
                  }}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Latest slot"
                />
              </div>
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
                  {"Max Instructions"->React.string}
                </label>
                <input
                  type_="number"
                  value={switch query.maxNumInstructions {
                  | Some(num) => Int.toString(num)
                  | None => ""
                  }}
                  onChange={e => {
                    let target = ReactEvent.Form.target(e)
                    let value = target["value"]
                    onQueryChange({
                      ...query,
                      maxNumInstructions: value === "" ? None : Int.fromString(value),
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
