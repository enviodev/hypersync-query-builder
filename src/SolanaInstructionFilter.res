open SolanaQueryStructure

type filterState = SolanaQueryStructure.instructionSelection

let labelClass = "block text-xs font-medium text-slate-700 mb-1"
let inputClass = "flex-1 border border-slate-300 rounded-lg px-3 py-2 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition-colors"
let addBtnClass = "px-3 py-2 bg-slate-700 text-white text-xs font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 disabled:opacity-50 transition-colors"
let chipClass = "flex items-center justify-between bg-slate-50 px-3 py-1.5 rounded-lg border border-slate-100"

let renderListEditor = (
  ~label: string,
  ~placeholder: string,
  ~values: array<string>,
  ~onAdd: string => unit,
  ~onRemove: int => unit,
  ~draft: string,
  ~setDraft: (string => string) => unit,
  ~validate: string => bool,
) => {
  <div className="mb-4">
    <label className={labelClass}> {label->React.string} </label>
    <div className="flex space-x-2 mb-2">
      <input
        type_="text"
        value={draft}
        onChange={e => {
          let target = ReactEvent.Form.target(e)
          setDraft(_ => target["value"])
        }}
        onKeyDown={e =>
          if ReactEvent.Keyboard.key(e) === "Enter" {
            ReactEvent.Synthetic.preventDefault(e)
            if validate(draft) {
              onAdd(draft)
            }
          }}
        placeholder={placeholder}
        className={inputClass}
      />
      <button
        onClick={_ => onAdd(draft)}
        disabled={String.length(draft) === 0 || !validate(draft)}
        className={addBtnClass}
      >
        {(Array.length(values) > 0 ? "Add (OR)" : "Add")->React.string}
      </button>
    </div>
    {Array.length(values) > 0
      ? <div className="space-y-1">
          {values
          ->Array.mapWithIndex((v, i) =>
            <div key={Int.toString(i)} className={chipClass}>
              <span className="text-xs font-mono text-slate-800 truncate"> {v->React.string} </span>
              <button
                onClick={_ => onRemove(i)}
                className="ml-2 text-red-600 hover:text-red-800 text-xs font-medium transition-colors"
              >
                {"Remove"->React.string}
              </button>
            </div>
          )
          ->React.array}
        </div>
      : React.null}
  </div>
}

let isHexBytes = (s: string, byteLen: int): bool => {
  let hex = if String.startsWith(s, "0x") || String.startsWith(s, "0X") {
    String.substring(s, ~start=2)
  } else {
    s
  }
  let len = String.length(hex)
  let expected = byteLen * 2
  if len !== expected {
    false
  } else {
    let re = RegExp.fromString("^[0-9a-fA-F]+$")
    RegExp.test(re, hex)
  }
}

let isBase58Pubkey = (s: string): bool => {
  let len = String.length(s)
  if len < 32 || len > 44 {
    false
  } else {
    let re = RegExp.fromString("^[1-9A-HJ-NP-Za-km-z]+$")
    RegExp.test(re, s)
  }
}

