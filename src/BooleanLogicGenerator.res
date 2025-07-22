type filterState = {
  addresses: array<string>,
  topics: array<array<string>>,
}

let generateEnglishDescription = (filterState: filterState) => {
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

let generateBooleanHierarchy = (filterState: filterState) => {
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
