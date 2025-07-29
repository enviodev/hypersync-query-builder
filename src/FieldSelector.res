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

let transactionFieldOptions: array<(transactionField, string)> = [
  (BlockHash, "Block Hash"),
  (BlockNumber, "Block Number"),
  (From, "From"),
  (To, "To"),
  (Hash, "Hash"),
  (Input, "Input"),
  (Value, "Value"),
  (Gas, "Gas"),
  (GasPrice, "Gas Price"),
  (Nonce, "Nonce"),
  (TransactionIndex, "Transaction Index"),
  (Status, "Status"),
  (CumulativeGasUsed, "Cumulative Gas Used"),
  (EffectiveGasPrice, "Effective Gas Price"),
  (GasUsed, "Gas Used"),
  (ContractAddress, "Contract Address"),
  (V, "V"),
  (R, "R"),
  (S, "S"),
  (YParity, "Y Parity"),
  (MaxPriorityFeePerGas, "Max Priority Fee Per Gas"),
  (MaxFeePerGas, "Max Fee Per Gas"),
  (ChainId, "Chain ID"),
  (AccessList, "Access List"),
  (AuthorizationList, "Authorization List"),
]

let logFieldOptions: array<(logField, string)> = [
  (Address, "Address"),
  (Data, "Data"),
  (Topic0, "Topic 0"),
  (Topic1, "Topic 1"),
  (Topic2, "Topic 2"),
  (Topic3, "Topic 3"),
  (BlockHash, "Block Hash"),
  (BlockNumber, "Block Number"),
  (TransactionHash, "Transaction Hash"),
  (TransactionIndex, "Transaction Index"),
  (LogIndex, "Log Index"),
  (Removed, "Removed"),
]

@react.component
let make = (~fieldSelection: fieldSelection, ~onFieldSelectionChange: fieldSelection => unit) => {
  let updateBlockFields = newFields => onFieldSelectionChange({...fieldSelection, block: newFields})
  let updateTransactionFields = newFields =>
    onFieldSelectionChange({...fieldSelection, transaction: newFields})
  let updateLogFields = newFields => onFieldSelectionChange({...fieldSelection, log: newFields})

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

  <div className="bg-white rounded-lg shadow p-6 mb-8">
    <div className="mb-6">
      <h3 className="text-lg font-medium text-gray-900 mb-2">
        {"Field Selection"->React.string}
      </h3>
      <p className="text-sm text-gray-500">
        {"Choose which fields to include in your query results"->React.string}
      </p>
    </div>

    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      // Block Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <div className="flex items-center justify-between mb-4">
          <h4 className="font-medium text-gray-900"> {"Block Fields"->React.string} </h4>
          <div className="flex space-x-2">
            <button
              onClick={_ => selectAllBlockFields()}
              className="text-xs text-blue-600 hover:text-blue-700">
              {"All"->React.string}
            </button>
            <span className="text-xs text-gray-300"> {"|"->React.string} </span>
            <button
              onClick={_ => clearAllBlockFields()}
              className="text-xs text-red-600 hover:text-red-700">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        <TagSelector
          title=""
          placeholder="Add field..."
          options={blockFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.block}
          onSelectionChange={updateBlockFields}
        />
        <div className="mt-3 pt-3 border-t border-gray-100">
          <div className="text-xs text-gray-500">
            {`${Int.toString(Array.length(fieldSelection.block))} selected`->React.string}
          </div>
        </div>
      </div>

      // Transaction Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <div className="flex items-center justify-between mb-4">
          <h4 className="font-medium text-gray-900"> {"Transaction Fields"->React.string} </h4>
          <div className="flex space-x-2">
            <button
              onClick={_ => selectAllTransactionFields()}
              className="text-xs text-blue-600 hover:text-blue-700">
              {"All"->React.string}
            </button>
            <span className="text-xs text-gray-300"> {"|"->React.string} </span>
            <button
              onClick={_ => clearAllTransactionFields()}
              className="text-xs text-red-600 hover:text-red-700">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        <TagSelector
          title=""
          placeholder="Add field..."
          options={transactionFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.transaction}
          onSelectionChange={updateTransactionFields}
        />
        <div className="mt-3 pt-3 border-t border-gray-100">
          <div className="text-xs text-gray-500">
            {`${Int.toString(Array.length(fieldSelection.transaction))} selected`->React.string}
          </div>
        </div>
      </div>

      // Log Fields
      <div className="border border-gray-200 rounded-lg p-4">
        <div className="flex items-center justify-between mb-4">
          <h4 className="font-medium text-gray-900"> {"Log Fields"->React.string} </h4>
          <div className="flex space-x-2">
            <button
              onClick={_ => selectAllLogFields()}
              className="text-xs text-blue-600 hover:text-blue-700">
              {"All"->React.string}
            </button>
            <span className="text-xs text-gray-300"> {"|"->React.string} </span>
            <button
              onClick={_ => clearAllLogFields()}
              className="text-xs text-red-600 hover:text-red-700">
              {"Clear"->React.string}
            </button>
          </div>
        </div>
        <TagSelector
          title=""
          placeholder="Add field..."
          options={logFieldOptions->Array.map(((v, l)) => {value: v, label: l})}
          selectedValues={fieldSelection.log}
          onSelectionChange={updateLogFields}
        />
        <div className="mt-3 pt-3 border-t border-gray-100">
          <div className="text-xs text-gray-500">
            {`${Int.toString(Array.length(fieldSelection.log))} selected`->React.string}
          </div>
        </div>
      </div>
    </div>
  </div>
}
