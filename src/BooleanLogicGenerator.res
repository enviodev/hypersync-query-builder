open QueryStructure

type filterState = QueryStructure.logSelection

// Helper function to check if a filter is empty
let isEmptyFilter = (filterState: filterState) => {
  let {address, topics} = filterState
  let addressArray = address->Option.getOr([])
  let topicsArray = topics->Option.getOr([])
  Array.length(addressArray) === 0 && Array.length(topicsArray) === 0
}

// Helper function to check if a transaction filter is empty
let isEmptyTransactionFilter = (filterState: QueryStructure.transactionSelection) => {
  let {from_, to_, sighash, status, kind, contractAddress, authorizationList} = filterState
  let fromArray = from_->Option.getOr([])
  let toArray = to_->Option.getOr([])
  let sighashArray = sighash->Option.getOr([])
  let kindArray = kind->Option.getOr([])
  let contractAddressArray = contractAddress->Option.getOr([])
  let authArray = authorizationList->Option.getOr([])
  
  Array.length(fromArray) === 0 &&
  Array.length(toArray) === 0 &&
  Array.length(sighashArray) === 0 &&
  Option.isNone(status) &&
  Array.length(kindArray) === 0 &&
  Array.length(contractAddressArray) === 0 &&
  Array.length(authArray) === 0
}

// Helper function to check if a block filter is empty
let isEmptyBlockFilter = (filterState: QueryStructure.blockSelection) => {
  let {hash, miner} = filterState
  let hashArray = hash->Option.getOr([])
  let minerArray = miner->Option.getOr([])
  Array.length(hashArray) === 0 && Array.length(minerArray) === 0
}

// Helper function to generate a clean filter description (without "Match logs where:" prefix)
let generateFilterDescription = (filterState: filterState) => {
  let {address, topics} = filterState
  let addressArray = address->Option.getOr([])
  let topicsArray = topics->Option.getOr([])
  
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
  
  Array.join(parts, " AND ")
}

// Helper function to generate transaction filter description
let generateTransactionFilterDescription = (filterState: QueryStructure.transactionSelection) => {
  let description = TransactionBooleanLogicGenerator.generateEnglishDescription(filterState)
  switch String.startsWith(description, "Match transactions where: ") {
  | true => String.sliceToEnd(description, ~start=26) // Remove "Match transactions where: " prefix
  | false => description
  }
}

// Helper function to generate block filter description  
let generateBlockFilterDescription = (filterState: QueryStructure.blockSelection) => {
  let description = BlockBooleanLogicGenerator.generateEnglishDescription(filterState)
  switch String.startsWith(description, "Match blocks where: ") {
  | true => String.sliceToEnd(description, ~start=20) // Remove "Match blocks where: " prefix
  | false => description
  }
}

let generateMultiFilterDescription = (filters: option<array<filterState>>) => {
  switch filters {
  | None => "selecting None"
  | Some(filterArray) => 
    if Array.length(filterArray) === 0 {
      "selecting None"
    } else if Array.length(filterArray) === 1 && isEmptyFilter(Array.getUnsafe(filterArray, 0)) {
      "selecting ALL"
    } else {
      let filterDescriptions = filterArray
        ->Array.map(filter => {
          if isEmptyFilter(filter) {
            "ALL logs"
          } else {
            let description = generateFilterDescription(filter)
            if String.includes(description, " AND ") {
              `(${description})`
            } else {
              description
            }
          }
        })
        ->Array.filter(desc => desc !== "")
      
      if Array.length(filterDescriptions) === 0 {
        "selecting None"
      } else {
        `Match logs where: ${Array.join(filterDescriptions, " OR ")}`
      }
    }
  }
}

let generateMultiTransactionFilterDescription = (filters: option<array<QueryStructure.transactionSelection>>) => {
  switch filters {
  | None => "selecting None"
  | Some(filterArray) => 
    if Array.length(filterArray) === 0 {
      "selecting None"
    } else if Array.length(filterArray) === 1 && isEmptyTransactionFilter(Array.getUnsafe(filterArray, 0)) {
      "selecting ALL"
    } else {
      let filterDescriptions = filterArray
        ->Array.map(filter => {
          if isEmptyTransactionFilter(filter) {
            "ALL transactions"
          } else {
            let description = generateTransactionFilterDescription(filter)
            if String.includes(description, " AND ") {
              `(${description})`
            } else {
              description
            }
          }
        })
        ->Array.filter(desc => desc !== "")
      
      if Array.length(filterDescriptions) === 0 {
        "selecting None"
      } else {
        `Match transactions where: ${Array.join(filterDescriptions, " OR ")}`
      }
    }
  }
}

