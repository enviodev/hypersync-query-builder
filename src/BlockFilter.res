open QueryStructure

type blockFilterState = QueryStructure.blockSelection

@react.component
let make = (~filterState: blockFilterState, ~onFilterChange, ~onRemove, ~filterIndex) => {
  let (isExpanded, setIsExpanded) = React.useState(() => true) // Start expanded for new filters
  let (newHash, setNewHash) = React.useState(() => "")
  let (newMiner, setNewMiner) = React.useState(() => "")

  let titanBuilderExample: blockFilterState = {
    hash: None,
    miner: Some(["0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97"]),
  }

  let setTitanBuilderExample = () => {
    onFilterChange(titanBuilderExample)
  }

  let addHash = () => {
    if newHash !== "" && newHash->String.startsWith("0x") {
      onFilterChange({
        ...filterState,
        hash: Some(Array.concat(filterState.hash->Option.getOr([]), [newHash])),
      })
      setNewHash(_ => "")
    }
  }

  let removeHash = index => {
    let currentArray = filterState.hash->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      hash: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let addMiner = () => {
    if newMiner !== "" && newMiner->String.startsWith("0x") {
      onFilterChange({
        ...filterState,
        miner: Some(Array.concat(filterState.miner->Option.getOr([]), [newMiner])),
      })
      setNewMiner(_ => "")
    }
  }

  let removeMiner = index => {
    let currentArray = filterState.miner->Option.getOr([])
    let newArray = Belt.Array.keepWithIndex(currentArray, (_, i) => i !== index)
    onFilterChange({
      ...filterState,
      miner: Array.length(newArray) > 0 ? Some(newArray) : None,
    })
  }

  let _blockSelectionToStruct = (): option<blockSelection> => {
    Some(filterState)
  }

  let generateEnglishDescription = () => {
    BlockBooleanLogicGenerator.generateEnglishDescription((filterState :> BlockBooleanLogicGenerator.blockFilterState))
  }

  let generateBooleanHierarchy = () => {
    BlockBooleanLogicGenerator.generateBooleanHierarchy((filterState :> BlockBooleanLogicGenerator.blockFilterState))
  }

  let generateCodeBlock = () => {
    let {hash, miner} = filterState

    let hashStr = switch hash {
    | Some(hashArray) when Array.length(hashArray) > 0 => {
        let hashList = Array.join(hashArray->Array.map(h => `    "${h}"`), ",\n")
        `  "hash": [\n${hashList}\n  ]`
      }
    | _ => ""
    }

    let minerStr = switch miner {
    | Some(minerArray) when Array.length(minerArray) > 0 => {
        let minerList = Array.join(minerArray->Array.map(m => `    "${m}"`), ",\n")
        `  "miner": [\n${minerList}\n  ]`
      }
    | _ => ""
    }

    let parts = [hashStr, minerStr]->Array.filter(str => str !== "")
    if Array.length(parts) > 0 {
      `{\n${Array.join(parts, ",\n")}\n}`
    } else {
      "{}"
    }
  }

  let hasFilters = Array.length(filterState.hash->Option.getOr([])) > 0 || Array.length(filterState.miner->Option.getOr([])) > 0

  <div className="bg-white rounded-lg shadow">
    <div className="p-4 border-b border-gray-200">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-gray-900">
            {`Block Filter ${Int.toString(filterIndex + 1)}`->React.string}
          </h3>
          {hasFilters
            ? <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                {"Active"->React.string}
              </span>
            : React.null}
        </div>
        <div className="flex items-center space-x-2">
          <button
            onClick={_ => setIsExpanded(prev => !prev)}
            className="inline-flex items-center p-2 text-sm font-medium text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
            <svg 
              className={`w-4 h-4 transform transition-transform ${isExpanded ? "rotate-180" : "rotate-0"}`}
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          <button
            onClick={_ => onRemove()}
            className="inline-flex items-center p-2 text-sm font-medium text-red-500 hover:text-red-700 hover:bg-red-100 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500">
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </button>
        </div>
      </div>
    </div>
    
    {isExpanded
      ? <div className="p-6">
          <div className="mb-4">
            <button
              onClick={_ => setTitanBuilderExample()}
              className="px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500">
              {"Titan Builder Blocks"->React.string}
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
                {(Array.length(filterState.hash->Option.getOr([])) > 0 ? "Add (via OR) Hash" : "Add Hash")->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.hash->Option.getOr([]), (hash, index) =>
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
                {(Array.length(filterState.miner->Option.getOr([])) > 0 ? "Add (via OR) Miner" : "Add Miner")->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.miner->Option.getOr([]), (miner, index) =>
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
      : React.null}
  </div>
} 
