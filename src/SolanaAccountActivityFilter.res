open SolanaQueryStructure

type filterState = SolanaQueryStructure.accountActivitySelection

let labelClass = "block text-xs font-medium text-slate-700 mb-1"
let renderListEditor = SolanaInstructionFilter.renderListEditor
let isBase58Pubkey = SolanaInstructionFilter.isBase58Pubkey

let isBase58Signature = SolanaInstructionFilter.isBase58Signature

// Trims here so every editor on this card stores the same shape.
let addToList = (current: option<array<string>>, value: string): option<array<string>> => Some(
  Array.concat(current->Option.getOr([]), [String.trim(value)]),
)

let removeFromList = (current: option<array<string>>, idx: int): option<array<string>> => {
  let cur = current->Option.getOr([])
  let next = cur->Array.filterWithIndex((_, i) => i !== idx)
  Array.length(next) > 0 ? Some(next) : None
}

let renderTriState = (~label: string, ~value: option<bool>, ~onChange: option<bool> => unit) =>
  <div key={label}>
    <label className={labelClass}> {label->React.string} </label>
    <div className="flex space-x-2">
      {[("Any", None), ("True", Some(true)), ("False", Some(false))]
      ->Array.map(((optionLabel, optionValue)) => {
        let isActive = value === optionValue
        <button
          key={optionLabel}
          onClick={_ => onChange(optionValue)}
          className={`px-2.5 py-1 text-xs font-medium rounded-lg border transition-colors ${isActive
              ? "bg-slate-800 text-white border-slate-800"
              : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"}`}
        >
          {optionLabel->React.string}
        </button>
      })
      ->React.array}
    </div>
  </div>

