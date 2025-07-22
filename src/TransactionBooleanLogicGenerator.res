type transactionFilterState = {
  from_: array<string>,
  to_: array<string>,
  sighash: array<string>,
  status: option<int>,
  kind: array<int>,
  contractAddress: array<string>,
}

let generateEnglishDescription = (filterState: transactionFilterState) => {
  let {from_, to_, sighash, status, kind, contractAddress} = filterState
  
  let hasAnyFilter = 
    Array.length(from_) > 0 ||
    Array.length(to_) > 0 ||
    Array.length(sighash) > 0 ||
    Option.isSome(status) ||
    Array.length(kind) > 0 ||
    Array.length(contractAddress) > 0
  
  if !hasAnyFilter {
    "No filters applied - will match all transactions"
  } else {
    let parts = []
    
    // From condition
    if Array.length(from_) > 0 {
      let fromCondition = if Array.length(from_) === 1 {
        `the sender address is ${Array.getUnsafe(from_, 0)}`
      } else {
        let fromList = from_->Array.join(" OR ")
        `the sender address is ${fromList}`
      }
      parts->Array.push(fromCondition)->ignore
    }
    
    // To condition
    if Array.length(to_) > 0 {
      let toCondition = if Array.length(to_) === 1 {
        `the recipient address is ${Array.getUnsafe(to_, 0)}`
      } else {
        let toList = to_->Array.join(" OR ")
        `the recipient address is ${toList}`
      }
      parts->Array.push(toCondition)->ignore
    }
    
    // Sighash condition
    if Array.length(sighash) > 0 {
      let sighashCondition = if Array.length(sighash) === 1 {
        `the function signature is ${Array.getUnsafe(sighash, 0)}`
      } else {
        let sighashList = sighash->Array.join(" OR ")
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
    if Array.length(kind) > 0 {
      let kindCondition = if Array.length(kind) === 1 {
        `the transaction kind is ${Int.toString(Array.getUnsafe(kind, 0))}`
      } else {
        let kindList = kind->Array.map(Int.toString)->Array.join(" OR ")
        `the transaction kind is ${kindList}`
      }
      parts->Array.push(kindCondition)->ignore
    }
    
    // Contract address condition
    if Array.length(contractAddress) > 0 {
      let contractCondition = if Array.length(contractAddress) === 1 {
        `the contract address is ${Array.getUnsafe(contractAddress, 0)}`
      } else {
        let contractList = contractAddress->Array.join(" OR ")
        `the contract address is ${contractList}`
      }
      parts->Array.push(contractCondition)->ignore
    }
    
    if Array.length(parts) > 0 {
      `Match transactions where: ${parts->Array.join(" AND ")}`
    } else {
      "No filters applied - will match all transactions"
    }
  }
}

let generateBooleanHierarchy = (filterState: transactionFilterState) => {
  let {from_, to_, sighash, status, kind, contractAddress} = filterState
  
  let hasAnyFilter = 
    Array.length(from_) > 0 ||
    Array.length(to_) > 0 ||
    Array.length(sighash) > 0 ||
    Option.isSome(status) ||
    Array.length(kind) > 0 ||
    Array.length(contractAddress) > 0
  
  if !hasAnyFilter {
    "No filters"
  } else {
    let lines = []
    
    let conditions = []
    if Array.length(from_) > 0 { conditions->Array.push("from")->ignore }
    if Array.length(to_) > 0 { conditions->Array.push("to")->ignore }
    if Array.length(sighash) > 0 { conditions->Array.push("sighash")->ignore }
    if Option.isSome(status) { conditions->Array.push("status")->ignore }
    if Array.length(kind) > 0 { conditions->Array.push("kind")->ignore }
    if Array.length(contractAddress) > 0 { conditions->Array.push("contractAddress")->ignore }
    
    let hasMultipleConditions = Array.length(conditions) > 1
    
    if hasMultipleConditions {
      lines->Array.push("AND")->ignore
    }
    
    let conditionIndex = ref(0)
    
    // From addresses
    if Array.length(from_) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(from_) === 1 {
        lines->Array.push(`${prefix}from = ${Array.getUnsafe(from_, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (from)`)->ignore
        Array.forEachWithIndex(from_, (i, addr) => {
          let isLastAddr = i === Array.length(from_) - 1
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
    if Array.length(to_) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(to_) === 1 {
        lines->Array.push(`${prefix}to = ${Array.getUnsafe(to_, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (to)`)->ignore
        Array.forEachWithIndex(to_, (i, addr) => {
          let isLastAddr = i === Array.length(to_) - 1
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
    if Array.length(sighash) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(sighash) === 1 {
        lines->Array.push(`${prefix}sighash = ${Array.getUnsafe(sighash, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (sighash)`)->ignore
        Array.forEachWithIndex(sighash, (i, sig) => {
          let isLastSig = i === Array.length(sighash) - 1
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
    if Array.length(kind) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(kind) === 1 {
        lines->Array.push(`${prefix}kind = ${Int.toString(Array.getUnsafe(kind, 0))}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (kind)`)->ignore
        Array.forEachWithIndex(kind, (i, k) => {
          let isLastKind = i === Array.length(kind) - 1
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
    if Array.length(contractAddress) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? (isLast ? "└── " : "├── ") : ""
      
      if Array.length(contractAddress) === 1 {
        lines->Array.push(`${prefix}contractAddress = ${Array.getUnsafe(contractAddress, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (contractAddress)`)->ignore
        Array.forEachWithIndex(contractAddress, (i, addr) => {
          let isLastAddr = i === Array.length(contractAddress) - 1
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
    
    lines->Array.join("\n")
  }
} 
