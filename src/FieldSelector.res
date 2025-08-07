open QueryStructure
open TagSelector

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
        className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 rounded-full bg-indigo-500"></div>
            <h4 className="font-semibold text-slate-900 text-sm">
              {"Block Fields"->React.string}
            </h4>
            <span
              className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
              {`${Int.toString(Array.length(fieldSelection.block))}`->React.string}
            </span>
          </div>
          <div className="flex space-x-1">
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
        <TagSelector
          title=""
          placeholder="Select block fields..."
          options={blockFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.block}
          onSelectionChange={updateBlockFields}
        />
      </div>

      // Transaction Fields
      <div
        className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 rounded-full bg-emerald-500"></div>
            <h4 className="font-semibold text-slate-900 text-sm">
              {"Transaction Fields"->React.string}
            </h4>
            <span
              className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
              {`${Int.toString(Array.length(fieldSelection.transaction))}`->React.string}
            </span>
          </div>
          <div className="flex space-x-1">
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
        <TagSelector
          title=""
          placeholder="Select transaction fields..."
          options={transactionFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.transaction}
          onSelectionChange={updateTransactionFields}
        />
      </div>

      // Log Fields
      <div
        className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 rounded-full bg-slate-700"></div>
            <h4 className="font-semibold text-slate-900 text-sm"> {"Log Fields"->React.string} </h4>
            <span
              className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
              {`${Int.toString(Array.length(fieldSelection.log))}`->React.string}
            </span>
          </div>
          <div className="flex space-x-1">
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
        <TagSelector
          title=""
          placeholder="Select log fields..."
          options={logFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.log}
          onSelectionChange={updateLogFields}
        />
      </div>

      // Trace Fields
      {tracesSupported
        ? <div
            className="bg-white border border-slate-200 rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-2">
                <div className="w-3 h-3 rounded-full bg-amber-500"></div>
                <h4 className="font-semibold text-slate-900 text-sm">
                  {"Trace Fields"->React.string}
                </h4>
                <span
                  className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                  {`${Int.toString(Array.length(fieldSelection.trace))}`->React.string}
                </span>
              </div>
              <div className="flex space-x-1">
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
            <TagSelector
              title=""
              placeholder="Select trace fields..."
              options={traceFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
              selectedValues={fieldSelection.trace}
              onSelectionChange={updateTraceFields}
            />
          </div>
        : React.null}
    </div>
  </div>
}
