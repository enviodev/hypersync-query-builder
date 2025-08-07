open QueryStructure

type filterState = QueryStructure.logSelection

@react.component
let make = (
  ~filterState: filterState,
  ~onFilterChange,
  ~onRemove,
  ~filterIndex,
  ~isExpanded: bool,
  ~onToggleExpand,
) => {
  let (newAddress, setNewAddress) = React.useState(() => "")
  let (newTopic, setNewTopic) = React.useState(() => "")
  let (currentTopicIndex, setCurrentTopicIndex) = React.useState(() => 0)

  // Example filter states
  let transferEventsExample: filterState = {
    address: None,
    topics: Some([["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"]]),
  }

  let burnEventsExample: filterState = {
    address: None,
    topics: Some([
      ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"],
      [],
      ["0x0000000000000000000000000000000000000000000000000000000000000000"],
    ]),
  }

  let setTransferEventsExample = () => {
    onFilterChange(transferEventsExample)
  }

  let setBurnEventsExample = () => {
    onFilterChange(burnEventsExample)
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
      let requiredLength = max(filterState.topics->Option.getOr([])->Array.length, currentIndex + 1)
      let paddedTopics = Belt.Array.makeBy(requiredLength, i => {
        if i < filterState.topics->Option.getOr([])->Array.length {
          Array.getUnsafe(filterState.topics->Option.getOr([]), i)
        } else {
          []
        }
      })

      let existingTopics = Belt.Array.get(paddedTopics, currentIndex)->Option.getOr([])
      let newTopics = Array.concat(existingTopics, [newTopic])
      Array.setUnsafe(paddedTopics, currentIndex, newTopics)

      onFilterChange({
        ...filterState,
        topics: Some(paddedTopics),
      })
      setNewTopic(_ => "")
    }
  }

  let removeTopic = (topicIndex, itemIndex) => {
    let currentTopics = filterState.topics->Option.getOr([])
    let topicArray = Belt.Array.get(currentTopics, topicIndex)->Option.getOr([])
    let newTopicArray = Belt.Array.keepWithIndex(topicArray, (_, i) => i !== itemIndex)
    let newTopics = Array.mapWithIndex(currentTopics, (topic, i) =>
      i === topicIndex ? newTopicArray : topic
    )
    onFilterChange({
      ...filterState,
      topics: Array.length(newTopics) > 0 && Array.some(newTopics, arr => Array.length(arr) > 0)
        ? Some(newTopics)
        : None,
    })
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
      let topicsContent = Array.join(
        topicsArray->Array.map(topicArray => {
          if Array.length(topicArray) === 0 {
            "    []"
          } else {
            let topicList = Array.join(topicArray->Array.map(topic => `      "${topic}"`), ",\n")
            `    [\n${topicList}\n    ]`
          }
        }),
        ",\n",
      )
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

  let hasFilters =
    Array.length(filterState.address->Option.getOr([])) > 0 ||
      Array.length(filterState.topics->Option.getOr([])) > 0

  <div
    className={`bg-white rounded-xl border border-slate-200 shadow-sm transition-all ${isExpanded
        ? "w-full"
        : "w-64"}`}>
    <div className="p-4 border-b border-slate-100">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <h3 className="text-lg font-medium text-slate-900">
            {`Log Filter ${Int.toString(filterIndex + 1)}`->React.string}
          </h3>
          {hasFilters
            ? <span
                className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700">
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
              onClick={_ => setTransferEventsExample()}
              className="px-4 py-2 bg-slate-700 text-white text-sm font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
              {"Transfer Events"->React.string}
            </button>
            <button
              onClick={_ => setBurnEventsExample()}
              className="px-4 py-2 bg-rose-600 text-white text-sm font-medium rounded-lg hover:bg-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500 transition-colors">
              {"Burn Events"->React.string}
            </button>
          </div>

          // Address Filters
          <div className="mb-6">
            <label className="block text-sm font-medium text-slate-700 mb-2">
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
                className="flex-1 border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition-colors"
              />
              <button
                onClick={_ => addAddress()}
                disabled={String.length(newAddress) == 0 || !(newAddress->String.startsWith("0x"))}
                className="px-4 py-2 bg-slate-700 text-white text-sm font-medium rounded-lg hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                {(
                  Array.length(filterState.address->Option.getOr([])) > 0
                    ? "Add (via OR) Address"
                    : "Add Address"
                )->React.string}
              </button>
            </div>
            <div className="space-y-2">
              {Array.mapWithIndex(filterState.address->Option.getOr([]), (address, index) =>
                <div
                  key={Int.toString(index)}
                  className="flex items-center justify-between bg-slate-50 px-3 py-2 rounded-lg border border-slate-100">
                  <span className="text-sm font-mono text-slate-800">
                    {address->React.string}
                  </span>
                  <button
                    onClick={_ => removeAddress(index)}
                    className="text-red-600 hover:text-red-800 text-sm font-medium transition-colors">
                    {"Remove"->React.string}
                  </button>
                </div>
              )->React.array}
            </div>
          </div>

          // Topic Filters
          <div className="mb-6">
            <label className="block text-sm font-medium text-slate-700 mb-2">
              {"Event Topics"->React.string}
            </label>
            <div className="flex space-x-2 mb-3">
              <select
                value={Int.toString(currentTopicIndex)}
                onChange={e => {
                  let target = ReactEvent.Form.target(e)
                  switch Int.fromString(target["value"]) {
                  | Some(index) => setCurrentTopicIndex(_ => index)
                  | None => ()
                  }
                }}
                className="border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-500 transition-colors">
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
                className="flex-1 border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-500 focus:border-slate-500 transition-colors"
              />
              <button
                onClick={_ => addTopic()}
                disabled={String.length(newTopic) == 0 || !(newTopic->String.startsWith("0x"))}
                className="px-4 py-2 bg-emerald-600 text-white text-sm font-medium rounded-lg hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-emerald-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                {(
                  currentTopicIndex < Array.length(filterState.topics->Option.getOr([])) &&
                    Array.length(
                      Array.getUnsafe(filterState.topics->Option.getOr([]), currentTopicIndex),
                    ) > 0
                    ? "Add (via OR) Topic"
                    : "Add Topic"
                )->React.string}
              </button>
            </div>
            <div className="space-y-3">
              {Array.mapWithIndex(filterState.topics->Option.getOr([]), (topicArray, topicIndex) =>
                <div
                  key={Int.toString(topicIndex)} className="border border-gray-200 rounded-md p-3">
                  <h4 className="text-sm font-medium text-gray-700 mb-2">
                    {`Topic ${Int.toString(topicIndex)}`->React.string}
                  </h4>
                  <div className="space-y-2">
                    {Array.mapWithIndex(topicArray, (topic, itemIndex) =>
                      <div
                        key={`${Int.toString(topicIndex)}-${Int.toString(itemIndex)}`}
                        className="flex items-center justify-between bg-gray-50 px-3 py-2 rounded-md">
                        <span className="text-sm font-mono text-gray-800">
                          {topic->React.string}
                        </span>
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
