type filterState = QueryStructure.logSelection

@react.component
let make = (~filterState: filterState, ~onFilterChange, ~onRemove, ~filterIndex) => {
  let (isExpanded, setIsExpanded) = React.useState(() => true) // Start expanded for new filters
  let (newAddress, setNewAddress) = React.useState(() => "")
  let (newTopic, setNewTopic) = React.useState(() => "")
  let (currentTopicIndex, setCurrentTopicIndex) = React.useState(() => 0)

  let exampleSetFilterState: filterState = {
    address: Some(["0x1234567890123456789012345678901234567890"]),
    topics: Some([["0x1", "0x2", "0x3"], [], ["0x4"]]),
  }

  let setExampleFilterState = () => {
    onFilterChange(exampleSetFilterState)
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

  let addTopic = () => {
    if newTopic !== "" && newTopic->String.startsWith("0x") {
      let currentIndex: int = currentTopicIndex
      // Ensure topics array is long enough to accommodate the current index
      let requiredLength = max(filterState.topics->Option.getOr([])->Array.length, currentIndex + 1)
      let paddedTopics = Belt.Array.makeBy(requiredLength, i => {
        if i < filterState.topics->Option.getOr([])->Array.length {
          Array.getUnsafe(filterState.topics->Option.getOr([]), i)
        } else {
          []
        }
      })
      
      // Add the new topic to the correct index
      let updatedTopics = Array.mapWithIndex(paddedTopics, (topicArray, i) =>
        if i === currentIndex {
          Array.concat(topicArray, [newTopic])
        } else {
          topicArray
        }
      )

      onFilterChange({
        ...filterState,
        topics: Some(updatedTopics),
      })
      setNewTopic(_ => "")
    }
  }

  let removeTopic = (topicIndex: int, itemIndex: int) => {
    let updatedTopics = Array.mapWithIndex(
      filterState.topics->Option.getOr([]),
      (topicArray, i) =>
        if i === topicIndex {
          Belt.Array.keepWithIndex(topicArray, (_, j) => j !== itemIndex)
        } else {
          topicArray
        },
    )

    onFilterChange({...filterState, topics: Some(updatedTopics)})
  }

  let generateEnglishDescription = () => {
    BooleanLogicGenerator.generateEnglishDescription({
      address: filterState.address,
      topics: filterState.topics,
    })
  }

  let generateBooleanHierarchy = () => {
    BooleanLogicGenerator.generateBooleanHierarchy({
      address: filterState.address,
      topics: filterState.topics,
    })
  }

  let generateCodeBlock = () => {
    let {address, topics} = filterState
    let addressArray = address->Option.getOr([])
    let topicsArray = topics->Option.getOr([])

    let addressStr = if Array.length(addressArray) > 0 {
      let addressList = Array.join(addressArray->Array.map(addr => `    "${addr}"`), ",\n")
      `  "address": [\n${addressList}\n  ]`
    } else {
      ""
    }

    let topicsStr = if Array.length(topicsArray) > 0 {
      let topicsContent = Array.join(topicsArray->Array.map(topicArray => {
          if Array.length(topicArray) === 0 {
            "    []"
          } else {
            let topicList = Array.join(topicArray->Array.map(topic => `      "${topic}"`), ",\n")
            `    [\n${topicList}\n    ]`
          }
        }), ",\n")
      `  "topics": [\n${topicsContent}\n  ]`
    } else {
      ""
    }

    let parts = [addressStr, topicsStr]->Array.filter(str => str !== "")
    if Array.length(parts) > 0 {
      `{\n${Array.join(parts, ",\n")}\n}`
    } else {
      "{}"
    }
  }

  let hasFilters = Array.length(filterState.address->Option.getOr([])) > 0 || Array.length(filterState.topics->Option.getOr([])) > 0

  <div className="bg-white rounded-lg shadow">
    <div className="p-4 border-b border-gray-200">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-gray-900">
            {`Log Filter ${Int.toString(filterIndex + 1)}`->React.string}
          </h3>
          {hasFilters
            ? <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
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
                disabled={String.length(newAddress) == 0 || !(newAddress->String.startsWith("0x"))}
                className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {(Array.length(filterState.address->Option.getOr([])) > 0 ? "Add (via OR) Address" : "Add Address")->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.address->Option.getOr([]), (address, index) =>
                <div
                  key={Int.toString(index)}
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
                value={Int.toString(currentTopicIndex)}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  setCurrentTopicIndex(_ =>
                    Int.fromString(target["value"])->Option.getOr(0)
                  )
                }}
                className="border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                {Array.mapWithIndex(Belt.Array.range(0, 3), (_, i) =>
                  <option key={Int.toString(i)} value={Int.toString(i)}>
                    {`Topic ${Int.toString(i)}`->React.string}
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
                disabled={String.length(newTopic) == 0 || !(newTopic->String.startsWith("0x"))}
                className="px-4 py-2 bg-green-600 text-white text-sm font-medium rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed">
                {(
                  currentTopicIndex < Array.length(filterState.topics->Option.getOr([])) && 
                  Array.length(Array.getUnsafe(filterState.topics->Option.getOr([]), currentTopicIndex)) > 0 
                    ? "Add (via OR) Topic" 
                    : "Add Topic"
                )->React.string}
              </button>
            </div>
            <div className="space-y-3">
              {Array.mapWithIndex(filterState.topics->Option.getOr([]), (topicArray, topicIndex) =>
                <div key={Int.toString(topicIndex)} className="border border-gray-200 rounded-md p-3">
                  <h4 className="text-sm font-medium text-gray-700 mb-2">
                    {`Topic ${Int.toString(topicIndex)}`->React.string}
                  </h4>
                  <div className="space-y-2">
                    {Array.mapWithIndex(topicArray, (topic, itemIndex) =>
                      <div
                        key={`${Int.toString(topicIndex)}-${Int.toString(itemIndex)}`}
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
      : React.null}
  </div>
}
