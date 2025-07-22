type blockFilterState = {
  hash: array<string>,
  miner: array<string>,
}

let generateEnglishDescription = (filterState: blockFilterState) => {
  let {hash, miner} = filterState
  
  let hasAnyFilter = 
    Array.length(hash) > 0 ||
    Array.length(miner) > 0
  
  if !hasAnyFilter {
    "No filters applied - will match all blocks"
  } else {
    let parts = []
    
    // Hash condition
    if Array.length(hash) > 0 {
      let hashCondition = if Array.length(hash) === 1 {
        `the block hash is ${Array.getUnsafe(hash, 0)}`
      } else {
        let hashList = hash->Array.join(" OR ")
        `the block hash is ${hashList}`
      }
      parts->Array.push(hashCondition)->ignore
    }
    
    // Miner condition
    if Array.length(miner) > 0 {
      let minerCondition = if Array.length(miner) === 1 {
        `the miner address is ${Array.getUnsafe(miner, 0)}`
      } else {
        let minerList = miner->Array.join(" OR ")
        `the miner address is ${minerList}`
      }
      parts->Array.push(minerCondition)->ignore
    }
    
    if Array.length(parts) > 0 {
      `Match blocks where: ${parts->Array.join(" AND ")}`
    } else {
      "No filters applied - will match all blocks"
    }
  }
}

let generateBooleanHierarchy = (filterState: blockFilterState) => {
  let {hash, miner} = filterState
  
  let hasAnyFilter = 
    Array.length(hash) > 0 ||
    Array.length(miner) > 0
  
  if !hasAnyFilter {
    "No filters"
  } else {
    let lines = []
    
    let conditions = []
    if Array.length(hash) > 0 { conditions->Array.push("hash")->ignore }
    if Array.length(miner) > 0 { conditions->Array.push("miner")->ignore }
    
    let hasMultipleConditions = Array.length(conditions) > 1
    
    if hasMultipleConditions {
      lines->Array.push("AND")->ignore
    }
    
    let conditionIndex = ref(0)
    
    // Hash
    if Array.length(hash) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(hash) === 1 {
        lines->Array.push(`${prefix}hash = ${Array.getUnsafe(hash, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (hash)`)->ignore
        Array.forEachWithIndex(hash, (i, h) => {
          let isLastHash = i === Array.length(hash) - 1
          let hashPrefix = if hasMultipleConditions {
            if isLast {
              isLastHash ? "    └── " : "    ├── "
            } else {
              isLastHash ? "│   └── " : "│   ├── "
            }
          } else {
            isLastHash ? "└── " : "├── "
          }
          lines->Array.push(`${hashPrefix}${h}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }
    
    // Miner
    if Array.length(miner) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(miner) === 1 {
        lines->Array.push(`${prefix}miner = ${Array.getUnsafe(miner, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (miner)`)->ignore
        Array.forEachWithIndex(miner, (i, m) => {
          let isLastMiner = i === Array.length(miner) - 1
          let minerPrefix = if hasMultipleConditions {
            if isLast {
              isLastMiner ? "    └── " : "    ├── "
            } else {
              isLastMiner ? "│   └── " : "│   ├── "
            }
          } else {
            isLastMiner ? "└── " : "├── "
          }
          lines->Array.push(`${minerPrefix}${m}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }
    
    lines->Array.join("\n")
  }
} 
