// Option record for selection

type selectOption<'a> = {
  value: 'a,
  label: string,
}

@react.component
let make = (
  ~options: array<selectOption<'a>>,
  ~selectedValues: array<'a>,
  ~onSelectionChange: array<'a> => unit,
  ~placeholder: string,
  ~title: string,
) => {
let (searchTerm, setSearchTerm) = React.useState(() => "")
let (isOpen, setIsOpen) = React.useState(() => false)
let (highlightIndex, setHighlightIndex) = React.useState(() => 0)

React.useEffect1(() => {
  setHighlightIndex(_ => 0)
  None
}, [searchTerm]);

  let filteredOptions =
    options
    ->Array.filter(option =>
        !Array.includes(selectedValues, option.value) &&
        (searchTerm === "" ||
         String.includes(
           String.toLowerCase(option.label),
           String.toLowerCase(searchTerm),
         )
        )
      )

  let labelFromValue = value =>
    options
    ->Array.find(option => option.value === value)
    ->Option.map(o => o.label)
    ->Option.getWithDefault("")

  let addValue = value => {
    if !Array.includes(selectedValues, value) {
      onSelectionChange(Array.concat(selectedValues, [value]))
    }
    setSearchTerm(_ => "")
    setIsOpen(_ => true)
  }

  let removeValue = value => {
    let newSelection = Array.filter(selectedValues, v => v !== value)
    onSelectionChange(newSelection)
  }

  <div className="relative">
    <div className="mb-2">
      <label className="text-sm font-medium text-gray-700">
        {title->React.string}
      </label>
    </div>
    <div className="flex flex-wrap items-center gap-2 border border-gray-300 rounded-md p-2">
      {selectedValues
      ->Array.map(value =>
          <span
            key={labelFromValue(value)}
            className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
            {labelFromValue(value)->React.string}
            <button
              onClick={_ => removeValue(value)}
              className="ml-1 text-gray-500 hover:text-gray-700 focus:outline-none">
              <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </span>
        )
      ->React.array}
      <input
        value={searchTerm}
        onFocus={_ => setIsOpen(_ => true)}
        onBlur={_ => Js.Global.setTimeout(_ => setIsOpen(_ => false), 100)->ignore}
        onChange={e => {
          let target = ReactEvent.Form.target(e)
          setSearchTerm(_ => target["value"])
        }}
        onKeyDown={e => {
          switch ReactEvent.Keyboard.key(e) {
          | "ArrowDown" => {
              ReactEvent.Synthetic.preventDefault(e)
              setIsOpen(_ => true)
              let len = Array.length(filteredOptions)
              let next = highlightIndex + 1
              setHighlightIndex(_ => next >= len ? len - 1 : next)
            }
          | "ArrowUp" => {
              ReactEvent.Synthetic.preventDefault(e)
              let prev = highlightIndex - 1
              setHighlightIndex(_ => prev < 0 ? 0 : prev)
            }
          | "Enter" => {
              ReactEvent.Synthetic.preventDefault(e)
              switch Array.get(filteredOptions, highlightIndex) {
              | Some(opt) => addValue(opt.value)
              | None => ()
              }
            }
          | _ => ()
          }
        }}
        placeholder={placeholder}
        className="flex-1 min-w-0 text-sm focus:outline-none"
      />
    </div>
    {isOpen && Array.length(filteredOptions) > 0 ?
      <div className="absolute z-10 mt-1 w-full bg-white shadow-lg rounded-md border border-gray-200 max-h-60 overflow-auto">
        {filteredOptions
        ->Array.mapWithIndex((option, index) =>
            <button
              key={Int.toString(index)}
              onMouseDown={_ => addValue(option.value)}
              onMouseEnter={_ => setHighlightIndex(_ => index)}
              className={
                "w-full text-left px-3 py-2 hover:bg-gray-50 text-sm" ++
                (index === highlightIndex ? " bg-gray-100" : "")
              }>
              {option.label->React.string}
            </button>
          )
        ->React.array}
      </div>
    : React.null}
  </div>
}

