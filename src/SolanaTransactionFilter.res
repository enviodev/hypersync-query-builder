open SolanaQueryStructure

type filterState = SolanaQueryStructure.transactionSelection

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
) => {
  let (newFeePayer, setNewFeePayer) = React.useState(() => "")

  let updateField = (newState: filterState) => onFilterChange(newState)

  let addFeePayer = (v: string) => {
    if isBase58Pubkey(v) {
      updateField({
        ...filterState,
        feePayer: Some(Array.concat(filterState.feePayer->Option.getOr([]), [v])),
      })
      setNewFeePayer(_ => "")
    }
  }

  let removeFeePayer = (idx: int) => {
    let cur = filterState.feePayer->Option.getOr([])
    let next = Belt.Array.keepWithIndex(cur, (_, i) => i !== idx)
    updateField({...filterState, feePayer: Array.length(next) > 0 ? Some(next) : None})
  }

  let hasFilters = Option.isSome(filterState.feePayer) || Option.isSome(filterState.success)

  <div
    className="relative bg-white rounded-xl border border-slate-200 shadow-sm transition-all w-full">
    <div className="p-4 border-b border-slate-100">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-slate-900">
            {`Transaction Filter ${Int.toString(filterIndex + 1)}`->React.string}
          </h3>
          {hasFilters
            ? <span
                className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
                {"Active"->React.string}
              </span>
            : React.null}
        </div>
        <div className="flex items-center space-x-1">
          <button
            onClick={_ => onToggleExpand()}
            className="inline-flex items-center p-2 text-sm font-medium text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded-lg transition-colors">
            <svg
              className={`w-4 h-4 transform transition-transform ${isExpanded
                  ? "rotate-180"
                  : "rotate-0"}`}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24">
              <path
                strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7"
              />
            </svg>
          </button>
          <button
            onClick={_ => onRemove()}
            className="inline-flex items-center p-2 text-sm font-medium text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition-colors">
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
          // Fee payer
          <div className="mb-4">
            <label className={labelClass}> {"Fee Payer Pubkeys (base58)"->React.string} </label>
            <div className="flex space-x-2 mb-2">
              <input
                type_="text"
                value={newFeePayer}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewFeePayer(_ => target["value"])
                }}
                onKeyDown={e =>
                  if ReactEvent.Keyboard.key(e) === "Enter" {
                    ReactEvent.Synthetic.preventDefault(e)
                    addFeePayer(newFeePayer)
                  }}
                placeholder="base58 pubkey"
                className={inputClass}
              />
              <button
                onClick={_ => addFeePayer(newFeePayer)}
                disabled={String.length(newFeePayer) === 0 || !isBase58Pubkey(newFeePayer)}
                className={addBtnClass}>
                {(
                  Array.length(filterState.feePayer->Option.getOr([])) > 0 ? "Add (OR)" : "Add"
                )->React.string}
              </button>
            </div>
            <div className="space-y-1">
              {filterState.feePayer
              ->Option.getOr([])
              ->Array.mapWithIndex((v, i) =>
                <div key={Int.toString(i)} className={chipClass}>
                  <span className="text-xs font-mono text-slate-800 truncate">
                    {v->React.string}
                  </span>
                  <button
                    onClick={_ => removeFeePayer(i)}
                    className="ml-2 text-red-600 hover:text-red-800 text-xs font-medium transition-colors">
                    {"Remove"->React.string}
                  </button>
                </div>
              )
              ->React.array}
            </div>
          </div>

          // Success toggle
          <div className="mb-4">
            <label className={labelClass}> {"Success"->React.string} </label>
            <div className="flex space-x-2">
              {[("Either", None), ("Success only", Some(true)), ("Failed only", Some(false))]
              ->Array.map(((label, value)) => {
                let isActive = filterState.success === value
                <button
                  key={label}
                  onClick={_ => updateField({...filterState, success: value})}
                  className={`px-3 py-1.5 text-xs font-medium rounded-lg border transition-colors ${isActive
                      ? "bg-slate-800 text-white border-slate-800"
                      : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"}`}>
                  {label->React.string}
                </button>
              })
              ->React.array}
            </div>
          </div>

          // Joins
          <div>
            <label className={labelClass}> {"Joins"->React.string} </label>
            <label className="inline-flex items-center text-xs text-slate-700 cursor-pointer">
              <input
                type_="checkbox"
                checked={filterState.includeInstructions}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  updateField({...filterState, includeInstructions: target["checked"]})
                }}
                className="mr-2"
              />
              {"include_instructions"->React.string}
            </label>
          </div>
        </div>
      : React.null}
  </div>
}
