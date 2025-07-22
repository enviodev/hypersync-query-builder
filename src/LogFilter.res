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
    let {addresses, topics} = filterState
    
    if Belt.Array.length(addresses) === 0 && Belt.Array.length(topics) === 0 {
      "No filters applied - will match all logs"
    } else {
      let parts = []
      
      // Address condition
      if Belt.Array.length(addresses) > 0 {
        let addressCondition = if Belt.Array.length(addresses) === 1 {
          `the contract address is ${Belt.Array.getUnsafe(addresses, 0)}`
        } else {
          let addressList = addresses->Js.Array2.joinWith(" OR ")
          `the contract address is ${addressList}`
        }
        parts->Js.Array2.push(addressCondition)->ignore
      }
      
      // Topic conditions
      let topicConditions = []
      Belt.Array.forEachWithIndex(topics, (i, topicArray) => {
        if Belt.Array.length(topicArray) > 0 {
          let condition = if Belt.Array.length(topicArray) === 1 {
            `topic[${Js.Int.toString(i)}] is ${Belt.Array.getUnsafe(topicArray, 0)}`
          } else {
            let topicList = topicArray->Js.Array2.joinWith(" OR ")
            `topic[${Js.Int.toString(i)}] is ${topicList}`
          }
          topicConditions->Js.Array2.push(condition)->ignore
        }
      })
      
      if Belt.Array.length(topicConditions) > 0 {
        let topicCondition = topicConditions->Js.Array2.joinWith(" AND ")
        parts->Js.Array2.push(topicCondition)->ignore
      }
      
      if Belt.Array.length(parts) > 0 {
        `Match logs where: ${parts->Js.Array2.joinWith(" AND ")}`
      } else {
        "No filters applied - will match all logs"
      }
    }
  }

  let generateBooleanHierarchy = () => {
    let {addresses, topics} = filterState
    
    if Belt.Array.length(addresses) === 0 && Belt.Array.length(topics) === 0 {
      "No filters"
    } else {
      let lines = []
      
      let hasMultipleConditions = 
        (Belt.Array.length(addresses) > 0) && 
        (topics->Belt.Array.some(topicArray => Belt.Array.length(topicArray) > 0))
      
      if hasMultipleConditions {
        lines->Js.Array2.push("AND")->ignore
      }
      
      // Address hierarchy
      if Belt.Array.length(addresses) > 0 {
        let prefix = hasMultipleConditions ? "├── " : ""
        if Belt.Array.length(addresses) === 1 {
          lines->Js.Array2.push(`${prefix}address = ${Belt.Array.getUnsafe(addresses, 0)}`)->ignore
        } else {
          lines->Js.Array2.push(`${prefix}OR (address)`)->ignore
          Belt.Array.forEachWithIndex(addresses, (i, addr) => {
            let isLast = i === Belt.Array.length(addresses) - 1
            let addrPrefix = if hasMultipleConditions {
              isLast ? "│   └── " : "│   ├── "
            } else {
              isLast ? "└── " : "├── "
            }
            lines->Js.Array2.push(`${addrPrefix}${addr}`)->ignore
          })
        }
      }
      
      // Topic hierarchy
      let nonEmptyTopics = topics->Belt.Array.keepWithIndex((topicArray, _) => Belt.Array.length(topicArray) > 0)
      if Belt.Array.length(nonEmptyTopics) > 0 {
        let hasTopicConditions = Belt.Array.length(nonEmptyTopics) > 1
        let topicPrefix = hasMultipleConditions ? "└── " : ""
        
        if hasTopicConditions {
          lines->Js.Array2.push(`${topicPrefix}AND (topics)`)->ignore
        }
        
        let topicIndex = ref(0)
        Belt.Array.forEachWithIndex(topics, (i, topicArray) => {
          if Belt.Array.length(topicArray) > 0 {
            let isLastTopic = topicIndex.contents === Belt.Array.length(nonEmptyTopics) - 1
            let basePrefix = if hasMultipleConditions {
              if hasTopicConditions {
                isLastTopic ? "    └── " : "    ├── "
              } else {
                "└── "
              }
            } else {
              if hasTopicConditions {
                isLastTopic ? "└── " : "├── "
              } else {
                ""
              }
            }
            
            if Belt.Array.length(topicArray) === 1 {
              lines->Js.Array2.push(`${basePrefix}topic[${Js.Int.toString(i)}] = ${Belt.Array.getUnsafe(topicArray, 0)}`)->ignore
            } else {
              lines->Js.Array2.push(`${basePrefix}OR (topic[${Js.Int.toString(i)}])`)->ignore
              Belt.Array.forEachWithIndex(topicArray, (j, topic) => {
                let isLastValue = j === Belt.Array.length(topicArray) - 1
                let valuePrefix = if hasMultipleConditions {
                  if hasTopicConditions {
                    if isLastTopic {
                      isLastValue ? "    └── " : "    ├── "
                    } else {
                      isLastValue ? "│   └── " : "│   ├── "
                    }
                  } else {
                    isLastValue ? "└── " : "├── "
                  }
                } else {
                  if hasTopicConditions {
                    if isLastTopic {
                      isLastValue ? "└── " : "├── "
                    } else {
                      isLastValue ? "│  └── " : "│  ├── "
                    }
                  } else {
                    isLastValue ? "└── " : "├── "
                  }
                }
                lines->Js.Array2.push(`${valuePrefix}${topic}`)->ignore
              })
            }
            topicIndex := topicIndex.contents + 1
          }
        })
      }
      
      lines->Js.Array2.joinWith("\n")
    }
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
    <button
      onClick={_ => setExampleFilterState()}
      > {"Set Example Filter State"->React.string}
    </button>
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
