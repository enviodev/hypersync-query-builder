type transactionFilterState = QueryStructure.transactionSelection

let generateEnglishDescription = (filterState: transactionFilterState) => {
  let {from_, to_, sighash, status, kind, contractAddress} = filterState
  let fromArray = from_->Option.getOr([])
  let toArray = to_->Option.getOr([])
  let sighashArray = sighash->Option.getOr([])
  let kindArray = kind->Option.getOr([])
  let contractAddressArray = contractAddress->Option.getOr([])
  
  let hasAnyFilter = 
    Array.length(fromArray) > 0 ||
    Array.length(toArray) > 0 ||
    Array.length(sighashArray) > 0 ||
    Option.isSome(status) ||
    Array.length(kindArray) > 0 ||
    Array.length(contractAddressArray) > 0
  
  if !hasAnyFilter {
    "No filters applied - will match all transactions"
  } else {
    let parts = []
    
    // From condition
    if Array.length(fromArray) > 0 {
      let fromCondition = if Array.length(fromArray) === 1 {
        `the sender address is ${Array.getUnsafe(fromArray, 0)}`
      } else {
        let fromList = Array.join(fromArray, " OR ")
        `the sender address is ${fromList}`
      }
      parts->Array.push(fromCondition)->ignore
    }
    
    // To condition
    if Array.length(toArray) > 0 {
      let toCondition = if Array.length(toArray) === 1 {
        `the recipient address is ${Array.getUnsafe(toArray, 0)}`
      } else {
        let toList = Array.join(toArray, " OR ")
        `the recipient address is ${toList}`
      }
      parts->Array.push(toCondition)->ignore
    }
    
    // Sighash condition
    if Array.length(sighashArray) > 0 {
      let sighashCondition = if Array.length(sighashArray) === 1 {
        `the function signature is ${Array.getUnsafe(sighashArray, 0)}`
      } else {
        let sighashList = Array.join(sighashArray, " OR ")
        `the function signature is ${sighashList}`
      }
      parts->Array.push(sighashCondition)->ignore
    }
    
    // Status condition
    switch status {
    | Some(s) => 
      let statusText = s === 1 ? "successful" : "failed"
      parts->Array.push(`the transaction is ${statusText}`)->ignore
    | None => ()
    }
    
    // Kind condition
    if Array.length(kindArray) > 0 {
      let kindCondition = if Array.length(kindArray) === 1 {
        `the transaction kind is ${Int.toString(Array.getUnsafe(kindArray, 0))}`
      } else {
        let kindList = switch Array.length(kindArray) {
        | 0 => ""
        | 1 => Int.toString(Array.getUnsafe(kindArray, 0))
        | 2 => Int.toString(Array.getUnsafe(kindArray, 0)) ++ " OR " ++ Int.toString(Array.getUnsafe(kindArray, 1))
        | _ => 
          let first = Int.toString(Array.getUnsafe(kindArray, 0))
          let second = Int.toString(Array.getUnsafe(kindArray, 1))
          let rest = Array.sliceToEnd(kindArray, ~start=2)
          let restStr = Array.reduce(rest, "", (acc, k) => acc ++ " OR " ++ Int.toString(k))
          first ++ " OR " ++ second ++ restStr
        }
        `the transaction kind is ${kindList}`
      }
      parts->Array.push(kindCondition)->ignore
    }
    
    // Contract address condition
    if Array.length(contractAddressArray) > 0 {
      let contractCondition = if Array.length(contractAddressArray) === 1 {
        `the contract address is ${Array.getUnsafe(contractAddressArray, 0)}`
      } else {
        let contractList = Array.join(contractAddressArray, " OR ")
        `the contract address is ${contractList}`
      }
      parts->Array.push(contractCondition)->ignore
    }
    
    if Array.length(parts) > 0 {
      `Match transactions where: ${Array.join(parts, " AND ")}`
    } else {
      "No filters applied - will match all transactions"
    }
  }
}

