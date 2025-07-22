open QueryStructure

type filterState = {
  addresses: array<string>,
  topics: array<array<string>>,
}

@react.component
let make = () => {
  let (filterState, setFilterState) = React.useState(() => {
    addresses: [],
    topics: [],
  })

  let (newAddress, setNewAddress) = React.useState(() => "")
  let (newTopic, setNewTopic) = React.useState(() => "")
  let (currentTopicIndex, setCurrentTopicIndex) = React.useState(() => 0)

  let exampleSetFilterState = {
    addresses: ["0x1234567890123456789012345678901234567890"],
    topics: [["0x1", "0x2", "0x3"], [], ["0x4"]],
  }

  let setExampleFilterState = () => {
    setFilterState(_ => exampleSetFilterState)
  }

  let addAddress = () => {
    if newAddress !== "" && newAddress->Js.String2.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        addresses: Belt.Array.concat(prevState.addresses, [newAddress]),
      })
      setNewAddress(_ => "")
    }
  }

  let removeAddress = index => {
    setFilterState(prevState => {
      ...prevState,
      addresses: Belt.Array.keepWithIndex(prevState.addresses, (_, i) => i !== index),
    })
  }

  let addTopic = () => {
    if newTopic !== "" && newTopic->Js.String2.startsWith("0x") {
      setFilterState(prevState => {
        let currentIndex: int = currentTopicIndex
        // Ensure topics array is long enough to accommodate the current index
        let requiredLength = max(Belt.Array.length(prevState.topics), currentIndex + 1)
        let paddedTopics = Belt.Array.makeBy(requiredLength, i => {
          if i < Belt.Array.length(prevState.topics) {
            Belt.Array.getUnsafe(prevState.topics, i)
          } else {
            []
          }
        })
        
        // Add the new topic to the correct index
        let updatedTopics = Belt.Array.mapWithIndex(paddedTopics, (i, topicArray) =>
          if i === currentIndex {
            Belt.Array.concat(topicArray, [newTopic])
          } else {
            topicArray
          }
        )

        {
          ...prevState,
          topics: updatedTopics,
        }
      })
      setNewTopic(_ => "")
    }
  }

  let removeTopic = (topicIndex: int, itemIndex: int) => {
    setFilterState(prevState => {
      let updatedTopics = Belt.Array.mapWithIndex(
        prevState.topics,
        (i, topicArray) =>
          if i === topicIndex {
            Belt.Array.keepWithIndex(topicArray, (_, j) => j !== itemIndex)
          } else {
            topicArray
          },
      )

      {...prevState, topics: updatedTopics}
    })
  }

  let logSelectionToStruct = (): option<logSelection> => {
    let result: logSelection = {
      address: if Belt.Array.length(filterState.addresses) > 0 {
        Some(filterState.addresses)
      } else {
        None
      },
      topics: if Belt.Array.length(filterState.topics) > 0 {
        Some(filterState.topics)
      } else {
        None
      },
    }
    Some(result)
  }

  let generateEnglishDescription = () => {
    BooleanLogicGenerator.generateEnglishDescription({
      addresses: filterState.addresses,
      topics: filterState.topics,
    })
  }

  let generateBooleanHierarchy = () => {
    BooleanLogicGenerator.generateBooleanHierarchy({
      addresses: filterState.addresses,
      topics: filterState.topics,
    })
  }

  let generateCodeBlock = () => {
    let {addresses, topics} = filterState

    let addressStr = if Belt.Array.length(addresses) > 0 {
      let addressList = addresses
        ->Belt.Array.map(addr => `    "${addr}"`)
        ->Js.Array2.joinWith(",\n")
      `  "address": [\n${addressList}\n  ]`
    } else {
      ""
    }

    let topicsStr = if Belt.Array.length(topics) > 0 {
      let topicsContent =
        topics
        ->Belt.Array.map(topicArray => {
          if Belt.Array.length(topicArray) === 0 {
            "    []"
          } else {
            let topicList = topicArray
              ->Belt.Array.map(topic => `      "${topic}"`)
              ->Js.Array2.joinWith(",\n")
            `    [\n${topicList}\n    ]`
          }
        })
        ->Js.Array2.joinWith(",\n")
      `  "topics": [\n${topicsContent}\n  ]`
    } else {
      ""
    }

    let parts = [addressStr, topicsStr]->Belt.Array.keep(str => str !== "")
    if Belt.Array.length(parts) > 0 {
      `{\n${parts->Js.Array2.joinWith(",\n")}\n}`
    } else {
      "{}"
    }
  }

  <div className="bg-white rounded-lg shadow p-6">
    <h3 className="text-lg font-medium text-gray-900 mb-4"> {"Log Filters"->React.string} </h3>
    <div className="mb-4">
      <button
        onClick={_ => setExampleFilterState()}
        className="px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500">
        {"Set Example Filter State"->React.string}
      </button>
    </div>
    // Address Filters
    <div className="mb-6">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {"Contract Addresses"->React.string}
      </label>
      <div className="flex space-x-2 mb-3">
        <input
          type_="text"
          value={newAddress}
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            setNewAddress(_ => target["value"])
          }}
          placeholder="0x..."
          className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <button
          onClick={_ => addAddress()}
          disabled={Js.String.length(newAddress) == 0 || !(newAddress->Js.String2.startsWith("0x"))}
          className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed">
          {(Belt.Array.length(filterState.addresses) > 0 ? "Add (via OR) Address" : "Add Address")->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {Belt.Array.mapWithIndex(filterState.addresses, (index, address) =>
          <div
            key={Js.Int.toString(index)}
            className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
            <span className="text-sm font-mono text-gray-800"> {address->React.string} </span>
            <button
              onClick={_ => removeAddress(index)}
              className="text-red-600 hover:text-red-800 text-sm">
              {"Remove"->React.string}
            </button>
          </div>
        )->React.array}
      </div>
    </div>
    // Topic Filters
    <div className="mb-6">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {"Event Topics"->React.string}
      </label>
      <div className="flex space-x-2 mb-3">
        <select
          value={Js.Int.toString(currentTopicIndex)}
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            setCurrentTopicIndex(_ =>
              Belt.Int.fromString(target["value"])->Belt.Option.getWithDefault(0)
            )
          }}
          className="border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
          {Belt.Array.mapWithIndex(Belt.Array.range(0, 3), (i, _) =>
            <option key={Js.Int.toString(i)} value={Js.Int.toString(i)}>
              {`Topic ${Js.Int.toString(i)}`->React.string}
            </option>
          )->React.array}
        </select>
        <input
          type_="text"
          value={newTopic}
          onChange={e => {
            let target = ReactEvent.Form.target(e)
            setNewTopic(_ => target["value"])
          }}
          placeholder="0x..."
          className="flex-1 border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <button
          onClick={_ => addTopic()}
          disabled={Js.String.length(newTopic) == 0 || !(newTopic->Js.String2.startsWith("0x"))}
          className="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed">
          {(
            currentTopicIndex < Belt.Array.length(filterState.topics) && 
            Belt.Array.length(Belt.Array.getUnsafe(filterState.topics, currentTopicIndex)) > 0 
              ? "Add (via OR) Topic" 
              : "Add Topic"
          )->React.string}
        </button>
      </div>
      <div className="space-y-3">
        {Belt.Array.mapWithIndex(filterState.topics, (topicIndex, topicArray) =>
          <div key={Js.Int.toString(topicIndex)} className="border border-gray-200 rounded-md p-3">
            <h4 className="text-sm font-medium text-gray-700 mb-2">
              {`Topic ${Js.Int.toString(topicIndex)}`->React.string}
            </h4>
            <div className="space-y-2">
              {Belt.Array.mapWithIndex(topicArray, (itemIndex, topic) =>
                <div
                  key={`${Js.Int.toString(topicIndex)}-${Js.Int.toString(itemIndex)}`}
                  className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                  <span className="text-sm font-mono text-gray-800"> {topic->React.string} </span>
                  <button
                    onClick={_ => removeTopic(topicIndex, itemIndex)}
                    className="text-red-600 hover:text-red-800 text-sm">
                    {"Remove"->React.string}
                  </button>
                </div>
              )->React.array}
            </div>
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
