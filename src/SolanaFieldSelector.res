open SolanaQueryStructure

let blockOptions: array<TagSelector.selectOption<blockField>> = allBlockFields->Array.map(f => {
  TagSelector.value: f,
  label: snakeToTitle(blockFieldToSnake(f)),
})

let transactionOptions: array<
  TagSelector.selectOption<transactionField>,
> = allTransactionFields->Array.map(f => {
  TagSelector.value: f,
  label: snakeToTitle(transactionFieldToSnake(f)),
})

let instructionOptions: array<
  TagSelector.selectOption<instructionField>,
> = allInstructionFields->Array.map(f => {
  TagSelector.value: f,
  label: snakeToTitle(instructionFieldToSnake(f)),
})

let logOptions: array<TagSelector.selectOption<logField>> = allLogFields->Array.map(f => {
  TagSelector.value: f,
  label: snakeToTitle(logFieldToSnake(f)),
})

let accountActivityOptions: array<
  TagSelector.selectOption<accountActivityField>,
> = allAccountActivityFields->Array.map(f => {
  TagSelector.value: f,
  label: snakeToTitle(accountActivityFieldToSnake(f)),
})

let rewardOptions: array<TagSelector.selectOption<rewardField>> = allRewardFields->Array.map(f => {
  TagSelector.value: f,
  label: snakeToTitle(rewardFieldToSnake(f)),
})

let renderSection = (
  ~title: string,
  ~total: int,
  ~selectedCount: int,
  ~onSelectAll: unit => unit,
  ~onClear: unit => unit,
  ~child: React.element,
) => {
  let allSelected = selectedCount == total
  let noneSelected = selectedCount == 0
  <div className="border border-gray-200 rounded-lg p-4">
    <div className="mb-3">
      <h4 className="font-medium text-gray-900"> {title->React.string} </h4>
      <div className="mt-2 flex items-center gap-3">
        {allSelected
          ? React.null
          : <button
              onClick={_ => onSelectAll()} className="text-xs text-blue-600 hover:text-blue-700"
            >
              {"All"->React.string}
            </button>}
        {noneSelected
          ? React.null
          : <button onClick={_ => onClear()} className="text-xs text-red-600 hover:text-red-700">
              {"Clear"->React.string}
            </button>}
      </div>
    </div>
    {child}
    <div className="mt-3 pt-3 border-t border-gray-100">
      <div className="text-xs text-gray-500">
        {`${Int.toString(selectedCount)} selected`->React.string}
      </div>
    </div>
  </div>
}

@react.component
let make = (~fieldSelection: fieldSelection, ~onFieldSelectionChange: fieldSelection => unit) => {
  let updateBlock = v => onFieldSelectionChange({...fieldSelection, block: v})
  let updateTransaction = v => onFieldSelectionChange({...fieldSelection, transaction: v})
  let updateInstruction = v => onFieldSelectionChange({...fieldSelection, instructionCall: v})
  let updateLog = v => onFieldSelectionChange({...fieldSelection, log: v})
  let updateAccountActivity = v => onFieldSelectionChange({...fieldSelection, accountActivity: v})
  let updateReward = v => onFieldSelectionChange({...fieldSelection, reward: v})

  <div className="bg-white rounded-lg p-2 mb-2">
    <p className="text-xs text-slate-500 mb-3">
      {"Field selection also drives the joins: a table with no columns selected returns no rows, and selecting columns of a related table (say transactions next to an instruction filter) pulls the rows that relate to what the filters matched."->React.string}
    </p>
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
      {renderSection(
        ~title="Block Fields",
        ~total=Array.length(blockOptions),
        ~selectedCount=Array.length(fieldSelection.block),
        ~onSelectAll=() => updateBlock(allBlockFields),
        ~onClear=() => updateBlock([]),
        ~child=<TagSelector
          title=""
          placeholder="Add field..."
          options={blockOptions}
          selectedValues={fieldSelection.block}
          onSelectionChange={updateBlock}
          showInput={false}
        />,
      )}
      {renderSection(
        ~title="Transaction Fields",
        ~total=Array.length(transactionOptions),
        ~selectedCount=Array.length(fieldSelection.transaction),
        ~onSelectAll=() => updateTransaction(allTransactionFields),
        ~onClear=() => updateTransaction([]),
        ~child=<TagSelector
          title=""
          placeholder="Add field..."
          options={transactionOptions}
          selectedValues={fieldSelection.transaction}
          onSelectionChange={updateTransaction}
          showInput={false}
        />,
      )}
      {renderSection(
        ~title="Instruction Call Fields",
        ~total=Array.length(instructionOptions),
        ~selectedCount=Array.length(fieldSelection.instructionCall),
        ~onSelectAll=() => updateInstruction(allInstructionFields),
        ~onClear=() => updateInstruction([]),
        ~child=<TagSelector
          title=""
          placeholder="Add field..."
          options={instructionOptions}
          selectedValues={fieldSelection.instructionCall}
          onSelectionChange={updateInstruction}
          showInput={false}
        />,
      )}
      {renderSection(
        ~title="Log Fields",
        ~total=Array.length(logOptions),
        ~selectedCount=Array.length(fieldSelection.log),
        ~onSelectAll=() => updateLog(allLogFields),
        ~onClear=() => updateLog([]),
        ~child=<TagSelector
          title=""
          placeholder="Add field..."
          options={logOptions}
          selectedValues={fieldSelection.log}
          onSelectionChange={updateLog}
          showInput={false}
        />,
      )}
      {renderSection(
        ~title="Account Activity Fields",
        ~total=Array.length(accountActivityOptions),
        ~selectedCount=Array.length(fieldSelection.accountActivity),
        ~onSelectAll=() => updateAccountActivity(allAccountActivityFields),
        ~onClear=() => updateAccountActivity([]),
        ~child=<TagSelector
          title=""
          placeholder="Add field..."
          options={accountActivityOptions}
          selectedValues={fieldSelection.accountActivity}
          onSelectionChange={updateAccountActivity}
          showInput={false}
        />,
      )}
      {renderSection(
        ~title="Reward Fields",
        ~total=Array.length(rewardOptions),
        ~selectedCount=Array.length(fieldSelection.reward),
        ~onSelectAll=() => updateReward(allRewardFields),
        ~onClear=() => updateReward([]),
        ~child=<TagSelector
          title=""
          placeholder="Add field..."
          options={rewardOptions}
          selectedValues={fieldSelection.reward}
          onSelectionChange={updateReward}
          showInput={false}
        />,
      )}
    </div>
  </div>
}
