type selectOption<'a> = {
  value: 'a,
  label: string,
  description: string,
}

@react.component
let make = (
  ~options: array<selectOption<'a>>,
  ~selectedValues: array<'a>,
  ~onSelectionChange: array<'a> => unit,
  ~placeholder: string,
  ~title: string,
) => {
  let (isOpen, setIsOpen) = React.useState(() => false)

  let toggleOption = (value: 'a) => {
    let isSelected = Array.includes(selectedValues, value)
    let newSelection = if isSelected {
      Array.filter(selectedValues, v => v !== value)
    } else {
      Array.concat(selectedValues, [value])
    }
    onSelectionChange(newSelection)
  }

  let selectedLabels = Array.filterMap(options, option =>
    if Array.includes(selectedValues, option.value) {
      Some(option.label)
    } else {
      None
    }
  )

  <div className="relative">
    <div className="mb-2">
      <label className="text-sm font-medium text-gray-700"> {title->React.string} </label>
    </div>

    <button
      type_="button"
      onClick={_ => setIsOpen(prev => !prev)}
      className="relative w-full bg-white border border-gray-300 rounded-md pl-3 pr-10 py-2 text-left cursor-pointer focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500 text-sm">
      <span className="block truncate">
        {switch Array.length(selectedLabels) {
        | 0 => placeholder->React.string
        | 1 => Array.getUnsafe(selectedLabels, 0)->React.string
        | count => `${Int.toString(count)} selected`->React.string
        }}
      </span>
      <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
        <svg
          className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
        </svg>
      </span>
    </button>

    {isOpen
      ? <div
          className="absolute z-10 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md border border-gray-200 overflow-auto">
          <div className="py-1">
            {Array.mapWithIndex(options, (option, index) => {
              let isSelected = Array.includes(selectedValues, option.value)
              <button
                key={Int.toString(index)}
                type_="button"
                onClick={_ => toggleOption(option.value)}
                className="relative w-full text-left px-3 py-2 hover:bg-gray-50 focus:outline-none focus:bg-gray-50">
                <div className="flex items-center">
                  <input
                    type_="checkbox"
                    checked={isSelected}
                    onChange={_ => ()}
                    className="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                  />
                  <div className="ml-3 flex-1">
                    <div className="text-sm font-medium text-gray-900">
                      {option.label->React.string}
                    </div>
                    <div className="text-xs text-gray-500 mt-1">
                      {option.description->React.string}
                    </div>
                  </div>
                </div>
              </button>
            })->React.array}
          </div>
        </div>
      : React.null}
  </div>
}