@react.component
let make = (
  ~filterState: filterState,
  ~onFilterChange: filterState => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int,
  ~isExpanded: bool,
  ~onToggleExpand: unit => unit,
  ~selectedTables: array<joinTable>,
  ~onIncludeTable: joinTable => unit,
) => {
  let (newAccount, setNewAccount) = React.useState(() => "")
  let (newMint, setNewMint) = React.useState(() => "")
  let (newOwner, setNewOwner) = React.useState(() => "")
  let (newProgramId, setNewProgramId) = React.useState(() => "")
  let (newTransactionId, setNewTransactionId) = React.useState(() => "")

  let updateField = (newState: filterState) => onFilterChange(newState)

  let toggleKind = (kind: string) => {
    let current = filterState.kind->Option.getOr([])
    let next = Array.includes(current, kind)
      ? current->Array.filter(k => k !== kind)
      : Array.concat(current, [kind])
    updateField({...filterState, kind: Array.length(next) > 0 ? Some(next) : None})
  }

  let hasFilters =
    Option.isSome(filterState.kind) ||
    Option.isSome(filterState.account) ||
    Option.isSome(filterState.transactionId) ||
    Option.isSome(filterState.mint) ||
    Option.isSome(filterState.owner) ||
    Option.isSome(filterState.programId) ||
    Option.isSome(filterState.isSigner) ||
    Option.isSome(filterState.isWritable) ||
    Option.isSome(filterState.isFeePayer) ||
    Option.isSome(filterState.fromLookupTable)

  <div
    className="relative bg-white rounded-xl border border-slate-200 shadow-sm transition-all w-full"
  >
    <div className="p-4 border-b border-slate-100">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-slate-900">
            {`Account Activity Filter ${Int.toString(filterIndex + 1)}`->React.string}
          </h3>
          {hasFilters
            ? <span
                className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700"
              >
                {"Active"->React.string}
              </span>
            : <span
                className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-50 text-amber-700 border border-amber-200"
              >
                {"Matches every row in range"->React.string}
              </span>}
        </div>
        <div className="flex items-center space-x-1">
          <button
            onClick={_ => onToggleExpand()}
            className="inline-flex items-center p-2 text-sm font-medium text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded-lg transition-colors"
          >
            <svg
              className={`w-4 h-4 transform transition-transform ${isExpanded
                  ? "rotate-180"
                  : "rotate-0"}`}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7"
              />
            </svg>
          </button>
          <button
            onClick={_ => onRemove()}
            className="inline-flex items-center p-2 text-sm font-medium text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
              />
            </svg>
          </button>
        </div>
      </div>
    </div>
    {isExpanded
      ? <div className="p-6">
          <p className="text-[11px] text-slate-500 mb-4">
            {"account_activity merges the native SOL side and the SPL token side into one row per (transaction, account). On a native row `account` is the wallet; on a token row it is the token account, so \"everything for wallet W\" needs two selections: one with account = W and one with owner = W. Fields inside a single selection are AND-ed."->React.string}
          </p>

          // Kind
          <div className="mb-4">
            <label className={labelClass}> {"Kind"->React.string} </label>
            <div className="flex space-x-2">
              {activityKinds
              ->Array.map(kind => {
                let isActive = Array.includes(filterState.kind->Option.getOr([]), kind)
                <button
                  key={kind}
                  onClick={_ => toggleKind(kind)}
                  className={`px-3 py-1.5 text-xs font-medium rounded-lg border transition-colors ${isActive
                      ? "bg-slate-800 text-white border-slate-800"
                      : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"}`}
                >
                  {kind->React.string}
                </button>
              })
              ->React.array}
            </div>
            <p className="mt-1 text-[11px] text-slate-500">
              {"Empty matches both sides. kind: native is the row set the old balance table held, kind: token the old token_balance one."->React.string}
            </p>
          </div>

          {renderListEditor(
            ~label="Accounts (base58) - wallet on native rows, token account on token rows",
            ~placeholder="base58 pubkey",
            ~values=filterState.account->Option.getOr([]),
            ~onAdd=v =>
              if isBase58Pubkey(v) {
                updateField({...filterState, account: addToList(filterState.account, v)})
                setNewAccount(_ => "")
              },
            ~onRemove=i =>
              updateField({...filterState, account: removeFromList(filterState.account, i)}),
            ~draft=newAccount,
            ~setDraft=setNewAccount,
            ~validate=isBase58Pubkey,
          )}

          {renderListEditor(
            ~label="Transaction IDs (base58 signature)",
            ~placeholder="base58 signature",
            ~values=filterState.transactionId->Option.getOr([]),
            ~onAdd=v =>
              if isBase58Signature(v) {
                updateField({
                  ...filterState,
                  transactionId: addToList(filterState.transactionId, v),
                })
                setNewTransactionId(_ => "")
              },
            ~onRemove=i =>
              updateField({
                ...filterState,
                transactionId: removeFromList(filterState.transactionId, i),
              }),
            ~draft=newTransactionId,
            ~setDraft=setNewTransactionId,
            ~validate=isBase58Signature,
          )}

          {renderListEditor(
            ~label="Owners (wallet behind a token account)",
            ~placeholder="base58 pubkey",
            ~values=filterState.owner->Option.getOr([]),
            ~onAdd=v =>
              if isBase58Pubkey(v) {
                updateField({...filterState, owner: addToList(filterState.owner, v)})
                setNewOwner(_ => "")
              },
            ~onRemove=i =>
              updateField({...filterState, owner: removeFromList(filterState.owner, i)}),
            ~draft=newOwner,
            ~setDraft=setNewOwner,
            ~validate=isBase58Pubkey,
          )}

          {renderListEditor(
            ~label="Mints (token rows only)",
            ~placeholder="base58 mint",
            ~values=filterState.mint->Option.getOr([]),
            ~onAdd=v =>
              if isBase58Pubkey(v) {
                updateField({...filterState, mint: addToList(filterState.mint, v)})
                setNewMint(_ => "")
              },
            ~onRemove=i => updateField({...filterState, mint: removeFromList(filterState.mint, i)}),
            ~draft=newMint,
            ~setDraft=setNewMint,
            ~validate=isBase58Pubkey,
          )}

          {renderListEditor(
            ~label="Token Program IDs (SPL Token vs Token-2022)",
            ~placeholder="TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            ~values=filterState.programId->Option.getOr([]),
            ~onAdd=v =>
              if isBase58Pubkey(v) {
                updateField({...filterState, programId: addToList(filterState.programId, v)})
                setNewProgramId(_ => "")
              },
            ~onRemove=i =>
              updateField({...filterState, programId: removeFromList(filterState.programId, i)}),
            ~draft=newProgramId,
            ~setDraft=setNewProgramId,
            ~validate=isBase58Pubkey,
          )}

          // Position flags
          <div className="mb-4">
            <div className="grid grid-cols-2 gap-3">
              {renderTriState(~label="is_signer", ~value=filterState.isSigner, ~onChange=v =>
                updateField({...filterState, isSigner: v})
              )}
              {renderTriState(~label="is_writable", ~value=filterState.isWritable, ~onChange=v =>
                updateField({...filterState, isWritable: v})
              )}
              {renderTriState(~label="is_fee_payer", ~value=filterState.isFeePayer, ~onChange=v =>
                updateField({...filterState, isFeePayer: v})
              )}
              {renderTriState(
                ~label="from_lookup_table",
                ~value=filterState.fromLookupTable,
                ~onChange=v => updateField({...filterState, fromLookupTable: v}),
              )}
            </div>
            <p className="mt-1 text-[11px] text-slate-500">
              {"These flags come from the message header, so a source that could not derive one leaves it null. A null flag matches neither true nor false."->React.string}
            </p>
          </div>

          <SolanaJoinHints
            tables={[(Transaction, "transaction fields"), (Block, "block fields")]}
            selectedTables={selectedTables}
            onIncludeTable={onIncludeTable}
          />
        </div>
      : React.null}
  </div>
}
