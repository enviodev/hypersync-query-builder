open QueryStructure

type activeSection =
  | Block
  | Transaction
  | Instruction

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
let instructionFieldToSnakeCaseString = (field: instructionField) => Obj.magic(field)

let blockFieldToCamelCaseString = field => snakeToCamel(blockFieldToSnakeCaseString(field))
let transactionFieldToCamelCaseString = field =>
  snakeToCamel(transactionFieldToSnakeCaseString(field))
let instructionFieldToCamelCaseString = field =>
  snakeToCamel(instructionFieldToSnakeCaseString(field))

let blockFieldToDisplayString = field => snakeToTitle(blockFieldToSnakeCaseString(field))
let transactionFieldToDisplayString = field =>
  snakeToTitle(transactionFieldToSnakeCaseString(field))
let instructionFieldToDisplayString = field =>
  snakeToTitle(instructionFieldToSnakeCaseString(field))

let blockFieldOptions = Array.map(QueryStructure.allBlockFields, field => (
  field,
  snakeToTitle(blockFieldToSnakeCaseString(field)),
))

let transactionFieldOptions = Array.map(QueryStructure.allTransactionFields, field => (
  field,
  snakeToTitle(transactionFieldToSnakeCaseString(field)),
))

let instructionFieldOptions = Array.map(QueryStructure.allInstructionFields, field => (
  field,
  snakeToTitle(instructionFieldToSnakeCaseString(field)),
))

@react.component
let make = (~fieldSelection: fieldSelection, ~onFieldSelectionChange: fieldSelection => unit) => {
  let (active, setActive) = React.useState(() => None)
  let selectionPanelRef = React.useRef(Nullable.null)

  let scrollAndFlash: Dom.element => unit = %raw(`
    function(el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      el.classList.add('field-selection-flash');
      setTimeout(function() {
        el.classList.remove('field-selection-flash');
      }, 700);
    }
  `)

  React.useEffect1(() => {
    switch active {
    | Some(_) =>
      let timerId: timeoutId = setTimeout(() => {
        switch Nullable.toOption(selectionPanelRef.current) {
        | Some(el) => scrollAndFlash(el)
        | None => ()
        }
      }, 50)
      Some(() => clearTimeout(timerId))
    | None => None
    }
  }, [active])
  let updateBlockFields = newFields => onFieldSelectionChange({...fieldSelection, block: newFields})
  let updateTransactionFields = newFields =>
    onFieldSelectionChange({...fieldSelection, transaction: newFields})
  let updateInstructionFields = newFields =>
    onFieldSelectionChange({...fieldSelection, instruction: newFields})

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

  let selectAllInstructionFields = () => {
    let allFields = Array.map(instructionFieldOptions, ((field, _)) => field)
    onFieldSelectionChange({...fieldSelection, instruction: allFields})
  }

  let clearAllInstructionFields = () => {
    onFieldSelectionChange({...fieldSelection, instruction: []})
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
      let gridClass = `grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6`

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
            options={blockFieldOptions->Array.map(((v, l)) => {TagSelector.value: v, label: l})}
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
            options={transactionFieldOptions->Array.map(((v, l)) => {
              TagSelector.value: v,
              label: l,
            })}
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

        // Instruction Fields
        <div className="border border-gray-200 rounded-lg p-4">
          <div className="mb-3">
            <h4 className="font-medium text-gray-900"> {"Instruction Fields"->React.string} </h4>
            {
              let selectedCount = Array.length(fieldSelection.instruction)
              let totalCount = Array.length(instructionFieldOptions)
              let allSelected = selectedCount == totalCount
              let noneSelected = selectedCount == 0
              <div className="mt-2 flex items-center gap-3">
                {allSelected
                  ? React.null
                  : <button
                      onClick={_ => selectAllInstructionFields()}
                      className="text-xs text-blue-600 hover:text-blue-700"
                    >
                      {"All"->React.string}
                    </button>}
                {noneSelected
                  ? React.null
                  : <button
                      onClick={_ => clearAllInstructionFields()}
                      className="text-xs text-red-600 hover:text-red-700"
                    >
                      {"Clear"->React.string}
                    </button>}
                {allSelected
                  ? React.null
                  : <>
                      <span className="text-gray-300"> {"·"->React.string} </span>
                      <button
                        onClick={_ => setActive(_ => Some(Instruction))}
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
            options={instructionFieldOptions->Array.map(((v, l)) => {
              TagSelector.value: v,
              label: l,
            })}
            selectedValues={fieldSelection.instruction}
            onSelectionChange={updateInstructionFields}
            showInput={false}
          />
          <div className="mt-3 pt-3 border-t border-gray-100">
            <div className="text-xs text-gray-500">
              {`${Int.toString(Array.length(fieldSelection.instruction))} selected`->React.string}
            </div>
          </div>
        </div>
      </div>
    }

    {switch active {
    | None => React.null
    | Some(section) =>
      <div
        ref={ReactDOM.Ref.domRef(selectionPanelRef)}
        className="mt-6 border border-gray-200 rounded-lg p-4"
      >
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
                  section == Instruction ? "bg-blue-50 text-blue-700" : "hover:bg-gray-50"
                )}
                onClick={_ => setActive(_ => Some(Instruction))}
              >
                {"Instruction"->React.string}
              </button>
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
            options={blockFieldOptions->Array.map(((v, l)) => {TagSelector.value: v, label: l})}
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
            options={transactionFieldOptions->Array.map(((v, l)) => {
              TagSelector.value: v,
              label: l,
            })}
            selectedValues={fieldSelection.transaction}
            onSelectionChange={updateTransactionFields}
            onOpen={() => ()}
            onClose={() => ()}
            forceOpen={true}
            showSelectedChips={false}
          />
        | Instruction =>
          <TagSelector
            title=""
            placeholder="Search instruction fields..."
            options={instructionFieldOptions->Array.map(((v, l)) => {
              TagSelector.value: v,
              label: l,
            })}
            selectedValues={fieldSelection.instruction}
            onSelectionChange={updateInstructionFields}
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
