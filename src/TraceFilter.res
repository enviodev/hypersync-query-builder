open QueryStructure

type traceFilterState = QueryStructure.traceSelection

@react.component
let make = (
  ~filterState: traceFilterState,
  ~onFilterChange,
  ~onRemove,
  ~filterIndex,
  ~isExpanded: bool,
  ~onToggleExpand,
) => {
  let (newFrom, setNewFrom) = React.useState(() => "")
  let (newTo, setNewTo) = React.useState(() => "")
  let (newAddress, setNewAddress) = React.useState(() => "")
  let (newCallType, setNewCallType) = React.useState(() => "")
  let (newRewardType, setNewRewardType) = React.useState(() => "")
  let (newKind, setNewKind) = React.useState(() => "")
  let (newSighash, setNewSighash) = React.useState(() => "")

  // Example filter states
  let callExample: traceFilterState = {
    from_: None,
    to_: None,
    address: None,
    callType: Some(["call"]),
    rewardType: None,
    kind: None,
    sighash: None,
  }

  let createExample: traceFilterState = {
    from_: None,
    to_: None,
    address: None,
    callType: Some(["create"]),
    rewardType: None,
    kind: None,
    sighash: None,
  }

  let suicideExample: traceFilterState = {
    from_: None,
    to_: None,
    address: None,
    callType: Some(["suicide"]),
    rewardType: None,
    kind: None,
    sighash: None,
  }

  let rewardExample: traceFilterState = {
    from_: None,
    to_: None,
    address: None,
    callType: None,
    rewardType: Some(["block"]),
    kind: None,
    sighash: None,
  }

  let setCallExample = () => {
    onFilterChange(callExample)
  }

  let setCreateExample = () => {
    onFilterChange(createExample)
  }

  let setSuicideExample = () => {
    onFilterChange(suicideExample)
  }

  let setRewardExample = () => {
    onFilterChange(rewardExample)
  }

  let addFrom = () => {
    if newFrom !== "" && newFrom->String.startsWith("0x") {
      onFilterChange({
        ...filterState,
        from_: Some(Array.concat(filterState.from_->Option.getOr([]), [newFrom])),
      })
      setNewFrom(_ => "")
    }
  }

  let removeFrom = index => {
    let currentArray = filterState.from_->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      from_: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let addTo = () => {
    if newTo !== "" && newTo->String.startsWith("0x") {
      onFilterChange({
        ...filterState,
        to_: Some(Array.concat(filterState.to_->Option.getOr([]), [newTo])),
      })
      setNewTo(_ => "")
    }
  }

  let removeTo = index => {
    let currentArray = filterState.to_->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      to_: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let addAddress = () => {
    if newAddress !== "" && newAddress->String.startsWith("0x") {
      onFilterChange({
        ...filterState,
        address: Some(Array.concat(filterState.address->Option.getOr([]), [newAddress])),
      })
      setNewAddress(_ => "")
    }
  }

  let removeAddress = index => {
    let currentArray = filterState.address->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      address: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let addCallType = () => {
    if newCallType !== "" {
      onFilterChange({
        ...filterState,
        callType: Some(Array.concat(filterState.callType->Option.getOr([]), [newCallType])),
      })
      setNewCallType(_ => "")
    }
  }

  let removeCallType = index => {
    let currentArray = filterState.callType->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      callType: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let addRewardType = () => {
    if newRewardType !== "" {
      onFilterChange({
        ...filterState,
        rewardType: Some(Array.concat(filterState.rewardType->Option.getOr([]), [newRewardType])),
      })
      setNewRewardType(_ => "")
    }
  }

  let removeRewardType = index => {
    let currentArray = filterState.rewardType->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      rewardType: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let addKind = () => {
    if newKind !== "" {
      onFilterChange({
        ...filterState,
        kind: Some(Array.concat(filterState.kind->Option.getOr([]), [newKind])),
      })
      setNewKind(_ => "")
    }
  }

  let removeKind = index => {
    let currentArray = filterState.kind->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      kind: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let addSighash = () => {
    if newSighash !== "" && newSighash->String.startsWith("0x") {
      onFilterChange({
        ...filterState,
        sighash: Some(Array.concat(filterState.sighash->Option.getOr([]), [newSighash])),
      })
      setNewSighash(_ => "")
    }
  }

  let removeSighash = index => {
    let currentArray = filterState.sighash->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      sighash: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let generateEnglishDescription = () => {
    TraceBooleanLogicGenerator.generateEnglishDescription(filterState)
  }

  <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
    <div className="flex items-center justify-between mb-4">
      <div className="flex items-center">
        <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center mr-3">
          <svg
            className="w-4 h-4 text-orange-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
        </div>
        <div>
          <h3 className="text-lg font-medium text-gray-900">
            {"Trace Filter"->React.string}
            {" #"->React.string}
            {Int.toString(filterIndex + 1)->React.string}
          </h3>
          <p className="text-sm text-gray-500"> {generateEnglishDescription()->React.string} </p>
        </div>
      </div>
      <div className="flex items-center space-x-2">
        <button onClick={_ => onToggleExpand()} className="text-gray-400 hover:text-gray-600">
          {isExpanded
            ? <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 15l7-7 7 7"
                />
              </svg>
            : <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7"
                />
              </svg>}
        </button>
        <button onClick={_ => onRemove()} className="text-red-400 hover:text-red-600">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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

    {isExpanded
      ? <div className="space-y-6">
          // Example buttons
          <div className="bg-gray-50 rounded-lg p-4">
            <h4 className="text-sm font-medium text-gray-700 mb-3">
              {"Quick Examples"->React.string}
            </h4>
            <div className="flex flex-wrap gap-2">
              <button
                onClick={_ => setCallExample()}
                className="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-700 text-xs font-medium rounded-md hover:bg-blue-200">
                {"Call traces"->React.string}
              </button>
              <button
                onClick={_ => setCreateExample()}
                className="inline-flex items-center px-3 py-1 bg-green-100 text-green-700 text-xs font-medium rounded-md hover:bg-green-200">
                {"Create traces"->React.string}
              </button>
              <button
                onClick={_ => setSuicideExample()}
                className="inline-flex items-center px-3 py-1 bg-red-100 text-red-700 text-xs font-medium rounded-md hover:bg-red-200">
                {"Suicide traces"->React.string}
              </button>
              <button
                onClick={_ => setRewardExample()}
                className="inline-flex items-center px-3 py-1 bg-yellow-100 text-yellow-700 text-xs font-medium rounded-md hover:bg-yellow-200">
                {"Reward traces"->React.string}
              </button>
            </div>
          </div>

          // From addresses
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"From Addresses"->React.string}
            </label>
            <div className="flex gap-2 mb-2">
              <input
                type_="text"
                value={newFrom}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewFrom(_ => target["value"])
                }}
                placeholder="0x..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button
                onClick={_ => addFrom()}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500">
                {"Add"->React.string}
              </button>
            </div>
            {Array.mapWithIndex(filterState.from_->Option.getOr([]), (address, index) =>
              <div
                key={address}
                className="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 mb-1">
                <span className="text-sm text-gray-700 font-mono"> {address->React.string} </span>
                <button
                  onClick={_ => removeFrom(index)} className="text-red-400 hover:text-red-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            )->React.array}
          </div>

          // To addresses
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"To Addresses"->React.string}
            </label>
            <div className="flex gap-2 mb-2">
              <input
                type_="text"
                value={newTo}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewTo(_ => target["value"])
                }}
                placeholder="0x..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button
                onClick={_ => addTo()}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500">
                {"Add"->React.string}
              </button>
            </div>
            {Array.mapWithIndex(filterState.to_->Option.getOr([]), (address, index) =>
              <div
                key={address}
                className="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 mb-1">
                <span className="text-sm text-gray-700 font-mono"> {address->React.string} </span>
                <button onClick={_ => removeTo(index)} className="text-red-400 hover:text-red-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            )->React.array}
          </div>

          // Addresses
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Addresses"->React.string}
            </label>
            <div className="flex gap-2 mb-2">
              <input
                type_="text"
                value={newAddress}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewAddress(_ => target["value"])
                }}
                placeholder="0x..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button
                onClick={_ => addAddress()}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500">
                {"Add"->React.string}
              </button>
            </div>
            {Array.mapWithIndex(filterState.address->Option.getOr([]), (address, index) =>
              <div
                key={address}
                className="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 mb-1">
                <span className="text-sm text-gray-700 font-mono"> {address->React.string} </span>
                <button
                  onClick={_ => removeAddress(index)} className="text-red-400 hover:text-red-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            )->React.array}
          </div>

          // Call types
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Call Types"->React.string}
            </label>
            <div className="flex gap-2 mb-2">
              <input
                type_="text"
                value={newCallType}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewCallType(_ => target["value"])
                }}
                placeholder="call, create, suicide..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button
                onClick={_ => addCallType()}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500">
                {"Add"->React.string}
              </button>
            </div>
            {Array.mapWithIndex(filterState.callType->Option.getOr([]), (callType, index) =>
              <div
                key={callType}
                className="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 mb-1">
                <span className="text-sm text-gray-700"> {callType->React.string} </span>
                <button
                  onClick={_ => removeCallType(index)} className="text-red-400 hover:text-red-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            )->React.array}
          </div>

          // Reward types
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Reward Types"->React.string}
            </label>
            <div className="flex gap-2 mb-2">
              <input
                type_="text"
                value={newRewardType}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewRewardType(_ => target["value"])
                }}
                placeholder="block, uncle..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button
                onClick={_ => addRewardType()}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500">
                {"Add"->React.string}
              </button>
            </div>
            {Array.mapWithIndex(filterState.rewardType->Option.getOr([]), (rewardType, index) =>
              <div
                key={rewardType}
                className="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 mb-1">
                <span className="text-sm text-gray-700"> {rewardType->React.string} </span>
                <button
                  onClick={_ => removeRewardType(index)}
                  className="text-red-400 hover:text-red-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            )->React.array}
          </div>

          // Kinds
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Kinds"->React.string}
            </label>
            <div className="flex gap-2 mb-2">
              <input
                type_="text"
                value={newKind}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewKind(_ => target["value"])
                }}
                placeholder="call, create, suicide, reward..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button
                onClick={_ => addKind()}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500">
                {"Add"->React.string}
              </button>
            </div>
            {Array.mapWithIndex(filterState.kind->Option.getOr([]), (kind, index) =>
              <div
                key={kind}
                className="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 mb-1">
                <span className="text-sm text-gray-700"> {kind->React.string} </span>
                <button
                  onClick={_ => removeKind(index)} className="text-red-400 hover:text-red-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            )->React.array}
          </div>

          // Sighash
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Function Signatures"->React.string}
            </label>
            <div className="flex gap-2 mb-2">
              <input
                type_="text"
                value={newSighash}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewSighash(_ => target["value"])
                }}
                placeholder="0x..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent"
              />
              <button
                onClick={_ => addSighash()}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500">
                {"Add"->React.string}
              </button>
            </div>
            {Array.mapWithIndex(filterState.sighash->Option.getOr([]), (sighash, index) =>
              <div
                key={sighash}
                className="flex items-center justify-between bg-gray-50 rounded-md px-3 py-2 mb-1">
                <span className="text-sm text-gray-700 font-mono"> {sighash->React.string} </span>
                <button
                  onClick={_ => removeSighash(index)} className="text-red-400 hover:text-red-600">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </div>
            )->React.array}
          </div>
        </div>
      : React.null}
  </div>
}
