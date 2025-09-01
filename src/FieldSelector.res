open QueryStructure

let snakeToCamel = (input: string): string =>
  Js.String.split("_", input)
  ->Belt.Array.keep(s => s != "")
  ->Belt.Array.reduceWithIndex("", (acc, s, i) =>
    if i == 0 {
      acc ++ s
    } else {
      acc ++
      Js.String.toUpperCase(Js.String.slice(~from=0, ~to_=1, s)) ++
      Js.String.slice(~from=1, ~to_=Js.String.length(s), s)
    }
  )

let snakeToTitle = (input: string): string =>
  Js.String.split("_", input)
  ->Belt.Array.keep(s => s != "")
  ->Belt.Array.map(s =>
    Js.String.toUpperCase(Js.String.slice(~from=0, ~to_=1, s)) ++
    Js.String.slice(~from=1, ~to_=Js.String.length(s), s)
  )
  ->Array.join(" ")

let camelToSnake = (input: string): string => {
  let re = Js.Re.fromStringWithFlags("[A-Z]", ~flags="g")
  Js.String.unsafeReplaceBy0(
    re,
    (matchPart, _, _) => "_" ++ Js.String.toLowerCase(matchPart),
    input,
  )
}

let blockFieldToSnakeCaseString = (field: blockField) => Obj.magic(field)
let transactionFieldToSnakeCaseString = (field: transactionField) => Obj.magic(field)
let logFieldToSnakeCaseString = (field: logField) => Obj.magic(field)
let traceFieldToSnakeCaseString = (field: traceField) => Obj.magic(field)

let blockFieldToCamelCaseString = field => snakeToCamel(blockFieldToSnakeCaseString(field))
let transactionFieldToCamelCaseString = field =>
  snakeToCamel(transactionFieldToSnakeCaseString(field))
let logFieldToCamelCaseString = field => snakeToCamel(logFieldToSnakeCaseString(field))
let traceFieldToCamelCaseString = field => snakeToCamel(traceFieldToSnakeCaseString(field))

let blockFieldToDisplayString = field => snakeToTitle(blockFieldToSnakeCaseString(field))
let transactionFieldToDisplayString = field =>
  snakeToTitle(transactionFieldToSnakeCaseString(field))
let logFieldToDisplayString = field => snakeToTitle(logFieldToSnakeCaseString(field))
let traceFieldToDisplayString = field => snakeToTitle(traceFieldToSnakeCaseString(field))

let blockFieldOptions = Array.map(QueryStructure.allBlockFields, field => (
  field,
  snakeToTitle(blockFieldToSnakeCaseString(field)),
))

let transactionFieldOptions = Array.map(QueryStructure.allTransactionFields, field => (
  field,
  snakeToTitle(transactionFieldToSnakeCaseString(field)),
))

let logFieldOptions = Array.map(QueryStructure.allLogFields, field => (
  field,
  snakeToTitle(logFieldToSnakeCaseString(field)),
))

let traceFieldOptions = Array.map(QueryStructure.allTraceFields, field => (
  field,
  snakeToTitle(traceFieldToSnakeCaseString(field)),
))

