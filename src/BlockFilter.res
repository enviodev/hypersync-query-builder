open QueryStructure

type blockFilterState = {
  hash: array<string>,
  miner: array<string>,
}

@react.component
let make = () => {
  let (filterState, setFilterState) = React.useState(() => {
    hash: [],
    miner: [],
  })

  let (newHash, setNewHash) = React.useState(() => "")
  let (newMiner, setNewMiner) = React.useState(() => "")

  let exampleSetFilterState = {
    hash: ["0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"],
    miner: ["0xminer1234567890123456789012345678901234567890"],
  }

  let setExampleFilterState = () => {
    setFilterState(_ => exampleSetFilterState)
  }

  let addHash = () => {
    if newHash !== "" && newHash->String.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        hash: Array.concat(prevState.hash, [newHash]),
      })
      setNewHash(_ => "")
    }
  }

  let removeHash = index => {
    setFilterState(prevState => {
      ...prevState,
      hash: Array.keepWithIndex(prevState.hash, (_, i) => i !== index),
    })
  }

  let addMiner = () => {
    if newMiner !== "" && newMiner->String.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        miner: Array.concat(prevState.miner, [newMiner]),
      })
      setNewMiner(_ => "")
    }
  }

  let removeMiner = index => {
    setFilterState(prevState => {
      ...prevState,
      miner: Array.keepWithIndex(prevState.miner, (_, i) => i !== index),
    })
  }

  let blockSelectionToStruct = (): option<blockSelection> => {
    let result: blockSelection = {
      hash: if Array.length(filterState.hash) > 0 {
        Some(filterState.hash)
      } else {
        None
      },
      miner: if Array.length(filterState.miner) > 0 {
        Some(filterState.miner)
      } else {
        None
      },
    }
    Some(result)
  }

  let generateEnglishDescription = () => {
    BlockBooleanLogicGenerator.generateEnglishDescription(filterState)
  }

  let generateBooleanHierarchy = () => {
    BlockBooleanLogicGenerator.generateBooleanHierarchy(filterState)
  }

  let generateCodeBlock = () => {
    let {hash, miner} = filterState

    let hashStr = if Array.length(hash) > 0 {
      let hashList = hash
        ->Array.map(h => `    "${h}"`)
        ->Array.join(",\n")
      `  "hash": [\n${hashList}\n  ]`
    } else {
      ""
    }

    let minerStr = if Array.length(miner) > 0 {
      let minerList = miner
        ->Array.map(m => `    "${m}"`)
        ->Array.join(",\n")
      `  "miner": [\n${minerList}\n  ]`
    } else {
      ""
    }

    let parts = [hashStr, minerStr]->Array.keep(str => str !== "")
    if Array.length(parts) > 0 {
      `{\n${parts->Array.join(",\n")}\n}`
    } else {
      "{}"
    }
  }

  <div className="bg-white rounded-lg shadow p-6">
    <h3 className="text-lg font-medium text-gray-900 mb-4"> {"Block Filters"->React.string} </h3>
    <div className="mb-4">
      <button
        onClick={_ => setExampleFilterState()}
        className="px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500">
        {"Set Example Filter State"->React.string}
      </button>
    </div>

    // Block Hashes
    <div className="mb-6">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {"Block Hashes"->React.string}
      </label>
      <div className="flex space-x-2 mb-3">
        <input
          type_="text"
          value={newHash}
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            setNewHash(_ => target["value"])
          }}
          placeholder="0x..."
          className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <button
          onClick={_ => addHash()}
          disabled={String.length(newHash) == 0 || !(newHash->String.startsWith("0x"))}
          className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed">
          {(Array.length(filterState.hash) > 0 ? "Add (via OR) Hash" : "Add Hash")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Array.mapWithIndex(filterState.hash, (index, hash) =>
          <div
            key={Int.toString(index)}
            className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
            <span className="text-sm font-mono text-gray-800"> {hash->React.string} </span>
            <button
              onClick={_ => removeHash(index)}
              className="text-red-600 hover:text-red-800 text-sm">
              {"Remove"->React.string}
            </button>
          </div>
        )->React.array}
      </div>
    </div>

    // Miner Addresses
    <div className="mb-6">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {"Miner Addresses"->React.string}
      </label>
      <div className="flex space-x-2 mb-3">
        <input
          type_="text"
          value={newMiner}
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            setNewMiner(_ => target["value"])
          }}
          placeholder="0x..."
          className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <button
          onClick={_ => addMiner()}
          disabled={String.length(newMiner) == 0 || !(newMiner->String.startsWith("0x"))}
          className="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed">
          {(Array.length(filterState.miner) > 0 ? "Add (via OR) Miner" : "Add Miner")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Array.mapWithIndex(filterState.miner, (index, miner) =>
          <div
            key={Int.toString(index)}
            className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
            <span className="text-sm font-mono text-gray-800"> {miner->React.string} </span>
            <button
              onClick={_ => removeMiner(index)}
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