@react.component
let make = (
  ~filterState: filterState,
  ~onFilterChange: filterState => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int,
  ~isExpanded: bool,
  ~onToggleExpand: unit => unit,
  ~selectedTables: array<string>,
  ~onIncludeTable: string => unit,
) => {
  let (newProgramId, setNewProgramId) = React.useState(() => "")
  let (newD1, setNewD1) = React.useState(() => "")
  let (newD2, setNewD2) = React.useState(() => "")
  let (newD4, setNewD4) = React.useState(() => "")
  let (newD8, setNewD8) = React.useState(() => "")
  let (newAccount, setNewAccount) = React.useState(() => "")
  let (accountSlot, setAccountSlot) = React.useState(() => 0)
  let (showAccounts, setShowAccounts) = React.useState(() => false)
  let (showDiscriminators, setShowDiscriminators) = React.useState(() => true)

  let updateField = (newState: filterState) => onFilterChange(newState)

  let addToList = (current: option<array<string>>, value: string): option<array<string>> => {
    Some(Array.concat(current->Option.getOr([]), [value]))
  }

  let removeFromList = (current: option<array<string>>, idx: int): option<array<string>> => {
    let cur = current->Option.getOr([])
    let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== idx)
    Array.length(next) > 0 ? Some(next) : None
  }

  let getAccountAt = (state: filterState, slot: int): option<array<string>> =>
    switch slot {
    | 0 => state.a0
    | 1 => state.a1
    | 2 => state.a2
    | 3 => state.a3
    | 4 => state.a4
    | 5 => state.a5
    | 6 => state.a6
    | 7 => state.a7
    | 8 => state.a8
    | 9 => state.a9
    | _ => None
    }

  let setAccountAt = (state: filterState, slot: int, v: option<array<string>>): filterState =>
    switch slot {
    | 0 => {...state, a0: v}
    | 1 => {...state, a1: v}
    | 2 => {...state, a2: v}
    | 3 => {...state, a3: v}
    | 4 => {...state, a4: v}
    | 5 => {...state, a5: v}
    | 6 => {...state, a6: v}
    | 7 => {...state, a7: v}
    | 8 => {...state, a8: v}
    | 9 => {...state, a9: v}
    | _ => state
    }

  let activeAccountSlots = () => {
    let slots = ref([])
    for i in 0 to 9 {
      switch getAccountAt(filterState, i) {
      | Some(arr) if Array.length(arr) > 0 => slots := Array.concat(slots.contents, [i])
      | _ => ()
      }
    }
    slots.contents
  }

  let hasFilters =
    Option.isSome(filterState.executingAccount) ||
    Option.isSome(filterState.d1) ||
    Option.isSome(filterState.d2) ||
    Option.isSome(filterState.d4) ||
    Option.isSome(filterState.d8) ||
    Array.length(activeAccountSlots()) > 0 ||
    Option.isSome(filterState.isInner) ||
    Option.isSome(filterState.txSuccess)

  <div
    className="relative bg-white rounded-xl border border-slate-200 shadow-sm transition-all w-full"
  >
    <div className="p-4 border-b border-slate-100">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-slate-900">
            {`Instruction Filter ${Int.toString(filterIndex + 1)}`->React.string}
          </h3>
          {hasFilters
            ? <span
                className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700"
              >
                {"Active"->React.string}
              </span>
            : React.null}
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
          // Executing accounts (the invoked programs; wire key executing_account)
          {renderListEditor(
            ~label="Executing Accounts / Program IDs (base58)",
            ~placeholder="e.g. TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            ~values=filterState.executingAccount->Option.getOr([]),
            ~onAdd=v => {
              if isBase58Pubkey(v) {
                updateField({
                  ...filterState,
                  executingAccount: addToList(filterState.executingAccount, v),
                })
                setNewProgramId(_ => "")
              }
            },
            ~onRemove=i =>
              updateField({
                ...filterState,
                executingAccount: removeFromList(filterState.executingAccount, i),
              }),
            ~draft=newProgramId,
            ~setDraft=setNewProgramId,
            ~validate=isBase58Pubkey,
          )}

          // Discriminators
          <div className="mb-4">
            <button
              onClick={_ => setShowDiscriminators(prev => !prev)}
              className="flex items-center text-xs font-semibold text-slate-700 hover:text-slate-900 mb-2"
            >
              <svg
                className={`w-3 h-3 mr-1 transform transition-transform ${showDiscriminators
                    ? "rotate-90"
                    : ""}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"
                />
              </svg>
              {"Instruction Discriminators (hex)"->React.string}
            </button>
            {showDiscriminators
              ? <div className="pl-4 border-l-2 border-slate-100">
                  {renderListEditor(
                    ~label="d1 (1 byte) - SPL Token style",
                    ~placeholder="0x03",
                    ~values=filterState.d1->Option.getOr([]),
                    ~onAdd=v => {
                      if isHexBytes(v, 1) {
                        updateField({...filterState, d1: addToList(filterState.d1, v)})
                        setNewD1(_ => "")
                      }
                    },
                    ~onRemove=i =>
                      updateField({...filterState, d1: removeFromList(filterState.d1, i)}),
                    ~draft=newD1,
                    ~setDraft=setNewD1,
                    ~validate=v => isHexBytes(v, 1),
                  )}
                  {renderListEditor(
                    ~label="d2 (2 bytes)",
                    ~placeholder="0x0103",
                    ~values=filterState.d2->Option.getOr([]),
                    ~onAdd=v => {
                      if isHexBytes(v, 2) {
                        updateField({...filterState, d2: addToList(filterState.d2, v)})
                        setNewD2(_ => "")
                      }
                    },
                    ~onRemove=i =>
                      updateField({...filterState, d2: removeFromList(filterState.d2, i)}),
                    ~draft=newD2,
                    ~setDraft=setNewD2,
                    ~validate=v => isHexBytes(v, 2),
                  )}
                  {renderListEditor(
                    ~label="d4 (4 bytes) - System Program style",
                    ~placeholder="0x02000000",
                    ~values=filterState.d4->Option.getOr([]),
                    ~onAdd=v => {
                      if isHexBytes(v, 4) {
                        updateField({...filterState, d4: addToList(filterState.d4, v)})
                        setNewD4(_ => "")
                      }
                    },
                    ~onRemove=i =>
                      updateField({...filterState, d4: removeFromList(filterState.d4, i)}),
                    ~draft=newD4,
                    ~setDraft=setNewD4,
                    ~validate=v => isHexBytes(v, 4),
                  )}
                  {renderListEditor(
                    ~label="d8 (8 bytes) - Anchor discriminator",
                    ~placeholder="0xf8c69e91e17587c8",
                    ~values=filterState.d8->Option.getOr([]),
                    ~onAdd=v => {
                      if isHexBytes(v, 8) {
                        updateField({...filterState, d8: addToList(filterState.d8, v)})
                        setNewD8(_ => "")
                      }
                    },
                    ~onRemove=i =>
                      updateField({...filterState, d8: removeFromList(filterState.d8, i)}),
                    ~draft=newD8,
                    ~setDraft=setNewD8,
                    ~validate=v => isHexBytes(v, 8),
                  )}
                </div>
              : React.null}
          </div>

          // Account position filters
          <div className="mb-4">
            <button
              onClick={_ => setShowAccounts(prev => !prev)}
              className="flex items-center text-xs font-semibold text-slate-700 hover:text-slate-900 mb-2"
            >
              <svg
                className={`w-3 h-3 mr-1 transform transition-transform ${showAccounts
                    ? "rotate-90"
                    : ""}`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"
                />
              </svg>
              {`Account Position Filters (a0..a9)${Array.length(activeAccountSlots()) > 0
                  ? ` - ${Int.toString(Array.length(activeAccountSlots()))} active`
                  : ""}`->React.string}
            </button>
            {showAccounts
              ? <div className="pl-4 border-l-2 border-slate-100">
                  <div className="flex space-x-2 mb-2">
                    <select
                      value={Int.toString(accountSlot)}
                      onChange={e => {
                        let target = ReactEvent.Form.target(e)
                        switch Int.fromString(target["value"]) {
                        | Some(n) => setAccountSlot(_ => n)
                        | None => ()
                        }
                      }}
                      className="border border-slate-300 rounded-lg px-2 py-2 text-xs"
                    >
                      {Belt.Array.range(0, 9)
                      ->Array.map(i =>
                        <option key={Int.toString(i)} value={Int.toString(i)}>
                          {`a${Int.toString(i)}`->React.string}
                        </option>
                      )
                      ->React.array}
                    </select>
                    <input
                      type_="text"
                      value={newAccount}
                      onChange={e => {
                        let target = ReactEvent.Form.target(e)
                        setNewAccount(_ => target["value"])
                      }}
                      placeholder="base58 pubkey"
                      className={inputClass}
                    />
                    <button
                      onClick={_ => {
                        if isBase58Pubkey(newAccount) {
                          let cur = getAccountAt(filterState, accountSlot)
                          updateField(
                            setAccountAt(filterState, accountSlot, addToList(cur, newAccount)),
                          )
                          setNewAccount(_ => "")
                        }
                      }}
                      disabled={String.length(newAccount) === 0 || !isBase58Pubkey(newAccount)}
                      className={addBtnClass}
                    >
                      {"Add"->React.string}
                    </button>
                  </div>
                  {activeAccountSlots()
                  ->Array.map(slot => {
                    let values = getAccountAt(filterState, slot)->Option.getOr([])
                    <div key={Int.toString(slot)} className="mb-3">
                      <div className="text-xs text-slate-600 mb-1">
                        {`Position a${Int.toString(slot)}`->React.string}
                      </div>
                      <div className="space-y-1">
                        {values
                        ->Array.mapWithIndex((v, i) =>
                          <div key={Int.toString(i)} className={chipClass}>
                            <span className="text-xs font-mono text-slate-800 truncate">
                              {v->React.string}
                            </span>
                            <button
                              onClick={_ => {
                                let cur = getAccountAt(filterState, slot)
                                updateField(setAccountAt(filterState, slot, removeFromList(cur, i)))
                              }}
                              className="ml-2 text-red-600 hover:text-red-800 text-xs"
                            >
                              {"Remove"->React.string}
                            </button>
                          </div>
                        )
                        ->React.array}
                      </div>
                    </div>
                  })
                  ->React.array}
                </div>
              : React.null}
          </div>

          // is_inner toggle
          <div className="mb-4">
            <label className={labelClass}> {"Is Inner Instruction (CPI)"->React.string} </label>
            <div className="flex space-x-2">
              {[("Both", None), ("Inner only", Some(true)), ("Outer only", Some(false))]
              ->Array.map(((label, value)) => {
                let isActive = filterState.isInner === value
                <button
                  key={label}
                  onClick={_ => updateField({...filterState, isInner: value})}
                  className={`px-3 py-1.5 text-xs font-medium rounded-lg border transition-colors ${isActive
                      ? "bg-slate-800 text-white border-slate-800"
                      : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"}`}
                >
                  {label->React.string}
                </button>
              })
              ->React.array}
            </div>
          </div>

          // tx_success tri-state (wire tx_success, legacy alias is_committed)
          <div className="mb-4">
            <label className={labelClass}> {"Parent Transaction Success"->React.string} </label>
            <div className="flex space-x-2">
              {[("Both", None), ("Successful txs", Some(true)), ("Failed txs", Some(false))]
              ->Array.map(((label, value)) => {
                let isActive = filterState.txSuccess === value
                <button
                  key={label}
                  onClick={_ => updateField({...filterState, txSuccess: value})}
                  className={`px-3 py-1.5 text-xs font-medium rounded-lg border transition-colors ${isActive
                      ? "bg-slate-800 text-white border-slate-800"
                      : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"}`}
                >
                  {label->React.string}
                </button>
              })
              ->React.array}
            </div>
            <p className="mt-1 text-[11px] text-amber-700">
              {"Under the server's failed-transaction trim policy no instruction rows are kept for failed transactions, so \"Failed txs\" matches nothing and \"Successful txs\" is a no-op. Use a transaction filter with success: false to see failed transactions."->React.string}
            </p>
          </div>

          <SolanaJoinHints
            tables={[
              ("transaction", "transaction fields"),
              ("log", "log fields"),
              ("block", "block fields"),
            ]}
            selectedTables={selectedTables}
            onIncludeTable={onIncludeTable}
          />
        </div>
      : React.null}
  </div>
}
