open QueryStructure

@react.component
let make = (
  ~filterState: instructionSelection,
  ~onFilterChange: instructionSelection => unit,
  ~onRemove: unit => unit,
  ~filterIndex: int,
  ~isExpanded: bool,
  ~onToggleExpand: unit => unit,
) => {
  let (newProgramId, setNewProgramId) = React.useState(() => "")
  let (newD1, setNewD1) = React.useState(() => "")
  let (newD8, setNewD8) = React.useState(() => "")
  let (newA0, setNewA0) = React.useState(() => "")

  // Example presets
  let computeBudgetExample: instructionSelection = {
    program_id: Some(["ComputeBudget111111111111111111111111111111"]),
    d1: None,
    d8: None,
    a0: None,
    is_inner: None,
  }

  let tokenProgramExample: instructionSelection = {
    program_id: Some(["TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"]),
    d1: None,
    d8: None,
    a0: None,
    is_inner: None,
  }

  let systemProgramExample: instructionSelection = {
    program_id: Some(["11111111111111111111111111111111"]),
    d1: None,
    d8: None,
    a0: None,
    is_inner: None,
  }

  let outerOnlyExample: instructionSelection = {
    program_id: None,
    d1: None,
    d8: None,
    a0: None,
    is_inner: Some(false),
  }

  let addProgramId = () => {
    if newProgramId !== "" {
      let current = filterState.program_id->Option.getOr([])
      onFilterChange({...filterState, program_id: Some(Array.concat(current, [newProgramId]))})
      setNewProgramId(_ => "")
    }
  }

  let removeProgramId = (index: int) => {
    let current = filterState.program_id->Option.getOr([])
    let updated = Belt.Array.keepWithIndex(current, (_, i) => i !== index)
    onFilterChange({...filterState, program_id: Array.length(updated) > 0 ? Some(updated) : None})
  }

  let addD1 = () => {
    if newD1 !== "" {
      let current = filterState.d1->Option.getOr([])
      onFilterChange({...filterState, d1: Some(Array.concat(current, [newD1]))})
      setNewD1(_ => "")
    }
  }

  let removeD1 = (index: int) => {
    let current = filterState.d1->Option.getOr([])
    let updated = Belt.Array.keepWithIndex(current, (_, i) => i !== index)
    onFilterChange({...filterState, d1: Array.length(updated) > 0 ? Some(updated) : None})
  }

  let addD8 = () => {
    if newD8 !== "" {
      let current = filterState.d8->Option.getOr([])
      onFilterChange({...filterState, d8: Some(Array.concat(current, [newD8]))})
      setNewD8(_ => "")
    }
  }

  let removeD8 = (index: int) => {
    let current = filterState.d8->Option.getOr([])
    let updated = Belt.Array.keepWithIndex(current, (_, i) => i !== index)
    onFilterChange({...filterState, d8: Array.length(updated) > 0 ? Some(updated) : None})
  }

  let addA0 = () => {
    if newA0 !== "" {
      let current = filterState.a0->Option.getOr([])
      onFilterChange({...filterState, a0: Some(Array.concat(current, [newA0]))})
      setNewA0(_ => "")
    }
  }

  let removeA0 = (index: int) => {
    let current = filterState.a0->Option.getOr([])
    let updated = Belt.Array.keepWithIndex(current, (_, i) => i !== index)
    onFilterChange({...filterState, a0: Array.length(updated) > 0 ? Some(updated) : None})
  }

  let handleKeyDown = (e, addFn) => {
    if ReactEvent.Keyboard.key(e) === "Enter" {
      addFn()
    }
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
          className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-purple-100 text-purple-800 mr-2"
        >
          {`Instruction #${Int.toString(filterIndex + 1)}`->React.string}
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
          // Example Presets
          <div>
            <label className="block text-xs font-medium text-slate-500 mb-2">
              {"Presets"->React.string}
            </label>
            <div className="flex flex-wrap gap-2">
              <button
                onClick={_ => onFilterChange(computeBudgetExample)}
                className="px-2 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 transition-colors"
              >
                {"ComputeBudget"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange(tokenProgramExample)}
                className="px-2 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 transition-colors"
              >
                {"Token Program"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange(systemProgramExample)}
                className="px-2 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 transition-colors"
              >
                {"System Program"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange(outerOnlyExample)}
                className="px-2 py-1 text-xs rounded border border-slate-200 hover:bg-slate-50 transition-colors"
              >
                {"Outer Only"->React.string}
              </button>
            </div>
          </div>

          // Program ID
          <div>
            <label className="block text-xs font-medium text-slate-700 mb-1">
              {"Program ID"->React.string}
            </label>
            <div className="flex gap-2">
              <input
                type_="text"
                value={newProgramId}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewProgramId(_ => target["value"])
                }}
                onKeyDown={e => handleKeyDown(e, addProgramId)}
                placeholder="e.g. TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
                className="flex-1 border border-slate-300 rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-slate-500"
              />
              <button
                onClick={_ => addProgramId()}
                className="px-2 py-1 text-xs bg-slate-900 text-white rounded hover:bg-slate-700 transition-colors"
              >
                {"Add"->React.string}
              </button>
            </div>
            {switch filterState.program_id {
            | Some(ids) if Array.length(ids) > 0 =>
              <div className="mt-1 flex flex-wrap gap-1">
                {Array.mapWithIndex(ids, (id, i) =>
                  <span
                    key={Int.toString(i)}
                    className="inline-flex items-center px-2 py-0.5 rounded text-xs bg-slate-100 text-slate-700"
                  >
                    {(
                      String.length(id) > 20
                        ? String.slice(id, ~start=0, ~end=8) ++
                          "..." ++
                          String.slice(id, ~start=String.length(id) - 8, ~end=String.length(id))
                        : id
                    )->React.string}
                    <button
                      onClick={_ => removeProgramId(i)}
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

          // D1 Discriminator
          <div>
            <label className="block text-xs font-medium text-slate-700 mb-1">
              {"D1 (1-byte discriminator, hex)"->React.string}
            </label>
            <div className="flex gap-2">
              <input
                type_="text"
                value={newD1}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewD1(_ => target["value"])
                }}
                onKeyDown={e => handleKeyDown(e, addD1)}
                placeholder="e.g. 03"
                className="flex-1 border border-slate-300 rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-slate-500"
              />
              <button
                onClick={_ => addD1()}
                className="px-2 py-1 text-xs bg-slate-900 text-white rounded hover:bg-slate-700 transition-colors"
              >
                {"Add"->React.string}
              </button>
            </div>
            {switch filterState.d1 {
            | Some(vals) if Array.length(vals) > 0 =>
              <div className="mt-1 flex flex-wrap gap-1">
                {Array.mapWithIndex(vals, (v, i) =>
                  <span
                    key={Int.toString(i)}
                    className="inline-flex items-center px-2 py-0.5 rounded text-xs bg-slate-100 text-slate-700"
                  >
                    {v->React.string}
                    <button
                      onClick={_ => removeD1(i)} className="ml-1 text-slate-400 hover:text-red-500"
                    >
                      {"x"->React.string}
                    </button>
                  </span>
                )->React.array}
              </div>
            | _ => React.null
            }}
          </div>

          // D8 Discriminator
          <div>
            <label className="block text-xs font-medium text-slate-700 mb-1">
              {"D8 (8-byte discriminator, hex)"->React.string}
            </label>
            <div className="flex gap-2">
              <input
                type_="text"
                value={newD8}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewD8(_ => target["value"])
                }}
                onKeyDown={e => handleKeyDown(e, addD8)}
                placeholder="e.g. e445a52e51cb9a1d"
                className="flex-1 border border-slate-300 rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-slate-500"
              />
              <button
                onClick={_ => addD8()}
                className="px-2 py-1 text-xs bg-slate-900 text-white rounded hover:bg-slate-700 transition-colors"
              >
                {"Add"->React.string}
              </button>
            </div>
            {switch filterState.d8 {
            | Some(vals) if Array.length(vals) > 0 =>
              <div className="mt-1 flex flex-wrap gap-1">
                {Array.mapWithIndex(vals, (v, i) =>
                  <span
                    key={Int.toString(i)}
                    className="inline-flex items-center px-2 py-0.5 rounded text-xs bg-slate-100 text-slate-700"
                  >
                    {v->React.string}
                    <button
                      onClick={_ => removeD8(i)} className="ml-1 text-slate-400 hover:text-red-500"
                    >
                      {"x"->React.string}
                    </button>
                  </span>
                )->React.array}
              </div>
            | _ => React.null
            }}
          </div>

          // A0 (First Account)
          <div>
            <label className="block text-xs font-medium text-slate-700 mb-1">
              {"A0 (first account key)"->React.string}
            </label>
            <div className="flex gap-2">
              <input
                type_="text"
                value={newA0}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewA0(_ => target["value"])
                }}
                onKeyDown={e => handleKeyDown(e, addA0)}
                placeholder="e.g. So11111111111111111111111111111111111111112"
                className="flex-1 border border-slate-300 rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-slate-500"
              />
              <button
                onClick={_ => addA0()}
                className="px-2 py-1 text-xs bg-slate-900 text-white rounded hover:bg-slate-700 transition-colors"
              >
                {"Add"->React.string}
              </button>
            </div>
            {switch filterState.a0 {
            | Some(vals) if Array.length(vals) > 0 =>
              <div className="mt-1 flex flex-wrap gap-1">
                {Array.mapWithIndex(vals, (v, i) =>
                  <span
                    key={Int.toString(i)}
                    className="inline-flex items-center px-2 py-0.5 rounded text-xs bg-slate-100 text-slate-700"
                  >
                    {(
                      String.length(v) > 20
                        ? String.slice(v, ~start=0, ~end=8) ++
                          "..." ++
                          String.slice(v, ~start=String.length(v) - 8, ~end=String.length(v))
                        : v
                    )->React.string}
                    <button
                      onClick={_ => removeA0(i)} className="ml-1 text-slate-400 hover:text-red-500"
                    >
                      {"x"->React.string}
                    </button>
                  </span>
                )->React.array}
              </div>
            | _ => React.null
            }}
          </div>

          // Is Inner toggle
          <div>
            <label className="block text-xs font-medium text-slate-700 mb-1">
              {"Instruction Type"->React.string}
            </label>
            <div className="flex gap-2">
              <button
                onClick={_ => onFilterChange({...filterState, is_inner: None})}
                className={`px-2 py-1 text-xs rounded border transition-colors ${switch filterState.is_inner {
                  | None => "bg-slate-900 text-white border-slate-900"
                  | Some(_) => "border-slate-200 hover:bg-slate-50"
                  }}`}
              >
                {"All"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange({...filterState, is_inner: Some(false)})}
                className={`px-2 py-1 text-xs rounded border transition-colors ${switch filterState.is_inner {
                  | Some(false) => "bg-slate-900 text-white border-slate-900"
                  | _ => "border-slate-200 hover:bg-slate-50"
                  }}`}
              >
                {"Outer Only"->React.string}
              </button>
              <button
                onClick={_ => onFilterChange({...filterState, is_inner: Some(true)})}
                className={`px-2 py-1 text-xs rounded border transition-colors ${switch filterState.is_inner {
                  | Some(true) => "bg-slate-900 text-white border-slate-900"
                  | _ => "border-slate-200 hover:bg-slate-50"
                  }}`}
              >
                {"Inner Only"->React.string}
              </button>
            </div>
          </div>
        </div>
      : React.null}
  </div>
}
