// Wrapper for the exclude-filter editor inside a filter card. The children are
// the same field inputs as the include section, bound to the selection's
// `exclude` filter.
@react.component
let make = (~entityNamePlural: string, ~hasExclusions: bool, ~children) => {
  <div className="mb-6 border border-rose-200 rounded-xl overflow-hidden">
    <div className="bg-rose-50 px-4 py-3 border-b border-rose-100">
      <div className="flex items-center space-x-2">
        <h4 className="text-sm font-semibold text-rose-700"> {"Exclude"->React.string} </h4>
        {hasExclusions
          ? <span
              className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-rose-100 text-rose-700"
            >
              {"Active"->React.string}
            </span>
          : React.null}
      </div>
      <p className="text-xs text-rose-600 mt-1">
        {`${entityNamePlural} matching the conditions below are excluded from this filter's results, even when they match the conditions above. Leave empty to exclude nothing.`->React.string}
      </p>
    </div>
    <div className="p-4"> {children} </div>
  </div>
}
