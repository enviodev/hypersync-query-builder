open QueryStructure

type transactionFilterState = {
  from_: array<string>,
  to_: array<string>,
  sighash: array<string>,
  status: option<int>,
  kind: array<int>,
  contractAddress: array<string>,
}

@react.component
let make = () => {
  let (filterState, setFilterState) = React.useState(() => {
    from_: [],
    to_: [],
    sighash: [],
    status: None,
    kind: [],
    contractAddress: [],
  })

  let (newFrom, setNewFrom) = React.useState(() => "")
  let (newTo, setNewTo) = React.useState(() => "")
  let (newSighash, setNewSighash) = React.useState(() => "")
  let (newStatus, setNewStatus) = React.useState(() => "")
  let (newKind, setNewKind) = React.useState(() => "")
  let (newContractAddress, setNewContractAddress) = React.useState(() => "")

  let exampleSetFilterState = {
    from_: ["0x1234567890123456789012345678901234567890"],
    to_: ["0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef"],
    sighash: ["0xa9059cbb", "0x23b872dd"],
    status: Some(1),
    kind: [0, 1],
    contractAddress: ["0xcontract123456789012345678901234567890"],
  }

  let setExampleFilterState = () => {
    setFilterState(_ => exampleSetFilterState)
  }

  let addFrom = () => {
    if newFrom !== "" && newFrom->String.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        from_: Array.concat(prevState.from_, [newFrom]),
      })
      setNewFrom(_ => "")
    }
  }

  let removeFrom = index => {
    setFilterState(prevState => {
      ...prevState,
      from_: Array.keepWithIndex(prevState.from_, (_, i) => i !== index),
    })
  }

  let addTo = () => {
    if newTo !== "" && newTo->String.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        to_: Array.concat(prevState.to_, [newTo]),
      })
      setNewTo(_ => "")
    }
  }

  let removeTo = index => {
    setFilterState(prevState => {
      ...prevState,
      to_: Array.keepWithIndex(prevState.to_, (_, i) => i !== index),
    })
  }

  let addSighash = () => {
    if newSighash !== "" && newSighash->String.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        sighash: Array.concat(prevState.sighash, [newSighash]),
      })
      setNewSighash(_ => "")
    }
  }

  let removeSighash = index => {
    setFilterState(prevState => {
      ...prevState,
      sighash: Array.keepWithIndex(prevState.sighash, (_, i) => i !== index),
    })
  }

  let setStatus = () => {
    switch Int.fromString(newStatus) {
    | Some(status) => 
      setFilterState(prevState => {...prevState, status: Some(status)})
      setNewStatus(_ => "")
    | None => ()
    }
  }

  let clearStatus = () => {
    setFilterState(prevState => {...prevState, status: None})
  }

  let addKind = () => {
    switch Int.fromString(newKind) {
    | Some(kind) => 
      setFilterState(prevState => {
        ...prevState,
        kind: Array.concat(prevState.kind, [kind]),
      })
      setNewKind(_ => "")
    | None => ()
    }
  }

  let removeKind = index => {
    setFilterState(prevState => {
      ...prevState,
      kind: Array.keepWithIndex(prevState.kind, (_, i) => i !== index),
    })
  }

  let addContractAddress = () => {
    if newContractAddress !== "" && newContractAddress->String.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        contractAddress: Array.concat(prevState.contractAddress, [newContractAddress]),
      })
      setNewContractAddress(_ => "")
    }
  }

  let removeContractAddress = index => {
    setFilterState(prevState => {
      ...prevState,
      contractAddress: Array.keepWithIndex(prevState.contractAddress, (_, i) => i !== index),
    })
  }

  let transactionSelectionToStruct = (): option<transactionSelection> => {
    let result: transactionSelection = {
      from_: if Array.length(filterState.from_) > 0 {
        Some(filterState.from_)
      } else {
        None
      },
      to_: if Array.length(filterState.to_) > 0 {
        Some(filterState.to_)
      } else {
        None
      },
      sighash: if Array.length(filterState.sighash) > 0 {
        Some(filterState.sighash)
      } else {
        None
      },
      status: filterState.status,
      kind: if Array.length(filterState.kind) > 0 {
        Some(filterState.kind)
      } else {
        None
      },
      contractAddress: if Array.length(filterState.contractAddress) > 0 {
        Some(filterState.contractAddress)
      } else {
        None
      },
      authorizationList: None, // TODO: Handle authorization list separately
    }
    Some(result)
  }

  let generateEnglishDescription = () => {
    TransactionBooleanLogicGenerator.generateEnglishDescription(filterState)
  }

  let generateBooleanHierarchy = () => {
    TransactionBooleanLogicGenerator.generateBooleanHierarchy(filterState)
  }

  let generateCodeBlock = () => {
    let {from_, to_, sighash, status, kind, contractAddress} = filterState

    let fromStr = if Array.length(from_) > 0 {
      let fromList = from_
        ->Array.map(addr => `    "${addr}"`)
        ->Array.join(",\n")
      `  "from": [\n${fromList}\n  ]`
    } else {
      ""
    }

    let toStr = if Array.length(to_) > 0 {
      let toList = to_
        ->Array.map(addr => `    "${addr}"`)
        ->Array.join(",\n")
      `  "to": [\n${toList}\n  ]`
    } else {
      ""
    }

    let sighashStr = if Array.length(sighash) > 0 {
      let sighashList = sighash
        ->Array.map(sig => `    "${sig}"`)
        ->Array.join(",\n")
      `  "sighash": [\n${sighashList}\n  ]`
    } else {
      ""
    }

    let statusStr = switch status {
    | Some(s) => `  "status": ${Int.toString(s)}`
    | None => ""
    }

    let kindStr = if Array.length(kind) > 0 {
      let kindList = kind
        ->Array.map(k => `    ${Int.toString(k)}`)
        ->Array.join(",\n")
      `  "kind": [\n${kindList}\n  ]`
    } else {
      ""
    }

    let contractAddressStr = if Array.length(contractAddress) > 0 {
      let contractList = contractAddress
        ->Array.map(addr => `    "${addr}"`)
        ->Array.join(",\n")
      `  "contractAddress": [\n${contractList}\n  ]`
    } else {
      ""
    }

    let parts = [fromStr, toStr, sighashStr, statusStr, kindStr, contractAddressStr]->Array.keep(str => str !== "")
    if Array.length(parts) > 0 {
      `{\n${parts->Array.join(",\n")}\n}`
    } else {
      "{}"
    }
  }

  <div className="bg-white rounded-lg shadow p-6">
    <h3 className="text-lg font-medium text-gray-900 mb-4"> {"Transaction Filters"->React.string} </h3>
    <div className="mb-4">
      <button
        onClick={_ => setExampleFilterState()}
        className="px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500">
        {"Set Example Filter State"->React.string}
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
          {(Array.length(filterState.from_) > 0 ? "Add (via OR) From" : "Add From")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Array.mapWithIndex(filterState.from_, (index, address) =>
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
          {(Array.length(filterState.to_) > 0 ? "Add (via OR) To" : "Add To")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Array.mapWithIndex(filterState.to_, (index, address) =>
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
          {(Array.length(filterState.sighash) > 0 ? "Add (via OR) Sighash" : "Add Sighash")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Array.mapWithIndex(filterState.sighash, (index, sighash) =>
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
            {`Status: ${Int.toString(status)} (${status === 1 ? "Success" : "Failed"})`->React.string} 
          </span>
          <button
            onClick={_ => clearStatus()}
            className="text-red-600 hover:text-red-800 text-sm">
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
          {(Array.length(filterState.kind) > 0 ? "Add (via OR) Kind" : "Add Kind")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Array.mapWithIndex(filterState.kind, (index, kind) =>
          <div
            key={Int.toString(index)}
            className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
            <span className="text-sm font-mono text-gray-800"> {Int.toString(kind)->React.string} </span>
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
          disabled={String.length(newContractAddress) == 0 || !(newContractAddress->String.startsWith("0x"))}
          className="px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500 disabled:opacity-50 disabled:cursor-not-allowed">
          {(Array.length(filterState.contractAddress) > 0 ? "Add (via OR) Contract" : "Add Contract")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Array.mapWithIndex(filterState.contractAddress, (index, address) =>
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
        <p className="text-sm text-blue-800"> {generateEnglishDescription()->React.string} </p>
      </div>
      
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {"Boolean Logic Hierarchy"->React.string}
      </label>
      <pre className="bg-gray-50 border border-gray-200 rounded-md p-4 text-sm font-mono mb-4 whitespace-pre overflow-x-auto">
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
} 