let generateMultiBlockFilterDescription = (filters: option<array<QueryStructure.blockSelection>>) => {
  switch filters {
  | None => "selecting None"
  | Some(filterArray) => 
    if Array.length(filterArray) === 0 {
      "selecting None"
    } else if Array.length(filterArray) === 1 && isEmptyBlockFilter(Array.getUnsafe(filterArray, 0)) {
      "selecting ALL"
    } else {
      let filterDescriptions = filterArray
        ->Array.map(filter => {
          if isEmptyBlockFilter(filter) {
            "ALL blocks"
          } else {
            let description = generateBlockFilterDescription(filter)
            if String.includes(description, " AND ") {
              `(${description})`
            } else {
              description
            }
          }
        })
        ->Array.filter(desc => desc !== "")
      
      if Array.length(filterDescriptions) === 0 {
        "selecting None"
      } else {
        `Match blocks where: ${Array.join(filterDescriptions, " OR ")}`
      }
    }
  }
}

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

let generateMultiBooleanHierarchy = (filters: option<array<filterState>>) => {
  switch filters {
  | None => "No filters"
  | Some(filterArray) => 
    if Array.length(filterArray) === 0 {
      "No filters"
    } else if Array.length(filterArray) === 1 && isEmptyFilter(Array.getUnsafe(filterArray, 0)) {
      "All logs"
    } else {
      let nonEmptyFilters = filterArray->Array.filter(filter => !isEmptyFilter(filter))
      let hasEmptyFilter = filterArray->Array.some(isEmptyFilter)
      
      if Array.length(nonEmptyFilters) === 0 && hasEmptyFilter {
        "All logs"
      } else if Array.length(nonEmptyFilters) === 1 && !hasEmptyFilter {
        // Single non-empty filter, no OR needed
        generateBooleanHierarchy(Array.getUnsafe(nonEmptyFilters, 0))
      } else {
        let lines = []
        lines->Array.push("OR")->ignore
        
        let allFilters = hasEmptyFilter ? Array.concat(nonEmptyFilters, [{address: None, topics: None}]) : nonEmptyFilters
        
        Array.forEachWithIndex(allFilters, (filter, i) => {
          let isLast = i === Array.length(allFilters) - 1
          let prefix = isLast ? "└── " : "├── "
          
          if isEmptyFilter(filter) {
            lines->Array.push(`${prefix}All logs`)->ignore
          } else {
            let filterHierarchy = generateBooleanHierarchy(filter)
            if String.includes(filterHierarchy, "\n") {
              // Multi-line hierarchy needs proper indentation
              let hierarchyLines = String.split(filterHierarchy, "\n")
              Array.forEachWithIndex(hierarchyLines, (line, lineIndex) => {
                if lineIndex === 0 {
                  lines->Array.push(`${prefix}${line}`)->ignore
                } else {
                  let indent = if isLast { "    " } else { "│   " }
                  lines->Array.push(`${indent}${line}`)->ignore
                }
              })
            } else {
              // Single line hierarchy
              lines->Array.push(`${prefix}${filterHierarchy}`)->ignore
            }
          }
        })
        
        Array.join(lines, "\n")
      }
    }
  }
} 

