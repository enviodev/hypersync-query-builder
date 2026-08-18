// Joins on Solana HyperSync are not per-selection booleans: they follow
// field_selection. The old include_transaction / include_logs / include_instructions
// / include_instruction flags are not part of the v0.2.0 wire API and are ignored by
// the server, so this component replaces them with what the join model actually is:
// one-click shortcuts that add default columns of a related table to field_selection.
@react.component
let make = (
  ~tables: array<(string, string)>,
  ~selectedTables: array<string>,
  ~onIncludeTable: string => unit,
) => {
  <div>
    <label className="block text-xs font-medium text-slate-700 mb-1">
      {"Also return (joins follow field selection)"->React.string}
    </label>
    <p className="text-[11px] text-slate-500 mb-2">
      {"There are no include_* flags. A related table comes back only when it has columns selected."->React.string}
    </p>
    <div className="flex flex-wrap gap-2">
      {tables
      ->Array.map(((table, label)) => {
        let alreadySelected = Array.includes(selectedTables, table)
        <button
          key={table}
          onClick={_ => onIncludeTable(table)}
          disabled={alreadySelected}
          className={`px-3 py-1.5 text-xs font-medium rounded-lg border transition-colors ${alreadySelected
              ? "bg-emerald-50 text-emerald-700 border-emerald-200 cursor-default"
              : "bg-white text-slate-700 border-slate-200 hover:bg-slate-50"}`}
        >
          {(alreadySelected ? `${label} selected` : `+ ${label}`)->React.string}
        </button>
      })
      ->React.array}
    </div>
  </div>
}
