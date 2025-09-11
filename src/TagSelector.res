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
  ~onOpen: (unit => unit) =?,
  ~onClose: (unit => unit) =?,
  ~forceOpen: bool=?,
  ~showSelectedChips: bool=?,
  ~showInput: bool=?,
) => {
  let forceOpen_ = switch forceOpen { | Some(v) => v | None => false }
  let showSelectedChips_ = switch showSelectedChips { | Some(v) => v | None => true }
  let showInput_ = switch showInput { | Some(v) => v | None => true }
  let (searchTerm, setSearchTerm) = React.useState(() => "")
  let (isOpen, setIsOpen) = React.useState(() => forceOpen_)
  let (highlightIndex, setHighlightIndex) = React.useState(() => 0)
  let addValue = value => {
    if !Array.includes(selectedValues, value) {
      onSelectionChange(Array.concat(selectedValues, [value]))
    }
    setSearchTerm(_ => "")
    setIsOpen(_ => true)
  }

  let filteredOptions =
    options->Array.filter(option =>
      !Array.includes(selectedValues, option.value) &&
      (searchTerm === "" ||
        String.includes(String.toLowerCase(option.label), String.toLowerCase(searchTerm)))
    )
  let handleKeyDown = e => {
    let colCount: int = %raw("(typeof window !== 'undefined' ? (window.innerWidth >= 1280 ? 3 : (window.innerWidth >= 640 ? 2 : 1)) : 1)")
    switch ReactEvent.Keyboard.key(e) {
    | "ArrowDown" => {
        ReactEvent.Synthetic.preventDefault(e)
        setIsOpen(_ => true)
        let len = Array.length(filteredOptions)
        let next = highlightIndex + colCount
        setHighlightIndex(_ => next >= len ? len - 1 : next)
      }
    | "ArrowUp" => {
        ReactEvent.Synthetic.preventDefault(e)
        let prev = highlightIndex - colCount
        setHighlightIndex(_ => prev < 0 ? 0 : prev)
      }
    | "ArrowRight" => {
        ReactEvent.Synthetic.preventDefault(e)
        let len = Array.length(filteredOptions)
        let next = highlightIndex + 1
        setHighlightIndex(_ => next >= len ? len - 1 : next)
      }
    | "ArrowLeft" => {
        ReactEvent.Synthetic.preventDefault(e)
        let prev = highlightIndex - 1
        setHighlightIndex(_ => prev < 0 ? 0 : prev)
      }
    | "Escape" => {
        if !forceOpen_ {
          setIsOpen(_ => false)
          switch onClose {
          | Some(cb) => cb()
          | None => ()
          }
        }
      }
    | "Enter" => {
        ReactEvent.Synthetic.preventDefault(e)
        switch filteredOptions[highlightIndex] {
        | Some(opt) => addValue(opt.value)
        | None => ()
        }
      }
    | _ => ()
    }
  }

  React.useEffect1(() => {
    setHighlightIndex(_ => 0)
    None
  }, [searchTerm])

  let labelFromValue = value =>
    options
    ->Array.find(option => option.value === value)
    ->Option.map(o => o.label)
    ->Option.getOr("")

  let removeValue = value => {
    let newSelection = Array.filter(selectedValues, v => v !== value)
    onSelectionChange(newSelection)
  }

  <div className="relative">
    <div className="mb-2">
      <label className="text-sm font-medium text-gray-700"> {title->React.string} </label>
    </div>
    <div className="flex flex-wrap items-center gap-2 border border-gray-300 rounded-md p-2">
      {showSelectedChips_
        ? selectedValues
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
          ->React.array
        : React.null}
      {showInput_
        ? <input
            value={searchTerm}
            onFocus={_ => {
              setIsOpen(_ => true)
              switch onOpen {
              | Some(cb) => cb()
              | None => ()
              }
            }}
            onBlur={_ =>
              Js.Global.setTimeout(
                _ => {
                  if !forceOpen_ {
                    setIsOpen(_ => false)
                    switch onClose {
                    | Some(cb) => cb()
                    | None => ()
                    }
                  }
                },
                100,
              )->ignore}
            onChange={e => {
              let target = ReactEvent.Form.target(e)
              setSearchTerm(_ => target["value"])
            }}
            onKeyDown={handleKeyDown}
            placeholder={placeholder}
            className="flex-1 min-w-0 text-sm focus:outline-none"
            autoFocus={forceOpen_}
          />
        : React.null}
    </div>
    {(forceOpen_ || isOpen)
      ? <>
          <div className="mt-2 text-xs text-gray-500">
            {"Type to search. Use ↑/↓ to navigate, Enter to add."->React.string}
          </div>
          {Array.length(filteredOptions) > 0
            ? <div className="mt-1 w-full bg-white rounded-md border border-gray-200 max-h-72 overflow-y-auto p-2"
                onKeyDown={handleKeyDown}>
                <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-1">
                  {filteredOptions
                  ->Array.mapWithIndex((option, index) =>
                    <button
                      key={Int.toString(index)}
                      onMouseDown={e => { ReactEvent.Synthetic.preventDefault(e); addValue(option.value) }}
                      onMouseEnter={_ => setHighlightIndex(_ => index)}
                      className={"text-left px-3 py-1.5 text-sm rounded border" ++ (
                        index === highlightIndex
                          ? " bg-blue-50 border-blue-300 text-blue-900 font-semibold ring-2 ring-blue-200"
                          : " border-transparent hover:bg-gray-50"
                      )}>
                      {option.label->React.string}
                    </button>
                  )
                  ->React.array}
                </div>
              </div>
            : <div className="mt-1 w-full rounded-md border border-gray-200 px-3 py-2 text-sm text-gray-400">
                {"No matches"->React.string}
              </div>}
        </>
      : React.null}
  </div>
}