let generateBooleanHierarchy = (filterState: transactionFilterState) => {
  let {from_, to_, sighash, status, kind, contractAddress} = filterState
  let fromArray = from_->Option.getOr([])
  let toArray = to_->Option.getOr([])
  let sighashArray = sighash->Option.getOr([])
  let kindArray = kind->Option.getOr([])
  let contractAddressArray = contractAddress->Option.getOr([])
  
  let hasAnyFilter = 
    Array.length(fromArray) > 0 ||
    Array.length(toArray) > 0 ||
    Array.length(sighashArray) > 0 ||
    Option.isSome(status) ||
    Array.length(kindArray) > 0 ||
    Array.length(contractAddressArray) > 0
  
  if !hasAnyFilter {
    "No filters"
  } else {
    let lines = []
    
    let conditions = []
    if Array.length(fromArray) > 0 { conditions->Array.push("from")->ignore }
    if Array.length(toArray) > 0 { conditions->Array.push("to")->ignore }
    if Array.length(sighashArray) > 0 { conditions->Array.push("sighash")->ignore }
    if Option.isSome(status) { conditions->Array.push("status")->ignore }
    if Array.length(kindArray) > 0 { conditions->Array.push("kind")->ignore }
    if Array.length(contractAddressArray) > 0 { conditions->Array.push("contractAddress")->ignore }
    
    let hasMultipleConditions = Array.length(conditions) > 1
    
    if hasMultipleConditions {
      lines->Array.push("AND")->ignore
    }
    
    let conditionIndex = ref(0)
    
    // From addresses
    if Array.length(fromArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(fromArray) === 1 {
        lines->Array.push(`${prefix}from = ${Array.getUnsafe(fromArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (from)`)->ignore
        Array.forEachWithIndex(fromArray, (addr, i) => {
          let isLastAddr = i === Array.length(fromArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else {
              isLastAddr ? "│   └── " : "│   ├── "
            }
          } else {
            isLastAddr ? "└── " : "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }
    
    // To addresses
    if Array.length(toArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(toArray) === 1 {
        lines->Array.push(`${prefix}to = ${Array.getUnsafe(toArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (to)`)->ignore
        Array.forEachWithIndex(toArray, (addr, i) => {
          let isLastAddr = i === Array.length(toArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else {
              isLastAddr ? "│   └── " : "│   ├── "
            }
          } else {
            isLastAddr ? "└── " : "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }
    
    // Sighash
    if Array.length(sighashArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(sighashArray) === 1 {
        lines->Array.push(`${prefix}sighash = ${Array.getUnsafe(sighashArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (sighash)`)->ignore
        Array.forEachWithIndex(sighashArray, (sig, i) => {
          let isLastSig = i === Array.length(sighashArray) - 1
          let sigPrefix = if hasMultipleConditions {
            if isLast {
              isLastSig ? "    └── " : "    ├── "
            } else {
              isLastSig ? "│   └── " : "│   ├── "
            }
          } else {
            isLastSig ? "└── " : "├── "
          }
          lines->Array.push(`${sigPrefix}${sig}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }
    
    // Status
    switch status {
    | Some(s) => 
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      let statusText = s === 1 ? "success" : "failed"
      lines->Array.push(`${prefix}status = ${Int.toString(s)} (${statusText})`)->ignore
      conditionIndex := conditionIndex.contents + 1
    | None => ()
    }
    
    // Kind
    if Array.length(kindArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(kindArray) === 1 {
        lines->Array.push(`${prefix}kind = ${Int.toString(Array.getUnsafe(kindArray, 0))}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (kind)`)->ignore
        Array.forEachWithIndex(kindArray, (k, i) => {
          let isLastKind = i === Array.length(kindArray) - 1
          let kindPrefix = if hasMultipleConditions {
            if isLast {
              isLastKind ? "    └── " : "    ├── "
            } else {
              isLastKind ? "│   └── " : "│   ├── "
            }
          } else {
            isLastKind ? "└── " : "├── "
          }
          lines->Array.push(`${kindPrefix}${Int.toString(k)}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }
    
    // Contract Address
    if Array.length(contractAddressArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(contractAddressArray) === 1 {
        lines->Array.push(`${prefix}contractAddress = ${Array.getUnsafe(contractAddressArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (contractAddress)`)->ignore
        Array.forEachWithIndex(contractAddressArray, (addr, i) => {
          let isLastAddr = i === Array.length(contractAddressArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else {
              isLastAddr ? "│   └── " : "│   ├── "
            }
          } else {
            isLastAddr ? "└── " : "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }
    
    Array.join(lines, "\n")
  }
} 
