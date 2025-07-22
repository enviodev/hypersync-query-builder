type filterState = QueryStructure.logSelection

let generateEnglishDescription = (filterState: filterState) => {
  let {address, topics} = filterState
  let addressArray = address->Option.getOr([])
  let topicsArray = topics->Option.getOr([])
  
  if Array.length(addressArray) === 0 && Array.length(topicsArray) === 0 {
    "No filters applied - will match all logs"
  } else {
    let parts = []
    
    // Address condition
    if Array.length(addressArray) > 0 {
      let addressCondition = if Array.length(addressArray) === 1 {
        `the contract address is ${Array.getUnsafe(addressArray, 0)}`
      } else {
        let addressList = Array.join(addressArray, " OR ")
        `the contract address is ${addressList}`
      }
      parts->Array.push(addressCondition)->ignore
    }
    
    // Topic conditions
    let topicConditions = []
    Array.forEachWithIndex(topicsArray, (topicArray, i) => {
      if Array.length(topicArray) > 0 {
        let condition = if Array.length(topicArray) === 1 {
          `topic[${Int.toString(i)}] is ${Array.getUnsafe(topicArray, 0)}`
        } else {
          let topicList = Array.join(topicArray, " OR ")
          `topic[${Int.toString(i)}] is ${topicList}`
        }
        topicConditions->Array.push(condition)->ignore
      }
    })
    
    if Array.length(topicConditions) > 0 {
      let topicCondition = Array.join(topicConditions, " AND ")
      parts->Array.push(topicCondition)->ignore
    }
    
    if Array.length(parts) > 0 {
      `Match logs where: ${Array.join(parts, " AND ")}`
    } else {
      "No filters applied - will match all logs"
    }
  }
}

let generateBooleanHierarchy = (filterState: filterState) => {
  let {address, topics} = filterState
  
  let addressArray = address->Option.getOr([])
  let topicsArray = topics->Option.getOr([])
  
  if Array.length(addressArray) === 0 && Array.length(topicsArray) === 0 {
    "No filters"
  } else {
    let lines = []
    
    let hasMultipleConditions = 
      (Array.length(addressArray) > 0) && 
      (topicsArray->Array.some(topicArray => Array.length(topicArray) > 0))
    
    if hasMultipleConditions {
      lines->Array.push("AND")->ignore
    }
    
    // Address hierarchy
    if Array.length(addressArray) > 0 {
      let prefix = hasMultipleConditions ? "├── " : ""
      if Array.length(addressArray) === 1 {
        lines->Array.push(`${prefix}address = ${Array.getUnsafe(addressArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (address)`)->ignore
        Array.forEachWithIndex(addressArray, (addr, i) => {
          let isLast = i === Array.length(addressArray) - 1
          let addrPrefix = if hasMultipleConditions {
            isLast ? "│   └── " : "│   ├── "
          } else {
            isLast ? "└── " : "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
    }
    
    // Topic hierarchy
    let nonEmptyTopics = topicsArray->Array.filterMap(topicArray => Array.length(topicArray) > 0 ? Some(topicArray) : None)
    if Array.length(nonEmptyTopics) > 0 {
      let hasTopicConditions = Array.length(nonEmptyTopics) > 1
      let topicPrefix = hasMultipleConditions ? "└── " : ""
      
      if hasTopicConditions {
        lines->Array.push(`${topicPrefix}AND (topics)`)->ignore
      }
      
      let topicIndex = ref(0)
      Array.forEachWithIndex(topicsArray, (topicArray, i) => {
        if Array.length(topicArray) > 0 {
          let isLastTopic = topicIndex.contents === Array.length(nonEmptyTopics) - 1
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
          
          if Array.length(topicArray) === 1 {
            lines->Array.push(`${basePrefix}topic[${Int.toString(i)}] = ${Array.getUnsafe(topicArray, 0)}`)->ignore
          } else {
            lines->Array.push(`${basePrefix}OR (topic[${Int.toString(i)}])`)->ignore
            Array.forEachWithIndex(topicArray, (topic, j) => {
              let isLastValue = j === Array.length(topicArray) - 1
              let valuePrefix = if hasMultipleConditions {
                if hasTopicConditions {
                  if isLastTopic {
                    isLastValue ? "        └── " : "        ├── "
                  } else {
                    isLastValue ? "    │   └── " : "    │   ├── "
                  }
                } else {
                  isLastValue ? "└── " : "├── "
                }
              } else {
                if hasTopicConditions {
                  if isLastTopic {
                    isLastValue ? "    └── " : "    ├── "
                  } else {
                    isLastValue ? "│  └── " : "│  ├── "
                  }
                } else {
                  isLastValue ? "└── " : "├── "
                }
              }
              lines->Array.push(`${valuePrefix}${topic}`)->ignore
            })
          }
          topicIndex := topicIndex.contents + 1
        }
      })
    }
    
    Array.join(lines, "\n")
  }
} 
