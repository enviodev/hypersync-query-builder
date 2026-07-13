// Wrapper for the exclude-filter editor inside a filter card. The children are
// the same field inputs as the include section, bound to the selection's
// `exclude` filter. Collapsed by default since most queries don't use
// exclusions; it opens automatically whenever the filter has active ones.
@react.component
let make = (~entityNamePlural: string, ~hasExclusions: bool, ~children) => {
  let (isExpanded, setIsExpanded) = React.useState(() => hasExclusions)

  // Reveal the section when exclusions appear (e.g. an example or shared URL)
  React.useEffect1(() => {
    if hasExclusions {
      setIsExpanded(_ => true)
    }
    None
  }, [hasExclusions])

  <div className="mb-6 border border-rose-200 rounded-xl overflow-hidden">
    <button
      type_="button"
      onClick={_ => setIsExpanded(prev => !prev)}
      className="w-full bg-rose-50 px-4 py-3 text-left hover:bg-rose-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-rose-500 transition-colors"
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <h4 className="text-sm font-semibold text-rose-700"> {"Exclude"->React.string} </h4>
          {hasExclusions
            ? <span
                className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-rose-100 text-rose-700"
              >
                {"Active"->React.string}
              </span>
            : <span className="text-xs text-rose-400"> {"Optional"->React.string} </span>}
        </div>
        <svg
          className={`w-4 h-4 text-rose-500 transform transition-transform ${isExpanded
              ? "rotate-180"
              : "rotate-0"}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
        </svg>
      </div>
      {isExpanded
        ? <p className="text-xs text-rose-600 mt-1">
            {`${entityNamePlural} matching the conditions below are excluded from this filter's results, even when they match the conditions above. Leave empty to exclude nothing.`->React.string}
          </p>
        : React.null}
    </button>
    {isExpanded ? <div className="p-4 border-t border-rose-100"> {children} </div> : React.null}
  </div>
}
