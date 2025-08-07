open QueryStructure

type transactionFilterState = QueryStructure.transactionSelection

@react.component
let make = (
  ~filterState: transactionFilterState,
  ~onFilterChange,
  ~onRemove,
  ~filterIndex,
  ~isExpanded: bool,
  ~onToggleExpand,
) => {
  let (newFrom, setNewFrom) = React.useState(() => "")
  let (newTo, setNewTo) = React.useState(() => "")
  let (newSighash, setNewSighash) = React.useState(() => "")
  let (newStatus, setNewStatus) = React.useState(() => "")
  let (newKind, setNewKind) = React.useState(() => "")
  let (newContractAddress, setNewContractAddress) = React.useState(() => "")

  // Example filter states
  let eip7702Example: transactionFilterState = {
    from_: None,
    to_: None,
    sighash: None,
    status: None,
    kind: Some([4]),
    contractAddress: None,
    authorizationList: None,
  }

  let failedTransactionsExample: transactionFilterState = {
    from_: None,
    to_: None,
    sighash: None,
    status: Some(0),
    kind: None,
    contractAddress: None,
    authorizationList: None,
  }

  let transferCallExample: transactionFilterState = {
    from_: None,
    to_: None,
    sighash: Some(["0xa9059cbb"]),
    status: None,
    kind: None,
    contractAddress: None,
    authorizationList: None,
  }

  let approveCallExample: transactionFilterState = {
    from_: None,
    to_: None,
    sighash: Some(["0x095ea7b3"]),
    status: None,
    kind: None,
    contractAddress: None,
    authorizationList: None,
  }

  let setEip7702Example = () => {
    onFilterChange(eip7702Example)
  }

  let setFailedTransactionsExample = () => {
    onFilterChange(failedTransactionsExample)
  }

  let setTransferCallExample = () => {
    onFilterChange(transferCallExample)
  }

  let setApproveCallExample = () => {
    onFilterChange(approveCallExample)
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

  let setStatus = () => {
    switch Int.fromString(newStatus) {
    | Some(status) =>
      onFilterChange({...filterState, status: Some(status)})
      setNewStatus(_ => "")
    | None => ()
    }
  }

  let clearStatus = () => {
    onFilterChange({...filterState, status: None})
  }

  let addKind = () => {
    switch Int.fromString(newKind) {
    | Some(kind) =>
      onFilterChange({
        ...filterState,
        kind: Some(Array.concat(filterState.kind->Option.getOr([]), [kind])),
      })
      setNewKind(_ => "")
    | None => ()
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

  let addContractAddress = () => {
    if newContractAddress !== "" && newContractAddress->String.startsWith("0x") {
      onFilterChange({
        ...filterState,
        contractAddress: Some(
          Array.concat(filterState.contractAddress->Option.getOr([]), [newContractAddress]),
        ),
      })
      setNewContractAddress(_ => "")
    }
  }

  let removeContractAddress = index => {
    let currentArray = filterState.contractAddress->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      contractAddress: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let _transactionSelectionToStruct = (): option<transactionSelection> => {
    Some(filterState)
  }

  let generateEnglishDescription = () => {
    TransactionBooleanLogicGenerator.generateEnglishDescription(
      (filterState :> TransactionBooleanLogicGenerator.transactionFilterState),
    )
  }

  let generateBooleanHierarchy = () => {
    TransactionBooleanLogicGenerator.generateBooleanHierarchy(
      (filterState :> TransactionBooleanLogicGenerator.transactionFilterState),
    )
  }

  let generateCodeBlock = () => {
    let {from_, to_, sighash, status, kind, contractAddress} = filterState

    let fromStr = switch from_ {
    | Some(fromArray) if Array.length(fromArray) > 0 => {
        let fromList =
          fromArray
          ->Array.map(addr => `    "${addr}"`)
          ->Array.join(",\n")
        `  "from": [\n${fromList}\n  ]`
      }
    | _ => ""
    }

    let toStr = switch to_ {
    | Some(toArray) if Array.length(toArray) > 0 => {
        let toList =
          toArray
          ->Array.map(addr => `    "${addr}"`)
          ->Array.join(",\n")
        `  "to": [\n${toList}\n  ]`
      }
    | _ => ""
    }

    let sighashStr = switch sighash {
    | Some(sighashArray) if Array.length(sighashArray) > 0 => {
        let sighashList =
          sighashArray
          ->Array.map(sig => `    "${sig}"`)
          ->Array.join(",\n")
        `  "sighash": [\n${sighashList}\n  ]`
      }
    | _ => ""
    }

    let statusStr = switch status {
    | Some(s) => `  "status": ${Int.toString(s)}`
    | None => ""
    }

    let kindStr = switch kind {
    | Some(kindArray) if Array.length(kindArray) > 0 => {
        let kindList =
          kindArray
          ->Array.map(k => `    ${Int.toString(k)}`)
          ->Array.join(",\n")
        `  "kind": [\n${kindList}\n  ]`
      }
    | _ => ""
    }

    let contractAddressStr = switch contractAddress {
    | Some(contractArray) if Array.length(contractArray) > 0 => {
        let contractList =
          contractArray
          ->Array.map(addr => `    "${addr}"`)
          ->Array.join(",\n")
        `  "contractAddress": [\n${contractList}\n  ]`
      }
    | _ => ""
    }

    let parts =
      [fromStr, toStr, sighashStr, statusStr, kindStr, contractAddressStr]->Array.filterMap(str =>
        str !== "" ? Some(str) : None
      )
    if Array.length(parts) > 0 {
      `{\n${Array.join(parts, ",\n")}\n}`
    } else {
      "{}"
    }
  }

  let hasFilters =
    Array.length(filterState.from_->Option.getOr([])) > 0 ||
    Array.length(filterState.to_->Option.getOr([])) > 0 ||
    Array.length(filterState.sighash->Option.getOr([])) > 0 ||
    Option.isSome(filterState.status) ||
    Array.length(filterState.kind->Option.getOr([])) > 0 ||
    Array.length(filterState.contractAddress->Option.getOr([])) > 0

  <div
    className={`bg-white rounded-xl border border-slate-200 shadow-sm transition-all ${isExpanded
        ? "w-full"
        : "w-64"}`}>
    <div className="p-4 border-b border-slate-100">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-slate-900">
            {`Transaction Filter ${Int.toString(filterIndex + 1)}`->React.string}
          </h3>
          {hasFilters
            ? <span
                className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">
                {"Active"->React.string}
              </span>
            : React.null}
        </div>
        <div className="flex items-center space-x-1">
          <button
            onClick={_ => onToggleExpand()}
            className="inline-flex items-center p-2 text-sm font-medium text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded-lg focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
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
            className="inline-flex items-center p-2 text-sm font-medium text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 transition-colors">
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
          <div className="mb-6 flex flex-wrap gap-2">
            <button
              onClick={_ => setEip7702Example()}
              className="px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 transition-colors">
              {"EIP-7702 Transactions"->React.string}
            </button>
            <button
              onClick={_ => setFailedTransactionsExample()}
              className="px-4 py-2 bg-rose-600 text-white text-sm font-medium rounded-lg hover:bg-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500 transition-colors">
              {"Failed Transactions"->React.string}
            </button>
            <button
              onClick={_ => setTransferCallExample()}
              className="px-4 py-2 bg-emerald-600 text-white text-sm font-medium rounded-lg hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-colors">
              {"Transfer EOA Calls"->React.string}
            </button>
            <button
              onClick={_ => setApproveCallExample()}
              className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
              {"Approve EOA Calls"->React.string}
            </button>
          </div>

          // From Addresses
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"From Addresses"->React.string}
            </label>
            <div className="flex space-x-2 mb-3">
              <input
                type_="text"
                value={newFrom}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewFrom(_ => target["value"])
                }}
                placeholder="0x..."
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                onClick={_ => addFrom()}
                disabled={String.length(newFrom) == 0 || !(newFrom->String.startsWith("0x"))}
                className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {(
                  Array.length(filterState.from_->Option.getOr([])) > 0
                    ? "Add (via OR) From"
                    : "Add From"
                )->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.from_->Option.getOr([]), (address, index) =>
                <div
                  key={Int.toString(index)}
                  className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                  <span className="text-sm font-mono text-gray-800"> {address->React.string} </span>
                  <button
                    onClick={_ => removeFrom(index)}
                    className="text-red-600 hover:text-red-800 text-sm">
                    {"Remove"->React.string}
                  </button>
                </div>
              )->React.array}
            </div>
          </div>

          // To Addresses
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"To Addresses"->React.string}
            </label>
            <div className="flex space-x-2 mb-3">
              <input
                type_="text"
                value={newTo}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewTo(_ => target["value"])
                }}
                placeholder="0x..."
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                onClick={_ => addTo()}
                disabled={String.length(newTo) == 0 || !(newTo->String.startsWith("0x"))}
                className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {(
                  Array.length(filterState.to_->Option.getOr([])) > 0 ? "Add (via OR) To" : "Add To"
                )->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.to_->Option.getOr([]), (address, index) =>
                <div
                  key={Int.toString(index)}
                  className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                  <span className="text-sm font-mono text-gray-800"> {address->React.string} </span>
                  <button
                    onClick={_ => removeTo(index)}
                    className="text-red-600 hover:text-red-800 text-sm">
                    {"Remove"->React.string}
                  </button>
                </div>
              )->React.array}
            </div>
          </div>

          // Sighash
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Function Signatures (Sighash)"->React.string}
            </label>
            <div className="flex space-x-2 mb-3">
              <input
                type_="text"
                value={newSighash}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewSighash(_ => target["value"])
                }}
                placeholder="0xa9059cbb"
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                onClick={_ => addSighash()}
                disabled={String.length(newSighash) == 0 || !(newSighash->String.startsWith("0x"))}
                className="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {(
                  Array.length(filterState.sighash->Option.getOr([])) > 0
                    ? "Add (via OR) Sighash"
                    : "Add Sighash"
                )->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.sighash->Option.getOr([]), (sighash, index) =>
                <div
                  key={Int.toString(index)}
                  className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                  <span className="text-sm font-mono text-gray-800"> {sighash->React.string} </span>
                  <button
                    onClick={_ => removeSighash(index)}
                    className="text-red-600 hover:text-red-800 text-sm">
                    {"Remove"->React.string}
                  </button>
                </div>
              )->React.array}
            </div>
          </div>

          // Status
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Transaction Status"->React.string}
            </label>
            <div className="flex space-x-2 mb-3">
              <input
                type_="number"
                value={newStatus}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewStatus(_ => target["value"])
                }}
                placeholder="0 (failed) or 1 (success)"
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                onClick={_ => setStatus()}
                disabled={String.length(newStatus) == 0}
                className="px-4 py-2 bg-orange-600 text-white text-sm font-medium rounded-md hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {"Set Status"->React.string}
              </button>
            </div>
            {switch filterState.status {
            | Some(status) =>
              <div className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                <span className="text-sm font-mono text-gray-800">
                  {`Status: ${Int.toString(status)} (${status === 1
                      ? "Success"
                      : "Failed"})`->React.string}
                </span>
                <button
                  onClick={_ => clearStatus()} className="text-red-600 hover:text-red-800 text-sm">
                  {"Clear"->React.string}
                </button>
              </div>
            | None => React.null
            }}
          </div>

          // Kind
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Transaction Kind"->React.string}
            </label>
            <div className="flex space-x-2 mb-3">
              <input
                type_="number"
                value={newKind}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewKind(_ => target["value"])
                }}
                placeholder="0, 1, 2..."
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                onClick={_ => addKind()}
                disabled={String.length(newKind) == 0}
                className="px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {(
                  Array.length(filterState.kind->Option.getOr([])) > 0
                    ? "Add (via OR) Kind"
                    : "Add Kind"
                )->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.kind->Option.getOr([]), (kind, index) =>
                <div
                  key={Int.toString(index)}
                  className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                  <span className="text-sm font-mono text-gray-800">
                    {Int.toString(kind)->React.string}
                  </span>
                  <button
                    onClick={_ => removeKind(index)}
                    className="text-red-600 hover:text-red-800 text-sm">
                    {"Remove"->React.string}
                  </button>
                </div>
              )->React.array}
            </div>
          </div>

          // Contract Address
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Contract Addresses"->React.string}
            </label>
            <div className="flex space-x-2 mb-3">
              <input
                type_="text"
                value={newContractAddress}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setNewContractAddress(_ => target["value"])
                }}
                placeholder="0x..."
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
              <button
                onClick={_ => addContractAddress()}
                disabled={String.length(newContractAddress) == 0 ||
                  !(newContractAddress->String.startsWith("0x"))}
                className="px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {(
                  Array.length(filterState.contractAddress->Option.getOr([])) > 0
                    ? "Add (via OR) Contract"
                    : "Add Contract"
                )->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.contractAddress->Option.getOr([]), (address, index) =>
                <div
                  key={Int.toString(index)}
                  className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                  <span className="text-sm font-mono text-gray-800"> {address->React.string} </span>
                  <button
                    onClick={_ => removeContractAddress(index)}
                    className="text-red-600 hover:text-red-800 text-sm">
                    {"Remove"->React.string}
                  </button>
                </div>
              )->React.array}
            </div>
          </div>

          // English Description and Boolean Logic
          <div className="mt-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"English Description"->React.string}
            </label>
            <div className="bg-blue-50 border border-blue-200 rounded-md p-4 mb-4">
              <p className="text-sm text-blue-800">
                {generateEnglishDescription()->React.string}
              </p>
            </div>

            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Boolean Logic Hierarchy"->React.string}
            </label>
            <pre
              className="bg-gray-50 border border-gray-200 rounded-md p-4 text-sm font-mono mb-4 whitespace-pre overflow-x-auto">
              {generateBooleanHierarchy()->React.string}
            </pre>

            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Generated Query Structure"->React.string}
            </label>
            <pre
              className="bg-gray-100 border border-gray-300 rounded-md p-4 text-sm font-mono overflow-x-auto">
              {generateCodeBlock()->React.string}
            </pre>
          </div>
        </div>
      : React.null}
  </div>
}
