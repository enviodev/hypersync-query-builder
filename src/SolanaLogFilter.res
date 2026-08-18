open SolanaQueryStructure

type filterState = SolanaQueryStructure.logSelection

let labelClass = "block text-xs font-medium text-slate-700 mb-1"
let inputClass = "flex-1 border border-slate-300 rounded-lg px-3 py-2 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition-colors"
let addBtnClass = "px-3 py-2 bg-slate-700 text-white text-xs font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 disabled:opacity-50 transition-colors"
let chipClass = "flex items-center justify-between bg-slate-50 px-3 py-1.5 rounded-lg border border-slate-100"

let isBase58Pubkey = SolanaInstructionFilter.isBase58Pubkey

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
  let (newKind, setNewKind) = React.useState(() => "")

  let updateField = (newState: filterState) => onFilterChange(newState)

  let addProgramId = (v: string) => {
    if isBase58Pubkey(v) {
      updateField({
        ...filterState,
        programId: Some(Array.concat(filterState.programId->Option.getOr([]), [v])),
      })
      setNewProgramId(_ => "")
    }
  }

  let removeProgramId = (idx: int) => {
    let cur = filterState.programId->Option.getOr([])
    let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== idx)
    updateField({...filterState, programId: Array.length(next) > 0 ? Some(next) : None})
  }

  let addKind = (v: string) => {
    let trimmed = String.trim(v)
    if String.length(trimmed) > 0 {
      updateField({
        ...filterState,
        kind: Some(Array.concat(filterState.kind->Option.getOr([]), [trimmed])),
      })
      setNewKind(_ => "")
    }
  }

  let removeKind = (idx: int) => {
    let cur = filterState.kind->Option.getOr([])
    let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== idx)
    updateField({...filterState, kind: Array.length(next) > 0 ? Some(next) : None})
  }

  let hasFilters = Option.isSome(filterState.programId) || Option.isSome(filterState.kind)

  <div
    className="relative bg-white rounded-xl border border-slate-200 shadow-sm transition-all w-full"
  >
    <div className="p-4 border-b border-slate-100">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-slate-900">
            {`Log Filter ${Int.toString(filterIndex + 1)}`->React.string}
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
          // Program IDs
          <div className="mb-4">
            <label className={labelClass}> {"Program IDs (base58)"->React.string} </label>
            <div className="flex space-x-2 mb-2">
              <input
                type_="text"
                value={newProgramId}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewProgramId(_ => target["value"])
                }}
                onKeyDown={e =>
                  if ReactEvent.Keyboard.key(e) === "Enter" {
                    ReactEvent.Synthetic.preventDefault(e)
                    addProgramId(newProgramId)
                  }}
                placeholder="base58 program pubkey"
                className={inputClass}
              />
              <button
                onClick={_ => addProgramId(newProgramId)}
                disabled={String.length(newProgramId) === 0 || !isBase58Pubkey(newProgramId)}
                className={addBtnClass}
              >
                {(
                  Array.length(filterState.programId->Option.getOr([])) > 0 ? "Add (OR)" : "Add"
                )->React.string}
              </button>
            </div>
            <div className="space-y-1">
              {filterState.programId
              ->Option.getOr([])
              ->Array.mapWithIndex((v, i) =>
                <div key={Int.toString(i)} className={chipClass}>
                  <span className="text-xs font-mono text-slate-800 truncate">
                    {v->React.string}
                  </span>
                  <button
                    onClick={_ => removeProgramId(i)}
                    className="ml-2 text-red-600 hover:text-red-800 text-xs font-medium transition-colors"
                  >
                    {"Remove"->React.string}
                  </button>
                </div>
              )
              ->React.array}
            </div>
          </div>

          // Kind
          <div className="mb-4">
            <label className={labelClass}> {"Log Kind"->React.string} </label>
            <p className="text-[11px] text-slate-500 mb-1">
              {"One of invoke, success, failed, consumed, log, data, other. SQD-ingested and default RPC-ingested ranges only carry log / data / other."->React.string}
            </p>
            <div className="flex space-x-2 mb-2">
              <input
                type_="text"
                value={newKind}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewKind(_ => target["value"])
                }}
                onKeyDown={e =>
                  if ReactEvent.Keyboard.key(e) === "Enter" {
                    ReactEvent.Synthetic.preventDefault(e)
                    addKind(newKind)
                  }}
                placeholder="log | data"
                className={inputClass}
              />
              <button
                onClick={_ => addKind(newKind)}
                disabled={String.length(String.trim(newKind)) === 0}
                className={addBtnClass}
              >
                {(
                  Array.length(filterState.kind->Option.getOr([])) > 0 ? "Add (OR)" : "Add"
                )->React.string}
              </button>
            </div>
            <div className="space-y-1">
              {filterState.kind
              ->Option.getOr([])
              ->Array.mapWithIndex((v, i) =>
                <div key={Int.toString(i)} className={chipClass}>
                  <span className="text-xs font-mono text-slate-800"> {v->React.string} </span>
                  <button
                    onClick={_ => removeKind(i)}
                    className="ml-2 text-red-600 hover:text-red-800 text-xs font-medium transition-colors"
                  >
                    {"Remove"->React.string}
                  </button>
                </div>
              )
              ->React.array}
            </div>
          </div>

          <SolanaJoinHints
            tables={[
              ("transaction", "transaction fields"),
              ("instruction_call", "instruction fields"),
              ("block", "block fields"),
            ]}
            selectedTables={selectedTables}
            onIncludeTable={onIncludeTable}
          />
        </div>
      : React.null}
  </div>
}