let generateMultiTransactionBooleanHierarchy = (filters: option<array<QueryStructure.transactionSelection>>) => {
  switch filters {
  | None => "No filters"
  | Some(filterArray) => 
    if Array.length(filterArray) === 0 {
      "No filters"
    } else if Array.length(filterArray) === 1 && isEmptyTransactionFilter(Array.getUnsafe(filterArray, 0)) {
      "All transactions"
    } else {
      let nonEmptyFilters = filterArray->Array.filter(filter => !isEmptyTransactionFilter(filter))
      let hasEmptyFilter = filterArray->Array.some(isEmptyTransactionFilter)
      
      if Array.length(nonEmptyFilters) === 0 && hasEmptyFilter {
        "All transactions"
      } else if Array.length(nonEmptyFilters) === 1 && !hasEmptyFilter {
        // Single non-empty filter, no OR needed
        TransactionBooleanLogicGenerator.generateBooleanHierarchy(Array.getUnsafe(nonEmptyFilters, 0))
      } else {
        let lines = []
        lines->Array.push("OR")->ignore
        
        let allFilters = hasEmptyFilter ? Array.concat(nonEmptyFilters, [{from_: None, to_: None, sighash: None, status: None, kind: None, contractAddress: None, authorizationList: None}]) : nonEmptyFilters
        
        Array.forEachWithIndex(allFilters, (filter, i) => {
          let isLast = i === Array.length(allFilters) - 1
          let prefix = isLast ? "└── " : "├── "
          
          if isEmptyTransactionFilter(filter) {
            lines->Array.push(`${prefix}All transactions`)->ignore
          } else {
            let filterHierarchy = TransactionBooleanLogicGenerator.generateBooleanHierarchy(filter)
            if String.includes(filterHierarchy, "\n") {
              // Multi-line hierarchy needs proper indentation
              let hierarchyLines = String.split(filterHierarchy, "\n")
              Array.forEachWithIndex(hierarchyLines, (line, lineIndex) => {
                if lineIndex === 0 {
                  lines->Array.push(`${prefix}${line}`)->ignore
                } else {
                  let indent = if isLast { "    " } else { "│   " }
                  lines->Array.push(`${indent}${line}`)->ignore
                }
              })
            } else {
              // Single line hierarchy
              lines->Array.push(`${prefix}${filterHierarchy}`)->ignore
            }
          }
        })
        
        Array.join(lines, "\n")
      }
    }
  }
}

let generateMultiBlockBooleanHierarchy = (filters: option<array<QueryStructure.blockSelection>>) => {
  switch filters {
  | None => "No filters"
  | Some(filterArray) => 
    if Array.length(filterArray) === 0 {
      "No filters"
    } else if Array.length(filterArray) === 1 && isEmptyBlockFilter(Array.getUnsafe(filterArray, 0)) {
      "All blocks"
    } else {
      let nonEmptyFilters = filterArray->Array.filter(filter => !isEmptyBlockFilter(filter))
      let hasEmptyFilter = filterArray->Array.some(isEmptyBlockFilter)
      
      if Array.length(nonEmptyFilters) === 0 && hasEmptyFilter {
        "All blocks"
      } else if Array.length(nonEmptyFilters) === 1 && !hasEmptyFilter {
        // Single non-empty filter, no OR needed
        BlockBooleanLogicGenerator.generateBooleanHierarchy(Array.getUnsafe(nonEmptyFilters, 0))
      } else {
        let lines = []
        lines->Array.push("OR")->ignore
        
        let allFilters = hasEmptyFilter ? Array.concat(nonEmptyFilters, [{hash: None, miner: None}]) : nonEmptyFilters
        
        Array.forEachWithIndex(allFilters, (filter, i) => {
          let isLast = i === Array.length(allFilters) - 1
          let prefix = isLast ? "└── " : "├── "
          
          if isEmptyBlockFilter(filter) {
            lines->Array.push(`${prefix}All blocks`)->ignore
          } else {
            let filterHierarchy = BlockBooleanLogicGenerator.generateBooleanHierarchy(filter)
            if String.includes(filterHierarchy, "\n") {
              // Multi-line hierarchy needs proper indentation
              let hierarchyLines = String.split(filterHierarchy, "\n")
              Array.forEachWithIndex(hierarchyLines, (line, lineIndex) => {
                if lineIndex === 0 {
                  lines->Array.push(`${prefix}${line}`)->ignore
                } else {
                  let indent = if isLast { "    " } else { "│   " }
                  lines->Array.push(`${indent}${line}`)->ignore
                }
              })
            } else {
              // Single line hierarchy
              lines->Array.push(`${prefix}${filterHierarchy}`)->ignore
            }
          }
        })
        
        Array.join(lines, "\n")
      }
    }
  }
} 