@react.component
let make = (
  ~fieldSelection: fieldSelection,
  ~onFieldSelectionChange: fieldSelection => unit,
  ~tracesSupported: bool,
) => {
  let (expandedSections, setExpandedSections) = React.useState(() => [])

  let toggleSection = (sectionName: string) => {
    setExpandedSections(prev =>
      if Array.includes(prev, sectionName) {
        Array.filter(prev, s => s !== sectionName)
      } else {
        Array.concat(prev, [sectionName])
      }
    )
  }

  let isSectionExpanded = (sectionName: string) => Array.includes(expandedSections, sectionName)
  let updateBlockFields = newFields => onFieldSelectionChange({...fieldSelection, block: newFields})
  let updateTransactionFields = newFields =>
    onFieldSelectionChange({...fieldSelection, transaction: newFields})
  let updateLogFields = newFields => onFieldSelectionChange({...fieldSelection, log: newFields})
  let updateTraceFields = newFields => onFieldSelectionChange({...fieldSelection, trace: newFields})

  let selectAllBlockFields = () => {
    let allFields = Array.map(blockFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, block: allFields})
  }

  let clearAllBlockFields = () => {
    onFieldSelectionChange({...fieldSelection, block: []})
  }

  let selectAllTransactionFields = () => {
    let allFields = Array.map(transactionFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, transaction: allFields})
  }

  let clearAllTransactionFields = () => {
    onFieldSelectionChange({...fieldSelection, transaction: []})
  }

  let selectAllLogFields = () => {
    let allFields = Array.map(logFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, log: allFields})
  }

  let clearAllLogFields = () => {
    onFieldSelectionChange({...fieldSelection, log: []})
  }

  let selectAllTraceFields = () => {
    let allFields = Array.map(traceFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, trace: allFields})
  }

  let clearAllTraceFields = () => {
    onFieldSelectionChange({...fieldSelection, trace: []})
  }

  <div className="space-y-6">
    <div
      className={`grid grid-cols-1 ${tracesSupported
          ? "md:grid-cols-2 lg:grid-cols-4"
          : "md:grid-cols-2 lg:grid-cols-3"} gap-4`}>
      // Block Fields
      <div
        className="bg-white border border-slate-200 rounded-xl p-4 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
        <div className="flex items-center justify-between mb-3 gap-2 flex-wrap">
          <button
            onClick={_ => toggleSection("block")}
            className="flex items-center space-x-2 text-left hover:bg-slate-50 rounded-lg p-1 -m-1 transition-colors">
            <div className="flex items-center space-x-2">
              <svg
                className={`w-4 h-4 text-slate-500 transition-transform ${isSectionExpanded("block")
                    ? "rotate-90"
                    : ""}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24">
                <path
                  strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"
                />
              </svg>
              <h4 className="font-semibold text-slate-900 text-sm">
                {"Block Fields"->React.string}
              </h4>
              <span
                className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                {`${Int.toString(Array.length(fieldSelection.block))}`->React.string}
              </span>
            </div>
          </button>
          <div className="flex space-x-1 flex-shrink-0">
            <button
              onClick={_ => selectAllBlockFields()}
              className="text-xs px-2 py-1 text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 rounded transition-colors">
              {"All"->React.string}
            </button>
            <button
              onClick={_ => clearAllBlockFields()}
              className="text-xs px-2 py-1 text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded transition-colors">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        {isSectionExpanded("block")
          ? <div className="space-y-3">
              <div className="space-y-2">
                {blockFieldOptions
                ->Array.map(((field, label)) =>
                  <label
                    key={label}
                    className="flex items-center space-x-3 p-2 rounded-lg hover:bg-slate-50 cursor-pointer transition-colors group">
                    <input
                      type_="checkbox"
                      checked={Array.includes(fieldSelection.block, field)}
                      onChange={_ => {
                        if Array.includes(fieldSelection.block, field) {
                          updateBlockFields(Array.filter(fieldSelection.block, f => f !== field))
                        } else {
                          updateBlockFields(Array.concat(fieldSelection.block, [field]))
                        }
                      }}
                      className="w-4 h-4 text-indigo-600 bg-white border-slate-300 rounded focus:ring-indigo-500 focus:ring-2"
                    />
                    <span
                      className="text-sm text-slate-700 group-hover:text-slate-900 transition-colors">
                      {label->React.string}
                    </span>
                  </label>
                )
                ->React.array}
              </div>
            </div>
          : React.null}
      </div>

      // Transaction Fields
      <div
        className="bg-white border border-slate-200 rounded-xl p-4 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
        <div className="flex items-center justify-between mb-3 gap-2 flex-wrap">
          <button
            onClick={_ => toggleSection("transaction")}
            className="flex items-center space-x-2 text-left hover:bg-slate-50 rounded-lg p-1 -m-1 transition-colors">
            <div className="flex items-center space-x-2">
              <svg
                className={`w-4 h-4 text-slate-500 transition-transform ${isSectionExpanded(
                    "transaction",
                  )
                    ? "rotate-90"
                    : ""}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24">
                <path
                  strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"
                />
              </svg>
              <h4 className="font-semibold text-slate-900 text-sm">
                {"Transaction Fields"->React.string}
              </h4>
              <span
                className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                {`${Int.toString(Array.length(fieldSelection.transaction))}`->React.string}
              </span>
            </div>
          </button>
          <div className="flex space-x-1 flex-shrink-0">
            <button
              onClick={_ => selectAllTransactionFields()}
              className="text-xs px-2 py-1 text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50 rounded transition-colors">
              {"All"->React.string}
            </button>
            <button
              onClick={_ => clearAllTransactionFields()}
              className="text-xs px-2 py-1 text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded transition-colors">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        {isSectionExpanded("transaction")
          ? <div className="space-y-3">
              <div className="space-y-2">
                {transactionFieldOptions
                ->Array.map(((field, label)) =>
                  <label
                    key={label}
                    className="flex items-center space-x-3 p-2 rounded-lg hover:bg-slate-50 cursor-pointer transition-colors group">
                    <input
                      type_="checkbox"
                      checked={Array.includes(fieldSelection.transaction, field)}
                      onChange={_ => {
                        if Array.includes(fieldSelection.transaction, field) {
                          updateTransactionFields(
                            Array.filter(fieldSelection.transaction, f => f !== field),
                          )
                        } else {
                          updateTransactionFields(Array.concat(fieldSelection.transaction, [field]))
                        }
                      }}
                      className="w-4 h-4 text-emerald-600 bg-white border-slate-300 rounded focus:ring-emerald-500 focus:ring-2"
                    />
                    <span
                      className="text-sm text-slate-700 group-hover:text-slate-900 transition-colors">
                      {label->React.string}
                    </span>
                  </label>
                )
                ->React.array}
              </div>
            </div>
          : React.null}
      </div>

      // Log Fields
      <div
        className="bg-white border border-slate-200 rounded-xl p-4 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
        <div className="flex items-center justify-between mb-3 gap-2 flex-wrap">
          <button
            onClick={_ => toggleSection("log")}
            className="flex items-center space-x-2 text-left hover:bg-slate-50 rounded-lg p-1 -m-1 transition-colors">
            <div className="flex items-center space-x-2">
              <svg
                className={`w-4 h-4 text-slate-500 transition-transform ${isSectionExpanded("log")
                    ? "rotate-90"
                    : ""}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24">
                <path
                  strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"
                />
              </svg>
              <h4 className="font-semibold text-slate-900 text-sm">
                {"Log Fields"->React.string}
              </h4>
              <span
                className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                {`${Int.toString(Array.length(fieldSelection.log))}`->React.string}
              </span>
            </div>
          </button>
          <div className="flex space-x-1 flex-shrink-0">
            <button
              onClick={_ => selectAllLogFields()}
              className="text-xs px-2 py-1 text-slate-600 hover:text-slate-700 hover:bg-slate-50 rounded transition-colors">
              {"All"->React.string}
            </button>
            <button
              onClick={_ => clearAllLogFields()}
              className="text-xs px-2 py-1 text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded transition-colors">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        {isSectionExpanded("log")
          ? <div className="space-y-3">
              <div className="space-y-2">
                {logFieldOptions
                ->Array.map(((field, label)) =>
                  <label
                    key={label}
                    className="flex items-center space-x-3 p-2 rounded-lg hover:bg-slate-50 cursor-pointer transition-colors group">
                    <input
                      type_="checkbox"
                      checked={Array.includes(fieldSelection.log, field)}
                      onChange={_ => {
                        if Array.includes(fieldSelection.log, field) {
                          updateLogFields(Array.filter(fieldSelection.log, f => f !== field))
                        } else {
                          updateLogFields(Array.concat(fieldSelection.log, [field]))
                        }
                      }}
                      className="w-4 h-4 text-slate-600 bg-white border-slate-300 rounded focus:ring-slate-500 focus:ring-2"
                    />
                    <span
                      className="text-sm text-slate-700 group-hover:text-slate-900 transition-colors">
                      {label->React.string}
                    </span>
                  </label>
                )
                ->React.array}
              </div>
            </div>
          : React.null}
      </div>

      // Trace Fields
      {tracesSupported
        ? <div
            className="bg-white border border-slate-200 rounded-xl p-4 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between mb-3 gap-2 flex-wrap">
              <button
                onClick={_ => toggleSection("trace")}
                className="flex items-center space-x-2 text-left hover:bg-slate-50 rounded-lg p-1 -m-1 transition-colors">
                <div className="flex items-center space-x-2">
                  <svg
                    className={`w-4 h-4 text-slate-500 transition-transform ${isSectionExpanded(
                        "trace",
                      )
                        ? "rotate-90"
                        : ""}`}
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"
                    />
                  </svg>
                  <h4 className="font-semibold text-slate-900 text-sm">
                    {"Trace Fields"->React.string}
                  </h4>
                  <span
                    className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                    {`${Int.toString(Array.length(fieldSelection.trace))}`->React.string}
                  </span>
                </div>
              </button>
              <div className="flex space-x-1 flex-shrink-0">
                <button
                  onClick={_ => selectAllTraceFields()}
                  className="text-xs px-2 py-1 text-amber-600 hover:text-amber-700 hover:bg-amber-50 rounded transition-colors">
                  {"All"->React.string}
                </button>
                <button
                  onClick={_ => clearAllTraceFields()}
                  className="text-xs px-2 py-1 text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded transition-colors">
                  {"Clear"->React.string}
                </button>
              </div>
            </div>
            {isSectionExpanded("trace")
              ? <div className="space-y-3">
                  <div className="space-y-2">
                    {traceFieldOptions
                    ->Array.map(((field, label)) =>
                      <label
                        key={label}
                        className="flex items-center space-x-3 p-2 rounded-lg hover:bg-slate-50 cursor-pointer transition-colors group">
                        <input
                          type_="checkbox"
                          checked={Array.includes(fieldSelection.trace, field)}
                          onChange={_ => {
                            if Array.includes(fieldSelection.trace, field) {
                              updateTraceFields(
                                Array.filter(fieldSelection.trace, f => f !== field),
                              )
                            } else {
                              updateTraceFields(Array.concat(fieldSelection.trace, [field]))
                            }
                          }}
                          className="w-4 h-4 text-amber-600 bg-white border-slate-300 rounded focus:ring-amber-500 focus:ring-2"
                        />
                        <span
                          className="text-sm text-slate-700 group-hover:text-slate-900 transition-colors">
                          {label->React.string}
                        </span>
                      </label>
                    )
                    ->React.array}
                  </div>
                </div>
              : React.null}
          </div>
        : React.null}
    </div>
  </div>
}
