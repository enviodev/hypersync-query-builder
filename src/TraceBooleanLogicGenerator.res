open QueryStructure

type traceFilterState = QueryStructure.traceSelection

let generateEnglishDescription = (filterState: traceFilterState) => {
  let {from_, to_, address, callType, rewardType, kind, sighash} = filterState
  let fromArray = from_->Option.getOr([])
  let toArray = to_->Option.getOr([])
  let addressArray = address->Option.getOr([])
  let callTypeArray = callType->Option.getOr([])
  let rewardTypeArray = rewardType->Option.getOr([])
  let kindArray = kind->Option.getOr([])
  let sighashArray = sighash->Option.getOr([])

  let hasAnyFilter =
    Array.length(fromArray) > 0 ||
    Array.length(toArray) > 0 ||
    Array.length(addressArray) > 0 ||
    Array.length(callTypeArray) > 0 ||
    Array.length(rewardTypeArray) > 0 ||
    Array.length(kindArray) > 0 ||
    Array.length(sighashArray) > 0

  if !hasAnyFilter {
    "No filters applied - will match all traces"
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

    // Address condition
    if Array.length(addressArray) > 0 {
      let addressCondition = if Array.length(addressArray) === 1 {
        `the address is ${Array.getUnsafe(addressArray, 0)}`
      } else {
        let addressList = Array.join(addressArray, " OR ")
        `the address is ${addressList}`
      }
      parts->Array.push(addressCondition)->ignore
    }

    // Call type condition
    if Array.length(callTypeArray) > 0 {
      let callTypeCondition = if Array.length(callTypeArray) === 1 {
        `the call type is ${Array.getUnsafe(callTypeArray, 0)}`
      } else {
        let callTypeList = Array.join(callTypeArray, " OR ")
        `the call type is ${callTypeList}`
      }
      parts->Array.push(callTypeCondition)->ignore
    }

    // Reward type condition
    if Array.length(rewardTypeArray) > 0 {
      let rewardTypeCondition = if Array.length(rewardTypeArray) === 1 {
        `the reward type is ${Array.getUnsafe(rewardTypeArray, 0)}`
      } else {
        let rewardTypeList = Array.join(rewardTypeArray, " OR ")
        `the reward type is ${rewardTypeList}`
      }
      parts->Array.push(rewardTypeCondition)->ignore
    }

    // Kind condition
    if Array.length(kindArray) > 0 {
      let kindCondition = if Array.length(kindArray) === 1 {
        `the kind is ${Array.getUnsafe(kindArray, 0)}`
      } else {
        let kindList = Array.join(kindArray, " OR ")
        `the kind is ${kindList}`
      }
      parts->Array.push(kindCondition)->ignore
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

    "Match traces where: " ++ Array.join(parts, " AND ")
  }
}

let generateBooleanHierarchy = (filterState: traceFilterState) => {
  let {from_, to_, address, callType, rewardType, kind, sighash} = filterState
  let fromArray = from_->Option.getOr([])
  let toArray = to_->Option.getOr([])
  let addressArray = address->Option.getOr([])
  let callTypeArray = callType->Option.getOr([])
  let rewardTypeArray = rewardType->Option.getOr([])
  let kindArray = kind->Option.getOr([])
  let sighashArray = sighash->Option.getOr([])

  let hasAnyFilter =
    Array.length(fromArray) > 0 ||
    Array.length(toArray) > 0 ||
    Array.length(addressArray) > 0 ||
    Array.length(callTypeArray) > 0 ||
    Array.length(rewardTypeArray) > 0 ||
    Array.length(kindArray) > 0 ||
    Array.length(sighashArray) > 0

  if !hasAnyFilter {
    "No filters"
  } else {
    let lines = []

    let conditions = []
    if Array.length(fromArray) > 0 {
      conditions->Array.push("from")->ignore
    }
    if Array.length(toArray) > 0 {
      conditions->Array.push("to")->ignore
    }
    if Array.length(addressArray) > 0 {
      conditions->Array.push("address")->ignore
    }
    if Array.length(callTypeArray) > 0 {
      conditions->Array.push("callType")->ignore
    }
    if Array.length(rewardTypeArray) > 0 {
      conditions->Array.push("rewardType")->ignore
    }
    if Array.length(kindArray) > 0 {
      conditions->Array.push("kind")->ignore
    }
    if Array.length(sighashArray) > 0 {
      conditions->Array.push("sighash")->ignore
    }

    let hasMultipleConditions = Array.length(conditions) > 1

    if hasMultipleConditions {
      lines->Array.push("AND")->ignore
    }

    let conditionIndex = ref(0)

    // From addresses
    if Array.length(fromArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(fromArray) === 1 {
        lines->Array.push(`${prefix}from = ${Array.getUnsafe(fromArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (from)`)->ignore
        Array.forEachWithIndex(fromArray, (addr, i) => {
          let isLastAddr = i === Array.length(fromArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else if isLastAddr {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastAddr {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // To addresses
    if Array.length(toArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(toArray) === 1 {
        lines->Array.push(`${prefix}to = ${Array.getUnsafe(toArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (to)`)->ignore
        Array.forEachWithIndex(toArray, (addr, i) => {
          let isLastAddr = i === Array.length(toArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else if isLastAddr {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastAddr {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Addresses
    if Array.length(addressArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(addressArray) === 1 {
        lines->Array.push(`${prefix}address = ${Array.getUnsafe(addressArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (address)`)->ignore
        Array.forEachWithIndex(addressArray, (addr, i) => {
          let isLastAddr = i === Array.length(addressArray) - 1
          let addrPrefix = if hasMultipleConditions {
            if isLast {
              isLastAddr ? "    └── " : "    ├── "
            } else if isLastAddr {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastAddr {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${addrPrefix}${addr}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Call types
    if Array.length(callTypeArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(callTypeArray) === 1 {
        lines->Array.push(`${prefix}callType = ${Array.getUnsafe(callTypeArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (callType)`)->ignore
        Array.forEachWithIndex(callTypeArray, (callType, i) => {
          let isLastCallType = i === Array.length(callTypeArray) - 1
          let callTypePrefix = if hasMultipleConditions {
            if isLast {
              isLastCallType ? "    └── " : "    ├── "
            } else if isLastCallType {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastCallType {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${callTypePrefix}${callType}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Reward types
    if Array.length(rewardTypeArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(rewardTypeArray) === 1 {
        lines->Array.push(`${prefix}rewardType = ${Array.getUnsafe(rewardTypeArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (rewardType)`)->ignore
        Array.forEachWithIndex(rewardTypeArray, (rewardType, i) => {
          let isLastRewardType = i === Array.length(rewardTypeArray) - 1
          let rewardTypePrefix = if hasMultipleConditions {
            if isLast {
              isLastRewardType ? "    └── " : "    ├── "
            } else if isLastRewardType {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastRewardType {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${rewardTypePrefix}${rewardType}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Kinds
    if Array.length(kindArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(kindArray) === 1 {
        lines->Array.push(`${prefix}kind = ${Array.getUnsafe(kindArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (kind)`)->ignore
        Array.forEachWithIndex(kindArray, (k, i) => {
          let isLastKind = i === Array.length(kindArray) - 1
          let kindPrefix = if hasMultipleConditions {
            if isLast {
              isLastKind ? "    └── " : "    ├── "
            } else if isLastKind {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastKind {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${kindPrefix}${k}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    // Sighash
    if Array.length(sighashArray) > 0 {
      let isLast = conditionIndex.contents === Array.length(conditions) - 1
      let prefix = hasMultipleConditions ? isLast ? "└── " : "├── " : ""

      if Array.length(sighashArray) === 1 {
        lines->Array.push(`${prefix}sighash = ${Array.getUnsafe(sighashArray, 0)}`)->ignore
      } else {
        lines->Array.push(`${prefix}OR (sighash)`)->ignore
        Array.forEachWithIndex(sighashArray, (sig, i) => {
          let isLastSig = i === Array.length(sighashArray) - 1
          let sigPrefix = if hasMultipleConditions {
            if isLast {
              isLastSig ? "    └── " : "    ├── "
            } else if isLastSig {
              "│   └── "
            } else {
              "│   ├── "
            }
          } else if isLastSig {
            "└── "
          } else {
            "├── "
          }
          lines->Array.push(`${sigPrefix}${sig}`)->ignore
        })
      }
      conditionIndex := conditionIndex.contents + 1
    }

    Array.join(lines, "\n")
  }
}
