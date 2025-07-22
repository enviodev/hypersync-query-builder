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

  let addAddress = () => {
    if newAddress !== "" && newAddress->String.startsWith("0x") {
      setFilterState(prevState => {
        ...prevState,
        addresses: prevState.addresses->Array.concat([newAddress]),
      })
      setNewAddress(_ => "")
    }
  }

  let removeAddress = index => {
    setFilterState(prevState => {
      ...prevState,
      addresses: prevState.addresses->Array.filterWithIndex((_, i) => i !== index),
    })
  }

  let addTopic = () => {
    if newTopic !== "" && newTopic->String.startsWith("0x") {
      setFilterState(prevState => {
        let updatedTopics = if currentTopicIndex >= prevState.topics->Array.length {
          // Add new topic array
          prevState.topics->Array.concat([[newTopic]])
        } else {
          // Add to existing topic array
          prevState.topics->Array.mapWithIndex((topicArray, i) =>
            if i === currentTopicIndex {
              topicArray->Array.concat([newTopic])
            } else {
              topicArray
            }
          )
        }
        {...prevState, topics: updatedTopics}
      })
      setNewTopic(_ => "")
    }
  }

  let removeTopic = (topicIndex, itemIndex) => {
    setFilterState(prevState => {
      let updatedTopics =
        prevState.topics
        ->Array.mapWithIndex((topicArray, i) =>
          if i === topicIndex {
            topicArray->Array.filterWithIndex((_, j) => j !== itemIndex)
          } else {
            topicArray
          }
        )
        ->Array.filter(topicArray => topicArray->Array.length > 0)
      {...prevState, topics: updatedTopics}
    })
  }

  let generateLogSelection = (): logSelection => {
    {
      address: if filterState.addresses->Array.length > 0 {
        Some(filterState.addresses)
      } else {
        None
      },
      topics: if filterState.topics->Array.length > 0 {
        Some(filterState.topics)
      } else {
        None
      },
    }
  }

  let formatJsonPreview = (logSelection: logSelection) => {
    let addressStr = switch logSelection.address {
    | Some(addresses) =>
      addresses->Array.joinWith(",\n    ")->(str => `  "address": [\n    "${str}"\n  ]`)
    | None => ""
    }

    let topicsStr = switch logSelection.topics {
    | Some(topics) => {
        let topicsFormatted =
          topics
          ->Array.map(topicArray => {
            let topicStr = topicArray->Array.joinWith(",\n      ")->(str => `"${str}"`)
            `    [\n      ${topicStr}\n    ]`
          })
          ->Array.joinWith(",\n")
        `  "topics": [\n${topicsFormatted}\n  ]`
      }
    | None => ""
    }

    let parts = [addressStr, topicsStr]->Array.filter(str => str !== "")
    if parts->Array.length > 0 {
      `{\n${parts->Array.joinWith(",\n")}\n}`
    } else {
      `{
  // Add addresses and topics above to see the query structure
}`
    }
  }

  <div className="max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-lg">
    <h2 className="text-2xl font-bold mb-6 text-gray-800"> {"Log Filters"->React.string} </h2>
    // Info section
    <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
      <h4 className="font-medium text-blue-800 mb-2">
        {"💡 How to use Log Filters"->React.string}
      </h4>
      <ul className="text-sm text-blue-700 space-y-1">
        <li>
          {"• Add contract addresses (0x...) to filter logs from specific contracts"->React.string}
        </li>
        <li>
          {"• Add topic hashes (0x...) to filter by specific events - topics are organized by position"->React.string}
        </li>
        <li> {"• Topic 0 is typically the event signature hash"->React.string} </li>
      </ul>
    </div>
    // Addresses Section
    <div className="mb-8">
      <h3 className="text-lg font-semibold mb-4 text-gray-700">
        {"Contract Addresses"->React.string}
      </h3>
      <div className="flex gap-2 mb-4">
        <input
          type_="text"
          value={newAddress}
          onChange={e => {
            let value = (e->ReactEvent.Form.target)["value"]
            setNewAddress(_ => value)
          }}
          placeholder="0xA0b86a33E6441b8bB2e86b5D7b7b9b5e8E3e9a8C (USDC contract)"
          className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        <button
          onClick={_e => addAddress()}
          disabled={newAddress->String.length == 0 || !(newAddress->String.startsWith("0x"))}
          className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed">
          {"Add Address"->React.string}
        </button>
      </div>
      <div className="space-y-2">
        {filterState.addresses
        ->Array.mapWithIndex((address, index) =>
          <div
            key={index->Int.toString}
            className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded">
            <span className="font-mono text-sm text-gray-700"> {address->React.string} </span>
            <button
              onClick={_e => removeAddress(index)}
              className="text-red-500 hover:text-red-700 text-sm font-medium">
              {"Remove"->React.string}
            </button>
          </div>
        )
        ->React.array}
      </div>
    </div>
    // Topics Section
    <div className="mb-8">
      <h3 className="text-lg font-semibold mb-4 text-gray-700"> {"Event Topics"->React.string} </h3>
      <div className="flex gap-2 mb-4">
        <select
          value={currentTopicIndex->Int.toString}
          onChange={e => {
            let value = (e->ReactEvent.Form.target)["value"]
            setCurrentTopicIndex(_ => value->Int.fromString->Option.getOr(0))
          }}
          className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
          {[0, 1, 2, 3] // Hardcoded to 4 topic positions for now
          ->Array.mapWithIndex((_, i) =>
            <option key={i->Int.toString} value={i->Int.toString}>
              {`Topic ${i->Int.toString}`->React.string}
            </option>
          )
          ->React.array}
        </select>
        <input
          type_="text"
          value={newTopic}
          onChange={e => {
            let value = (e->ReactEvent.Form.target)["value"]
            setNewTopic(_ => value)
          }}
          placeholder="0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef (Transfer)"
          className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        <button
          onClick={_e => addTopic()}
          disabled={newTopic->String.length == 0 || !(newTopic->String.startsWith("0x"))}
          className="px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed">
          {"Add Topic"->React.string}
        </button>
      </div>
      <div className="space-y-3">
        {filterState.topics
        ->Array.mapWithIndex((topicArray, topicIndex) =>
          <div key={topicIndex->Int.toString} className="border border-gray-200 rounded-lg p-3">
            <h4 className="font-medium text-gray-600 mb-2">
              {`Topic ${topicIndex->Int.toString}`->React.string}
            </h4>
            <div className="space-y-2">
              {topicArray
              ->Array.mapWithIndex((topic, itemIndex) =>
                <div
                  key={itemIndex->Int.toString}
                  className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded">
                  <span className="font-mono text-sm text-gray-700"> {topic->React.string} </span>
                  <button
                    onClick={_e => removeTopic(topicIndex, itemIndex)}
                    className="text-red-500 hover:text-red-700 text-sm font-medium">
                    {"Remove"->React.string}
                  </button>
                </div>
              )
              ->React.array}
            </div>
          </div>
        )
        ->React.array}
      </div>
    </div>
    // Preview Section
    <div className="border-t pt-6">
      <h3 className="text-lg font-semibold mb-4 text-gray-700">
        {"Query Preview"->React.string}
      </h3>
      <div className="bg-gray-900 text-gray-100 p-4 rounded-lg text-sm overflow-x-auto">
        <pre className="whitespace-pre-wrap">
          {formatJsonPreview(generateLogSelection())->React.string}
        </pre>
      </div>
    </div>
  </div>
}
