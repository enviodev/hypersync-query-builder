open QueryStructure
open TagSelector

type activeSection =
  | Block
  | Transaction
  | Log
  | Trace

let snakeToCamel = (input: string): string =>
  Js.String.split("_", input)
  ->Belt.Array.keep(s => s != "")
  ->Belt.Array.reduceWithIndex("", (acc, s, i) =>
    if i == 0 {
      acc ++ s
    } else {
      acc ++
      String.toUpperCase(Js.String.slice(~from=0, ~to_=1, s)) ++
      Js.String.slice(~from=1, ~to_=String.length(s), s)
    }
  )

let snakeToTitle = (input: string): string =>
  Js.String.split("_", input)
  ->Belt.Array.keep(s => s != "")
  ->Belt.Array.map(s =>
    String.toUpperCase(Js.String.slice(~from=0, ~to_=1, s)) ++
    Js.String.slice(~from=1, ~to_=String.length(s), s)
  )
  ->Array.join(" ")

let camelToSnake = (input: string): string => {
  let re = RegExp.fromString("[A-Z]", ~flags="g")
  Js.String.unsafeReplaceBy0(re, (matchPart, _, _) => "_" ++ String.toLowerCase(matchPart), input)
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
  let (active, setActive) = React.useState(() => None)
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

  <div className="bg-white rounded-lg shadow p-6 mb-8">
    <div className="mb-6">
      <h3 className="text-lg font-medium text-gray-900 mb-2">
        {"Field Selection"->React.string}
      </h3>
      <p className="text-sm text-gray-500">
        {"Choose which fields to include in your query results"->React.string}
      </p>
    </div>

    {
      let gridClass = switch active {
      | None =>
        `grid grid-cols-1 lg:grid-cols-2 ${tracesSupported
            ? "xl:grid-cols-4"
            : "xl:grid-cols-3"} gap-6`
      | Some(_) =>
        `grid grid-cols-1 lg:grid-cols-2 ${tracesSupported
            ? "xl:grid-cols-4"
            : "xl:grid-cols-3"} gap-6`
      }

      <div className={gridClass}>
        // Block Fields
        <div className="border border-gray-200 rounded-lg p-4">
          <div className="mb-3">
            <h4 className="font-medium text-gray-900"> {"Block Fields"->React.string} </h4>
            {
              let selectedCount = Array.length(fieldSelection.block)
              let totalCount = Array.length(blockFieldOptions)
              let allSelected = selectedCount == totalCount
              let noneSelected = selectedCount == 0
              <div className="mt-2 flex items-center gap-3">
                {allSelected
                  ? React.null
                  : <button
                      onClick={_ => selectAllBlockFields()}
                      className="text-xs text-blue-600 hover:text-blue-700"
                    >
                      {"All"->React.string}
                    </button>}
                {noneSelected
                  ? React.null
                  : <button
                      onClick={_ => clearAllBlockFields()}
                      className="text-xs text-red-600 hover:text-red-700"
                    >
                      {"Clear"->React.string}
                    </button>}
                {allSelected
                  ? React.null
                  : <>
                      <span className="text-gray-300"> {"·"->React.string} </span>
                      <button
                        onClick={_ => setActive(_ => Some(Block))}
                        className="text-xs text-gray-700 hover:text-gray-900"
                      >
                        {"Add fields"->React.string}
                      </button>
                    </>}
              </div>
            }
          </div>
          <TagSelector
            title=""
            placeholder="Add field..."
            options={blockFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
            selectedValues={fieldSelection.block}
            onSelectionChange={updateBlockFields}
            showInput={false}
          />
          <div className="mt-3 pt-3 border-t border-gray-100">
            <div className="text-xs text-gray-500">
              {`${Int.toString(Array.length(fieldSelection.block))} selected`->React.string}
            </div>
          </div>
        </div>

        // Transaction Fields
        <div className="border border-gray-200 rounded-lg p-4">
          <div className="mb-3">
            <h4 className="font-medium text-gray-900"> {"Transaction Fields"->React.string} </h4>
            {
              let selectedCount = Array.length(fieldSelection.transaction)
              let totalCount = Array.length(transactionFieldOptions)
              let allSelected = selectedCount == totalCount
              let noneSelected = selectedCount == 0
              <div className="mt-2 flex items-center gap-3">
                {allSelected
                  ? React.null
                  : <button
                      onClick={_ => selectAllTransactionFields()}
                      className="text-xs text-blue-600 hover:text-blue-700"
                    >
                      {"All"->React.string}
                    </button>}
                {noneSelected
                  ? React.null
                  : <button
                      onClick={_ => clearAllTransactionFields()}
                      className="text-xs text-red-600 hover:text-red-700"
                    >
                      {"Clear"->React.string}
                    </button>}
                {allSelected
                  ? React.null
                  : <>
                      <span className="text-gray-300"> {"·"->React.string} </span>
                      <button
                        onClick={_ => setActive(_ => Some(Transaction))}
                        className="text-xs text-gray-700 hover:text-gray-900"
                      >
                        {"Add fields"->React.string}
                      </button>
                    </>}
              </div>
            }
          </div>
          <TagSelector
            title=""
            placeholder="Add field..."
            options={transactionFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
            selectedValues={fieldSelection.transaction}
            onSelectionChange={updateTransactionFields}
            showInput={false}
          />
          <div className="mt-3 pt-3 border-t border-gray-100">
            <div className="text-xs text-gray-500">
              {`${Int.toString(Array.length(fieldSelection.transaction))} selected`->React.string}
            </div>
          </div>
        </div>

        // Log Fields
        <div className="border border-gray-200 rounded-lg p-4">
          <div className="mb-3">
            <h4 className="font-medium text-gray-900"> {"Log Fields"->React.string} </h4>
            {
              let selectedCount = Array.length(fieldSelection.log)
              let totalCount = Array.length(logFieldOptions)
              let allSelected = selectedCount == totalCount
              let noneSelected = selectedCount == 0
              <div className="mt-2 flex items-center gap-3">
                {allSelected
                  ? React.null
                  : <button
                      onClick={_ => selectAllLogFields()}
                      className="text-xs text-blue-600 hover:text-blue-700"
                    >
                      {"All"->React.string}
                    </button>}
                {noneSelected
                  ? React.null
                  : <button
                      onClick={_ => clearAllLogFields()}
                      className="text-xs text-red-600 hover:text-red-700"
                    >
                      {"Clear"->React.string}
                    </button>}
                {allSelected
                  ? React.null
                  : <>
                      <span className="text-gray-300"> {"·"->React.string} </span>
                      <button
                        onClick={_ => setActive(_ => Some(Log))}
                        className="text-xs text-gray-700 hover:text-gray-900"
                      >
                        {"Add fields"->React.string}
                      </button>
                    </>}
              </div>
            }
          </div>
          <TagSelector
            title=""
            placeholder="Add field..."
            options={logFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
            selectedValues={fieldSelection.log}
            onSelectionChange={updateLogFields}
            showInput={false}
          />
          <div className="mt-3 pt-3 border-t border-gray-100">
            <div className="text-xs text-gray-500">
              {`${Int.toString(Array.length(fieldSelection.log))} selected`->React.string}
            </div>
          </div>
        </div>

        // Trace Fields
        {tracesSupported
          ? <div className="border border-gray-200 rounded-lg p-4">
              <div className="mb-3">
                <h4 className="font-medium text-gray-900"> {"Trace Fields"->React.string} </h4>
                {
                  let selectedCount = Array.length(fieldSelection.trace)
                  let totalCount = Array.length(traceFieldOptions)
                  let allSelected = selectedCount == totalCount
                  let noneSelected = selectedCount == 0
                  <div className="mt-2 flex items-center gap-3">
                    {allSelected
                      ? React.null
                      : <button
                          onClick={_ => selectAllTraceFields()}
                          className="text-xs text-blue-600 hover:text-blue-700"
                        >
                          {"All"->React.string}
                        </button>}
                    {noneSelected
                      ? React.null
                      : <button
                          onClick={_ => clearAllTraceFields()}
                          className="text-xs text-red-600 hover:text-red-700"
                        >
                          {"Clear"->React.string}
                        </button>}
                    {allSelected
                      ? React.null
                      : <>
                          <span className="text-gray-300"> {"·"->React.string} </span>
                          <button
                            onClick={_ => setActive(_ => Some(Trace))}
                            className="text-xs text-gray-700 hover:text-gray-900"
                          >
                            {"Add fields"->React.string}
                          </button>
                        </>}
                  </div>
                }
              </div>
              <TagSelector
                title=""
                placeholder="Add field..."
                options={traceFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
                selectedValues={fieldSelection.trace}
                onSelectionChange={updateTraceFields}
                showInput={false}
              />
              <div className="mt-3 pt-3 border-t border-gray-100">
                <div className="text-xs text-gray-500">
                  {`${Int.toString(Array.length(fieldSelection.trace))} selected`->React.string}
                </div>
              </div>
            </div>
          : React.null}
      </div>
    }

    {switch active {
    | None => React.null
    | Some(section) =>
      <div className="mt-6 border border-gray-200 rounded-lg p-4">
        <div className="mb-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <button
                className={"text-sm px-3 py-1 rounded " ++ (
                  section == Block ? "bg-blue-50 text-blue-700" : "hover:bg-gray-50"
                )}
                onClick={_ => setActive(_ => Some(Block))}
              >
                {"Block"->React.string}
              </button>
              <button
                className={"text-sm px-3 py-1 rounded " ++ (
                  section == Transaction ? "bg-blue-50 text-blue-700" : "hover:bg-gray-50"
                )}
                onClick={_ => setActive(_ => Some(Transaction))}
              >
                {"Transaction"->React.string}
              </button>
              <button
                className={"text-sm px-3 py-1 rounded " ++ (
                  section == Log ? "bg-blue-50 text-blue-700" : "hover:bg-gray-50"
                )}
                onClick={_ => setActive(_ => Some(Log))}
              >
                {"Log"->React.string}
              </button>
              {tracesSupported
                ? <button
                    className={"text-sm px-3 py-1 rounded " ++ (
                      section == Trace ? "bg-blue-50 text-blue-700" : "hover:bg-gray-50"
                    )}
                    onClick={_ => setActive(_ => Some(Trace))}
                  >
                    {"Trace"->React.string}
                  </button>
                : React.null}
            </div>
            <button
              className="text-sm text-gray-500 hover:text-gray-700"
              onClick={_ => setActive(_ => None)}
            >
              {"Close"->React.string}
            </button>
          </div>
        </div>

        {switch section {
        | Block =>
          <TagSelector
            title=""
            placeholder="Search block fields..."
            options={blockFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
            selectedValues={fieldSelection.block}
            onSelectionChange={updateBlockFields}
            onOpen={() => ()}
            onClose={() => ()}
            forceOpen={true}
            showSelectedChips={false}
          />
        | Transaction =>
          <TagSelector
            title=""
            placeholder="Search transaction fields..."
            options={transactionFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
            selectedValues={fieldSelection.transaction}
            onSelectionChange={updateTransactionFields}
            onOpen={() => ()}
            onClose={() => ()}
            forceOpen={true}
            showSelectedChips={false}
          />
        | Log =>
          <TagSelector
            title=""
            placeholder="Search log fields..."
            options={logFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
            selectedValues={fieldSelection.log}
            onSelectionChange={updateLogFields}
            onOpen={() => ()}
            onClose={() => ()}
            forceOpen={true}
            showSelectedChips={false}
          />
        | Trace =>
          <TagSelector
            title=""
            placeholder="Search trace fields..."
            options={traceFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
            selectedValues={fieldSelection.trace}
            onSelectionChange={updateTraceFields}
            onOpen={() => ()}
            onClose={() => ()}
            forceOpen={true}
            showSelectedChips={false}
          />
        }}
      </div>
    }}
  </div>
}
