open QueryStructure

@react.component
let make = (
  ~filterState: transactionSelection,
  ~onFilterChange: transactionSelection => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int,
  ~isExpanded: bool,
  ~onToggleExpand: unit => unit,
) => {
  let (newFeePayer, setNewFeePayer) = React.useState(() => "")

  let successOnlyExample: transactionSelection = {
    fee_payer: None,
    success: Some(true),
  }

  let failedOnlyExample: transactionSelection = {
    fee_payer: None,
    success: Some(false),
  }

  let addFeePayer = () => {
    if newFeePayer !== "" {
      let current = filterState.fee_payer->Option.getOr([])
      onFilterChange({...filterState, fee_payer: Some(Array.concat(current, [newFeePayer]))})
      setNewFeePayer(_ => "")
    }
  }

  let removeFeePayer = (index: int) => {
    let current = filterState.fee_payer->Option.getOr([])
    let updated = Belt.Array.keepWithIndex(current, (_, i) => i !== index)
    onFilterChange({...filterState, fee_payer: Array.length(updated) > 0 ? Some(updated) : None})
  }

  <div className="border border-slate-200 rounded-lg overflow-hidden bg-white">
    <div
      className="px-4 py-3 flex items-center justify-between bg-slate-50 border-b border-slate-200"
    >
      <button
        onClick={_ => onToggleExpand()}
        className="flex items-center text-left focus:outline-none flex-1"
      >
        <span
          className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 mr-2"
        >
          {`Transaction #${Int.toString(filterIndex + 1)}`->React.string}
        </span>
        <svg
          className={`w-4 h-4 text-slate-400 transform transition-transform ${isExpanded
              ? "rotate-180"
              : ""}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      <button
        onClick={_ => onRemove()}
        className="text-slate-400 hover:text-red-500 transition-colors ml-2"
      >
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </button>
    </div>

    {isExpanded
      ? <div className="p-4 space-y-4">
          // Presets
          <div>
            <label className="block text-xs font-medium text-slate-500 mb-2">
              {"Presets"->React.string}
            </label>
            <div className="flex flex-wrap gap-2">
              <button
                onClick={_ => onFilterChange(successOnlyExample)}
                className="px-2 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 transition-colors"
              >
                {"Successful Only"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange(failedOnlyExample)}
                className="px-2 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 transition-colors"
              >
                {"Failed Only"->React.string}
              </button>
            </div>
          </div>

          // Fee Payer
          <div>
            <label className="block text-xs font-medium text-slate-700 mb-1">
              {"Fee Payer"->React.string}
            </label>
            <div className="flex gap-2">
              <input
                type_="text"
                value={newFeePayer}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewFeePayer(_ => target["value"])
                }}
                onKeyDown={e => {
                  if ReactEvent.Keyboard.key(e) === "Enter" {
                    addFeePayer()
                  }
                }}
                placeholder="Solana public key"
                className="flex-1 border border-slate-300 rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-slate-500"
              />
              <button
                onClick={_ => addFeePayer()}
                className="px-2 py-1 text-xs bg-slate-900 text-white rounded hover:bg-slate-700 transition-colors"
              >
                {"Add"->React.string}
              </button>
            </div>
            {switch filterState.fee_payer {
            | Some(payers) if Array.length(payers) > 0 =>
              <div className="mt-1 flex flex-wrap gap-1">
                {Array.mapWithIndex(payers, (p, i) =>
                  <span
                    key={Int.toString(i)}
                    className="inline-flex items-center px-2 py-0.5 rounded text-xs bg-slate-100 text-slate-700"
                  >
                    {(
                      String.length(p) > 20
                        ? String.slice(p, ~start=0, ~end=8) ++
                          "..." ++
                          String.slice(p, ~start=String.length(p) - 8, ~end=String.length(p))
                        : p
                    )->React.string}
                    <button
                      onClick={_ => removeFeePayer(i)}
                      className="ml-1 text-slate-400 hover:text-red-500"
                    >
                      {"x"->React.string}
                    </button>
                  </span>
                )->React.array}
              </div>
            | _ => React.null
            }}
          </div>

          // Success toggle
          <div>
            <label className="block text-xs font-medium text-slate-700 mb-1">
              {"Transaction Status"->React.string}
            </label>
            <div className="flex gap-2">
              <button
                onClick={_ => onFilterChange({...filterState, success: None})}
                className={`px-2 py-1 text-xs rounded border transition-colors ${switch filterState.success {
                  | None => "bg-slate-900 text-white border-slate-900"
                  | Some(_) => "border-slate-200 hover:bg-slate-50"
                  }}`}
              >
                {"All"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange({...filterState, success: Some(true)})}
                className={`px-2 py-1 text-xs rounded border transition-colors ${switch filterState.success {
                  | Some(true) => "bg-green-700 text-white border-green-700"
                  | _ => "border-slate-200 hover:bg-slate-50"
                  }}`}
              >
                {"Successful"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange({...filterState, success: Some(false)})}
                className={`px-2 py-1 text-xs rounded border transition-colors ${switch filterState.success {
                  | Some(false) => "bg-red-700 text-white border-red-700"
                  | _ => "border-slate-200 hover:bg-slate-50"
                  }}`}
              >
                {"Failed"->React.string}
              </button>
            </div>
          </div>
        </div>
      : React.null}
  </div>
}
